<!-- $Id: url_fail.php,v 1.1 2005-08-06 18:28:19 jonasbn Exp $ -->
<html>
	<head>
	<LINK REL="SHORTCUT ICON" HREF="/pictures/?shopid=testshop&image=myicon.ico">
		<title>It FAILED!</title>

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
        		<a href="www.cashcowgateway.com"><img src="https://<? print $SERVER_NAME; ?>/pictures/?shopid=testshop&image=logo.gif" alt="Cashcow Gateway" width="99" height="38"></a>
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


<h1>It FAILED!</h1>

<!--
	It is customary to tell the user to try again, and that it
	might be anything besides his/her card that is failing. 
	People get so nervous when told that their card was not 
	valid for payment
-->
<?php

if ($paymenttype == 'pbs' && subscribe =='yes') {
	echo '
	<p>
	Transaktionen kunne ikke gennemføres. 
	Dette kan skyldes tekniske problemer
	hos PBS, eller at kortnummeret ikke blev 
	tastet korrekt ind.  

	Prøv venligst igen. Vi undskylder ulejligheden

	</p>';
} elseif ($paymenttype == 'ecredit') {
	echo '
	<p>
	Transaktionen kunne ikke gennemføres. 
	Dette kan skyldes tekniske problemer
	hos eCredit, eller at personinformationen ikke blev 
	tastet korrekt ind.  

	Prøv venligst igen. Vi undskylder ulejligheden

	</p>';
} else {
	echo '
	<p>
	Transaktionen kunne ikke gennemføres. 
	Dette kan skyldes tekniske problemer
	hos PBS, eller at kortnummeret ikke blev 
	tastet korrekt ind.  

	Prøv venligst igen. Vi undskylder ulejligheden

	</p>';
}

?>

<p>Følgende informationer blev videreført fra 
kort-valideringssiden:</p>



<!-- Errortype contains a small text as to what went wrong. --> 

<ul>
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
	'errortype',
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


<p>
<a href="http://<? print $SERVER_NAME; ?>">Tilbage til butikken</a>
</p>


</body>
</html>
