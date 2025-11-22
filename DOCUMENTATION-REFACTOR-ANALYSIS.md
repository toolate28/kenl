---
title: Documentation Structure Refactoring - SAIF Compliance Analysis
date: 2025-11-18
atom: ATOM-DOC-20251118-009
classification: ANALYSIS
status: in-progress
---

# KENL Documentation Refactoring Analysis
## SAIF-Compliant Structure for Obsidian-Wall Navigation

**Purpose:** Comprehensive analysis of current documentation structure and roadmap for SAIF-compliant refactoring that creates an "Obsidian-wall" navigation pattern for action-deciding user paths.

**Target Outcome:** Transform documentation into a focused, link-oriented structure that guides users from high-level intent to specific actions with minimal cognitive overhead.

---

## Executive Summary

### Current State (Inventory)

**Root Level (28 MD files):**
- Mix of guides, standards, audits, reviews, and historical documents
- No clear entry point hierarchy
- Heavy duplication between root and subdirectories
- Unclear versioning and status

**Subdirectories:**
- `docs/` (6 files) - Unclear purpose, overlaps with root
- `claude-landing/` (22 files) - Agent-facing, well-organized
- `case-studies/` (11 files) - Good structure but no version control
- `governance/` - Well-structured (ARCREF + ADR)

**Document Registry:**
- Located: `.kenl/document-registry.json`
- Last updated: 2025-11-05
- Only tracks 16 documents (out of ~67 total MD files)
- **Critical gap:** Missing most root-level documentation

### Problems Identified

1. **Root-level pollution** - 28 MD files with unclear hierarchy
2. **Registry incomplete** - Only 24% of documentation tracked
3. **No versioning** - Case studies lack version control
4. **Agent confusion** - Copilot vs Claude directories need optimization
5. **Link rot risk** - No systematic link validation
6. **SAIF non-compliance** - Many docs lack SAIF flags or proper ATOM tags
7. **Obsidian-wall missing** - No clear navigation paths from intent → action

### Recommended Structure (SAIF-Compliant)

```
kenl/
├── README.md                    # Entry point (keeps root clean)
├── CLAUDE.md                    # Primary AI agent instructions
├── CONTRIBUTING.md              # Contribution guide
├── SECURITY.md                  # Security policy
├── LICENSE                      # License file
├── CODE_OF_CONDUCT.md           # Community standards
│
├── docs/                        # **USER-FACING** documentation
│   ├── 00-START-HERE.md         # Navigation hub (Obsidian-wall entry)
│   ├── guides/                  # How-to guides
│   │   ├── installation/        # Installation walkthroughs
│   │   ├── configuration/       # Configuration guides
│   │   └── workflows/           # Workflow documentation
│   ├── standards/               # Standards and conventions
│   │   ├── VISUAL-ELEMENTS-STANDARD.md
│   │   ├── NAMING-CONVENTIONS.md
│   │   ├── OWI_METADATA_STANDARD.md
│   │   └── SCRIPT-ENVIRONMENT-TAGGING-STANDARD.md
│   ├── frameworks/              # Framework documentation
│   │   ├── OWI_FRAMEWORK_OVERVIEW.md
│   │   ├── SAIF-PATTERN-ANALYSIS.md
│   │   └── ATOM-overview.md
│   └── reference/               # Reference materials
│       ├── WORKSPACE.md
│       └── TERMINOLOGY.md
│
├── .github/                     # GitHub configuration
│   ├── agents/                  # Custom agent profiles
│   │   ├── README.md            # Agent directory index
│   │   ├── documentation-expert.md
│   │   └── shell-script-expert.md
│   ├── copilot-instructions/    # Copilot-specific context
│   │   └── KENL-MODULES-CONTEXT.md
│   ├── copilot-instructions.md  # Main Copilot instructions
│   └── workflows/               # CI/CD pipelines
│
├── claude-landing/              # **CLAUDE-FACING** (AI agent orientation)
│   ├── README.md                # Claude entry point
│   ├── CURRENT-STATE.md         # Environment snapshot
│   ├── QUICK-REFERENCE.md       # Common commands/paths
│   ├── RECENT-WORK.md           # Session history
│   └── guides/                  # Agent-specific guides
│
├── governance/                  # **GOVERNANCE** artifacts
│   ├── 02-Decisions/            # ADRs (Architectural Decision Records)
│   ├── mcp-governance/          # ARCREF artifacts
│   └── audits/                  # **NEW** - Audit reports
│       ├── AUDIT-FINDINGS-2025-11-16.md
│       ├── AUDIT_REPORT_LICENSE_LEGAL.md
│       └── versioning.yaml      # Audit version tracking
│
├── case-studies/                # Real-world scenarios
│   ├── README.md                # Case study index
│   ├── RWS-*.md                 # Real-world scenarios
│   └── .versions/               # **NEW** - Version history
│       └── case-study-versions.yaml
│
├── reports/                     # **NEW** - Analysis and reviews
│   ├── README.md                # Reports index
│   ├── COMPREHENSIVE-REVIEW-SUMMARY.md
│   ├── BLIND-SPOTS-AND-UNIFIED-ROADMAP.md
│   ├── evaluation_summary.md
│   └── .versions/               # Version tracking
│
├── historical/                  # **NEW** - Archive
│   ├── README.md                # Archive index
│   ├── ABOUT-OUR-COLLABORATION.md
│   ├── ACKNOWLEDGMENTS.md
│   ├── PR-DAY-ZERO-DESIGN.md
│   └── START-HERE-COMPREHENSIVE-REVIEW.md
│
└── .kenl/                       # Internal metadata
    ├── document-registry.json   # Document tracking (MUST be updated)
    └── link-validation.log      # Link health tracking
```

