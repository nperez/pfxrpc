use warnings;
use strict;

use Test::More tests => 17;

BEGIN
{
    use_ok('POE::Filter::XML');
    use_ok('POE::Filter::XML::RPC');
    use_ok('POE::Filter::XML::RPC::Value');
}

my $filter = POE::Filter::XML::RPC->new();

my $request = POE::Filter::XML::RPC::Request->new
(
    'MYMETHODNAME',
    [
        POE::Filter::XML::RPC::Value->new(42),
        POE::Filter::XML::RPC::Value->new(1),
        POE::Filter::XML::RPC::Value->new('ABCDEF0123456789=='),
        POE::Filter::XML::RPC::Value->new(22.22),
        POE::Filter::XML::RPC::Value->new('19980717T14:08:55'),
        POE::Filter::XML::RPC::Value->new('mtfnpy'),
        POE::Filter::XML::RPC::Value->new({'key1' => 'value1', 'key2' => 'value2'}),
        POE::Filter::XML::RPC::Value->new([43, 0, 'strval'])
    ]
);

my $response_okay = POE::Filter::XML::RPC::Response->new
(
    POE::Filter::XML::RPC::Value->new('Okay!')
);

my $response_fault = POE::Filter::XML::RPC::Response->new
(
    POE::Filter::XML::RPC::Fault->new
    (
        '100',
        'MY FAULT'
    )
);

$filter->get_one_start(bless($request, 'POE::Filter::XML::Node'));
my $filtered_request = $filter->get_one()->[0];

is($filtered_request->toString(), $request->toString(), 'Round trip of request');

is($filtered_request->get_parameter(0)->value(), $request->get_parameter(0)->value(), 'Parameter 0/7');
is($filtered_request->get_parameter(1)->value(), $request->get_parameter(1)->value(), 'Parameter 1/7');
is($filtered_request->get_parameter(2)->value(), $request->get_parameter(2)->value(), 'Parameter 2/7');
is($filtered_request->get_parameter(3)->value(), $request->get_parameter(3)->value(), 'Parameter 3/7');
is($filtered_request->get_parameter(4)->value(), $request->get_parameter(4)->value(), 'Parameter 4/7');
is($filtered_request->get_parameter(5)->value(), $request->get_parameter(5)->value(), 'Parameter 5/7');

is_deeply($filtered_request->get_parameter(6)->value(), $request->get_parameter(6)->value(), 'Parameter 6/7');
is_deeply($filtered_request->get_parameter(7)->value(), $request->get_parameter(7)->value(), 'Parameter 7/7');

$filter->get_one_start(bless($response_okay, 'POE::Filter::XML::Node'));
my $fil_response_okay = $filter->get_one()->[0];

is($fil_response_okay->toString(), $response_okay->toString(), 'Round trip of response');
is_deeply($fil_response_okay->return_value()->value(), $response_okay->return_value()->value(), 'Return value');

$filter->get_one_start(bless($response_fault, 'POE::Filter::XML::Node'));
my $fil_response_fault = $filter->get_one()->[0];

is($fil_response_fault->toString(), $response_fault->toString(), 'Round trip of response fault');
is($fil_response_fault->fault()->code(), $response_fault->fault()->code(), 'Fault code');
is($fil_response_fault->fault()->string(), $response_fault->fault()->string(), 'Fault code');
