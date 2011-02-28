package Mvac::Sample::Controller::Products;

use strict;
use warnings;

use base 'Mojolicious::Controller';

use Mvac::Sample::App;

# This action will render a template
sub index {
    my $self = shift;

    my $app = app_class('Products')->new;
       $app->prepare_from_controller($self);
}

sub new_product {
    my $self = shift;
    my $app = app_class('Products')->new;
       $app->prepare_from_controller($self);
}

sub create {
    my $self = shift;
    my $req  = $self->req;

    # require post
    return $self->render(template => 'products/new_product')
        if ($self->req->method ne 'POST');

    my $app = app_class('Products')->new;
       $app->prepare_from_controller($self);
       $app->title($req->param('title'));
       $app->description($req->param('description'));
       $app->type($req->param('type'));
       $app->small_image($req->upload('small_image'));
       $app->large_image($req->upload('large_image'));

    # validate
    unless ($app->check_create_input) {
        return $self->render(template => 'products/new_product');
    }

    # save
    $app->save_product;

    $self->redirect_to('products');
}

sub edit {
    my $self = shift;

    my $app = app_class('Products')->new;
       $app->prepare_from_controller($self);
       $app->id($self->stash('id'));
}

sub update {
    my $self = shift;
    my $req  = $self->req;

    return $self->render(template => 'products/edit')
        if ($self->tx->req->method ne 'POST');

    my $app = app_class('Products')->new;
       $app->prepare_from_controller($self);
       $app->id($req->param('id'));
       $app->title($req->param('title'));
       $app->description($req->param('description'));
       $app->type($req->param('type'));
       $app->small_image($req->upload('small_image'));
       $app->large_image($req->upload('large_image'));

    # validate
    unless ($app->check_update_input) {
        return $self->render(template => 'products/edit_product');
    }

    # update
    $app->update_product;

    $self->redirect_to('products');
}

sub order_up {
    my $self = shift;
    my $req  = $self->req;

    return $self->render(template => 'products')
        if ($self->tx->req->method ne 'POST');

    my $app = app_class('Products')->new;
       $app->prepare_from_controller($self);
       $app->id($req->param('id'));

    $app->order_up;

    $self->redirect_to('products');
}

sub order_down {
    my $self = shift;
    my $req  = $self->req;

    return $self->render(template => 'products')
        if ($self->tx->req->method ne 'POST');

    my $app = app_class('Products')->new;
       $app->prepare_from_controller($self);
       $app->id($req->param('id'));

    $app->order_down;

    $self->redirect_to('products');
}

sub delete {
    my $self = shift;
    my $req  = $self->req;

    return $self->render(template => 'products')
        if ($self->tx->req->method ne 'POST');

    my $app = app_class('Products')->new;
       $app->prepare_from_controller($self);
       $app->id($req->param('id'));

    $app->delete_product;

    $self->redirect_to('products');
}

1;
