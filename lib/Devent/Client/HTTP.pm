package Devent::Client::HTTP;

use warnings;
use strict;

use LWP::UserAgent;
use Time::HiRes qw( ualarm );

use POSIX qw( :signal_h );

our $VERSION = '0.04';

my $TIMEOUT = 1/5;

sub new {
	my ($class, %opts) = @_;

	my $ua = LWP::UserAgent->new( agent => "Devent $VERSION" );
	$ua->timeout( $opts{"timeout"} || $TIMEOUT );
	my $req = HTTP::Request->new("POST");
	$req->header("Content-Type" => "application/json");
	my $self = {
		_ua => $ua,
		_req => $req,
		_receivers => $opts{"receivers"},
	};

	bless $self, $class;
	return $self;
}

sub write {
	my ($self, $topic, $json) = @_;

	my $ret;
	eval {
		$self->{_req}->content($json);
		my @receivers = @{ $self->{_receivers} };
		while ( my $uri = splice(@receivers, rand @receivers, 1) ) {
			$uri =~ s|/$||;
			$uri = join("/", $uri, $topic);
			$self->{_req}->uri($uri);
			my $res = $self->{_ua}->request( $self->{_req} );
			if ($res->is_success) {
				$ret = 1;
				last;
			}
		}
	};

	return $ret;
}

1;

=head1 NAME

Devent::Client - D(?:istributed|eveloper|ebug) events

=head1 VERSION

Version 0.03

=cut

=head1 SYNOPSIS

Devent::Client is the client library for putting events on the wire from a
distributed application.  It takes pains to never block, instead
preferring to drop messages in the case that it would block.

    use Devent;

    my $d = Devent::Client->new();

    $d->write( "www.error",
               {
                  timestamp => time(),
                  error => 500,
                  data => $stacktrace
               }
             );


=head1 SUBROUTINES/METHODS

=head2 new();

Makes a new Devent::Client object and connects it to the downstream listeners.
Acts as a singleton, only returning one object per process.

Takes optional parameters hwm => $num_messages to control the number
of undeliverable messages to buffer in memory, and swap => $num_bytes
to control the number of bytes to buffer to disk in the case that we
overflow our hwm.

Defaults: hwm => 1000 messages, swap => off

WARNING: be careful using swap.  That code in the underlying ZeroMQ
library aserts when it runs into errors, aborting the current process.

=head2 write( "topic", {message => ...} );

Puts a message on the wire under a topic that bridges can subscribe
to.  Returns true on success, false on failure.

Success means that the message made it into a buffer somewhere, not
that it was successfully transmitted.

=cut

=head1 AUTHOR

Douglas Hunter, C<< <douglas at shutterstock.com> >>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Devent::Client


=head1 LICENSE AND COPYRIGHT

Copyright 2011, 2012 Shutterstock Images, LLC.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=cut
