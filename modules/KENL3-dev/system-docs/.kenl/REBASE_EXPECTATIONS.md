---
project: Bazza-DX SAGE Framework
status: current
version: 2025-11-06
classification: OWI-DOC
atom: ATOM-DOC-20251106-019
owi-version: 1.0.0
---

# Rebase Expectations & Post-Mortem Template

**ATOM-DOC-20251105-034**
**Purpose:** Predict rebase outcomes, document actual results, identify anomalies
**Created:** 2025-11-05 (immediately before rebase)

---

## Methodology

This document captures my (Claude's) expectations for the rebase process across common scenarios. After the rebase, we'll compare actual results to these predictions to identify:
- Unexpected behavior
- System learning opportunities
- Edge cases to document
- SAGE framework improvements

---

## Scenario 1: Clean Rebase (Most Likely - 85% confidence)

### Expected Process
```
1. Run cleanup script
   └─ Frees 1-3GB (caches, node_modules, backups)
   └─ Creates backup (~50-200KB compressed)
   └─ Documents current state

2. Pin deployment
   └─ sudo ostree admin pin 0
   └─ Deployment 0 marked as pinned

3. Initiate rebase
   └─ rpm-ostree rebase fedora:fedora/43/x86_64/bazzite-dx
   └─ Downloads: ~2-4GB (diff from current to fresh)
   └─ Time: 10-30 minutes (network dependent)
   └─ Creates new deployment (becomes index 0)
   └─ Old deployment shifts to index 1

4. Reboot
   └─ GRUB shows 2 deployments
   └─ Boots into new (index 0) by default
   └─ Boot time: 30-90 seconds

5. First boot (fresh Bazzite-DX)
   └─ /home preserved (all user data intact)
   └─ /etc preserved (system configs intact)
   └─ /usr replaced (fresh immutable base)
   └─ /var preserved (logs, state)
```

### Expected File State After Reboot

| Path | Status | Reason |
|------|--------|--------|
| `~/.config/bazza-dx/` | ✓ INTACT | Userspace, in backup |
| `~/kenl/` | ✓ INTACT | Userspace, git repo |
| `~/bazzadx-essential-backup-*.tar.gz` | ✓ INTACT | Home directory |
| `~/.bashrc` | ✓ INTACT + SAGE integration | Modified by cleanup script |
| `~/.config/logdy/config.yaml` | ✓ INTACT | Created today |
| `~/.config/systemd/user/logdy-central.service` | ✓ INTACT | Created today |
| `~/.local/bin/logdy` | ? UNCERTAIN | May need reinstall if layered |
| `/etc/environment.d/99-environment.conf` | ✓ REPLACED | Fresh system (GPU issue gone?) |
| `/usr/lib/environment.d/` | ✓ REPLACED | Fresh system configs |
| Layered packages | ❌ REMOVED | Fresh base has no layers |

### Expected Service State

| Service | Status | Reason |
|---------|--------|--------|
| `logdy-central.service` | INACTIVE | Needs `systemctl --user start` |
| `beszel-agent.service` | DOES NOT EXIST | Will be created by restore script |
| `sage-observer.timer` | INACTIVE | Disabled by cleanup script |
| Failed services (beszel, gamemode) | GONE | Fresh system, no custom layers yet |

### Expected Network State
- **Interfaces**: Same physical NICs detected
- **Configuration**: DHCP defaults (NetworkManager fresh config)
- **Bonding**: ❌ Not configured (manual step required)
- **Policy routing**: ❌ Not configured (manual step required)

### Expected ATOM Trail
```
~/.config/bazza-dx/atom_trail.log will contain:
- ATOM-CFG-20251105-005: Creating Logdy central aggregation
- ATOM-DEPLOY-20251105-XXX: Pre-rebase cleanup
- ... previous history preserved ...

New entries after rebase:
- ATOM-DEPLOY-20251105-024: Post-rebase restoration initiated
- ATOM-DEPLOY-20251105-XXX: Post-rebase restoration complete
```

---

## Scenario 2: GPU Issue Resolution (70% confidence)

### Hypothesis
The GPU hang is caused by:
- Corrupt `/usr/lib/environment.d/99-environment.conf:4` (RADV_DEBUG syntax error)
- OR accumulated Mesa shader cache conflicts
- OR layered package version mismatch

### Expected Outcome
After rebase to fresh Bazzite-DX:
- ✓ `/usr/lib/environment.d/` files replaced with known-good versions
- ✓ `RADV_DEBUG` syntax error **should be gone**
- ✓ Mesa shader cache **cleared by cleanup script**
- ✓ **GPU hangs should stop or reduce significantly**

### How to Verify
```bash
# Check environment files
cat /usr/lib/environment.d/99-environment.conf

# Should NOT contain syntax errors like:
# RADV_DEBUG=llvm,zerovram  # (this was the error)

# Test GPU incrementally:
1. Light desktop use (2 hours) - should be stable
2. Firefox video playback (1 hour) - should be stable
3. Simple OpenGL app (30 min) - WATCH FOR HANGS
4. Light Steam game (15 min, exit frequently) - CRITICAL TEST
```

### If GPU Still Hangs
Indicates issue is:
- Hardware (unlikely, desktop use is stable)
- Kernel/driver (check `dmesg | grep amdgpu`)
- Deeper Mesa/RADV issue requiring bug report

---

## Scenario 3: Backup/Restore Works Perfectly (75% confidence)

### Expected Process
```bash
# After first boot into fresh Bazzite-DX
cd ~
tar -xzf bazzadx-essential-backup-YYYYMMDD-HHMMSS.tar.gz

# Files restored:
~/.config/bazza-dx/          ✓
~/.config/Claude/            ✓
~/.bashrc.sage-additions     ✓
~/kenl/.kenl/                ✓
~/kenl/CLAUDE.md             ✓
~/kenl/.sage-manifest.yaml   ✓
~/kenl/.gitmessage           ✓
~/SYSTEM_INTELLIGENCE_REPORT.md  ✓
~/CLAUDE_DESKTOP_IMPORT.md       ✓
~/pre-rebase-backup/             ✓
```

### Expected Function Test
```bash
source ~/.config/bazza-dx/env.sh
# Should load without errors (except jq warning)

verify_bazzadx_env
# Should show:
# - Directories exist
# - ATOM counter intact
# - Immutable base detected
# - New deployment checksum

atom TEST "Post-rebase test"
# Should generate ATOM-TEST-20251105-XXX
# Should append to atom_trail.log
```

---

## Scenario 4: Network Optimization Application (60% confidence manual success)

### Expected Manual Steps
```bash
sudo cp ~/kenl/.kenl/network-configs/*.nmconnection /etc/NetworkManager/system-connections/
# Expected: 6 files copied (bond0, eth0-slave, eth1-slave, eth2, eth3, wlan0)

sudo chmod 600 /etc/NetworkManager/system-connections/*.nmconnection
# Expected: Permissions set correctly

sudo nmcli connection reload
# Expected: "6 connections reloaded"

sudo nmcli connection up bond0-gaming
# Expected: Bond activated, eth0+eth1 enslaved
# Possible issue: Interfaces may have different names (enp* instead of eth*)
```

### Expected Interface Naming
**Common possibilities:**
- `eth0` → `enp4s0` (PCI bus 4, slot 0)
- `eth1` → `enp5s0` (PCI bus 5, slot 0)
- `eth2` → `enp6s0` (etc.)
- `wlan0` → `wlp3s0` (WiFi PCI)

**Check actual names:**
```bash
ip link show
nmcli device status
```

**If names different:** Update .nmconnection files before copying

### Expected Routing Tables
```bash
ip route show table 100
# Expected: default via X.X.X.1 dev eth2

ip route show table 101
# Expected: default via Y.Y.Y.1 dev eth3

ip rule show
# Expected: fwmark 100 lookup 100
```

---

## Scenario 5: Logdy Auto-Start (80% confidence)

### Expected After Reboot
```bash
systemctl --user status logdy-central.service
# Expected:
# ● logdy-central.service - Logdy Central Log Aggregation
#    Loaded: loaded (/home/toolated/.config/systemd/user/logdy-central.service; enabled)
#    Active: active (running) since [timestamp]
```

### Expected Log Collection
Visit http://localhost:8080
- Should show logs from:
  - ATOM trail (entries from before and after rebase)
  - User journald (boot messages, systemd events)
  - SAGE observer (if re-enabled)

### Possible Issue: Missing Logs
If Claude Desktop logs not showing:
- Claude Desktop may not be installed yet
- Log paths may be different
- Enable after Claude Desktop installed

---

## Scenario 6: Post-Boot Analysis (New Feature - 50% confidence)

### Expected Behavior
5 minutes after boot, `post-boot-analysis.timer` should trigger:

```bash
systemctl --user status post-boot-analysis.timer
# Expected: Active and waiting for next run

journalctl --user -u post-boot-analysis.service
# Expected log entries:
# - System state collected
# - Failed services count: 0-2 (beszel may still fail until configured)
# - GPU temperature: Normal (40-60°C idle)
# - Memory usage: <50%
# - Disk usage: <70%
```

### Possible Issues
- **Claude Code not available**: Analysis skipped (harmless)
- **High error count**: May indicate issues to investigate
- **Service failed**: Check `journalctl --user -u post-boot-analysis.service`

---

## Scenario 7: Steam GPU-Safe Launch (New Feature - Unknown confidence)

### Expected First Launch
```bash
~/.config/steam/steam-wrapper.sh
# Should:
# 1. Source SAGE environment
# 2. Generate ATOM tag
# 3. Set conservative GPU environment:
#    - RADV_PERFTEST=nggc
#    - RADV_DEBUG="" (cleared)
#    - MESA_GLTHREAD=false
# 4. Launch Steam
```

### Expected Steam Behavior
- **Steam client**: Should launch normally
- **Shader pre-caching**: May take longer (conservative settings)
- **Game launch**: Should work but with conservative performance
- **GPU hang**: **Should NOT occur** (if fix worked)

### How to Test Safely
```
1. Launch Steam via wrapper
2. Run Steam for 30 minutes (library browsing)
3. If stable: Try simple 2D game (5 minutes)
4. If stable: Try light 3D game (10 minutes, exit frequently)
5. If stable: Incrementally increase session length
```

### If Hang Occurs
```bash
# Document with ATOM
bash -c 'source ~/.config/bazza-dx/env.sh && atom ERROR "GPU hang during Steam - game: [name], duration: [time]"'

# Check dmesg
dmesg | grep -i amdgpu | tail -50
# Look for: "ring gfx timeout" or "GPU fault detected"

# This indicates: GPU issue persists, deeper investigation needed
```

---

## Scenario 8: Rollback Required (10% probability, 100% preparedness)

### When to Rollback
- **Critical failure**: System won't boot to GUI
- **Severe regressions**: Major functionality broken
- **Worse than before**: GPU hangs more frequent
- **Data loss**: (shouldn't happen, but if it does)

### Rollback Process
```bash
# From GRUB menu:
# Select previous deployment (index 1)
# -OR-
# From command line after boot:
rpm-ostree rollback
systemctl reboot

# After rollback:
rpm-ostree status
# Should show: Previous deployment now active
```

### Expected State After Rollback
- **Back to pre-rebase**: Exact same state as before rebase
- **Backup still exists**: Can try rebase again with modifications
- **ATOM trail preserved**: All history intact

---

## Scenario 9: Partial Success / Manual Intervention Needed (40% confidence)

### Likely Manual Fixes Needed

1. **Logdy binary missing**
   ```bash
   # Reinstall
   curl -L [logdy-url] -o ~/.local/bin/logdy
   chmod +x ~/.local/bin/logdy
   systemctl --user restart logdy-central.service
   ```

2. **Network interface names changed**
   ```bash
   # Update .nmconnection files
   sed -i 's/eth0/enp4s0/g' ~/kenl/.kenl/network-configs/*.nmconnection
   # Then apply
   ```

3. **Beszel agent missing**
   ```bash
   # Already handled by post-rebase-restore.sh
   # Just need to configure auth
   ```

4. **Claude Desktop not installed**
   ```bash
   # Install via Flatpak or rpm-ostree
   flatpak install com.anthropic.claude
   # -OR-
   rpm-ostree install claude-desktop
   ```

---

## Scenario 10: Unexpected Bonuses (25% confidence)

### Possible Improvements from Fresh Base

1. **Faster boot**: Fresh system without accumulated cruft
2. **Better performance**: Optimized package versions
3. **Fewer failed services**: Clean systemd state
4. **Updated packages**: Newer versions from repo
5. **GPU firmware update**: If kernel/firmware updated
6. **Better power management**: Recent mesa/kernel improvements

---

## Data Collection Plan

### Before Rebase (Collect Now)
```bash
# System state
rpm-ostree status --json > ~/pre-rebase-backup/rpm-ostree-before.json
systemctl --failed > ~/pre-rebase-backup/failed-services-before.txt
lspci > ~/pre-rebase-backup/hardware-before.txt
uname -a > ~/pre-rebase-backup/kernel-before.txt
cat /etc/os-release > ~/pre-rebase-backup/os-release-before.txt

# ATOM count
cp ~/.config/bazza-dx/atom_counter ~/pre-rebase-backup/atom-counter-before.txt

# Current GPU state
dmesg | grep -i amdgpu > ~/pre-rebase-backup/dmesg-amdgpu-before.txt
```

### After Rebase (Collect Immediately)
```bash
# System state
rpm-ostree status --json > ~/post-rebase-compare/rpm-ostree-after.json
systemctl --failed > ~/post-rebase-compare/failed-services-after.txt
lspci > ~/post-rebase-compare/hardware-after.txt
uname -a > ~/post-rebase-compare/kernel-after.txt
cat /etc/os-release > ~/post-rebase-compare/os-release-after.txt

# GPU state
dmesg | grep -i amdgpu > ~/post-rebase-compare/dmesg-amdgpu-after.txt

# Environment files
cat /usr/lib/environment.d/99-environment.conf > ~/post-rebase-compare/environment-conf-after.txt || echo "File does not exist"
```

### After 24 Hours (Stability Check)
```bash
# Uptime
uptime > ~/post-rebase-compare/uptime-24h.txt

# GPU stability
dmesg | grep -i "gpu\|amdgpu\|timeout\|fault" > ~/post-rebase-compare/gpu-stability-24h.txt

# Service health
systemctl --failed > ~/post-rebase-compare/failed-services-24h.txt

# ATOM trail since rebase
grep "ATOM-.*-$(date +%Y%m%d)" ~/.config/bazza-dx/atom_trail.log > ~/post-rebase-compare/atom-activity-24h.txt
```

---

## Post-Mortem Template

After rebase, fill this in:

### Actual Results

**Date/Time of Rebase:** _______________
**Rebase Duration:** _______________
**Download Size:** _______________
**Boot Time (First Boot):** _______________

### Predictions vs Reality

| Scenario | Predicted | Actual | Match? | Notes |
|----------|-----------|--------|--------|-------|
| Clean rebase process | Expected | _____ | ☐ Yes ☐ No | _____ |
| GPU issue fixed | Likely | _____ | ☐ Yes ☐ No | _____ |
| Backup restore | Expected | _____ | ☐ Yes ☐ No | _____ |
| Logdy auto-start | Expected | _____ | ☐ Yes ☐ No | _____ |
| Network config | Manual | _____ | ☐ Yes ☐ No | _____ |
| Post-boot analysis | Uncertain | _____ | ☐ Yes ☐ No | _____ |
| Steam GPU-safe | Unknown | _____ | ☐ Yes ☐ No | _____ |

### Unexpected Observations

1. _____________________________________
2. _____________________________________
3. _____________________________________

### Issues Encountered

1. _____________________________________
   - **Severity:** Critical / High / Medium / Low
   - **Resolution:** _____________________________________

### Improvements to SAGE Framework

Based on rebase experience, update:
- ☐ REBASE_PREPARATION.md
- ☐ post-rebase-restore.sh
- ☐ SAGE observer logic
- ☐ ATOM tag categories
- ☐ Documentation

---

## Success Criteria

Rebase is considered **successful** if:
- ✓ System boots to GUI
- ✓ SAGE framework functions restored
- ✓ ATOM trail preserved and incrementing
- ✓ Logdy collecting logs
- ✓ GPU stable for 2+ hours desktop use
- ✓ No data loss

Rebase is considered **needs work** if:
- ⚠ GPU still hangs (investigate further)
- ⚠ Services need manual fixes (document)
- ⚠ Performance regressions (investigate)

Rebase is considered **failed** if:
- ❌ Won't boot
- ❌ Data loss occurred
- ❌ Critical functionality missing
- → **Rollback immediately**

---

**Status:** PRE-REBASE - Expectations documented
**Next:** Run cleanup script, collect before-data, then rebase
**ATOM:** ATOM-DOC-20251105-034
