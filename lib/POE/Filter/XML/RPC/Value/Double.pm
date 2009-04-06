package POE::Filter::XML::RPC::Value::Double;

use warnings;
use strict;

use base('POE::Filter::XML::RPC::Value');

use constant 'TYPE' => 'double';

sub new()
{
	my ($class, $arg) = @_;

	my $self = $class->SUPER::new();

	return bless($self, $class);
}

1;