---

## SAIF-Compliant Navigation Pattern

### The "Obsidian-Wall" Concept

**Definition:** A documentation structure where each document has:
1. **Clear entry point** - Obvious "start here" for each audience
2. **Contextual links** - Next steps visible but not intrusive
3. **Footnote depth** - Additional context scroll-accessible, not in-frame
4. **Decision points** - Clear action-oriented choices
5. **SAIF flags** - Trackable completion markers

### Navigation Hierarchy (User Personas)

#### Persona 1: New User (Gaming-focused)
```
Entry: README.md
  └─→ docs/00-START-HERE.md
      ├─→ "I want to game" → docs/guides/installation/BAZZITE-DX-IWI-INSTALLATION-SAIF.md
      │   └─→ Phase 0 → Phase 1 → ... → Phase 6 (SAIF flags at each phase)
      ├─→ "I want to optimize" → case-studies/RWS-05-HALO-INFINITE.md
      └─→ "I want to understand" → docs/frameworks/OWI_FRAMEWORK_OVERVIEW.md
```

#### Persona 2: Developer (Contributor)
```
Entry: CONTRIBUTING.md
  └─→ "Understand structure" → docs/00-START-HERE.md
      ├─→ "Write code" → docs/standards/NAMING-CONVENTIONS.md
      ├─→ "Use AI tools" → CLAUDE.md OR .github/copilot-instructions.md
      ├─→ "Create governance" → governance/02-Decisions/ADR_TEMPLATE.md
      └─→ "Run workflows" → .github/workflows/README.md (needs creation)
```

#### Persona 3: AI Agent (Claude)
```
Entry: CLAUDE.md
  └─→ claude-landing/README.md
      ├─→ "Current state" → CURRENT-STATE.md
      ├─→ "Commands" → QUICK-REFERENCE.md
      ├─→ "Recent work" → RECENT-WORK.md
      └─→ "Terminology" → TERMINOLOGY.md
```

#### Persona 4: AI Agent (Copilot)
```
Entry: .github/copilot-instructions.md
  └─→ "Module context" → .github/copilot-instructions/KENL-MODULES-CONTEXT.md
      ├─→ "Use custom agent" → .github/agents/README.md
      │   ├─→ documentation-expert.md
      │   └─→ shell-script-expert.md
      └─→ "Understand ATOM" → docs/frameworks/ATOM-overview.md (needs creation)
```

