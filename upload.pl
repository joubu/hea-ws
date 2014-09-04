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
my $data = $cgi->param('POSTDATA');
if ($data) {

    $data = JSON::decode_json($data);

    if (!$data->{library}) {
        Hea::Response::json({
            error => "Missing 'library' key in data",
        });
        exit;
    }

    unless($data->{library}{id}) {
        $data->{library}{id} = Hea::Library::create($data->{library});
    } else {
        Hea::Library::update($data->{library});
        Hea::Volumetry::delete_all($data->{library}{id});
        Hea::SystemPreference::delete_all($data->{library}{id});
    }
    Hea::Volumetry::create($data->{library}{id}, $data->{volumetry});
    Hea::SystemPreference::create($data->{library}{id}, $data->{systempreferences});
}

Hea::Response::json({
    library => $data->{library},
});
