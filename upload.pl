#!/usr/bin/perl

use Modern::Perl;
use CGI;
use JSON;
use DBI;

use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Hea::Dbh;
use Hea::Library;
use Hea::Volumetry;
use Hea::SystemPreference;
use Hea::Response;

my $cgi = new CGI;
my $data = $cgi->param('data');
my $library_id;
if ($data) {
    $data = from_json($data);

    if (!$data->{library}) {
        Hea::Response::json({
            error => "Missing 'library' key in data",
        });
        exit;
    }

    if(!$data->{library}->{id}) {
        $data->{library}->{id} = Hea::Library::create($data->{library});
    } else {
        Hea::Library::update($data->{library});
    }

    my $library_id = $data->{library}->{id};
    $data->{library} = Hea::Library::get($library_id);

    if ($data->{volumetry}) {
        Hea::Volumetry::create($library_id, $data->{volumetry});
    }

    if ($data->{systempreferences}) {
        Hea::SystemPreference::update($library_id, $data->{systempreferences});
    }
}

Hea::Response::json({
    library => $data->{library},
});
