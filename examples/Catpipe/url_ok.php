<!-- $Id: url_ok.php,v 1.1 2005-08-06 18:28:19 jonasbn Exp $ -->
<html>
	<head>
	<LINK REL="SHORTCUT ICON" HREF="/pictures/?shopid=testshop&image=myicon.ico">
		<title>It worked!</title>

		<!-- Minimal stylesheet -->
		<style type=text/css>
			dummy {}
			body,td,th,p,h1,h2,h3,input
			{
				background-color: #f2f3e7;
				font-family: verdana, arial, helvetica, sans-serif;
			}

			td.naviHeaderBack
			{
				background-color: #9a968a;
			}

			.naviCurrentSection
			{
				color: #feffff;
				font-weight: bold;
			}

			a.naviSectionLink
			{
				color: #010000;
				text-decoration: none;
				font-weight: bold;
			}

			td.headerToBody
			{
				background-image: url(/images/topbar-lower-border.gif);
			}


			th.tableHeader
			{
				background-color: #aaaaa2;
				color: #000000;
				font-weight: bold;
			}

		</style>


	</head>

<body >
	<!-- A nice header -->
        <table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr>
        	<td width="5" class="naviHeaderBack">
			<img src="https://<? print $SERVER_NAME; ?>/pictures/?shopid=testshop&image=shop.gif" width="5" height="1">
		</td>
        	<td class="naviHeaderBack" align="left">
        		<a href="http://www.cashcowgateway.com"><img src="https://<? print $SERVER_NAME; ?>/pictures/?shopid=testshop&image=logo.gif" alt="Cashcow Gateway" width="99" height="38"></a>
		</td>
        	<td align="right" class="naviHeaderBack" width="100%">
			&nbsp;
		</td>
        	<td width="5" class="naviHeaderBack">
			<img src="https://<? print $SERVER_NAME; ?>/pictures/?shopid=testshop&image=shop.gif" width="5" height="1">
		</td>
        </tr>
	</table>

<hr>

<h1>It worked!</h1>

<p>Følgende informationer blev videreført fra 
kort-valideringssiden:</p>

<ul>


<!-- list all the info this page received -->
<?php

$seek = array(
	'cust_name',
	'cust_street',
	'cust_company',
	'cust_zip',
	'cust_city',
	'cust_state',
	'cust_coutry',
	'cust_phone',
	'cust_fax', 
	'cust_email',
	'amount',
	'orderid',
	'sessionid',
	'paymenttype',
	'subscribe'
);
while (list($placeholder, $var) = each($seek)) {
	if (isset($$var)) {
		$thisval = $$var;
		print "<li>$var=$thisval</li>";
	}
}

?>
</ul>

<h3>Note to developers</h3>
<?php

if ($paymenttype == 'pbs' && !isset($subscribe)) {
	echo '
<p>
The gateway now holds a ticket for this transaction. You should now ship the
product before the tickets expires (7 days), and use the gateway interface
to mark the order as shipped to collect the money.
</p>
	';
} elseif ($paymenttype == 'pbs' && $subscribe == 'yes' ) {
	echo '
<p>
The gateway now holds a ticket for this subscription. This ticket can be
authorized by an amount specified by shopowner or default amount set at
card-checking time into a new order. You should now ship the
product before the tickets expires (7 days), and use the gateway interface
to mark the order as shipped to collect the money.
</p>
	';
} elseif ($paymenttype == 'ecredit') {
	echo '
<p>
The gateway now has an orderid that corresponds to an orderid at eCredit.
You should now ship the order, and use the gateway interface
to mark the order as shipped to collect the money.
</p>
	';
}
?>

<p>
This is also a good time to check that the amount returned is the same as the 
amount requested. This is where your sessionid comes into play. You should 
lookup the information you need to confirm that the bill-of-sale actually
corrosponds with the amount authorized from the server.

You could also check the remote address to check that the requester is indeed the gateway.
</p>

<p>
<? echo "Remote address: $REMOTE_ADDR" ?>
</p>

<p>
<a href="http://<? print $SERVER_NAME; ?>">Back to the shop</a>
</p>

</body>
</html>
