use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Data::GUID',
    AUTHOR              => 'Ricardo Signes <rjbs@cpan.org>',
    VERSION_FROM        => 'lib/Data/GUID.pm',
    ABSTRACT_FROM       => 'lib/Data/GUID.pm',
    LICENSE             => 'perl',
    PL_FILES            => {},
    PREREQ_PM => {
        'Data::UUID'    => 1.148,
        'Sub::Exporter' => 0.90,
        'Sub::Install'  => 0.03,
        'Test::More'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Data-GUID-* cover_db' },
);
