package Mvac::Sample;

use strict;
use warnings;

use base 'Mojolicious';

use HTML::FillInForm::Lite qw(fillinform);
use MojoX::Renderer::Xslate;
use Text::Xslate qw(html_builder);
use Mvac::Sample::Model;
use Mojolicious::Static;

__PACKAGE__->attr(model => sub { Mvac::Sample::Model->new });

# This method will run once at server start
sub startup {
    my $self = shift;

    # Routes
    my $r = $self->routes;

    # namespace
    $r->namespace('Mvac::Sample::Controller');

    # routing
    $r->route('/products')->to('products#index');
    $r->route('/products/new')->to('products#new_product');
    $r->route('/products/create')->to('products#create');
    $r->route('/products/edit/:id', id =>qr{\d+})->to('products#edit');
    $r->route('/products/update')->to('products#update');
    $r->route('/products/order_up')->to('products#order_up');
    $r->route('/products/order_down')->to('products#order_down');
    $r->route('/products/delete')->to('products#delete');

    # use Xslate
    my $xslate = MojoX::Renderer::Xslate->build(
        mojo             => $self,
        template_options => {
            function => {
                fillinform => html_builder(\&fillinform),
                html_line_break => html_builder(\&html_line_break),
            },
        },
    );
    $self->renderer->add_handler(tx => $xslate);

    # static file path
    my $static = Mojolicious::Static->new;
    $static->root('static');
    $self->static($static);

    # json config plugin
    $self->plugin('json_config', {
        file => 'config/config.json',
    });

    # session
    my $sessions = Mojolicious::Sessions->new;
    $sessions->cookie_name('mvac-sample-session');
    $self->sessions($sessions);

    # Defend CSRF
    $self->plugin('Mojolicious::Plugin::CSRFDefender');
}

sub html_line_break {
    my ($str) = @_;
    $str =~ s/&/&amp;/go;
    $str =~ s/</&lt;/go;
    $str =~ s/>/&gt;/go;
    $str =~ s/"/&quot;/go;
    $str =~ s/'/&#39;/go;
    $str =~ s{\n}{<br />}g;
    return $str;
}

1;
