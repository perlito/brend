use strict;
use warnings;
use Test::More;


use Catalyst::Test 'brend';
use brend::Controller::Feed;

ok( request('/feed')->is_success, 'Request should succeed' );
done_testing();
