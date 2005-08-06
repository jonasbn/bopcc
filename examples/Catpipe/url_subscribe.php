<!-- just for kicks and demo purposes we list the received arguments. This shouldn't be done i production enviroments -->
<!--
<?php
//$Id: url_subscribe.php,v 1.1 2005-08-06 18:28:19 jonasbn Exp $

while (list($key, $val) = each($HTTP_GET_VARS)) {
	print "\n$key = $val";
}
print "\n";

?>
-->
<html>
	<head>
	<LINK REL="SHORTCUT ICON" HREF="/pictures/?shopid=testshop&image=myicon.ico">
		<title>
			Order my book!
		</title>
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

<body>

	<!-- A nice header -->
        <table border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr>
        	<td width="5" class="naviHeaderBack">
			<img src="https://<?php print $SERVER_NAME; ?>/pictures/?shopid=testshop&image=shop.gif" width="5" height="1">
		</td>
        	<td class="naviHeaderBack" align="left">
        		<a href="http://www.cashcowgateway.com"><img src="https://<?php print $SERVER_NAME; ?>/pictures/?shopid=testshop&image=logo.gif" alt="Cashcow Gateway" width="99" height="38" border=0></a>
		</td>
        	<td align="right" class="naviHeaderBack" width="100%">
			&nbsp;
		</td>
        	<td width="5" class="naviHeaderBack">
			<img src="https://<? print $SERVER_NAME; ?>/pictures/?shopid=testshop&image=shop.gif" width="5" height="1">
		</td>
        </tr>
	</table>

<!-- demonstrates howto access image files from the url_* files. Note that the servername should be changed to reflect
	your own gateway. -->

<p align="right">
<img src="https://<?php print $SERVER_NAME; ?>/pictures/?shopid=testshop&image=shop.gif" width="167" height="37" alt="[Troels' shop]"></p>


<!-- A nice title -->
<p>Cashcow Gateways  web-boghandel</p>
<hr>


<!-- Your aren't. Really! -->
<h1>You are about to make a subscription to a magazine </h1>

<!-- Tell the user what stage he is in, and why his data is shown again -->
<p>Please enter your credit card information and double-check the 
information provided below.</p>


<!-- Setup the form to send the result of the user data to the gateway. -->
<form method="post" action="https://<?php print $SERVER_NAME; ?>/subscribe/">

<!-- Set a hidden field with name shopid, and value = the GATEWAYID of the shop. NOT the companyname, NOT the PBSID --> 
<input type="hidden" name="shopid" value="testshop">



<!-- If the sessionid is set, send it back with the next request. We will need it later.
	In a real-life situation, you would probably bail (ie show an errormessage)  if the sessionid wasn't set
	but it all depends on how you build your shop.
-->

<?php
if (isset($sessionid)) {
	print '<input type="hidden" name="sessionid" 
		value="' . $sessionid . '">';
}
?>


<!-- Basic layout 

	In this example we show all the info the user provided as editable fields again.
	All these fields could be hidden if you only want to prompt for creditcard but
	you HAVE to include them in the form.

	The minimal amount of data you can send on is shopid, amount, emonth, eyear and cardnum.
	Other data will be checked in accordance with the setup of the shop on the gateway.
-->
<table border="0">

<tr valign="middle">
	<td>
		&nbsp;
	</td>
	 <td align="right">
		<!-- the submit button that starts the request auth -->
		<input type="submit">
	</td>
</tr>

<tr valign="middle">
	<td>
		Your name:
	</td>
	 <td>
		<!-- read the users name back to him so he can verify that we got his data -->
		<input name="cust_name" <?php 
		if (isset($cust_name)) print ' value="' . 
		htmlspecialchars($cust_name) ?>
		">
	</td>
</tr>

<tr valign="middle">
	<td>
		Street:
	</td>
	<td>
		<input name="cust_street" <?php 
			if (isset($cust_street)) print ' value="' . 
			htmlspecialchars($cust_street) ?>">
	</td>
</tr>

<tr valign="middle">
	<td>
		Zip-code:
	</td>
	 <td>
		<input name="cust_zip" <?php 
			if (isset($cust_zip)) print ' value="' . 
			htmlspecialchars($cust_zip) ?>">
	</td>
</tr>

<tr valign="middle">
	<td>
		Phone#:
	</td>
 	<td>
		<input name="cust_phone" <?php 
			if (isset($cust_phone)) print ' value="' . 
			htmlspecialchars($cust_phone) ?>">
	</td>
</tr>

<tr valign="middle">
	<td>
		Your e-mail address:
	</td>
	 <td>
		<input name="cust_email" <?php 
			if (isset($cust_email)) print ' value="' . 
			htmlspecialchars($cust_email) ?>">
	</td>
</tr>




<!-- this is where your money lies. Ask the user for a cardnumber -->
<tr valign="middle">
	<td>
		Credit card number:
	</td>
 	<td>
						<!-- a test card  not for real use :-) -->
		<input name="cardnum" value="5413037279946869">
	</td>
</tr>

<tr valign="middle">
	<td>
		Credit card expiry date (month/year):
	</td>
 	<td>
		<!-- get expire month / year from the user.
			NOTE: The year passed in eyear should be 2 DIGITS ONLY. If you feel like
			asking for 4 digits it is YOUR RESPONSIBILITY to convert back to 2 digits.
		--> 

		<input name="emonth" size="2" value="04">/
		<input name="eyear" size="2" value="0">
	</td>
</tr>
<tr valign="middle">
	<td>
		Credit card CVC code:<br>
		three-digit code written<br>
		on the back of the card.
	</td>
	<td>
		<input name="cvc" size="3" value="685">
	</td>
</tr>

<tr>
	<td colspan="2">&nbsp;</td>
</tr>

<tr valign="middle">
	<td>Amount:</td>
	<td>
		<!-- show the man what he owes -->
		<input name="amount" <?php if (isset($amount)) print " value=\"$amount\"" ?>>
	</td>
</tr>

</table>

</form>

</body>
</html>
