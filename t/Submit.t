# $Id: Submit.t,v 1.4 2005-08-03 20:38:31 jonasbn Exp $

use strict;
use Test::More tests => 4;

use Business::OnlinePayment;
use_ok('Business::OnlinePayment::CashCow');

ok(my $tx = Business::OnlinePayment->new("CashCow"));

$tx->content(
	TestFlg	    => 1,
	shopid	    => 'foniristele',
	type        => 'VISA',
	amount      => '1.00',
	card_number => '5413037279946869',
	exp_date    => '0112',
	name        => 'John Doe',
	cvc		    => '628',
);

ok($tx->submit());

ok($tx->is_success);