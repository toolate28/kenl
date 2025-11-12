---
project: Bazza-DX SAGE Framework
classification: OWI-DOC
atom: ATOM-DOC-20251112-003
status: active
version: 1.0.0
---

# KENL0-system Module Manifest

**Module:** KENL0-system
**Version:** 1.0.0
**Status:** Production Ready
**Last Updated:** 2025-11-12

---

## Purpose

KENL0 is the "sudog" (super-underdog) layer that handles privileged system-wide operations on immutable Linux systems (Bazzite/Fedora Atomic). It is the only KENL module that can modify system packages, rebase OS versions, and execute elevated operations while maintaining ATOM trail audit logging.

---

## Module Information

| Property | Value |
|----------|-------|
| **Module ID** | KENL0 |
| **Module Name** | System Operations |
| **Category** | System Foundation |
| **Privilege Level** | Elevated (sudo required) |
| **Platform** | Linux (Bazzite/Fedora Atomic), Windows (PowerShell modules) |
| **Dependencies** | None (base layer) |

---

## Directory Structure

```
KENL0-system/
├── README.md                     # Module documentation
├── MANIFEST.md                   # This file
├── aliases/                      # Shell aliases for system ops
├── functions/                    # Bash functions for common tasks
├── powershell/                   # Windows PowerShell modules
│   ├── KENL.psm1                 # Core PowerShell module
│   ├── KENL.Network.psm1         # Network optimization module
│   ├── Install-KENL.ps1          # Installer script (idempotent)
│   ├── COMMAND-STRUCTURE.md      # Cross-platform command reference
│   └── README.md                 # PowerShell module documentation
├── quick-actions/                # Chainable system operations
│   ├── update-verify.sh          # Update + verification
│   └── rebase-clean.sh           # Rebase + cleanup
├── rpm-ostree-ops/               # rpm-ostree operation scripts
├── sudoers.d/                    # Safe sudoers configurations
├── system-atom.sh                # System-level ATOM logging
├── ujust-integration/            # Bazzite ujust recipes
└── windows-support/              # Windows-specific documentation
    ├── README.md                 # Windows support overview
    ├── surface-pro-4/            # Surface Pro 4 guides
    └── alternatives/             # Linux migration alternatives
```

---

## Files Inventory

### Core Files (Linux)

| File | Purpose | Required |
|------|---------|----------|
| `README.md` | Module documentation | Yes |
| `MANIFEST.md` | This manifest | Yes |
| `system-atom.sh` | System-level ATOM trail logging | Yes |

### PowerShell Modules (Windows)

| File | Purpose | Required |
|------|---------|----------|
| `powershell/KENL.psm1` | Core module (platform detection, ATOM logging) | Yes |
| `powershell/KENL.Network.psm1` | Network optimization and testing | Yes |
| `powershell/Install-KENL.ps1` | Idempotent installer | Yes |
| `powershell/COMMAND-STRUCTURE.md` | Bash↔PowerShell command reference | No |
| `powershell/README.md` | PowerShell module docs | Yes |

### System Operations (Linux)

| Directory | Purpose | Required |
|-----------|---------|----------|
| `aliases/` | System operation aliases | No |
| `functions/` | Reusable bash functions | No |
| `quick-actions/` | Chainable operations | No |
| `rpm-ostree-ops/` | rpm-ostree wrappers | No |
| `ujust-integration/` | Bazzite ujust recipes | No |

### Windows Support

| Directory | Purpose | Required |
|-----------|---------|----------|
| `windows-support/` | Windows migration documentation | No |

---

## Dependencies

### System Dependencies (Linux)

**Required Packages:**
```bash
# Bazzite/Fedora Atomic (built-in)
rpm-ostree    # System package management
systemctl     # Service management
```

**Optional Packages:**
```bash
# For enhanced functionality
sudo rpm-ostree install \
    tmux \
    htop \
    ncdu
```

### System Dependencies (Windows)

**Required:**
- PowerShell 5.1+ (Windows) or PowerShell Core 7+ (cross-platform)
- Git for Windows (for Git Bash compatibility)

**Optional:**
- PowerShell-Yaml module (for YAML config parsing)

### KENL Module Dependencies

- **None** - KENL0 is the base layer

### External Tools

- **rpm-ostree:** Immutable OS package management (Fedora Atomic/Bazzite)
- **ujust:** Bazzite-specific convenience commands

---

## Installation

### Quick Install (Linux)

```bash
# KENL0 requires no installation - operates from repo
cd ~/kenl/modules/KENL0-system

# Optional: Add aliases to shell
cat aliases/system-ops.sh >> ~/.bashrc
source ~/.bashrc
```

