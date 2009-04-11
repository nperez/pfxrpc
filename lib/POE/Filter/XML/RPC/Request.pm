package POE::Filter::XML::RPC::Request;

use 5.010;
use warnings;
use strict;

use POE::Filter::XML::Node;

use base('POE::Filter::XML::Node');

sub new()
{
	my ($class, $methodname, $params) = @_;
	
    my $self = POE::Filter::XML::Node->new('methodCall');
	$self->appendChild('methodName');
	$self->appendChild('params');

	bless($self, $class);

	$self->method_name($methodname);

	if(defined($params) and ref($params) eq 'ARRAY')
	{
		foreach my $param (@$params)
		{
			$self->add_parameter($param);
		}
	}

	return $self;
}

sub method_name()
{
	my ($self, $arg) = @_;

	if(defined($arg))
	{
		($self->findnodes('child::methodName'))[0]->appendText($arg);
		return $arg;
	
	} else {

		return $self->findvalue('child::methodName/child::text()');
	}
}

sub parameters()
{
	return [ map { bless($_, 'POE::Filter::XML::RPC::Value') } shift(@_)->findnodes('child::params/child::param/child::value') ];
}

sub add_parameter()
{
	my ($self, $val) = @_;

	$self->add($self->wrap($val));
    
    return bless($val, 'POE::Filter::XML::RPC::Value');
}

sub insert_parameter()
{
	my ($self, $val, $index) = @_;
	
	$self->insert($self->wrap($val), $index);

    return bless($val, 'POE::Filter::XML::RPC::Value');
}

sub delete_parameter()
{
	my ($self, $index) = @_;

	my $val = ($self->delete($index)->findnodes('child::value'))[0];

    return bless($val, 'POE::Filter::XML::RPC::Value');
}

sub get_parameter()
{
	my ($self, $index) = @_;
    
	my $val = ($self->get($index)->findnodes('child::value'))[0];
    
    return bless($val, 'POE::Filter::XML::RPC::Value');
}

sub add()
{
    my ($self, $val) = @_;
    return ($self->findnodes('child::params'))[0]->appendChild($val);
}

sub delete()
{
    my ($self, $index) = @_;
    return ($self->findnodes('child::params'))[0]->removeChild($self->get($index));
}

sub insert()
{
    my ($self, $val, $index) = @_;
    return ($self->findnodes('child::params'))[0]->insertBefore($val, $self->get($index));
}

sub get()
{
    my ($self, $index) = @_;
    return ($self->findnodes("child::params/child::param[position()=$index]"))[0];
}

sub wrap()
{
	my ($self, $val) = @_;

	my $param = POE::Filter::XML::Node->new('param');
	
	$param->appendChild($val);

	return $param;
}
1;