---

## Document Registry Updates Required

### Current Registry Stats
- **Total documents tracked:** 16
- **Active:** 7
- **Archived:** 7
- **Superseded:** 2

### Missing Documents (Need Registry Entries)

**Root Level (24 missing):**
- ALIGNED-SIGHT.md
- AI-INTEGRATION-GUIDE.md
- AUDIT-FINDINGS-2025-11-16.md
- AUDIT_REPORT_LICENSE_LEGAL.md
- BAZZITE-DX-IWI-INSTALLATION-SAIF.md
- BLIND-SPOTS-AND-UNIFIED-ROADMAP.md
- CHANGELOG.md
- CLEANUP-EXECUTION-PLAN.md
- CODE_OF_CONDUCT.md
- COMPREHENSIVE-REVIEW-SUMMARY.md
- CONTRIBUTING.md
- GITHUB-COPILOT-AGENT-BRIEFING.md
- NAMING-CONVENTIONS.md
- OWI_FRAMEWORK_OVERVIEW.md
- OWI_METADATA_STANDARD.md
- PR-DAY-ZERO-DESIGN.md
- PROMPT-ANALYSIS-AND-OPTIMIZATION.md
- SAIF-PATTERN-ANALYSIS.md
- SCRIPT-ENVIRONMENT-TAGGING-STANDARD.md
- SECURITY.md
- VISUAL-ELEMENTS-STANDARD.md
- WORKSPACE.md
- evaluation_summary.md
- README-DOGFOODING-SECTION.md

**Subdirectories (43 missing):**
- All 22 claude-landing/ files
- All 11 case-studies/ files
- All 6 docs/ files
- Selected governance/ files

### Registry Update Strategy

1. **Phase 1:** Add all root-level documentation (24 files)
2. **Phase 2:** Add case-studies with version tracking (11 files)
3. **Phase 3:** Add agent-facing docs (claude-landing, copilot)
4. **Phase 4:** Add versioned reports/audits
5. **Phase 5:** Implement automated registry updates via pre-commit hook

---

## Workflow Analysis

### GitHub Actions Review

**Files:**
- `.github/workflows/ci.yml` - Pre-commit, CodeQL, pytest
- `.github/workflows/release.yml` - Semantic release
- `.github/workflows/validate.yml` - Validation workflows
- `.github/workflows/atom-example.yml.disabled` - Example ATOM workflow

**Issues Found:**
1. **No workflow documentation** - Missing `.github/workflows/README.md`
2. **No link validation** - Should add markdown-link-check action
3. **No registry sync** - Document registry not auto-updated
4. **No SAIF validation** - Missing validation for SAIF flag format

**Recommendations:**
1. Create `.github/workflows/README.md` explaining each workflow
2. Add `markdown-link-check` action to validate internal/external links
3. Add pre-commit hook to update document-registry.json
4. Add SAIF flag format validator
5. Enable `.github/workflows/atom-example.yml` with proper configuration

---

## KENL13 (iWinstaller) Translation Insights

### Current State: BAZZITE-DX-IWI-INSTALLATION-SAIF.md

**Structure:**
- 6 phases with clear SAIF flags
- Hardware-specific targeting
- PowerShell integration for Windows pre-testing
- ATOM trail integration

**Translation to KENL13:**

1. **Modularize phases** → Each phase becomes a separate module/tool
2. **Generalize hardware** → Support multiple hardware profiles
3. **Abstract OS** → Windows 10 → Bazzite-DX migration path
4. **Automate validation** → Each SAIF flag triggers automated tests
5. **Evidence collection** → Screenshots, logs, metrics at each phase

