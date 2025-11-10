# KENL0: System Operations ("sudog" layer)

**Version:** 1.0.0
**Target Platform:** Bazzite (rpm-ostree) - Immutable Linux
**Status:** Production Ready
**Privilege Level:** Elevated (requires sudo for some operations)

---

## Overview

KENL0 is the **"sudog" (super-underdog) layer** that handles privileged systemwide operations on immutable Linux systems (Bazzite/Fedora Atomic). It provides:

- ⚙️ **Chainable system operations** (rebase + clean, update + verify)
- 🔒 **Safe elevated privileges** via sudoers configuration
- 📋 **ATOM trail logging** for all systemwide changes
- 🎯 **CTFWI validation** before dangerous operations
- 🔄 **Automatic rollback points** with rpm-ostree
- 🚀 **ujust integration** for Bazzite-specific operations
- ⚡ **OS-specific aliases/functions** optimized for Bazzite

---

## Why KENL0?

Other KENLs operate in **user-space** (respecting immutability). KENL0 is the **only KENL** that can:
- Modify system packages (rpm-ostree)
- Rebase to different OS versions
- Manage systemwide services
- Execute privileged operations safely

It's the "sudog" - the foundation that enables systemwide changes while maintaining ATOM trail audit logging.

---

## Quick Actions (Chained Operations)

### Update + Verify

```bash
cd ~/kenl/KENL0-system/quick-actions
./update-verify.sh

# Performs:
# 1. Check for updates
# 2. Update system (rpm-ostree upgrade)
# 3. Verify integrity
# 4. Report changes
# All logged to ATOM trail!
```

### Rebase + Clean

```bash
cd ~/kenl/KENL0-system/quick-actions
./rebase-clean.sh stable

# Performs:
# 1. Rebase to Bazzite stable/testing/latest
# 2. Clean old deployments (keep 2)
# 3. Verify system integrity
# Rollback point created automatically!
```

---

## ujust Integration

Bazzite uses `ujust` for system management. KENL0 wraps it with ATOM trail logging:

```bash
cd ~/kenl/KENL0-system/ujust-integration
./ujust-atom.sh --choose

# Shows menu:
#  1) update - Update system
#  2) rebase-stable - Rebase to stable
#  3) setup-gaming - Configure gaming
#  ... and more, all ATOM-logged!
```

---

## Aliases (Bazzite-Optimized)

```bash
# Load Bazzite aliases
source ~/kenl/KENL0-system/aliases/bazzite-aliases.sh

# rpm-ostree shortcuts
os-status          # rpm-ostree status
os-update          # rpm-ostree upgrade
os-rollback        # rpm-ostree rollback
os-clean           # Cleanup old deployments

# Flatpak shortcuts
fpl                # flatpak list
fpi <app>          # flatpak install
fpup               # flatpak update

# Distrobox shortcuts
dbl                # distrobox list
dbe <name>         # distrobox enter

# Gaming
proton-list        # List installed Proton versions
steam-logs         # View Steam logs

# Quick actions
qa-update          # Chained update + verify
qa-rebase          # Chained rebase + clean
qa-ujust           # ujust menu
```

---

## Functions (Advanced)

```bash
# Load system functions
source ~/kenl/KENL0-system/functions/system-functions.sh

# Full system update (rpm-ostree + flatpak + distrobox)
full-update

# Deep clean (rpm-ostree + flatpak + caches + journals)
deep-clean

# Safe rebase with confirmation
safe-rebase stable

# Emergency rollback and reboot
emergency-rollback

# Update gaming stack (Proton-GE + Steam + gaming flatpaks)
update-gaming

# System health check
health-check

# Generate diagnostic report
system-report
```

---

## ATOM Trail Integration

All KENL0 operations are logged:

```bash
# System operation with ATOM trail
./system-atom.sh update "Monthly system update" "rpm-ostree upgrade"

# Creates ATOM-SYSTEM-20251109-001

# View system ATOM trail
ls ~/.config/atom-sage/trail/ATOM-SYSTEM-*
cat ~/.config/atom-sage/trail/ATOM-SYSTEM-20251109-001.log
```

---

## Sudoers Configuration

For passwordless operations (optional, requires root):

