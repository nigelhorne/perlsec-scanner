use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'PerlSec::Scanner',
    VERSION      => '0.01',
    LICENSE      => 'perl',
    EXE_FILES    => ['bin/perlsec-scan'],
PREREQ_PM => {
    'Getopt::Long'        => 2.50,
    'File::Find'          => 1.37,
    'File::Spec'          => 3.40,
    'File::Path'          => 2.09,
    'File::Basename'      => 2.85,
    'File::HomeDir'       => 1.006,
    'JSON::MaybeXS'       => 0,
    'MetaCPAN::Client'    => 2.029000,
    'Storable'            => 3.15,
    'Cwd'                 => 3.75,
    'Term::ANSIColor'     => 5.01,        # optional, if terminal color used
    'Exporter'            => 5.73,        # for Exporter 'import'
    'Test::More'          => 1.302183,    # if tests included
},
    
    ABSTRACT     => 'Static security scanner for Perl code',
    AUTHOR       => 'Nigel Horne <njh@nigelhorne.com>'
);
