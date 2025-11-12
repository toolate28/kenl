---
title: KENL Quick Reference
date: 2025-11-12
atom: ATOM-DOC-20251112-006
---

# KENL Quick Reference

**Last Updated:** 2025-11-12

## First Steps (New Claude Instance)

1. **Check current state:** `cat claude-landing/CURRENT-STATE.md`
2. **Check recent work:** `cat claude-landing/RECENT-WORK.md`
3. **Check git:** `git log --oneline -10`
4. **Check platform:** `uname -a` or `$PSVersionTable` (Windows)

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
