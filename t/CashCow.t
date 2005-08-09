# $Id: CashCow.t,v 1.3 2005-08-09 08:38:29 jonasbn Exp $

use strict;
use Test::More tests => 13;

use constant DEBUG => 0;

use_ok( qw(Business::OnlinePayment::CashCow));

can_ok('Business::OnlinePayment::CashCow', 'submit'); #overloaded
can_ok('Business::OnlinePayment::CashCow', 'set_defaults'); #overloaded
can_ok('Business::OnlinePayment::CashCow', 'remap_fields'); #overloaded

use Business::OnlinePayment;

ok(my $cashcow = Business::OnlinePayment->new("CashCow"));

isa_ok($cashcow, 'Business::OnlinePayment::CashCow');

can_ok($cashcow, 'shopid'); #autoloaded
can_ok($cashcow, 'test_transaction'); #inherited

ok($cashcow->test_transaction(1));

is($cashcow->test_transaction(), 1);

if (DEBUG) {
	use Data::Dumper;
	print STDERR Dumper $cashcow;
}

#testing default values
ok($cashcow->server());
ok($cashcow->path());
ok($cashcow->port());
