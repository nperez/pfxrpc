package POE::Filter::XML::RPC::Value::Base64;

use warnings;
use strict;

use constant 'TYPE' => 'base64';

our @ISA = qw/ POE::Filter::XML::RPC::Value /;

sub new()
{
	my ($class, $arg) = @_;

	my $self = $class->SUPER::new();

	$self->insert_tag(+TYPE)->data($arg);

	return bless($self, $class);
}

sub value()
{
	my ($self, $arg) = @_;
	
	if(defined($arg))
	{
		$self->get_tag(+TYPE)->data($arg);
	
	} else {

		return $self->get_tag(+TYPE)->data();
	}
}

1;
