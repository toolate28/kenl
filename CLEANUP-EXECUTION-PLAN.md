---
title: KENL Repository Cleanup - Detailed Execution Plan
date: 2025-11-16
classification: OWI-DOC
status: planning
ctfwi: Each phase requires explicit approval before execution
---

# KENL Repository Cleanup - Detailed Execution Plan

**Based on:** [AUDIT-FINDINGS-2025-11-16.md](./AUDIT-FINDINGS-2025-11-16.md)

**CTFWI Principle:** Every phase has explicit checkpoints. No execution without validation.

---

## Pre-Execution Checklist

### **⚠️ SAFETY FIRST - DO BEFORE ANYTHING**

```bash
# 1. Create safety branch
git checkout -b pre-cleanup-backup-2025-11-16
git push -u origin pre-cleanup-backup-2025-11-16

# 2. Verify clean working tree
git status
# Expected: "nothing to commit, working tree clean"
# If not clean: STOP and commit/stash first

# 3. Document current state
git log --oneline -10 > /tmp/pre-cleanup-git-state.txt
find . -name "*.md" | wc -l > /tmp/pre-cleanup-file-count.txt
du -sh . > /tmp/pre-cleanup-repo-size.txt

# 4. Create restoration script
cat > /tmp/restore-if-needed.sh <<'EOF'
#!/bin/bash
# Emergency restoration script
git checkout main
git reset --hard origin/main
git clean -fdx
echo "Restored to pre-cleanup state"
EOF
chmod +x /tmp/restore-if-needed.sh

# 5. Tag current state
git tag pre-cleanup-$(date +%Y%m%d-%H%M%S)
git push --tags
```

**CTFWI Checkpoint:** Verify all 5 steps completed successfully before proceeding.

---

## Decision Tree: Critical Questions

### Q1: atom-sage-framework - Separate Repo?

**Decision:** [ ] Yes, creating separate repo  |  [ ] No, keeping in KENL

**If YES (separate repo):**
- ⏸️ **PAUSE Phase 1 cleanup** - don't delete root `atom-sage-framework/` yet
- Execute "Extraction Plan" (see below) first
- Then return to Phase 1

**If NO (keeping in KENL):**
- ✅ Proceed with Phase 1 as planned
- Delete root `atom-sage-framework/` duplicate

---

### Q2: MANIFEST Templates - Fill or Delete?

**Decision:** [ ] Fill in all templates  |  [ ] Delete templates  |  [ ] Hybrid approach

**If FILL IN:**
- ⏸️ **PAUSE Phase 1**
- Execute "MANIFEST Completion Workflow" (see below)
- Each module owner fills MANIFEST
- Then proceed to Phase 2

**If DELETE:**
- ✅ Add to Phase 1 cleanup
- Remove all placeholder MANIFEST files

**If HYBRID:**
- Define which modules get MANIFESTs (production-ready only?)
- Delete others

---

### Q3: Windows Support Scope

**Decision:** [ ] Keep all  |  [ ] Keep core only  |  [ ] Archive niche content

**If KEEP ALL:**
- ✅ No changes needed
- Add clarifying README

**If KEEP CORE:**
- Archive Surface Pro 4 specific content
- Keep dual-boot and general migration guides

**If ARCHIVE NICHE:**
- Move Windows-specific to separate branch/repo
- Link from main repo

---

### Q4: SAIF Automotive Examples

**Decision:** [ ] Keep in dotfiles/  |  [ ] Move to examples/  |  [ ] Archive

**If MOVE:**
- Add to Phase 2
- Create `examples/saif-use-cases/`
- Update all references

**If ARCHIVE:**
- Add to Phase 1
- Move to `.archive/2025-11-16/saif-automotive/`

---

## Phase 1: Critical Cleanup (Deduplicate)

**Estimated Time:** 30 minutes
**Risk Level:** LOW (git preserves history)
**Prerequisites:** All decisions above finalized

### 1.1: Remove Accidental File

**CTFWI: Confirm this file serves no purpose**

```bash
# Verify it's truly accidental
cat atom-sage-framework/y
# Expected: zsh completion config (accidental)

# Remove it
git rm atom-sage-framework/y
git commit -m "chore: remove accidental zsh config file

This file was accidentally committed from Windows/WSL environment.
It contains zsh completion settings and serves no project purpose.

ATOM-CLEANUP-20251116-001"

# Update .gitignore to prevent recurrence
cat >> .gitignore <<'EOF'

# Accidental shell config files
**/y
**/.zcompdump*
**/.zshrc.local
**/.zsh_history
EOF

git add .gitignore
git commit -m "chore: prevent accidental shell config commits

Added patterns to .gitignore to prevent similar issues.

ATOM-CLEANUP-20251116-002"
```

**Verification:**
```bash
# Should not exist
test ! -f atom-sage-framework/y && echo "✅ File removed" || echo "❌ File still exists"

# Should be in .gitignore
grep "^\\*\\*/y$" .gitignore && echo "✅ Added to .gitignore" || echo "❌ Not in .gitignore"
```

**Rollback if needed:**
```bash
git revert HEAD~1  # Revert .gitignore change
git revert HEAD~1  # Revert file removal
```

---

### 1.2: Consolidate CONTRIBUTING Docs

**CTFWI: Verify root CONTRIBUTING.md is most complete version**

```bash
# Compare all CONTRIBUTING files
diff CONTRIBUTING.md modules/KENL1-framework/CONTRIBUTING.md
diff CONTRIBUTING.md modules/KENL1-framework/atom-sage-framework/CONTRIBUTING.md

# If root is most complete, proceed. Otherwise, merge best content first.

# Create pointers in sub-modules
cat > modules/KENL1-framework/CONTRIBUTING.md <<'EOF'
# Contributing to KENL1 Framework

See the root [CONTRIBUTING.md](../../CONTRIBUTING.md) for contribution guidelines.

This module follows all project-wide conventions.
EOF

cat > modules/KENL1-framework/atom-sage-framework/CONTRIBUTING.md <<'EOF'
# Contributing to ATOM+SAGE Framework

See the root [CONTRIBUTING.md](../../../CONTRIBUTING.md) for contribution guidelines.

This framework follows all project-wide conventions.
EOF

git add modules/KENL1-framework/CONTRIBUTING.md
git add modules/KENL1-framework/atom-sage-framework/CONTRIBUTING.md
git commit -m "docs: consolidate CONTRIBUTING to single source of truth

Replaced duplicate CONTRIBUTING files with pointers to root document.
This ensures consistency and reduces maintenance burden.

Files changed:
- modules/KENL1-framework/CONTRIBUTING.md (now pointer)
- modules/KENL1-framework/atom-sage-framework/CONTRIBUTING.md (now pointer)

ATOM-CLEANUP-20251116-003"
```

