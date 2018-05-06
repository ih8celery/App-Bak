#! /usr/bin/env perl

package Util::Bak;

use strict;
use warnings;

use feature qw/say/;

use YAML::XS qw/LoadFile/;

sub new {
  my ($n_class, $n_ar_path, $n_defaults) = @_;

  # find the location of the archive
  ## if an archive is passed in via the defaults, the
  ## archive spec will not be consulted for the location of the archive;
  ## otherwise, the value of 'home'in the spec will be used
  my $n_yaml = LoadFile($n_ar_path);
  my $n_archive;
  if (exists $n_defaults->{ARCHIVE} && -e $n_defaults->{ARCHIVE}) {
    $n_archive = $n_defaults->{ARCHIVE};
  }
  elsif (exists $n_yaml->{home}) {
    $n_archive = $n_yaml->{home};
  }
  else {
    die "malformed spec error: new: spec does not define " 
      . "archive home";
  }

  # the archive must contain a slot for files
  unless (exists $n_yaml->{files}) {
    die "malformed spec error: new: spec does not define a files hash";
  }

  my $n_config  = {
    ARCHIVE     => $n_archive,
    SPEC_FILE   => $n_ar_path,
    SPEC_YAML   => $n_yaml->{files},
    VERBOSE     => $n_defaults->{VERBOSE},
    UP_FILE     => $n_defaults->{UP_FILE},
    DOWN_FILE   => $n_defaults->{DOWN_FILE},
    UP_METHOD   => $n_defaults->{UP_METHOD},
    DOWN_METHOD => $n_defaults->{DOWN_METHOD},
    REGISTRY    => $n_defaults->{REGISTRY},
    EDITOR      => $n_defaults->{EDITOR},
  };

  bless $n_config, $n_class; 
}

sub spec {
  my ($self) = @_;

  return $self->{SPEC_FILE};
}

sub archive {
  my ($self) = @_;

  return $self->{ARCHIVE};
}

sub editor {
  my ($self) = @_;

  return $self->{EDITOR};
}

sub Add {
  1;
}

sub Remove {
  1;
}

sub Describe {
  1;
}

sub Down {
  1;
}

sub Up {
  1;
}

1;
