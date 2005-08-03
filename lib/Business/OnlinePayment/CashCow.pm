package Business::OnlinePayment::CashCow;

# $Id: CashCow.pm,v 1.4 2005-08-03 12:56:38 jonasbn Exp $

use strict;
use vars qw($VERSION @ISA);

use Business::OnlinePayment;
use Net::SSLeay qw(make_form post_https make_headers);
use Switch;
use XML::Simple;
use Carp qw(croak);
use Data::Dumper;

use constant DEBUG => 1;

$VERSION = '0.01';
@ISA = qw(Business::OnlinePayment);

sub set_defaults {
    my $self = shift;

	$self->server('cashcow.catpipe.net');
	$self->path('/auth/');
    $self->port('443');
    $self->{_content}{currency} = 208; #DKK
    
    return 1;
}

sub get_fields {
    my ($self, @fields) = @_;

	if (DEBUG) {
		print STDERR "Dumping \@fields in get_fields\n";
		print STDERR Dumper \@fields;
	}

    my %content = $self->content();
    my %new = ();
    foreach( grep defined $content{$_}, @fields) { $new{$_} = $content{$_}; }
 
 	if (DEBUG) {
		print STDERR "Dumping \\\%new in get_fields\n";
		print STDERR Dumper \%new;
	}
 
 	return %new;
}

sub map_fields {
    my($self) = @_;

    my %content = $self->content();
	
	#setting transaction type
    $content{'type'} = lc($content{'type'}) || $content{'type'};
    
    $self->transaction_type($content{'type'});

    $content{'referer'} = defined( $content{'referer'} )
                            ? make_headers( 'Referer' => $content{'referer'} )
                            : "";

    # stuff it back into %content
    $self->content(%content);
}

sub remap_fields {
    my ($self, %map) = @_;

    my %content = $self->content();
    foreach (keys %map) {
    	if (! defined $map{$_}) {
	    	if (DEBUG) {
	    		print STDERR "Skipping: $_ mapping\n";
    		}
    		next;
    	} else {
    		if (DEBUG) {
    			print STDERR "Mapping: $_ to: $map{$_}\n";
        	}
        	$content{$map{$_}} = $content{$_};
		}
    }
    $self->content(%content);
}

sub test_transaction {
	my ($self, $value) = @_;
	
	if ($value) {
		$self->{'_content'}{'TestFlg'} = $value;
	}
	return $self->{'_content'}{'TestFlg'};
}

sub submit {
    my $self = shift;

	if (DEBUG) {
		print STDERR "Dumping \$self in submit\n";
		print STDERR Dumper $self;
	}
	
	my %content = ();

	#setting content action
	unless ($content{'action'}) {
		$content{'action'} = 'normal authorization';
	}

	my @fields = qw(
		cust_name
        cust_street
        cust_city
		cust_state
        cust_zip
		cust_country
        cust_phone
		cust_fax
        cust_email
        TestFlg
        currency
	);
	my @required_fields = qw(
 		cardnum
 		emonth
 		eyear
 		cvc
 		amount
 		shopid
 	);

	#Required by CashCow
	#cvc
	#currency
	#company

	#Special handling
	#exp_date -> needs split

    $self->remap_fields(
		type			=> undef,
		login			=> undef,  
		password		=> undef,
		action			=> undef,
		description		=> undef,
        amount          => 'amount',
		invoice_number	=> undef,
		customer_id		=> undef,
		name			=> 'cust_name',
        address         => 'cust_street',
        city            => 'cust_city',
		state			=> 'cust_state',
        zip             => 'cust_zip',
		country			=> 'cust_country',
        phone           => 'cust_phone',
		fax				=> 'cust_fax',
        email           => 'cust_email',
        card_number     => 'cardnum',
		exp_date		=> undef,
		account_number	=> undef,
		routing_code	=> undef,
		bank_name		=> undef,
    );

	my ($emonth, $eyear) = $self->{_content}{exp_date} =~ m/^(\d{2})(\d{2})$/;

    $self->{_content}{emonth} = $emonth;
    $self->{_content}{eyear} = $eyear;

    $self->required_fields(@required_fields);
	
	push @fields, @required_fields;
	
	switch (lc($content{'action'})) {
 
			case ('normal authorization') { $self->_normal_authorization(
				\@fields,
			); }
			#case ('authorization only' ) { $self->_authorization_only(); }
			#case ('credit' ) { $self->_credit_authorization(); }
			#case ('post authorization' ) { $self->_post_authorization();}
			else { croak ("unknown action: ".$content{'action'}) }
	}

	return 1;
}

