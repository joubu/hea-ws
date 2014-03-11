package Hea::Dbh;

use DBI;
use YAML qw/LoadFile/;

use FindBin qw/$Bin/;

my $dbh;

sub dbh {
    my $conf = LoadFile("$Bin/database.yml");
    $dbh //= DBI->connect('dbi:mysql:' . $conf->{database}, $conf->{user}, $conf->{password}, {
        RaiseError => 1
    });
}

1;
