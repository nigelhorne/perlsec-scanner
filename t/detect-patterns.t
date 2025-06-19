use Test::More;
use PatternCheck qw(check_static_patterns);

my @findings;
check_static_patterns('eval $user_input;', 'test.pl', 1, \@findings);

is(scalar @findings, 1, 'Detected one insecure pattern');
like($findings[0][2], qr/eval/, 'Pattern includes "eval"');
done_testing();
