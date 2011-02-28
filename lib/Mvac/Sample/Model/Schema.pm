package Mvac::Sample::Model::Schema;
use strict;
use warnings;

use DBIx::Skinny::Schema;
use DateTime;
use DateTime::Format::Strptime;
use DateTime::Format::MySQL;
use DateTime::TimeZone;


my $timezone = DateTime::TimeZone->new(name => 'Asia/Tokyo');
install_inflate_rule '^.+_at$' => callback {
    inflate {
        my $value = shift;
        my $dt = DateTime::Format::Strptime->new(
            pattern   => '%Y-%m-%d %H:%M:%S',
            time_zone => $timezone,
        )->parse_datetime($value);
        return DateTime->from_object( object => $dt );
    };
    deflate {
        my $value = shift;
        return DateTime::Format::MySQL->format_datetime($value);
    };
};

install_table 'products' => schema {
    pk 'id';
    columns qw(
        id
        title
        description
        type
        order_num
        small_image_url
        large_image_url
        created_at
        updated_at
    );
};

1;
