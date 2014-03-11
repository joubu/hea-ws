package Hea::Volumetry;

use Hea::Dbh;

sub create {
    my ($library_id, $volumetry) = @_;

    my (@values, @values_args);
    foreach my $key (keys %$volumetry) {
        push @values, "(?, ?, ?)";
        push @values_args, $library_id, $key, $volumetry->{$key};
    }

    my $sql = q{
        INSERT INTO volumetry (library_id, name, value)
        VALUES
    } . join (',', @values);
    my $dbh = Hea::Dbh::dbh;
    my $rows = $dbh->do($sql, {}, @values_args);

    return $rows;
}

1;
