package POE::Filter::XML::RPC::Value::Array;

use warnings;
use strict;

use base('POE::Filter::XML::RPC::Value');

sub new()
{
	my ($class, $array) = @_;
	
	my $self = $class->SUPER::new();

	bless($self, $class);

	$self->appendChild('array')->appendChild('data');

	foreach my $val (@$array)
	{
		$self->add($val);
	}
	
	return $self;
}

sub add()
{
	my ($self, $val) = @_;
	
	my $data = $self->datatag();
	$data->appendChild($val);
	
	return $val;
}

sub insert()
{
	my ($self, $val, $index) = @_;

	if(!$self->_check_index($index))
	{
		Carp::confess('Index "' . $index . '" out of range!');
	}

	my $data = $self->datatag();

	my $refnode = $self->get($index - 1);

	$data->insertAfter($val, $refnode);

	return $val;
}


sub delete()
{
	my ($self, $index) = @_;
	
	if(!$self->_check_index($index))
	{
		Carp::confess('Index "' . $index . '" out of range!');
	}

	my $child = [$self->values()]->[$index];
    $self->removeChild($child);
    return $child;
}

sub get()
{
	my ($self, $index) = @_;

	if(!$self->_check_index($index))
	{
		Carp::confess('Index "' . $index . '" out of range!');
	}
	
	return [$self->values()]->[$index];
	
}

sub values()
{
	return shift(@_)->datatag()->getChildrenByTagName('*');
}

sub _check_index()
{
	my ($self, $index) = @_;
	
	return $index > 0 and $index <= $#{$self->values()} + 1;
}

sub datatag()
{
	return shift(@_)->getSingleChildByTagName('array')->getSingleChildByTagName('data');
}

1;
