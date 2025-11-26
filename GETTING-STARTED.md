---
title: KENL Getting Started - Obsidian Vault Initialization
classification: SAIF-ENTRY-POINT
atom: ATOM-DOC-20251126-001
created: 2025-11-26
version: 2.0.0
status: production
---

# KENL Getting Started

> **Your first step:** Set up the Obsidian vault, import this file, and let the guided pathways build your personalized KENL environment.

---

## 🎯 What You're About to Do

This guide follows the **SAIF (System-Aware Intent Flagging)** process:

1. **Install Obsidian** (5 minutes)
2. **Create your KENL vault** (2 minutes)
3. **Import this file** - your first note becomes your dashboard
4. **Select your pathway** - Gaming, Development, System Recovery, or Migration
5. **Follow guided steps** - each step imports/verifies the modules you need

By the end, you'll have a personalized, documented, rollback-safe system tailored to YOUR needs.

---

## Step 1: Install Obsidian

### Linux (Bazzite/Fedora)

```bash
# Flatpak (recommended for immutable systems)
flatpak install flathub md.obsidian.Obsidian -y

# Grant home directory access
flatpak override md.obsidian.Obsidian --filesystem=home --user
```

### Windows

```powershell
# Option 1: Winget (Windows 11)
winget install Obsidian.Obsidian

# Option 2: Chocolatey
choco install obsidian -y

# Option 3: Direct download
Start-Process "https://obsidian.md/download"
```

### macOS

```bash
brew install --cask obsidian
```

---

## Step 2: Clone KENL Repository

```bash
# Clone to standard location
git clone https://github.com/toolate28/kenl.git ~/.kenl

# Or on Windows
git clone https://github.com/toolate28/kenl.git $env:USERPROFILE\.kenl
```

---

## Step 3: Create Your Vault

### Option A: Use KENL Directory as Vault (Recommended)

1. Open Obsidian
2. Click **"Open folder as vault"**
3. Navigate to `~/.kenl` (or `%USERPROFILE%\.kenl` on Windows)
4. Click **Open**

### Option B: Create Separate Vault with Links

```bash
# Create vault with standard structure
mkdir -p ~/.kenl-vault/{00-Dashboard,01-ATOM-Trails,02-Modules,03-Playcards,04-Archives}

# Create symlinks to KENL documentation
ln -s ~/.kenl/modules ~/.kenl-vault/02-Modules/kenl-modules
ln -s ~/.kenl/claude-landing ~/.kenl-vault/00-Dashboard/claude-landing
```

---

## Step 4: Enable Essential Plugins

Open Obsidian Settings → Community Plugins → Browse:

| Plugin | Purpose | Required |
|--------|---------|----------|
| **Dataview** | Query ATOM trails and Play Cards | ✅ Yes |
| **Templater** | ATOM tag templates | ✅ Yes |
| **Calendar** | Timeline view of work | Optional |
| **Kanban** | Task management | Optional |

---

## Step 5: Select Your Pathway

### 🎮 Gaming Pathway
**For:** Linux gaming, Play Cards, Proton optimization

```
Import: modules/KENL2-gaming/README.md
Then:   Follow gaming setup checklist
Result: Shareable game configs with performance metrics
```

**Quick start:**
- [ ] Import KENL2-gaming README
- [ ] Research your first game: `./research-game.sh "Game Name"`
- [ ] Create Play Card: `./create-playcard.sh "Game Name"`
- [ ] Apply and verify

---

### 💻 Development Pathway
**For:** Claude Code, Ollama/Qwen, MCP integration, Distrobox

```
Import: modules/KENL3-dev/README.md
Then:   Follow dev environment setup
Result: AI-assisted development with full ATOM traceability
```

**Quick start:**
- [ ] Import KENL3-dev README
- [ ] Set up Distrobox: `distrobox create -n kenl-dev -i ubuntu:24.04`
- [ ] Install Claude Code or Ollama
- [ ] Configure MCP servers

---

### 🔧 System Recovery Pathway
**For:** Windows recovery, Surface Pro 4, system diagnostics

```
Import: modules/Surface_Pro_4_EoL_BattleMedic_v2.1/BattleMedic-Complete-Manual.md
Then:   Follow initialization checklist in document
Result: Automated system recovery with SAIF logging
```

**Quick start:**
- [ ] Import BattleMedic manual
- [ ] Run: `Import-Module BattleMedic`
- [ ] Initialize: `Initialize-BattleMedic`
- [ ] Diagnose: `Get-BattleMedicDiagnostic -Quick`

---

### 🚀 Migration Pathway
**For:** Windows 10 EOL migration, dual-boot setup

