package POE::Filter::XML::RPC::Value::String;

use warnings;
use strict;

use constant 'TYPE' => 'string';

use base('POE::Filter::XML::RPC::Value');

sub new()
{
	my ($class, $arg) = @_;

	my $self = $class->SUPER::new();

	$self->appendChild(+TYPE)->textContent($arg);

	return bless($self, $class);
}

sub value()
{
	my ($self, $arg) = @_;
	
	if(defined($arg))
	{
		$self->getSingleChildByTagName(+TYPE)->textContent($arg);
	
	} else {
		
		return $self->getSingleChildByTagName(+TYPE)->textContent();
	}
}

1;
