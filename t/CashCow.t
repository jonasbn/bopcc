# $Id: CashCow.t,v 1.1 2005-08-02 22:03:21 jonasbn Exp $

use strict;
use Test::More tests => 11;

use constant DEBUG => 0;

use_ok( qw(Business::OnlinePayment::CashCow));

can_ok('Business::OnlinePayment::CashCow', 'submit');
can_ok('Business::OnlinePayment::CashCow', 'set_defaults');
can_ok('Business::OnlinePayment::CashCow', 'test_transaction');

use Business::OnlinePayment;

ok(my $cashcow = Business::OnlinePayment->new("CashCow"));

isa_ok($cashcow, 'Business::OnlinePayment::CashCow');

ok($cashcow->test_transaction(1));

is($cashcow->test_transaction(), 1);

if (DEBUG) {
	use Data::Dumper;

	print STDERR Dumper $cashcow;
}

#testing default values
ok($cashcow->{'server'});
ok($cashcow->{'path'});
ok($cashcow->{'port'});
