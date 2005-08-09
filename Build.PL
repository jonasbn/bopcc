# $Id: Build.PL,v 1.4 2005-08-09 08:38:29 jonasbn Exp $

use Module::Build;

my $shopid;

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
	recursive_test_files => 1,
);

my $args_href = $build->args();

if ($args_href->{shopid}) {
        $build->notes('shopid' => $args_href->{shopid});
}

$build->create_build_script;
