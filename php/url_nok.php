<?php echo('<XML>');

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

while (list($placeholder, $var) = each($_REQUEST)) {
	if (isset($_REQUEST[$placeholder])) {
		$tag = strtoupper("$placeholder");
		echo("<$tag>".$var."</$tag>");
	}
}
?>
</XML>