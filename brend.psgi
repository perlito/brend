use strict;
use warnings;

use brend;

my $app = brend->apply_default_middlewares(brend->psgi_app);
$app;

