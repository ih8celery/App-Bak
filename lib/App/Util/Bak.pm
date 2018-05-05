#! /usr/bin/env perl

package App::Util::Bak;

use strict;
use warnings;

use Util::Bak;

use Getopt::Long;

our $VERSION = '0.001000';

sub Run {
  1;
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
