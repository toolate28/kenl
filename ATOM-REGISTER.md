---
title: KENL ATOM Tag Register
classification: ATOM-REGISTRY
updated: 2025-11-26
version: 2.0.0
atom: ATOM-DOC-20251126-002
status: active
---

# ATOM Tag Register

This document tracks all ATOM (Atomic Audit Trail Operations Manifest) tags used in the KENL repository. Every significant change, decision, or action is tagged for traceability.

---

## ATOM Tag Format

```
ATOM-{TYPE}-{YYYYMMDD}-{NNN}
```

**Types:**
| Type | Description | Example |
|------|-------------|---------|
| `DOC` | Documentation changes | ATOM-DOC-20251126-001 |
| `CFG` | Configuration changes | ATOM-CFG-20251112-006 |
| `MCP` | MCP tool invocations | ATOM-MCP-20251110-001 |
| `SAGE` | SAGE methodology executions | ATOM-SAGE-20251105-003 |
| `DEPLOY` | Production deployments | ATOM-DEPLOY-20251114-001 |
| `TASK` | Task tracking | ATOM-TASK-20251112-001 |
| `RESEARCH` | Research queries | ATOM-RESEARCH-20251112-001 |
| `STATUS` | Status reports | ATOM-STATUS-20251116-001 |
| `PWSH` | PowerShell operations | ATOM-PWSH-20251110-001 |
| `NETWORK` | Network operations | ATOM-NETWORK-20251117-001 |
| `GAMING` | Gaming configurations | ATOM-GAMING-20251110-001 |
| `PLAYCARD` | Play Card operations | ATOM-PLAYCARD-20251110-001 |
| `PATTERN` | Design pattern implementations | ATOM-PATTERN-20251112-001 |
| `CASE` | Case study documentation | ATOM-CASE-20251112-001 |
| `CLEANUP` | Cleanup operations | ATOM-CLEANUP-20251116-001 |
| `REFACTOR` | Code refactoring | ATOM-REFACTOR-20251118-001 |
| `PROFILE` | Profile/environment setup | ATOM-PROFILE-20251126-001 |
| `SAIF` | SAIF process operations | ATOM-SAIF-20251125-001 |
| `VERIFY` | Verification operations | ATOM-VERIFY-20251126-001 |
| `MODULE` | Module imports/exports | ATOM-MODULE-20251126-001 |
| `PATHWAY` | Pathway selections | ATOM-PATHWAY-20251126-001 |

---

## Active ATOM Tags

### November 2025

#### 2025-11-26 (Documentation Restructure)

| Tag | Description | File/Location | Status |
|-----|-------------|---------------|--------|
| ATOM-DOC-20251126-001 | GETTING-STARTED.md - Obsidian vault initialization | `/GETTING-STARTED.md` | Active |
| ATOM-DOC-20251126-002 | ATOM Register creation | `/ATOM-REGISTER.md` | Active |
| ATOM-DOC-20251126-003 | README.md restructure with pathway system | `/README.md` | Active |
| ATOM-PROFILE-20251126-001 | PowerShell profile installation script | `/scripts/Install-KenlProfile.ps1` | Active |
| ATOM-STATUS-20251126-001 | CURRENT-STATE.md update - Documentation restructure status | `claude-landing/CURRENT-STATE.md` | Active |

#### 2025-11-25 (SAIF Module)

| Tag | Description | File/Location | Status |
|-----|-------------|---------------|--------|
| ATOM-SAIF-20251125-001 | KENL.SAIF.psm1 module creation | `/modules/KENL0-system/powershell/KENL.SAIF.psm1` | Active |

#### 2025-11-23 (BF6 Gaming Branch)

