#! /usr/bin/env perl

use strict;
use warnings;

use Test::More;

BEGIN { plan tests => 2; }

BEGIN { use_ok 'App::Util::Bak'; }
BEGIN { use_ok 'App::Util::Bak::Archive'; }

BEGIN { done_testing(); }
