package POE::Filter::XML::RPC::Value;

use 5.010;
use warnings;
use strict;

use base('POE::Filter::XML::Node', 'Exporter');
use Class::InsideOut('register', 'public');
use Scalar::Util('looks_like_number', 'reftype');

use constant 
{
    'ARRAY'     => 0,
    'BASE64'    => 1,
    'BOOL'      => 2,
    'DATETIME'  => 3,
    'DOUBLE'    => 4,    
    'INT'       => 5,
    'STRING'    => 6,
    'STRUCT'    => 7,
};

our @EXPORT= qw/ ARRAY BASE64 BOOL DATETIME DOUBLE INT STRING STRUCT /;

public 'type' => my %type;

sub new
{
	my $class = shift(@_);
    my $arg = shift(@_);
    my $force_bool = shift(@_);

	my $self = $class->SUPER::new('value');
    bless($self, $class);
    register($self);

    my $type;

    given($arg)
    {
        when(m#^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$#)
        {
            $self->type(+BASE64);
            $type = 'base64';
        }
        when(/^(?:1|0){1}|true|false$/i)
        {
            $self->type(+BOOL);
            $type = 'bool';
        }
        when(looks_like_number($_))
        {
            if($_ =~ /\.{1}/)
            {
                $self->type(+DOUBLE);
                $type = 'double';
            }
            else
            {
                $self->type(+INT);
                $type = 'int';
            }
        }
        when(reftype($_) eq 'ARRAY')
        {
            $self->type(+ARRAY);
            # do array processing
            return $self;
        }
        when(reftype($_) eq 'HASH')
        {
            $self->type(+STRUCT);
            # do hash processing
            return $self;
        }
        default
        {
            $self->type(+STRING);
            $type = 'string';
        }
    }
	
    $self->appendChild($type)->appendText($arg);
    
	return $self;
}

sub value()
{
}

1;
