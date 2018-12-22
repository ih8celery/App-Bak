#!/usr/bin/env perl

package Project::Package::Type;

use strict;
use warnings;

use Mouse;

has 'name'    => { is => 'rw', isa => 'Str' };
has 'summary' => { is => 'rw', isa => 'Str' };

sub match {
  confess 'match method not implemented';
}

sub pack {
  confess 'pack method not implemented';
}

sub unpack {
  confess 'unpack method not implemented';
}
