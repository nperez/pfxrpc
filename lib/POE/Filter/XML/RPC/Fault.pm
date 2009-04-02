package POE::Filter::XML::RPC::Fault;

use warnings;
use strict;

use base('POE::Filter::XML::Node');

sub new()
{
	my ($class, $code, $string) = @_;

	my $self = $class->SUPER::new('fault');

	my $struct = POE::Filter::XML::RPC::Value::Struct->new();
	my $int = POE::Filter::XML::RPC::Value::Int->new($code);
	my $message = POE::Filter::XML::RPC::Value::String->new($string);

	$struct->add_member('faultCode', $int);
	$struct->add_member('faultString', $message);

	$self->appendChild($struct);

	return bless($self, $class);
}

sub code()
{
	return shift(@_)->struct()->get_member('faultCode')->value()->textContent();
}

sub string()
{
	return shift(@_)->struct()->get_member('faultString')->value()->textContent();
}

sub struct()
{
	return shift(@_)->getSingleChildByTagName('value');
}

1;
