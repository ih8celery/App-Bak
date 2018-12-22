#!/usr/bin/env perl

package Project::Package::Type::Dir;

use strict;
use warnings;

use File::Spec::Functions qw/catfile/;
use File::Copy;

use Mouse;
extends qw/Project::Package::Type/;

sub pack {
  my ($self, $package_name, $files) = @_;

  confess 'no files to package' unless @$files;

  mkdir $package_name;

  foreach (@$files) {
    my ($k, $v) = each %$_;
    copy($v, catfile($package_name, $k));
  }
}

sub unpack {
  my ($self, $package_name, $files) = @_;

  confess 'no files to unpackage' unless @$files;

  unless (-d $package_name) {
    confess 'package type does not match packaging method';
  }

  foreach (@$files) {
    my ($k, $v) = each %$_;
    confess "$k is not a file in $package_name"
      unless -e catfile($package_name, $k);
  }

  foreach (@$files) {
    my ($k, $v) = each %$_;
    copy(catfile($package_name, $k), $v);
  }
}

1;

__END__
