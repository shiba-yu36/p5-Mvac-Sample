package test::App::Products;
use strict;
use warnings;

use base qw(Test::Class);

use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;

use Mvac::Sample::App;
use Mvac::Sample::Model;

use Test::Mvac::Sample;

sub _delete_product : Test(3) {
    my ($self) = @_;

    my $p1 = create_product;
    my $p2 = create_product;

    my $app = app_class('Products')->new;
       $app->model(Mvac::Sample::Model->new);
       $app->id($p1->id);
    $app->delete_product;

    my $orgs = Mvac::Sample::Model->products_from_type('original')->all;
    is @$orgs, 1;
    is $orgs->[0]->id, $p2->id;
    is $orgs->[0]->order_num, 1;

    delete_products;
}

__PACKAGE__->runtests;

1;
