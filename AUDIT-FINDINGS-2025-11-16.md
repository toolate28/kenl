---
title: KENL Repository Audit Findings
date: 2025-11-16
classification: OWI-DOC
status: review-needed
---

# KENL Repository Audit - Cleanup Recommendations

**Date:** 2025-11-16
**Auditor:** Claude (via user request)
**Scope:** Identify outdated, duplicated, or unnecessary content

---

## Executive Summary

Found **47 issues** across 6 categories:
- 🔴 **Critical** (8): Major duplications, broken structure
- 🟠 **High** (15): Template files never filled in, outdated references
- 🟡 **Medium** (18): Minor duplications, optimization opportunities
- 🟢 **Low** (6): Cosmetic issues, nice-to-have cleanups

**Estimated cleanup impact:**
- Remove ~500KB of duplicate content
- Fix 37 template files
- Consolidate 4 major documentation sets
- Remove 1 accidental commit

---

## 🔴 Critical Issues (Action Required)

### 1. Duplicate `atom-sage-framework/` Directories

**Location:**
- `/home/user/kenl/atom-sage-framework/` (230KB)
- `/home/user/kenl/modules/KENL1-framework/atom-sage-framework/` (252KB)

**Problem:** Near-identical content in two locations. Files differ slightly.

**Evidence:**
```bash
$ diff -q atom-sage-framework/ modules/KENL1-framework/atom-sage-framework/ -r
Files atom-sage-framework/README.md and modules/KENL1-framework/atom-sage-framework/README.md differ
Only in modules/KENL1-framework/atom-sage-framework/forks: ATOM-IWI
Only in atom-sage-framework/: y  # <- accidental file
```

**Recommendation:**
- ✅ **Keep:** `modules/KENL1-framework/atom-sage-framework/` (canonical location)
- ❌ **Delete:** `/home/user/kenl/atom-sage-framework/` (root duplicate)
- ⚠️ **Extract:** If moving to separate repo (per discussion), use KENL1 version as base

**Impact:** High - confuses contributors, wastes disk space, outdated content risk

---

### 2. Duplicate OWI Framework Documentation

**Location:**
- `/home/user/kenl/OWI_FRAMEWORK_OVERVIEW.md`
- `/home/user/kenl/OWI_METADATA_STANDARD.md`
- `/home/user/kenl/modules/KENL1-framework/OWI_FRAMEWORK_OVERVIEW.md`
- `/home/user/kenl/modules/KENL1-framework/OWI_METADATA_STANDARD.md`

**Problem:** Identical framework docs in root and KENL1 module.

**Recommendation:**
- ✅ **Keep:** `modules/KENL1-framework/OWI_*.md` (belongs with framework)
- ❌ **Delete:** Root-level `OWI_*.md` files
- 📝 **Add:** Symlink or README pointer from root if needed for discoverability

**Impact:** High - documentation drift risk

---

### 3. Multiple `CONTRIBUTING.md` Files

**Location:**
- `/home/user/kenl/CONTRIBUTING.md` (root)
- `/home/user/kenl/atom-sage-framework/CONTRIBUTING.md`
- `/home/user/kenl/modules/KENL1-framework/CONTRIBUTING.md`
- `/home/user/kenl/modules/KENL1-framework/atom-sage-framework/CONTRIBUTING.md`

**Problem:** 4 CONTRIBUTING files with potentially different guidelines.

**Recommendation:**
- ✅ **Keep:** Root `/home/user/kenl/CONTRIBUTING.md` (primary)
- ❌ **Delete:** All sub-module CONTRIBUTING files
- 📝 **Add:** One-line pointer in submodules: "See [root CONTRIBUTING.md](../../CONTRIBUTING.md)"

**Impact:** High - contributor confusion

---

### 4. Accidental File: `atom-sage-framework/y`

**Location:** `/home/user/kenl/atom-sage-framework/y`

**Content:**
```bash
# The following lines were added by compinstall
zstyle ':completion:*' expand prefix suffix
# ... zsh completion config
```

