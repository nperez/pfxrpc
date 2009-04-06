package POE::Filter::XML::RPC::Value;

use warnings;
use strict;

use base('POE::Filter::XML::Node');

use constant 'TYPE' => 'string';

sub new
{
	my $class = shift(@_);
    my $arg = shift(@_);

	my $self = $class->SUPER::new('value');
	
    $self->appendChild(+TYPE)->textContent($arg);
	
    bless ($self, $class);
	return $self;
}

sub value()
{
    my ($self, $arg) = @_;
    
    my $node = $self->getSingleChildByTagName(+TYPE);
    my $content = $self->textContent();

    if(!defined($node) && (defined($content) and length($content)))
    {
        # we have a non value-wrapped string
        
        if(defined($arg))
        {
            $self->textContent($arg);

        } else {

            return $content;
        }
    }
    else
    {
        if(defined($arg))
        {
            $self->getSingleChildByTagName(+TYPE)->textContent($arg);

        } else {

            return $self->getSingleChildByTagName(+TYPE)->textContent();
        }
    }
}

1;
