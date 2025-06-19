use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'PerlSec::Scanner',
    VERSION      => '0.01',
    LICENSE      => 'perl',
    EXE_FILES    => ['bin/perlsec-scan'],
    PREREQ_PM    => {
        'File::Find'         => 0,
        'Getopt::Long'       => 0,
        'JSON'               => 0,
        'MetaCPAN::Client'   => 0,
        'Exporter'           => 0,
        'Cwd'                => 0,
    },
    ABSTRACT     => 'Static security scanner for Perl code',
    AUTHOR       => 'Nigel Horne <njh@nigelhorne.com>
);
