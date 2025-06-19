package VersionCheck;

use strict;
use warnings;
use MetaCPAN::Client;
use File::Spec;
use File::Path qw(make_path);
use File::HomeDir;
use Storable qw(retrieve store);
use Exporter 'import';

our @EXPORT_OK = qw(check_module_versions load_allowed_versions);

my $cache_dir  = File::Spec->catdir(File::HomeDir->my_home, '.cache', 'perlsec-scanner');
make_path($cache_dir) unless -d $cache_dir;

my $cache_file = File::Spec->catfile($cache_dir, 'meta_cache.stor');
my %metacpan_cache = -e $cache_file ? %{ retrieve($cache_file) } : ();

# Load allowed modules and their min versions from a file
sub load_allowed_versions {
    my $file = shift || 'allowed_modules.txt';
    open my $fh, '<', $file or die "Can't open allowlist $file: $!";
    my %allow;
    while (<$fh>) {
        next if /^\s*#/;
        my ($mod, $ver) = split /\s+/, $_;
        $allow{$mod} = $ver if $mod && $ver;
    }
    close $fh;
    return %allow;
}

# Check lines like: use Some::Module VERSION;
sub check_module_versions {
    my ($line, $file, $lineno, $ref, $allowref, $ttl, $refresh) = @_;

    if ($line =~ /^\s*use\s+([\w:]+)(?:\s+([\d\._]+))?/) {
        my ($module, $version) = ($1, $2);
        return unless $module;

        my $allowed_ver = $allowref->{$module};
        if (defined $allowed_ver) {
            if ($version && $version < $allowed_ver) {
                push @$ref, [$file, $lineno, "Outdated module: $module $version < allowed $allowed_ver", 'VersionTooLow', 'Medium'];
            }
        } else {
            # unknown module—ask MetaCPAN
            my $latest = get_latest_version($module, $ttl, $refresh);
            if ($latest) {
                push @$ref, [$file, $lineno, "Module $module not in allowlist, latest is $latest", 'UnknownModule', 'Medium'];
            } else {
                push @$ref, [$file, $lineno, "Module $module not in allowlist and not found in MetaCPAN", 'UnknownModule', 'Low'];
            }
        }
    }
}

# Cache-aware MetaCPAN lookup
sub get_latest_version {
    my ($module, $ttl, $refresh) = @_;
    my $now = time;

    if (!$refresh) {
        my $cached = $metacpan_cache{$module};
        if ($cached && ($now - ($cached->{timestamp} || 0)) < $ttl) {
            return $cached->{version};
        }
    }

    # Else fetch fresh
    my $client = MetaCPAN::Client->new;
    my $ver;

    eval {
        my $release = $client->release({ name => $module });
        $ver = $release->version;
        $metacpan_cache{$module} = {
            version   => $ver,
            timestamp => $now,
        };
    };

    return $ver || ($metacpan_cache{$module} ? $metacpan_cache{$module}{version} : undef);
}

sub list_cache_status {
    return unless %metacpan_cache;

    print "📦 MetaCPAN Cache Status:\n";
    for my $mod (sort keys %metacpan_cache) {
        my $entry = $metacpan_cache{$mod};
        my $age   = time - ($entry->{timestamp} || 0);
        my $ago   = format_duration($age);
        printf "  %-25s version %-7s cached %s ago\n", $mod, $entry->{version}, $ago;
    }
}

sub format_duration {
    my $sec = shift;
    return sprintf "%.1fd", $sec / 86400 if $sec >= 86400;
    return sprintf "%.1fh", $sec / 3600  if $sec >= 3600;
    return sprintf "%.1fm", $sec / 60    if $sec >= 60;
    return "${sec}s";
}

END {
	store \%metacpan_cache, $cache_file if %metacpan_cache;
}

1;
