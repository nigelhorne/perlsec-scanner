# PerlSec Scanner

A static security scanner for Perl code that detects common vulnerabilities, risky patterns, and outdated dependencies—complete with MetaCPAN live version checks.

## Features

- Detects insecure patterns (e.g., `eval`, `system`, untrusted input)
- Flags dangerous regexes that may cause ReDoS
- Warns about outdated or unknown modules using both local allowlist and live CPAN versions
- Outputs JSON, Sarif or text reports
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
  --input, -i   Directory to scan (default: .)
  --output, -o  Output file (default: findings.json)
  --format, -f  Output format: json, sarif or txt (default: json)
  --verbose, -v	Verbose output
  --help, -h    Show usage
```
