package SL::Controller::Database;
use Mojo::Base 'Mojolicious::Controller';

use SL::Model::Config;
use strict;
use warnings;
use utf8;
use POSIX qw/strftime/;


sub backup_restore {
    my $c = shift;

    my $sql = qq{
SELECT
  datname,
  (SELECT round(pg_database_size(datname) / 1024.0 / 1024.0, 1)) || ' MB'
FROM pg_database
WHERE datname NOT IN ('postgres', 'template0', 'template1')
ORDER BY datname
};
    my $pg = $c->mojo_pg->{object};
    
    $c->render(
        dbinfos => $pg->db->query($sql)->arrays->to_array,
    );
}


sub backup {
    my $c = shift;

    use Data::Dumper;

    #print STDERR Dumper $c->pg;

    my $dbname = $c->mojo_pg->{access_data}{dbname} || 'database';
    my $iso_date = strftime("%Y-%m-%d", localtime);
    
    $c->res->headers->content_type("application/octet-stream");
    $c->res->headers->content_disposition(
        "attachment; filename=${dbname}_${iso_date}.sql.gz"
    );

    my $pg_dump_cmd = join(' ',
                           'pg_dump',
                           '--dbname', $c->mojo_pg->{connstr},
                           '| gzip -c'
                       );
    say STDERR $pg_dump_cmd;
    
    open(my $cmd_handle, "-|", $pg_dump_cmd) || die $!;

    my $content;
    while (read($cmd_handle, $content, 1024) ) {
        
        $c->write($content);
    }
    close $cmd_handle;
    $c->finish();
}


1;
