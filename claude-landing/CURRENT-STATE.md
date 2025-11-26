---
title: KENL Repository Status
updated: 2025-11-26
branch: copilot/update-repo-documentation-structure
classification: STATUS-UPDATE
atom: ATOM-STATUS-20251126-001
---

# Current Repository Status

**Last Updated:** 2025-11-26 02:45 UTC
**Branch:** `copilot/update-repo-documentation-structure`
**Active Session:** Documentation restructure and SAIF process implementation

---

## Recent Work Summary

### Session Focus: Documentation Restructure + SAIF Integration
**Started:** 2025-11-26
**Status:** In Progress

**Objectives:**
1. Restructure README to mirror BattleMedic pathways/walkthroughs
2. Create pathway-based Obsidian vault initialization
3. Add PowerShell profile functions for dynamic banners and current playcard
4. Update ATOM register and workflow documentation
5. Make repo a true SAIF process throughout

---

## New Documentation Structure

### Entry Points

| Document | Purpose | ATOM Tag |
|----------|---------|----------|
| [GETTING-STARTED.md](../GETTING-STARTED.md) | **Primary entry point** - Obsidian vault setup, pathway selection | ATOM-DOC-20251126-001 |
| [ATOM-REGISTER.md](../ATOM-REGISTER.md) | Complete ATOM tag tracking | ATOM-DOC-20251126-002 |
| [README.md](../README.md) | Overview with pathway selection | ATOM-DOC-20251126-003 |

### New Scripts

| Script | Purpose | ATOM Tag |
|--------|---------|----------|
| [scripts/Install-KenlProfile.ps1](../scripts/Install-KenlProfile.ps1) | PowerShell profile with banners | ATOM-PROFILE-20251126-001 |

---

## Pathway System

The new structure uses **pathways** to guide users:

```
🎮 Gaming     → KENL2-gaming      → Play Cards, Proton
💻 Development → KENL3-dev        → Claude Code, Ollama, MCP
🔧 Recovery   → BattleMedic      → Windows fixes, diagnostics
🚀 Migration  → KENL0-system     → Windows 10 EOL, dual-boot
```

Each pathway:
1. Imports relevant modules to Obsidian vault
2. Verifies environment/dependencies
3. Guides through setup checklist
4. Identifies optimal AI injection points

---

## PowerShell Profile Features

After running `Install-KenlProfile.ps1`:

```powershell
# Dynamic banner showing current context
Show-KenlBanner

# Output:
# ╔══════════════════════════════════════════════════════════════╗
# ║  KENL - Intent-Driven Infrastructure                         ║
# ╠══════════════════════════════════════════════════════════════╣
# ║  Platform:  Windows                                           ║
# ║  Context:   KENL2                                             ║
# ║  Playcard:  🎮 Halo Infinite                                  ║
# ║  ATOM:      ATOM-GAMING-20251126-001                          ║
# ║  SAIF:      SAIF-CONFIG-20251126-001                          ║
# ╚══════════════════════════════════════════════════════════════╝

# Navigate modules
kenl-switch 2         # Go to KENL2-gaming
kenl-switch battlemedic  # Go to BattleMedic

# Manage playcards
Set-CurrentPlaycard -Name "halo-infinite"
Get-CurrentPlaycard
Show-Playcards
```

---

## ATOM Trail Locations

| Location | Purpose | Format |
|----------|---------|--------|
| `~/.kenl/atom_trail.log` | Runtime ATOM entries | `[timestamp] [ATOM-TAG] [platform] action` |
| `~/.kenl/saif-trail.log` | SAIF checkpoint flags | JSON lines |
| `/ATOM-REGISTER.md` | Repository-wide tracking | Markdown table |

---

## Module Status

| Module | Status | Verified |
|--------|--------|----------|
| KENL0-system | ✅ Active | PowerShell modules working |
| KENL1-framework | ✅ Active | ATOM+SAGE core |
| KENL2-gaming | ✅ Active | Play Cards, research scripts |
| KENL3-dev | ✅ Active | MCP guides, Ollama setup |
| KENL4-monitoring | ✅ Active | ATOM DB architecture |
| KENL5-13 | ✅ Active | Various utilities |
| BattleMedic | ✅ Active | v2.1.0, SAIF compliant |

---

## Next Actions

### Immediate
1. ✅ Create GETTING-STARTED.md (pathway entry point)
2. ✅ Create Install-KenlProfile.ps1 (dynamic banners)
3. ✅ Create ATOM-REGISTER.md (tag tracking)
4. ✅ Update README.md (new structure)
5. [ ] Verify shell scripts execute correctly
6. [ ] Run code review
7. [ ] Commit changes

### Deferred
- Add Bash profile equivalent
- Create Obsidian plugin for ATOM integration
- Implement CTFWI handover automation

---

## Environment Status

**Platform:** CI Environment (GitHub Actions)
**Working Directory:** `/home/runner/work/kenl/kenl`
**Shell:** Bash
**PowerShell:** Not available in CI

---

## Documentation Index

**Orientation:**
- `GETTING-STARTED.md` - **START HERE** for new users
- `claude-landing/CURRENT-STATE.md` - This file (AI agents start here)
- `ATOM-REGISTER.md` - Tag tracking

**Modules:**
- `modules/KENL0-system/` - System operations, PowerShell modules
- `modules/KENL2-gaming/` - Play Cards, Proton optimization
- `modules/KENL3-dev/` - Development environments
- `modules/Surface_Pro_4_EoL_BattleMedic_v2.1/` - Windows recovery

**Governance:**
- `governance/02-Decisions/` - ADR documents
- `governance/mcp-governance/` - ARCREF artifacts

---

**Status:** 🔄 Work in progress - Documentation restructure

---

**ATOM:** ATOM-STATUS-20251126-001
**Last Updated:** 2025-11-26 02:45 UTC
