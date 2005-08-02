# pod.t file providing pod coverage test for Business-OnlinePayment-CashCow

# $Id: pod-coverage.t,v 1.1 2005-08-02 22:03:21 jonasbn Exp $

#pod test courtesy of petdance
#http://use.perl.org/~petdance/journal/17412

use Test::More;
eval "use Test::Pod::Coverage 0.08";
plan skip_all => "Test::Pod::Coverage 0.08 required for testing POD coverage" if $@;
all_pod_coverage_ok();
