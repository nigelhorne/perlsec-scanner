use strict;
use warnings;
use Test::More;
use File::Temp qw(tempdir);
use JSON;

# Create a temporary directory with a test file
my $tmpdir = tempdir(CLEANUP => 1);
my $test_file = "$tmpdir/vuln.pl";

open my $fh, '>', $test_file or die $!;
print $fh <<'EOF';
eval $user_input;
EOF
close $fh;

# Run the scanner
my $json_file = "$tmpdir/output.json";
my $cmd = "perl bin/perlsec-scan --input $tmpdir --output $json_file --format json";
my $exit = system($cmd);

ok($exit == 0, 'CLI executed successfully');
ok(-e $json_file, 'Output file created');

open my $rfh, '<', $json_file or die "Can't read output: $!";
my $json = do { local $/; <$rfh> };
close $rfh;

# diag("Raw JSON:\n$json");

my $results;
eval { $results = decode_json($json) };
ok(!$@, 'JSON decoded without error');

ok(ref $results eq 'ARRAY', 'JSON is an array');

ok(@$results >= 1, 'Detected at least one issue');

if (ref $results eq 'ARRAY' && @$results) {
    like($results->[0]{message}, qr/eval/, 'Detected eval statement');
} else {
    fail('No findings returned to validate eval pattern');
}

done_testing();