| Tag | Description | File/Location | Status |
|-----|-------------|---------------|--------|
| ATOM-CFG-20251112-011 | GitHub automation setup | `.github/` | Merged |
| ATOM-PATTERN-20251112-001 | Long-task pattern design | `claude-landing/LONG-TASK-PATTERN.md` | Active |
| ATOM-CFG-20251112-009 | Claude Code CLI configuration | `claude-landing/CLI-*.md` | Active |
| ATOM-CASE-20251112-001 | BF6 AI decision-making case study | `case-studies/AI_GUIDED_DECISION_MAKING_BF6.md` | Active |
| ATOM-CFG-20251112-005 | Workflow diagrams | `scripts/windows-partition-scripts/WORKFLOW_DIAGRAM.md` | Active |
| ATOM-CFG-20251112-006 | Profile setup documentation | `scripts/windows-partition-scripts/PROFILES_SETUP.md` | Active |
| ATOM-RESEARCH-20251112-001 | Research agent prompt | `.claude/RESEARCH_PROMPT.md` | Active |

#### 2025-11-18 (Documentation Session)

| Tag | Description | File/Location | Status |
|-----|-------------|---------------|--------|
| ATOM-DOC-20251118-001 | README-DOGFOODING-SECTION.md | `/README-DOGFOODING-SECTION.md` | Active |
| ATOM-DOC-20251118-002 | ALIGNED-SIGHT.md | `/ALIGNED-SIGHT.md` | Active |
| ATOM-DOC-20251118-003 | TERMINOLOGY.md | `claude-landing/TERMINOLOGY.md` | Active |
| ATOM-DOC-20251118-004 | HIGH-IMPACT-PROJECTS-ASSESSMENT.md | `claude-landing/HIGH-IMPACT-PROJECTS-ASSESSMENT.md` | Active |
| ATOM-REFACTOR-20251118-001 | "Relay Race" → "Baton Pass" terminology | Various | Active |
| ATOM-DOC-20251118-005 | ABOUT-OUR-COLLABORATION.md | `/ABOUT-OUR-COLLABORATION.md` | Active |
| ATOM-DOC-20251118-006 | WORKSPACE.md | `/WORKSPACE.md` | Active |

#### 2025-11-17 (LOGDY Session)

| Tag | Description | File/Location | Status |
|-----|-------------|---------------|--------|
| ATOM-DOC-20251117-001 | Logdy SAIF implementation | `claude-landing/SESSION-2025-11-17-LOGDY-SAIF-COMPLETE.md` | Active |

#### 2025-11-16 (Audit & Cleanup)

| Tag | Description | File/Location | Status |
|-----|-------------|---------------|--------|
| ATOM-DOC-20251116-001 | Audit findings report | `/AUDIT-FINDINGS-2025-11-16.md` | Active |
| ATOM-CLEANUP-20251116-001 | Phase 1 cleanup execution | `/CLEANUP-EXECUTION-PLAN.md` | Completed |
| ATOM-CLEANUP-20251116-002 | Phase 2 cleanup execution | `/CLEANUP-EXECUTION-PLAN.md` | Completed |
| ATOM-CLEANUP-20251116-003 | Phase 3 cleanup execution | `/CLEANUP-EXECUTION-PLAN.md` | Completed |
| ATOM-CLEANUP-20251116-004 | Phase 4 cleanup execution | `/CLEANUP-EXECUTION-PLAN.md` | Completed |
| ATOM-CLEANUP-20251116-005 | Phase 5 cleanup execution | `/CLEANUP-EXECUTION-PLAN.md` | Completed |
| ATOM-CLEANUP-20251116-006 | Phase 6 cleanup execution | `/CLEANUP-EXECUTION-PLAN.md` | Completed |
| ATOM-CLEANUP-20251116-007 | Phase 7 cleanup execution | `/CLEANUP-EXECUTION-PLAN.md` | Completed |

#### 2025-11-15 (Obsidian Quick Start)

| Tag | Description | File/Location | Status |
|-----|-------------|---------------|--------|
| ATOM-DOC-20251115-001 | Obsidian Quick Start guide | `claude-landing/OBSIDIAN-QUICK-START.md` | Active |

#### 2025-11-14 (Comprehensive Review)

| Tag | Description | File/Location | Status |
|-----|-------------|---------------|--------|
| ATOM-DOC-20251114-001 | Acknowledgments documentation | `/ACKNOWLEDGMENTS.md` | Active |
| ATOM-DOC-20251114-999 | Comprehensive repository review | `/COMPREHENSIVE-REVIEW-SUMMARY.md` | Active |