**Recommended KENL13 Structure:**
```
modules/KENL13-iwinstaller/
├── README.md                    # Overview and entry point
├── phases/
│   ├── phase0-preinstall.sh     # Pre-installation testing
│   ├── phase1-partitioning.sh   # Disk partitioning
│   ├── phase2-installation.sh   # OS installation
│   ├── phase3-optimization.sh   # Hardware optimization
│   ├── phase4-validation.sh     # Critical tests
│   ├── phase5-atom.sh           # ATOM trail integration
│   └── phase6-handover.sh       # Documentation handover
├── profiles/
│   ├── hardware-profiles.yaml   # Hardware configurations
│   └── windows-profiles.yaml    # Windows 10 migration configs
├── tools/
│   ├── network-baseline.ps1     # PowerShell network testing
│   ├── disk-analyzer.sh         # Disk layout analysis
│   └── saif-validator.sh        # SAIF flag validation
└── docs/
    ├── INSTALLATION-GUIDE.md    # User-facing guide
    └── DEVELOPER-GUIDE.md       # Developer documentation
```

---

## Agent-Facing Directory Optimization

### Claude Landing (claude-landing/)

**Current State:**
- 22 files, well-organized
- Good mix of orientation, reference, and session tracking

**Recommendations:**
1. ✅ **Keep current structure** - Already optimized
2. ✅ **Add README.md** - Create entry point with navigation
3. ⚠️ **Consolidate guides** - Move technical guides to main docs/
4. ✅ **Version RECENT-WORK.md** - Archive old sessions

**Proposed Changes:**
```
claude-landing/
├── README.md                    # NEW - Entry point
├── CURRENT-STATE.md             # Keep
├── QUICK-REFERENCE.md           # Keep
├── RECENT-WORK.md               # Keep, add versioning
├── TERMINOLOGY.md               # Keep
├── orientation/                 # NEW - Consolidate orientation docs
│   ├── AGENT-FACING-CONTENT-DESIGN.md
│   ├── AI-MAINTENANCE-GUIDE.md
│   └── LONG-TASK-PATTERN.md
├── standards/                   # NEW - Agent-specific standards
│   ├── CLI-FORMATTING-STANDARDS.md
│   ├── CLI-OUTPUT-GUIDE.md
│   └── MARKDOWN-TABLE-FORMATTING.md
└── sessions/                    # NEW - Session archives
    └── 2025-11/
        └── SESSION-2025-11-16-NETWORK-LOGDY.md
```

### Copilot Instructions (.github/copilot-instructions/)

**Current State:**
- 3 files: KENL-MODULES-CONTEXT.md, KENL2-gaming.md, KENL3-dev.md
- Missing module context for KENL0, KENL1, KENL4-13

**Recommendations:**
1. ⚠️ **Complete module contexts** - Add KENL0, KENL1, KENL4-13
2. ✅ **Create index** - README.md with navigation
3. ⚠️ **Add examples** - Common task examples per module
4. ⚠️ **Link to agents** - Reference custom agents from .github/agents/

**Proposed Changes:**
```
.github/copilot-instructions/
├── README.md                    # NEW - Navigation hub
├── KENL-MODULES-CONTEXT.md      # Keep (overview)
├── modules/                     # NEW - Per-module details
│   ├── KENL0-system.md
│   ├── KENL1-framework.md
│   ├── KENL2-gaming.md          # Move here
│   ├── KENL3-dev.md             # Move here
│   ├── KENL4-monitoring.md      # NEW
│   └── ... (KENL5-13)
└── examples/                    # NEW - Task examples
    ├── adding-module.md
    ├── writing-playcard.md
    └── creating-adr.md
```

### Custom Agents (.github/agents/)

**Current State:**
- 3 files: README.md, documentation-expert.md, shell-script-expert.md
- Good structure, well-documented

**Recommendations:**
1. ✅ **Keep current structure** - Already good
2. ⚠️ **Add agents** - Consider Python expert, YAML expert
3. ✅ **Cross-reference** - Link from copilot-instructions
4. ⚠️ **Usage metrics** - Track which agents are most useful

---

## Time-Relevant Observations

