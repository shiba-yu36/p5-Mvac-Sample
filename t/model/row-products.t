package test::Model::Row::Products;
use strict;
use warnings;

use base qw(Test::Class);

use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;

use Mvac::Sample::Model;

use Test::Mvac::Sample;

sub _products_to_change_order_by_deletion : Test(6) {
    my $p1 = create_product;
    my $p2 = create_product;
    my $p3 = create_product;
    my $p4 = create_product(type => 'oem');
    my $p5 = create_product(type => 'oem');

    my $changes;
    $changes = $p1->products_to_change_order_by_deletion->all;
    is @$changes, 2;
    is $changes->[0]->id, $p2->id;
    is $changes->[1]->id, $p3->id;

    $changes = $p4->products_to_change_order_by_deletion->all;
    is @$changes, 1;
    is $changes->[0]->id, $p5->id;

    $changes = $p5->products_to_change_order_by_deletion->all;
    is @$changes, 0;

    delete_products;
}

sub _delete_this : Test(6) {
    my $p1 = create_product;
    my $p2 = create_product;
    my $p3 = create_product(type => 'oem');
    my $p4 = create_product(type => 'oem');

    $p1->delete_this;
    my $orgs = Mvac::Sample::Model->products_from_type('original')->all;
    is @$orgs, 1;
    is $orgs->[0]->id, $p2->id;
    is $orgs->[0]->order_num, 1;

    $p4->delete_this;
    my $oems = Mvac::Sample::Model->products_from_type('oem')->all;
    is @$oems, 1;
    is $oems->[0]->id, $p3->id;
    is $oems->[0]->order_num, 1;

    delete_products;
}

__PACKAGE__->runtests;

1;
