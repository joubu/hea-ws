package Hea::Library;

use Hea::Dbh;
use Digest::MD5;
use Data::Entropy qw( entropy_source );

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

    $library->{id} = build_new_id( $library->{name} );

    my $dbh = Hea::Dbh::dbh;
    my $sql = q{
        INSERT INTO library (library_id, name, url, library_type, country, creation_time)
        VALUES (?, ?, ?, ?, ?, NOW())
    };

    $library->{type} ||= '';
    $library->{country} ||= '';

    my $rows = $dbh->do($sql, {}, $library->{id}, $library->{name}, $library->{url}, $library->{type},
        $library->{country});

    return $library->{id};
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

sub build_new_id {
    my ( $library_name ) = @_;
    my $string = $library_name . entropy_source->get_bits(256);

    my $md5 = Digest::MD5->new->md5_base64($string);
    return $md5;
}

1;
