---
title: Governance - Decision Records and Architecture References
date: 2025-11-18
atom: ATOM-DOC-20251118-016
classification: GOVERNANCE
status: active
---

# KENL Governance Documentation

This directory contains governance artifacts for architectural decisions and infrastructure changes.

**Purpose:** Maintain traceable, evidence-based decision-making with rollback safety.

---

## 📂 Directory Structure

```
governance/
├── README.md                    ← You are here
├── 02-Decisions/                ← ADRs (Architectural Decision Records)
│   ├── ADR_TEMPLATE.md          ← Template for new ADRs
│   └── ADR-*.md                 ← Individual decision records
├── mcp-governance/              ← ARCREF (Architecture Reference artifacts)
│   ├── ARCREF_TEMPLATE.yaml     ← Template for new ARCREFs
│   └── ARCREF-*.yaml            ← Individual architecture references
└── audits/                      ← Audit reports (NEW)
    ├── AUDIT-FINDINGS-*.md
    └── versioning.yaml          ← Audit version tracking
```

---

## 🎯 Governance System Overview

### Dual Governance Requirement

**CRITICAL:** Infrastructure and architectural changes MUST have both:
1. **ARCREF artifact** - Technical implementation details
2. **ADR document** - Decision rationale and context

### When to Create Governance Documents

**Required for:**
- ✅ MCP tool integrations
- ✅ Cloud/platform changes
- ✅ Repository-level infrastructure
- ✅ Build system modifications
- ✅ CI/CD pipeline changes
- ✅ Security policy changes
- ✅ Technology choices
- ✅ Pattern implementations

**Not required for:**
- ❌ Documentation updates (unless framework changes)
- ❌ Bug fixes (unless architectural impact)
- ❌ Minor refactoring
- ❌ Test additions

---

## 📋 ADR - Architectural Decision Records

### Purpose
Document **why** architectural decisions were made, not just **what** was decided.

### Location
`governance/02-Decisions/`

### Template
[ADR_TEMPLATE.md](02-Decisions/ADR_TEMPLATE.md)

### Format
```markdown
# ADR-NNN: <Title>

**Status:** proposed | accepted | deprecated | superseded
**Date:** YYYY-MM-DD
**ATOM Tag:** ATOM-ADR-YYYYMMDD-NNN
**ARCREF ID:** ARCREF-YYYYMMDD-NNN (if applicable)

## Context
<Problem statement and background>

## Decision
<What was decided>

## Rationale
<Why this decision was made>

## Consequences
**Positive:**
- Benefit 1
- Benefit 2

**Negative:**
- Trade-off 1
- Trade-off 2

## Alternatives Considered
<Other options and why rejected>

## References
- [Link to related docs]
```

### Status Lifecycle
```
proposed → accepted → deprecated/superseded
```

---

## 🔧 ARCREF - Architecture Reference Artifacts

### Purpose
Document **how** to implement infrastructure changes with rollback safety.

### Location
`governance/mcp-governance/`

### Template
[ARCREF_TEMPLATE.yaml](mcp-governance/ARCREF_TEMPLATE.yaml)

### Format
```yaml
arcref_id: ARCREF-YYYYMMDD-NNN
title: <Short Title>
atom_tag: ATOM-CFG-YYYYMMDD-NNN
status: active
category: mcp-tool | cloud | infrastructure | cicd

# Implementation details
implementation:
  description: <What is being implemented>
  steps:
    - step: 1
      action: <Command or action>
      validation: <How to verify>

# Rollback plan (REQUIRED)
rollback:
  description: <How to undo>
  steps:
    - step: 1
      action: <Rollback command>
      validation: <How to verify rollback>

# Testing (REQUIRED)
test_verification:
  - test: <Test name>
    command: <Test command>
    expected: <Expected result>

# Traceability
related_adr: ADR-NNN
related_prs:
  - PR-123
```

---

## 🔍 Finding Governance Documents

### By Topic

**MCP Integration:**
- ADRs: Search "MCP" in `02-Decisions/`
- ARCREFs: Check `mcp-governance/ARCREF-*-mcp-*.yaml`

**CI/CD Changes:**
- ADRs: Search "workflow" or "action" in `02-Decisions/`
- ARCREFs: Check `mcp-governance/ARCREF-*-cicd-*.yaml`

**Cloud/Platform:**
- ADRs: Search "cloudflare" or "platform" in `02-Decisions/`
- ARCREFs: Check `mcp-governance/ARCREF-*-cloud-*.yaml`

### By Status

**Active decisions:**
```bash
grep -r "status: accepted" governance/02-Decisions/
```

**Superseded decisions:**
```bash
grep -r "status: superseded" governance/02-Decisions/
```

### By Date

**Recent decisions:**
```bash
ls -lt governance/02-Decisions/ADR-*.md | head -10
```

---

## ✍️ Creating New Governance Documents

### Workflow