```bash
# Validate sudoers file
sudo visudo -c -f ~/kenl/KENL0-system/sudoers.d/kenl0-system

# Install (BE CAREFUL!)
sudo cp ~/kenl/KENL0-system/sudoers.d/kenl0-system /etc/sudoers.d/
sudo chmod 0440 /etc/sudoers.d/kenl0-system

# Allows passwordless:
# - rpm-ostree status (read-only)
# - systemctl status (read-only)
# - journalctl (read-only)
#
# Requires password:
# - rpm-ostree upgrade/rebase/install
# - systemctl reboot/poweroff
```

**Security Note**: Only install if you understand the implications!

---

## CTFWI Validation

"Checked The Flags, What Intent?" - pre-flight checks before dangerous operations:

```bash
# Example: Rebase operation
./system-atom.sh rebase "Rebase to testing" "rpm-ostree rebase ..."

# CTFWI validates:
# ✅ rpm-ostree available
# ✅ Rollback point will be created
# ✅ Target version exists
# ✅ Sufficient disk space
# ✅ No pending operations
#
# Prompts for confirmation before executing
```

---

## Directory Structure

```
KENL0-system/
├── system-atom.sh              # Core ATOM trail wrapper
├── quick-actions/              # Chained operations
│   ├── update-verify.sh        # Update + verify
│   ├── rebase-clean.sh         # Rebase + clean
│   └── rollback-restore.sh     # (TODO)
├── ujust-integration/          # Bazzite ujust wrappers
│   └── ujust-atom.sh           # ATOM-logged ujust
├── rpm-ostree-ops/             # rpm-ostree specific (TODO)
├── sudoers.d/                  # Safe sudoers config
│   └── kenl0-system            # Sudoers file
├── aliases/                    # OS-specific aliases
│   └── bazzite-aliases.sh      # Bazzite-optimized
├── functions/                  # Advanced functions
│   └── system-functions.sh     # Bazzite system functions
└── README.md                   # This file
```

---

## Integration with Other KENLs

KENL0 is the **only KENL with elevated privileges**. Other KENLs call KENL0 for system operations:

```
┌─────────────────────────────────────────┐
│  KENL2 Gaming: "Update Proton-GE"       │
│  └─→ Calls KENL0: ujust install-proton  │
│      └─→ ATOM trail: ATOM-SYSTEM-*      │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  KENL3 Dev: "Install dev tools"         │
│  └─→ Calls KENL0: rpm-ostree install    │
│      └─→ ATOM trail: ATOM-SYSTEM-*      │
└─────────────────────────────────────────┘
```

---

## KENL5 Facades Integration

Switch to system operations context:

```bash
cd ~/kenl/KENL5-facades
./switch-kenl.sh system

# Prompt changes to:
⚙️  KENL0 user@bazzite:~$

# Aliases and functions loaded automatically!
qa-update          # Quick action available
os-status          # Alias available
full-update        # Function available
```

---

## Safety Features

1. **ATOM Trail**: Every operation logged
2. **CTFWI Validation**: Pre-flight checks before dangerous ops
3. **Automatic Rollback Points**: rpm-ostree creates rollback automatically
4. **Confirmation Prompts**: Asks before executing
5. **Immutable-Safe**: Respects rpm-ostree constraints

---

## Example Workflow

```bash
# Morning: Check for updates
./switch-kenl.sh system
⚙️  KENL0 user@bazzite:~$ check-updates

# Updates available! Run update + verify
⚙️  KENL0 user@bazzite:~$ qa-update
# → Creates ATOM-SYSTEM-20251109-001
# → Updates system
# → Verifies integrity
# ✅ Complete!

# Reboot to activate
⚙️  KENL0 user@bazzite:~$ sudo systemctl reboot

# After reboot: Verify
⚙️  KENL0 user@bazzite:~$ os-status
✅ New deployment active!

# View ATOM trail
⚙️  KENL0 user@bazzite:~$ cat ~/.config/atom-sage/trail/ATOM-SYSTEM-20251109-001.log
```

---

## License

MIT License - See [../KENL1-framework/LICENSE](../KENL1-framework/LICENSE)

---

## Navigation

- **← [Root README](../README.md)** - Overview of all KENL modules
- **→ [KENL1: Framework](../KENL1-framework/README.md)** - Core ATOM+SAGE+OWI
- **→ [KENL5: Facades](../KENL5-facades/README.md)** - Context switching

---

**Status**: Production Ready | **Version**: 1.0.0 | **Platform**: Bazzite (rpm-ostree) | **Privilege**: Elevated
