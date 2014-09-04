package Hea::SystemPreference;

use Hea::Dbh;

sub create {
    my ($library_id, $systempreference) = @_;

    my $dbh = Hea::Dbh::dbh;
    my $insert_sql = q{
        INSERT INTO systempreference(library_id, name, value)
        VALUES (?, ?, ?)
    };
    my $sth = $dbh->prepare($insert_sql);
    my $rows;
    foreach my $key (keys %$systempreference) {
        $sth->execute($library_id, $key, $systempreference->{$key});
    }

    return $rows;
}

sub delete_all {
    my ( $library_id ) = @_;
    my $dbh = Hea::Dbh::dbh;
    my $rows = $dbh->do(q|
        DELETE FROM systempreference WHERE library_id = ?
    |, {}, $library_id);
}

1;