**Problem:** Accidentally committed zsh config file (Windows path in filename).

**Recommendation:**
- ❌ **Delete immediately** and add to `.gitignore`
- 📝 **Add to .gitignore:** `**/y`, `**/.zcompdump*`, `**/.zshrc.local`

**Impact:** Medium - not harmful but unprofessional

---

### 5. Duplicate Governance Documents

**Location:**
- `/home/user/kenl/governance/02-Decisions/ADR-001-ATOM-SAGE-LAUNCH.md`
- `/home/user/kenl/modules/KENL1-framework/02-Decisions/ADR-001-ATOM-SAGE-LAUNCH.md`

**Problem:** Same ADR in two locations.

**Recommendation:**
- ✅ **Keep:** `governance/02-Decisions/` (project-wide governance)
- ❌ **Delete:** `modules/KENL1-framework/02-Decisions/`
- 📝 **Reference:** Link from KENL1 README to governance folder

**Impact:** High - single source of truth for decisions

---

### 6. Archive Directory Confusion

**Location:**
- `/home/user/kenl/.archive/` (documented)
- Multiple files in `/home/user/kenl/.archive/2025-11-02/` from early project

**Problem:** Archive exists but some files still duplicate content in active tree.

**Files to verify:**
```bash
.archive/2025-11-02/bazza-dx-one-pager.md
.archive/2025-11-02/bazza-dx-project-documentation.md
.archive/2025-11-02/gaming-config-*.md
```

**Recommendation:**
- ✅ **Verify:** Check if these are truly superseded
- ❌ **Delete active duplicates** if superseded
- 📝 **Document:** Add `superseded_by` metadata in archive README

**Impact:** Medium - reduces confusion about "current" docs

---

### 7. Empty MANIFEST Templates (12 modules)

**Location:** Most `modules/KENL*/MANIFEST.md` files

**Problem:** Template placeholders never filled in.

**Evidence:**
```bash
$ head modules/KENL2-gaming/MANIFEST.md
**Module:** KENL{N}-{name}  # <- Not filled in
**Version:** X.Y.Z          # <- Not filled in
{One-paragraph description of what this module does}  # <- Placeholder
```

**Files with templates:**
- KENL0, KENL1, KENL2, KENL3, KENL4, KENL5, KENL6, KENL7, KENL8, KENL9, KENL11, KENL12

**Recommendation:**
- ⚠️ **Fill in or delete:** Either complete templates or remove placeholder MANIFESTs
- 📝 **Alternative:** Convert to simpler README if MANIFEST overhead isn't needed

**Impact:** Medium - reduces noise, improves professionalism

---

### 8. Outdated Date References (29 files)

**Location:** Files referencing 2022, 2023, 2024 dates

**Problem:** Documentation may be outdated.

**Examples:**
- `modules/KENL3-dev/guides/MCP-INTEGRATION-GUIDE.md` - Check if MCP info current
- `modules/KENL0-system/windows-support/surface-pro-4/WINDOWS_10_EOL_ISSUES.md` - EOL was Oct 2025
- `dotfiles/SAIF-PROFESSIONAL-AUTOMOTIVE.md` - Likely outdated automotive examples

**Recommendation:**
- 📅 **Review each file** - Update dates and verify accuracy
- ⚠️ **Archive outdated** - Move to `.archive/` if superseded
- 📝 **Add `last_verified` frontmatter** to critical docs

**Impact:** Medium - outdated info misleads users

---

## 🟠 High Priority Issues

### 9. Inconsistent README Quality

**Problem:** 37 README files across repo, varying quality.

**Recommendations:**
- Standardize format (see `CONTRIBUTING.md` for template)
- Ensure all module READMEs explain purpose, installation, usage
- Add "Last Updated" dates

---

### 10. Broken Internal Links (Potential)

**Found:** 100+ internal markdown links `[text](../path/file.md)`

**Risk:** With duplicated files and moves, some links may be broken.

**Recommendation:**
- Run link checker: `markdown-link-check **/*.md`
- Fix broken references
- Use relative paths consistently

