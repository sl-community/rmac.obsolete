#!/usr/bin/perl
use strict;
use warnings;
use feature qw(say);
use File::Path qw(make_path remove_tree);
use YAML::Tiny;
use Data::Dumper;
use File::Basename;
use Time::Piece;

# We will be called with e.g. "/sl-community/rmac/develop"


my $instance_identifier = $ARGV[0] // die "No instance name or id given\n";


my $instances = YAML::Tiny->read( '/ledgersetup.yml' )->[0]{instances};



my %info = (
    timestamp => Time::Piece->new->strftime,
    status    => 'Unknown',
);


my ($instance) = grep {
    (exists $_->{name} && $_->{name} eq $instance_identifier)
        || (exists $_->{id} && $_->{id} eq $instance_identifier)
    } @$instances;

defined $instance
    || die "Instance with identifier '$instance_identifier' not found in config\n";


say STDERR "Initializing $instance_identifier...";


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
$instance->{databases}{names} = [];

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


my $infofile = "/tmp/ledgersetup/runinfo";
make_path(dirname($infofile));

say STDERR "Writing run information to $infofile";


open(my $runinfo, ">", $infofile) || die $!;
$Data::Dumper::Terse=1;
print $runinfo Dumper(\%info);
close $runinfo;


#########################################################################


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



sub expand_list_of_dumps {
    my @result = ();

    say STDERR "expand_list_of_dumps: @_";
    
    foreach my $entry (@_) {
        say STDERR "Parsing entry: $entry";
        $entry =~ s/\{\{(.*)?\}\}/_evaluate($1)/ge;
        say STDERR "Entry before globbing: $entry";
        push @result, glob($entry);
    }

    say STDERR "Expanded list of dumps: @result";

    $info{status} = "No database dump available";
    
    return @result;
}



sub _evaluate {
    my $expr = shift;

    die "Invalid expression: $expr\n" unless $expr =~ m|build_time\(|;
    
    return eval $expr;
}

sub build_time {
    my $format = shift;

    return Time::Piece->new->localtime->strftime($format); 
}
