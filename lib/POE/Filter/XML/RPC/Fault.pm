package POE::Filter::XML::RPC::Fault;

use warnings;
use strict;

use base('POE::Filter::XML::Node');

sub new()
{
	my ($class, $code, $string) = @_;

	my $self = $class->SUPER::new('fault');

    my $hash = {'faultCode' => $code, 'faultString' => $string};
	my $struct = POE::Filter::XML::RPC::Value->new($hash);

	$self->appendChild($struct);

	return bless($self, $class);
}

sub code()
{
	return shift(@_)->struct()->value()->{'faultCode'};
}

sub string()
{
	return shift(@_)->struct()->value()->{'faultString'};
}

sub struct()
{
	return bless(shift(@_)->getSingleChildByTagName('value'), 'POE::Filter::XML::RPC::Value');
}

1;
