#! /usr/bin/env perl

package Util::Bak;

use strict;
use warnings;

use feature qw/say/;

use YAML::XS;
use File::Spec::Functions;

sub new {
  my ($n_class, $n_defaults) = @_;

  my $n_config = {
    VERBOSE     => $n_defaults->{VERBOSE} || 0,
    UP_FILE     => $n_defaults->{UP_FILE},
    DOWN_FILE   => $n_defaults->{DOWN_FILE},
    UP_METHOD   => $n_defaults->{UP_METHOD},
    DOWN_METHOD => $n_defaults->{DOWN_METHOD},
    REGISTRY    => $n_defaults->{REGISTRY},
    ARCHIVE     => $n_defaults->{ARCHIVE},
  };

  bless $n_config, $n_class; 
}

sub Add {}

sub Remove {}

sub Show {}

sub Down {}

sub Up {}