### Quick Install (Windows - PowerShell Modules)

```powershell
# Run idempotent installer
cd C:\Users\YourName\kenl\modules\KENL0-system\powershell
.\Install-KENL.ps1

# Or install to AllUsers (requires elevation)
.\Install-KENL.ps1 -Scope AllUsers

# Force reinstall
.\Install-KENL.ps1 -Force

# Dry-run (preview changes)
.\Install-KENL.ps1 -WhatIf
```

### Verification (Linux)

```bash
# Test system-atom logging
./modules/KENL0-system/system-atom.sh STATUS "KENL0 verification test"

# Check ATOM log
tail ~/.atom-logs/atom-$(date +%Y%m%d).log
```

### Verification (Windows)

```powershell
# Import modules
Import-Module KENL
Import-Module KENL.Network

# Test platform detection
Get-KenlPlatform

# Test network
Test-KenlNetwork

# Expected output: Platform info and network latency metrics
```

---

## Configuration

### Configuration Files (Linux)

| File | Location | Purpose |
|------|----------|---------|
| `system-atom.conf` | `~/.config/kenl/` | ATOM logging config (optional) |

### Configuration Files (Windows)

| File | Location | Purpose |
|------|----------|---------|
| ATOM logs | `%USERPROFILE%\.atom-logs\` | PowerShell ATOM trail logs |

### Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `KENL_ATOM_LOG_DIR` | `~/.atom-logs` | ATOM log directory (Linux) |
| `KENL_SYSTEM_OPS` | `safe` | Operation mode (safe/advanced) |

---

## Usage

### Basic Usage (Linux)

```bash
# System operations with ATOM logging
cd ~/kenl/modules/KENL0-system

# Update system + verify
./quick-actions/update-verify.sh

# Check rpm-ostree status
rpm-ostree status

# View ATOM logs
cat ~/.atom-logs/atom-$(date +%Y%m%d).log
```

### Basic Usage (Windows)

```powershell
# Test network performance
Test-KenlNetwork

# Optimize network for gaming
Optimize-KenlNetwork -BandwidthMbps 100 -LatencyMs 40 -ApplyMTU

# Set optimal MTU
Set-KenlMTU -MTU 1492

# Write ATOM log
Write-AtomTrail -Type "STATUS" -Message "Network optimized for gaming"

# Get platform info
Get-KenlPlatform
```

### Advanced Usage (Linux)

```bash
# Rebase to different Bazzite variant
./quick-actions/rebase-clean.sh stable

# Layer additional packages
sudo rpm-ostree install package-name
./system-atom.sh CFG "Layered package: package-name"

# Rollback to previous deployment
sudo rpm-ostree rollback
```

---

## Integration Points

### Integration with Other Modules

- **All KENL modules** can call KENL0's system-atom.sh for logging
- **KENL1** (Framework) builds on KENL0's ATOM trail foundation
- **KENL2** (Gaming) uses KENL0 for system-level optimizations

### System Integration (Linux)

- **Shell:** Sources aliases/functions for convenient access
- **Systemd:** Can manage services via systemctl wrappers
- **rpm-ostree:** Direct integration with immutable OS layer

### System Integration (Windows)

- **PowerShell Profile:** Modules load via $PROFILE
- **Network Stack:** Direct integration with Windows networking APIs
- **ATOM Logging:** Cross-platform compatible with Linux ATOM trails

---

## ATOM Traceability

### ATOM Tags

| Tag | Purpose |
|-----|---------|
| `ATOM-SYSTEM-*` | System package changes (rpm-ostree) |
| `ATOM-CFG-*` | Configuration changes |
| `ATOM-STATUS-*` | Status checks and health reports |

### Logging (Linux)

- **Log Location:** `~/.atom-logs/atom-YYYYMMDD.log`
- **Log Format:** `TIMESTAMP [ATOM-TYPE-YYYYMMDD-NNN] MESSAGE`

### Logging (Windows)

- **Log Location:** `%USERPROFILE%\.atom-logs\atom-YYYYMMDD.log`
- **Log Format:** `TIMESTAMP [ATOM-TYPE-YYYYMMDD-NNN] MESSAGE`
- **Generated by:** KENL.psm1 `Write-AtomTrail` function

---

## Testing & Validation

### Unit Tests (Linux)

```bash
# Test ATOM logging
./system-atom.sh STATUS "Test message"
grep "Test message" ~/.atom-logs/atom-$(date +%Y%m%d).log

# Expected: Message appears in today's log
```

### Unit Tests (Windows)

```powershell
# Test PowerShell modules
Import-Module KENL -Force
Import-Module KENL.Network -Force

