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
		$self->insert_tag('name')->data($key);
	
	} else {

		$self->insert_tag('name');
	}

	if(defined($value))
	{
		$self->insert_tag($value);
	
	} else {

		$self->insert_tag(POE::Filter::XML::RPC::Value->new());
	}

	return $self;
}

sub key()
{
	return shift(@_)->get_tag('name')->data();
}

sub value()
{
	return shift(@_)->get_tag('value');
}


1;
