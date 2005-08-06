# $Id: Submit.t,v 1.5 2005-08-06 17:02:15 jonasbn Exp $

use strict;
use Test::More;
use Module::Build;

my $build = Module::Build->current;
my $shopid = $build->notes("shopid");

if (! $shopid) {
	plan skip_all => 'No CashCow shopid specified skipping tests';	
} else {
	plan tests => 4;
}

use Business::OnlinePayment;
use_ok('Business::OnlinePayment::CashCow');

ok(my $tx = Business::OnlinePayment->new
	("CashCow", 
#		{ 
#			shopid => $shopid; 
#			TestFlg	    => 1,
#
#		}
	)
);

$tx->content(
	type        => 'VISA',
	amount      => '1.00',
	card_number => '5413037279946869',
	exp_date    => '0112',
	name        => 'John Doe',
	cvc		    => '628',
);


ok($tx->submit());
ok($tx->is_success);