**Verification:**
```bash
# Pointers should exist and reference correct path
grep "../../CONTRIBUTING.md" modules/KENL1-framework/CONTRIBUTING.md
grep "../../../CONTRIBUTING.md" modules/KENL1-framework/atom-sage-framework/CONTRIBUTING.md

# Root CONTRIBUTING should be unchanged (except git history)
git diff HEAD~1 CONTRIBUTING.md | wc -l  # Should be 0
```

**Rollback:**
```bash
git revert HEAD~1
```

---

### 1.3: Remove Duplicate OWI Documentation

**CTFWI: Verify modules/KENL1-framework/ versions are canonical**

```bash
# Compare root vs KENL1 versions
diff OWI_FRAMEWORK_OVERVIEW.md modules/KENL1-framework/OWI_FRAMEWORK_OVERVIEW.md
diff OWI_METADATA_STANDARD.md modules/KENL1-framework/OWI_METADATA_STANDARD.md

# If KENL1 versions are equal or better, proceed. Otherwise merge first.

# Remove root duplicates
git rm OWI_FRAMEWORK_OVERVIEW.md OWI_METADATA_STANDARD.md

# Add pointer in root README (if not already present)
# Add section to README.md explaining where to find framework docs

git commit -m "refactor: consolidate OWI docs in KENL1-framework module

Removed duplicate OWI documentation from root. Canonical versions
reside in modules/KENL1-framework/ where framework is implemented.

Deleted files:
- OWI_FRAMEWORK_OVERVIEW.md (duplicate)
- OWI_METADATA_STANDARD.md (duplicate)

Canonical location: modules/KENL1-framework/

ATOM-CLEANUP-20251116-004"
```

**Verification:**
```bash
# Root files should not exist
test ! -f OWI_FRAMEWORK_OVERVIEW.md && echo "✅ Removed" || echo "❌ Still exists"
test ! -f OWI_METADATA_STANDARD.md && echo "✅ Removed" || echo "❌ Still exists"

# KENL1 files should still exist
test -f modules/KENL1-framework/OWI_FRAMEWORK_OVERVIEW.md && echo "✅ Canonical exists" || echo "❌ Missing!"
test -f modules/KENL1-framework/OWI_METADATA_STANDARD.md && echo "✅ Canonical exists" || echo "❌ Missing!"
```

**Rollback:**
```bash
git revert HEAD~1
```

---

### 1.4: Consolidate Governance (ADRs)

**CTFWI: Verify governance/ is authoritative location**

```bash
# Compare governance vs KENL1 ADRs
diff governance/02-Decisions/ADR-001-ATOM-SAGE-LAUNCH.md \
     modules/KENL1-framework/02-Decisions/ADR-001-ATOM-SAGE-LAUNCH.md

# If governance/ is authoritative (it should be), proceed

# Remove duplicate from KENL1
git rm -r modules/KENL1-framework/02-Decisions/

# Add reference in KENL1 README
cat >> modules/KENL1-framework/README.md <<'EOF'

## Architecture Decision Records (ADRs)

ADRs for this module are maintained in the project-wide governance directory:
[governance/02-Decisions/](../../governance/02-Decisions/)

EOF

git add modules/KENL1-framework/README.md
git commit -m "refactor: consolidate ADRs in governance directory

Removed duplicate ADR directory from KENL1-framework module.
All Architecture Decision Records should be in governance/02-Decisions/
for project-wide visibility and consistency.

Deleted:
- modules/KENL1-framework/02-Decisions/ (duplicate ADRs)

Canonical location: governance/02-Decisions/

ATOM-CLEANUP-20251116-005"
```

**Verification:**
```bash
# Duplicate should not exist
test ! -d modules/KENL1-framework/02-Decisions && echo "✅ Removed" || echo "❌ Still exists"

# Canonical should exist
test -d governance/02-Decisions && echo "✅ Canonical exists" || echo "❌ Missing!"

# KENL1 README should reference governance
grep "governance/02-Decisions" modules/KENL1-framework/README.md && echo "✅ Referenced" || echo "❌ Not referenced"
```

**Rollback:**
```bash
git revert HEAD~1
```

---

### 1.5: Remove Duplicate atom-sage-framework Directory

**⚠️ CRITICAL: Only execute if Decision Q1 = "NO" (keeping in KENL)**

**CTFWI: Verify KENL1 version is canonical and no external references to root version**

```bash
# SAFETY CHECK: Find all references to atom-sage-framework path
grep -r "atom-sage-framework" --include="*.md" --include="*.sh" --include="*.yaml" . | \
  grep -v "modules/KENL1-framework/atom-sage-framework" | \
  grep -v ".git/" | \
  tee /tmp/atom-sage-refs.txt

# Review /tmp/atom-sage-refs.txt carefully
# If any CI/CD, scripts, or docs reference root atom-sage-framework/, update them first

# Compare directories one more time
diff -r atom-sage-framework/ modules/KENL1-framework/atom-sage-framework/ | \
  grep -v "^Only in" | \
  grep -v "^Binary files" | \
  tee /tmp/atom-sage-diff.txt

# If diffs are acceptable (KENL1 is equal or better), proceed

# Remove root duplicate
git rm -r atom-sage-framework/

# Update any references found in safety check
# (Manual step - update based on /tmp/atom-sage-refs.txt)

git commit -m "refactor: remove duplicate atom-sage-framework directory

The atom-sage-framework existed in both root and modules/KENL1-framework/.
Removed root duplicate; canonical version is in KENL1-framework module.

This consolidation:
- Eliminates ~230KB of duplicate content
- Ensures single source of truth
- Reduces maintenance burden
- Prevents documentation drift

Deleted: /atom-sage-framework/ (entire directory)
Canonical: modules/KENL1-framework/atom-sage-framework/

ATOM-CLEANUP-20251116-006"
```

