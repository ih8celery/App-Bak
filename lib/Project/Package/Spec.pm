#!/usr/bin/env perl

package Project::Package::Spec;

use Mouse;
with qw/Project::Package::Type/;

has 'files'      => { is => 'rw', isa => 'HashRef' };
has 'properties' => { is => 'rw', isa => 'HashRef' };

has 'name'     => { is => 'bare', isa => 'Str' };
has 'summary'  => { is => 'bare', isa => 'Str' };
has 'version'  => { is => 'bare', isa => 'Str' };
has 'type'     => { is => 'rw', isa => 'Str' }; # NOTE pack or unpack
has 'packtype' => { is => 'rw', isa => 'Project::Package::Type' };

sub name {}

sub summary {}

sub version {}
