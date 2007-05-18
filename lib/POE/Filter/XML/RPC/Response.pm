package POE::Filter::XML::RPC::Response;

use warnings;
use strict;

use base('POE::Filter::XML::Node');

sub new()
{
	my ($class, $arg) = @_;

	my $node = $class->SUPER::new('methodResponse');
	
	bless($node, $class);

	if($arg->isa('POE::Filter::XML::RPC::Fault'))
	{
		$node->fault($arg);
	
	} elsif($arg->isa('POE::Filter::XML::RPC::Value')) {

		$node->return_value($arg);
	}

	return $node;
		
}	

sub fault()
{
	my ($self, $arg) = @_;
	
	if(defined($arg))
	{
		my $fault = $self->get_tag('fault');
		
		if(!defined($fault))
		{
			$self->insert_tag($arg);
		
		} else {
	
			$fault->detach();
			$self->insert_tag($arg);
		}
	
		return $arg;

	} else {

		return $self->get_tag('fault');
	}

}

sub return_value()
{
	my ($self, $arg) = @_;
	
	if(defined($arg))
	{
		if(!defined($self->get_tag('params')))
		{
			$self->insert_tag('params')->insert_tag('param')->insert_tag($arg);
		
		} else {
	
			$self->get_tag('params')->get_tag('param')->insert_tag($arg);
		}

		return $arg;
	
	} else {

		if(my $params = $self->get_tag('params'))
		{
			if(my $param = $params->get_tag('param'))
			{
				return $param->get_tag('value');
			}
		}

		return undef;
	}
}

1;
