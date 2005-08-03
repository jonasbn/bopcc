package Business::OnlinePayment::CashCow;

# $Id: CashCow.pm,v 1.3 2005-08-03 10:35:47 jonasbn Exp $

use strict;
use Carp qw(croak);
use vars qw($VERSION @ISA);

use Data::Dumper;

use Business::OnlinePayment;
use Net::SSLeay qw/make_form post_https make_headers/;
use Switch;

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
	
	print STDERR "################################ HALLLO\n";
	print STDERR $self->test_transaction()?1:0;
	
	
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

    if (DEBUG) {
    	print STDERR "Dumping \\\$server_response in _normal_authorization\n";
    	print STDERR Dumper \$server_response;

    	print STDERR "Dumping \\\%headers in _normal_authorization\n";
    	print STDERR Dumper \%headers;
    
    	print STDERR "Dumping \\\$page in _normal_authorization\n";
    	print STDERR Dumper \$page;
	}

    my %response;

    if (keys %response) {
        $self->is_success(1);
    } else {
        $self->is_success(0);
    }
}

1;

__END__

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

	(**) Not supported by this module at this time.

=head2 METHODS

=head3 submit

This method is required to be overloaded by L<Business::OnlinePayment>

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

=head2 DEVELOPERS NOTES

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

=head1 TODO

=over

=item * Implement handling of e-dankort

=item * Investigate return values

=item * Investigate test flags (TestFlg)

=back

=head1 BUGS

Please report issues via CPAN RT:

  http://rt.cpan.org/NoAuth/Bugs.html?Dist=Business-OnlinePayment-CashCow

or by sending mail to

  bug-Business-OnlinePayment-CashCow@rt.cpan.org

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
