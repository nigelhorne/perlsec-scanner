use strict;
use warnings;
use Test::More;
use File::Temp qw(tempdir);
use File::Spec;
use JSON;

my $bin = 'bin/perlsec-scan';

# ⛔ Test 1: Nonexistent directory
{
    my $cmd = "$^X $bin --input /definitely/not/real --output nul.json --format json 2>&1";
    my $out = `$cmd`;
    like($out, qr/Invalid input path/i, 'Handles nonexistent input path');
}

# ⛔ Test 2: Unreadable file
{
    my $dir = tempdir(CLEANUP => 1);
    my $pl = File::Spec->catfile($dir, 'nope.pl');

    open my $fh, '>', $pl or die $!;
    print $fh "eval \$danger;\n";
    close $fh;

    chmod 0000, $pl;

    my $json = File::Spec->catfile($dir, 'out.json');
    my $cmd  = "$^X $bin -i $dir -o $json -f json 2>&1";
    my $out  = `$cmd`;

    like($out, qr/Can't open/i, 'Handles unreadable file gracefully');

    chmod 0644, $pl;  # Restore permissions just in case
}

done_testing();