1. **Determine if governance required** (see checklist above)
2. **Create ARCREF first** (technical details)
   ```bash
   cp governance/mcp-governance/ARCREF_TEMPLATE.yaml \
      governance/mcp-governance/ARCREF-20251118-001.yaml
   # Edit with implementation details
   ```
3. **Create ADR** (decision rationale)
   ```bash
   cp governance/02-Decisions/ADR_TEMPLATE.md \
      governance/02-Decisions/ADR-001-my-decision.md
   # Edit with context and rationale
   ```
4. **Link ARCREF in ADR** (cross-reference)
5. **Test implementation** (follow ARCREF steps)
6. **Submit PR** (include both documents)
7. **Update status** (once accepted)

---

## 📊 Governance Metrics

### Current Stats (TODO: Automate)
- **Total ADRs:** Count files in `02-Decisions/`
- **Active ADRs:** Count status: accepted
- **Total ARCREFs:** Count files in `mcp-governance/`
- **Active ARCREFs:** Count status: active

### Quality Metrics
- **ADR/ARCREF ratio:** Should be ~1:1 for infrastructure changes
- **Rollback success rate:** Track successful rollbacks
- **Implementation accuracy:** Measure deviations from ARCREF

---

## 🔗 Related Documentation

### Templates
- [ADR Template](02-Decisions/ADR_TEMPLATE.md)
- [ARCREF Template](mcp-governance/ARCREF_TEMPLATE.yaml)

### Standards
**Note:** The following standards links will work after Phase 5 of the documentation refactor (see DOCUMENTATION-REFACTOR-ANALYSIS.md). Until then, these files are in the repository root.
- [OWI Metadata Standard](../docs/standards/OWI_METADATA_STANDARD.md)
- [Naming Conventions](../docs/standards/NAMING-CONVENTIONS.md)

### Guides
- [Contributing Guide](../CONTRIBUTING.md)
- [Copilot Instructions](../.github/copilot-instructions.md)

---

## ⚠️ Common Mistakes

### Don't:
- ❌ Create ADR without ARCREF (for infrastructure changes)
- ❌ Skip rollback plan in ARCREF
- ❌ Forget to link ARCREF ID in ADR
- ❌ Use wrong status (must follow lifecycle)
- ❌ Create governance for minor changes
- ❌ Skip test verification steps

### Do:
- ✅ Create both ARCREF and ADR for infrastructure
- ✅ Include complete rollback instructions
- ✅ Cross-reference between ARCREF and ADR
- ✅ Follow status lifecycle
- ✅ Use judgment on when governance is needed
- ✅ Test thoroughly before marking accepted

---

## 🆘 Getting Help

### "Do I need governance for...?"

**Ask yourself:**
1. Does it change infrastructure? → Yes: ARCREF + ADR
2. Does it affect architecture? → Yes: ADR minimum
3. Is it a technology choice? → Yes: ADR minimum
4. Is it a bug fix? → Usually no
5. Is it documentation? → Usually no

**Still unsure?** Open a discussion on GitHub

### "Which template do I use?"

**For infrastructure changes:** ARCREF + ADR
**For architectural decisions:** ADR only
**For implementation details:** ARCREF only (if ADR exists)

### "How do I supersede an ADR?"

1. Create new ADR with updated decision
2. Update old ADR status to "superseded"
3. Add `superseded_by: ADR-NNN` to old ADR
4. Link old ADR in new ADR context

---

## ✅ Quality Checklist

### For ADRs
- [ ] Status is one of: proposed, accepted, deprecated, superseded
- [ ] Date is present in YYYY-MM-DD format
- [ ] ATOM tag present: ATOM-ADR-YYYYMMDD-NNN
- [ ] ARCREF ID linked (if infrastructure change)
- [ ] Context section explains problem
- [ ] Decision section clear and specific
- [ ] Rationale explains why
- [ ] Consequences listed (positive and negative)
- [ ] Alternatives considered documented

### For ARCREFs
- [ ] Unique ARCREF ID: ARCREF-YYYYMMDD-NNN
- [ ] ATOM tag present: ATOM-CFG-YYYYMMDD-NNN
- [ ] Status is active, deprecated, or superseded
- [ ] Implementation steps are clear and testable
- [ ] Rollback plan is complete and tested
- [ ] Test verification steps provided
- [ ] Related ADR linked
- [ ] Category appropriate

---

## 🔄 Maintenance

### Regular Reviews
- **Frequency:** Quarterly
- **Review:** All active ADRs and ARCREFs
- **Update:** Supersede outdated decisions
- **Archive:** Move historical documents

### Version Control
All governance documents are version controlled via git.
- Changes tracked in commit history
- ATOM tags enable traceability
- Status updates require PR

---

**Last Updated:** 2025-11-18
**ATOM Tag:** ATOM-DOC-20251118-016
**Next Review:** 2026-01-18

**ATOM-DOC-20251118-016**
