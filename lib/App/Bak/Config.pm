#!/usr/bin/env perl

package App::Bak::Config;

use strict;
use warnings;

# imports
use YAML::XS qw/LoadFile DumpFile/;

# subs
sub new {
  my $yaml     = LoadFile($_[1]);
  my $defaults = $_[2] || {};

  my $contents = {
    source     => ($defaults->{source} || $yaml->{source}),
    dest       => ($defaults->{dest} || $yaml->{dest}),
    is_verbose => ($defaults->{is_verbose} || $yaml->{is_verbose}),
    method     => ($defaults->{method} || $yaml->{method}),
    packaging  => ($defaults->{packaging} || $yaml->{packaging}),
    suffix     => ($defaults->{suffix} || $yaml->{suffix}),
    types      => ($yaml->{types}),
    project    => ($defaults->{project}),
    places     => ($defaults->{places})
  };

  bless {
    file     => $_[1],
    contents => $contents
  }, $_[0];
}

sub store {
  my ($self, $file, $contents) = @_;

  if (defined $file && defined $contents) {
    DumpFile($file, $contents);
  }
  elsif (defined $file) {
    DumpFile($file, $self->{contents});
  }
  else {
    DumpFile($self->{file}, $self->{contents});
  }
}

sub load {
  my ($self, $file) = @_;

  if (defined $file) {
    $self->{contents} = LoadFile($file);
  }
  else {
    $self->{contents} = LoadFile($self->{file});
  }
}

sub is_verbose {
  return $_[0]->{contents}{is_verbose};
}

sub source {
  return $_[0]->{contents}{source};
}

sub dest {
  return $_[0]->{contents}{dest};
}

sub packaging {
  my ($self) = @_;

  return $self->{contents}{packaging};
}

sub method {
  my ($self) = @_;

  return $self->{contents}{method};
}

sub suffix {
  my ($self) = @_;

  return $self->{contents}{suffix};
}

sub type {
  my ($self, $name) = @_;

  return $self->{contents}{types}{ $name };
}

sub project {
  my ($self) = @_;

  return $self->{content}{project};
}

sub files {
  my ($self) = @_;

  return $self->{contents}{places};
}

1;

__END__
