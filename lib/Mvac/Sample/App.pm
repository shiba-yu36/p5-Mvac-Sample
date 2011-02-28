package Mvac::Sample::App;
use strict;
use warnings;

use base qw(
    Class::Accessor::Fast
    Class::Data::Inheritable
);

use Exporter::Lite;
use UNIVERSAL::require;

our @EXPORT = qw(app_class);
our @EXPORT_OK = @EXPORT;

__PACKAGE__->mk_accessors(qw(
    config
    model
    form
));

use FormValidator::Simple;
use Path::Class;
my $validate_message_file =
    file(__FILE__)->parent->parent->parent->parent
    ->subdir('config')->file('messages.yml')->stringify;


sub app_class (@) {
    my $app = shift;
    return __PACKAGE__ unless $app;

    $app = join '::', __PACKAGE__, $app;
    $app->use or die $@;
    $app;
}

sub prepare_from_controller {
    my ($self, $c) = @_;

    $self->config($c->stash('config'));
    $self->model($c->app->model);
    $c->stash(app => $self);

    return $self;
}

sub validator {
    my $self = shift;
    return $self->{_validator} if $self->{_validator};

    $self->{_validator} = FormValidator::Simple->new;
    $self->{_validator}->set_messages($validate_message_file);

    return $self->{_validator};
}

1;
