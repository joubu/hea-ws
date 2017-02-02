package Hea::Installation;

use Modern::Perl;
use Hea::Dbh;
use Digest::MD5;
use Data::Entropy qw( entropy_source );

sub get {
    my ($koha_id) = @_;

    my $dbh = Hea::Dbh::dbh;
    my $sql = q{
        SELECT *
        FROM installation
        WHERE koha_id = ?
    };
    return $dbh->selectrow_hashref($sql, {}, $koha_id);
}

sub create {
    my ($installation) = @_;

    $installation->{koha_id} = build_new_id();

    my $dbh = Hea::Dbh::dbh;
    my $sql = q{
        INSERT INTO installation (koha_id, name, library_type, creation_time, modification_time)
        VALUES (?, ?, ?, NOW(), NOW())
    };

    $installation->{library_type} ||= '';
    $installation->{name} ||= '';

    my $rows = $dbh->do($sql, {}, $installation->{koha_id}, $installation->{name}, $installation->{library_type} );
    $installation->{id} = $dbh->last_insert_id( undef, undef, 'installation', undef );
    return $installation;
}

sub update {
    my ($installation) = @_;

    return unless $installation->{koha_id};
    my $dbh = Hea::Dbh::dbh;
    my (@sets, @args);
    if ($installation->{library_type}) {
        push @sets, q{ library_type = ? };
        push @args, $installation->{library_type};
    }
    if ($installation->{name}) {
        push @sets, q{ name = ? };
        push @args, $installation->{name};
    }
    if ($installation->{url}) {
        push @sets, q{ url = ? };
        push @args, $installation->{url};
    }
    if ($installation->{country}) {
        push @sets, q{ country = ? };
        push @args, $installation->{country};
    }
    if ($installation->{geolocation}) {
        push @sets, q{ geolocation = ? };
        push @args, $installation->{geolocation};
    }
    push @sets, q{ modification_time = NOW() };
    my $sql = q{ UPDATE installation SET };
    $sql .= join(',', @sets);
    $sql .= q{ WHERE koha_id = ? };

    my $rows = $dbh->do($sql, {}, @args, $installation->{koha_id});
    return $rows;
}

sub build_new_id {
    my $string = entropy_source->get_bits(256);
    return Digest::MD5->new->md5_base64($string);
}

1;
