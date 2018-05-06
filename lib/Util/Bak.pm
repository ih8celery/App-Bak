#! /usr/bin/env perl

package Util::Bak;

use strict;
use warnings;

use feature qw/say/;

use YAML::XS qw/LoadFile DumpFile/;
use File::Spec::Functions qw/catfile/;
use File::Copy;

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

sub down_file {
  my ($self, $k) = @_;

  if (exists $self->{DOWN_FILE} && $self->{DOWN_FILE} ne '') {
    return $self->{DOWN_FILE};
  }

  my $down_file;
  if (exists $self->{SPEC_YAML}{files}{$k}{down_file}) {
    $down_file = $self->{SPEC_YAML}{files}{$k}{down_file};
  }
  else {
    $down_file = $self->{SPEC_YAML}{files}{$k}{up_file};
  }

  if (exists $self->{SPEC_YAML}{files}{_root}) {
    $down_file = catfile($self->{SPEC_YAML}{files}{_root}, $down_file);
  }

  return $down_file;
}

sub up_file {
  my ($self, $k) = @_;

  if (exists $self->{UP_FILE} && $self->{UP_FILE} ne '') {
    return $self->{UP_FILE};
  }

  my $up_file;
  if (exists $self->{SPEC_YAML}{files}{$k}{up_file}) {
    $up_file = $self->{SPEC_YAML}{files}{$k}{up_file};
  }
  else {
    die 'malformed spec error: up_file: no up file defined for file';
  }

  if (exists $self->{SPEC_YAML}{files}{_root}) {
    $up_file = catfile($self->{SPEC_YAML}{files}{_root}, $up_file);
  }

  return $up_file;
}

sub down_method {
  my ($self, $k) = @_;

  if (exists $self->{DOWN_METHOD} && $self->{DOWN_METHOD} ne '') {
    return $self->{DOWN_METHOD};
  }

  if (exists $self->{SPEC_YAML}{files}{$k}{down_method}) {
    return $self->{SPEC_YAML}{files}{$k}{down_method};
  }
  else {
    return 'COPY';
  }
}

sub up_method {
  my ($self, $k) = @_;

  if (exists $self->{UP_METHOD} && $self->{UP_METHOD} ne '') {
    return $self->{UP_METHOD};
  }

  if (exists $self->{SPEC_YAML}{files}{$k}{up_method}) {
    return $self->{SPEC_YAML}{files}{$k}{up_method};
  }
  else {
    return 'COPY';
  }
}

sub _transfer_file {
  my ($method, $src, $dest) = @_;

  if ($method eq 'COPY') {
    copy($src, $dest);
  }
  else {
    die "error: transfer_file: $method is not a valid method";
  }
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
  my ($self, @places) = @_;

  for my $place (@places) {
    if (exists $self->{SPEC_YAML}{files}{$place}) {
      my $src    = catfile($self->{ARCHIVE}, $place);
      my $dest   = $self->down_file($place);
      my $method = $self->down_method($place);

      _transfer_file($method, $src, $dest);
    }
  }
}

sub Up {
  my ($self, @places) = @_;
  
  for my $place (@places) {
    if (exists $self->{SPEC_YAML}{files}{$place}) {
      my $dest   = catfile($self->{ARCHIVE}, $place);
      my $src    = $self->up_file($place);
      my $method = $self->up_method($place);

      _transfer_file($method, $src, $dest);
    }
  }
}

1;
