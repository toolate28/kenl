---
project: Bazza-DX SAGE Framework
status: current
version: 2025-11-06
classification: OWI-DOC
atom: ATOM-DOC-20251106-019
owi-version: 1.0.0
---

# Current State vs Post-Rebase Configuration

**ATOM-DOC-20251105-033**
**Last Updated:** 2025-11-05

---

## Overview

This document explains the difference between your **current pre-rebase state** and the **automated post-rebase configuration** that will be applied.

---

## Current State (Pre-Rebase)

### Logdy
- ✓ Installed at `~/.local/bin/logdy` (v0.17.0)
- ✓ Running on http://127.0.0.1:8080/
- ⚠ **BASIC MODE**: Only listening to stdin (piped input)
- ❌ NOT aggregating system/service/app logs
- ❌ NOT aggregating SAGE ATOM trail
- ❌ NOT aggregating Claude conversations
- ❌ NOT persistent (no systemd service)

### Beszel
- ⚠ May have attempted installation (service failing)
- ❌ Not properly configured
- ❌ No auth key set up

### Network
- ✓ Basic DHCP on available interfaces
- ❌ No bonding
- ❌ No policy-based routing
- ❌ No download optimization
- ❌ No gaming latency optimization

### SAGE Framework
- ✓ Installed in `~/.config/bazza-dx/`
- ✓ ATOM system working
- ✓ Environment functions available
- ✓ Observer scripts created
- ⚠ Observer systemd services exist but disabled
- ✓ Documentation complete

### Claude Integration
- ✓ MCP servers configured for Claude Desktop
- ❌ No automatic post-boot analysis
- ❌ Conversations not logged centrally

### Steam
- ✓ Likely installed (Bazzite-DX default)
- ⚠ Using default Bazzite gaming environment
- ⚠ **GPU HANG RISK**: Not using safe wrapper

---

## Post-Rebase State (Automated)

When you run `~/post-rebase-restore.sh` after rebase, you'll get:

### Logdy - Full Central Aggregation
- ✓ **Systemd service**: `logdy-central.service` (auto-start on boot)
- ✓ **System logs**: User journald in real-time
- ✓ **SAGE ATOM trail**: All audit tags centralized
- ✓ **SAGE observer**: Self-healing logs
- ✓ **Claude Desktop**: Conversation logs aggregated
- ✓ **Claude Code**: Session logs aggregated
- ✓ **Post-boot analysis**: Health check results
- ✓ **Steam/Proton**: Ready to enable after install
- ✓ **Log archival**: Auto-rotation with compression
- ✓ **PII redaction**: Safe for public viewing
- ✓ **Web UI**: http://localhost:8080 (persistent)
- ○ **Future**: Cloudflare Tunnel to logs.toolated.online

### Beszel - System Monitoring
- ✓ **Agent installed**: Latest version from GitHub
- ✓ **Systemd service**: `beszel-agent.service` (disabled until auth)
- ✓ **Configuration**: `~/.config/beszel/config.yaml`
- ⚠ **Manual step**: Generate auth key + set hub URL
- ✓ **Metrics configured**: CPU, RAM, disk, network, GPU (AMD)

### Network Optimization
- ✓ **Configurations created**: `~/kenl/.kenl/network-configs/`
  - Bond0: eth0 + eth1 (active-backup/LACP)
  - eth2: Dedicated download interface (table 100)
  - eth3: Gaming proxy (table 101)
  - wlan0: Link-local only
- ✓ **Sysctl tuning**: BBR congestion control, optimized buffers
- ✓ **Policy routing script**: Traffic splitting by port
- ⚠ **Manual application required**: NetworkManager + firewall (needs root)

### SAGE Framework
- ✓ **Restored from backup**: All functions preserved
- ✓ **Post-boot analysis**: Systemd timer (5 min after boot)
- ✓ **Claude Code integration**: Auto-analysis of system state
- ✓ **Observer optional**: Can enable if desired
- ✓ **Shell integration**: Auto-source in `.bashrc`

### Claude Integration
- ✓ **MCP servers restored**: Filesystem + Git
- ✓ **Automatic analysis**: Post-boot health checks
- ✓ **Conversation logging**: Fed into Logdy
- ✓ **Non-interactive mode**: Observer can invoke Claude

### Steam - GPU-Safe Configuration
- ✓ **Steam wrapper**: `~/.config/steam/steam-wrapper.sh`
- ✓ **Conservative RADV**: Only safe NGGC enabled
- ✓ **Mesa safety**: GL threading disabled
- ✓ **Shader caching**: Dedicated directory
- ✓ **Proton logging**: Enabled with proper paths
- ✓ **GameMode**: Conservative nice value
- ✓ **Desktop launcher**: "Steam (GPU-Safe)" icon
- ✓ **Environment template**: Per-game customization guide

---

## Upgrade Now vs Wait for Rebase?

### Option 1: Upgrade Logdy NOW (Before Rebase)

Run: `bash ~/upgrade-logdy-now.sh`

**Pros:**
- Start collecting logs immediately
- Test configuration before rebase
- Historical data preserved through rebase

