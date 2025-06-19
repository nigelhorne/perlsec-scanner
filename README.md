# PerlSec Scanner

A static security scanner for Perl code that detects common vulnerabilities, risky patterns, and outdated dependencies—complete with MetaCPAN live version checks.

## Features

- Detects insecure patterns (e.g., `eval`, `system`, untrusted input)
- Flags dangerous regexes that may cause ReDoS
- Warns about outdated or unknown modules using both local allowlist and live CPAN versions
- Outputs HTML, JSON, Sarif or text reports
- CLI-friendly and CI-ready
- Extensible, modular codebase

## Installation

```bash
perl Makefile.PL
make
make install
```

## Usage

```bash
bin/perlsec-scan [OPTIONS]

Options:
  --input, -i <dir>         Input directory to scan (default: .)
  --output, -o <file>       Output file for report (default: findings.json)
  --format, -f <format>     Output format: json | txt | html | sarif (default: json)
  --allowlist, -a <file>    Allowlist of approved modules/versions (default: allowed_modules.txt)
  --cache-ttl <N[smhd]>     Cache time-to-live (e.g. 7d = 7 days, 6h = 6 hours, 30m = 30 minutes).
                            Default is 7d
  --refresh-cache           Force MetaCPAN lookups even if cache is valid
  --show-cache-status       Display current cache entries with age and versions
  --verbose, -v             Show detailed progress during scan
  --help, -h                Show usage message
```