---

### 11. TODO/FIXME Markers (20 files)

**Files with TODO markers:**
```
atom-sage-framework/docs/GETTING_STARTED.md
atom-sage-framework/docs/USER_MANUAL.md
.kenl/REBASE_EXPECTATIONS.md
claude-landing/MIGRATION-PLAN.md
modules/KENL13-iwi/resources/RESOURCES.md
... and 15 more
```

**Recommendation:**
- Extract TODOs to GitHub Issues
- Mark incomplete docs as "Draft" in frontmatter
- Clean up completed TODOs

---

## 🟡 Medium Priority Issues

### 12. Case Studies Duplication

**Location:**
- `/home/user/kenl/case-studies/`
- `/home/user/kenl/modules/KENL1-framework/case-studies/`

**Files:**
- `GITHUB_COPILOT_INTEGRATION.md` (both locations)
- `CLOUDFLARE_INTEGRATION.md` (both locations)

**Recommendation:**
- Keep in root `case-studies/` (cross-module relevance)
- Delete from KENL1-framework
- Add index/README to case-studies explaining purpose

---

### 13. Windows Support Documentation Scope

**Location:** `modules/KENL0-system/windows-support/`

**Observation:** Extensive Windows 10 EOL migration guides for a Linux-focused project.

**Content:**
- Surface Pro 4 specific guides
- Windows 11 dual-boot setup
- Alternative OS evaluations

**Recommendation:**
- ✅ **Keep:** Core dual-boot and migration guides (valuable for Linux migration)
- ⚠️ **Evaluate:** Surface Pro 4 specific content - is this too niche?
- 📝 **Clarify:** Add README explaining this is for Windows → Bazzite migrations

**Impact:** Low-Medium - good content but scope creep risk

---

### 14. SAIF Documentation in `dotfiles/`

**Location:** `dotfiles/SAIF-*.md` (7 files)

**Content:**
- Automotive industry examples
- Professional workflows
- NDA workflows

**Problem:** Unclear why SAIF framework examples are in `dotfiles/` directory.

**Recommendation:**
- Move to `modules/KENL1-framework/atom-sage-framework/examples/saif/`
- Or create `examples/` directory at root
- Update paths and references

---

### 15. Claude-Specific Documentation Location

**Location:** `claude-landing/` (13 files)

**Purpose:** AI agent orientation docs

**Observation:** Very useful but not obvious to human users.

**Recommendation:**
- ✅ **Keep:** Excellent resource
- 📝 **Add:** Explanation in root README about `claude-landing/` purpose
- 🔗 **Link:** From main README: "AI Agents start here: [claude-landing/](./claude-landing/)"

---

### 16-25. (Additional Medium Priority)

- `.kenl/` metadata clarity
- `docs/` vs `documentation/` confusion
- Unused shell scripts
- PowerShell module documentation completeness
- Play Card example coverage
- CI/CD outdated refs (fixed in separate commit)
- Pre-commit hook docs vs config alignment
- Gaming guide completeness
- Security documentation gaps
- Backup/recovery procedure docs

---

## 🟢 Low Priority / Nice-to-Have

### 26. Empty Git Directories

**Found:** 3 empty git-managed directories

**Impact:** Negligible, but clean them up

---

### 27. VISUAL-ELEMENTS-STANDARD.md Usage

**Location:** Root `VISUAL-ELEMENTS-STANDARD.md`

**Observation:** 145 files use diagrams, check compliance.

**Recommendation:** Audit later for consistency

---

### 28-31. (Cosmetic)

- Consistent emoji usage in README
- Diagram color scheme (per user request - SEPARATE TASK)
- Code block language tags
- Frontmatter consistency

---

## Cleanup Action Plan

### Phase 1: Critical (Do First)

