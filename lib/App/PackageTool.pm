#!/usr/bin/env perl

package App::PackageTool;

use strict;
use warnings;

use File::Spec::Functions qw/catfile/;
use YAML::XS qw/LoadFile DumpFile/;

use Project::Package::Manager;

use Mouse;
extends qw/CLI::CommandLineApp/;

has 'package'    => { is => 'bare', isa => 'Project::Package' };
has 'delivery'   => { is => 'bare', isa => 'Project::Delivery' };
has 'properties' => { is => 'rw', isa => 'HashRef' };

override 'execute', sub {
  my ($self) = @_;

  my $context = {
    'config' => ($ENV{BAK_CONFIG} || catfile($ENV{HOME}, '.bak_config.yml')),
  };

  my $info = $self->get_args(
    {
      description => {
        name    => 'PackageTool',
        summary => 'create archives and distribute files based on yaml files'
      },
      commands    => {
        up   => 'transfer files into an archive',
        down => 'transfer files out of an archive'
      },
      options     => {
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
    \@ARGS,
    $context
  );

  $self->properties(LoadFile($info->options('config')));

  my $manager = Project::Package::Manager->new(file => $info->options('spec'));

  my $cmd  = $info->command->name;
  my $file = '';
  if ($cmd eq 'up') {
    $manager->pack;
  }
  elsif ($cmd eq 'down') {
    $manager->unpack;
  }
  elsif ($cmd eq 'info') {
    $manager->describe($file);
  }
}

1;

__END__
