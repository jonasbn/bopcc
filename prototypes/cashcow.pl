#!/usr/bin/perl -w

# $Id: cashcow.pl,v 1.1 2005-08-02 22:03:21 jonasbn Exp $

use strict;
use Data::Dumper;
use Net::SSLeay qw/post_https make_form/;

my ($page, $response, %reply_headers);

#POST
#($page, $response, %reply_headers) = 
#	post_https('cashcow.catpipe.net', 443, '/auth/?shopid=foniristele'); 

#print STDERR "Response: $response\n";
#print STDERR Dumper $page;

#POST 2

#<li><strong>credit card number</strong></li>
# <li><strong>credit card expiry month</strong></li>
# <li><strong>credit card expiry year</strong></li>
# <li><strong>transaction amount</strong></li>
# <li><strong>name</strong></li>
# <li><strong>email</strong></li></ul>

($page, $response, %reply_headers) = 
	post_https('cashcow.catpipe.net', 443, '/auth/', '',
		make_form(
			shopid    => 'foniristele',
			cust_name => 'test testesen',
	)); 

print STDERR "Response: $response\n";
print STDERR Dumper $page;
print STDERR Dumper \%reply_headers;

