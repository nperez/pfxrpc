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

    my $fault = $self->getSingleChildByTagName('fault');

	if(defined($arg))
	{	
		if(!defined($fault))
		{
			$self->appendChild($arg);
		
		} else {
	
			$self->removeChild($fault);
			$self->appendChild($arg);
		}
	
		return $arg;

	} else {
        
        return undef if not defined $fault;
		return bless('POE::Filter::XML::RPC::Fault', $self->getSingleChildByTagName('fault'));
	}

}

sub return_value()
{
	my ($self, $arg) = @_;
	
	if(defined($arg))
	{
		if(!defined($self->getSingleChildByTagName('params')))
		{
			$self->appendChild('params')->appendChild('param')->appendChild($arg);
		
		} else {
	
			$self->getSingleChildByTagName('params')->getSingleChildByTagName('param')->appendChild($arg);
		}

		return $arg;
	
	} else {

		if(my $params = $self->getSingleChildByTagName('params'))
		{
			if(my $param = $params->getSingleChildByTagName('param'))
			{
				return bless($param->getSingleChildByTagName('value'), 'POE::Filter::XML::RPC::Value');
			}
		}

		return undef;
	}
}

1;
