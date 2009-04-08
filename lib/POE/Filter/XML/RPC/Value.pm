package POE::Filter::XML::RPC::Value;

use 5.010;
use warnings;
use strict;

use base('POE::Filter::XML::Node', 'Exporter');
use Class::InsideOut(':std');
use Scalar::Util('looks_like_number', 'reftype');

use constant 
{
    'ARRAY'     => 'array',
    'BASE64'    => 'base64',
    'BOOL'      => 'bool',
    'DATETIME'  => 'dateTime.iso8601',
    'DOUBLE'    => 'double',    
    'INT'       => 'int',
    'STRING'    => 'string',
    'STRUCT'    => 'struct',
    'DATA'      => 'data',
    'NAME'      => 'name',
    'VALUE'     => 'value',
    'MEMBER'    => 'member',
};

our @EXPORT= qw/ ARRAY BASE64 BOOL DATETIME DOUBLE INT STRING STRUCT /;

private 'type' => my %type;

sub new
{
	my $class = shift(@_);
    my $arg = shift(@_);
    my $force_type = shift(@_);
    
    my $val = process($arg, $force_type);
    bless($val, $class);
    register($val);

    $type{id($val)} = $force_type // determine_type($arg);
}

sub process
{
    my ($arg, $force) = (shift(@_), shift(@_));
    
    my $val = __PACKAGE__->SUPER::new(+VALUE);
    
    given($force // determine_type($arg))
    {
        when(+ARRAY)
        {
            my $data = $val->appendChild(+ARRAY)->appendChild(+DATA);
            
            foreach(@$arg)
            {
                $data->appendChild(process($_));
            }
        }
        when(+STRUCT)
        {
            my $struct = $val->appendChild(+STRUCT);

            while(my ($key, $val) = each %$_)
            {
                my $member = $struct->appendChild(+MEMBER);
                $member->appendChild(+NAME);
                $member->appendChild(process($val));
            }
        }
        default
        {
            $val->appendChild($_)->appendText($arg);
        }
    }

    return $val;
}

sub value()
{
    my ($self, $arg) = (shift(@_), shift(@_));
    
    if(defined($arg))
    {
        my $type = determine_type($arg);
        $self->removeChild(($self->firstChild()));
        $self->appendChild($type)->appendText($arg);
    }
    else
    {
        my $content = $self->textContent();
        if(defined($content))
        {
            return $content;
        }
        elsif(exists($type{id($self)}) && defined(my $valtype = $type{id($self)}))
        {
            return $self->getSingleChildByTagName($valtype)->textContent();
        }
        else
        {
            return node_to_value($self);
        }
    }
}

sub node_to_value
{
    my $node = shift(@_);
    
    my $content = $node->textContent();
    return $content if defined($content);

    my $val = $node->firstChild();
    given($val->nodeName())
    {
        when(+STRUCT)
        {
            my $struct = {};
            foreach($node->getChildrenByTagName('member'))
            {
                $struct->{($_->getChildrenByTagName('name'))[0]->textContent()} =
                    node_to_value(($_->getChildrenByTagName('value'))[0]);
            }

            return $struct;
        }
        when(+ARRAY)
        {
            my $array = [];

            foreach($node->firstChild()->getChildrenByTagName('value'))
            {
                push(@$array, node_to_value($_));
            }

            return $array;
        }
        default
        {
            return $val->textContent();
        }
    }
}

sub type()
{
    my $self = shift(@_);
    
    if(!exists($type{id($self)}) || !defined($type{id($self)}))
    {
        my $content = $self->textContent();
        
        if(defined($content))
        {
            # string
            $type{id($self)} = +STRING;
            return +STRING;
        }
        
        my $determined = determine_type($self->value());
        $type{id($self)} = $determined;
        return $determined;
    }
    else
    {
        return $type{id($self)};
    }
}

sub determine_type($)
{
    my $arg = shift(@_);
    
    given($arg)
    {
        when(m@^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$@)
        {
            return +BASE64;
        }
        when(/^(?:1|0){1}|true|false$/i)
        {
            return +BOOL;
        }
        when(looks_like_number($_))
        {
            if($_ =~ /\.{1}/)
            {
                return +DOUBLE;
            }
            else
            {
                return +INT;
            }
        }
        when(reftype($_) eq 'ARRAY')
        {
            return +ARRAY;
        }
        when(reftype($_) eq 'HASH')
        {
            return +STRUCT;
        }
        default
        {
            return +STRING;
        }
    }
}
1;