**Verification:**
```bash
# Root should not exist
test ! -d atom-sage-framework && echo "✅ Removed" || echo "❌ Still exists"

# KENL1 should exist
test -d modules/KENL1-framework/atom-sage-framework && echo "✅ Canonical exists" || echo "❌ Missing!"

# No broken references (run from root)
! grep -r "^\\./atom-sage-framework" --include="*.md" --include="*.sh" . 2>/dev/null && \
  echo "✅ No broken refs" || echo "❌ Found broken refs"
```

**Rollback:**
```bash
git revert HEAD~1
# Note: This restores the duplicate. If you made reference updates, revert those too.
```

---

### 1.6: Consolidate Case Studies

**CTFWI: Verify root case-studies/ has complete set**

```bash
# List all case studies
find . -type d -name "case-studies" -exec ls -la {} \;

# Compare duplicates
diff case-studies/GITHUB_COPILOT_INTEGRATION.md \
     modules/KENL1-framework/case-studies/GITHUB_COPILOT_INTEGRATION.md

diff case-studies/CLOUDFLARE_INTEGRATION.md \
     modules/KENL1-framework/case-studies/CLOUDFLARE_INTEGRATION.md

# If root is authoritative (it should be), proceed

# Remove KENL1 duplicates
git rm modules/KENL1-framework/case-studies/GITHUB_COPILOT_INTEGRATION.md
git rm modules/KENL1-framework/case-studies/CLOUDFLARE_INTEGRATION.md

# If directory is now empty, remove it
if [ -z "$(ls -A modules/KENL1-framework/case-studies)" ]; then
  git rm -r modules/KENL1-framework/case-studies/
fi

# Add reference in KENL1 README
cat >> modules/KENL1-framework/README.md <<'EOF'

## Case Studies

Real-world usage examples are maintained in the project-wide case studies:
[case-studies/](../../case-studies/)

Relevant case studies for this module:
- [GitHub Copilot Integration](../../case-studies/GITHUB_COPILOT_INTEGRATION.md)
- [Cloudflare Integration](../../case-studies/CLOUDFLARE_INTEGRATION.md)

EOF

git add modules/KENL1-framework/README.md
git commit -m "refactor: consolidate case studies in root directory

Removed duplicate case studies from KENL1-framework module.
Case studies have cross-module relevance and should be project-wide.

Deleted:
- modules/KENL1-framework/case-studies/GITHUB_COPILOT_INTEGRATION.md
- modules/KENL1-framework/case-studies/CLOUDFLARE_INTEGRATION.md
- modules/KENL1-framework/case-studies/ (if empty)

Canonical location: case-studies/

ATOM-CLEANUP-20251116-007"
```

**Verification:**
```bash
# KENL1 duplicates should not exist
test ! -f modules/KENL1-framework/case-studies/GITHUB_COPILOT_INTEGRATION.md && \
  echo "✅ Removed" || echo "❌ Still exists"

# Root versions should exist
test -f case-studies/GITHUB_COPILOT_INTEGRATION.md && \
  echo "✅ Canonical exists" || echo "❌ Missing!"
```

**Rollback:**
```bash
git revert HEAD~1
```

---

### Phase 1 Summary & Verification

**After completing steps 1.1 - 1.6:**

```bash
# Run comprehensive verification
cat > /tmp/phase1-verify.sh <<'EOF'
#!/bin/bash
set -e

echo "=== Phase 1 Verification ==="

# Accidental file removed
test ! -f atom-sage-framework/y && echo "✅ 1.1: Accidental file removed" || echo "❌ 1.1 FAILED"

# CONTRIBUTING consolidated
test -f CONTRIBUTING.md && echo "✅ 1.2: Root CONTRIBUTING exists" || echo "❌ 1.2 FAILED"
grep "../../CONTRIBUTING.md" modules/KENL1-framework/CONTRIBUTING.md &>/dev/null && \
  echo "✅ 1.2: KENL1 pointer exists" || echo "❌ 1.2 FAILED"

# OWI docs consolidated
test ! -f OWI_FRAMEWORK_OVERVIEW.md && echo "✅ 1.3: Root OWI removed" || echo "❌ 1.3 FAILED"
test -f modules/KENL1-framework/OWI_FRAMEWORK_OVERVIEW.md && \
  echo "✅ 1.3: KENL1 OWI exists" || echo "❌ 1.3 FAILED"

# ADRs consolidated
test ! -d modules/KENL1-framework/02-Decisions && echo "✅ 1.4: KENL1 ADRs removed" || echo "❌ 1.4 FAILED"
test -d governance/02-Decisions && echo "✅ 1.4: Governance ADRs exist" || echo "❌ 1.4 FAILED"

# atom-sage-framework consolidated (only if Q1 = NO)
# test ! -d atom-sage-framework && echo "✅ 1.5: Root atom-sage removed" || echo "❌ 1.5 FAILED"
# test -d modules/KENL1-framework/atom-sage-framework && \
#   echo "✅ 1.5: KENL1 atom-sage exists" || echo "❌ 1.5 FAILED"

# Case studies consolidated
test ! -f modules/KENL1-framework/case-studies/GITHUB_COPILOT_INTEGRATION.md && \
  echo "✅ 1.6: KENL1 case studies removed" || echo "❌ 1.6 FAILED"
test -f case-studies/GITHUB_COPILOT_INTEGRATION.md && \
  echo "✅ 1.6: Root case studies exist" || echo "❌ 1.6 FAILED"

echo ""
echo "=== Git Status ==="
git status

echo ""
echo "=== Commit Count ==="
git log --oneline pre-cleanup-backup-2025-11-16..HEAD | wc -l
echo "Expected: 6-7 commits (depending on Q1)"

EOF

chmod +x /tmp/phase1-verify.sh
/tmp/phase1-verify.sh
```

