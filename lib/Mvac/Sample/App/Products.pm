package Mvac::Sample::App::Products;
use strict;
use warnings;
use base qw(
    Mvac::Sample::App
);

__PACKAGE__->mk_accessors(qw(
    id
    title
    description
    type
    small_image
    large_image
    image_type
));

sub check_create_input {
    my $self = shift;

    my $title       = $self->title;
    my $description = $self->description;
    my $type        = $self->type;
    my $small_image = $self->small_image;
    my $large_image = $self->large_image;

    my $result = $self->_check_req_param;

    $self->_check_valid_image('small_image', $result);
    $self->_check_valid_image('large_image', $result);

    $self->form($result);

    return !$result->has_error;
}

sub check_update_input {
    my $self    = shift;
    my $product = $self->product_from_req;

    my $result = $self->_check_req_param;

    if ($self->small_image) {
        $self->_check_valid_image('small_image', $result);
    }

    if ($self->large_image) {
        $self->_check_valid_image('large_image', $result);
    }

    $self->form($result);

    return !$result->has_error;
}

sub _check_valid_image {
    my ($self, $key, $res) = @_;
    my $upload = $self->$key;

    if (!$upload) {
        $res->set_invalid($key => 'NOT_BLANK');
    }
    else {
        unless ($upload->headers->content_type =~ /^image/) {
            $res->set_invalid($key => 'INVALID_IMAGE');
        }
    }
}

sub _check_req_param {
    my $self = shift;

    my $result = $self->validator->check({
        title       => $self->title,
        description => $self->description,
        type        => $self->type,
    } => [
        title       => ['NOT_BLANK', ['LENGTH', 1, 100]],
        description => [['LENGTH', 0, 65535]],
        type        => [['IN_ARRAY', qw(original oem)]],
    ]);

    return $result;
}

sub save_product {
    my ($self)      = @_;
    my $upload_dir  = $self->config->{photo_upload_dir};
    my $model       = $self->model;

    my $title       = $self->title;
    my $description = $self->description;
    my $type        = $self->type;
    my $small_image = $self->small_image;
    my $large_image = $self->large_image;

    # save small image
    my $small_image_name =
        $self->_upload_image($small_image, $upload_dir . 'small/');

    # save large image
    my $large_image_name =
        $self->_upload_image($large_image, $upload_dir . 'large/');

    # order
    my $count = $model->count('products', 'id', {type => $type});
    my $order = $count + 1;

    # save product
    my $upload_path = $self->config->{photo_upload_path};
    my $product = $model->insert('products', {
        title           => $title,
        description     => $description,
        type            => $type,
        order_num       => $order,
        small_image_url => $upload_path . 'small/' . $small_image_name,
        large_image_url => $upload_path . 'large/' . $large_image_name,
    });
}

sub update_product {
    my ($self)      = @_;
    my $model       = $self->model;
    my $upload_dir  = $self->config->{photo_upload_dir};
    my $product     = $self->product_from_req or return;

    my $title       = $self->title;
    my $description = $self->description;
    my $type        = $self->type;
    my $small_image = $self->small_image;
    my $large_image = $self->large_image;

    # save small image
    my $small_image_name;
    if ($small_image) {
        $small_image_name =
            $self->_upload_image($small_image, $upload_dir . 'small/');
    }

    # save large image
    my $large_image_name;
    if ($large_image) {
        $large_image_name =
            $self->_upload_image($large_image, $upload_dir . 'large/');
    }

    # save product
    my $upload_path = $self->config->{photo_upload_path};
    my $args = {
        title       => $title,
        description => $description,
        type        => $type,
    };
    $args->{small_image_url} = qq<${upload_path}small/${small_image_name}>
        if $small_image_name;
    $args->{large_image_url} = qq<${upload_path}large/${large_image_name}>
        if $large_image_name;
    $product->update($args);

    return $product;
}

sub _upload_image {
    my ($self, $image, $path) = @_;

    my $filename  = $image->filename;
    my ($ext)     = $filename =~ /\.([^.]+)$/;
    $ext ||= 'gif';
    my $timestamp = time;
    $filename     = "$timestamp.$ext";
    $path .= $filename;

    $image->move_to($path);

    return $filename;
}

sub original_products {
    my ($self) = @_;
    my $model = $self->model;
    return $model->products_from_type('original')->all;
}

sub oem_products {
    my ($self) = @_;
    my $model = $self->model;
    return $model->products_from_type('oem')->all;
}

sub product_from_req {
    my ($self) = @_;
    my $model  = $self->model;
    my $id     = $self->id or return;

    return $model->single('products', {id => $id});
}

sub delete_image {
    my ($self) = @_;
    my $model  = $self->model;
    my $product    = $self->product_from_req or return;
    my $image_type = $self->image_type or return;

    return unless $image_type =~ /^small|large$/;

    my $column = $image_type . '_image_url';

    $product->update({$column => ''});

    return $product;
}

sub order_up {
    my ($self)  = @_;
    my $model   = $self->model;
    my $product = $self->product_from_req or return;

    my $order = $product->order_num;
    my $product_up = $model->single('products', {
        type      => $product->type,
        order_num => $order - 1,
    });
    return unless $product_up;

    $product->update({order_num => $order - 1});
    $product_up->update({order_num => $order});

    return $product;
}

sub order_down {
    my ($self)  = @_;
    my $model   = $self->model;
    my $product = $self->product_from_req or return;

    my $order = $product->order_num;
    my $product_down = $model->single('products', {
        type      => $product->type,
        order_num => $order + 1,
    });
    return unless $product_down;

    $product->update({order_num => $order + 1});
    $product_down->update({order_num => $order});

    return $product;
}

sub delete_product {
    my ($self) = @_;
    my $model = $self->model;
    my $product = $self->product_from_req or return;

    $product->delete_this;
}

1;