sub _normal_authorization {
    my ($self, $fields) = @_;

	if (DEBUG) {
		print STDERR "Dumping \$self in _normal_authorization\n";
		print STDERR Dumper $self;

		print STDERR "Dumping \\\@fields in _normal_authorization\n";
		print STDERR Dumper $fields;
	}
	
	#Populating post data based on fields
    my %post_data = $self->get_fields( @{$fields} );
	
	#Setting test-flag if set
	$post_data{'TestFlg'} = $self->test_transaction()?1:0;
	
	print STDERR $self->test_transaction();
	
	
	if (DEBUG) {
		print STDERR "Dumping \%post_data in _normal_authorization\n";
		print STDERR Dumper \%post_data;
	}

    my $pd = make_form(%post_data);
    my $headers = make_headers('Referer' => $self->{'_content'}{'referer'});
    
    my ($page, $server_response, %headers) = 
    	post_https(
    		$self->server(),
    		$self->port(),
    		$self->path(),
    		$headers,
    		$pd
    	);

	return $self->_process_response($page, $server_response, \%headers);
}

sub _process_response {
	my ($self, $page, $server_response, $headers) = @_;

	if (DEBUG) {
    	print STDERR "Dumping \\\$server_response in _process_response\n";
    	print STDERR Dumper \$server_response;

    	print STDERR "Dumping \\\$headers in _process_response\n";
    	print STDERR Dumper \$headers;
    
    	print STDERR "Dumping \\\$page in _process_response\n";
    	print STDERR Dumper \$page;
	}


	my $ref = XMLin($page); 

    if ($ref->{order}{errormessage}) {
        $self->is_success(0);
    } else {
        $self->is_success(1);
    }

	return 1;
}

1;

__END__

=pod

=head1 NAME

Business::OnlinePayment::CashCow - Online payment processing via CashCow ApS

=head1 SYNOPSIS

	my $transaction = new Business::OnlinePayment("CashCow");
	$transaction->content(
						  type       => $cardtype,
						  amount     => $session->{orderid}{totalamount},
						  cardnumber => $request->{params}{card_number},
						  expiration => $exp,
						  name       => $request->{params}{cardholder_name},
						 );
	$transaction->submit();
  
	if ($transaction->is_success()) {
		return ('OK', { authorizationcode => $transaction->authorization(); } );
	} else {
	 	return ( 'NOK', { errormessage => $transaction->error_message(); } )
	}

=head1 DESCRIPTION

CashCow ApS is based on the CashCow open source project, which is a C library, 
please see to L<Business::CashCow>.

The goal of this module is to make a machine to machine credit card
transactions. CashCow has several options where you can specify URL for handling
online payments directly using PHP. 

So in order to avoid this layer and still perform transactions this module was 
initiated. At the same time the module attempts to follow the defacto standard 
for the modules in the L<Business::OnlinePayment> namespace.

In order to avoid filtering a HTML response two solutions are doable 

Either you can specify the result URLs on the CashCow gateway using the PHP 
located in the php directory, which output XML, which is more structured and 
more easily parsed.

If you want to roll your own , please refer to the examples located in the xml 
directory.

You can also create HTML (or a different XML) output you just need to subclass
this class and override the _process_response method.

=head2 SUPPORTED TRANSACTION TYPES

	Dankort
	E-Dankort (**)
	VISA/Dankort
	Eurocard
	MasterCard
	Visa
	Visa Electron
	JCB
	Diners (*)
	American Express (*)
	Forbrugsforeningen (*)
	Ikano Finans kort (*)
	
	(*) To accept this, you need a Merchant Agreement with the card provider in 
	question.

	(**) Not supported by this module at this time (SEE: TODO).

=head2 METHODS

=head3 new 

This method is located in the SUPER class L<Business::OnlinePayment> and 
returns a Business::OnlinePayment::CashCow object when called with 
the string CashCow as parameter to the contructor.

=head3 submit

This method is required to be overloaded by L<Business::OnlinePayment>

The method uses HTTPS via L<Net::SSLeay>. 

=head3 set_defaults

This method overloads the similar method in L<Business::OnlinePayment>

It sets possible default required by the module.

=head3 test_transaction

This method overloads the similar method in L<Business::OnlinePayment>

