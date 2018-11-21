package SL::Controller::Database;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Pg;

use SL::Model::Config;
use utf8;

sub index {
    my $c = shift;

    my $dbuser = $c->param('dbuser');  # This is *really* needed
    my $dbpasswd = $c->param('dbpasswd');
    my $dbhost = $c->param('dbhost');
    my $dbport = $c->param('dbport') || 5432;
    my $dbdefault = $c->param('dbdefault');

    my $pg = Mojo::Pg->new("postgresql://$dbuser:$dbpasswd\@$dbhost:$dbport/$dbdefault");
    # my $version =
    #     $pg->db->query('select version() as version')->hash->{version};

    my $sql = qq|
SELECT
  datname,
  (SELECT pg_size_pretty(pg_database_size(datname)))
FROM pg_database
WHERE datname NOT IN ('postgres', 'template0', 'template1')
|;
    
    my $dbinfos =  $pg->db->query($sql)->arrays->to_array;
    #map { $_ = $_->[0] } @$dbinfos;
    
    $c->render(
        type => $c->param('who'),
        dbinfos => $dbinfos,
    );
}



1;
