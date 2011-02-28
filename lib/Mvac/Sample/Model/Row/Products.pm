package Mvac::Sample::Model::Row::Products;
use strict;
use warnings;
use utf8;
use base 'DBIx::Skinny::Row';

sub products_to_change_order_by_deletion {
    my ($self) = @_;
    my $order = $self->order_num;
    my $type  = $self->type;
    return $self->{skinny}->search('products', {
        type      => $type,
        order_num => {'>' => $order},
    });
}

sub delete_this {
    my ($self) = @_;
    my $changes = $self->products_to_change_order_by_deletion;

    while (my $row = $changes->next) {
        my $current = $row->order_num;
        $row->update({order_num => $current - 1});
    }
    $self->delete;
}

1;
