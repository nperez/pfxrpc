package POE::Filter::XML::RPC::Value::StructMember;

use warnings;
use strict;

use base('POE::Filter::XML::Node');

sub new()
{
	my ($class, $key, $value) = @_;

	my $self = $class->SUPER::new('member');

	if(defined($key))
	{
		$self->appendChild('name')->textContent($key);
	
	} else {

		$self->appendChild('name');
	}

	if(defined($value))
	{
		$self->appendChild($value);
	
	} else {

		$self->appendChild(POE::Filter::XML::RPC::Value->new());
	}

	return $self;
}

sub key()
{
    if(@_ > 1)
    {
        my ($self, $arg) = @_;
        $self->getSingleChildByTagName('name')->textContent($arg);
    }
    else
    {
	    return shift(@_)->getSingleChildByTagName('name')->textContent();
    }
}

sub value()
{
    if(@_ > 1)
    {
        my ($self, $arg) = @_;
        my $val = $self->getSingleChildByTagName('value');
        $self->removeChild($val);
        
        if(ref($arg) && $arg->isa('POE::Filter::XML::RPC::Value'))
        {
            $self->appendChild($arg);
        }
        else
        {
            #bleh need to write a value type guesser
            $self->appendChild(POE::Filter::XML::RPC::Value::String->new($arg));
        }
    }
    else
    {
	    return shift(@_)->getSingleChildByTagName('value');
    }
}


1;
