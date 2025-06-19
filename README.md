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
  --offline                 Skip MetaCPAN queries; rely only on allowlist and cache
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

## GitHub Action Integration

You can integrate the scanner into any repo by using the reusable GitHub Action, defined in `.github/actions/perlsec-scan/action.yml`.
This lets you scan code on every push or pull request without copying the scanner into each project.
Simply reference the action in your workflow with `uses: nigelhorne/perlsec-scanner/.github/actions/perlsec-scan@main` and pass optional arguments like `--format html` or `--offline`.
It will automatically clone the scanner, install dependencies, and execute your configured scan.
This modular setup ensures your security checks are portable, consistent, and frictionless across multiple Perl projects.

### Example

```yaml
- uses: nigelhorne/perlsec-scanner/.github/actions/perlsec-scan@main
  with:
    args: "--format html --output findings.html"
    - name: Upload findings HTML as artifact
  uses: actions/upload-artifact@v4
  with:
    name: findings-html
    path: findings.html
- name: Post Scan Summary Notification to PR
  if: github.event_name == 'pull_request'
  uses: actions/github-script@v6
  with:
    script: |
      const fs = require('fs');
      // Read the generated summary file
      const summary = fs.readFileSync('summary.md', 'utf8');
      const { owner, repo } = context.repo;
      const prNumber = context.payload.pull_request.number;

      // List existing comments to avoid duplicating notifications
      const { data: comments } = await github.rest.issues.listComments({
        owner, repo, issue_number: prNumber
      });

      // Update if an existing PerlSec comment is found, otherwise create a new one
      const existingComment = comments.find(c => c.body.includes('### ⚠️ PerlSec Findings'));
      if (existingComment) {
        await github.rest.issues.updateComment({
          owner,
          repo,
          comment_id: existingComment.id,
          body: summary
        });
      } else {
        await github.rest.issues.createComment({
          owner,
          repo,
          issue_number: prNumber,
          body: summary
        });
      }
```

Once the workflow completes, GitHub Actions makes the `findings-html` artifact available in the run summary.
Here’s how you can access it:

1. **View the Workflow Run:**
   Navigate to your repository’s **Actions** tab and click on the most recent workflow run that executed the scanner.

2. **Locate the Artifact:**
   Scroll down to the **Artifacts** section at the bottom of the run summary.
   You’ll see an artifact labeled “findings-html.”

3. **Download the Artifact:**
   Click on the “findings-html” artifact and choose to download it.
   This will give you the generated `findings.html` file, which you can open in a browser to review the scan results.

This manual download is the standard practice. If you need to further integrate access—such as linking to the report from a GitHub issue or automating notifications—you can add additional steps in your workflow to post those links.
