# $Id: Submit.t,v 1.8 2005-10-12 17:33:48 jonasbn Exp $

use strict;
use Test::More;
use Module::Build;

my $build  = Module::Build->current;
my $shopid = $build->notes("shopid");

if (! $shopid) {
	plan skip_all => 'No CashCow shopid specified skipping tests';	
} else {
	plan tests => 8;
}

use Business::OnlinePayment;
use_ok('Business::OnlinePayment::CashCow');

my %processor_options = (
	shopid  => $shopid,
);

ok(my $tx = Business::OnlinePayment->new( "CashCow", %processor_options ));

can_ok($tx, "shopid");
ok($tx->test_transaction(1));

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

$tx->content(
	action		=> 'fail',
	type        => 'VISA',
	amount      => '1.00',
	card_number => '5413037279946869',
	exp_date    => '0112',
	name        => 'John Doe',
	cvc		    => '628',
);

ok(! $tx->submit());

$tx->content(
	currency    => 208,
	type        => 'VISA',
	amount      => '1.00',
	card_number => '5413037279946869',
	exp_date    => '0112',
	name        => 'John Doe',
	cvc		    => '628',
);
ok($tx->submit());
