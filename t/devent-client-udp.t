#!perl

use warnings;
use strict;

use Test::More tests => 1;

use Devent::Client;

my $d = Devent::Client->new(
        	transport => "udp",
					receivers => ["127.0.0.1:6553"],
				);

ok( $d->write("painters.best", {bob => "ross", from => "udp"}) );

