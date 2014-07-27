#===============================================================================
#
#         FILE: pod-coverage.t
#
#       AUTHOR: Trevor S. Cornpropst (tsc), tscornpropst@gmail.com
#      VERSION: 1.0
#      CREATED: 05/15/2014 21:41:52
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::Pod::Coverage tests=>1;

my $trust = { trustme => [qr/^BUILD|DEMOLISH|AUTOLOAD|AUTOMETHOD|START$/] };
pod_coverage_ok("Log::File", $trust);
