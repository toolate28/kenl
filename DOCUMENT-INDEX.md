---
title: KENL Root Document Index
atom: ATOM-DOC-20251126-010
classification: INDEX
status: production
created: 2025-11-26
version: 1.0.0
---

# KENL Root Document Index

**Purpose:** 1-line review of every root-level document, its location rationale, and current state.

**Auto-update:** This index should be updated when documents are added, moved, or archived.

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

## 🔍 Audits and Reviews (Historical Context)

| Document | Purpose | State | Location Rationale |
|----------|---------|-------|-------------------|
| `AUDIT-FINDINGS-2025-11-16.md` | Nov 16 audit results | 📦 Archive-candidate | Historical record, move to .archive |
| `AUDIT_REPORT_LICENSE_LEGAL.md` | License compliance audit | ✅ Active | Legal reference |
| `COMPREHENSIVE-REVIEW-SUMMARY.md` | Repository review summary | 📦 Archive-candidate | Historical, move to .archive |
| `IMPROVEMENTS-2025-11-16.md` | Nov 16 improvements | 📦 Archive-candidate | Historical, move to .archive |
| `START-HERE-COMPREHENSIVE-REVIEW.md` | Review starting point | 📦 Archive-candidate | Superseded by GETTING-STARTED.md |
| `evaluation_summary.md` | Evaluation results | 📦 Archive-candidate | Historical, move to .archive |

---

## 🛠️ Technical Planning (Internal/Development)

| Document | Purpose | State | Location Rationale |
|----------|---------|-------|-------------------|
| `CLEANUP-EXECUTION-PLAN.md` | Cleanup task planning | 📦 Archive-candidate | Contains broken links, outdated |
| `BRANCH-CONSOLIDATION-STRATEGY.md` | Branch merge strategy | 📦 Archive-candidate | Temporary planning doc |
| `MERGE-INSTRUCTIONS.md` | Merge workflow instructions | 📦 Archive-candidate | Temporary planning doc |
| `CI-FAILURE-ANALYSIS.md` | CI debugging notes | 📦 Archive-candidate | Troubleshooting record |
| `CI-PRECOMMIT-FIX.md` | Pre-commit fix notes | 📦 Archive-candidate | Troubleshooting record |
| `PR-DAY-ZERO-DESIGN.md` | PR workflow design | ✅ Active | Process design reference |
| `WORKSPACE.md` | Workspace configuration | ✅ Active | Environment config |

---

## 📐 Analysis and Optimization

| Document | Purpose | State | Location Rationale |
|----------|---------|-------|-------------------|
| `SAIF-PATTERN-ANALYSIS.md` | SAIF command-flag pattern analysis | ✅ Active | Pattern documentation |
| `PROMPT-ANALYSIS-AND-OPTIMIZATION.md` | AI prompt optimization | ✅ Active | AI prompt reference |
| `BLIND-SPOTS-AND-UNIFIED-ROADMAP.md` | Gap analysis and roadmap | ⚠️ Review | Contains placeholder images, needs cleanup |
| `ALIGNED-SIGHT.md` | Alignment documentation | ✅ Active | Vision alignment |

---

## 📝 Session and Collaboration Records

| Document | Purpose | State | Location Rationale |
|----------|---------|-------|-------------------|
| `ABOUT-OUR-COLLABORATION.md` | User-specific collaboration notes | 📦 Archive-candidate | Personal notes, move to .archive |
| `SESSION_SUMMARY_2025-11-26.md` | Session summary | 📦 Archive-candidate | Temporary, move to .archive |
| `README-DOGFOODING-SECTION.md` | Dogfooding section draft | 📦 Archive-candidate | Draft content, integrate or archive |

---

## 📊 State Legend

| State | Meaning | Action |
|-------|---------|--------|
| ✅ Active | Document is current and in correct location | None |
| ⚠️ Review | Document needs content review | Schedule review |
| 📦 Archive-candidate | Move to `.archive/` directory | Run archive script |
| ❌ Deprecated | Remove or replace | Remove from repo |

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

**Known issues in non-core documents:**
- `CLEANUP-EXECUTION-PLAN.md`: Multiple broken links (archive candidate)
- `BLIND-SPOTS-AND-UNIFIED-ROADMAP.md`: Placeholder image references
- `atom-sage-framework/`: Some relative path issues

---

**ATOM:** ATOM-DOC-20251126-010
**Last Updated:** 2025-11-26
