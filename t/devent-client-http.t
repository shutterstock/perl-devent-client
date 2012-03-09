#!perl

use warnings;
use strict;

use Test::More tests => 1;

use Devent::Client;

my $d = Devent::Client->new(
        	transport => "http",
					receivers => ["http://127.0.0.1:6552"],
					timeout => 1/5,
				);

SKIP: {
	skip "until we spin up a mocked listener", 1;
	ok( $d->write("painters.best", {bob => "ross", from => "http"}) );
}
