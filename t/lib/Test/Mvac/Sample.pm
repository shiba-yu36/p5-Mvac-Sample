package Test::Mvac::Sample;
use strict;
use warnings;

BEGIN {
    $ENV{DBI_REWRITE_DSN} = 1;
    $ENV{PLACK_ENV} = 'test';
}

use DBIx::RewriteDSN -rules => q{
    ^dbi:mysql:([0-9a-zA-Z_]+)$ dbi:mysql:dbname=$1_test;host=127.0.0.1
};

use Mvac::Sample::App;

use Path::Class qw(file);
use Mvac::Sample;
my $config = Mvac::Sample
    ->new(mode => $ENV{PLACK_ENV})
    ->plugin('json_config' => {file => 'config/config.json'});
my $assets_path = file(__FILE__)->dir->parent->parent->parent->subdir('assets');
my $image_path = $assets_path->file('small_image.gif');

use Test::More;

use Exporter::Lite;
our @EXPORT = qw(
    create_product
    delete_products
);
push @EXPORT, @Test::More::EXPORT;

sub create_product(%) {
    require Mojo::Asset::File;
    require String::Random;
    my $rand = String::Random->new;

    my %args = @_;
    my $app = app_class('Products')->new;
    $app->model(Mvac::Sample::Model->new);
    $app->config($config);

    $app->title($args{title} || $rand->randregex('[a-zA-Z0-9]{30}'));
    $app->description($args{title} || $rand->randregex('[a-zA-Z0-9]{50}'));
    $app->type($args{type} || 'original');
    my $small_image = _setup_upload($args{small_image_path});
    $app->small_image($small_image);
    my $large_image = _setup_upload($args{large_image_path});
    $app->large_image($large_image);

    return $app->save_product;
}

sub delete_products {
    require Mvac::Sample::Model;
    Mvac::Sample::Model->delete('products', {});
    unlink glob($config->{photo_upload_dir} . 'small/*');
    unlink glob($config->{photo_upload_dir} . 'large/*');
}

sub _setup_upload {
    require Mojo::Asset::File;
    require Mojo::Upload;
    my ($path) = @_;
    my $asset = Mojo::Asset::File->new(path => $path || $image_path);
    return Mojo::Upload->new->asset($asset);
}

1;
