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

# process arguments
sub get_subcommand {

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
  my ($r_arg_place, @r_arg_rest) = process_args();

  # create an Util::Bak object
  my $bak = Util::Bak->new($r_conf);

  # decide between operations on archive
  ## collect archive files
  if ($r_command eq 'up') {
    $bak->Up($r_arg_place);
  }

  ## distribute archive files
  elsif ($r_command eq 'down') {
    $bak->Down($r_arg_place);
  }

  ## add to archive or create a new archive
  elsif ($r_command eq 'new' && !@r_arg_rest) {
    $bak->Add($r_arg_place, @r_arg_rest);
  }

  ## remove archive or from archive
  elsif ($r_command eq 'rm') {
    $bak->Remove($r_arg_place, @r_arg_rest);
  }

  ## show information about archive
  else {
    $bak->Show($r_arg_place);
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
