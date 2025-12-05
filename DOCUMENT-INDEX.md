---
title: KENL Root Document Index
atom: ATOM-DOC-20251205-005
classification: INDEX
status: production
created: 2025-11-26
updated: 2025-12-05
version: 1.3.0
---

# KENL Root Document Index

**Purpose:** 1-line review of every root-level document, its location rationale, and current state.

**Auto-update:** This index should be updated when documents are added, moved, or archived.

**Archive:** Files marked as 📦 Archive-candidate have been moved to `.archive/` directory.

---

## 📁 Core Documents (Essential for All Users)

| Document | Purpose | State | Location Rationale |
|----------|---------|-------|-------------------|
| `README.md` | Primary entry point with pathway navigation | ✅ Active | Standard repo root location |
| `GETTING-STARTED.md` | Workflow selection (AI-assisted or self-propelled) and setup | ✅ Active | User onboarding entry point |
| `CONTRIBUTING.md` | Contribution guidelines and PR checklist | ✅ Active | Standard repo root for contributors |
| `LICENSE` | MIT license | ✅ Active | Standard repo root |
| `SECURITY.md` | Vulnerability reporting process | ✅ Active | Standard repo root for security |
| `CODE_OF_CONDUCT.md` | Community participation guidelines | ✅ Active | Standard repo root for community |
| `CHANGELOG.md` | Version history | ✅ Active | Standard repo root |
| `ACKNOWLEDGMENTS.md` | Third-party attributions | ✅ Active | Standard repo root |

---

## 📁 User Directory (Personal Workspace)

| Document | Purpose | State | Location Rationale |
|----------|---------|-------|-------------------|
| `user/README.md` | User workspace guide and setup instructions | ✅ Active | Personal project landing zone |
| `user/.gitignore` | Prevents committing personal files | ✅ Active | Privacy protection |

**Purpose:** Personal workspace for project-specific files, symlinks to local projects, and custom configurations.

---

## 📋 Framework Standards (Reference Documents)

**Location:** `docs/standards/`

| Document | Purpose | State | Previous Location |
|----------|---------|-------|-------------------|
| `docs/standards/OWI_FRAMEWORK_OVERVIEW.md` | OWI methodology explanation | ✅ Active | Moved from root |
| `docs/standards/OWI_METADATA_STANDARD.md` | OWI metadata format specification | ✅ Active | Moved from root |
| `docs/standards/VISUAL-ELEMENTS-STANDARD.md` | Emoji, color, Mermaid conventions | ✅ Active | Moved from root |
| `docs/standards/NAMING-CONVENTIONS.md` | Branch, commit, tag naming rules | ✅ Active | Moved from root |
| `docs/standards/SCRIPT-ENVIRONMENT-TAGGING-STANDARD.md` | Script header format | ✅ Active | Moved from root |
| `ATOM-REGISTER.md` | ATOM tag tracking registry | ✅ Active | Root (traceability requirement) |

---

## 📖 Guides and Walkthroughs

**Location:** `docs/guides/`

| Document | Purpose | State | Previous Location |
|----------|---------|-------|-------------------|
| `docs/guides/AI-INTEGRATION-GUIDE.md` | Per-module AI usage guide | ✅ Active | Moved from root |
| `docs/guides/BAZZITE-DX-IWI-INSTALLATION-SAIF.md` | Complete Bazzite installation walkthrough | ✅ Active | Moved from root |
| `docs/guides/COMPLETE-DEVELOPMENT-SETUP.md` | Development environment setup | ✅ Active | Moved from root |
| `docs/guides/GITHUB-COPILOT-AGENT-BRIEFING.md` | Copilot agent instructions | ✅ Active | Moved from root |

---

## 🔍 Audits and Reviews

| Document | Purpose | State | Location |
|----------|---------|-------|----------|
| `AUDIT_REPORT_LICENSE_LEGAL.md` | License compliance audit | ✅ Active | Root (legal reference) |

**Archived (2025-11-26):**
- `.archive/audits/AUDIT-FINDINGS-2025-11-16.md`
- `.archive/audits/COMPREHENSIVE-REVIEW-SUMMARY.md`
- `.archive/audits/IMPROVEMENTS-2025-11-16.md`
- `.archive/audits/evaluation_summary.md`
- `.archive/audits/START-HERE-COMPREHENSIVE-REVIEW.md`