# Test platform detection
$platform = Get-KenlPlatform
if ($platform -eq "Windows") {
    Write-Host "✓ Platform detection works"
}

# Test ATOM logging
Write-AtomTrail -Type "TEST" -Message "Unit test"
$log = Get-Content "$env:USERPROFILE\.atom-logs\atom-$(Get-Date -Format 'yyyyMMdd').log"
if ($log -match "Unit test") {
    Write-Host "✓ ATOM logging works"
}
```

### Validation Checklist

- [ ] System-atom.sh creates logs in `~/.atom-logs/`
- [ ] PowerShell modules import without errors
- [ ] Network tests return valid latency (Windows)
- [ ] ATOM logs have correct format and counter
- [ ] Installer is idempotent (no changes on re-run)

---

## Rollback & Recovery

### Uninstallation (Linux)

```bash
# KENL0 has no installation - simply remove aliases/functions from shell config
# Remove lines added to ~/.bashrc or ~/.zshrc

# ATOM logs can be archived or deleted
mv ~/.atom-logs ~/.atom-logs.backup
```

### Uninstallation (Windows)

```powershell
# Remove PowerShell modules
Remove-Module KENL -Force
Remove-Module KENL.Network -Force

$modulePath = "$HOME\Documents\PowerShell\Modules"
Remove-Item -Path "$modulePath\KENL" -Recurse -Force
Remove-Item -Path "$modulePath\KENL.Network" -Recurse -Force

# Archive ATOM logs (optional)
Move-Item "$env:USERPROFILE\.atom-logs" "$env:USERPROFILE\.atom-logs.backup"
```

### Rollback Procedure (Linux)

```bash
# Rollback rpm-ostree changes
sudo rpm-ostree rollback

# Reboot to previous deployment
sudo systemctl reboot

# After reboot, verify
rpm-ostree status
```

---

## Maintenance

### Update Procedure

```bash
# Update KENL0 with rest of kenl repo
cd ~/kenl
git pull origin main

# Reinstall PowerShell modules if updated (Windows)
.\modules\KENL0-system\powershell\Install-KENL.ps1 -Force
```

### Health Checks (Linux)

```bash
# Check rpm-ostree status
rpm-ostree status

# Check ATOM logs
ls -lh ~/.atom-logs/

# Verify recent ATOM entries
tail -20 ~/.atom-logs/atom-$(date +%Y%m%d).log
```

### Health Checks (Windows)

```powershell
# Test modules
Import-Module KENL -Force
Import-Module KENL.Network -Force

# Test network
Test-KenlNetwork

# Check ATOM logs
Get-ChildItem "$env:USERPROFILE\.atom-logs"
Get-Content "$env:USERPROFILE\.atom-logs\atom-$(Get-Date -Format 'yyyyMMdd').log" | Select-Object -Last 20
```

---

## Known Issues

### Current Issues

1. **Windows PowerShell 5.1 Compatibility**: Some network APIs behave differently on PowerShell 5.1 vs Core. Workaround: Use fallback to ping.exe when Test-Connection returns 0ms.

2. **NTFS-3G Performance**: NTFS partitions on Linux have slightly slower performance than native ext4. Workaround: Use ext4 for Linux-heavy workloads.

### Limitations

1. **rpm-ostree operations require sudo**: Cannot be fully automated without sudoers configuration
2. **PowerShell modules require Windows**: Bash equivalents for Linux are in progress
3. **ATOM logs are local**: No centralized logging yet (planned for KENL4-monitoring)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-11-12 | Initial manifest creation |
| 1.0.0 | 2025-11-11 | PowerShell modules v1.0 released |
| 1.0.0 | 2025-11-10 | Windows-support moved to KENL0 |
| 1.0.0 | 2025-11-06 | Base system operations established |

---

## References

### Internal Documentation

- `README.md` - Module overview and usage guide
- `powershell/README.md` - PowerShell module documentation
- `powershell/COMMAND-STRUCTURE.md` - Cross-platform command reference
- `windows-support/README.md` - Windows migration guide

### External Resources

- [Bazzite Documentation](https://docs.bazzite.gg/) - Bazzite-specific system operations
- [rpm-ostree Documentation](https://coreos.github.io/rpm-ostree/) - Immutable OS package management
- [PowerShell Documentation](https://docs.microsoft.com/powershell/) - PowerShell scripting reference

---

## Metadata

- **Created:** 2025-11-12
- **Last Updated:** 2025-11-12
- **Maintainer:** toolate28/kenl
- **ATOM Tag:** ATOM-DOC-20251112-003
- **Classification:** OWI-DOC
- **Status:** Active

---
