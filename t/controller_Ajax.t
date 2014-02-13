use strict;
use warnings;
use Test::More;


use Catalyst::Test 'brend';
use brend::Controller::Ajax;

ok( request('/ajax')->is_success, 'Request should succeed' );
done_testing();
