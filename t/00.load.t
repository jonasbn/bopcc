#pod test courtesy of petdance
#http://use.perl.org/comments.pl?sid=18853&cid=28930

# $Id: 00.load.t,v 1.1 2005-08-02 22:03:21 jonasbn Exp $

use Test::More tests => 1;

BEGIN { use_ok( 'Business::OnlinePayment::CashCow' ); }
