#!/usr/bin/env perl

package Devel::Project::Config::Meta;

use strict;
use warnings;

sub new {
  my ($class, $basis) = @_;

  my $ref = $basis || {};
  bless $ref, $class;
}

sub name {
  my ($self, $name) = @_;

  if (defined $name) {
    $self->{name} = $name;
  }
}

sub version {
  my ($self, $version) = @_;

  if (defined $version) {
    $self->{version} = $version;
  }

  return $self->{version};
}

1;
