---
project: KENL Framework
classification: OWI-DOC
atom: ATOM-DOC-20251126-001
status: production
version: 2.1.0
---

# Battle Medic Recovery Suite v2.1 - Module Manifest

**Module:** Surface_Pro_4_EoL_BattleMedic_v2.1
**Version:** 2.1.0
**Status:** Production Ready
**Last Updated:** 2025-11-26
**Target Hardware:** Microsoft Surface Pro 4

---

## Purpose

The Battle Medic Recovery Suite is a comprehensive PowerShell-based system recovery toolkit specifically designed for End-of-Life Surface Pro 4 devices experiencing critical system failures, with specialized handling for wof.sys driver corruption and related BSOD errors.

**Primary Use Case:** Recovery from wof.sys green screen/BSOD (STOP code: 0xD3)

---

## Module Information

| Property | Value |
|----------|-------|
| **Module ID** | BattleMedic |
| **Full Name** | Battle Medic Recovery Suite |
| **Category** | System Recovery / Diagnostics |
| **Privilege Level** | Elevated (Administrator required) |
| **Platform** | Windows 10/11 (Build 10240+) |
| **PowerShell** | 3.0+ (5.1+ recommended) |
| **Dependencies** | WMI/CIM, Volume Shadow Copy, .NET Framework 4.5+ |

---

## Directory Structure

```
Surface_Pro_4_EoL_BattleMedic_v2.1/
├── BattleMedic.psd1                      # PowerShell module manifest
├── BattleMedic.psm1                      # Main module file
├── MANIFEST.md                           # This file
├── BattleMedic-Complete-Manual.md        # Complete documentation
├── Test-BattleMedicRequirements.ps1      # Pre-deployment testing
├── Modules/
│   ├── BattleMedic.Compatibility.psm1    # Cross-version compatibility
│   ├── BattleMedic.Core.psm1             # Core functions
│   ├── BattleMedic.Diagnostics.psm1      # System diagnostics
│   ├── BattleMedic.Logging.psm1          # SAIF-compliant logging
│   ├── BattleMedic.Recovery.psm1         # Recovery operations
│   ├── BattleMedic.SP4.psm1              # Surface Pro 4 specific
│   └── BattleMedic.WinRE.psm1            # Windows Recovery Environment
├── Formats/
│   └── BattleMedic.Format.ps1xml         # Custom output formatting
├── Types/
│   └── BattleMedic.Types.ps1xml          # Type extensions
└── Obsidian_Vault/                       # Recovery documentation vault
    ├── 00_HOME.md
    ├── 01_WOFSYS_EMERGENCY_PROTOCOL.md
    ├── 02_REQUIREMENTS_CHECKLIST.md
    ├── 03_STEP_BY_STEP_RECOVERY.md
    └── Logs/
```

---

## Files Inventory

### Core Module Files

| File | Purpose | Required |
|------|---------|----------|
| `BattleMedic.psd1` | PowerShell module manifest | Yes |
| `BattleMedic.psm1` | Main entry point, function exports | Yes |
| `MANIFEST.md` | This documentation | No |
| `BattleMedic-Complete-Manual.md` | Complete usage guide | Recommended |
| `Test-BattleMedicRequirements.ps1` | Pre-deployment verification | Recommended |

### Sub-Modules

| File | Purpose | Required |
|------|---------|----------|
| `BattleMedic.Core.psm1` | Core functions (Initialize, Get-Status) | Yes |
| `BattleMedic.Diagnostics.psm1` | System diagnostics and priority classification | Yes |
| `BattleMedic.Recovery.psm1` | Recovery operations (Repair-WOFDriver, etc.) | Yes |
| `BattleMedic.Logging.psm1` | SAIF audit logging | Yes |
| `BattleMedic.Compatibility.psm1` | PowerShell 3.0-5.1 compatibility layer | Yes |
| `BattleMedic.SP4.psm1` | Surface Pro 4 hardware optimizations | No |
| `BattleMedic.WinRE.psm1` | Windows Recovery Environment offline operations | No |

### Supporting Files

| File | Purpose | Required |
|------|---------|----------|
| `BattleMedic.Format.ps1xml` | Custom output formatting for diagnostic objects | No |
| `BattleMedic.Types.ps1xml` | Type extensions for recovery objects | No |

---

## Dependencies

### System Dependencies

**Required:**
```powershell
# Windows version
Windows 10 Build 10240+ or Windows 11

# PowerShell version
PowerShell 3.0+ (5.1+ recommended)

# .NET Framework
.NET Framework 4.5 or later
```

**Optional:**
```powershell
# For enhanced functionality
Windows Assessment and Deployment Kit (Windows ADK)
Windows Recovery Environment (WinRE) partition
```

### PowerShell Modules

**No external PowerShell module dependencies** - completely self-contained

### Services

| Service | Purpose | Required |
|---------|---------|----------|
| **winmgmt** | Windows Management Instrumentation | Yes |
| **VSS** | Volume Shadow Copy (for checkpoints) | Recommended |
| **EventLog** | Event logging | Yes |

