#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Devent::Client' ) || print "Bail out!\n";
}

diag( "Testing Devent $Devent::Client::VERSION, Perl $], $^X" );
