# $Id: Submit.t,v 1.1 2005-08-02 22:03:21 jonasbn Exp $

use strict;
use Test::More qw(no_plan);

use Business::OnlinePayment;
use_ok('Business::OnlinePayment::CashCow');

ok(my $tx = Business::OnlinePayment->new("CashCow"));

$tx->content(
	type       => 'VISA',
	amount     => '1.00',
	cardnumber => '5413037279946869',
	expiration => '0112',
	name       => 'John Doe',
);

ok($tx->submit());