---

## Installation

### Quick Install

**For standalone BattleMedic recovery:**

```powershell
# Import module directly (no installation needed)
cd C:\kenl\modules\Surface_Pro_4_EoL_BattleMedic_v2.1
Import-Module .\BattleMedic.psd1
```

### Permanent Installation

**To install to PowerShell module path:**

```powershell
# Copy to user module directory
$destination = Join-Path $HOME "Documents\PowerShell\Modules\BattleMedic"
Copy-Item -Path "C:\kenl\modules\Surface_Pro_4_EoL_BattleMedic_v2.1" -Destination $destination -Recurse -Force

# Import from modules path
Import-Module BattleMedic
```

### Verification

```powershell
# Verify module loaded
Get-Module BattleMedic

# Run requirements test
.\Test-BattleMedicRequirements.ps1 -Verbose

# Initialize module
Initialize-BattleMedic
```

---

## Configuration

### Configuration Files

| File | Location | Purpose |
|------|----------|---------|
| `Config.json` | `C:\ProgramData\BattleMedic\` | Runtime configuration |
| `LastState.json` | `C:\ProgramData\BattleMedic\` | Persistent state tracking |

### Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `BATTLEMEDIC_LOG_DIR` | `C:\ProgramData\BattleMedic\Logs` | Log file location |
| `BATTLEMEDIC_VERBOSE` | `false` | Enable verbose logging |

### Module Parameters

Configure during initialization:

```powershell
Initialize-BattleMedic -Config @{
    VerboseLogging = $true
    EnableSAIF = $true
    SP4Optimizations = $true
    AutoCheckpoint = $true
}
```

---

## Usage

### Basic Usage

```powershell
# Import module
Import-Module BattleMedic

# Initialize
Initialize-BattleMedic

# Quick diagnostic
Get-BattleMedicDiagnostic -Quick

# Full diagnostic with hardware
Get-BattleMedicDiagnostic -IncludeHardware

# Automated recovery
Start-BattleMedicRecovery -Auto

# Guided recovery (interactive)
Show-RecoveryMenu
```

### wof.sys Specific Recovery

```powershell
# Emergency wof.sys repair
Repair-WOFDriver -Force -DisableCompactOS

# With backup creation
Repair-WOFDriver -Force -CreateBackup -DisableCompactOS

# Offline repair (from WinRE)
.\Modules\BattleMedic.WinRE.psm1 -OfflineMode -TargetDrive C: -RepairWOF
```

### Surface Pro 4 Specific

```powershell
# SP4 hardware status
Get-SP4Status -Detailed

# Screen flicker fix
Repair-SP4ScreenFlicker

# Thermal mitigation
Start-SP4ThermalMitigation
```

---

## Integration Points

### Integration with KENL Framework

Battle Medic is designed as a standalone module but integrates with:

- **KENL.SAIF**: Uses SAIF-compliant logging format
- **KENL Core**: Shares ATOM trail methodology
- **KENL Documentation**: Obsidian vault structure compatible

### Integration with Windows

- **Event Viewer**: Logs to Application and System logs
- **Task Scheduler**: Can be scheduled for preventive diagnostics
- **Windows Recovery**: Works in WinRE offline mode
- **System Restore**: Creates checkpoints before operations

### Integration with Monitoring

**Signal-CLI integration** (optional):
```powershell
# Send recovery notifications via Signal
Initialize-BattleMedic -SignalCLI -Recipient "+1234567890"
```

---

## ATOM Traceability

### ATOM Tags

| Tag | Purpose |
|-----|---------|
| `ATOM-DOC-20251126-001` | This manifest creation |
| `ATOM-RECOVERY-YYYYMMDD-NNN` | Recovery operation logs |
| `ATOM-DIAG-YYYYMMDD-NNN` | Diagnostic reports |

### Logging

- **Log Location:** `C:\ProgramData\BattleMedic\Logs\`
- **Log Format:** SAIF-compliant JSON + plaintext summaries
- **Retention:** 30 days default (configurable)

**Example log entry:**

```json
{
  "Timestamp": "2025-11-26T14:30:22.123Z",
  "ATOM": "ATOM-RECOVERY-20251126-001",
  "Component": "BattleMedic",
  "Version": "2.1.0",
  "Action": "Repair-WOFDriver",
  "Result": "Success",
  "Duration": "15m23s",
  "User": "SYSTEM\\Administrator",
  "Details": {
    "DriverStatus": "Corrupted -> Healthy",
    "CompactOS": "Disabled",
    "BackupCreated": true
  }
}
```

---

## Testing & Validation

### Pre-Deployment Testing

```powershell
# Comprehensive requirements test
.\Test-BattleMedicRequirements.ps1 -GenerateReport

# Review report
Get-Content BattleMedic_Requirements_*.json | ConvertFrom-Json
```

### Unit Tests

```powershell
# Test idempotency
Initialize-BattleMedic
Initialize-BattleMedic  # Should be safe to re-run

