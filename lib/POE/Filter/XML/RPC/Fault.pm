package POE::Filter::XML::RPC::Fault;

use warnings;
use strict;

use POE::Filter::XML::RPC::Value;

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
    return shift(@_)->find('child::value/child::struct/child::member[child::name/child::text() = "faultCode"]/child::value/child::*[self::int or self::i4]/child::text()');
}

sub string()
{
    return shift(@_)->find('child::value/child::struct/child::member[child::name/child::text() = "faultString"]/child::value/child::string/child::text()');
}

1;
