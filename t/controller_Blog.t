use strict;
use warnings;
use Test::More;


use Catalyst::Test 'brend';
use brend::Controller::Blog;

ok( request('/blog')->is_success, 'Request should succeed' );
done_testing();
