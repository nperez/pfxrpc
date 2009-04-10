package POE::Filter::XML::RPC::Request;

use 5.010;
use warnings;
use strict;

use POE::Filter::XML::Node;

use base('POE::Filter::XML::Node');

sub new()
{
	my ($class, $methodname, $params) = @_;
	
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
        bless($val, 'POE::Filter::XML::RPC::Value');
		push(@$values, $val);
	}

	return $values;
}

sub add_parameter()
{
	my ($self, $val) = @_;

	$self->add($self->wrap($val));
    
    return bless($val, 'POE::Filter::XML::RPC::Value');
}

sub insert_parameter()
{
	my ($self, $val, $index) = @_;
	
	$self->insert($self->wrap($val), $index);

    return bless($val, 'POE::Filter::XML::RPC::Value');
}

sub delete_parameter()
{
	my ($self, $index) = @_;

	my $val = $self->delete($index)->getSingleChildByTagName('value');

    return bless($val, 'POE::Filter::XML::RPC::Value');
}

sub get_parameter()
{
	my ($self, $index) = @_;
    
	my $val = $self->get($index)->getSingleChildByTagName('value');
    
    return bless($val, 'POE::Filter::XML::RPC::Value');
}

sub datatag()
{
	return ordain(shift(@_)->getSingleChildByTagName('params'));
}

sub add()
{
    my ($self, $val) = @_;
    ordain($self->datatag()->appendChild($val));
}

sub delete()
{
    my ($self, $index) = @_;
    return ordain($self->datatag()->removeChild($self->get($index)));
}

sub insert()
{
    my ($self, $val, $index) = @_;
    return ordain($self->datatag()->insertBefore($self->get($index)));
}

sub get()
{
    my ($self, $index) = @_;
    return ordain(($self->datatag()->getChildrenByTagName('*'))[$index]);
}

sub wrap()
{
	my ($self, $val) = @_;

	my $param = POE::Filter::XML::Node->new('param');
	
	$param->appendChild($val);

	return $param;
}
1;
