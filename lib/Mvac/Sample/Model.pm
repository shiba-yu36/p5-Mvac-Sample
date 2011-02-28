package Mvac::Sample::Model;
use strict;
use warnings;

use Path::Class;
use lib file(__FILE__)->dir->parent->parent->parent->subdir('lib')->stringify;

use DBIx::Skinny connect_info => +{
    dsn      => 'dbi:mysql:mvac_sample',
    username => 'nobody',
    password => 'nobody',
};


# --------------------------
# for products
# --------------------------
sub products_from_type {
    my ($self, $type) = @_;
    my $products = $self->search('products',{
        type => $type,
    },{
        order_by => {order_num => 'asc'},
    });

    return $products;
}

1;
