use strict;
use warnings;
use Test::More;


use Catalyst::Test 'brend';
use brend::Controller::Shop;

ok( request('/shop')->is_success, 'Request should succeed' );
done_testing();
