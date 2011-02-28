use strict;
use warnings;
use inc::Module::Install;

name 'Mvac-Sample';
all_from 'lib/Mvac/Sample.pm';

# Mojolicious系
requires 'Mojolicious';
requires 'MojoX::Renderer::Xslate';
requires 'Mojolicious::Controller';
requires 'Mojolicious::Plugin::CSRFDefender';

# DB系
requires 'DBD::mysql';
requires 'DBIx::Skinny';
requires 'DBIx::Skinny::Schema';

# Template系
requires 'Text::Xslate';

# 時間
requires 'DateTime';
requires 'DateTime::Format::Strptime';
requires 'DateTime::Format::MySQL';
requires 'DateTime::TimeZone';

# ファイル
requires 'File::Basename';
requires 'File::Spec';

# Plack
requires 'Plack';
requires 'Plack::Builder';
requires 'Plack::Middleware::Static';

# それ以外
requires 'Class::Accessor::Fast';
requires 'Class::Data::Inheritable';
requires 'List::Rubyish';
requires 'Exporter::Lite';
requires 'FormValidator::Simple';
requires 'HTML::FillInForm::Lite';
requires 'HTML::Entities';


tests 't/*.t';

test_requires 'Test::More';
test_requires 'Test::Class';
test_requires 'DBIx::RewriteDSN';
test_requires 'Path::Class';
test_requires 'String::Random';
test_requires 'Mojo::Asset::File';
test_requires 'JSON::Syck';
test_requires 'Mojo::Upload';

bundle_local_lib;

WriteAll;
