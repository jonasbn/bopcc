package Business::OnlinePayment::CashCow;

# $Id: CashCow.pm,v 1.26 2007-06-18 10:28:21 jonasbn Exp $

use strict;
use warnings;
use vars qw($VERSION);

use base 'Business::OnlinePayment';
use Net::SSLeay qw(make_form post_https make_headers);
use XML::Simple;
use URI::Escape;
use Data::Dumper;

use constant DEBUG => 0;

$VERSION = '0.11';

sub set_defaults {
    my $self = shift;

    $self->server('cashcow.catpipe.net');
    $self->path('/auth/');
    $self->port('443');

    if ( !$self->can('shopid') ) {
        $self->build_subs(qw( shopid ));
    }

    return 1;
}

sub get_fields {
    my ( $self, @fields ) = @_;

    if (DEBUG) {
        print STDERR "Dumping \@fields in get_fields\n";
        print STDERR Dumper \@fields;
    }

    my %content = $self->content();
    my %new     = ();
    foreach ( grep defined $content{$_}, @fields ) {
        $new{$_} = $content{$_};
    }

    if (DEBUG) {
        print STDERR "Dumping \\\%new in get_fields\n";
        print STDERR Dumper \%new;
    }

    return %new;
}

sub remap_fields {
    my ( $self, %map ) = @_;

    #We use accessor in case internal format changes
    my %content = $self->content();
    foreach ( keys %map ) {
        if ( !defined $map{$_} ) {
            if (DEBUG) {
                print STDERR "Skipping: $_ mapping\n";
            }
            next;
        } else {
            if (DEBUG) {
                print STDERR "Mapping: $_ to: $map{$_}\n";
            }
            $content{ $map{$_} } = $content{$_};
        }
    }

    if (DEBUG) {
        print STDERR "Dumping \\\%content in remap_fields\n";
        print STDERR Dumper \%content;
    }

    # stuff it back into %content
    $self->content(%content);

	return;
}