**Expected Output:**
```
=== Phase 1 Verification ===
✅ 1.1: Accidental file removed
✅ 1.2: Root CONTRIBUTING exists
✅ 1.2: KENL1 pointer exists
✅ 1.3: Root OWI removed
✅ 1.3: KENL1 OWI exists
✅ 1.4: KENL1 ADRs removed
✅ 1.4: Governance ADRs exist
✅ 1.6: KENL1 case studies removed
✅ 1.6: Root case studies exist

=== Git Status ===
On branch main
nothing to commit, working tree clean

=== Commit Count ===
6-7 commits
```

**If any ❌ appear:** STOP and investigate before proceeding.

**Full Phase 1 Rollback (if needed):**
```bash
# Reset to before Phase 1
git reset --hard pre-cleanup-backup-2025-11-16
git clean -fdx
```

---

## Phase 2: High Priority Cleanup

**Estimated Time:** 1-2 hours
**Risk Level:** MEDIUM (requires validation)
**Prerequisites:** Phase 1 complete and verified

### 2.1: Address MANIFEST Templates

**CTFWI: Decision Q2 determines action**

**Option A: Delete Empty Manifests**

```bash
# Find all template MANIFESTs (not filled in)
grep -l "KENL{N}" modules/*/MANIFEST.md > /tmp/empty-manifests.txt

# Review list
cat /tmp/empty-manifests.txt

# Delete each one
while read manifest; do
  git rm "$manifest"
done < /tmp/empty-manifests.txt

git commit -m "chore: remove unfilled MANIFEST templates

These MANIFEST.md files contained only template placeholders
and were never completed. Removing to reduce noise.

Modules should use README.md for documentation.
If MANIFEST pattern is needed in future, re-add with actual content.

ATOM-CLEANUP-20251116-008"
```

**Option B: Fill In Manifests** (see "MANIFEST Completion Workflow" below)

**Option C: Hybrid** (delete some, fill in others based on module maturity)

---

### 2.2: Update Outdated Date References

**CTFWI: Review each file before updating**

```bash
# Find files with old dates
grep -r "2024\|2023\|2022" --include="*.md" . | \
  grep -v ".git/" | \
  grep -v "CHANGELOG" | \
  grep -v ".archive/" | \
  tee /tmp/old-dates.txt

# Extract unique files
cut -d: -f1 /tmp/old-dates.txt | sort -u > /tmp/files-with-old-dates.txt

# Review each file (MANUAL STEP)
# For each file in /tmp/files-with-old-dates.txt:
#   1. Read the file
#   2. Determine if content is still accurate
#   3. Either:
#      a) Update dates and verify accuracy
#      b) Archive the file
#      c) Delete if obsolete

# Example for one file:
# vim modules/KENL3-dev/guides/MCP-INTEGRATION-GUIDE.md
# Update references, verify commands still work
# git add modules/KENL3-dev/guides/MCP-INTEGRATION-GUIDE.md
# git commit -m "docs: update MCP integration guide for 2025
#
# Verified all steps still work with latest MCP version.
# Updated dates and package versions.
#
# ATOM-CLEANUP-20251116-009"

# Repeat for each file

# Windows 10 EOL (Oct 2025) - special case
# This content is now historical/reference
# Add note that EOL has passed
sed -i '1a > **Note:** Windows 10 EOL occurred on October 14, 2025. This guide is maintained for historical reference and users still on Windows 10.' \
  modules/KENL0-system/windows-support/surface-pro-4/WINDOWS_10_EOL_ISSUES.md

git add modules/KENL0-system/windows-support/surface-pro-4/WINDOWS_10_EOL_ISSUES.md
git commit -m "docs: mark Windows 10 EOL content as historical

Windows 10 support ended October 14, 2025.
Added note that this is historical/reference content.

ATOM-CLEANUP-20251116-010"
```

**Verification:**
```bash
# Re-run date check, should have fewer hits
grep -r "2024\|2023\|2022" --include="*.md" . | \
  grep -v ".git/" | \
  grep -v "CHANGELOG" | \
  grep -v ".archive/" | \
  wc -l

# Should be significantly lower than before
```

---

### 2.3: Fix Broken Links

**CTFWI: Install link checker and verify all links**

```bash
# Install markdown-link-check
npm install -g markdown-link-check

# Check all markdown files
find . -name "*.md" -not -path "./.git/*" -not -path "./.archive/*" | \
  xargs markdown-link-check -q | \
  tee /tmp/link-check-results.txt

# Extract broken links
grep "✖" /tmp/link-check-results.txt > /tmp/broken-links.txt

# Review broken links
cat /tmp/broken-links.txt

# Fix each broken link (MANUAL)
# Common issues:
#   - Relative path wrong after file moves in Phase 1
#   - Files renamed
#   - External URLs changed

# After fixing each, stage and commit:
# git add <files-with-fixed-links>
# git commit -m "docs: fix broken links in <module>
#
# Corrected links broken by Phase 1 consolidation.
#
# ATOM-CLEANUP-20251116-011"

# Re-run link check until clean
find . -name "*.md" -not -path "./.git/*" -not -path "./.archive/*" | \
  xargs markdown-link-check -q
```

**Verification:**
```bash
# Should show all ✔ (green checkmarks), no ✖ (red X)
find . -name "*.md" -not -path "./.git/*" -not -path "./.archive/*" | \
  xargs markdown-link-check -q | \
  grep -c "✖"

# Expected: 0
```

---

### 2.4: Extract TODOs to GitHub Issues

**CTFWI: Review each TODO before creating issue**

