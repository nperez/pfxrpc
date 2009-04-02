package POE::Filter::XML::RPC::ValueFactory;

use warnings;
use strict;

use POE::Filter::XML::RPC::Value;
use POE::Filter::XML::RPC::Value::Int;
use POE::Filter::XML::RPC::Value::Double;
use POE::Filter::XML::RPC::Value::Array;
use POE::Filter::XML::RPC::Value::Struct;
use POE::Filter::XML::RPC::Value::Base64;
use POE::Filter::XML::RPC::Value::Bool;
use POE::Filter::XML::RPC::Value::String;
use POE::Filter::XML::RPC::Value::DateTime;

use Exporter;

our @ISA = qw/ Exporter /;
our @EXPORT = qw/ value_process base_process/;

sub value_process
{
	my $tag = shift(@_);
	my $type = 'string';
	my $child = [$tag->getChildrenByTagName('*')]->[0];
	$type = $child->nodeName() if defined($child);
	
	return base_process($type, $tag);
}

sub base_process
{
	my ($type, $data) = @_;

	if($type eq 'i4' or $type eq 'int')
	{
		return bless($data,'POE::Filter::XML::RPC::Value::Int');
	
	} elsif ($type eq 'string') {

		return bless($data,'POE::Filter::XML::RPC::Value::String');

	} elsif($type eq 'boolean') {
		
		return bless($data,'POE::Filter::XML::RPC::Value::Bool');

	} elsif($type eq 'double') {

		return bless($data,'POE::Filter::XML::RPC::Value::Double');

	} elsif($type eq 'dateTime.iso8601') {

		return bless($data,'POE::Filter::XML::RPC::Value::DateTime');
	
	} elsif($type eq 'base64') {

		return bless($data,'POE::Filter::XML::RPC::Value::Base64');
	
	} elsif($type eq 'array') {
		
		return bless($data,'POE::Filter::XML::RPC::Value::Array');

	} elsif($type eq 'struct') {

		return bless($data,'POE::Filter::XML::RPC::Value::Struct');
	
	} elsif(not defined($type) and defined($data)) {

		return bless($data,'POE::Filter::XML::RPC::Value::String');
	
	} else {

		return bless($data,'POE::Filter::XML::RPC::Value::String');
	}
}

1;
