package Business::OnlinePayment::CashCow;

# $Id: CashCow.pm,v 1.1 2005-08-02 22:03:21 jonasbn Exp $

use strict;
use Carp qw(croak);
use vars qw($VERSION @ISA);

use Business::OnlinePayment;
use Net::SSLeay qw/make_form post_https make_headers/;
use Switch;

use constant DEBUG => 1;

$VERSION = '0.01';
@ISA = qw(Business::OnlinePayment);

sub set_defaults {
    my $self = shift;

	$self->server('cashcow.catpipe.net');
	$self->path('/auth');
    $self->port('443');
    
    return 1;
}

sub test_transaction {
	my ($self, $value) = @_;
	
	if ($value) {
		$self->{'content'}{'TestFlg'} = $value;
	}
	return $self->{'content'}{'TestFlg'};
}

sub submit {
    my $self = shift;

	my @fields = qw();
	my %content;
	unless ($content{'action'}) {
		$content{'action'} = 'normal authorization';
	}
	switch (lc($content{'action'})) {
 
			case ('normal authorization') { $self->_normal_authorization(
				\@fields,
				\%content,
			); }
			#case ('authorization only' ) { $self->_authorization_only(); }
			#case ('credit' ) { $self->_credit_authorization(); }
			#case ('post authorization' ) { $self->_post_authorization();}
			else { croak ("unknown action: ".$content{'action'}) }
	}

	return 1;
}

sub _normal_authorization {
    my ($self, $fields, $content) = @_;
	
	#Setting transaction type
	$self->transaction_type($content->{'type'});

    $self->remap_fields(
        amount            => 'amount',
        #currency          => '',
        address           => 'cust_street',
        city              => 'cust_city',
        zip               => 'cust_zip',
        phone             => 'cust_phone',
        email             => 'cust_email',
        card_number       => 'cardnum',
        expiration        => 'x_Exp_Date',
        cvv2              => 'cvc',
    );

	#Populating post data based on fields
    my %post_data = $self->get_fields( @{$fields} );

	#Setting test-flag if set
	$post_data{'TestFlg'} = $self->test_transaction()?1:0;
	

	if (DEBUG) {
    	warn "\n$_ => $post_data{$_}\n" for keys %post_data;
	}

    my $pd = make_form(%post_data);
    my $headers = make_headers('Referer' => $content->{'referer'});
    
#     my ($page, $server_response, %headers) = 
#     	post_https(
#     		$self->server(),
#     		$self->port(),
#     		$self->path(),
#     		$headers,
#     		$pd
#     	);

    my %response;
    if (DEBUG) {
    	warn "\n$_ => $response{$_}\n" for keys %response;
	}

    if ( $response{'BLAH'} eq '0' ) {
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
