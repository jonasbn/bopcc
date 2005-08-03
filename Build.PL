# $Id: Build.PL,v 1.2 2005-08-03 13:52:37 jonasbn Exp $

use Module::Build;
my $build = Module::Build->new(
	module_name => 'Business::OnlinePayment::CashCow',
	license 	=> 'artistic',
	requires => {
	    'Carp'                   	=> 0, #core
	    'Data::Dumper'           	=> 0, #core
	    'Exporter'               	=> 0, #core
	    'Business::OnlinePayment'   => 0,
		'Net::SSLeay'				=> 0,
		'Switch'					=> 0,
		'XML::Simple'				=> 0,
   },
   recursive_test_files => 1,
);
$build->create_build_script;
