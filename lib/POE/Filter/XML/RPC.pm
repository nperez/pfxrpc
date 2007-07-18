package POE::Filter::XML::RPC;

use warnings;
use strict;

use POE;
use POE::Filter::Stackable;
use POE::Filter::Stream;
use POE::Filter::HTTPD;
use POE::Filter::XML;
use POE::Filter::XML::RPC::Guts;
use POE::Filter::XML::RPC::HTTPShim;
use Exporter;

use base('POE::Filter::Stackable', 'Exporter');

use constant
{
	'BUFFER'	=> 0,
	'HTTP'		=> 1,
	'TCP'		=> 2,
};

our $VERSION = '0.01';
our @EXPORT = 
(
	'TCP', 
	'HTTP', 
	'SERVER_MODE',
	'CLIENT_MODE',
);

sub new()
{	
	my $class = shift(@_);
	
	if(@_ & 1)
	{
		Carp::confess('Please provide an even number of arguments');
	}

	my $config = {};
	
	while($#_ != -1)
	{
		my $key = lc(shift(@_));
		my $val = shift(@_);
		$config->{$key} = $val;
	}

	my $self = [];
	$self->[+BUFFER] = [];

	bless($self, $class);

	unless($config->{'transport'})
	{
		$config->{'transport'} = +HTTP;
	}
	
	if($config->{'transport'} == +HTTP)
	{
		unless(exists($config->{'mode'}))
		{
			Carp::confess('Client/Server mode specification is required!');
		}

		$self->push(POE::Filter::HTTPD->new());
		
		$self->push
		(
			POE::Filter::XML::RPC::HTTPShim->new
			(
				'Mode'			=> $config->{'mode'},
				'URI'			=> $config->{'uri'},
				'HostHeader'	=> $config->{'hostheader'},
				'UserAgent'		=> $config->{'useragent'},
				'ServerHeader'	=> $config->{'serverheader'},
			)
		);
	
	} elsif($config->{'transport'} == +TCP) {
		
		$self->push(POE::Filter::Stream->new());
	
	} else {

		Carp::confess('Unknown transport type!');
	}
	
	#turn off streaming documents
	$self->push(POE::Filter::XML->new('NotStreaming' => 1));
	$self->push(POE::Filter::XML::RPC::Guts->new());
	
	return $self;
}

1;
__END__
=head1 NAME

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

=head1 AUTHOR

Nicholas R. Perez, C<< <nperez at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-poe-filter-xml-rpc at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=POE-Filter-XML-RPC>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc POE::Filter::XML::RPC

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/POE-Filter-XML-RPC>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/POE-Filter-XML-RPC>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=POE-Filter-XML-RPC>

=item * Search CPAN

L<http://search.cpan.org/dist/POE-Filter-XML-RPC>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Nicholas R. Perez, all rights reserved.

This program is released under the following license: GPL

=cut

1; # End of POE::Filter::XML::RPC
