---
title: Obsidian Quick Start for KENL
date: 2025-11-15
atom: ATOM-DOC-20251115-001
status: active
---

# Obsidian Quick Start - KENL SAGE Integration

**Purpose:** Get Obsidian vault set up locally to visualize KENL's SAGE methodology (System-Aware Guided Evolution) and ATOM trails.

---

## Installation (5 minutes)

### On Bazzite/Linux

```bash
# Install Obsidian via Flatpak
flatpak install flathub md.obsidian.Obsidian

# Launch
flatpak run md.obsidian.Obsidian
```

### On Windows (Current Platform)

```powershell
# Download from Obsidian website
Start-Process "https://obsidian.md/download"

# Or install via Chocolatey
choco install obsidian -y
```

---

## Initial Setup (10 minutes)

### 1. Create KENL Vault

```bash
# Create vault directory structure
mkdir -p ~/.kenl/vault/{00-Index,01-ATOM-Trails,02-Modules,03-Playbooks,04-Resources,05-Archives}

# Or on Windows
New-Item -ItemType Directory -Path "$env:USERPROFILE\.kenl\vault" -Force
New-Item -ItemType Directory -Path "$env:USERPROFILE\.kenl\vault\00-Index" -Force
New-Item -ItemType Directory -Path "$env:USERPROFILE\.kenl\vault\01-ATOM-Trails" -Force
New-Item -ItemType Directory -Path "$env:USERPROFILE\.kenl\vault\02-Modules" -Force
New-Item -ItemType Directory -Path "$env:USERPROFILE\.kenl\vault\03-Playbooks" -Force
New-Item -ItemType Directory -Path "$env:USERPROFILE\.kenl\vault\04-Resources" -Force
New-Item -ItemType Directory -Path "$env:USERPROFILE\.kenl\vault\05-Archives" -Force
```

### 2. Open Vault in Obsidian

1. Launch Obsidian
2. Click "Open folder as vault"
3. Navigate to `~/.kenl/vault` (or `%USERPROFILE%\.kenl\vault` on Windows)
4. Click "Select"

### 3. Enable Community Plugins

1. Settings (gear icon) → Community plugins
2. Turn off "Safe mode"
3. Click "Browse" → Install these plugins:
   - **Dataview** (dynamic content queries)
   - **Templater** (ATOM tag templates)
   - **Calendar** (timeline view)

---

## Quick Vault Structure

```
~/.kenl/vault/
├── 00-Index/
│   ├── Dashboard.md           # 🎯 START HERE - Task-focused landing page
│   ├── Quick-Reference.md     # Common KENL commands
│   └── Current-Context.md     # What you're working on RIGHT NOW
├── 01-ATOM-Trails/            # Audit trail entries (one per task)
├── 02-Modules/                # Notes for each KENL0-12 module
├── 03-Playbooks/              # Step-by-step guides (gaming, dev, system)
├── 04-Resources/              # Bazzite docs, ProtonDB notes, hardware
└── 05-Archives/               # Completed tasks
```

---

## Create Your First Note (5 minutes)

### Dashboard.md

Create `00-Index/Dashboard.md`:

```markdown
# 🎮💻 KENL Dashboard

> **Last Updated:** {{date}}

---

## 🎯 What Do You Want to Do?

### Gaming 🎮
- [[Gaming-Setup|Set up a new game]]
- [[Troubleshooting|Fix game crashes]]
- [[Play-Cards|Share game configs]]

### Development 💻
- [[Dev-Environment|Set up dev container]]
- [[MCP-Integration|Configure Claude MCP]]
- [[PowerShell-Modules|Use KENL PowerShell]]

### System ⚙️
- [[System-Updates|Update Bazzite]]
- [[Rollback|Undo changes]]
- [[Performance|Optimize performance]]

---

## 📋 Current Tasks

- Check `01-ATOM-Trails/` for active work

---

## 🔗 Quick Links

- [Full Obsidian Walkthrough](../modules/KENL7-learning/guides/SAGE-OBSIDIAN-WALKTHROUGH.md)
- [KENL Repository](../README.md)
- [Bazzite Docs](https://docs.bazzite.gg/)
```

---

## Full Walkthrough

**For complete SAGE methodology and advanced features:**

📄 **See:** [`modules/KENL7-learning/guides/SAGE-OBSIDIAN-WALKTHROUGH.md`](../modules/KENL7-learning/guides/SAGE-OBSIDIAN-WALKTHROUGH.md)

**The full walkthrough covers:**
- ATOM trail templates
- Play Card integration
- Bazzite docs linking
- Graph view visualization
- MCP integration (future)
- Real-world game setup example (Baldur's Gate 3)
- Comparison: Traditional docs vs SAGE

---

## Why Use Obsidian with KENL?

**Traditional workflow:**
```
Task → Google → Read 5 articles → Guess → Maybe works → Forget details next time
```

**SAGE workflow:**
```
Task → Open Dashboard → Check ATOM trails → Apply previous solution → Works immediately
```

**Benefits:**
- ✅ Context-aware (know what you were doing last)
- ✅ Hardware-specific (YOUR configs, not generic)
- ✅ Audit trail (every change tracked with intent)
- ✅ Shareable (export Play Cards for friends)
- ✅ Offline-first (works without internet)
- ✅ Rollback-safe (undo instructions documented)

---

## Next Steps

1. ✅ Install Obsidian
2. ✅ Create vault at `~/.kenl/vault`
3. ✅ Create `Dashboard.md` (your landing page)
4. 🔜 Read full walkthrough in KENL7-learning/guides/
5. 🔜 Document your first task with an ATOM trail
6. 🔜 Create Play Card for a game you've configured

---

## Troubleshooting

### Can't Find Vault Directory

**Linux/WSL2:**
```bash
cd ~/.kenl/vault
pwd  # Prints full path
```

**Windows PowerShell:**
```powershell
cd $env:USERPROFILE\.kenl\vault
Get-Location  # Prints full path
```

### Obsidian Can't Access Files

**Flatpak (Linux):**
```bash
# Grant home directory access
flatpak override md.obsidian.Obsidian --filesystem=home
```

**Windows:**
- Ensure Obsidian has file permissions in Windows Security settings

---

## References

- **Full SAGE Walkthrough:** `modules/KENL7-learning/guides/SAGE-OBSIDIAN-WALKTHROUGH.md`
- **KENL ATOM Framework:** `modules/KENL1-framework/README.md`
- **Obsidian Documentation:** https://help.obsidian.md/
- **Bazzite Documentation:** https://docs.bazzite.gg/

---

**ATOM:** ATOM-DOC-20251115-001
**Created:** 2025-11-15
**Related:** SAGE-OBSIDIAN-WALKTHROUGH.md, CURRENT-STATE.md