# Test diagnostic consistency
$diag1 = Get-BattleMedicDiagnostic -Quick
$diag2 = Get-BattleMedicDiagnostic -Quick
$diag1.Priority -eq $diag2.Priority  # Should be True
```

### Validation Checklist

- [ ] Module imports without errors
- [ ] Requirements test passes
- [ ] Initialization succeeds
- [ ] Diagnostic returns valid priority
- [ ] Checkpoint creation works
- [ ] Repair operations are idempotent
- [ ] Logging functions correctly
- [ ] SP4 detection works (if applicable)

---

## Rollback & Recovery

### Uninstallation

```powershell
# Remove from PowerShell modules
$modulePath = Join-Path $HOME "Documents\PowerShell\Modules\BattleMedic"
if (Test-Path $modulePath) {
    Remove-Module BattleMedic -ErrorAction SilentlyContinue
    Remove-Item $modulePath -Recurse -Force
}

# Clean up configuration
Remove-Item "C:\ProgramData\BattleMedic" -Recurse -Force -ErrorAction SilentlyContinue
```

### Rollback Procedure

**If a recovery operation fails:**

```powershell
# List available restore points
Get-ComputerRestorePoint | Where-Object { $_.Description -like "*BattleMedic*" }

# Restore to checkpoint
Restore-Computer -RestorePoint <RestorePointNumber> -Confirm
```

---

## Maintenance

### Update Procedure

```powershell
# Update module (manual)
cd C:\kenl
git pull

# Re-import updated module
Remove-Module BattleMedic -ErrorAction SilentlyContinue
Import-Module C:\kenl\modules\Surface_Pro_4_EoL_BattleMedic_v2.1\BattleMedic.psd1 -Force
```

### Health Checks

```powershell
# Module health check
Get-Module BattleMedic | Select Name, Version, ExportedCommands

# Verify SAIF logging
Test-Path "C:\ProgramData\BattleMedic\Logs"

# Check for corrupted config
Get-Content "C:\ProgramData\BattleMedic\Config.json" -ErrorAction SilentlyContinue | ConvertFrom-Json
```

---

## Known Issues

### Current Limitations

1. **PowerShell 3.0 Support**: Limited functionality on PS 3.0 (full features require 5.1+)
2. **WinRE Offline Mode**: Requires Windows ADK on recovery media for some operations
3. **SP4 Battery Warnings**: Some operations blocked on low battery (<30%)
4. **CompactOS**: Disabling CompactOS can increase disk usage by 2-4GB

### Compatibility

| Windows Version | Support Level |
|----------------|---------------|
| Windows 10 1507-1909 | Limited (EOL OS) |
| Windows 10 2004+ | Full support |
| Windows 11 | Full support |
| Windows Server 2016+ | Core functions only (no SP4 features) |

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.1.0 | 2025-11-26 | Added Obsidian vault, wof.sys emergency protocol |
| 2.0.0 | 2024-11-24 | Complete rewrite with SAIF compliance |
| 1.0.0 | 2024-03-15 | Initial release for SP4 screen flicker issue |

---

## References

### Internal Documentation

- `BattleMedic-Complete-Manual.md` - Comprehensive guide
- `Obsidian_Vault/` - Recovery workflow documentation
- `Test-BattleMedicRequirements.ps1` - Pre-flight testing

### External Resources

- [Microsoft: wof.sys Overview](https://learn.microsoft.com/en-us/windows-hardware/drivers/ifs/wof-sys)
- [Surface Pro 4 Support](https://support.microsoft.com/en-us/surface)
- [Windows ADK](https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install)

---

## Metadata

- **Created:** 2025-11-26
- **Last Updated:** 2025-11-26
- **Maintainer:** KENL Project
- **ATOM Tag:** ATOM-DOC-20251126-001
- **Classification:** OWI-DOC
- **Status:** Production
- **Target Use Case:** Surface Pro 4 wof.sys recovery

---

## Quick Reference Card

```
╔══════════════════════════════════════════════════════════╗
║           Battle Medic Quick Reference                   ║
╠══════════════════════════════════════════════════════════╣
║ Emergency wof.sys Fix:                                   ║
║   Repair-WOFDriver -Force -DisableCompactOS              ║
║                                                           ║
║ Quick Diagnostic:                                        ║
║   Get-BattleMedicDiagnostic -Quick                       ║
║                                                           ║
║ Create Checkpoint:                                       ║
║   New-RecoveryCheckpoint -Name "PreRecovery"             ║
║                                                           ║
║ SP4 Screen Flicker:                                      ║
║   Repair-SP4ScreenFlicker                                ║
║                                                           ║
║ Full Recovery:                                           ║
║   Start-BattleMedicRecovery -Auto                        ║
╚══════════════════════════════════════════════════════════╝
```

---

*Module Status: Production Ready*
*Documentation Status: Complete*
*Last Validation: 2025-11-26*
