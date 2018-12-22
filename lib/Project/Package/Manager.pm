#!/usr/bin/env perl

package Project::Package::Manager;

use strict;
use warnings;

use Project::Package::Spec;

use Mouse;

has 'specfile'   => { is => 'rw', isa => 'Str' };
has 'properties' => { is => 'rw', isa => 'HashRef' };
has 'spec'       => { is => 'rw', isa => 'Project::Package::Spec' };

# TODO constructor

sub pack {
  my ($self, $props) = @_;

  $props = $self->properties unless defined $props;

  $self->spec->packtype->pack($props);
}

sub unpack {
  my ($self, $props) = @_;

  $props = $self->properties unless defined $props;

  $self->spec->packtype->unpack($props);
}

sub match {
  my ($self, $props) = @_;

  $props = $self->properties unless defined $props;

  $self->spec->packtype->match($props);
}

sub describe {
  my ($self, $name) = @_;

  confess 'name is required' unless defined $name;

  if (exists $self->spec->files->{ $name }) {
    my $file = $self->spec->files->{ $name };

    my $fileName    = $file->name;
    my $fileSummary = $file->summary;
    my $fileVersion = $file->version;

    print "$fileName ($fileVersion): $fileSummary\n";
  }
  else {
    confess "$name is not a file in the package";
  }
}
