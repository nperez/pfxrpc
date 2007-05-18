package POE::Filter::XML::RPC::HTTPShim;

use warnings;
use strict;

use base('POE::Filter');

use HTTP::Response;
use HTTP::Request;
use HTTP::Status;


use constant 
{
	'INBUFFER' => 0,
	'OUTBUFFER' => 1,
	'SERVER_ERROR' => '<html><body>500 internal server error</body></html>',
};

sub new()
{
	my $class = shift(@_);

	my $self = [];
	$self->[+INBUFFER] = [];
	$self->[+OUTBUFFER] = [];

	return bless($self, $class);
}

sub get_one_start()
{
	my ($self, $raw) = @_;

	if(defined($raw))
	{
		push(@{$self->[+INBUFFER]}, @$raw);
	}
}

sub get_one()
{
	my $self = shift(@_);

	if(@{$self->[+OUTBUFFER]})
	{
		return shift(@{$self->[+OUTBUFFER]});
	
	} else {

		for(0..$#{$self->[+INBUFFER]})
		{
			my $request = shift(@{$self->[+INBUFFER]});

			my $content = $request->decoded_content('ref' => 1);

			if(defined($content))
			{
				my $array = [];
				
				open(my $fh, '<', $content);
				
				while(read($fh, my $buffer, 1024))
				{
					push(@$array, $buffer);
				}
				
				close($fh);

				push(@{$self->[+OUTBUFFER]}, $array);
			}
		}

		if(@{$self->[+OUTBUFFER]})
		{
			return shift(@{$self->[+OUTBUFFER]});
		
		} else {

			return [];
		}
	}
}

sub put()
{
	my ($self, $content) = @_;

	my $response = HTTP::Response->new();

	if(@$content)
	{
		$response->code(+RC_OK);
		$response->content_type('text/xml');
		
		foreach my $stuff (@$content)
		{
			$response->add_content($stuff);
		}
	
	} else {

		$response->code(+RC_INTERNAL_SERVER_ERROR);
		$response->content_type('text/html');
		$response->content_length(length(+SERVER_ERROR));
		$response->content(+SERVER_ERROR);
	}

	return [$response];
}

1;
