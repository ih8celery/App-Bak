#! /usr/bin/env perl

package App::Util::Bak;

use strict;
use warnings;

use feature qw/say/;

BEGIN {
  use Exporter;

  our @ISA = qw/Exporter/;
  our @EXPORT = qw/&Run/;
}

use Util::Bak;

use Getopt::Long;
use File::Spec::Functions qw/catfile/;

our $VERSION = '0.001000';

sub help {
  print <<EOM;
  -h|--help          print this help message
  -v|--version       print bak's current version
  -V|--verbose       print messages verbosely
  -f|--up-file=s     set the file used as the source for up
  -F|--down-file=s   set the file used as destination of down
  -m|--up-method=s   set the method used by up to transfer files
  -M|--down-method=s set the method used by down to transfer files
  -r|--registry=s    use a particular YAML file as spec for archive
  -a|--archive=s     use a particular file or directory as archive
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
  elsif ($gs_first eq 'describe') {
    return 'describe';
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
  elsif ($gs_first eq 'whereis') {
    return 'whereis';
  }
  else {
    die "error: $gs_first is not a subcommand";
  }
}

sub find_archive_spec {
  my ($fas_registry, $fas_ar_name) = @_;
  my $fas_location = '';

  # read each line of file, looking for archive name
  open my $fas_fh, '<', $fas_registry;

  while ((my $fas_line = <$fas_fh>)) {
    chomp $fas_line;
    my @fas_fields = split /:\s+/, $fas_line;

    if ($fas_fields[0] eq $fas_ar_name) {
      $fas_location = $fas_fields[1];
      last;
    }
  }

  close $fas_fh;

  if (-e $fas_location) {
    return $fas_location;
  }
  else {
    die "error: could not find an archive named $fas_ar_name";
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
    REGISTRY    => catfile($ENV{HOME}, '.bak_registry'),
    ARCHIVE     => '',
    EDITOR      => ($ENV{EDITOR} || 'vim'),
  };

  my %r_opts = (
    'h|help'          => \&help,
    'v|version'       => \&version,
    'V|verbose'       => sub { $r_conf->{VERBOSE} = 1; },
    'e|editor=s'      => \$r_conf->{EDITOR},
    'f|up-file=s'     => \$r_conf->{UP_FILE},
    'F|down-file=s'   => \$r_conf->{DOWN_FILE},
    'm|up-method=s'   => \$r_conf->{UP_METHOD},
    'M|down-method=s' => \$r_conf->{DOWN_METHOD},
    'r|registry=s'    => \$r_conf->{REGISTRY},
    'a|archive=s'     => \$r_conf->{ARCHIVE},
  );

  my $r_command = get_subcommand();

  exit 1 unless GetOptions(%r_opts);

  my ($r_file, @r_places) = @ARGV;
  my $r_spec = find_archive_spec($r_conf->{REGISTRY}, $r_file);

  # create an Util::Bak object
  my $bak = Util::Bak->new($r_spec, $r_conf);

  # collect archive files into the archive
  # this introduces files recently added to the spec
  # removes files not found in the spec
  if ($r_command eq 'up') {
    $bak->Up(@r_places);
  }

  # disseminate archive files to their "down" locations
  elsif ($r_command eq 'down') {
    $bak->Down(@r_places);
  }

  # add files to archive spec
  elsif ($r_command eq 'add') {
    $bak->Add(@r_places);
  }

  # remove files from archive spec
  elsif ($r_command eq 'rm') {
    $bak->Remove(@r_places);
  }

  # edit an existing archive spec
  elsif ($r_command eq 'edit') {
    exec $bak->editor . ' ' . $bak->spec;
  }

  # open the archive proper
  elsif ($r_command eq 'whereis') {
    say $bak->archive;
  }

  # show information about archive
  elsif ($r_command eq 'describe') {
    say $bak->Describe;
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
