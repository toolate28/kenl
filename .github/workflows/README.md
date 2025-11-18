---
title: GitHub Actions Workflows Documentation
date: 2025-11-18
atom: ATOM-DOC-20251118-014
classification: WORKFLOW-DOCS
status: active
---

# GitHub Actions Workflows Documentation

This directory contains CI/CD workflows for the KENL repository.

---

## 📋 Active Workflows

### ci.yml - Continuous Integration
**Trigger:** Push to main, Pull requests
**Purpose:** Validate code quality and run tests

**Jobs:**
1. **pre-commit** - Run all pre-commit hooks
   - Trailing whitespace removal
   - End-of-file fixers
   - YAML/JSON validation
   - Large file detection (max 500KB)
   - Secret detection (detect-secrets)
   - Shellcheck for bash scripts

2. **CodeQL** - Security scanning
   - Languages: JavaScript, Python
   - Analyzes code for vulnerabilities
   - Reports to Security tab

3. **tests** - Run test suite
   - Python: pytest (if tests exist)
   - Conditional execution based on test presence

**Required checks:** All jobs must pass for PR merge

---

### release.yml - Semantic Release
**Trigger:** Tag push (`v*.*.*`)
**Purpose:** Automated release creation

**Jobs:**
1. **Release** - Create GitHub release
   - Uses semantic-release
   - Generates changelog
   - Creates release notes
   - Publishes release artifacts

**Usage:**
```bash
git tag v1.0.0
git push origin v1.0.0
# CI runs automatically
```

---

### validate.yml - Additional Validation
**Trigger:** Push, Pull requests
**Purpose:** Extended validation checks

**Jobs:**
- Additional validation logic
- Custom checks beyond standard CI

---

### atom-example.yml.disabled - ATOM Workflow Example
**Status:** Disabled (example/template)
**Purpose:** Show ATOM integration pattern

**To enable:**
1. Rename to `atom-example.yml`
2. Configure ATOM endpoints
3. Update trigger conditions

---

## 🔍 Workflow Status

### Current Issues

**None identified** ✅

### Potential Improvements

1. **Link Validation** (Priority: HIGH)
   - Add markdown-link-check action
   - Validate internal and external links
   - Report broken links in PRs

2. **Document Registry Sync** (Priority: HIGH)
   - Auto-update `.kenl/document-registry.json`
   - Validate registry coverage
   - Fail if new docs lack registry entry

3. **SAIF Flag Validation** (Priority: MEDIUM)
   - Check SAIF flag format in documentation
   - Validate SAIF flag uniqueness
   - Ensure flags follow `SAIF-{ACTION}-{YYYYMMDD}-{NNN}` pattern

4. **ATOM Tag Validation** (Priority: MEDIUM)
   - Validate commit message ATOM tags
   - Check tag format: `ATOM-{TYPE}-{YYYYMMDD}-{NNN}`
   - Ensure tag uniqueness

5. **Module Testing** (Priority: LOW)
   - Add module-specific test suites
   - PowerShell module testing (Pester)
   - Bash script testing (bats)

---

## 🛠️ Adding a New Workflow

### Steps

1. **Create workflow file:** `.github/workflows/<name>.yml`
2. **Define triggers:**
   ```yaml
   on:
     push:
       branches: [main]
     pull_request:
       branches: [main]
   ```
3. **Add jobs:**
   ```yaml
   jobs:
     job-name:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - name: Run task
           run: |
             # Your commands here
   ```
4. **Test workflow:**
   - Create PR with workflow changes
   - Verify execution in Actions tab
5. **Document workflow:**
   - Add section to this README
   - Include trigger, purpose, jobs
6. **Create ARCREF:**
   - Required for infrastructure changes
   - Location: `governance/mcp-governance/`
7. **Create ADR:**
   - Document decision rationale
   - Location: `governance/02-Decisions/`

---

## 📚 Workflow Patterns

### Pre-commit Hook Integration
```yaml
- name: Run pre-commit
  uses: pre-commit/action@v3.0.0
```

