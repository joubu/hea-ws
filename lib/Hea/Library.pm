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

    my $library_id;

    my $dbh = Hea::Dbh::dbh;
    my $sql = q{
        INSERT INTO library (name, url, library_type, country)
        VALUES (?, ?, ?, ?)
    };

    $library->{type} //= '';
    $library->{country} //= '';

    my $rows = $dbh->do($sql, {}, $library->{name}, $library->{url}, $library->{type},
        $library->{country});
    if ($rows) {
        $library_id = $dbh->last_insert_id(undef, undef, undef, undef);
    }

    return $library_id;
}

sub update {
    my ($library) = @_;

    my $dbh = Hea::Dbh::dbh;
    my (@sets, @args);
    if ($library->{name}) {
        push @sets, q{ name = ? };
        push @args, $library->{name};
    }
    if ($library->{url}) {
        push @sets, q{ url = ? };
        push @args, $library->{url};
    }
    if ($library->{type}) {
        push @sets, q{ library_type = ? };
        push @args, $library->{type};
    }
    if ($library->{country}) {
        push @sets, q{ country = ? };
        push @args, $library->{country};
    }
    if (@sets) {
        my $sql = q{ UPDATE library SET };
        $sql .= join(',', @sets);
        $sql .= q{ WHERE library_id = ? };

        my $rows = $dbh->do($sql, {}, @args, $library->{id});
        return $rows;
    }
}

1;