```bash
# Find all TODO markers
grep -rn "TODO\|FIXME\|XXX" --include="*.md" . | \
  grep -v ".git/" | \
  grep -v ".archive/" | \
  tee /tmp/todos.txt

# Parse into structured format
cat > /tmp/parse-todos.sh <<'EOF'
#!/bin/bash
# Extract TODOs with file, line, and content
while IFS= read -r line; do
  file=$(echo "$line" | cut -d: -f1)
  linenum=$(echo "$line" | cut -d: -f2)
  content=$(echo "$line" | cut -d: -f3-)
  echo "---"
  echo "File: $file"
  echo "Line: $linenum"
  echo "Content: $content"
done < /tmp/todos.txt
EOF

chmod +x /tmp/parse-todos.sh
/tmp/parse-todos.sh > /tmp/parsed-todos.txt

# Review /tmp/parsed-todos.txt

# For each TODO:
#   1. Determine if still relevant
#   2. Create GitHub issue (use gh CLI or web)
#   3. Replace TODO with reference to issue

# Example:
# Before: <!-- TODO: Add installation instructions -->
# After:  <!-- See issue #123: Add installation instructions -->

gh issue create --title "Add installation instructions to KENL3" \
  --body "From TODO in modules/KENL3-dev/README.md:L45

Current state: Installation section is placeholder
Needed: Step-by-step installation guide

Context: Discovered during cleanup - ATOM-CLEANUP-20251116"

# Replace TODO in file
# vim modules/KENL3-dev/README.md
# Replace TODO line with: <!-- See issue #123 -->

git add modules/KENL3-dev/README.md
git commit -m "docs: convert TODO to GitHub issue #123

Replaced inline TODO with tracked GitHub issue.

ATOM-CLEANUP-20251116-012"

# Repeat for all TODOs
```

**Verification:**
```bash
# Count remaining TODOs
grep -rc "TODO\|FIXME\|XXX" --include="*.md" . | \
  grep -v ":0$" | \
  wc -l

# Expected: Significantly reduced or zero
```

---

### 2.5: Reorganize SAIF Examples

**CTFWI: Decision Q4 determines action**

**If MOVE to examples/:**

```bash
# Create new location
mkdir -p examples/saif-use-cases/automotive

# Move files
git mv dotfiles/SAIF-AUTOMOTIVE-GM-DIRECTOR.md examples/saif-use-cases/automotive/
git mv dotfiles/SAIF-AUTOMOTIVE-R\&D-PROTOTYPER.md examples/saif-use-cases/automotive/
git mv dotfiles/SAIF-PROFESSIONAL-AUTOMOTIVE.md examples/saif-use-cases/automotive/
git mv dotfiles/SAIF-NDA-WORKFLOW.md examples/saif-use-cases/

# Update references in other files
grep -r "dotfiles/SAIF" --include="*.md" . | \
  cut -d: -f1 | \
  sort -u | \
  tee /tmp/saif-refs.txt

# Update each reference (MANUAL)
# Change: dotfiles/SAIF-*.md → examples/saif-use-cases/...

# Add README to new location
cat > examples/saif-use-cases/README.md <<'EOF'
# SAIF Use Cases

SAIF (Self-Aware Intent Framework) examples demonstrating various workflows.

## Automotive Examples

Professional workflows for automotive industry:
- [GM Director Workflow](./automotive/SAIF-AUTOMOTIVE-GM-DIRECTOR.md)
- [R&D Prototyper Workflow](./automotive/SAIF-AUTOMOTIVE-R&D-PROTOTYPER.md)
- [Professional Automotive](./automotive/SAIF-PROFESSIONAL-AUTOMOTIVE.md)

## NDA Workflows

- [NDA Workflow](./SAIF-NDA-WORKFLOW.md)

EOF

git add examples/saif-use-cases/README.md
git commit -m "refactor: reorganize SAIF examples from dotfiles to examples

SAIF use cases are examples, not dotfile configurations.
Moved to examples/saif-use-cases/ for better discoverability.

Moved files:
- dotfiles/SAIF-AUTOMOTIVE-* → examples/saif-use-cases/automotive/
- dotfiles/SAIF-NDA-WORKFLOW.md → examples/saif-use-cases/

Updated all references in documentation.

ATOM-CLEANUP-20251116-013"
```

**Verification:**
```bash
# New location should exist
test -d examples/saif-use-cases && echo "✅ Created" || echo "❌ Missing"

# Files should be moved
test ! -f dotfiles/SAIF-AUTOMOTIVE-GM-DIRECTOR.md && echo "✅ Moved" || echo "❌ Still in old location"
test -f examples/saif-use-cases/automotive/SAIF-AUTOMOTIVE-GM-DIRECTOR.md && echo "✅ In new location" || echo "❌ Not moved"

# No broken references
! grep -r "dotfiles/SAIF" --include="*.md" . | grep -v examples/saif-use-cases/README.md && \
  echo "✅ No broken refs" || echo "❌ Broken refs found"
```

---

### 2.6: Clarify Windows Support Scope

**CTFWI: Decision Q3 determines action**

**Add clarifying README:**

```bash
cat > modules/KENL0-system/windows-support/README.md <<'EOF'
# Windows Support for KENL

**Purpose:** This directory assists Windows users migrating to Bazzite Linux.

## Scope

**In Scope:**
- Windows 10 → Bazzite migration guides
- Windows 11 dual-boot configurations
- Hardware compatibility guides
- Alternative OS evaluations for Windows refugees

**Not In Scope:**
- Windows-native KENL support (KENL is Linux-only)
- General Windows administration
- Windows-only gaming configurations

## Target Audience

1. **Windows 10 EOL refugees** (post October 14, 2025)
2. **Dual-boot users** wanting to try Linux without fully leaving Windows
3. **Surface Pro 4 users** with specific hardware constraints

## Status

- **Windows 10 EOL**: Reference/historical (EOL occurred Oct 2025)
- **Dual-boot guides**: Active, tested on Windows 11
- **Surface Pro 4**: Niche hardware guide, maintained on best-effort basis

## Why in KENL?

Many Bazzite users are Windows gamers making the switch. These guides smooth
the transition by addressing common Windows-specific concerns.

## Contributing

See root [CONTRIBUTING.md](../../../CONTRIBUTING.md) for guidelines.

EOF

git add modules/KENL0-system/windows-support/README.md
git commit -m "docs: clarify Windows support scope in KENL

Added README explaining why Windows migration guides exist in a
Linux-focused project. Addresses scope questions and sets expectations.

ATOM-CLEANUP-20251116-014"
```

**Verification:**
```bash
test -f modules/KENL0-system/windows-support/README.md && echo "✅ Created" || echo "❌ Missing"
grep "Windows 10 EOL refugees" modules/KENL0-system/windows-support/README.md && echo "✅ Content correct" || echo "❌ Wrong content"
```

---

### 2.7: Clarify claude-landing Purpose

