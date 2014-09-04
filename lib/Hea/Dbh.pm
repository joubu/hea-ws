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
    $dbh->{'mysql_enable_utf8'} = 1;
    $dbh->do("set NAMES 'utf8'");
    return $dbh;
}

1;
