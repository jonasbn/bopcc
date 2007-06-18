# $Id: illegal_characters_bug.t,v 1.1 2007-06-18 10:28:21 jonasbn Exp $

use strict;
use Test::More tests => 5;

use Business::OnlinePayment::CashCow;

use Business::OnlinePayment;

my ($server_response, $reply_headers, $page);

ok(my $cashcow = Business::OnlinePayment->new("CashCow"));

isa_ok($cashcow, 'Business::OnlinePayment::CashCow');

can_ok($cashcow, '_process_response'); #inherited

$server_response = 'HTTP/1.1 200 OK';
$reply_headers   = 'DATE';
$page = q(
<XML><ORDERID>409000</ORDERID><CUST_NAME>Secher & Partnere</CUST_NAME><CURRENCY>208</CURRENCY><AMOUNT>1003.0625</AMOUNT><SHOPID>foniristele</SHOPID><CODE>40</CODE></XML>
);

ok($cashcow->_process_response($page, $server_response, $reply_headers));

ok($cashcow->is_success());