**CTFWI: Explain to human users what claude-landing is for**

```bash
# Add section to root README.md (if not already present)
cat >> README.md <<'EOF'

---

## For AI Agents

If you're an AI agent (like Claude, GPT, or similar) working with this repository:

**Start here:** [claude-landing/](./claude-landing/)

The `claude-landing/` directory contains:
- Current repository state
- Recent work summaries
- Quick reference guides
- Orientation for AI-assisted development

Human users: This directory optimizes AI agent onboarding but may be useful for understanding recent changes.

EOF

git add README.md
git commit -m "docs: explain claude-landing purpose in root README

Added section explaining that claude-landing/ is for AI agent orientation.
Makes it clear to human users why this directory exists.

ATOM-CLEANUP-20251116-015"
```

**Verification:**
```bash
grep "claude-landing" README.md && echo "✅ Referenced" || echo "❌ Not mentioned"
grep "AI agent" README.md && echo "✅ Explained" || echo "❌ Not explained"
```

---

### Phase 2 Summary & Verification

**After completing steps 2.1 - 2.7:**

```bash
cat > /tmp/phase2-verify.sh <<'EOF'
#!/bin/bash
set -e

echo "=== Phase 2 Verification ==="

# MANIFESTs handled (decision-dependent)
# TODO: Add check based on Q2 decision

# Outdated dates reduced
old_dates=$(grep -rc "2024\|2023\|2022" --include="*.md" . 2>/dev/null | grep -v ":0$" | wc -l)
echo "Files with old dates: $old_dates (should be reduced from Phase 2 start)"

# Links verified
broken_links=$(find . -name "*.md" -not -path "./.git/*" | xargs markdown-link-check -q 2>/dev/null | grep -c "✖" || true)
if [ "$broken_links" -eq 0 ]; then
  echo "✅ 2.3: No broken links"
else
  echo "❌ 2.3: $broken_links broken links remaining"
fi

# TODOs converted to issues
todo_count=$(grep -rc "TODO\|FIXME\|XXX" --include="*.md" . 2>/dev/null | grep -v ":0$" | wc -l)
echo "Files with TODOs: $todo_count (should be reduced)"

# SAIF examples moved (if Q4 = MOVE)
# test -d examples/saif-use-cases && echo "✅ 2.5: SAIF examples moved" || echo "❌ 2.5 FAILED"

# Windows support README added
test -f modules/KENL0-system/windows-support/README.md && \
  echo "✅ 2.6: Windows support README exists" || echo "❌ 2.6 FAILED"

# claude-landing explained
grep "claude-landing" README.md &>/dev/null && \
  echo "✅ 2.7: claude-landing explained" || echo "❌ 2.7 FAILED"

echo ""
echo "=== Git Status ==="
git status

echo ""
echo "=== Phase 2 Commit Count ==="
git log --oneline HEAD~15..HEAD | tail -8 | wc -l
echo "Expected: ~7-8 commits"

EOF

chmod +x /tmp/phase2-verify.sh
/tmp/phase2-verify.sh
```

**If any failures:** Investigate and fix before Phase 3.

**Phase 2 Rollback:**
```bash
# Count commits made in Phase 2 (approximately)
git log --oneline --since="1 hour ago" | wc -l

# Reset to before Phase 2 (adjust number based on above)
git reset --hard HEAD~8
```

---

## Phase 3: Medium Priority Cleanup

**Estimated Time:** 30 minutes
**Risk Level:** LOW
**Prerequisites:** Phases 1 & 2 complete

### 3.1: Standardize README Format

**CTFWI: Define standard README template**

```bash
# Create template
cat > /tmp/README-TEMPLATE.md <<'EOF'
# Module/Project Name

**Brief one-line description**

## Purpose

What this module/component does and why it exists.

## Quick Start

```bash
# Installation
...

# Basic usage
...
```

## Documentation

- [Full docs](./docs/)
- [Examples](./examples/)
- [Configuration](./CONFIG.md)

## Status

**Version:** X.Y.Z
**Maturity:** [Production | Beta | Alpha]
**Last Updated:** YYYY-MM-DD

## Contributing

See [CONTRIBUTING.md](../../CONTRIBUTING.md)

EOF

# Review current READMEs and update to match template (MANUAL)
# Focus on modules with sparse READMEs

# Example:
# vim modules/KENL6-social/README.md
# Update to match template
# git add modules/KENL6-social/README.md
# git commit -m "docs: standardize KENL6 README format"
```

---

### 3.2: Add Last Updated Dates

**CTFWI: Add frontmatter to important docs**

```bash
# For each major doc, add/update frontmatter with last_verified date
# Example:
cat > /tmp/add-frontmatter.sh <<'EOF'
#!/bin/bash
file="$1"

# Check if frontmatter exists
if ! head -n1 "$file" | grep -q "^---$"; then
  # Add new frontmatter
  cat > "/tmp/new-$file" <<FRONTMATTER
---
last_verified: $(date +%Y-%m-%d)
status: active
---

$(cat "$file")
FRONTMATTER
  mv "/tmp/new-$file" "$file"
fi
EOF

# Apply to critical docs (MANUAL selection)
```

---

### 3.3: Create Missing READMEs

**CTFWI: Ensure all directories have README or index**

```bash
# Find directories without README
find modules/ -type d | while read dir; do
  if [ ! -f "$dir/README.md" ]; then
    echo "Missing README: $dir"
  fi
done > /tmp/missing-readmes.txt

# Review and create minimal READMEs for each
# Commit together:
# git commit -m "docs: add missing READMEs for discoverability"
```

---

### Phase 3 Summary

Much of Phase 3 is ongoing quality improvement. Execute what makes sense now, defer the rest to backlog.

**Verification:**
```bash
# All modules should have README
find modules/ -mindepth 1 -maxdepth 1 -type d | while read dir; do
  test -f "$dir/README.md" && echo "✅ $dir" || echo "❌ $dir (missing README)"
done
```

---

## Phase 4: Automation & Prevention

**Estimated Time:** 1 hour
**Risk Level:** LOW
**Prerequisites:** Phases 1-3 complete

### 4.1: Add Link Checker to CI

