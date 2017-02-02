package Hea::Volumetry;

use Hea::Dbh;

sub create {
    my ($koha_id, $volumetry) = @_;

    my (@values, @values_args);
    while ( my ( $name, $value ) = each %$volumetry ) {
        push @values, "(?, ?, ?)";
        push @values_args, $koha_id, $name, $value;
    }

    my $sql = q{
        INSERT INTO volumetry (koha_id, name, value)
        VALUES
    } . join (',', @values);
    my $dbh = Hea::Dbh::dbh;
    my $rows = $dbh->do($sql, {}, @values_args);

    return $rows;
}

sub delete_all {
    my ( $koha_id ) = @_;
    my $dbh = Hea::Dbh::dbh;
    my $rows = $dbh->do(q|
        DELETE FROM volumetry WHERE koha_id = ?
    |, {}, $koha_id);
}

1;
