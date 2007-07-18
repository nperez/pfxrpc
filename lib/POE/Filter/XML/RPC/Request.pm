package POE::Filter::XML::RPC::Request;

use warnings;
use strict;

use base('POE::Filter::XML::RPC::Value::Array');

use constant 'id' => 4;

sub new()
{
	my ($class, $methodname, $params) = @_;

	my $self = POE::Filter::XML::Node->new('methodCall');
	$self->insert_tag('methodName');
	$self->insert_tag('params');

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
		$self->get_tag('methodName')->data($arg);
		return $arg;
	
	} else {

		return $self->get_tag('methodName')->data();
	}
}

sub parameters()
{
	my $self = shift(@_);

	my $params = $self->values();

	my $values = [];

	foreach my $param (@$params)
	{
		push(@$values, $param->get_tag('value'));
	}

	return $values;
}

sub add_parameter()
{
	my ($self, $val) = @_;

	$self->add($self->wrap($val));

	return $val;
}

sub remove_parameter()
{
	my ($self, $val) = @_;

	$self->remove($self->wrap($val));

	return $val;
}

sub insert_parameter()
{
	my ($self, $val, $index) = @_;
	
	$self->insert($self->wrap($val), $index);

	return $val;
}

sub delete_parameter()
{
	my ($self, $index) = @_;

	return $self->delete($index)->get_tag('value');
}

sub get_parameter()
{
	my ($self, $index) = @_;

	return $self->get($index)->get_tag('value');
}

sub datatag()
{
	return shift(@_)->get_tag('params');
}

sub wrap()
{
	my ($self, $val) = @_;

	my $param = POE::Filter::XML::Node->new('param');
	
	$param->insert_tag($val);

	return $param;
}
1;
