---
title: KENL Root Document Index
atom: ATOM-DOC-20251126-010
classification: INDEX
status: production
created: 2025-11-26
updated: 2025-11-26
version: 1.1.0
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
| `GETTING-STARTED.md` | Obsidian vault setup and pathway selection | ✅ Active | User onboarding entry point |
| `CONTRIBUTING.md` | Contribution guidelines and PR checklist | ✅ Active | Standard repo root for contributors |
| `LICENSE` | MIT license | ✅ Active | Standard repo root |
| `SECURITY.md` | Vulnerability reporting process | ✅ Active | Standard repo root for security |
| `CODE_OF_CONDUCT.md` | Community participation guidelines | ✅ Active | Standard repo root for community |
| `CHANGELOG.md` | Version history | ✅ Active | Standard repo root |
| `ACKNOWLEDGMENTS.md` | Third-party attributions | ✅ Active | Standard repo root |

---

## 📋 Framework Standards (Reference Documents)

| Document | Purpose | State | Location Rationale |
|----------|---------|-------|-------------------|
| `OWI_FRAMEWORK_OVERVIEW.md` | OWI methodology explanation | ✅ Active | Framework reference |
| `OWI_METADATA_STANDARD.md` | OWI metadata format specification | ✅ Active | Standard specification |
| `VISUAL-ELEMENTS-STANDARD.md` | Emoji, color, Mermaid conventions | ✅ Active | Style guide for all docs |
| `NAMING-CONVENTIONS.md` | Branch, commit, tag naming rules | ✅ Active | Development standard |
| `SCRIPT-ENVIRONMENT-TAGGING-STANDARD.md` | Script header format | ✅ Active | Script development standard |
| `ATOM-REGISTER.md` | ATOM tag tracking registry | ✅ Active | Traceability requirement |

---

## 📖 Guides and Walkthroughs

| Document | Purpose | State | Location Rationale |
|----------|---------|-------|-------------------|
| `AI-INTEGRATION-GUIDE.md` | Per-module AI usage guide | ✅ Active | Central AI guidance |
| `BAZZITE-DX-IWI-INSTALLATION-SAIF.md` | Complete Bazzite installation walkthrough | ✅ Active | Primary installation guide |
| `GITHUB-COPILOT-AGENT-BRIEFING.md` | Copilot agent instructions | ✅ Active | Agent onboarding |

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

| Document | Purpose | State | Location Rationale |
|----------|---------|-------|-------------------|
| `PR-DAY-ZERO-DESIGN.md` | PR workflow design | ✅ Active | Process design reference |
| `WORKSPACE.md` | Workspace configuration | ✅ Active | Environment config |
| `DOCUMENT-INDEX.md` | This file - root doc inventory | ✅ Active | Navigation hub |

**Archived (2025-11-26):**
- `.archive/planning/CLEANUP-EXECUTION-PLAN.md`
- `.archive/planning/BRANCH-CONSOLIDATION-STRATEGY.md`
- `.archive/planning/MERGE-INSTRUCTIONS.md`
- `.archive/planning/CI-FAILURE-ANALYSIS.md`
- `.archive/planning/CI-PRECOMMIT-FIX.md`
- `.archive/planning/BLIND-SPOTS-AND-UNIFIED-ROADMAP.md`

---

## 📐 Analysis and Optimization

| Document | Purpose | State | Location Rationale |
|----------|---------|-------|-------------------|
| `SAIF-PATTERN-ANALYSIS.md` | SAIF command-flag pattern analysis | ✅ Active | Pattern documentation |
| `PROMPT-ANALYSIS-AND-OPTIMIZATION.md` | AI prompt optimization | ✅ Active | AI prompt reference |
| `ALIGNED-SIGHT.md` | Alignment documentation | ✅ Active | Vision alignment |

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

**ATOM:** ATOM-DOC-20251126-010
**Version:** 1.1.0
**Last Updated:** 2025-11-26
