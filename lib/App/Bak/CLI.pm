#!/usr/bin/env perl

package App::Bak::CLI;

use strict;
use warnings;

use feature qw/say/;

# export symbols
BEGIN {
  use Exporter;

  our @ISA    = qw/Exporter/;
  our @EXPORT = qw/&Run/;
}

# import modules
use Carp qw/croak/;
use Project::Delivery;
use Project::Package;
use Project::Config;
use App::Bak::Config;

use File::Spec::Functions qw/catfile/;
use Cwd;

use Getopt::Long qw/:config no_ignore_case no_auto_abbrev/;

# package variables
our $VERSION = '0.001000';

# subs
sub help {
  print <<EOM;
Usage:
  bak [-h|-v] [subcommand] [options] [arguments]

Subcommands:
  up       transfer files into an archive
  down     transfer files from archive

Options:
  -h|--help          print this help message
  -v|--version       print bak's current version
  -V|--verbose       print messages verbosely
  -f|--config=s      set the config file used by bak
  -s|--source=s      set the file useed as source of transfer
  -d|--dest=s        set the file used as destination of transfer
  -m|--method=s      set the method used to transfer files
  -r|--registry=s    use a YAML file to locate project
  -p|--packaging=s   set the packaging method use to package or unpackage
  -P|--project=s     set the project name
  -x|--suffix=s      set suffix used to mark or identify files during transfer
EOM

  exit 0;
}

sub version {
  say "bak $VERSION";

  exit 0;
}

sub get_subcommand {
  # with no args, just print help
  help() unless @ARGV;

  my $first = shift @ARGV;

  # otherwise test for global option or subcommand
  if ($first eq '-h' || $first eq '--help') {
    help();
  }
  elsif ($first eq '-v' || $first eq '--version') {
    version();
  }
  elsif ($first eq 'up') {
    return 'up';
  }
  elsif ($first eq 'down') {
    return 'down';
  }
  else {
    die "error: $first is not a subcommand";
  }
}

sub Run {
  my $is_verbose = 0;
  my $should_pkg = 1;
  my $conf_file  = $ENV{BAK_CONFIG} || catfile($ENV{HOME}, '.bak_config.yml');
  my $packaging  = 'FILE';
  my $method     = 'COPY';
  my $source     = cwd();
  my $dest       = cwd();
  my $project;
  my $suffix     = 'NONE';

  my %opts = (
    'h|help'        => \&help,
    'v|version'     => \&version,
    'V|verbose'     => sub { $is_verbose = 1; },
    'm|method=s'    => \$method,
    's|source=s'    => \$source,
    'd|dest=s'      => \$dest,
    'p|packaging=s' => \$packaging,
    'x|suffix=s'    => \$suffix,
    'f|config=s'    => \$conf_file,
    'P|project=s'   => \$project
  );

  my $command = get_subcommand();

  exit 1 unless GetOptions(%opts);

  my $app_config = App::Bak::Config->new($conf_file, {
    is_verbose => $is_verbose,
    source     => $source,
    dest       => $dest,
    packaging  => $packaging,
    method     => $method,
    suffix     => $suffix,
    project    => $project,
    places     => [ @ARGV ]
  });

  my $bak = Project::Delivery
    ->new(Project::Config->new($project));

  if ($command eq 'up') {
    $bak->store($app_config);
  }
  else {
    $bak->deliver($app_config);
  }
}

1;

__END__

=head1 Name

  App::Bak::CLI v0.001000

=head1 Subcommands

=over 4

=item * up

update archive from saved sources

=item * down

send archive files "down" to their destinations

=back

=head1 Options

=over 4

=item * -h|--help

print a help message covering options and subcommands

=item * -v|--version

print version

=item * -V|--verbose

print additional information

=item * --fake

rather than making changes to any files, show which files would be changed

=item * -p|--packaging=s

set the packaging method used in file transfer

=item -x|--suffix=s

use suffix to create files or select them for transfer (e.g. a version number)

=item * -f|--config=s

set configuration file used by C<bak>. Defaults to ~/.bak_config

=item * -m|--method=s

set the method used to transfer files

=item * -r|--registry=s

set the file used as the specification of the archive

=item * -a|--archive=s

set the file or directory used as the destination of C<up> or the source
of C<down>

=item * -s|--source=s

set the source of files used in transfer

=item * -d|--dest=s

set the destination of files in transfer

=item * -w|--wrap

package files used in transfer

=item * -W|--no-wrap

do NOT package files used in transfer

=item * -e|--editor=s

set the editor used to open an archive spec

=back

=head1 License

Copyright (C) 2018 Adam Marshall.

This software is available under the MIT License.