### CodeQL Security Scanning
```yaml
- name: Initialize CodeQL
  uses: github/codeql-action/init@v2
  with:
    languages: javascript, python
```

### Conditional Execution
```yaml
- name: Run tests
  if: hashFiles('pytest.ini') != '' || hashFiles('tests/**') != ''
  run: pytest -q
```

### Matrix Testing
```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest]
    python-version: [3.9, 3.10, 3.11]
```

---

## 🔗 Related Documentation

### Workflow Configuration
- [Pre-commit Config](../../.pre-commit-config.yaml) - Hook configuration
- [CodeQL Config](../../.github/codeql/) - Security scan rules (if exists)

### Governance
- [ARCREF Template](../../governance/mcp-governance/ARCREF_TEMPLATE.yaml)
- [ADR Template](../../governance/02-Decisions/ADR_TEMPLATE.md)

### Standards
- [Contributing Guide](../../CONTRIBUTING.md) - PR requirements
- [Naming Conventions](../../docs/standards/NAMING-CONVENTIONS.md) - Branch naming

---

## ⚙️ Workflow Permissions

### Default Permissions
```yaml
permissions:
  contents: read
  packages: read
  security-events: write
```

### Why These Permissions?
- **contents: read** - Access repository code
- **packages: read** - Access GitHub packages
- **security-events: write** - Upload CodeQL results

### Changing Permissions
⚠️ **Requires:** ARCREF + ADR documentation
⚠️ **Security review:** Required for expanded permissions

---

## 🐛 Troubleshooting

### Workflow Fails

**Step 1:** Check workflow logs
```bash
# View in GitHub UI
Repository → Actions → Select workflow run → View logs
```

**Step 2:** Reproduce locally
```bash
# For pre-commit
pre-commit run --all-files

# For tests
pytest -q

# For shellcheck
find . -name "*.sh" -exec shellcheck {} \;
```

**Step 3:** Fix and re-run
- Fix issues locally
- Commit and push
- Workflow re-runs automatically

### Common Issues

**Issue:** Pre-commit hooks fail
**Solution:** Run `pre-commit run --all-files` locally and fix issues

**Issue:** CodeQL fails
**Solution:** Check for syntax errors in JS/Python files

**Issue:** Tests fail
**Solution:** Run `pytest -v` locally to see detailed error messages

**Issue:** Secrets detected
**Solution:** Remove secrets, use environment variables or GitHub secrets

---

## 📊 Workflow Metrics

### Success Rate
- **Target:** >95% success rate
- **Current:** Unknown (TODO: add tracking)

### Execution Time
- **ci.yml:** ~3-5 minutes
- **release.yml:** ~2-3 minutes
- **validate.yml:** ~1-2 minutes

### Cost
- **Free tier:** 2,000 minutes/month
- **Current usage:** Unknown (check Actions tab)

---

## 🔄 Maintenance

### Regular Review
- **Frequency:** Monthly
- **Check:** Workflow success rates
- **Update:** Dependencies (actions versions)

### Dependency Updates
```yaml
# Update action versions regularly
- uses: actions/checkout@v4  # Check for v5
- uses: github/codeql-action/init@v2  # Check for v3
```

### Workflow Optimization
- Remove unused steps
- Cache dependencies
- Parallelize jobs where possible

---

## ✅ Checklist for New Workflows

- [ ] Created workflow file in `.github/workflows/`
- [ ] Defined clear trigger conditions
- [ ] Added appropriate permissions
- [ ] Documented in this README
- [ ] Created ARCREF (if infrastructure change)
- [ ] Created ADR (if architectural decision)
- [ ] Tested workflow execution
- [ ] Updated relevant documentation
- [ ] Added ATOM tag to commit

---

**Last Updated:** 2025-11-18
**ATOM Tag:** ATOM-DOC-20251118-014
**Next Review:** 2025-12-18

**ATOM-DOC-20251118-014**
