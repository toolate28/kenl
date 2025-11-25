# Battle Medic Recovery Suite v2.1 - Quick Reference Guide

## 🚀 Quick Start
```powershell
Import-Module BattleMedic              # Load module
Initialize-BattleMedic                 # First-time setup
Show-RecoveryMenu                      # Interactive recovery
Get-BattleMedicDiagnostic -Quick       # Fast health check
```

## 🎯 Priority Classification
| Level | **Indicators** | **Response** | **Examples** |
|-------|---------------|-------------|------------|
| **P0** | System critical, data loss imminent | Immediate (<5min) | BSOD, thermal >80°C, disk <5% |
| **P1** | Major functionality broken | Urgent (<30min) | Services down, update loops |
| **P2** | Noticeable degradation | Scheduled (<4hr) | Slow boot, app crashes |
| **P3** | Minor issues | Best effort | Temp files, optimization |

## 💊 Common Fixes
```powershell
# BSOD 0xD3 (WOF.SYS) - 15min
Repair-WOFDriver -DisableCompactOS -Force

# Emergency disk space - 20min
Start-EmergencyCleanup -TargetFreeGB 5

# System file corruption - 30min
Repair-SystemFiles -Online

# Windows Update stuck - 30min
Reset-WindowsUpdate

# Full automated recovery - 45min
Start-BattleMedicRecovery -Mode Automated -Priority P1
```

## 🔍 Diagnostic Commands
```powershell
Test-BattleMedicEnvironment    # Verify setup
Get-SystemHealthReport         # Full health report  
Test-SystemPriority           # Get priority level
Get-SP4Status                 # SP4 hardware check
Get-BattleMedicLog -Latest 10 # Recent activities
```

## 🛡️ Safety Features
- **Idempotent**: All operations safe to re-run
- **Checkpoints**: Auto-created before changes
- **Rollback**: Automatic on failure
- **State-aware**: Skips unnecessary operations
- **SAIF logging**: Full audit trail

## ⚙️ Configuration
```powershell
# View current config
Get-BattleMedicConfig

# Update settings
Set-BattleMedicConfig @{
    VerboseLogging = $true
    SAIFEnabled = $true
    AutoBackup = $true
}
```

## 🚨 SP4 Specific
```powershell
Repair-SP4ScreenFlicker        # Fix 60Hz flicker (5min)
Repair-SP4TypeCover           # Fix keyboard issues
Start-SP4ThermalMitigation    # Cool down system
Reset-SP4GPUDriver            # Fix graphics crashes
```

## 📊 Recovery Decision Tree
```
System Issue?
├─ Check Priority: Get-BattleMedicDiagnostic -Quick
├─ P0 (Critical)?
│  └─ Yes → Start-BattleMedicRecovery -Auto -Force
│  └─ No → Continue ↓
├─ P1 (High)?
│  └─ Yes → Show-RecoveryMenu → Guided Mode
│  └─ No → Continue ↓
└─ P2/P3 → Schedule maintenance window
```

## 🔧 Module Management
```powershell
# Installation
Install-Module BattleMedic -Scope CurrentUser

# Version check
Get-BattleMedicVersion

# Compatibility test  
Test-BattleMedicEnvironment

# Unload module
Remove-Module BattleMedic
```

## ⚡ Performance Expectations
| Operation | Typical Time | Resource Usage |
|-----------|-------------|----------------|
| Quick Diagnostic | 15 sec | Low CPU/RAM |
| Full Diagnostic | 2 min | Medium |
| WOF Repair | 15 min | Medium |
| SFC Scan | 30 min | Medium CPU, High disk |
| Full Recovery | 45 min | High |

## 🆘 Troubleshooting
| **Issue** | **Solution** |
|-----------|------------|
| Module won't load | Check PS version ≥3.0, run as Admin |
| Diagnostics fail | Verify WMI service running |
| Can't create checkpoint | Need admin rights + System Restore enabled |
| Operations slow | Check disk space >5GB free |
| SP4 features missing | Not Surface Pro 4 or detection failed |

## 📝 Essential Aliases
```powershell
bmr      # Start-BattleMedicRecovery
bmdiag   # Get-BattleMedicDiagnostic  
bmlog    # Get-BattleMedicLog
sp4fix   # Start-SP4Recovery
woffix   # Repair-WOFDriver
bminit   # Initialize-BattleMedic
```

## 🌟 Best Practices
1. **Always run as Administrator** for full functionality
2. **Create manual checkpoint** before major operations
3. **Check battery >30%** before recovery (mobile devices)
4. **Free 5GB+ disk space** before starting
5. **Test on non-production** system first
6. **Keep logs** for troubleshooting: `Export-BattleMedicReport`
7. **Use Guided Mode** if unsure about fixes
8. **Monitor temperature** during intensive operations

## 📞 Support Escalation
1. Check logs: `Get-BattleMedicLog -Latest 20`
2. Generate report: `Export-BattleMedicReport -Format HTML`
3. Verify environment: `Test-BattleMedicEnvironment`
4. Document priority level and error messages
5. If P0 persists after recovery → Manual intervention required

---
**Version**: 2.1.0 | **PS Requirement**: 3.0+ | **OS**: Win10 1507+ | **License**: MIT
**Docs**: `/Documentation/BattleMedic-Complete-Manual.md` | **Tests**: `Run-BattleMedicTests.ps1`
