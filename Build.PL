# $Id: Build.PL,v 1.5 2005-10-12 17:33:48 jonasbn Exp $

use Module::Build;

my $shopid;

my $build = Module::Build->new(
	module_name => 'Business::OnlinePayment::CashCow',
	license 	=> 'artistic',
	requires => {
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