```
Import: modules/KENL0-system/windows-support/README.md
Then:   Follow partition workflow
Result: Safe dual-boot with rollback capability
```

**Quick start:**
- [ ] Import KENL0 Windows support docs
- [ ] Review workflow: `scripts/windows-partition-scripts/WORKFLOW_DIAGRAM.md`
- [ ] Follow STEP1 → STEP2 → STEP3 sequence

---

## Step 6: Install PowerShell Profile (Optional)

For dynamic banners and current playcard display:

```powershell
# Import KENL profile functions
. ~/.kenl/scripts/Install-KenlProfile.ps1

# Or manually add to $PROFILE:
notepad $PROFILE
```

Add this to your profile for automatic KENL integration:

```powershell
# KENL Profile Integration
$env:KENL_HOME = "$env:USERPROFILE\.kenl"
Import-Module "$env:KENL_HOME\modules\KENL0-system\powershell\KENL.psm1" -ErrorAction SilentlyContinue
Import-Module "$env:KENL_HOME\modules\KENL0-system\powershell\KENL.SAIF.psm1" -ErrorAction SilentlyContinue

# Show current context on shell start
if (Get-Command Show-KenlBanner -ErrorAction SilentlyContinue) {
    Show-KenlBanner
}
```

---

## What Happens Next

After selecting your pathway:

1. **Guided import** - Each pathway imports only the modules you need
2. **Verification** - Scripts run to ensure your environment is ready
3. **AI injection points** - Optimal points to add Claude Code or GitHub Copilot
4. **Checkpoints** - SAIF flags mark your progress for resumption

---

## Pathway Decision Tree

```mermaid
graph TD
    Start([🚀 Start Here]) --> Q1{What do you want to do?}
    
    Q1 --> |Play games on Linux| Gaming[🎮 Gaming Pathway]
    Q1 --> |Develop software| Dev[💻 Development Pathway]
    Q1 --> |Fix Windows issues| Recovery[🔧 Recovery Pathway]
    Q1 --> |Migrate from Windows| Migration[🚀 Migration Pathway]
    
    Gaming --> G1[Import KENL2-gaming]
    G1 --> G2[Research games on ProtonDB]
    G2 --> G3[Create Play Cards]
    G3 --> G4[Share with friends]
    
    Dev --> D1[Import KENL3-dev]
    D1 --> D2[Set up Distrobox]
    D2 --> D3[Install AI tools]
    D3 --> D4[Configure MCP]
    
    Recovery --> R1[Import BattleMedic]
    R1 --> R2[Run diagnostics]
    R2 --> R3[Apply fixes]
    R3 --> R4[Document recovery]
    
    Migration --> M1[Import KENL0 Windows]
    M1 --> M2[Plan partitions]
    M2 --> M3[Create dual-boot]
    M3 --> M4[Verify & backup]
    
    G4 --> Complete([✅ KENL Configured])
    D4 --> Complete
    R4 --> Complete
    M4 --> Complete
    
    style Start fill:#5865F2,color:#fff
    style Complete fill:#57F287,color:#000
    style Gaming fill:#ED4245,color:#fff
    style Dev fill:#00AFF4,color:#fff
    style Recovery fill:#FEE75C,color:#000
    style Migration fill:#845EF7,color:#fff
```

---

## ATOM Trail

This file initiates your ATOM trail. Every action you take from here is logged:

```
ATOM-DOC-20251126-001: Started KENL setup (this file imported)
ATOM-PATHWAY-YYYYMMDD-NNN: Selected [Gaming|Dev|Recovery|Migration] pathway
ATOM-MODULE-YYYYMMDD-NNN: Imported module X
ATOM-VERIFY-YYYYMMDD-NNN: Verified module X working
```

---

## Quick Reference

| Command | Purpose |
|---------|---------|
| `Show-KenlBanner` | Display current context and playcard |
| `Get-KenlInfo` | Show KENL system status |
| `Get-AtomTrail -Last 10` | View recent ATOM entries |
| `New-SAIFFlag` | Create checkpoint flag |
| `Show-SAIFTrail` | View SAIF progress |

---

## Need Help?

- **AI Agents:** Start with `claude-landing/CURRENT-STATE.md`
- **Documentation:** Check module-specific READMEs
- **Issues:** [GitHub Issues](https://github.com/toolate28/kenl/issues)
- **Security:** See [SECURITY.md](./SECURITY.md)

---

**Next Step:** Select your pathway above and follow the checklist!

---

**ATOM:** ATOM-DOC-20251126-001
**SAIF:** SAIF-INIT-20251126-001
**Created:** 2025-11-26
