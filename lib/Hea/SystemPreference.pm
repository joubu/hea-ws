package Hea::SystemPreference;

use Hea::Dbh;

sub create {
    my ($koha_id, $systempreference) = @_;

    my $dbh = Hea::Dbh::dbh;
    my $insert_sql = q{
        INSERT INTO systempreference(koha_id, name, value)
        VALUES (?, ?, ?)
    };
    my $sth = $dbh->prepare($insert_sql);
    while ( my ( $name, $value ) = each %$systempreference ) {
        $sth->execute( $koha_id, $name, $value );
    }
}

sub delete_all {
    my ( $koha_id ) = @_;
    my $dbh = Hea::Dbh::dbh;
    my $rows = $dbh->do(q|
        DELETE FROM systempreference WHERE koha_id = ?
    |, {}, $koha_id);
}

1;
