use strict;
use warnings;

use 5.006;

use ExtUtils::MakeMaker 6.63;

my %WriteMakefileArgs = (
    NAME                      => 'Log::File',
    AUTHOR                    => q{Trevor Cornpropst <tscornpropst@gmail.com>},
    VERSION_FROM              => 'lib/Log/File.pm',
    ABSTRACT_FROM             => 'lib/Log/File.pm',
    LICENSE                   => 'artistic2',
    DISTNAME                  => 'Log-File',
    MIN_PERL_VERSION          => 5.006,
    BUILD_REQUIRES            => {
        'ExtUtils::MakeMaker' => 6.63,
    },
    CONFIGURE_REQUIRES        => {
        'ExtUtils::MakeMaker' => 6.63,
    },
    PREREQ_PM                 => {
        'Carp'                => 0,
        'Class::InsideOut'    => 0,
        'Fcntl'               => 0,
        'IO::File'            => 0,
        'Readonly'            => 0
    },
    TEST_REQUIRES             => {
        'Test::More'          => 0,
        'Test::Pod'           => 0,
        'Test::Pod::Coverage' => 0
    },
    test                      => { TESTS    => 't/*.t', },
    dist                      => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);

my %FallbackPrereqs = (
    'Carp'             => 0,
    'Class::InsideOut' => 0,
    'Fcntl'            => 0,
    'IO::File'         => 0,
    'Readonly'         => 0,
);

unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
    delete $WriteMakefileArgs{TEST_REQUIRES};
    delete $WriteMakefileArgs{BUILD_REQUIRES};
    $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
    unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);
