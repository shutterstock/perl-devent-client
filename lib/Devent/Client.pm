package Devent::Client;

use warnings;
use strict;

use Sys::Hostname qw( hostname );
use Time::HiRes qw( time );
use JSON::XS qw( encode_json );
use Scalar::Util qw( looks_like_number weaken );

our $VERSION = '0.07';

sub new {
	my ($class, %opts) = @_;

	my $transport = uc delete $opts{"transport"}
		or  die "transport is required";
	$transport =~ /^(?:HTTP|UDP|ZMQ)$/
		or  die "transport must be HTTP, UDP or ZMQ";

	my $receivers = delete $opts{"receivers"}
		or  die "transport is required";
	ref $receivers eq "ARRAY"
		or  die "receivers => [ proto://host:port, ... ]";

	_validate_receivers($transport, $receivers);

	my $self = {
		_quiet => delete $opts{quiet},
	};
	my $writer = "Devent::Client::$transport";

	local $@;
	eval "require $writer";
	die "$writer unavailable: $@"
		if  $@;

	my %writer_opts;
	$writer_opts{"receivers"} = $receivers;
	$transport eq "HTTP"  and  $opts{"timeout"}
		and  looks_like_number($opts{"timeout"})
			and  $writer_opts{"timeout"} = delete $opts{"timeout"};
	$transport eq "ZMQ"  and  $opts{"hwm"}
		and  looks_like_number($opts{"hwm"})
			and  $writer_opts{"hwm"} = delete $opts{"hwm"};

	bless $self, $class;
	eval {
		$self->{_writer} = $writer->new(%writer_opts);
	};
	die "can't make new $writer: $@"
		if  $@;

	return $self;
}

sub write {
	my ($self, $topic, $message) = @_;

	if (!$topic) {
		warn "write with no topic"  unless  $self->{_quiet};
		return;
	}
	if (!$message) {
		warn "write with no message"  unless  $self->{_quiet};
		return;
	}
	if (ref $message ne "HASH") {
		warn "message must be a hash ref"  unless  $self->{_quiet};
		return;
	}

	$message->{_ts} ||= time();
	$message->{_host} ||= hostname();
	$message->{_pid} ||= $$;

	my $json;
	local $@;
	eval { $json = encode_json($message) };

	if ($@) {
		warn "can't encode message"  unless  $self->{_quiet};
		return;
	}

	return $self->{_writer}->write($topic, $json);
}

sub _validate_receivers {
	my ($transport, $receivers) = @_;

 	my $nr = 0;
	my ($host, $port);
	for my $receiver (@{ $receivers }) {
		if ($transport =~ /^(?:HTTP|ZMQ)$/) {
			my ($scheme, $authority) = $receiver =~ /^(.*?):\/\/(.*)$/;
			die "invalid $transport reciever: $receiver"
				if  $transport eq "HTTP"  and  $transport ne uc $scheme;
			die "invalid $transport receiver: $receiver"
				if  $transport eq "ZMQ"  and  "TCP" ne uc $scheme;
			die "invalid $transport receiver: $receiver"
				unless  $authority && $authority =~ /^(?:[^:]*?):(?:\d+)$/;
			($host, $port) = split(':', $authority);
			$transport eq "HTTP"  and  !$port  and  $port = 80;
		} else {
			die "UDP can't round robin"
				if  $nr > 0;
			die "invalid UDP reciever: $receiver"
				unless  $receiver =~ /^(?:[^:]*?):(?:\d+)$/;
			($host, $port) = split(':', $receiver);
		}
		die "invalid $transport receiver: $receiver"
			unless  $host && $port && $port =~ /^\d+$/;
		gethostbyname($host)  or  die "can't get host: $host";
		$nr++;
	}
}

1;

=head1 NAME

Devent::Client - D(?:istributed|eveloper|ebug) events

=head1 VERSION

Version 0.07

=cut

=head1 SYNOPSIS

Devent::Client is the client library for putting events on the wire
from a distributed application.  It takes pains to never block,
instead preferring to drop messages in the case that it would block.

    use Devent;

    # via udp
    my $d = Devent::Client->new(
      transport => "udp",
      recievers => ["forwarder1:7665"]
    );

    # or http
    my $d = Devent::Client->new(
      transport => "http",
      recievers => ["http://forwarder1:7664", "http://forwarder2:7664"]
    );

    # or zeromq
    my $d = Devent::Client->new(
      transport => "zmq",
      recievers => ["tcp://forwarder1:7666", "tcp://forwarder2:7666"]
    );

    $d->write("painters.best", {
        name => "Bob Ross",
        period => "Sensitive Side of the Disco Era",
    });


=head1 SUBROUTINES/METHODS

=head2 new( transport => "(udp|http|zmq)", receivers => [...]);

Makes a new Devent::Client object and connects it to the upstream
listeners.  UDP can take only one receiver.  HTTP or ZMQ will load
balance between available hosts.

=head2 write( "topic", {message => ...} );

Puts a message on the wire under a topic.  The first argument is a
topic, which must be a string.  The second argument is a hash
reference, which is converted to JSON before transport.

A true return value means the message was delivered.  This of course
will always be true via UDP.  If you need a confirmation that your
message made it upstream, you may want to consider using HTTP (and the
additional cost that comes with it).

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