It test the B<TestFlg> form field (SEE: 'Original Formfields', below and 'TODO'
below).

=head3 map_fields

This method overloads the similar method in L<Business::OnlinePayment>

=head3 remap_fields

This method overloads the similar method in L<Business::OnlinePayment>

=head3 get_fields

This method overloads the similar method in L<Business::OnlinePayment>

=head3 content 

This method is inherited from L<Business::OnlinePayment>

=head3 is_success 

This method is inherited from L<Business::OnlinePayment>

=head3 result_code

This method is inherited from L<Business::OnlinePayment>

=head3 require_avs 

This method is inherited from L<Business::OnlinePayment>

=head3 transaction_type 

This method is inherited from L<Business::OnlinePayment>

=head3 error_message 

This method is inherited from L<Business::OnlinePayment>

=head3 authorization 

This method is inherited from L<Business::OnlinePayment>

=head3 server 

This method is inherited from L<Business::OnlinePayment>

=head3 port 

This method is inherited from L<Business::OnlinePayment>

=head3 path

This method is inherited from L<Business::OnlinePayment>

=head3 _process_response

=head1 DEVELOPERS NOTES

=head2 CashCow

The CashCow system is quite flexible and therefor it is not possible to say
what fields are mandatory and which are optional, since configurations may
differ from shop to shop.

=head3 Original Formfields

=over 

=item * shopid

=item * foreignorderid

=item * sessionid

=item * cust_name

=item * cust_street

=item * cust_zip

=item * cust_phone

=item * cust_email

=item * cardnum

=item * emonth

=item * eyear

=item * cvc

=item * amount

=back

=head3 shopid

This is the shopid configured on the CashCow gateway for the shop you want to 
access.

I expect this field to be mandatory hence it is needed to complete a
transaction. 

=head3 foreignorderid

I expect this field to be optional.

=head3 sessionid

I expect this field to be optional.

=head3 cust_name

I expect this field to be optional.

=head3 cust_street

I expect this field to be optional.

=head3 cust_zip

I expect this field to be optional.

=head3 cust_phone

I expect this field to be optional.

=head3 cust_email

This is the customer email adresse. CashCow has some different options for this
parameter. It can either be optional or mandatory and you can even have the 
CashCow gateway evaluate the email address with the configuration parameter
strict which can be set on the gateway.

I expect this field to be optional.

=head3 cardnum

I expect this field to be mandatory hence it is needed to complete a
transaction. 

=head3 emonth

The expiration month in two digits, listed on the front of the creditcard.

I expect this field to be mandatory hence it is needed to complete a
transaction. 

=head3 eyear

The expiration year in two digits, listed on the front of the creditcard.

I expect this field to be mandatory hence it is needed to complete a
transaction. 

=head3 cvc

The 3-digit control number on the back of a creditcard.

I expect this field to be mandatory hence it is needed to complete a
transaction. 

=head3 amount



=head1 TODO

=over

=item * Implement handling of e-dankort card type

=item * Implement handling of ecredit transactions (default is PBS)

=item * Implement handling of subscribtions

=item * Investigate return values

=item * Investigate test flags (TestFlg)

=back

=head1 BUGS

Please report issues via CPAN RT:

  http://rt.cpan.org/NoAuth/Bugs.html?Dist=Business-OnlinePayment-CashCow

or by sending mail to

  bug-Business-OnlinePayment-CashCow@rt.cpan.org

=head1 CAVEATS

=over

=item * Please be aware that the CashCow gateways URLs are not RFC 2396
compliant, '~' in URLs are not currently supported - might tease during 
development or similar.

=back

=head1 SEE ALSO

=over

=item * L<Business::OnlinePayment>

=item * L<Net::SSLeay>

=item * L<http://www.cashcowgateway.com/>

=item * L<http://www.cashcow.dk/>

=item * L<Business::CashCow>

=back

=head1 AUTHOR

Jonas B. Nielsen, (jonasbn) - C<< <jonasbn@cpan.org> >>

=head1 COPYRIGHT

CashCowGateWay is copyright of CashCow ApS

CashCow is copyright of the CashCow association

Business-OnlinePayment-CashCow is (C) by logicLAB 2005

Business-OnlinePayment-CashCow is released under the artistic license

The distribution is licensed under the Artistic License, as specified
by the Artistic file in the standard perl distribution
(http://www.perl.com/language/misc/Artistic.html).

=cut
