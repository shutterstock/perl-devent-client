use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Devent::Client',
    AUTHOR              => q{Douglas Hunter <douglas@shutterstock.com>},
    VERSION_FROM        => 'lib/Devent/Client.pm',
    ABSTRACT_FROM       => 'lib/Devent/Client.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'ZeroMQ::Raw' => 0,
        'JSON::XS' => 0,
        'Time::HiRes' => 0,
        'LWP::UserAgent' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Devent-Client-*' },
);
