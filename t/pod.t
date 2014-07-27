#===============================================================================
#
#         FILE: pod.t
#
#       AUTHOR: Trevor S. Cornpropst (tsc), tscornpropst@gmail.com
#      VERSION: 1.0
#      CREATED: 05/15/2014 21:46:47
#     REVISION: ---
#===============================================================================

use strict;

use Test::More;

eval "use Test::Pod 1.00";
plan_skip_all => "Test::Pod 1.00 rquired for testing POD" if $@;
all_pod_files_ok();
