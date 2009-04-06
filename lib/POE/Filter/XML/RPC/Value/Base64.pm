package POE::Filter::XML::RPC::Value::Base64;

use warnings;
use strict;

use base('POE::Filter::XML::RPC::Value');

use constant 'TYPE' => 'base64';

sub new()
{
	my ($class, $arg) = @_;

	my $self = $class->SUPER::new();

	return bless($self, $class);
}

1;
