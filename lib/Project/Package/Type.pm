#!/usr/bin/env perl

package Project::Package::Type;

use Mouse::Role;
with qw/Project::Utils::Describable/;
requires qw/match pack unpack/;
