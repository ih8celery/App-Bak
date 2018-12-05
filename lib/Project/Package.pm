#!/usr/bin/env perl

package Project::Package;

use strict;
use warnings;

use feature qw/say/;

use Archive::Zip qw/:ERRORS :CONSTANTS/;
use Carp qw/croak/;
use File::Spec::Functions qw/catfile/;
use File::Copy;

our $VERSION = '0.001000';

sub new {
  my ($class) = @_;

  bless {}, $class;
}

sub package {
  my ($self, $method, $package_name, $files) = @_;

  croak "no files to package" unless @$files;

  my $result;
  if ($method eq 'FILE') {
    mkdir $package_name;
    $result = $package_name;
  }
  elsif ($method eq 'ZIP') {
    my $zip    = Archive::Zip->new();
    foreach (@$files) {
      $zip->addFile($_) if -f $_;

      $zip->addDirectory($_) if -d $_;
    }

    $result = $package_name . '.zip';

    $zip->writeToFileNamed($result);
  }
  else {
    croak "unknown packaging method $method";
  }

  return $result;
}

sub unpackage {
  my ($self, $method, $package_name, $dest, $files) = @_;

  croak "no files to unpackage" unless @$files;

  my $result = [];
  if ($method eq 'FILE') {
    # 1. verify package is dir
    unless (-d $package_name) {
      croak "package type does not match packaging method";
    }

    # 2. find files in dir
    foreach (@$files) {
      croak "$_ is not a file in $package_name"
        unless -e catfile($package_name, $_);
    }

    # 3. copy files from dir
    foreach (@$files) {
      copy(catfile($package_name, $_), catfile($dest, $_));
      push @$result, catfile($dest, $_);
    }
  }
  elsif ($method eq 'ZIP') {
    # 1. verify package plus .zip is file
    unless (-f $package_name . '.zip') {
      croak "package type does not match packaging method";
    }

    # 2. find files in package
    my $zip = Archive::Zip->new();
    $zip->read($package_name . '.zip');

    foreach (@$files) {
      croak "$_ is not a file in $package_name.zip"
        unless (defined $zip->memberNamed($_));
    }

    # 3. extract files
    foreach (@$files) {
      $zip->extractMember($_, catfile($dest, $_));
      push @$result, catfile($dest, $_);
    }
  }
  else {
    croak "unknown packaging method: $method";
  }

  return $result;
}

1;

__END__

=head1 Name

  Project::Package v0.001000 -- package and unpackage project files

=head1 Subroutines

=over 4

=item * new ($class)

create simple packager object

=item * package ($self, $packaging, $package_name, $files_array)

package files using specified packaging

=item * unpackage ($self, $packaging, $package_name, $files_array)

unpackage files using specified packaging

=back

=head1 License

Copyright (C) 2018 Adam Marshall.

This software is available under the MIT License.