sub submit {
    my $self = shift;

    if (DEBUG) {
        print STDERR "Dumping \$self in submit\n";
        print STDERR Dumper $self;
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

    $self->remap_fields(
        type           => undef,
        login          => undef,
        password       => undef,
        action         => undef,
        description    => undef,
        amount         => 'amount',
        invoice_number => undef,
        customer_id    => undef,
        name           => 'cust_name',
        address        => 'cust_street',
        city           => 'cust_city',
        state          => 'cust_state',
        zip            => 'cust_zip',
        country        => 'cust_country',
        phone          => 'cust_phone',
        fax            => 'cust_fax',
        email          => 'cust_email',
        card_number    => 'cardnum',
        exp_date       => undef,
        account_number => undef,
        routing_code   => undef,
        bank_name      => undef,
    );

    #We use accessor in case internal format changes
    my %content = $self->content();

    #setting content shopid
    $content{'shopid'} = $self->shopid();

    #setting content currency
    if ( !$content{'currency'} ) {
        $content{'currency'} = 208;
    }

    #setting content TestFlg
    if ( $self->test_transaction() ) {
        $content{'TestFlg'} = $self->test_transaction();
    }

    #setting content action
    if ( !$content{'action'} ) {
        $content{'action'} = 'normal authorization';
    }

    #setting expiration data (month/year)
    my ( $emonth, $eyear ) = $content{'exp_date'} =~ m/^(\d{2})(\d{2})$/;

    $content{'emonth'} = $emonth;
    $content{'eyear'}  = $eyear;

    if (DEBUG) {
        print STDERR "Dumping \\\%content in submit\n";
        print STDERR Dumper \%content;
    }

    # stuff it back into %content
    $self->content(%content);

    $self->required_fields(@required_fields);

    #Combining the field lists
    push @fields, @required_fields;

    if (DEBUG) {
        print STDERR "Dumping \\\@fields in submit\n";
        print STDERR Dumper \@fields;
    }

    if ( lc( $content{'action'} ) eq 'normal authorization' ) {
        $self->_normal_authorization( \@fields );
    } else {
        $self->error_message( "unsupported action: $content{'action'}" );
        return 0;
    }

    return 1;
}

sub _normal_authorization {
    my ( $self, $fields ) = @_;

    if (DEBUG) {
        print STDERR "Dumping \$self in _normal_authorization\n";
        print STDERR Dumper $self;

        print STDERR "Dumping \\\@fields in _normal_authorization\n";
        print STDERR Dumper $fields;
    }

    #Populating post data based on fields
    my %post_data = $self->get_fields( @{$fields} );

    #Setting test-flag if set
    $post_data{'TestFlg'} = $self->test_transaction();

    if (DEBUG) {
        print STDERR "Dumping \%post_data in _normal_authorization\n";
        print STDERR Dumper \%post_data;
    }

    my ( $page, $server_response, $reply_headers )
        = post_https( $self->server(), $self->port(), $self->path(), undef,
        make_form(%post_data), );

    $self->server_response($server_response);

    return $self->_process_response( $page, $server_response,
        $reply_headers );
}

sub _process_response {
    my ( $self, $page, $server_response, $reply_headers ) = @_;

    if (DEBUG) {
        print STDERR "Dumping \\\$server_response in _process_response\n";
        print STDERR Dumper \$server_response;

        print STDERR "Dumping \\\$reply_headers in _process_response\n";
        print STDERR Dumper \$reply_headers;

        print STDERR "Dumping \\\$page in _process_response\n";
        print STDERR Dumper \$page;
    }


	my $safe = uri_escape($page, "\x26");
    my $ref;

    eval { $ref = XMLin($safe); };

    if ( $@ or not $ref ) {
        $self->error_message(
            'Unable to handle response from CashCow gateway');
        $self->is_success(0);
    } else {

        if (DEBUG) {
            print STDERR Dumper $ref;
        }

        if ( ref $ref eq 'HASH' && defined $ref->{SHOPID} && $ref->{ORDERID} && $ref->{AMOUNT} && $ref->{CURRENCY} && $ref->{CUST_NAME}) {
            if ( my $errormessage = $ref->{errormessage}
                || $ref->{ERRORTYPE} )
            {
                $self->error_message($errormessage);
                $self->is_success(0);
            } else {
                $self->is_success(1);
            }
        } else {
            $self->error_message('Malformed response from CashCow gateway');
            $self->is_success(0);
        }
    }

    return 1;
}

1;

__END__

=pod

=head1 NAME

Business::OnlinePayment::CashCow - Online payment processing via CashCow

=head1 VERSION

This documentation describes version 0.02 of Business::OnlinePayment::CashCow

=head1 SYNOPSIS

	my $tx = new Business::OnlinePayment("CashCow");


	my $tx = new Business::OnlinePayment("CashCow", {
		shopid   => 'cashcowshopid',
	});


	$tx->content(
		type       => 'Visa',
		amount     => '1129.50',
		cardnumber => '123456789012',
		expiration => '1212',
		name       => 'Richie Rich',
	);


	$tx->content(
		type       => 'Visa',
		amount     => '1129.50',
		cardnumber => '123456789012',
		expiration => '1212',
		name       => 'Richie Rich',
		currency   => 608, #PHP - Philipine Pesos????
	);


	$tx->submit();

	if ($tx->is_success()) {
		print "Payment successfull\n";
	} else {
		print "Error: ".$tx->error_message();
	}

=head1 DESCRIPTION

The CashCow gateway used in this module is the CashCow open source project, 
which is a C library, please see to L<Business::CashCow>.

The goal of this module is to make a machine to machine credit card
transactions. CashCow has several options where you can specify URL for handling
online payments directly using CGI scripts. 

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

Return 1 upon success and 0 upon failure. 

Check B<is_success> for indication of transaction success and B<error_message>
in case of transaction failure.

=head3 set_defaults

This method overloads the similar method in L<Business::OnlinePayment>

It sets possible defaults required by Business::OnlinePayment::CashCow.

=head3 test_transaction

This method is inherited from L<Business::OnlinePayment>

It test the B<TestFlg> form field (SEE: 'Original Formfields', below and 'TODO'
below).

=head3 remap_fields

This method overloads the similar method in L<Business::OnlinePayment>

This method was overloaded for development reasons only and will eventually
be removed.

=head3 get_fields

This method overloads the similar method in L<Business::OnlinePayment>

This method was overloaded for development reasons only and will eventually
be removed.

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

This is a private method implemented to handle the response, which the author
recommends to be and XML formatted response.

=head1 DEVELOPERS NOTES

=head2 CashCow

The CashCow system is quite flexible and therefore it is not possible to say
what fields are mandatory and which are optional, since configurations may
differ from shop to shop (SEE: TODO).

=head2 Processor Options

=over

=item * shopid

=back

=head3 shopid

This is the string holding the shopid for the shop configured on the CashCow 
gateway for the shop you want to access.

This field is regarded to be mandatory hence it is needed to complete a
transaction - all requests to a CashCow gateway without a shopid is responded
to with an HTTP response code of 304.

=head2 Original CashCow Formfields

These fields are the ones provided by the CashCow gateway. This module complies
with the L<Business::OnlinePayment> API v2. so the API described in this 
module should be used. But fields listed below can be added to the content
dataset (SEE: SYNOPSIS) if some extra information is needed - use of some fields 
however is not recommended since these are redundant with the fields specified
in the L<Business::OnlinePayment> API.

=over 

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

=item * currency

=back

=head3 foreignorderid

This field can be use to hold your own orderid for reference.

This field is regarded as defaulting to optional. Can be used freely.

=head3 sessionid

This field can be use to hold a sessionid.

This field is regarded as defaulting to optional. Can be used freely.

=head3 cust_name

The customer name (full name) - concatenation might be necessary. Cardholders
name should go in this field.

This field is regarded as defaulting to optional. Please use: B<name> instead.

=head3 cust_street

The street of the customer address.

This field is regarded as defaulting to optional. Please use: B<address> 
instead.

=head3 cust_zip

The zip code of the customers address.

This field is regarded as defaulting to optional. Please use: B<zip> instead.

=head3 cust_phone

The phonenumber of the customer.

This field is regarded as defaulting to optional. Please use: B<phone> instead.

=head3 cust_email

This is the customer email adresse. CashCow has some different options for this
parameter. It can either be optional or mandatory and you can even have the 
CashCow gateway evaluate the email address with the configuration parameter
strict which can be set on the gateway.

This field is regarded as defaulting to optional. Please use: B<email> instead.

=head3 cardnum

This field is regarded as defaulting to mandatory. Please use: B<card_number> 
instead.

=head3 emonth

The expiration month in two digits, listed on the front of the creditcard.

This field is regarded as defaulting to mandatory. Please use: B<expiration> 
instead.

=head3 eyear

The expiration year in two digits, listed on the front of the creditcard.

This field is regarded as defaulting to mandatory. Please use: B<expiration> 
instead.

=head3 cvc

The 3- or 4-digit control number on the back of a creditcard. The CashCow 
gateway refers to this as CVC, but the name actually depends on the card in 
question, but this module sticks to the name CVC eventhough it might be used 
for:

=over

=item * CVV2 (Visa)

=item * CVC2 (Mastercard) 

=item * CID (American Express)

=back

This field is regarded as defaulting to mandatory.

=head3 amount

The amount should be provided in english notation, do not use locale if it 
differs from the using . (dot) as separator. (SEE: SYNOPSIS).

This field is regarded as defaulting to mandatory.

=head4 currency

This argument can be used to specify the currency. The currency defaults
to 208, which is the numeric currency code for DKK - Danish Krone.

The numeric codes are defined in: ISO4217

See, SEE ALSO section for references.

=head1 TODO

=over

=item * Implement handling of e-dankort card type

=item * Implement handling of ecredit transactions (default is PBS)

=item * Implement handling of subscribtions

=item * Investigate return values and use of: authorization() and result_code()

=item * Investigate test flags (TestFlg)

=item * Make it possible to control what fields are mandatory and optional. This
could be done via the optional processor info parameter to the constructor
(SEE: B<new>).

=item * The tests reveal a warning of sorts from Net::SSLeay - it would be nice
to have this warning eliminated.

=item * Some warnings are issued due to redefinition of autoloaded subs built
by the SUPER class, this would be nice to get out of the way aswell

=back

	t/Submit..........ok 1/6Subroutine shopid redefined at (eval 36) line 1.     
	Subroutine testflg redefined at (eval 37) line 1.

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

=item * L<http://420.am/business-onlinepayment/>

=item * L<Business::CashCow>

=item * L<http://www.sti.nasa.gov/cvv.html>

=item * L<http://search.cpan.org/src/JASONK/Business-OnlinePayment-2.01/notes_for_module_writers>

=item * L<Locale::Currency>

=item * L<http://en.wikipedia.org/wiki/ISO_4217>

=item * L<http://www.iso.org/iso/en/prods-services/popstds/currencycodeslist.html>

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
