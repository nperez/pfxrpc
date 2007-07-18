package POE::Filter::XML::RPC::HTTPShim;

use warnings;
use strict;


use Carp;

use HTTP::Response;
use HTTP::Request;
use HTTP::Status;

use Exporter;

use base('POE::Filter', 'Exporter');

use constant 
{
	#Interal Members
	'INBUFFER'		=> 0,
	'OUTBUFFER'		=> 1,
	'MODE'			=> 2,
	'URI'			=> 3,
	'USERAGENT'		=> 4,
	'HOST'			=> 5,
	'SERVER'		=> 6,
	
	#Exported modes
	'SERVER_MODE'	=> 0,
	'CLIENT_MODE'	=> 1,

	#For server mode
	'SERVER_ERROR'	=> '<html><body>500 internal server error</body></html>',
};

our $VERSION = '0.01';
our @EXPORT = qw/ CLIENT_MODE SERVER_MODE /;

sub clone()
{
	my $self = shift(@_);

	return POE::Filter::XML::RPC::HTTPShim->new
	(
		'mode'			=> $self->[+MODE],
		'uri'			=> $self->[+URI],
		'useragent'		=> $self->[+USERAGENT],
		'hostheader'	=> $self->[+HOST],
		'serverheader'	=> $self->[+SERVER],
	);
}

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
	$self->[+INBUFFER] = [];
	$self->[+OUTBUFFER] = [];
	
	
	unless(exists($config->{'mode'}))
	{
		Carp::confess('Client/Server mode specification is required!');
	}
	
	if($config->{'mode'} == +CLIENT_MODE)
	{
		unless($config->{'hostheader'})
		{
			Carp::confess
			(
				'A HostHeader argument is required to be' .
				'compliant with the XML-RPC spec. Please provide one.'
			);
		}
	
		unless($config->{'uri'})
		{
			$config->{'uri'} = '/';
		}
	
	
		unless($config->{'useragent'})
		{
			$config->{'useragent'} = __PACKAGE__ . '/' . $VERSION;
		}
		
		$self->[+HOST] = $config->{'hostheader'};
		$self->[+URI] = $config->{'uri'};
		$self->[+USERAGENT] = $config->{'useragent'};
		$self->[+MODE] = $config->{'mode'};
	
	} elsif($config->{'mode'} == +SERVER_MODE) {
		
		unless($config->{'serverheader'})
		{
			$config->{'serverheader'} = __PACKAGE__ . '/' . $VERSION;
		}

		$self->[+SERVER] = $config->{'serverheader'};
		$self->[+MODE] = $config->{'mode'};
	
	} else {

		Carp::confess
		(
			'Unknown mode specified: ' . $config->{'mode'}
		);
	}
		

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
	
	my $http;

	if($self->[+MODE] == +SERVER_MODE)
	{
		my $response;
		
		if(@$content)
		{
			$response = HTTP::Response->new(+RC_OK);
			$response->content_type('text/xml');
			$response->server($self->[+SERVER]);
			
			foreach my $stuff (@$content)
			{
				$response->add_content($stuff);
			}
		
		} else {
			
			$response = HTTP::Response->new(+RC_INTERNAL_SERVER_ERROR);
			$response->content_type('text/html');
			$response->content_length(length(+SERVER_ERROR));
			$response->content(+SERVER_ERROR);
		}

		$http = $response;

	} else {

		my $request = HTTP::Request->new();

		if(@$content)
		{
			$request->method('POST');
			$request->uri($self->[+URI]);
			$request->user_agent($self->[+USERAGENT]); 
			
			foreach my $stuff (@$content)
			{
				$request->add_content($stuff);
			}
		}
		
		$http = $request;
	}

	$http->protocol('HTTP/1.0');
	
	return [$http];
}

1;
