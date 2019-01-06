##################################
package SL::Model::Calc::Document;
##################################
use strict;
use warnings;
use feature ':5.10';
use utf8;

use Cwd qw(abs_path cwd);
use File::Spec;
use File::Basename;
use File::Copy;
use OpenOffice::OODoc;
use YAML::Tiny;
use Data::Dumper;
use File::pushd;

#use SL::Log;



sub new {
    my $class = shift;
    my %args = @_;

    my $self = {
        config      => $args{config},
        src         => $args{src},
        dest        => $args{dest},
        workdir     => $args{workdir},
    };

    
    my $resource_path = abs_path(File::Spec->catfile(
        dirname(__FILE__),
        'resources',
    ));
    $self->{resource_path} = $resource_path;
    
    my $src  = File::Spec->catfile($resource_path, 'docs', $self->{src});

    my $dest = File::Spec->catfile($args{workdir}, $self->{dest});
    copy($src, $dest) || die $!;

    $self->{dest} = $dest;

    $self->{doc} = odfDocument(file => $dest);
    $self->{doc}->normalizeSheet('Sheet1', 'full');


    bless $self, $class;

    return $self;
}        


sub fill_in {
    my $self = shift;
    my %args = @_;
    

    if (exists $args{text}) {

        while (my ($index, $cell) = each @{$args{cells}}) {
            $self->{doc}->updateCell(0, $cell, $args{text}[$index]);
       }
    }
    elsif (exists $args{from_sql}) {

        my ($filename, $key) = split(m|/|, $args{from_sql});
        
        my $yml_file = File::Spec->catfile(
            $self->{resource_path},
            'queries',
            "$filename.yml"
        );

        my $yaml = YAML::Tiny->read($yml_file);
        my $sql = $yaml->[0]{$key};

        my $pg = Mojo::Pg->new($self->{config}->pg_connstr);
        
        my $result = $pg->db->query($sql, @{$args{bind_values}})
            ->arrays->to_array;

        #say STDERR Dumper($result);

        return if $args{test};
        
        @$result == 1 || die "Not exactly one row"; # TODO

        
        while (my ($index, $cell) = each @{$args{cells}}) {
            #say STDERR "Filling: $cell <= $result->[0][$index]";
            $self->{doc}->updateCell(0, $cell, $result->[0][$index]);
        }

        return $result->[0];
    }
}


sub update {
    my $self = shift;
    my %args = @_;
    
    foreach my $cell (@{$args{cells}}) {
        #say STDERR "Updating $cell...";
        $self->{doc}->updateCell(0, $cell, $self->{doc}->getCellValue(0, $cell));
    }
}

sub save {
    my $self = shift;
    $self->{doc}->save;
}


sub download_name {
    my $self = shift;
    my ($name) = @_;

    my $dir = pushd(dirname($self->{dest}));

    symlink(basename($self->{dest}), $name);

    $self->{download_name} = $name;
}




1;