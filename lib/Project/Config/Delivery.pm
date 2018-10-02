#!/usr/bin/env perl

package Project::Config::Delivery;

use strict;
use warnings;

sub new {
  my ($class, $basis) = @_;
  
  my $ref = $basis || {};
  bless $ref, $class;
}

sub packaging {
  my ($self, $packaging) = @_;

  if (defined $packaging) {
    $self->{packaging} = $packaging;
  }

  return $self->{packaging};
}

sub archive {
  my ($self, $archive) = @_;

  if (defined $archive) {
    $self->{archive} = $archive;
  }

  return $self->{archive};
}

sub method {
  my ($self, $method) = @_;

  if (defined $method) {
    $self->{method} = $method;
  }
  
  return $self->{method};
}

sub suffix {
  my ($self, $suffix) = @_;

  if (defined $suffix) {
    $self->{suffix} = $suffix;
  }

  return $self->{suffix};
}

1;
