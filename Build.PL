# $Id: Build.PL,v 1.3 2005-08-06 17:02:15 jonasbn Exp $

use Module::Build;

my ($shopid);

my $build = Module::Build->new(
	module_name => 'Business::OnlinePayment::CashCow',
	license 	=> 'artistic',
	requires => {
	    'Carp'                   	=> 0, #core
	    'Data::Dumper'           	=> 0, #core
	    'Exporter'               	=> 0, #core
	    'Business::OnlinePayment'   => 0,
		'Net::SSLeay'				=> 0,
		'XML::Simple'				=> 0,
	},
	get_options => {
    	shop_id => { 
    		store => \$shopid,
   	},
	recursive_test_files => 1,
);
$build->create_build_script;
