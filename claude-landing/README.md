# Claude Landing Zone

**Purpose:** Immediate orientation documents for any Claude instance (Claude Code, Claude Desktop, etc.) working on the KENL project.

## CTF Flag System

**These documents contain "flags" - documented expectations about the current state.**

When resuming work, you should **"capture the flags"** by validating each expectation against reality:

- ✅ **Flag validates:** Documented state matches reality → proceed
- 🚩 **Flag fails:** Mismatch detected → investigate before proceeding
- ⚠️ **Flag partial:** Some aspects match, some don't → use judgment

**Flags range from simple (typos, file paths) to complex (performance metrics, hidden edge cases).**

**See:** RECENT-WORK.md "CTF Flag Capture Protocol" for detailed validation checklist.

---

## Quick Start

**First time here?** Read these in order:

1. **CURRENT-STATE.md** - Where we are right now (platform, branch, phase)
2. **RECENT-WORK.md** - What was just completed (last session's work)
3. **NEXT-STEPS.md** - Immediate actionable tasks
4. **HARDWARE.md** - Hardware specs and configuration
5. **QUICK-REFERENCE.md** - Common commands, paths, key files

## Supporting Documents

- **TESTING-RESULTS.md** - Recent validation results (network, modules, games)
- **MIGRATION-PLAN.md** - Windows → Bazzite migration roadmap
- **OBSIDIAN-QUICK-START.md** - Local Obsidian vault setup for SAGE methodology

## Update Frequency

These documents should be updated:
- **After each major session** - Update RECENT-WORK.md and CURRENT-STATE.md
- **When state changes** - Branch changes, platform migrations, hardware updates
- **After testing** - Add results to TESTING-RESULTS.md
- **Before long breaks** - Ensure NEXT-STEPS.md is current

## ATOM Tracking

All documents in this directory use ATOM tags for traceability:
- Format: `ATOM-DOC-YYYYMMDD-NNN`
- See: `atom-sage-framework/README.md` for details

---

## 🗂️ Directory Organization

```
claude-landing/
├── README.md (this file)      ← Start here
├── CURRENT-STATE.md            ← System snapshot
├── QUICK-REFERENCE.md          ← Commands/paths
├── RECENT-WORK.md              ← Session history
├── NEXT-STEPS.md               ← Actionable tasks
├── HARDWARE.md                 ← Hardware specs
├── TERMINOLOGY.md              ← KENL vocabulary
│
├── orientation/                ← Orientation guides
├── standards/                  ← Agent-specific standards
├── sessions/                   ← Session archives
└── guides/                     ← Technical guides
```

**For detailed navigation, see [Enhanced Navigation Guide](../DOCUMENTATION-REFACTOR-ANALYSIS.md#agent-facing-directory-optimization)**

---

*Last Updated: 2025-11-18*
*ATOM: ATOM-DOC-20251118-012*
