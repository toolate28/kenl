---
project: Bazza-DX SAGE Framework
status: current
version: 2025-11-14
classification: OWI-DOC
atom: ATOM-DOC-20251114-002
owi-version: 1.0.0
last-updated: 2025-11-14
---

# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in KENL, **please do not open a public issue**. We take security seriously and appreciate responsible disclosure.

### Reporting Channels

**Preferred Method: GitHub Security Advisories**
1. Navigate to [Security Advisories](https://github.com/toolate28/kenl/security/advisories)
2. Click "Report a vulnerability"
3. Provide detailed information (see below)

**Alternative Method: Private Email**
- Email: **toolate28+kenl-security@gmail.com** (replace with your actual security contact email)
- Subject line: `[SECURITY] Brief description`
- Use GPG encryption if possible (key: [link to public key])

### What to Include

Please provide the following information:

1. **Type of vulnerability** (e.g., code injection, XSS, path traversal, privilege escalation)
2. **Affected components** (e.g., PowerShell module, bash script, ujust recipe)
3. **Steps to reproduce** (clear, numbered steps)
4. **Proof of concept** (code snippet, screenshot, or video)
5. **Impact assessment** (what can an attacker achieve?)
6. **Suggested fix** (if you have one)
7. **Your contact information** (for follow-up questions)

**Example:**

```
Type: Command injection in KENL.Network.psm1
Component: Test-KenlNetwork function (line 127)
Reproduction:
  1. Import KENL.Network module
  2. Run: Test-KenlNetwork -CustomHost '127.0.0.1; rm -rf /'
  3. Malicious command executes

Impact: Remote code execution with user privileges
Suggested fix: Use Test-Connection instead of ping.exe, or sanitize input with [ValidatePattern()]
```

### Response Timeline

- **Acknowledgment**: Within 48 hours (business days)
- **Initial assessment**: Within 7 days
- **Fix timeline**: Provided with initial assessment (varies by severity)
- **Disclosure**: Coordinated with reporter after patch is released

### Severity Classification

We use the following severity levels:

| Severity | Description | Response Time |
|----------|-------------|---------------|
| **Critical** | Remote code execution, privilege escalation on immutable system | 24-48 hours |
| **High** | Data exposure, authentication bypass, DoS on system services | 7 days |
| **Medium** | Local file read, information disclosure, client-side XSS | 14 days |
| **Low** | Configuration issues, minor information leaks | 30 days |

### Out of Scope

The following are **not** considered security vulnerabilities:

1. **Social engineering** (e.g., tricking users to run malicious commands)
2. **DOS via resource exhaustion** (e.g., infinite loops in user scripts)
3. **Issues in third-party dependencies** (report to upstream project instead)
4. **Theoretical vulnerabilities** without proof of concept
5. **Known limitations** documented in READMEs (e.g., "ujust recipes run with user privileges")

### Bounty Program

**Status**: No formal bug bounty program currently.

However, we deeply appreciate security research and will:
- Acknowledge your contribution in release notes (with your permission)
- List you in [ACKNOWLEDGMENTS.md](./ACKNOWLEDGMENTS.md)
- Provide a detailed thank-you and credit

### Automated Security Measures

KENL uses the following automated security tools:

1. **CodeQL** (GitHub Actions) - Scans JavaScript and Python code for vulnerabilities
2. **Dependabot** - Monitors npm/Python dependencies for known CVEs
3. **Pre-commit hooks** - `detect-secrets` prevents credential leaks
4. **Shellcheck** (severity: style) - Catches bash scripting bugs and unsafe patterns

See [`.github/workflows/ci.yml`](./.github/workflows/ci.yml) for CI/CD security automation.

### Security Best Practices

KENL follows these security principles:

**Immutable OS Protection**
- All scripts run in user-space (`~/.local`, `~/.config`)
- System changes require explicit `rpm-ostree` commands with confirmation prompts
- ATOM trails log all system modifications for audit

**Least Privilege**
- No scripts request `sudo` without explicit user approval
- Elevation prompts explain *why* root is needed
- Alternative non-root approaches documented where possible

**Input Validation**
- PowerShell functions use `[ValidateSet()]`, `[ValidateRange()]`, `[ValidatePattern()]`
- Bash scripts validate with regex before passing to system commands
- No `eval` or `Invoke-Expression` without sanitization

**Secret Management**
- No hardcoded credentials in any file
- `.env` files gitignored by default
- Pre-commit hooks prevent secret commits

**Dependency Integrity**
- All third-party scripts include source attribution
- Manual review required before integrating external code
- Lock files (`package-lock.json`) ensure reproducible builds

### Known Limitations

**By Design** (not security vulnerabilities):

1. **Distrobox containers share home directory** - Containers can read `~/.ssh`, `~/.gnupg` by default. This is intentional for development workflow. Isolate sensitive data in dedicated containers if needed.

2. **ujust recipes run with user privileges** - Recipes can modify user files. Review recipes before running: `cat /usr/share/ublue-os/just/*.just`

3. **Play Cards may contain malicious launch parameters** - Always review Play Card YAML before applying: `cat playcard.yaml`

4. **ATOM trails log commands** - Logs may contain sensitive data (file paths, usernames). Keep `~/.kenl/logs/` permissions restricted (`chmod 700`)

### Historical Security Issues

**None reported as of 2025-11-14.**

When vulnerabilities are discovered and patched, they will be listed here with:
- CVE ID (if assigned)
- Affected versions
- Fixed version
- Credit to reporter

---

## Security-Related Documentation

- **ATOM Audit Trails**: [modules/KENL1-framework/](./modules/KENL1-framework/)
- **Governance Framework**: [governance/](./governance/) - ARCREF/ADR templates include security review requirements
- **Rollback Instructions**: Every ARCREF document includes rollback plan for safe system recovery

---

## Contact

- **Security Email**: toolate28+kenl-security@gmail.com
- **GitHub Advisories**: https://github.com/toolate28/kenl/security/advisories
- **General Issues**: https://github.com/toolate28/kenl/issues (non-security bugs only)

**Thank you** for helping keep KENL and the community safe!

**ATOM**: ATOM-DOC-20251114-002