### Critical Path Items (Next 7 Days)

1. **Document Registry Sync** (Priority: CRITICAL)
   - Current coverage: 24% (16/67 files)
   - Missing: All case studies, root-level docs, agent docs
   - **Impact:** No version control, no ATOM trail, no link validation
   - **Effort:** 4-6 hours (can be partially automated)

2. **Workflow Documentation** (Priority: HIGH)
   - Missing: Workflow README, SAIF validators
   - **Impact:** Contributors don't understand CI/CD
   - **Effort:** 2-3 hours

3. **Link Validation** (Priority: HIGH)
   - No automated checking
   - **Impact:** Broken links degrade user experience
   - **Effort:** 1-2 hours (add GitHub Action)

4. **Obsidian-Wall Entry Points** (Priority: MEDIUM)
   - Create docs/00-START-HERE.md
   - Create claude-landing/README.md
   - Create .github/copilot-instructions/README.md
   - **Impact:** Improves discoverability
   - **Effort:** 3-4 hours

5. **Case Study Versioning** (Priority: MEDIUM)
   - Add .versions/ directories
   - Create versioning.yaml
   - **Impact:** Enables safe editing
   - **Effort:** 2-3 hours

### Non-Critical But Valuable

1. **KENL13 Module Creation** - Can wait until design finalized
2. **Python/YAML Custom Agents** - Nice to have, not urgent
3. **Historical Archive** - Low priority, can defer
4. **Report Consolidation** - Can be done iteratively

---

## ATOM Trail Verification

### Checking Recent Commits

```bash
git log --all --oneline -20 | grep -E "ATOM-"
```

**Result:** Only 1 recent commit has ATOM tag (db02ada)

**Issue:** ATOM tags not consistently applied

**Recommendation:**
1. Add git commit template (.gitmessage) enforcement
2. Add pre-commit hook to validate ATOM tag format
3. Require ATOM tags for documentation changes

### Verifying ATOM Tag Format

**Standard Format:** `ATOM-{TYPE}-{YYYYMMDD}-{NNN}`

**Types Found in Registry:**
- ATOM-DOC-* (documentation)
- ATOM-CFG-* (configuration)
- ATOM-STATUS-* (status reports)
- ATOM-RESEARCH-* (research)
- ATOM-DEPLOY-* (deployment)

**Missing Types:**
- ATOM-REFACTOR-* (for this PR)
- ATOM-SAIF-* (SAIF compliance)

**Recommendation:** Add ATOM-REFACTOR-20251118-001 to this PR

---

## Link and Reference Audit

### Current Link Health (Not Verified)

**No automated checking in place**

**Manual Spot Check Required:**
1. README.md → Module links
2. CLAUDE.md → claude-landing/ links
3. copilot-instructions.md → Module links
4. Case studies → External resource links

**Recommendation:** Add `markdown-link-check` GitHub Action

### Script and Tool References

**Scripts in Repository:**
- `make_kenl_scaffold_zip.sh` - Root level
- `scripts/bootstrap.sh` - Mentioned in docs
- `scripts/` directory - Contains utility scripts

**Recommendation:**
1. Create scripts/README.md documenting each script
2. Add version info to script headers
3. Link scripts from docs where referenced

---

## Task Delegation Plan

### Tasks for Claude Desktop/CLI

Given the scope and complexity, the following tasks should be delegated to Claude Desktop or CLI:

#### Task 1: Document Registry Complete Update
**Scope:** Update `.kenl/document-registry.json` with all 67 documentation files
**Deliverables:**
- Updated registry with proper ATOM tags
- Version history entries
- Status classification (active/archive/superseded)
**Estimated Effort:** 4-6 hours

#### Task 2: Create Navigation Hub Documents
**Scope:** Create entry point documents for Obsidian-wall navigation
**Deliverables:**
- `docs/00-START-HERE.md` (user-facing)
- `claude-landing/README.md` (Claude-facing)
- `.github/copilot-instructions/README.md` (Copilot-facing)
- `.github/workflows/README.md` (workflow documentation)
**Estimated Effort:** 3-4 hours

