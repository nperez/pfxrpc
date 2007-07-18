package POE::Filter::XML::RPC::Guts;
use Filter::Template;
const XRPC POE::Filter::XML::RPC

use POE::Filter::XML::RPC::Request;
use POE::Filter::XML::RPC::Response;
use POE::Filter::XML::RPC::ValueFactory;
use POE::Filter::XML::RPC::Fault;

use POE::Filter::XML::Node;

use base('POE::Filter');

use constant
{
	BUFFER => 0,
};

sub new()
{
	my $class = shift;
	my $self = [];
	
	$self->[+BUFFER] = [];

	return bless($self, $class);
}

sub get_one_start()
{
	my ($self, $raw) = @_;
	if(@{$self->[+BUFFER]})
	{
		push(@{$self->[+BUFFER]}, @$raw);
	
	} else {

		$self->[+BUFFER] = $raw;
	}
}

sub get_one()
{
	my $self = shift(@_);
	
	my $node = shift(@{$self->[+BUFFER]});
	

	if(defined($node))
	{
		if($node->name() eq 'methodCall')
		{
			my $children = $node->get_children_hash();
			if(exists($children->{'methodName'}))
			{
				my $data = $children->{'methodName'}->data();
				if(!defined($data) and !length($data))
				{
					return 
					[
						XRPC::Fault->new
						(
							102,
							'Malformed XML-RPC: No methodName data defined'
						)
					];
				}
			
			} else {

				return
				[
					XRPC::Fault->new
					(
						103,
						'Malformed XML-RPC: No methodName child tag present'
					)
				];
			}
			
			# params are optional, but let's be consistent for the
			# Request code's sake.

			if(!exists($children->{'params'}))
			{
				$node->insert_tag('params');
			
			} else {

				my $params = $children->{'params'}->get_sort_children();

				foreach my $param (@$params)
				{
					my $value = $param->get_tag('value');
					
					if(!defined($value))
					{
						return
						[
							XRPC::Fault->new
							(
								110,
								'Malformed XML-RPC: No value tag within param'
							)
						];
					}
					
					XRPC::ValueFactory::value_process($value);
				}
			}
					
			bless($node, 'XRPC::Request');
			return [$node];
	
		} elsif ($node->name() eq 'methodResponse') {
			
			my $children = $node->get_children_hash();

			if(!exists($children->{'params'}) and 
				!exists($children->{'fault'}))
			{
				return
				[
					XRPC::Fault->new
					(
						104,
						'Malformed XML-RPC: Response does not contain ' .	
						'parameters or a fault object'
					)
				]
			
			} elsif(exists($children->{'params'})) {
					
				my $params = $children->{'params'}->get_sort_children();

				if(!@{$params})
				{
					return
					[
						XRPC::Fault->new
						(
							105,
							'Malformed XML-RPC: Return parameters does ' .
							'not contain any param children'
						)
					];
				
				} 

				foreach my $param (@$params)
				{
					my $value = $param->get_tag('value');

					if($param->name() ne 'param')
					{
						return
						[
							XRPC::Fault->new
							(
								108,
								'Malformed XML-RPC: Params object ' .
								'contains children other than param'
							)
						];
					
					}

					if(!defined($value))
					{
						return
						[
							XRPC::Fault->new
							(
								109,
								'Malformed XML-RPC: Param child does '.
								'not contain a value object'
							)
						];
					
					} else {

						XRPC::ValueFactory::value_process($value);
					}
				}
		
			} elsif(exists($children->{'fault'})) {

				my $fault = $children->{'fault'};
				my $value = $fault->get_tag('value');

				my $struct = 
					XRPC::ValueFactory::value_process
					(
						$value
					);

				if(!$struct->isa('XRPC::Value::Struct'))
				{
					return
					[
						XRPC::Fault->new
						(
							106,
							'Malformed XML-RPC: Fault value is not a ' .
							'valid struct object'
						)
					];
				
				} 
				elsif(!defined($struct->get_member('faultCode')) or
					!defined($struct->get_member('faultString')))
				{
					return
					[
						XRPC::Fault->new
						(
							107,
							'Malformed XML-RPC: Fault value does not ' . 
							'contain either a fault code or fault string'
						)
					];
				}

				bless($fault, 'XRPC::Fault');
			}
				
			bless($node, 'XRPC::Response');
			return [$node];
		
		} else {
			
			warn $node->to_str();

			return 
			[
				XRPC::Fault->new
				( 
					101, 
					'Malformed XML-RPC: Top level node is not valid'
				)
			];
		}
	
	} else {

		return [];
	}
}

sub put()
{
	my ($self, $nodes) = @_;
	
	my $ret = [];

	foreach my $node (@$nodes)
	{
		push(@$ret, bless($node, 'POE::Filter::XML::Node'));
	}
	
	return $ret;
}

1;
