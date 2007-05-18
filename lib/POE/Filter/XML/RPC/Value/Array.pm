package POE::Filter::XML::RPC::Value::Array;

use warnings;
use strict;

our @ISA = qw/ POE::Filter::XML::RPC::Value /;

use constant 'id' => 4;

sub new()
{
	my ($class, $array) = @_;
	
	my $self = $class->SUPER::new();

	bless($self, $class);

	$self->insert_tag('array')->insert_tag('data');

	foreach my $val (@$array)
	{
		$self->add($val);
	}
	
	return $self;
}

sub add()
{
	my ($self, $val) = @_;
	
	my $children = $self->values();

	my $data = $self->datatag();

	if(@$children)
	{
		$val->[+id] = $#{$children} + 1;
		$data->insert_tag($val);
	
	} else {

		$val->[+id] = 0;
		$data->insert_tag($val);
	}

	return $val;
}

sub remove()
{
	my ($self, $val) = @_;
	
	$val->detach();
	$self->_update_id();

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

	$val->[+id] = $index;

	my $children = $self->values();

	foreach my $child (@$children)
	{
		if($child->[+id] >= $index)
		{
			$child->[+id]++;
		}
	}

	$data->insert_tag($val);

	return $val;
}


sub delete()
{
	my ($self, $index) = @_;
	
	if(!$self->_check_index($index))
	{
		Carp::confess('Index "' . $index . '" out of range!');
	}

	my $children = $self->values();
	
	foreach my $child (@$children)
	{
		if($child->[+id] == $index)
		{
			$child->detach();
			$self->_update_id();
			return $child;
		}
	}
}

sub get()
{
	my ($self, $index) = @_;

	if(!$self->_check_index($index))
	{
		Carp::confess('Index "' . $index . '" out of range!');
	}
	
	my $children = $self->values();
	
	foreach my $child (@$children)
	{
		if($child->[+id] == $index)
		{
			return $child;
		}
	}
}

sub values()
{
	return shift(@_)->datatag()->get_sort_children();
}

sub _update_id()
{
	my $values = shift(@_)->values();
	
	for(0..$#{$values})
	{
		$values->[$_]->[+id] = $_;
	}
}

sub _check_index()
{
	my ($self, $index) = @_;
	
	return $index > 0 and $index <= $#{$self->values()} + 1;
}

sub datatag()
{
	return shift(@_)->get_tag('array')->get_tag('data');
}

1;
