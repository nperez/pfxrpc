package POE::Filter::XML::RPC::Value::Struct;

use warnings;
use strict;

use POE::Filter::XML::RPC::Value::StructMember;

use constant 'TYPE' => 'struct';

use base('POE::Filter::XML::RPC::Value');

sub new()
{
	my ($class, $hash) = @_;

	my $self = $class->SUPER::new();

	$self->appendChild(+TYPE);

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
	
    my $member = POE::Filter::XML::RPC::Value::StructMember->new($key, $value);
	$self->datatag()->appendChild($member);

	return $member;
}

sub remove_member()
{
	my ($self, $key) = @_;

	my $member = $self->get_member($key);

	if(defined($member))
	{
        $self->removeChild($member);
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

	my $children = $self->_values();

	foreach my $child (@$children)
	{
		if($child->getSingleChildByTagName('name')->textContent() eq $key)
		{
			return bless($child, __PACKAGE__);
		}
	}

	return undef;
}

sub values()
{
    my $self = shift(@_);
    my $values = 
        [ map { bless($_, __PACKAGE__) if defined $_; } 
        $self->_values();
	return $values;
}

sub _values()
{
    return shift(@_)->datatag()->getChildrenByTagName('*');
}

sub datatag()
{
	return shift(@_)->getSingleChildByTagName(+TYPE);
}

1;