**Cons:**
- Will be reconfigured again during post-rebase anyway
- Current system may have issues that rebase will fix

### Option 2: Wait Until After Rebase

Run: `bash ~/post-rebase-restore.sh` (after rebase + reboot)

**Pros:**
- One-time comprehensive setup
- Fresh system, no legacy issues
- Everything configured together

**Cons:**
- No log collection until then
- Lose visibility into pre-rebase state

### Recommendation

**Upgrade Logdy NOW** if you want to:
- Collect logs leading up to rebase
- Test the configuration
- Have visibility during cleanup process

The post-rebase script will just reconfigure it anyway, so no harm done.

---

## What Requires Manual Intervention?

Even with automation, these require manual steps:

### 1. Network Optimization (Root Required)
```bash
# Copy NetworkManager configurations
sudo cp ~/kenl/.kenl/network-configs/*.nmconnection /etc/NetworkManager/system-connections/
sudo chmod 600 /etc/NetworkManager/system-connections/*.nmconnection
sudo nmcli connection reload

# Apply sysctl tuning
sudo cp ~/kenl/.kenl/network-configs/99-gaming-network.conf /etc/sysctl.d/
sudo sysctl --system

# Set up policy routing (after network up)
~/kenl/.kenl/network-configs/setup-policy-routing.sh
```

### 2. Beszel Agent Authentication
```bash
# Generate key
~/.local/bin/beszel-agent generate-key

# Edit config with hub URL and key
nano ~/.config/beszel/config.yaml

# Enable service
systemctl --user enable --now beszel-agent.service
```

### 3. Cloudflare Tunnel (for public logs)
```bash
# Install cloudflared
# Create tunnel
# Configure DNS
# Update Logdy to use tunnel
```

### 4. GPU Testing (After Rebase)
```bash
# Monitor for hangs
dmesg -w | grep -i amdgpu

# Start with light 2D apps
# Progress to light 3D if stable
# Document with ATOM tags
```

---

## Quick Command Reference

### Current System
```bash
# View current Logdy
http://127.0.0.1:8080/

# Source SAGE
source ~/.config/bazza-dx/env.sh

# Generate ATOM
atom TEST "test message"

# View ATOM trail
tail ~/.config/bazza-dx/atom_trail.log
```

### Upgrade Logdy Now
```bash
bash ~/upgrade-logdy-now.sh
```

### After Rebase
```bash
# Restore everything
bash ~/post-rebase-restore.sh

# Check services
systemctl --user status logdy-central post-boot-analysis.timer

# View aggregated logs
http://localhost:8080

# Launch Steam safely
~/.config/steam/steam-wrapper.sh
```

---

## File Locations

### Current (Pre-Rebase)
```
~/.local/bin/logdy              # Logdy binary
~/.config/logdy/config.json     # Basic config
~/.config/bazza-dx/             # SAGE framework
~/kenl/                         # Project repository
~/cleanup-pre-rebase.sh         # Cleanup script
~/bazzadx-essential-backup-*.tar.gz  # Backup archive
```

### Post-Rebase (After Restore)
```
~/.config/logdy/config.yaml                    # Full aggregation config
~/.config/logdy/archive/                       # Log archives
~/.config/systemd/user/logdy-central.service   # Logdy service
~/.config/systemd/user/post-boot-analysis.*    # Auto-analysis
~/.config/beszel/                              # Monitoring config
~/.config/steam/steam-wrapper.sh               # GPU-safe Steam
~/kenl/.kenl/network-configs/                  # Network optimization
```

---

## Decision Tree

```
START
  │
  ├─ Want logs NOW?
  │   ├─ YES → Run upgrade-logdy-now.sh
  │   └─ NO  → Wait for rebase
  │
  ├─ Ready to rebase?
  │   ├─ YES → bash cleanup-pre-rebase.sh
  │   │        rpm-ostree rebase fedora:fedora/43/x86_64/bazzite-dx
  │   │        systemctl reboot
  │   └─ NO  → Stay on current system
  │
  └─ After reboot (fresh Bazzite-DX)
      │
      └─ bash post-rebase-restore.sh
          │
          ├─ Logdy central aggregation ✓
          ├─ SAGE framework ✓
          ├─ Post-boot analysis ✓
          ├─ Steam GPU-safe ✓
          ├─ Beszel installed (needs auth)
          └─ Network configs created (needs root)
```

---

**Current Status:** PRE-REBASE
**Next Action:** Your choice:
1. Upgrade Logdy now: `bash ~/upgrade-logdy-now.sh`
2. Run cleanup: `bash ~/cleanup-pre-rebase.sh`
3. Proceed with rebase

**Rollback:** `rpm-ostree rollback && systemctl reboot`

---

**ATOM:** ATOM-DOC-20251105-033
**See also:**
- `~/QUICK_START.md` - Quick reference
- `~/kenl/.kenl/REBASE_PREPARATION.md` - Detailed rebase guide
- `~/SYSTEM_INTELLIGENCE_REPORT.md` - Complete system status
