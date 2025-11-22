---
title: GitHub Copilot Instructions - Navigation Hub
date: 2025-11-18
atom: ATOM-DOC-20251118-013
classification: AGENT-NAVIGATION
status: active
audience: github-copilot
---

# GitHub Copilot Instructions - Navigation Hub

Welcome, Copilot! This directory contains context-specific instructions for working with KENL modules and subsystems.

**Purpose:** Provide module-specific context to GitHub Copilot for better code generation and assistance.

---

## 🚀 Quick Start

### For Code Changes

1. **Read main instructions:** [../.github/copilot-instructions.md](../copilot-instructions.md)
2. **Find module context:** [modules/](#module-specific-context) (this directory)
3. **Check custom agents:** [../agents/](../agents/) (specialized experts)
4. **Review standards:** [../../standards/](../../standards/)  
   _Note: Standards files are currently in the root directory. They will be moved to `docs/standards/` in Phase 5 of the refactoring plan._

---

## 📂 Directory Structure

```
.github/copilot-instructions/
├── README.md                    ← You are here
├── KENL-MODULES-CONTEXT.md      ← Overview of all 14 modules
│
├── modules/                     ← Per-module detailed context
│   ├── KENL0-system.md          ← System operations
│   ├── KENL1-framework.md       ← ATOM + SAGE core
│   ├── KENL2-gaming.md          ← Gaming configs
│   ├── KENL3-dev.md             ← Dev environment
│   ├── KENL4-monitoring.md      ← Monitoring
│   └── ... (KENL5-13)
│
└── examples/                    ← Task examples
    ├── adding-module.md
    ├── writing-playcard.md
    └── creating-adr.md
```

---

## 🎯 Module-Specific Context

### Available Modules

| Module | Purpose | Context Doc | Status |
|--------|---------|-------------|--------|
| KENL0 | System operations, PowerShell | modules/KENL0-system.md | TODO |
| KENL1 | ATOM + SAGE framework | modules/KENL1-framework.md | TODO |
| KENL2 | Gaming, Play Cards | [KENL2-gaming.md](KENL2-gaming.md) | ✅ |
| KENL3 | Dev environment, MCP | [KENL3-dev.md](KENL3-dev.md) | ✅ |
| KENL4 | Monitoring | modules/KENL4-monitoring.md | TODO |
| KENL5 | Backup/Restore | modules/KENL5-backup.md | TODO |
| KENL6 | Security | modules/KENL6-security.md | TODO |
| KENL7 | Networking | modules/KENL7-networking.md | TODO |
| KENL8 | Storage | modules/KENL8-storage.md | TODO |
| KENL9 | Cloud (Cloudflare) | modules/KENL9-cloud.md | TODO |
| KENL10 | Branding | modules/KENL10-branding.md | TODO |
| KENL11 | Community | modules/KENL11-community.md | TODO |
| KENL12 | Analytics | modules/KENL12-analytics.md | TODO |
| KENL13 | IWInstaller | modules/KENL13-iwinstaller.md | TODO |

### General Context

**For all modules:** Start with [KENL-MODULES-CONTEXT.md](KENL-MODULES-CONTEXT.md)

---

## 🛠️ Custom Agents

When to use custom agents instead of general Copilot:

### Documentation Expert
**Use when:**
- Writing or updating markdown documentation
- Formatting tables (especially critical!)
- Creating Mermaid diagrams
- Following visual standards

**Location:** [../agents/documentation-expert.md](../agents/documentation-expert.md)

### Shell Script Expert
**Use when:**
- Creating bash scripts
- Following KENL shell standards
- Adding ATOM tags to scripts
- Ensuring shellcheck compliance

**Location:** [../agents/shell-script-expert.md](../agents/shell-script-expert.md)

---

## 📋 Common Tasks

### Adding a New Module

1. **Read:** [examples/adding-module.md](examples/adding-module.md) (TODO)
2. **Create:** `modules/KENLX-<name>/` directory
3. **Add:** README.md with ATOM tag
4. **Update:** Root README.md module list
5. **Register:** `.sage-manifest.yaml` entry

### Creating a Play Card

1. **Read:** [examples/writing-playcard.md](examples/writing-playcard.md) (TODO)
2. **Reference:** [KENL2-gaming.md](KENL2-gaming.md)
3. **Template:** `modules/KENL2-gaming/play-cards/template.yaml`
4. **Validate:** YAML syntax
5. **Test:** Load in game environment

### Writing an ADR

1. **Read:** [examples/creating-adr.md](examples/creating-adr.md) (TODO)
2. **Template:** `governance/02-Decisions/ADR_TEMPLATE.md`
3. **ARCREF:** Create accompanying ARCREF if infrastructure change
4. **Link:** Cross-reference ARCREF ID in ADR
5. **Commit:** Use ATOM-DOC tag

---

## 🎓 Learning Resources

### Standards & Conventions

**Mandatory reading:**
- [Naming Conventions](../../docs/standards/NAMING-CONVENTIONS.md) (TODO: move to standards/)
- [Visual Elements Standard](../../docs/standards/VISUAL-ELEMENTS-STANDARD.md) (TODO: move to standards/)
- [Script Environment Tagging](../../docs/standards/SCRIPT-ENVIRONMENT-TAGGING-STANDARD.md) (TODO: move to standards/)

**Framework understanding:**
- [OWI Framework Overview](../../docs/frameworks/OWI_FRAMEWORK_OVERVIEW.md) (TODO: move to frameworks/)
- [SAIF Pattern Analysis](../../docs/frameworks/SAIF-PATTERN-ANALYSIS.md) (TODO: move to frameworks/)

---

## ⚠️ Important Reminders

### Do's
- ✅ Read module-specific context before making changes
- ✅ Use custom agents for specialized tasks
- ✅ Add ATOM tags to significant changes
- ✅ Follow Conventional Commits format
- ✅ Stay in user-space (`~/.local`, `~/.config`)
- ✅ Include rollback instructions

### Don'ts
- ❌ Modify system files (violates immutable base)
- ❌ Skip pre-commit validation
- ❌ Create files without updating document registry
- ❌ Use wrong module for functionality
- ❌ Forget to link ARCREF in ADR

---

## 🔗 External References

### Primary Documentation
- [Main Copilot Instructions](../copilot-instructions.md) - Complete guidelines
- [Contributing Guide](../../CONTRIBUTING.md) - Contribution workflow
- [Claude Instructions](../../CLAUDE.md) - For comparison/alignment

### User-Facing Docs
- [Documentation Hub](../../docs/00-START-HERE.md) - User navigation
- [README](../../README.md) - Project overview

---

## 📊 Coverage Status

**Module Context Coverage:**
- Complete: 2/14 (KENL2, KENL3)
- In Progress: 0/14
- TODO: 12/14

**Priority Order:**
1. KENL0-system (foundational)
2. KENL1-framework (core concepts)
3. KENL13-iwinstaller (high value)
4. KENL4-monitoring (debugging support)
5. KENL7-networking (common issues)
6. KENL5-13 (as needed)

---

## 🆘 Getting Help

### "Which module handles...?"

**System operations:** KENL0-system
**Framework/ATOM:** KENL1-framework
**Gaming:** KENL2-gaming
**Development:** KENL3-dev
**Monitoring:** KENL4-monitoring
**Backup:** KENL5-backup
**Security:** KENL6-security
**Networking:** KENL7-networking
**Storage:** KENL8-storage
**Cloud:** KENL9-cloud
**Branding:** KENL10-branding
**Community:** KENL11-community
**Analytics:** KENL12-analytics
**Installation:** KENL13-iwinstaller

### "How do I...?"

**See:** [Main instructions](../copilot-instructions.md) - Search for your question

---

**Last Updated:** 2025-11-18
**ATOM Tag:** ATOM-DOC-20251118-013
**Status:** Active (v1.0)

**ATOM-DOC-20251118-013**