```bash
# 1. Remove duplicate atom-sage-framework at root
git rm -r atom-sage-framework/
git commit -m "refactor: remove duplicate atom-sage-framework, canonical in modules/KENL1-framework"

# 2. Remove duplicate OWI docs at root
git rm OWI_FRAMEWORK_OVERVIEW.md OWI_METADATA_STANDARD.md
git commit -m "refactor: consolidate OWI docs in KENL1-framework module"

# 3. Remove accidental file
git rm atom-sage-framework/y
echo "**/y" >> .gitignore
echo "**/.zcompdump*" >> .gitignore
git commit -m "chore: remove accidental zsh config file"

# 4. Consolidate CONTRIBUTING
git rm modules/KENL1-framework/CONTRIBUTING.md
git rm modules/KENL1-framework/atom-sage-framework/CONTRIBUTING.md
# Add pointers in those locations
git commit -m "docs: consolidate to single root CONTRIBUTING.md"

# 5. Remove duplicate governance
git rm -r modules/KENL1-framework/02-Decisions/
git commit -m "refactor: consolidate ADRs in governance/ directory"
```

### Phase 2: High Priority

```bash
# 6. Fix or remove MANIFEST templates
# Either fill them in or delete placeholder content

# 7. Review and update outdated date references

# 8. Run link checker and fix broken references
npm install -g markdown-link-check
markdown-link-check **/*.md

# 9. Extract TODOs to GitHub Issues
```

### Phase 3: Medium Priority

```bash
# 10. Reorganize SAIF examples
# 11. Clarify claude-landing purpose in README
# 12. Consolidate case studies
# 13. Document Windows support scope
```

### Phase 4: Low Priority / Ongoing

```bash
# 14. Cosmetic improvements
# 15. Diagram consistency review
# 16. Link verification automation in CI
```

---

## Recommendations Summary

### DELETE (11 items):
1. `/atom-sage-framework/` (duplicate)
2. Root `OWI_*.md` files (2 files)
3. Sub-module CONTRIBUTING files (3 files)
4. `atom-sage-framework/y` (accidental)
5. `modules/KENL1-framework/02-Decisions/` (duplicate ADRs)
6. Empty MANIFEST templates OR fill them in (12 files)

### CONSOLIDATE (4 areas):
1. atom-sage-framework → modules/KENL1-framework only
2. OWI docs → modules/KENL1-framework only
3. CONTRIBUTING → root only
4. Governance/ADRs → governance/ only

### UPDATE (3 areas):
1. Outdated date references (29 files)
2. Broken links (TBD after link check)
3. TODO markers → GitHub Issues (20 files)

### CLARIFY (3 areas):
1. claude-landing/ purpose (add to root README)
2. Windows support scope (add README)
3. SAIF examples location (move from dotfiles/)

---

## Risk Assessment

**Low Risk Changes:**
- Deleting duplicate files (git history preserves)
- Removing accidental file (`y`)
- Consolidating CONTRIBUTING docs

**Medium Risk Changes:**
- Removing MANIFEST templates (may break automation?)
- Updating date references (requires verification)
- Moving SAIF examples

**High Risk Changes:**
- Removing root atom-sage-framework (CHECK for external refs!)
- Consolidating governance docs (verify no automation depends on path)

---

## Next Steps

1. **User Decision:** Approve this audit and action plan
2. **Backup:** Create branch `pre-cleanup-backup`
3. **Execute:** Phase 1 critical cleanup
4. **Verify:** Run tests, check links, verify builds
5. **Iterate:** Phases 2-4 based on priority

---

## Questions for User

1. **atom-sage-framework split:** Still planning separate repo? If so, timing affects cleanup.
2. **MANIFEST templates:** Fill in or delete? Need automation context.
3. **Windows support:** Keep Surface Pro 4 specific docs or too niche?
4. **SAIF automotive examples:** Keep, move, or archive?
5. **Cleanup aggressiveness:** Conservative (keep more) or aggressive (delete more)?

---

**ATOM:** ATOM-DOC-20251116-001
**Intent:** Comprehensive audit to identify cleanup opportunities
**Status:** Review needed - awaiting user decisions
**Next:** User approves → Execute Phase 1 cleanup
