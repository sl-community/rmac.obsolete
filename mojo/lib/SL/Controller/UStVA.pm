package SL::Controller::UStVA;
use strict;
use warnings;
use Mojo::Base 'Mojolicious::Controller';
use Mojolicious::Static;
use Mojo::File;

use SL::Model::Config;
use SL::Model::Calc::Document;

use utf8;
#use Mojo::Util;



sub download {
    my $c = shift;

    my $conf = SL::Model::Config->instance($c);

    my $workdir = $c->private_spool_realm("ustva", empty => 1);
    
    my $text = "<pre>";

    $text .= $ENV{REQUEST_URI} . "\n";
    $text .= $c->dumper($conf) . "\n";

    $text .= "Workdir: $workdir\n";
    
    $text .= "</pre>";


    
    my $doc = SL::Model::Calc::Document->new(
        config    => $conf,
        src       => "ustva-template.ods",
        dest      => "out.ods",
        workdir   => $workdir,
    );

    
    # Headline:
    $doc->fill_in(
        cells => ["B1"],
        text  => ["Umsatzsteuer-Voranmeldung " . $c->param("year")],
    );

    
    # Voranmeldungszeitraum:
    my $interval = $c->param("interval");
    
    if ($interval == 1) { # Month
        my %field_map = (
            '01' => "G4", '02' => "G5", '03' => "G6",
            '04' => "G7", '05' => "G8", '06' => "G9",
            '07' => "I4", '08' => "I5", '09' => "I6",
            '10' => "I7", '11' => "I8", '12' => "I9",
        );

        $doc->fill_in(
            cells => [$field_map{$c->param("month")}],
            text  => ["X"],
        );   
    }
    elsif ($interval == 3) { # Quarter
        my %field_map = (
            '01' => "K4",
            '04' => "K5",
            '07' => "K6",
            '10' => "K7",
        );

        $doc->fill_in(
            cells => [$field_map{$c->param("month")}],
            text  => ["X"],
        );   
    }

    
    $doc->fill_in(
        cells    => ["B4", "B5", "B6"],
        from_sql => "ustva/firma",
    );

    $doc->fill_in(
        cells    => ["B9"],
        from_sql => "ustva/steuernummer",
    );

    $doc->fill_in(
        cells    => ["D9"],
        from_sql => "ustva/ust_idnr",
    );

    $doc->save;


    
    
    $c->render(text => $text);
}



1;
