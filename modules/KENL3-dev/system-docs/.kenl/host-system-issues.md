---
project: Bazza-DX SAGE Framework
status: current
version: 2025-11-06
classification: OWI-DOC
atom: ATOM-DOC-20251106-019
owi-version: 1.0.0
---

# Host System Issues (Bazzite-DX rpm-ostree)

**Date**: 2025-11-05
**Boot**: 0f5cb2e53c554107b48d76895c909feb
**ATOM-STATUS-20251105-001**

## Issues Requiring Host-Side Fixes

### Critical (Constant Failures)

#### 1. beszel-agent.service
- **Status**: Failed 200+ times
- **Error**: `Failed to load public keys: no key provided`
- **Required**: Set `-key` flag, `KEY` env var, or `KEY_FILE` env var
- **Fix**: Either configure keys or disable service
- **Command to fix on host**:
  ```bash
  # Option A: Disable if not needed
  sudo systemctl disable --now beszel-agent.service

  # Option B: Configure with keys
  sudo systemctl edit beszel-agent.service
  # Add: Environment="KEY=your-key-here"
  ```

#### 2. gamemode-monitor.sh
- **Status**: Recurring failure every 5 seconds
- **Error**: `/usr/local/bin/gamemode-monitor.sh: line 5: gamemoded: command not found`
- **Impact**: Gaming optimizations may not work
- **Fix on host**:
  ```bash
  # Check if gamemode is installed
  rpm-ostree status | grep gamemode

  # If not, layer it
  rpm-ostree install gamemode

  # Or fix the script path
  sudo vim /usr/local/bin/gamemode-monitor.sh
  ```

### Medium Priority

#### 3. RADV_DEBUG Configuration Error
- **File**: `/usr/lib/environment.d/99-environment.conf:4`
- **Error**: Invalid syntax (around "RADV_DEBUG")
- **Impact**: PAM warnings on every sudo command
- **Fix on host**:
  ```bash
  sudo vim /usr/lib/environment.d/99-environment.conf
  # Fix line 4 syntax
  ```

#### 4. Flatpak Database Errors
- **Error**: `QSqlQuery::prepare: database not open`
- **Process**: PID 8728
- **Impact**: May affect flatpak app functionality
- **Fix on host**:
  ```bash
  flatpak repair --system
  flatpak repair --user
  ```

### Low Priority

#### 5. Firewalld Network Interface
- **Interface**: enp4s0f4u3
- **Error**: `UNKNOWN_INTERFACE: 'enp4s0f4u3' is not in any zone`
- **Impact**: Network connectivity may be suboptimal
- **Fix on host**:
  ```bash
  sudo firewall-cmd --get-active-zones
  sudo firewall-cmd --zone=public --add-interface=enp4s0f4u3 --permanent
  sudo firewall-cmd --reload
  ```

## Minor Issue

#### 6. hhd-ui Crash
- **Time**: 11:55:44
- **Signal**: SIGTRAP
- **Command**: `hhd-ui --version`
- **Coredump**: `/var/lib/systemd/coredump/core.hhd-ui.0...`
- **Impact**: Very low - just UI version check
- **Action**: Report to handheld daemon project

## Rollback Instructions

If any fix causes issues on immutable system:
```bash
# See current deployment
rpm-ostree status

# Rollback to previous
rpm-ostree rollback

# Reboot to activate
systemctl reboot
```

## ATOM Trail
- ATOM-STATUS-20251105-001: Initial host issues documentation
- Next: ATOM-CFG-20251105-001 when fixes applied
