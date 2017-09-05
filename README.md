# Devent::Client

Devent::Client provides a 'write' method that uses either http, udp or
zeromq to write a devent message to a forwarder or a hub.

# Installation

You'll need to have zeromq and zeromq-devel installed to make use of
the zeromq transport, as well as Jonathan Rockway's ZeroMQ::Raw
bindings available here:
http://search.cpan.org/CPAN/authors/id/J/JR/JROCKWAY/ZeroMQ-Raw-0.01.tar.gz

Then it's a matter of the standard:

	perl Makefile.PL
	make
	make test
	make install

## Authors

This library was developed by Douglas Hunter at [Shutterstock](http://www.shutterstock.com)

## License

[MIT](LICENSE) © 2012-2017 Shutterstock Images, LLC
