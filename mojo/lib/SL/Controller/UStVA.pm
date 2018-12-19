package SL::Controller::UStVA;
use Mojo::Base 'Mojolicious::Controller';
use Mojolicious::Static;
use Mojo::File;

use SL::Model::Config;
use File::Spec;
use File::Basename;
use utf8;
use Mojo::Util;

sub download {
    my $c = shift;

    $c->render(text => $ENV{REQUEST_URI});
}



1;
