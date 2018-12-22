#!/usr/bin/env perl

package Project::Package::Spec;

use strict;
use warnings;

use YAML::XS qw/LoadFile/;

use Mouse;
extends qw/Project::Package::Type/;

has 'specFile'   => { is => 'rw', isa => 'Str', required => 1 };

has 'files'      => { is => 'rw', isa => 'HashRef' };
has 'properties' => { is => 'rw', isa => 'HashRef' };

has 'packageType' => { is => 'rw', isa => 'Project::Package::Type' };

around BUILDARGS => sub {
  my ($method, $class) = @_;

  if (scalar @_ == 1 && ! ref $_[0]) {
    my $hash = LoadFile($_[0]);

    confess 'Specfile is invalid: name is a required field'
      unless defined $hash->{name};

    $hash->{packaging} = 'Dir' unless defined $hash->{packaging};

    require "Project::Package::Type::$hash->{packaging}";

    $class->$method(
      specFile    => $_[0],
      files       => ($hash->{files} || []),
      name        => $hash->{name},
      summary     => ($hash->{summary} || ''),
      properties  => ($hash->{properties} || {}),
      packageType => ("Project::Package::Type::$hash->{packaging}"->new)
    );
  }
  else {
    $class->$method(@_);
  }
};

sub pack {
  my ($self, $props) = @_;

  $props = $self->files unless defined $props;

  $self->spec->packageType->pack($self->name, $props);
}

sub unpack {
  my ($self, $props) = @_;

  $props = $self->files unless defined $props;

  $self->spec->packageType->unpack($self->name, $props);
}

1;

__END__
