---
title: Archive Directory
atom: ATOM-DOC-20251126-012
classification: INDEX
status: production
created: 2025-11-26
updated: 2025-11-26
---

# KENL Document Archive

This directory contains archived documentation organized by category.

## Archive Structure

```
.archive/
├── audits/       # Historical audit results and reviews
├── planning/     # Completed planning documents
├── sessions/     # AI collaboration session records
├── drafts/       # Draft content not integrated
├── 2025-11-02/   # Early project documentation (legacy)
├── 2025-11-05/   # Pre-rebase documentation (legacy)
└── README.md     # This file
```

## Document Status Definitions

- **active**: Current, in-use documentation (in main directories)
- **archive**: Historical reference, content superseded or integrated elsewhere
- **superseded**: Replaced by newer version (see `superseded_by` field)

## Contents (2025-11-26 Archive)

### `/audits/`
| File | Original Purpose | Archived Date |
|------|------------------|---------------|
| `AUDIT-FINDINGS-2025-11-16.md` | Nov 16 audit results | 2025-11-26 |
| `COMPREHENSIVE-REVIEW-SUMMARY.md` | Repository review summary | 2025-11-26 |
| `IMPROVEMENTS-2025-11-16.md` | Nov 16 improvements | 2025-11-26 |
| `evaluation_summary.md` | Evaluation results | 2025-11-26 |
| `START-HERE-COMPREHENSIVE-REVIEW.md` | Superseded by GETTING-STARTED.md | 2025-11-26 |

### `/planning/`
| File | Original Purpose | Archived Date |
|------|------------------|---------------|
| `CLEANUP-EXECUTION-PLAN.md` | Cleanup task planning (contains broken links) | 2025-11-26 |
| `BRANCH-CONSOLIDATION-STRATEGY.md` | Branch merge strategy | 2025-11-26 |
| `MERGE-INSTRUCTIONS.md` | Merge workflow instructions | 2025-11-26 |
| `CI-FAILURE-ANALYSIS.md` | CI debugging notes | 2025-11-26 |
| `CI-PRECOMMIT-FIX.md` | Pre-commit fix notes | 2025-11-26 |
| `BLIND-SPOTS-AND-UNIFIED-ROADMAP.md` | Gap analysis (contains placeholder images) | 2025-11-26 |

### `/sessions/`
| File | Original Purpose | Archived Date |
|------|------------------|---------------|
| `ABOUT-OUR-COLLABORATION.md` | User-specific collaboration notes | 2025-11-26 |
| `SESSION_SUMMARY_2025-11-26.md` | Session summary | 2025-11-26 |

### `/drafts/`
| File | Original Purpose | Archived Date |
|------|------------------|---------------|
| `README-DOGFOODING-SECTION.md` | Dogfooding section draft | 2025-11-26 |

## Retrieval

To restore archived documents:
```bash
# Move file back to root
mv .archive/audits/FILENAME.md ./FILENAME.md

# Update DOCUMENT-INDEX.md to reflect restoration
```

## ⚠️ Notes

- These files may contain broken links or outdated content
- Links pointing to these files from other documents may need updating
- Consider removing permanently after 90 days if not referenced

## ATOM Trail

All archive operations are logged with ATOM tags for traceability.

**ATOM:** ATOM-DOC-20251126-012 (updated from ATOM-CFG-20251105-021)
**Archived By:** @copilot
**Archive Date:** 2025-11-26
