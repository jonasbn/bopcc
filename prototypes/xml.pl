#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use XML::Simple;
use URI::Escape;

my $xml = qq[
<XML><ORDERID>409000</ORDERID><CUST_NAME>Secher & Partnere</CUST_NAME><CURRENCY>208</CURRENCY><AMOUNT>1003.0625</AMOUNT><SHOPID>foniristele</SHOPID><CODE>40</CODE></XML>
];
my $xs = XML::Simple->new;

my $safe = uri_escape($xml, "\x26");

my $ref = $xs->XMLin($safe) || die "Unable to parse XML\n";


print STDERR Dumper $ref;
