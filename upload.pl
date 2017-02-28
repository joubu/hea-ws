#!/usr/bin/perl

use Modern::Perl;
use CGI;
use JSON;
use DBI;

use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Hea::Dbh;
use Hea::Installation;
use Hea::Library;
use Hea::Volumetry;
use Hea::SystemPreference;
use Hea::Response;

my $cgi = new CGI;
my $data = $cgi->param('POSTDATA');
my $installation;
if ($data) {

    $data = JSON::decode_json($data);

    unless ( $data->{library} or $data->{installation} ) {
        Hea::Response::json({
            error => "Missing 'library' or 'installation' key in data",
        });
        exit;
    }

    my @libraries = ();
    if ( $data->{library} ) {
        my $library = $data->{library};
        $installation = {
            name         => $library->{name},
            url          => $library->{url},
            country      => $library->{country},
            geolocation  => $library->{geolocation},
            koha_id      => $library->{id},
            library_type => $library->{type},
        };
        push @libraries,
          {
            name    => $library->{name},
            url     => $library->{url},
            country => $library->{country},
            geolocation  => $library->{geolocation},
          };
    } else {
        $installation = $data->{installation};
        if ( $data->{libraries} and @{ $data->{libraries} } ) {
            @libraries = @{ $data->{libraries} };
        } else {
            push @libraries,
              {
                name    => $installation->{name},
                url     => $installation->{url},
                country => $installation->{country},
                geolocation  => $installation->{geolocation},
              };
        }
    }

    $installation->{type} = '' unless grep {/^$installation->{type}$/} qw( public school academic research private societyAssociation corporate government religiousOrg subscription);
    $installation->{library_type} = $installation->{type};
    unless($installation->{koha_id}) {
        $installation = Hea::Installation::create($installation);
    } else {
        my $existing_install = Hea::Installation::get($installation->{koha_id});
        if ( $existing_install ) {
            Hea::Installation::update($installation);
            Hea::Library::delete_all($installation->{koha_id});
            Hea::Volumetry::delete_all($installation->{koha_id});
            Hea::SystemPreference::delete_all($installation->{koha_id});
        } else {
            $installation = Hea::Installation::create($installation);
        }
    }

    for my $library ( @libraries ) {
        $library->{koha_id} = $installation->{koha_id};
        Hea::Library::create($library);
    }
    Hea::Volumetry::create($installation->{koha_id}, $data->{volumetry});
    Hea::SystemPreference::create($installation->{koha_id}, $data->{systempreferences});
}

if ( $data->{library} ){
    Hea::Response::json({
        library => { id => $installation->{koha_id} }
    });
} else {
    Hea::Response::json({
        koha_id => $installation->{koha_id}, id => $installation->{id},
    });
}
