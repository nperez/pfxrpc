package POE::Filter::XML::RPC::Value::DateTime;

use warnings;
use strict;

use base('POE::Filter::XML::RPC::Value');

use constant 'TYPE' => 'dateTime.iso8601';

sub new()
{
	my ($class, $arg) = @_;

	my $self = $class->SUPER::new();

	return bless($self, $class);
}

1;