```yaml
# .github/workflows/link-check.yml
name: Check Links

on:
  pull_request:
    paths:
      - '**.md'
  schedule:
    - cron: '0 0 * * 0'  # Weekly

jobs:
  markdown-link-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
      - uses: gaurav-nelson/github-action-markdown-link-check@v1
        with:
          config-file: '.github/markdown-link-check-config.json'
```

```json
# .github/markdown-link-check-config.json
{
  "ignorePatterns": [
    {
      "pattern": "^http://localhost"
    }
  ],
  "timeout": "10s",
  "retryOn429": true,
  "aliveStatusCodes": [200, 206]
}
```

```bash
git add .github/workflows/link-check.yml
git add .github/markdown-link-check-config.json
git commit -m "ci: add automated link checking

Prevents broken links from being merged.
Runs on PRs touching markdown and weekly for external link rot.

ATOM-CLEANUP-20251116-016"
```

---

### 4.2: Add MANIFEST Validation (if using manifests)

**Only if Q2 decision was to keep MANIFESTs**

```bash
# Create validator script
cat > scripts/validate-manifests.sh <<'EOF'
#!/bin/bash
set -e

echo "Validating MANIFEST files..."

find modules/ -name "MANIFEST.md" | while read manifest; do
  # Check for template placeholders
  if grep -q "KENL{N}" "$manifest"; then
    echo "❌ $manifest: Contains template placeholder KENL{N}"
    exit 1
  fi

  if grep -q "X.Y.Z" "$manifest"; then
    echo "❌ $manifest: Contains template placeholder X.Y.Z"
    exit 1
  fi

  # Check for required sections
  for section in "Purpose" "Module Information" "Status"; do
    if ! grep -q "## $section" "$manifest"; then
      echo "❌ $manifest: Missing required section: $section"
      exit 1
    fi
  done

  echo "✅ $manifest: Valid"
done

echo "All MANIFESTs validated successfully"
EOF

chmod +x scripts/validate-manifests.sh

# Add to CI
# (add to .github/workflows/ci.yml)

git add scripts/validate-manifests.sh
git commit -m "ci: add MANIFEST validation script

Ensures MANIFEST files are complete and don't contain placeholders.

ATOM-CLEANUP-20251116-017"
```

---

### 4.3: Update .gitignore

**Prevent accidental commits**

```bash
cat >> .gitignore <<'EOF'

# Accidental shell configs
**/y
**/.zcompdump*
**/.zshrc.local
**/.zsh_history
**/.bash_history

# Editor artifacts
**/.vscode/settings.json
**/.idea/workspace.xml

# OS artifacts
.DS_Store
Thumbs.db

# Temporary files
**/tmp/
**/*.tmp
**/*.bak

EOF

git add .gitignore
git commit -m "chore: expand .gitignore to prevent common accidents

Added patterns for shell configs, editor artifacts, and temp files.

ATOM-CLEANUP-20251116-018"
```

---

## Optional: atom-sage-framework Extraction Plan

**Only execute if Decision Q1 = "YES" (separate repo)**

### Extraction Steps

```bash
# 1. Create new repo on GitHub
gh repo create toolate28/atomic-intent-logging --public --description "7-minute recovery from catastrophic failures. Log intent, not just state."

# 2. Clone new repo
cd /tmp
git clone https://github.com/toolate28/atomic-intent-logging.git
cd atomic-intent-logging

# 3. Extract atom-sage-framework from KENL
cd /home/user/kenl
git filter-branch --subdirectory-filter modules/KENL1-framework/atom-sage-framework \
  --prune-empty --tag-name-filter cat -- --all

# 4. Push to new repo
git remote add atomic-intent https://github.com/toolate28/atomic-intent-logging.git
git push atomic-intent main

# 5. In KENL repo, replace with git submodule
cd /home/user/kenl
git rm -r modules/KENL1-framework/atom-sage-framework
git submodule add https://github.com/toolate28/atomic-intent-logging.git modules/KENL1-framework/atom-sage-framework
git commit -m "refactor: extract atom-sage-framework to separate repository

atom-sage-framework is now a standalone project: atomic-intent-logging
KENL uses it as a git submodule.

This enables:
- Broader adoption beyond gaming use case
- Independent versioning and releases
- PyPI/npm publishing
- KENL remains reference implementation

ATOM-CLEANUP-20251116-EXTRACTION"

# 6. Update KENL docs to reference new repo
# Update README.md, links, etc.
```

---

## Optional: MANIFEST Completion Workflow

**Only execute if Decision Q2 = "FILL IN"**

### Completion Process

```bash
# For each module with template MANIFEST:

cat > modules/KENL2-gaming/MANIFEST.md <<'EOF'
---
project: Bazza-DX SAGE Framework
classification: OWI-DOC
atom: ATOM-DOC-20251116-KENL2
status: active
version: 1.2.0
---

# KENL Module Manifest

**Module:** KENL2-gaming
**Version:** 1.2.0
**Status:** Production Ready
**Last Updated:** 2025-11-16

---

## Purpose

Provides gaming configurations, Play Cards, and Proton optimization tooling
for Bazzite Linux. Enables reproducible game setups with validated hardware
profiles and performance tuning.

---

## Module Information

| Property | Value |
|----------|-------|
| **Module ID** | KENL2 |
| **Module Name** | Gaming |
| **Category** | Gaming |
| **Dependencies** | KENL0-system, KENL1-framework |
| **Platforms** | Bazzite, Fedora Atomic |
| **Maintainer** | @toolate28 |

---

## Features

- Play Card system for validated game configs
- Proton version management
- MangoHud integration
- Performance profiling tools
- Anti-cheat compatibility guides

---

## Installation

See [README.md](./README.md) for installation and usage.

---

## Status

**Production Ready**
- Core Play Card system: ✅
- Proton integration: ✅
- Documentation: ✅
- Test coverage: 80%

---

**ATOM:** ATOM-DOC-20251116-KENL2

EOF

git add modules/KENL2-gaming/MANIFEST.md
git commit -m "docs: complete KENL2 gaming module MANIFEST

Filled in template with actual module information.

ATOM-CLEANUP-20251116-MANIFEST-KENL2"

# Repeat for each module
```

