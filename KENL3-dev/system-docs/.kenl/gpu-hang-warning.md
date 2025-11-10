---
project: Bazza-DX SAGE Framework
status: current
version: 2025-11-06
classification: OWI-DOC
atom: ATOM-DOC-20251106-019
owi-version: 1.0.0
---

# GPU Configuration Warning

**ATOM-STATUS-20251105-009**
**Severity:** CRITICAL
**Status:** UNRESOLVED

## Issue Description

Desktop hangs occur when running high GPU-intensive processes. This indicates:
- Driver misconfiguration
- Mesa settings misalignment
- Power management issues
- Or GPU firmware problems

## Observed Symptoms

- Desktop freeze/hang during GPU-intensive tasks
- Requires hard reboot or TTY recovery
- Affects AMD Radeon GPU

## Known Configuration Issues

From `/usr/lib/environment.d/99-environment.conf:4`:
- RADV_DEBUG configuration error (PAM warnings)

## Affected Operations

**AVOID UNTIL RESOLVED:**
- Heavy 3D gaming workloads
- GPU-accelerated compute tasks
- Multiple GPU-intensive processes simultaneously
- Video encoding/rendering at high settings

## Safe Operations

**OK TO PERFORM:**
- Light desktop usage
- Web browsing
- Development (no GPU compute)
- 2D games or older titles at medium settings

## Investigation Steps

```bash
# Check current GPU driver
lspci | grep -i vga
lsmod | grep amdgpu

# Check Mesa environment
env | grep -E "(MESA|RADV|AMD)"

# Check for errors
dmesg | grep -i "amdgpu"
journalctl -b | grep -i "gpu\|radeon\|amd"

# Check power management
cat /sys/class/drm/card0/device/power_state
cat /sys/class/drm/card0/device/power_dpm_state
```

## Potential Fixes (NOT YET APPLIED)

### Option 1: Fix environment.d Configuration

```bash
# Check the problematic file
sudo cat /usr/lib/environment.d/99-environment.conf

# Likely issue on line 4 (RADV_DEBUG)
# Fix requires: sudo vim /usr/lib/environment.d/99-environment.conf
# Then reboot
```

### Option 2: Reset Mesa Configuration

```bash
# Remove user-level Mesa overrides
rm -f ~/.config/mesa.conf

# Check for system-level overrides
ls -la /etc/drirc
```

### Option 3: AMD GPU Power Management

```bash
# Add kernel parameters via rpm-ostree
sudo rpm-ostree kargs \
  --append=amdgpu.ppfeaturemask=0xffffffff \
  --append=amdgpu.dpm=1

# Reboot required
systemctl reboot
```

### Option 4: Fresh Bazzite Rebase (RECOMMENDED)

```bash
# Document current state (already done)
# Rebase to fresh image
rpm-ostree rebase fedora:fedora/43/x86_64/bazzite-dx

# Reboot
systemctl reboot

# Reapply userspace configs (safe)
source ~/.config/bazza-dx/env.sh
```

## Rollback Plan

All fixes above are rpm-ostree based:

```bash
# View deployments
rpm-ostree status

# Rollback to previous (safe)
rpm-ostree rollback && systemctl reboot

# Pin current deployment before experimenting
sudo ostree admin pin 0
```

## SAGE Observer Integration

The SAGE observer has been configured to:
1. Monitor GPU-related journal errors
2. Detect repeated desktop hangs (if observable)
3. Report to Logdy
4. **NOT** attempt automatic remediation (requires human decision)

## Human Decision Required

**Status:** Awaiting user decision on fix approach

**Recommended Action:**
1. Document all custom configurations (~/.config)
2. Perform clean rebase to fresh Bazzite-DX
3. Gradually reapply configurations
4. Test GPU stability incrementally

**Timeline:** User discretion - system usable for non-GPU-intensive work

## ATOM Trail

- ATOM-STATUS-20251105-009: GPU hang warning documented
- ATOM-CFG-20251105-001: Environment configuration setup (avoids GPU)
- Next: ATOM-DEPLOY-20251105-XXX when fix applied
