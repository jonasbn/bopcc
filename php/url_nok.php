<!-- $Id: url_nok.php,v 1.1 2005-08-03 13:05:50 jonasbn Exp $ -->
<?php echo('<?xml version="1.0" encoding="ISO-8859-1"?>'); ?>
<CUSTOMER>
		<CUST_NAME><?php=$cust_name ?></CUST_NAME>
		<CUST_STREET><?php $cust_street ?></CUST_STREET>
		<CUST_COMPANY><?php $cust_company ?></CUST_COMPANY>
		<CUST_ZIP><?php $cust_zip ?></CUST_ZIP>
		<CUST_CITY><?php $cust_city ?></CUST_CITY>
		<CUST_STATE><?php $cust_state ?></CUST_STATE>
		<CUST_COUNTRY><?php $cust_country ?></CUST_COUNTRY>
		<CUST_PHONE><?php $cust_phone ?></CUST_PHONE>
		<CUST_FAX><?php $cust_fax ?></CUST_FAX>
		<CUST_EMAIL><?php $cust_email ?></CUST_EMAIL>
	</CUSTOMER>
	<ORDER>
		<AMOUNT><?php $amount ?></AMOUNT>
		<ORDERID><?php $orderid ?></ORDERID>
		<SESSION><?php $sessionid ?></SESSIONID>
		<ERRORTYPE><?php $errortype ?></ERRORTYPE>
		<PAYMENTTYPE><?php $paymenttype ?></PAYMENTTYPE>
		<SUBSCRIBE><?php $subscribe ?></SUBSCRIBE>
	</ORDER>
</XML>