# KENL Shell Libraries

**Shared bash libraries for KENL modules**

These libraries provide common functionality used across all KENL shell scripts, including SAIF-guided operations, logging, platform detection, and ATOM trail integration.

**ATOM**: ATOM-CORE-20251125-001

---

## Quick Start

### Source the libraries
```bash
# In your script, source the core libraries
source /path/to/kenl/modules/KENL0-system/functions/kenl-core.sh
source /path/to/kenl/modules/KENL0-system/functions/kenl-saif.sh

# Or use relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../KENL0-system/functions/kenl-core.sh"
source "$SCRIPT_DIR/../KENL0-system/functions/kenl-saif.sh"
```

---

## Available Libraries

### kenl-core.sh
Core library with shared functions for all KENL scripts.

**Features**:
- Color output and formatting
- Logging functions (info, success, warn, error)
- Header and divider formatting
- Platform detection (bazzite, fedora, ubuntu, linux, macos, wsl2, windows)
- ATOM trail logging
- User prompts and confirmations
- Command helpers
- Error handling

**Key Functions**:
```bash
# Logging
kenl_info "Information message"
kenl_success "Success message"
kenl_warn "Warning message"
kenl_error "Error message"
kenl_debug "Debug message"  # Only when KENL_DEBUG=1

# Formatting
kenl_header "Title"         # Print a header banner
kenl_divider                # Print a horizontal line

# Platform
platform=$(kenl_get_platform)  # Returns: bazzite, fedora, ubuntu, etc.
kenl_is_immutable              # Returns 0 if rpm-ostree based
kenl_is_root                   # Returns 0 if running as root
kenl_require_root              # Exit if not root

# User interaction
kenl_confirm "Continue?"       # Returns 0 if yes
kenl_confirm_phrase "DELETE"   # Require exact phrase
value=$(kenl_prompt "Enter value" "^[0-9]+$" "default")

# Commands
kenl_has_command "yq"          # Returns 0 if command exists
kenl_require_command "yq" "flatpak install yq"

# ATOM
tag=$(generate_atom_tag "CONFIG" "Description")
tag=$(atom "CONFIG" "Message" "Details")
show_atom_trail 20             # Show last 20 entries
```

### kenl-saif.sh
SAIF (System-Aware Intent Flagging) library for guided user journeys.

**Features**:
- SAIF flag generation
- Formatted execution results with next-step guidance
- CTFWI handover document creation
- SAIF trail logging and querying

**Key Functions**:
```bash
# Initialize SAIF
init_saif

# Generate SAIF flag
flag=$(new_saif_flag "CONFIG" "MTU" "MTU set to 1492" "Success")

# Display result with next-step guidance
write_saif_result "$flag" "Success" "MTU set to 1492" \
    "Verify with: ping 8.8.8.8" \
    "Check logs at: ~/.kenl/logs/" \
    "Rollback: sudo ip link set dev eth0 mtu 1500" \
    "$HOME/.kenl/logs/network.log" \
    "sudo ip link set dev eth0 mtu 1500"

# Create handover document
create_handover "Disk Preparation" "Step 1" \
    "Disk wiped,GPT created" \
    "Boot Bazzite,Run partition script" \
    "Do not interrupt"

# Show SAIF trail
show_saif_trail 20
show_saif_trail 10 "CONFIG"  # Filter by action type

# Convenience functions
saif_validate "PREINSTALL" "Validation passed" "Success" "Proceed to next phase"
saif_config "MTU" "MTU set" "Success" "ping 8.8.8.8" "ip link set mtu 1500"
saif_network "LATENCY" "Network test complete" "Success"
```

### system-functions.sh
System management functions for Bazzite/Fedora Atomic.

**Features**:
- Full system update (rpm-ostree, flatpak, distrobox)
- Update checking
- Safe rebase operations
- Deep cleaning
- Emergency rollback
- Gaming stack updates
- Health checks and diagnostics