#### 2025-11-10 (PowerShell & Gaming)

| Tag | Description | File/Location | Status |
|-----|-------------|---------------|--------|
| ATOM-PWSH-20251110-001 | KENL.psm1 core module | `modules/KENL0-system/powershell/KENL.psm1` | Active |
| ATOM-PLAYCARD-20251110-001 | Play Card creation | `modules/KENL2-gaming/play-cards/` | Active |
| ATOM-GAMING-20251110-001 | Gaming module initialization | `modules/KENL2-gaming/` | Active |
| ATOM-RESEARCH-20251110-001 | ProtonDB research | `modules/KENL2-gaming/compat-tracking/` | Active |

#### 2025-11-06 (Initial Setup)

| Tag | Description | File/Location | Status |
|-----|-------------|---------------|--------|
| ATOM-DOC-20251106-019 | CHANGELOG and CONTRIBUTING | `/CHANGELOG.md`, `/CONTRIBUTING.md` | Active |

#### 2025-11-05 (Framework Foundation)

| Tag | Description | File/Location | Status |
|-----|-------------|---------------|--------|
| ATOM-DOC-20251105-024 | OWI Metadata Standard | `/OWI_METADATA_STANDARD.md` | Active |
| ATOM-DOC-20251105-025 | OWI examples | `/OWI_METADATA_STANDARD.md` | Active |
| ATOM-CFG-20251105-026 | OWI configuration | `/OWI_METADATA_STANDARD.md` | Active |
| ATOM-VISUAL-20251105-001 | Visual elements standard | `/VISUAL-ELEMENTS-STANDARD.md` | Active |
| ATOM-SAGE-20251105-003 | SAGE manifest | `/.sage-manifest.yaml` | Active |

---

## Governance ARCREFs

| ARCREF ID | Title | ADR Link | Status |
|-----------|-------|----------|--------|
| ARCREF-ATOM-SAGE-001 | ATOM+SAGE Framework Launch | ADR-001 | Active |
| ARCREF-CI-CHECKOUT-002 | CI Checkout v5 Upgrade | ADR-002 | Active |

---

## ATOM Trail Files

The ATOM trail is maintained in these locations:

| Location | Purpose | Format |
|----------|---------|--------|
| `~/.kenl/atom_trail.log` | Local runtime trail | `[timestamp] [ATOM-TAG] [platform] action` |
| `~/.kenl/saif-trail.log` | SAIF checkpoint trail | JSON lines |
| `/.sage-manifest.yaml` | SAGE configuration | YAML |

---

## How to Create ATOM Tags

### In PowerShell

```powershell
# Using KENL module
Write-AtomTrail -Type CFG -Action "Changed network settings"

# Using SAIF module
New-SAIFFlag -Action 'CONFIG' -Subject 'NETWORK' -Description 'Applied MTU optimization'
```

### In Shell Scripts

```bash
# Manual entry
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ATOM-CFG-$(date +%Y%m%d)-001] [Linux] Applied optimization" >> ~/.kenl/atom_trail.log
```

### In Documentation

Add to YAML frontmatter:
```yaml
---
title: Document Title
atom: ATOM-DOC-YYYYMMDD-NNN
---
```

---

## Validation

To verify ATOM tag integrity:

```bash
# Find all ATOM tags in repository
grep -rn "ATOM-" --include="*.md" --include="*.yaml" --include="*.ps1" --include="*.sh" | grep -v "Binary"

# Check for duplicate tags
grep -rn "ATOM-" --include="*.md" | awk -F: '{print $2}' | sort | uniq -d
```

---

## Next ATOM Tag Numbers

Use these for the next tag in each category (November 26, 2025):

| Type | Next Number | Example |
|------|-------------|---------|
| DOC | 003 | ATOM-DOC-20251126-003 |
| CFG | 001 | ATOM-CFG-20251126-001 |
| PROFILE | 002 | ATOM-PROFILE-20251126-002 |
| VERIFY | 001 | ATOM-VERIFY-20251126-001 |

---

**Last Updated:** 2025-11-26
**ATOM:** ATOM-DOC-20251126-002
