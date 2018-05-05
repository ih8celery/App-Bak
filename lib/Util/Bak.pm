#! /usr/bin/env perl

package Util::Bak;

use strict;
use warnings;

use feature qw/say/;

use YAML::XS qw/LoadFile/;

sub new {
  my ($n_class, $n_ar_path, $n_defaults) = @_;

  my $n_config  = {
    ARCHIVE     => $n_ar_path,
    SPEC        => LoadFile($n_ar_path),
    VERBOSE     => ($n_defaults->{VERBOSE} || 0),
    UP_FILE     => $n_defaults->{UP_FILE},
    DOWN_FILE   => $n_defaults->{DOWN_FILE},
    UP_METHOD   => $n_defaults->{UP_METHOD},
    DOWN_METHOD => $n_defaults->{DOWN_METHOD},
    REGISTRY    => $n_defaults->{REGISTRY},
    EDITOR      => $n_defaults->{EDITOR},
  };

  bless $n_config, $n_class; 
}

sub Edit_Spec {
  1;
}

sub Edit_Archive {
  1;
}

sub Add {
  1;
}

sub Remove {
  1;
}

sub Show {
  1;
}

sub Down {
  1;
}

sub Up {
  1;
}

1;
