#!/usr/bin/env perl

package Devel::Project::Config::Build;

use strict;
use warnings;

sub new {
  my ($class, $basis) = @_;

  my $ref = $basis || {};
  bless $ref, $class;
}

1;
