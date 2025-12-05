---
title: KENL Quick Reference
date: 2025-12-05
atom: ATOM-DOC-20251205-001
---

# KENL Quick Reference

**Last Updated:** 2025-12-05

## ⚡ Quick OS Detection (Run This First!)

**Detect your environment before reading further:**

```bash
# Linux (Bazzite-DX, Ubuntu CI, Distrobox)
uname -a && cat /etc/os-release 2>/dev/null | head -3

# Check if in distrobox
if [ -f /run/.containerenv ]; then
    echo "✅ Running in distrobox container (user-space mode)"
else
    echo "❌ Running on host system"
fi
```

```powershell
# Windows 11 (Pre-migration testing)
$PSVersionTable
Get-WmiObject Win32_OperatingSystem | Select-Object Caption,Version
```

**Script naming convention hint:**
- 📄 `script.sh` (lowercase) → Likely Windows/WSL scripts
- 📄 `SCRIPT.sh` (UPPERCASE) → Likely Bazzite/rpm-ostree scripts

---

## 🎯 Platform-Specific First Commands

### 🐧 Linux (Bazzite-DX / Distrobox)

**You're operating in user-space only (`~/.local`, `~/.config`, `~/.kenl`).**

```bash
# Check environment
pwd
whoami
cat /etc/os-release | grep PRETTY_NAME

# Git state
git status
git log --oneline -5

# Network baseline (if not in CI)
ping -c 3 1.1.1.1 2>/dev/null || echo "No network or ping restricted"

# Check ATOM counter
cat ~/.kenl/.atom-counter 2>/dev/null || echo "0"

# List available modules
ls -la modules/
```

**⚠️ NEVER:**
- Use `sudo` for system modifications (immutable OS)
- Modify `/etc`, `/usr`, `/opt`
- Suggest rpm-ostree layering without explicit permission

### 🪟 Windows 11 (Pre-Migration Testing)

**You're testing before Bazzite migration.**

```powershell
# Platform validation
$PSVersionTable
Get-KenlPlatform  # After loading modules

# Git state
git status
git log --oneline -5

# Network baseline (expect ~6ms)
Test-KenlNetwork

# PowerShell modules (should load without errors)
Import-Module ./modules/KENL0-system/powershell/KENL.psm1
Import-Module ./modules/KENL0-system/powershell/KENL.Network.psm1

# Hardware validation
Get-WmiObject Win32_Processor | Select-Object Name
Get-Disk | Where-Object BusType -eq USB  # External drive check
```

### 🤖 GitHub Actions CI

**You're in automated testing (Ubuntu 24.04).**

```bash
# Verify CI environment
echo "CI: $CI"
echo "GITHUB_ACTIONS: $GITHUB_ACTIONS"
cat /etc/os-release | head -3

# Run pre-commit checks
pre-commit run --all-files

# No network-dependent tests
# No hardware validation needed
```

---

## First Steps (New Claude Instance)

### 1. Detect Platform (See Above) 
**👆 Run OS detection commands before proceeding!**

### 2. Read Orientation Docs
1. **Check current state:** `cat claude-landing/CURRENT-STATE.md`
2. **Check recent work:** `cat claude-landing/RECENT-WORK.md`
3. **Review CTF protocol:** See RECENT-WORK.md "CTF Flag Capture Protocol" section

### 3. Capture the Flags (Validate Documented Expectations)

**Purpose:** Verify documented state matches reality before proceeding

**Run platform-specific commands from "Platform-Specific First Commands" section above.**

### 3. Report Validation Results

**If all flags validate (✅):** Proceed with task

**If any flag fails (🚩):** Report mismatch:
- Expected: [What docs claim]
- Reality: [What you found]
- Impact: [Affects current work?]
- Action: [Update docs OR investigate]

## Key Paths

```
kenl/
├── claude-landing/          ← START HERE (orientation docs)
├── modules/KENL0-system/    ← System operations, PowerShell modules
│   └── powershell/          ← Windows KENL modules
├── modules/KENL2-gaming/    ← Gaming configs, Play Cards
│   ├── configs/network/     ← Network optimization scripts
│   └── configs/hardware/    ← AMD Ryzen 5 5600H + Vega config
├── case-studies/RWS-*.md    ← Real-world scenarios
├── governance/              ← ARCREF + ADR templates
└── CLAUDE.md                ← Primary project instructions
```

## Essential Commands

### Git
```bash
git status
git log --oneline -10
git branch -a
```

### PowerShell Modules (Windows)
```powershell
# Load modules
Import-Module ./modules/KENL0-system/powershell/KENL.psm1
Import-Module ./modules/KENL0-system/powershell/KENL.Network.psm1

# Test network
Test-KenlNetwork

# Check platform
Get-KenlPlatform
```

### Network Testing
```bash
# Linux/WSL2
bash modules/KENL2-gaming/configs/network/test-network-latency.sh

# Windows PowerShell
Test-KenlNetwork
```

### ATOM Tags
```bash
# Format: ATOM-{TYPE}-{YYYYMMDD}-{NNN}
ATOM-MCP-20251112-001      # MCP tool invocation
ATOM-CFG-20251112-002      # Configuration change
ATOM-DOC-20251112-003      # Documentation update
```

## Hardware Specs

- **CPU:** AMD Ryzen 5 5600H (6C/12T, 3.3-4.2GHz)
- **GPU:** AMD Radeon Vega Graphics (7 CUs, integrated)
- **RAM:** 16GB
- **Storage:** 512GB NVMe (internal) + 2TB HDD (external)

## Current State (2025-11-12)

- **Platform:** Windows 11 (pre-migration testing)
- **Branch:** main
- **Network:** 6.2ms baseline (Tailscale disabled)
- **Modules:** PowerShell KENL.psm1 + KENL.Network.psm1 ✅ ACK

## Effective Directives

```
✅ "assess your environment first, against the documentation"
✅ "check recent commits to understand current work"
✅ "pay special attention to [specific files/concepts]"
✅ "we're on Windows testing before Bazzite migration"
```

## Test-Then-Commit Workflow

1. Create module code
2. User tests with real workload
3. User reports ACK (good) or NACK (fix needed)
4. **Then** commit (only after ACK)
5. No PRs until all modules validated

---

**ATOM:** ATOM-DOC-20251112-006
