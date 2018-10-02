#!/usr/bin/env perl

package Project::Config::Properties;

use strict;
use warnings;

sub new {
  my ($class, $props) = @_;

  if (defined $props) {
    return bless ($props, $class);
  }
  else {
    return bless ({}, $class);
  }
}

sub get {
  my ($self, $name) = @_;

  if (exists $self->{ $name }) {
    return $self->{ $name };
  }

  return undef;
}

sub set {
  my ($self, $name, $value) = @_;

  $self->{ $name } = $value;
}

1;

__END__
