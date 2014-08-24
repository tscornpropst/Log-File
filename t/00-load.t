#!perl -T

use strict;
use warnings FATAL => 'all';

use Test::More tests => 1;

use_ok( 'Log::File' );

diag( "Testing Log::File $Log::File::VERSION, Perl $], $^X" );
