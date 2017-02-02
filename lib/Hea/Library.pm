package Hea::Library;

use Hea::Dbh;

sub get {
    my ($library_id) = @_;

    my $dbh = Hea::Dbh::dbh;
    my $sql = q{
        SELECT *
        FROM library
        WHERE library_id = ?
    };
    my $library = $dbh->selectrow_hashref($sql, {}, $library_id);

    return $library;
}

sub create {
    my ($library) = @_;

    return unless $library->{koha_id};
    my $dbh = Hea::Dbh::dbh;
    my $sql = q{
        INSERT INTO library (koha_id, name, url, country, geolocation)
        VALUES (?, ?, ?, ?, ?)
    };

    $library->{name} ||= '';
    $library->{url} ||= '';
    $library->{country} ||= '';
    $library->{geolocation} ||= '';

    return $dbh->do($sql, {}, $library->{koha_id}, $library->{name}, $library->{url}, $library->{country}, $library->{geolocation} );
}

sub delete_all {
    my ( $koha_id ) = @_;
    my $dbh = Hea::Dbh::dbh;
    my $rows = $dbh->do(q|
        DELETE FROM library WHERE koha_id = ?
    |, {}, $koha_id);
}

1;
