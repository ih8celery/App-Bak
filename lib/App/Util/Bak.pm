#! /usr/bin/env perl

package App::Util::Bak;

use strict;
use warnings;

use feature qw/say/;

use Util::Bak;

use Getopt::Long;

our $VERSION = '0.001000';

sub help {
  say <<EOM;
  '-h|--help'          print this help message
  '-v|--version'       print bak's current version
  '-V|--verbose'       print messages verbosely
  '-f|--up-file=s'     set the file used as the source for up
  '-F|--down-file=s'   set the file used as destination of down
  '-m|--up-method=s'   set the method used by up to transfer files
  '-M|--down-method=s' set the method used by down to transfer files
  '-r|--registry=s'    use a particular YAML file as spec for archive
  '-a|--archive=s'     use a particular file or directory as archive
EOM
}

sub version {
  say "bak $VERSION";
}

# process subcommand
sub get_subcommand {
  # with no args, just print help
  help() unless @ARGV;

  my $gs_first = shift @ARGV;

  # otherwise test for global option or subcommand
  if ($gs_first eq '-h' || $gs_first eq '--help') {
    help();
  }
  elsif ($gs_first eq '-v' || $gs_first eq '--version') {
    version();
  }
  elsif ($gs_first eq 'add') {
    return 'add';
  }
  elsif ($gs_first eq 'rm') {
    return 'rm';
  }
  elsif ($gs_first eq 'ls') {
    return 'ls';
  }
  elsif ($gs_first eq 'edit') {
    return 'edit';
  }
  elsif ($gs_first eq 'up') {
    return 'up';
  }
  elsif ($gs_first eq 'down') {
    return 'down';
  }
  else {
    die "error: $gs_first is not a subcommand";
  }
}

# process arguments: this produces a "place" and a list of other args.
# the place points to a directory or YAML file and, in case of the latter,
# the relevant data within the YAML file
sub process_args {
  my $pa_first = shift @ARGV || die "error: process_args: no args found";

  # split into registry filename and the "rest" of key and drop them
  # with the rest of the command line arguments
  my @pa_path_parts = split /\./, $pa_first;
  return (shift(@pa_path_parts), [ @pa_path_parts ] , @ARGV);
}

sub get_archive_path {
  my ($gap_registry, $gap_ar_name) = @_;
  my $gap_location = '';

  # read each line of file, looking for archive name
  open my $gap_fh, '<', $gap_registry;

  while ((my $gap_line = <$gap_fh>)) {
    my @gap_fields = split /:\s+/, $gap_line;

    if ($gap_fields[0] eq $gap_ar_name) {
      $gap_location = $gap_fields[1];
      last;
    }
  }

  close $gap_fh;

  if (-e $gap_location) {
    return $gap_location;
  }
  else {
    die "error: could not find an archive (using \'$gap_location\')";
  }
}

# main application logic
sub Run {
  my $r_conf = {
    VERBOSE     => 0,
    UP_FILE     => '',
    DOWN_FILE   => '',
    UP_METHOD   => 'COPY',
    DOWN_METHOD => 'COPY',
    REGISTRY    => '',
    ARCHIVE     => '',
  };

  my %r_opts = (
    '-h|--help'          => \&help,
    '-v|--version'       => \&version,
    '-V|--verbose'       => sub { $r_conf->{VERBOSE} = 1; },
    '-f|--up-file=s'     => \$r_conf->{UP_FILE},
    '-F|--down-file=s'   => \$r_conf->{DOWN_FILE},
    '-m|--up-method=s'   => \$r_conf->{UP_METHOD},
    '-M|--down-method=s' => \$r_conf->{DOWN_METHOD},
    '-r|--registry=s'    => \$r_conf->{REGISTRY},
    '-a|--archive=s'     => \$r_conf->{ARCHIVE},
  );

  # get subcommand
  my $r_command = get_subcommand();

  # get options
  exit 1 unless GetOptions(%r_opts);

  # process arguments
  my ($r_file, $r_place, @r_rest) = process_args();

  # create an Util::Bak object
  my $bak = Util::Bak->new(get_archive_path($r_file), $r_conf);

  # decide between operations on archive
  ## collect archive files
  if ($r_command eq 'up') {
    $bak->Up($r_place);
  }

  ## disseminate archive files
  elsif ($r_command eq 'down') {
    $bak->Down($r_place);
  }

  ## add to archive or create a new archive
  elsif ($r_command eq 'add') {
    $bak->Add($r_place, @r_rest);
  }

  ## remove archive or from archive
  elsif ($r_command eq 'rm') {
    $bak->Remove($r_place, @r_rest);
  }

  ## show information about archive
  else {
    $bak->Show($r_place);
  }
}

1;

=head1 Name

  bak - easy archive management using YAML specifications

=head1 Synopsis

C<bak> is like C<tar>, but its interface is simpler. in the background,
C<bak> relies on YAML files to describe what an archive is. here is an
example archive definition:

  ---
  _root: ~/.config/nvim
  plugin:
    up_file: plugins.vim
    up_method: COPY
    down_file: plugins.vim
    down_method: COPY
  init:
    up_file: init.vim
    down_file: init.vim
  ...

=head1 Subcommands

=over 4

=item * up

update archive from saved sources

=item * down

send archive files "down" to their destinations

=item * rm

delete an archive or file in the archive

=item * new

create an archive or insert a file into an existing archive

=item * ls

show the files present in an archive

=item * edit

use editor to open an archive specification for manual editing

=back

=head1 Options

=over 4

=item * -h|--help

print a help message covering options and subcommands

=item * -v|--version

print App::Util::Bak version

=item * -V|--verbose

print additional information

=item * --fake

rather than making changes to any files, show which files would be changed

=item * -f|--up-file=s

set the file used as the source by the up subcommand

=item * -F|--down-file=s

set the file used as the destination by the down subcommand

=item * -m|--up-method=s

set the method for getting a file up into an archive. accepted values
are COPY and MOVE.

=item * -M|--down-method=s

set the method for sending a file down from an archive. accepted
values are COPY, MOVE, and LINK.

=item * -r|--registry=s

set the file used as the specification of the archive

=item * -a|--archive=s

set the file or directory used as the destination of C<up> or the source
of C<down>

=back

=head1 Examples

bak new dotfiles

bak new dotfiles.vim ~/.vimrc

bak new dotfiles.bash ~/.bashrc

bak up dotfiles

bak down dotfiles.bash

=head1 License

Copyright (C) 2018 Adam Marshall.

This software is available under the MIT License.