---

## Post-Cleanup Actions

### 1. Update CHANGELOG

```bash
cat >> CHANGELOG.md <<'EOF'

## [Unreleased] - 2025-11-16

### Changed
- Consolidated duplicate documentation (atom-sage-framework, OWI, CONTRIBUTING, ADRs)
- Removed 47 outdated/duplicate/incorrect items per cleanup audit
- Standardized README formats across modules
- Updated outdated date references (2022-2024 → 2025)
- Fixed broken internal links

### Removed
- Duplicate `atom-sage-framework/` at root (canonical in modules/KENL1-framework/)
- Duplicate OWI documentation (canonical in KENL1-framework)
- Accidental file `atom-sage-framework/y`
- Empty MANIFEST templates (or filled in - per decision)

### Added
- Link checking in CI/CD
- Automated MANIFEST validation (if using manifests)
- Windows support scope clarification
- claude-landing purpose explanation
- Expanded .gitignore patterns

### Fixed
- ~XX broken markdown links
- Inconsistent documentation structure
- Unclear module purposes

### Migration Notes
- If referencing `atom-sage-framework/` at root, update to `modules/KENL1-framework/atom-sage-framework/`
- If referencing root OWI docs, update to `modules/KENL1-framework/OWI_*.md`
- Check external tooling for hardcoded paths to moved files

**ATOM:** ATOM-CLEANUP-20251116-000 through ATOM-CLEANUP-20251116-018

EOF

git add CHANGELOG.md
git commit -m "docs: document cleanup changes in CHANGELOG

Comprehensive changelog for cleanup audit execution.

ATOM-CLEANUP-20251116-CHANGELOG"
```

---

### 2. Create Release

```bash
git tag -a v1.1.0-cleanup -m "Repository cleanup and consolidation

Major documentation consolidation and cleanup:
- Removed 47 issues (duplicates, outdated content, broken links)
- Consolidated documentation to single sources of truth
- Improved discoverability and consistency
- Added automation to prevent regressions

See CHANGELOG.md for complete details.

ATOM-CLEANUP-20251116-COMPLETE"

git push origin v1.1.0-cleanup
```

---

### 3. Announce in Discussions

```bash
gh discussion create \
  --category announcements \
  --title "Repository Cleanup Complete - v1.1.0" \
  --body "Major cleanup based on comprehensive audit:

- ✅ Removed duplicates (atom-sage, OWI docs, CONTRIBUTING, ADRs)
- ✅ Fixed broken links
- ✅ Updated outdated content
- ✅ Added CI automation (link checking, MANIFEST validation)
- ✅ Improved documentation consistency

**Impact:**
- Smaller repo size (~500KB removed)
- Single source of truth for all docs
- Better contributor experience
- Automated quality checks

**Migration Notes:**
Some paths changed - see CHANGELOG.md for details.

**Questions?** Reply here or open an issue.

ATOM-CLEANUP-20251116-COMPLETE"
```

---

## Full Rollback Procedure

**If cleanup needs to be undone entirely:**

```bash
# 1. Checkout backup branch
git checkout pre-cleanup-backup-2025-11-16

# 2. Create new main from backup
git branch -D main
git checkout -b main

# 3. Force push (CAUTION)
git push origin main --force

# 4. Restore tags
git push origin --delete v1.1.0-cleanup

# 5. Announce rollback
gh discussion create \
  --category announcements \
  --title "Cleanup Rolled Back" \
  --body "Repository cleanup has been rolled back to pre-cleanup state.

If you pulled recent changes, run:
\`\`\`bash
git fetch origin
git reset --hard origin/main
\`\`\`

Cleanup will be re-attempted after addressing issues."
```

---

## Decision Summary Template

**Fill this out before executing any phase:**

```yaml
---
date: 2025-11-16
phase: planning
ctfwi: All decisions confirmed before execution
---

# Cleanup Decisions

## Q1: atom-sage-framework Separate Repo?
Decision: [ ] YES - Extract  |  [ ] NO - Keep in KENL
Action: Execute extraction plan  |  Execute Phase 1.5 deletion

## Q2: MANIFEST Templates?
Decision: [ ] FILL  |  [ ] DELETE  |  [ ] HYBRID
Action: Execute completion workflow  |  Execute deletion in Phase 2.1  |  Define criteria

## Q3: Windows Support Scope?
Decision: [ ] KEEP ALL  |  [ ] KEEP CORE  |  [ ] ARCHIVE NICHE
Action: No changes  |  Archive Surface Pro 4  |  Create windows-support branch

## Q4: SAIF Examples?
Decision: [ ] MOVE  |  [ ] KEEP  |  [ ] ARCHIVE
Action: Execute Phase 2.5  |  No changes  |  Execute archival

## Execution Order:
1. [ ] Pre-execution checklist complete
2. [ ] Decisions above finalized
3. [ ] Phase 1: Critical cleanup
4. [ ] Phase 1 verification passed
5. [ ] Phase 2: High priority
6. [ ] Phase 2 verification passed
7. [ ] Phase 3: Medium priority
8. [ ] Phase 4: Automation
9. [ ] Post-cleanup actions
10. [ ] Announce completion

## Approval:
- [ ] User reviewed and approved plan
- [ ] CTFWI checkpoints understood
- [ ] Rollback procedure tested
- [ ] Ready to execute

---
**Signed:** ___________________
**Date:** ___________________
```

---

## Final CTFWI Checkpoint

**Before executing ANY phase:**

1. ✅ Read entire plan from start to finish
2. ✅ Answer all decision questions (Q1-Q4)
3. ✅ Understand rollback procedures
4. ✅ Create backup branch
5. ✅ Test rollback script in /tmp
6. ✅ Allocate 3-4 hours uninterrupted time
7. ✅ Verify git working tree clean
8. ✅ Ensure no uncommitted work in progress
9. ✅ User explicitly approves: "Execute Phase 1"

**Only then:** Begin Phase 1, Step 1.1.

---

**ATOM:** ATOM-DOC-20251116-002
**Intent:** Provide complete, unambiguous cleanup execution plan
**Status:** Awaiting user approval and decisions
**Next:** User fills Decision Summary, gives explicit "go" command
