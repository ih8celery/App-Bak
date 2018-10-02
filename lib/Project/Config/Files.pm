#!/usr/bin/env perl

package Project::Config::Files;

use strict;
use warnings;

sub new {
  my ($class, $basis) = @_;

  my $ref = $basis || {};
  bless $ref, $class;
}

sub file {
  my ($self, $name, $value) = @_;

  unless (defined $name) {
    return [ values (%$self) ];
  }

  if (defined $value) {
    $self->{ $name } = $value;
  }

  return $self->{ $name };
}

sub add {
  my ($self, $name, $value) = @_;

  $self->{ $name } = $value;
}

sub remove {
  my ($self, $name) = @_;

  delete $self->{ $name };
}

1;
