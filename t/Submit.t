# $Id: Submit.t,v 1.2 2005-08-03 09:43:59 jonasbn Exp $

use strict;
use Test::More qw(no_plan);

use Business::OnlinePayment;
use_ok('Business::OnlinePayment::CashCow');

ok(my $tx = Business::OnlinePayment->new("CashCow"));

$tx->content(
	TestFlg	   => 1,
	shopid	   => 'foniristele',
	type       => 'VISA',
	amount     => '1.00',
	cardnumber => '5413037279946869',
	expiration => '0112',
	name       => 'John Doe',
	cvc		   => '628',
);

ok($tx->submit());