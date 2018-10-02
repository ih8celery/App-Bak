#!/usr/bin/env perl

package Devel::Project::Package;

use strict;
use warnings;

use feature qw/say/;

use Archive::Zip;
use Compress::Bzip2;
use File::Temp;
use Carp qw/croak/;

our $VERSION = '0.001000';

sub new {
  my ($class) = @_;

  bless {}, $class;
}

# ensure that file is packaged
# TODO return boolean
sub validate {
  my ($self, $method, $package) = @_;
}

# call appropriate sub from library to create a package
# TODO return name of packaged file
sub package {
  my ($self, $method, $package_name, $files) = @_;

  if ($method eq 'FILE') {
    # create a dir
  }
  elsif ($method eq 'ZIP') {
    # create zip archive
  }
  elsif ($method eq 'BZIP2') {
    # create bzip archive 
  }
  else {
    croak "unknown packaging method $method";
  }
}

# reverse package sub
# TODO return array of file names representing extracted files
sub unpackage {
  my ($self, $method, $package_name, $files) = @_;
}

1;

__END__

=head1 Name

  Devel::Project::Package v0.001000 -- package and unpackage project files

=head1 Subroutines

=over 4

=item * new ($class)

create simple packager object

=item * validate ($self, $method, $package_name)

ensure files are packaged as specified

=item * package ($self, $package_name, $files_array)

package files using specified packaging

=item * package ($self, $package_name, $files_array)

unpackage files using specified packaging

=back

=head1 License

Copyright (C) 2018 Adam Marshall.

This software is available under the MIT License.
