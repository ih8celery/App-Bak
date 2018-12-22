#!/usr/bin/env perl

package App::PackageTool;

use strict;
use warnings;

use File::Spec::Functions qw/catfile/;
use YAML::XS qw/LoadFile/;

use Project::Package::Spec;

use Mouse;
extends qw/Dev::CLI::CommandLineApp/;

has 'properties' => { is => 'rw', isa => 'HashRef' };

override 'execute', sub {
  my ($self) = @_;

  $self->configfile($ENV{BAK_CONFIG} || catfile($ENV{HOME}, '.bak_config.yml'));

  my $info = $self->get_args(
    {
      commands => 'up|down',
      options  => {
        '--help|-h'     => {
          summary => 'print this help message'
        },
        '--version|-v'  => {
          summary => 'print current version'
        },
        '--verbose|-V'  => {
          summary => 'print messages verbosely'
        },
        '--config|-f=s' => {
          summary => 'set the config file used by bak'
        },
        '--source|-s=s' => {
          summary => 'set the file used as source of transfer'
        },
        '--dest|-d=s'   => {
          summary => 'set the file used as destination of transfer'
        },
        '--define|-D=s' => {
          summary => 'define property in key:value format'
        },
        '--spec|-S=s'   => {
          summary => 'set the file used as the spec for creating or releasing package'
        }
      }
    },
    \@ARGS
  );

  $self->properties(LoadFile($info->options('config')));

  my $spec = Project::Package::Spec->new($info->options('spec'));

  my $cmd = $info->command->name;
  if ($cmd eq 'up') {
    $spec->pack;
  }
  elsif ($cmd eq 'down') {
    $spec->unpack;
  }
}

1;

__END__
