package Hea::SystemPreference;

use Hea::Dbh;

sub update {
    my ($library_id, $systempreference) = @_;

    my $dbh = Hea::Dbh::dbh;
    my $update_sql = q{
        UPDATE systempreference
        SET value = ?
        WHERE library_id = ? AND name = ?
    };
    my $update_sth = $dbh->prepare($update_sql);
    my $insert_sql = q{
        INSERT INTO systempreference(library_id, name, value)
        VALUES (?, ?, ?)
    };
    my $insert_sth = $dbh->prepare($insert_sql);
    my $rows;
    foreach my $key (keys %$systempreference) {
        my $rows = $update_sth->execute($systempreference->{$key}, $library_id, $key);
        if ($rows and $rows == 0) {
            $insert_sth->execute($library_id, $key, $systempreference->{$key});
        }
    }

    return $rows;
}

1;
