package POE::Filter::XML::RPC::ValueFactory;
use Filter::Template;
const XVal POE::Filter::XML::RPC::Value

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
	my $data;

	my $children = [$tag->getChildrenByTagName('*')];

	my $child = $children->[0];

	if(defined($child))
	{
		$type = $child->nodeName();

		if($type eq 'array')
		{
			my $datatag = $child->getSingleChildByTagName('data');
			my $values = $datatag->getChildrenByTagName('*');
			
			foreach my $value (@$values)
			{	
				value_process($value);
			}
		
		} elsif($type eq 'struct') {
			
			my $members = $child->get_sort_children();
			
			foreach my $member (@$members)
			{	
				value_process($member->get_tag('value'));
				bless($member, 'XVal::StructMember');
			}
		}
	}
	
	return base_process($type, $tag);
}

sub base_process
{
	my ($type, $data) = @_;

	if($type eq 'i4' or $type eq 'int')
	{
		return bless($data,'XVal::Int');
	
	} elsif ($type eq 'string') {

		return bless($data,'XVal::String');

	} elsif($type eq 'boolean') {
		
		return bless($data,'XVal::Bool');

	} elsif($type eq 'double') {

		return bless($data,'XVal::Double');

	} elsif($type eq 'dateTime.iso8601') {

		return bless($data,'XVal::DateTime');
	
	} elsif($type eq 'base64') {

		return bless($data,'XVal::Base64');
	
	} elsif($type eq 'array') {
		
		return bless($data,'XVal::Array');

	} elsif($type eq 'struct') {

		return bless($data,'XVal::Struct');
	
	} elsif(not defined($type) and defined($data)) {

		return bless($data,'XVal::String');
	
	} else {

		return bless($data,'XVal::String');
	}
}

1;
