# $Id: _process_response.t,v 1.1 2005-10-12 16:02:48 jonasbn Exp $

use strict;
use Test::More tests => 7;

use Business::OnlinePayment::CashCow;

use Business::OnlinePayment;

my ($server_response, $reply_headers, $page);

ok(my $cashcow = Business::OnlinePayment->new("CashCow"));

isa_ok($cashcow, 'Business::OnlinePayment::CashCow');

can_ok($cashcow, '_process_response'); #inherited

$server_response = 'HTTP/1.1 200 OK';
$reply_headers   = 'DATE';
$page = q(
<XML><ORDERID>92722</ORDERID><CURRENCY>208</CURRENCY><CUST_NAME>John Doe</CUST_NAME><AMOUNT>1.00</AMOUNT><SHOPID>foniristele</SHOPID></XML>);

ok($cashcow->_process_response($page, $server_response, $reply_headers));

ok($cashcow->is_success());

$server_response = 'HTTP/1.1 200 OK';
$reply_headers   = 'DATE';
$page = q(
<h1>An error occurred (error code 602)</h1>

<p>The error was:</p> 
            <p><em>system error</em></p><p>You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near \'\' at line 1: select name from cardauthenticators where id = </p>
</td></tr></table></body></html>);

ok($cashcow->_process_response($page, $server_response, $reply_headers));

ok(! $cashcow->is_success());