#### Task 3: Link Validation Setup
**Scope:** Add automated link checking to CI/CD
**Deliverables:**
- New GitHub Action for markdown-link-check
- Initial link health report
- Fix broken links (if any)
**Estimated Effort:** 2-3 hours

#### Task 4: Case Study Versioning System
**Scope:** Implement version tracking for case studies
**Deliverables:**
- `case-studies/.versions/case-study-versions.yaml`
- Version history for each case study
- Update process documentation
**Estimated Effort:** 2-3 hours

#### Task 5: Complete Copilot Module Contexts
**Scope:** Create missing module context documents
**Deliverables:**
- KENL0-system.md
- KENL1-framework.md
- KENL4-monitoring.md through KENL13
**Estimated Effort:** 4-5 hours

### Tasks I Can Handle (Copilot)

1. **Initial structure creation** - Create directory structure and skeleton files
2. **Registry template** - Create updated registry template
3. **Pre-commit hooks** - Add ATOM tag validation hook
4. **Workflow validation** - Review existing workflows for issues
5. **This analysis document** - Complete and commit

---

## Implementation Phases

### Phase 1: Foundation (Week 1)
- [ ] Complete this analysis document
- [ ] Create directory structure (reports/, historical/, new subdirs)
- [ ] Update document registry (add all 67 files)
- [ ] Create navigation hub documents

### Phase 2: Agent Optimization (Week 2)
- [ ] Complete copilot module contexts
- [ ] Reorganize claude-landing/
- [ ] Create .github/workflows/README.md
- [ ] Add custom agents (Python, YAML)

### Phase 3: Automation (Week 3)
- [ ] Add link validation GitHub Action
- [ ] Add ATOM tag validation pre-commit hook
- [ ] Add SAIF flag validator
- [ ] Implement registry auto-update

### Phase 4: Content Migration (Week 4)
- [ ] Move root-level docs to appropriate subdirectories
- [ ] Version case studies
- [ ] Archive historical documents
- [ ] Consolidate reports

### Phase 5: KENL13 Translation (Week 5+)
- [ ] Design KENL13 module structure
- [ ] Extract phases from BAZZITE-DX-IWI-INSTALLATION-SAIF.md
- [ ] Create modular tooling
- [ ] Implement evidence collection

---

## Success Metrics

### Quantitative
- **Registry coverage:** 24% → 100%
- **Link health:** Unknown → 100% valid
- **ATOM tag compliance:** <5% → 100%
- **Navigation depth:** Unknown → Max 3 clicks from entry point

### Qualitative
- **User feedback:** Can users find what they need in <2 minutes?
- **Agent effectiveness:** Do AI agents understand structure?
- **Maintenance burden:** Reduced cognitive load for updates?
- **SAIF compliance:** All operations have clear flags?

---

## Appendix: SAIF Flag Examples

### Installation Walkthrough
```markdown
## Phase 0: Pre-Installation Testing
**SAIF:** `SAIF-VALIDATE-PREINSTALL-20251117-001`
**Result:** PowerShell network module operational, baseline established
```

### Configuration Changes
```markdown
## Applying Network Optimization
**SAIF:** `SAIF-NETWORK-OPTIMIZE-20251117-002`
**Result:** MTU set to 1492, latency reduced by 15%
```

### Documentation Updates
```markdown
## Updated Document Registry
**SAIF:** `SAIF-REGISTRY-SYNC-20251118-001`
**Result:** All 67 documentation files tracked with ATOM tags
```

---

## Next Steps

1. **Review this analysis** - Ensure alignment with project goals
2. **Delegate tasks** - Assign to Claude Desktop/CLI as appropriate
3. **Create GitHub issues** - One per phase for tracking
4. **Start Phase 1** - Begin with foundation work
5. **Report progress** - Use report_progress tool after each phase completion

---

**ATOM-REFACTOR-20251118-001**
