package RegexCheck;
use Exporter 'import';
our @EXPORT_OK = qw(check_regex_patterns);

sub check_regex_patterns {
    my ($line, $file, $line_no, $ref) = @_;

    push @$ref, [$file, $line_no, "Nested quantifier (.*)+", 'RegexCheck', 'Medium'] if $line =~ /\(\.\*\)\+/;
    push @$ref, [$file, $line_no, "Ambiguous alternation repetition", 'RegexCheck', 'Medium'] if $line =~ /\((\w\|)+\w\)\+/;
    push @$ref, [$file, $line_no, "Greedy .* or .+ followed by literal", 'RegexCheck', 'Medium'] if $line =~ /\.\*[\+\?]?\s*[a-zA-Z0-9]/;
    push @$ref, [$file, $line_no, "Nested .+ quantifier", 'RegexCheck', 'Medium'] if $line =~ /\(\.\+\)(?:\*|\+)/;
}
1;
