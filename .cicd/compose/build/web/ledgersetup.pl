#!/usr/bin/perl
use strict;
use warnings;
use feature qw(say);
use Getopt::Long;
use File::Path qw(make_path remove_tree);
use YAML::Tiny;
use Data::Dumper;
use File::Basename;


my $instance_name = $ARGV[0] // die "No instance name given\n";

my %opts;

GetOptions(
    \%opts,
    "dry-run",
    "initialize",
#    "rootpw=s",
#    "user=s",
#    "pass=s",
#    "lang=s",
#    "dataset=s",
    "debug",
) || exit 1;


my $instances = YAML::Tiny->read( '/config.yml' )->[0]{instances};

##say Dumper $instances;


say STDERR "Initializing $instance_name...";

my ($instance) = grep { $_->{name} eq $instance_name } @$instances;

defined $instance || die "Instance $instance_name not found in config\n";

# Set admin/root password
defined $instance->{rootpw} || die "Instance has no root password\n";
my $rootpw_hash = crypt($instance->{rootpw}, "root");

chdir("/srv/www/sql-ledger") || die $!;
make_path("users");

open(my $members, ">", 'users/members') || die $!;

print $members <<EOF;
# Run my Accounts Accounting members

[root login]
password=$rootpw_hash
EOF
close $members;


# Eventually wait for db to come up:
my $tries = 0;
my $db_ready = 0;
while ($tries <= 10) {
    
    if (system("pg_isready -h db") == 0) {
        $db_ready = 1;
        last;
    }

    say STDERR "db is not yet ready. Waiting...";
    sleep 5;
    $tries++;
}

die "Database not reachable\n" unless $db_ready;


# Create db user:
system "createuser -h db -e -U postgres --superuser sql-ledger";


# Create and load databases:
foreach my $dumpfile (expand_list_of_dumps(@{$instance->{databases}{dumps}})) {
    if (-r $dumpfile) {
        say STDERR "$dumpfile is readable";
    }
    else {
        die "Unreadable dumpfile: $dumpfile\n";
    }

    my ($dbname) = $dumpfile =~ m|.*/([^.]+)|;

    push @{$instance->{databases}{names}}, $dbname;
    

    my $db_exists = system("psql -h db -U postgres -d $dbname -c '' >/dev/null 2>&1") == 0;

    say STDERR "Database $dbname " .
        ($db_exists?  "exists" : "does not exist");


    if ($db_exists && $instance->{databases}{force_recreate}) {
        say STDERR "Drop database due to force_recreate: $dbname";
        system "dropdb -h db -e -U postgres $dbname";

        $db_exists = 0;
    }
    
    if (!$db_exists) {
        say STDERR "Setup database: $dbname";
        # CREATE DATABASE is included in dump.
        #system "createdb -h db -e -U postgres $dbname"; 
        system "acat $dumpfile | psql -o /dev/null -h db -U postgres -q";
    }
}


# Create users

foreach my $user (@{$instance->{users}}) {

    my $name = $user->{name} || die "No name given\n";

    my $lang = $user->{lang} // 'gb';
    unless (grep { $_ eq $lang } qw(de gb)) {
        die "Unsupported language: $lang";
    }

    my $pass = $user->{pass} || die "No pass given\n";
    my $database = $user->{database} || die "No database given\n";
    
    say STDERR "Create user $name (lang=$lang, database=$database)";
    
    

    my $settings = {
        gb => {
            dateformat   => 'yyyy-mm-dd',
            numberformat => '1,000.00',
            countrycode  => '',
            dboptions    => '',
        },
        de => {
            dateformat   => 'dd.mm.yy',
            numberformat => '1.000,00',
            countrycode  => 'de',
            dboptions    => "set DateStyle to 'GERMAN'",
        }
    };

    
    chdir("/srv/www/sql-ledger") || die $!;
    
    open(my $members, ">>", 'users/members') || die $!;

    print $members get_members_entry(
        name     => $name,
        database => $database,
        settings => $settings->{$lang},
        pass     => $pass,
    );

    close $members;
}


#say Dumper $instance;



sub get_members_entry {
    my %args = @_;

    my $pw_hash = crypt($args{pass}, substr($args{name}, 0, 2));

    my @databases = ($args{database});
    my $multidb_user = 0;

    if ($args{database} eq '*') {
        @databases = @{$instance->{databases}{names}};
        $multidb_user = 1;
    }

    
    my $result = "";
    
    foreach my $db (@databases) {

        my $username = $multidb_user? "$args{name}\@$db" : $args{name}; 
        
        $result .= qq|
[$username]
acs=
company=$db
countrycode=$args{settings}{countrycode}
dateformat=$args{settings}{dateformat}
dbconnect=dbi:Pg:dbname=$db;host=db
dbdriver=Pg
dbhost=db
dbname=$db
dboptions=$args{settings}{dboptions}
dbpasswd=
dbport=
dbuser=sql-ledger
department=
department_id=
email=$args{name}\@localhost
fax=
menuwidth=155
name=$args{name}
numberformat=$args{settings}{numberformat}
outputformat=html
password=$pw_hash
printer=
role=user
sid=
signature=
stylesheet=sql-ledger.css
tel=
templates=templates/$args{name}
timeout=10800
vclimit=1000
warehouse=
warehouse_id=
|;

    }

    return $result;
}





#########################################################################
use Time::Piece;
sub expand_list_of_dumps {
    my @result = ();
    
    foreach my $entry (@_) {
        $entry =~ s/\{\{(.*)?\}\}/_evaluate($1)/ge;
        push @result, glob($entry);
    }
    return @result;
}

sub _evaluate {
    my $expr = shift;

    die "Invalid expression: $expr\n" unless $expr =~ m|current_date\(|;
    
    return eval $expr;
}

sub current_date {
    my $format = shift;

    return Time::Piece->new->localtime->strftime($format); 
}
#########################################################################
