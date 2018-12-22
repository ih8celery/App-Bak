#! /usr/bin/env perl

package Project::Delivery;

use strict;
use warnings;

use feature qw/say/;

use Carp qw/croak/;
use Cwd;
use File::Spec::Functions qw/catfile/;
use Project::Package;
use Project::Config;

use File::Copy;

sub new {
  my ($class, $config, $packager) = @_;

  my $basis = { config => $config };

  if (defined $packager) {
    $basis->{packager} = $packager;
  }
  else {
    $basis->{packager} = Project::Package->new();
  }

  bless $basis, $class;
}

sub transfer {
  my ($self, $method, $src, $dest) = @_;

  if ($method eq 'COPY') {
    copy($src, $dest);
  }
  elsif ($method eq 'MOVE') {
    move($src, $dest);
  }
  else {
    croak "error: transfer: $method is not a valid method";
  }
}

sub deliver {
  my ($self, $info) = @_;

  $info = [] unless defined $info;

  my $reftype   = ref $info;

  # call file method with no arguments to retrieve
  # a list of all files in the project
  my $files     = [ $self->{config}->files->file ];
  my $packaging = $self->{config}->delivery->packaging;
  my $suffix    = $self->{config}->delivery->suffix;
  my $project   = $self->{config}->meta->name;
  my $dest      = cwd;
  if ($reftype eq 'App::Bak::Config') {
    if (defined $info->files) {
      $files = $info->files;
    }

    if (defined $info->packaging) {
      $packaging = $info->packaging;
    }

    if (defined $info->suffix) {
      $suffix = $info->suffix;
    }

    if (defined $info->dest) {
      $dest = $info->dest;
    }
  }
  elsif ($reftype eq 'HASH') {
    if (exists $info->{files} && defined $info->{files}) {
      $files = $info->{files};
    }

    if (exists $info->{packaging}) {
      $packaging = $info->{packaging};
    }

    if (exists $info->{suffix}) {
      $packaging = $info->{suffix};
    }

    if (exists $info->{dest}) {
      $dest = $info->{dest};
    }
  }
  elsif ($reftype eq 'ARRAY') {
    if (@$info) {
      $files = $info;
    }
  }
  else {
    croak "$info is not a valid argument to deliver";
  }

  if (defined $suffix && $suffix ne '') {
    $project .= '-' . $suffix;
  }
  $project = catfile($self->{config}->delivery->archive, $project);

  my $unpackaged = $self->{packager}
                        ->unpackage(
                          $packaging,
                          $project,
                          $self->{config}->delivery->archive,
                          $files);

  my $pkg = $self->{packager}->package($packaging, $project, $unpackaged);

  $self->transfer('MOVE', $pkg, $dest);
}

sub store {
  my ($self, $info) = @_;
  
  $info = [] unless defined $info;

  my $reftype   = ref $info;

  say "initial files: ", @{ $self->{config}->files->file };
  # call file method with no arguments to retrieve
  # a list of all files in the project
  my $files     = $self->{config}->files->file;
  my $file_names;
  my $packaging = $self->{config}->delivery->packaging;
  my $suffix    = $self->{config}->delivery->suffix;
  my $project   = $self->{config}->meta->name;
  my $archive   = $self->{config}->delivery->archive || cwd;
  if ($reftype eq 'App::Bak::Config') {
    if (defined $info->files) {
      $file_names = $info->files;
    }

    if (defined $info->packaging) {
      $packaging = $info->packaging;
    }

    if (defined $info->suffix) {
      $suffix = $info->suffix;
    }

    if (defined $info->dest) {
      $archive = $info->dest;
    }
  }
  elsif ($reftype eq 'HASH') {
    if (exists $info->{files} && defined $info->{files}) {
      $file_names = $info->{files};
    }

    if (exists $info->{packaging}) {
      $packaging = $info->{packaging};
    }

    if (exists $info->{suffix}) {
      $packaging = $info->{suffix};
    }

    if (exists $info->{dest}) {
      $archive = $info->{dest};
    }
  }
  elsif ($reftype eq 'ARRAY') {
    if (@$info) {
      $file_names = $info;
    }
  }
  else {
    croak "$info is not a valid argument to store";
  }

  if (defined $file_names && @$file_names) {
    $files = [];
    foreach (@$file_names) {
      my $path = $self->{config}->files->file($_);

      if (defined $path && ref $path ne 'ARRAY') {
        push @$files, $path;
      }
      else {
        croak "no matching file path";
      }
    }
  }

  if (defined $suffix && $suffix ne '') {
    $project .= '-' . $suffix;
  }

  my $pkg = $self->{packager}->package($packaging, $project, $files);

  $self->transfer('MOVE', $pkg, $archive);
}