**Key Functions**:
```bash
# Source the library
source /path/to/kenl/modules/KENL0-system/functions/system-functions.sh

# Update
full-update         # Update everything
check-updates       # Check for updates (no changes)

# Rebase
safe-rebase stable  # Rebase to stable

# Cleanup
deep-clean          # Clean everything

# Rollback
emergency-rollback  # Rollback and reboot

# Gaming
update-gaming       # Update gaming stack
check-proton 1086940  # Check ProtonDB for app

# Diagnostics
health-check        # System health check
system-report       # Generate detailed report
```

---

## SAIF Output Example

When a function generates SAIF output:

```
╔════════════════════════════════════════════════════════════╗
║  SAIF Execution Result                                     ║
╚════════════════════════════════════════════════════════════╝

  ✅ MTU set to 1492

  SAIF Flag: SAIF-CONFIG-20251125-001

  📋 Next Steps:
     → Verify with: ping 8.8.8.8
     → Check logs at: ~/.kenl/logs/network.log
     → Rollback if needed: sudo ip link set dev eth0 mtu 1500

  📁 Log: /home/user/.kenl/logs/network.log
  ↩️  Rollback: sudo ip link set dev eth0 mtu 1500

─────────────────────────────────────────────────────────────
```

---

## CTFWI Handover Documents

Handover documents capture the state of an operation for continuation:

```markdown
---
title: Disk Preparation
classification: CTFWI-HANDOVER
saif: SAIF-HANDOVER-20251125-001
timestamp: 2025-11-25T12:00:00-06:00
phase: Step 1
status: handover
---

# Disk Preparation
## CTFWI Handover Document

## Completed Actions

- ✅ Disk wiped
- ✅ GPT created

## Next Actions

- ⏳ Boot Bazzite Live USB
- ⏳ Run partition script

## Critical Notes

⚠️ Do not interrupt partitioning
```

---

## Configuration

Environment variables:
- `KENL_CONFIG_DIR` - Config directory (default: `~/.kenl`)
- `KENL_LOGS_DIR` - Logs directory (default: `~/.kenl/logs`)
- `ATOM_TRAIL_PATH` - ATOM trail file (default: `~/.kenl/atom_trail.log`)
- `ATOM_COUNTER_PATH` - ATOM counter file (default: `~/.kenl/.atom-counter`)
- `KENL_DEBUG` - Enable debug output when set to `1` or `true`

---

## Files

```
functions/
├── kenl-core.sh          # Core library (logging, platform, ATOM)
├── kenl-saif.sh          # SAIF library (flags, handovers, guidance)
├── system-functions.sh   # System management functions
└── README.md             # This file
```

---

## Usage in Scripts

### Basic Script Template

```bash
#!/usr/bin/env bash
#
# my-script.sh - Description
#
# Version: 1.0.0
# ATOM: ATOM-TYPE-YYYYMMDD-NNN

set -euo pipefail

# Source core libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KENL0="${SCRIPT_DIR}/../KENL0-system/functions"

# shellcheck source=/dev/null
[[ -f "$KENL0/kenl-core.sh" ]] && source "$KENL0/kenl-core.sh"
[[ -f "$KENL0/kenl-saif.sh" ]] && source "$KENL0/kenl-saif.sh"

# Your script logic
main() {
    kenl_header "My Operation"
    kenl_info "Starting..."

    # Do work...

    # Generate SAIF result
    if command -v new_saif_flag &> /dev/null; then
        flag=$(new_saif_flag "CONFIG" "MY-OP" "Operation completed" "Success")
        write_saif_result "$flag" "Success" "Operation completed" \
            "Next step 1" "Next step 2" "Next step 3"
    else
        kenl_success "Operation completed"
        echo ""
        echo "📋 Next Steps:"
        echo "   → Next step 1"
        echo "   → Next step 2"
    fi
}

main "$@"
```

---

## Cross-Platform Compatibility

The core library works on:
- Bazzite (Fedora Atomic)
- Fedora, Ubuntu, Arch Linux
- macOS
- WSL2
- Git Bash / MSYS2 on Windows

Platform-specific code paths are handled by `kenl_get_platform`.

---

**Version**: 1.0.0
**ATOM**: ATOM-CORE-20251125-001
**License**: Same as KENL framework
