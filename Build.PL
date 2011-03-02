# $Id: Build.PL,v 1.8 2007-06-18 10:28:21 jonasbn Exp $

use Module::Build;
use Module::Build::Compat;

my $build = Module::Build->new(
    module_name => 'Business::OnlinePayment::CashCow',
    license     => 'artistic',
    requires    => {
        'Data::Dumper'            => 0,      #core
        'Exporter'                => 0,      #core
        'Business::OnlinePayment' => 0.02,
        'Net::SSLeay'             => 0,
        'XML::Simple'             => 0,
        'URI::Escape'             => 0,
        'Test::Kwalitee'          => 0,
        'Test::Perl::Critic'      => 0,
    },
    create_makefile_pl   => 'passthrough',
    recursive_test_files => 1,
);

my $args_href = $build->args();

if ( $args_href->{shopid} ) {
    $build->notes( 'shopid' => $args_href->{shopid} );
}
$build->create_build_script;
