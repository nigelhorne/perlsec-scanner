package PatternCheck;
use Exporter 'import';
our @EXPORT_OK = qw(check_static_patterns);

sub check_static_patterns {
    my ($line, $file, $line_no, $ref) = @_;

    if ($line =~ /
        (eval\s+\$\w+|           # risky eval
         system\(|              # shell execution
         `[^`]*`|               # backticks
         open\s+[^,]+,\s*['"]>| # file open for writing
         \$ENV{|                # environment vars
         \b(param|input)\b      # unsanitized user input
    )/x) {
        push @$ref, [$file, $line_no, "Insecure pattern: $line"];
    }
}
1;
