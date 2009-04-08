package POE::Filter::XML::RPC::Request;

use 5.010;
use warnings;
use strict;

use base('POE::Filter::XML::RPC::Value::Array');

use constant 'id' => 4;

sub new()
{
	my ($class, $methodname, $params) = @_;
$DB::single=1;
	my $self = POE::Filter::XML::Node->new('methodCall');
	$self->appendChild('methodName');
	$self->appendChild('params');

	bless($self, $class);

	$self->method_name($methodname);

	if(defined($params) and ref($params) eq 'ARRAY')
	{
		foreach my $param (@$params)
		{
			$self->add_parameter($param);
		}
	}

	return $self;
}

sub method_name()
{
	my ($self, $arg) = @_;

	if(defined($arg))
	{
		$self->getSingleChildByTagName('methodName')->appendText($arg);
		return $arg;
	
	} else {

		return $self->getSingleChildBTagName('methodName')->textContent();
	}
}

sub parameters()
{
	my $self = shift(@_);

	my $params = $self->values();

	my $values = [];

	foreach my $param (@$params)
	{
        my $val = $param->getSingleChildByTagName('value');
        
        given($val)
        {
            when($_->isa('POE::Filter::XML::RPC::Value::Array'))
            {
                bless($_, 'POE::Filter::XML::RPC::Value::Array');
            }
            when($_->isa('POE::Filter::XML::RPC::Value::Struct'))
            {
                bless($_, 'POE::Filter::XML::RPC::Value::Struct');
            }
            default
            {
                return bless($_, 'POE::Filter::XML::RPC::Value');
            }
        }

		push(@$values, $val);
	}

	return $values;
}

sub add_parameter()
{
	my ($self, $val) = @_;

	$self->add($self->wrap($val));
    
    given($val)
    {
        when($_->isa('POE::Filter::XML::RPC::Value::Array'))
        {
            return bless($_, 'POE::Filter::XML::RPC::Value::Array');
        }
        when($_->isa('POE::Filter::XML::RPC::Value::Struct'))
        {
            return bless($_, 'POE::Filter::XML::RPC::Value::Struct');
        }
        default
        {
            return bless($_, 'POE::Filter::XML::RPC::Value');
        }
    }
}

sub insert_parameter()
{
	my ($self, $val, $index) = @_;
	
	$self->insert($self->wrap($val), $index);

    given($val)
    {
        when($_->isa('POE::Filter::XML::RPC::Value::Array'))
        {
            return bless($_, 'POE::Filter::XML::RPC::Value::Array');
        }
        when($_->isa('POE::Filter::XML::RPC::Value::Struct'))
        {
            return bless($_, 'POE::Filter::XML::RPC::Value::Struct');
        }
        default
        {
            return bless($_, 'POE::Filter::XML::RPC::Value');
        }
    }
}

sub delete_parameter()
{
	my ($self, $index) = @_;

	my $val = $self->delete($index)->getSingleChildByTagName('value');

    given($val)
    {
        when($_->isa('POE::Filter::XML::RPC::Value::Array'))
        {
            return bless($_, 'POE::Filter::XML::RPC::Value::Array');
        }
        when($_->isa('POE::Filter::XML::RPC::Value::Struct'))
        {
            return bless($_, 'POE::Filter::XML::RPC::Value::Struct');
        }
        default
        {
            return bless($_, 'POE::Filter::XML::RPC::Value');
        }
    }
}

sub get_parameter()
{
	my ($self, $index) = @_;
    
	my $val = $self->get($index)->getSingleChildByTagName('value');
    
    given($val)
    {
        when($_->isa('POE::Filter::XML::RPC::Value::Array'))
        {
            return bless($_, 'POE::Filter::XML::RPC::Value::Array');
        }
        when($_->isa('POE::Filter::XML::RPC::Value::Struct'))
        {
            return bless($_, 'POE::Filter::XML::RPC::Value::Struct');
        }
        default
        {
            return bless($_, 'POE::Filter::XML::RPC::Value');
        }
    }
}

sub datatag()
{
	return shift(@_)->getSingleChildByTagName('params');
}

sub wrap()
{
	my ($self, $val) = @_;

	my $param = POE::Filter::XML::Node->new('param');
	
	$param->appendChild($val);

	return $param;
}
1;
