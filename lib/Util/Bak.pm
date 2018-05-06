#! /usr/bin/env perl

package Util::Bak;

use strict;
use warnings;

use feature qw/say/;

use YAML::XS qw/LoadFile DumpFile/;

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
    SPEC_YAML   => $n_yaml,
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

sub save_spec {
  DumpFile($_[0]->{SPEC_FILE}, $_[0]->{SPEC_YAML});
}

sub Add {
  my ($self, $place, @rest) = @_;

  # make sure there is something to add and no preexisting files of the
  # same name
  unless (@$place) {
    die "error: Add: no name for new file in archive";
  }
  
  if (exists $self->{SPEC_YAML}{files}{ $place->[0] }) {
    die "error: Add: file named $place->[0] already exists";
  }

  my $item = {
    up_method   => 'COPY',
    down_method => 'COPY',
  };

  # set the "up file" and "down file" of the new archive file
  ## set "up file"
  if (exists $rest[0]) {
    $item->{up_file} = $rest[0];
  }
  else {
    if (exists $self->{UP_FILE} && $self->{UP_FILE} ne '') {
      $item->{up_file} = $self->{UP_FILE};
    }
    else {
      die 'error: Add: no up file specified';
    }
  }

  ## set "down file"
  if (exists $rest[1]) {
    $item->{down_file} = $rest[1];
  }
  else {
    if (exists $self->{DOWN_FILE} && $self->{DOWN_FILE} ne '') {
      $item->{down_file} = $self->{DOWN_FILE};
    }
    else {
      $item->{down_file} = $item->{up_file};
    }
  }

  $self->{SPEC_YAML}{files}{ $place->[0] } = $item;
  $self->save_spec();
}

sub Remove {
  my ($self, $place) = @_;

  # make sure there is something to remove
  unless (@$place) {
    die "error: Remove: no file specified";
  }
  
  unless (exists $self->{SPEC_YAML}{files}{ $place->[0] }) {
    die "error: Remove: file named $place->[0] does not exist";
  }

  delete $self->{SPEC_YAML}{files}{ $place->[0] };
  $self->save_spec();
}

# return a string representation of the files in an archive's spec
sub Describe {
  my ($self) = @_;

  my $describer = sub {
    my ($k) = @_;

    my $res = $k . ' (' . $self->{SPEC_YAML}{files}{$k}{up_file} . ' -> ';
    
    if (exists $self->{SPEC_YAML}{files}{$k}{down_file}) {
      $res .= $self->{SPEC_YAML}{files}{$k}{down_file} . ')';
    }
    else {
      $res .= $self->{SPEC_YAML}{files}{$k}{up_file} . ')';
    }

    return $res;
  };

  my @keys = grep { $_ !~ /^_/ } keys %{ $self->{SPEC_YAML}{files} };
  @keys = map { $_ = $describer->($_); } @keys;
  return join("\n", @keys);
}

sub Down {
  1;
}

sub Up {
  1;
}

1;
