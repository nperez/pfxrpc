package POE::Filter::XML::RPC::Value::Int;

use warnings;
use strict;

use constant 'TYPE' => 'int';

use base('POE::Filter::XML::RPC::Value');

sub new()
{
	my ($class, $arg) = @_;

	my $self = $class->SUPER::new();

	return bless($self, $class);
}

1;
