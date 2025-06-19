package RegexCheck;
use Exporter 'import';
our @EXPORT_OK = qw(check_regex_danger);

sub check_regex_danger {
    my ($line, $file, $line_no, $ref) = @_;

    push @$ref, [$file, $line_no, "Nested quantifier (.*)+"] if $line =~ /\(\.\*\)\+/;
    push @$ref, [$file, $line_no, "Ambiguous alternation repetition"] if $line =~ /\((\w\|)+\w\)\+/;
    push @$ref, [$file, $line_no, "Greedy .* or .+ followed by literal"] if $line =~ /\.\*[\+\?]?\s*[a-zA-Z0-9]/;
    push @$ref, [$file, $line_no, "Nested .+ quantifier"] if $line =~ /\(\.\+\)(?:\*|\+)/;
}
1;
