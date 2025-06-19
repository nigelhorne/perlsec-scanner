package VersionCheck;
use Exporter 'import';
our @EXPORT_OK = qw(check_module_versions load_allowed_versions);

sub load_allowed_versions {
    my $file = shift;
    open my $fh, '<', $file or die "Can't open allowlist $file: $!";
    my %versions;
    while (<$fh>) {
        my ($mod, $ver) = split;
        $versions{$mod} = $ver;
    }
    close $fh;
    return %versions;
}

sub check_module_versions {
    my ($line, $file, $line_no, $ref, $allowed_ref) = @_;
    if ($line =~ /^\s*use\s+([\w:]+)\s*(\d+(\.\d+)*)?/) {
        my ($module, $ver) = ($1, $2 || '0');
        if (!exists $allowed_ref->{$module}) {
            push @$ref, [$file, $line_no, "Unknown module '$module'"];
        } elsif ($ver < $allowed_ref->{$module}) {
            push @$ref, [$file, $line_no, "Outdated '$module' version $ver (expected $allowed_ref->{$module})"];
        }
    }
}
1;
