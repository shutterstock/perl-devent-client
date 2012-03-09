#!perl

use warnings;
use strict;

use Test::More tests => 2;

use Devent::Client;

my $d = Devent::Client->new(
        	transport => "zmq",
					receivers => ["tcp://127.0.0.1:6554"],
					hwm => 1,
				);

my $m = "x" x 900;

# we're buffered in memory
ok( $d->write("topic", {mess => $m, from => "zmq"}));

# we overflow our hwm
ok( !$d->write("topic", {mess => $m, from => "zmq"}) );

