package Hea::Response;

use CGI;
use JSON;

sub json {
    my ($data) = @_;
    my $cgi = new CGI;

    print $cgi->header('application/json');
    print to_json($data);
}

1;
