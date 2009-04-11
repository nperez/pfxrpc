package POE::Filter::XML::RPC::Value;

use 5.010;
use warnings;
use strict;

use base('POE::Filter::XML::Node', 'Exporter');
use Class::InsideOut(':std');
use Scalar::Util('looks_like_number', 'reftype');
use Regexp::Common('time');

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
    return $val;
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

            while(my ($key, $val) = each %$arg)
            {
                my $member = $struct->appendChild(+MEMBER);
                $member->appendChild(+NAME)->appendText($key);
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
        $self->removeChild($self->firstChild());
        my $type = determine_type($arg);
        $self->appendChild($type)->appendText($arg);
        $type{id($self)} = $type;
    }
    else
    {
        my $content = $self->findvalue('child::text()');
        if(defined($content) && length($content))
        {
            return $content;
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
    
    my $content = $node->findvalue('child::text()');
    return $content if defined($content) && length($content);

    my $val = $node->firstChild();
    given($val->nodeName())
    {
        when(+STRUCT)
        {
            my $struct = {};
            foreach($val->findnodes('child::member'))
            {
                $struct->{$_->findvalue('child::name/child::text()')} =
                    node_to_value(($_->findnodes('child::value'))[0]);
            }

            return $struct;
        }
        when(+ARRAY)
        {
            my $array = [];

            foreach($val->findnodes('child::data/child::value'))
            {
                push(@$array, node_to_value($_));
            }

            return $array;
        }
        default
        {
            return $val->findvalue('child::text()');
        }
    }
}

sub type()
{
    my $self = shift(@_);
   $DB::single = 1; 
    if(!exists($type{id($self)}) || !defined($type{id($self)}))
    {
        my $content = $self->findvalue('child::text()');
        
        if(defined($content) && length($content))
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
        when(/^(?:1|0){1}$|^true$|^false$/i)
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
        when((reftype($_) // '') eq 'ARRAY')
        {
            return +ARRAY;
        }
        when((reftype($_) // '') eq 'HASH')
        {
            return +STRUCT;
        }
        when($_ =~ $RE{'time'}{'iso'})
        {
            return +DATETIME;
        }
        default
        {
            return +STRING;
        }
    }
}
1;
