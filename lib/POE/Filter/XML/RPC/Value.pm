package POE::Filter::XML::RPC::Value;

use warnings;
use strict;

use base('POE::Filter::XML::Node');


sub new
{
	my $class = shift(@_);

	my $self = $class->SUPER::new('value');
	
	bless ($self, $class);
	return $self;
}


1;