---

## 🛠️ Technical Documentation

**Location:** `docs/technical/`

| Document | Purpose | State | Previous Location |
|----------|---------|-------|-------------------|
| `docs/technical/PR-DAY-ZERO-DESIGN.md` | PR workflow design | ✅ Active | Moved from root |
| `docs/technical/WORKSPACE.md` | Workspace configuration | ✅ Active | Moved from root |
| `docs/technical/SAIF-WORKFLOW-PROGRESS-REPORT.md` | SAIF workflow progress tracking | ✅ Active | Moved from root |
| `docs/technical/atom-context-sync-proposal.md` | Context sync proposal | ✅ Active | Moved from root |
| `docs/technical/kenl-atom-visual-presentation.md` | ATOM visual presentation | ✅ Active | Moved from root |
| `docs/technical/kenl-context-sync-atom-directive.md` | Context sync directive | ✅ Active | Moved from root |
| `DOCUMENT-INDEX.md` | This file - root doc inventory | ✅ Active | Root (navigation hub) |

**Archived (2025-11-26):**
- `.archive/planning/CLEANUP-EXECUTION-PLAN.md`
- `.archive/planning/BRANCH-CONSOLIDATION-STRATEGY.md`
- `.archive/planning/MERGE-INSTRUCTIONS.md`
- `.archive/planning/CI-FAILURE-ANALYSIS.md`
- `.archive/planning/CI-PRECOMMIT-FIX.md`
- `.archive/planning/BLIND-SPOTS-AND-UNIFIED-ROADMAP.md`

---

## 📐 Analysis and Optimization

**Location:** `docs/analysis/`

| Document | Purpose | State | Previous Location |
|----------|---------|-------|-------------------|
| `docs/analysis/SAIF-PATTERN-ANALYSIS.md` | SAIF command-flag pattern analysis | ✅ Active | Moved from root |
| `docs/analysis/PROMPT-ANALYSIS-AND-OPTIMIZATION.md` | AI prompt optimization | ✅ Active | Moved from root |
| `docs/analysis/ALIGNED-SIGHT.md` | Alignment documentation | ✅ Active | Moved from root |

---

## 📊 State Legend

| State | Meaning | Action |
|-------|---------|--------|
| ✅ Active | Document is current and in correct location | None |
| ⚠️ Review | Document needs content review | Schedule review |
| 📦 Archived | Moved to `.archive/` directory | See `.archive/README.md` |

---

## 🔄 Freshness Protocol

**Every document should have:**
1. `atom:` tag in frontmatter
2. `created:` or `updated:` date
3. `status:` field (draft/production/deprecated)
4. `version:` field for versioned docs

**Freshness check schedule:**
- Core docs: Monthly review
- Standards: Quarterly review
- Archives: Annual cleanup

---

## 🔗 Cross-Reference Validation

Run link validation:
```bash
./scripts/validate-links.sh
```

---

## 🔄 Recent Updates (2025-12-05)

**Documentation Reorganization:**
- ✅ **User Directory**: Created `user/` as personal workspace for project-specific files and symlinks
- ✅ **Standards**: Moved framework standards to `docs/standards/`
- ✅ **Guides**: Moved installation/integration guides to `docs/guides/`
- ✅ **Analysis**: Moved pattern analysis docs to `docs/analysis/`
- ✅ **Technical**: Moved technical design docs to `docs/technical/`
- ✅ **Structure**: Updated README, copilot-instructions, and DOCUMENT-INDEX to reflect new organization

**Previous Polish Pass Changes:**
- ✅ **KENL8-security**: Removed Vault/TOTP references, added security analysis Jupyter notebook
- ✅ **macOS Support**: Removed macOS references (focus on Windows/Linux)
- ✅ **Obsidian**: Made optional - users can choose AI-assisted (with Obsidian) or self-propelled (any editor) workflows
- ✅ **context-sync**: Clarified as AI-agent-only requirement

---

**ATOM:** ATOM-DOC-20251205-005
**Version:** 1.3.0
**Last Updated:** 2025-12-05
