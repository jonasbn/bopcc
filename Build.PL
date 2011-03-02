# $Id: Build.PL,v 1.8 2007-06-18 10:28:21 jonasbn Exp $

use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
    dist_author          => 'Jonas B. Nielsen, (jonasbn) <jonasbn@cpan.org>',
    module_name => 'Business::OnlinePayment::CashCow',
    license     => 'artistic',
    create_makefile_pl   => 'traditional',
    recursive_test_files => 1,
    requires    => {
        'Data::Dumper'            => 0,      #core
        'Exporter'                => 0,      #core
        'Business::OnlinePayment' => 0.02,
        'Net::SSLeay'             => 0,
        'XML::Simple'             => 0,
        'URI::Escape'             => 0,
    },
	build_requires => {
		'Test::More'          => '0',    #core
        'Test::Kwalitee'          => 0,
        'Test::Perl::Critic'      => 0,
    },
	meta_merge => {
		resources => {
			homepage => 'http://logicLAB.jira.com/browse/BOPCC',
			bugtracker =>
				'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Business-OnlinePayment-CashCow',
			repository => 'http://logicLAB.jira.com/svn/BOPCC',
		},
	},
);

my $args_href = $build->args();

if ( defined $args_href->{shopid} ) {
    $build->notes( 'shopid' => $args_href->{shopid} );
}

$build->create_build_script();
