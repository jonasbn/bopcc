<?php echo('<?XML version="1.0" encoding="ISO-8859-1"?>');

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
		$tag = strtoupper($var);
		print "<$tag>$thisval</$tag>";
	}
}
?>
</XML>