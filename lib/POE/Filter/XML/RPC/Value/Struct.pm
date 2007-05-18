package POE::Filter::XML::RPC::Value::Struct;

use warnings;
use strict;

use POE::Filter::XML::Node;
use POE::Filter::XML::RPC::Value::StructMember;

our @ISA = qw/ POE::Filter::XML::RPC::Value /;

use constant 'TYPE' => 'struct';

sub new()
{
	my ($class, $hash) = @_;

	my $self = $class->SUPER::new();

	$self->insert_tag(+TYPE);

	bless($self, $class);

	while(my ($key, $value) = each %$hash)
	{
		$self->add_member($key, $value);
	}

	return $self;
}

sub add_member()
{
	my ($self, $key, $value) = @_;
	
	my $member = $self->insert_tag(
		POE::Filter::XML::RPC::Value::StructMember->new($key, $value)
	);

	return $member;
}

sub remove_member()
{
	my ($self, $key) = @_;

	my $member = $self->get_member($key);

	if(defined($member))
	{
		$member->detach();
	}

	return $member;
}

sub get_value()
{
	my ($self, $key) = @_;

	my $member = $self->get_member($key);
	
	if(defined($member))
	{
		return $member->value();
	}

	return undef;
}

sub get_member()
{
	my ($self, $key) = @_;

	my $children = $self->values();

	foreach my $child (@$children)
	{
		if($child->get_tag('name')->data() eq $key)
		{
			return $child;
		}
	}

	return undef;
}

sub values()
{
	return shift(@_)->get_sort_children();
}

1;
