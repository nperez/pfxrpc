use warnings;
use strict;

use Test::More tests => 9;

BEGIN
{
    use_ok('POE::Filter::XML::RPC');
    use_ok('POE::Filter::XML');
}

my $filter = POE::Filter::XML::RPC->new();

my $request = POE::Filter::XML::RPC::Request->new
(
    'MYMETHODNAME',
    [
        POE::Filter::XML::RPC::Value::Int->new(42),
        POE::Filter::XML::RPC::Value::Bool->new(1),
        POE::Filter::XML::RPC::Value::Base64->new('ABCDEF0123456789=='),
        POE::Filter::XML::RPC::Value::Double->new(22.22),
        POE::Filter::XML::RPC::Value::DateTime->new('19980717T14:08:55'),
        POE::Filter::XML::RPC::Value::String->new('mtfnpy'),
        POE::Filter::XML::RPC::Value::Struct->new({'key1' => 'value1', 'key2' => 'value2'}),
        POE::Filter::XML::RPC::Value::Array->new
        (
            [
                POE::Filter::XML::RPC::Value::Int->new(42),
                POE::Filter::XML::RPC::Value::Bool->new(1),
                POE::Filter::XML::RPC::Value::Double->new(22.22),
            ]
        )
    ]
);

my $response_okay = POE::Filter::XML::RPC::Response->new
(
    POE::Filter::XML::RPC::Value::String->new('Okay!')
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

is($filtered_request->get_parameter(0)->value(), $request->get_parameter(0)->value(), 'Parameter 0/6');
is($filtered_request->get_parameter(1)->value(), $request->get_parameter(1)->value(), 'Parameter 1/6');
is($filtered_request->get_parameter(2)->value(), $request->get_parameter(2)->value(), 'Parameter 2/6');
is($filtered_request->get_parameter(3)->value(), $request->get_parameter(3)->value(), 'Parameter 3/6');
is($filtered_request->get_parameter(4)->value(), $request->get_parameter(4)->value(), 'Parameter 4/6');
is($filtered_request->get_parameter(5)->value(), $request->get_parameter(5)->value(), 'Parameter 5/6');
is($filtered_request->get_parameter(5)->value(), $request->get_parameter(6)->value(), 'Parameter 6/6');
