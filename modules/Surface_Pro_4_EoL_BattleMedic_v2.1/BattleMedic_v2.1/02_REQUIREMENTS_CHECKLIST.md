---
title: BattleMedic Requirements Checklist
tags: [requirements, prerequisites, checklist]
created: 2025-11-26
---

# ✅ BattleMedic Requirements Checklist

[[00_HOME|← Back to Home]] | [[03_STEP_BY_STEP_RECOVERY|Next: Step-by-Step Recovery →]]

---

## 🎯 Quick Validation

Run this command to automatically check all requirements:

```powershell
.\Test-BattleMedicRequirements.ps1 -Verbose -GenerateReport
```

**Expected Result**: "✓ SYSTEM IS READY FOR BATTLE MEDIC DEPLOYMENT"

---

## 📋 Manual Checklist

If automatic test fails or you want to verify manually:

### System Requirements

- [ ] **Windows Version**: Windows 10 Build 10240+ or Windows 11
  ```powershell
  Get-ComputerInfo | Select WindowsVersion, WindowsBuildLabEx
  ```

- [ ] **PowerShell Version**: 3.0 or higher (5.1+ recommended)
  ```powershell
  $PSVersionTable.PSVersion
  ```

- [ ] **Architecture**: 64-bit OS
  ```powershell
  [Environment]::Is64BitOperatingSystem
  ```

### Permissions & Access

- [ ] **Administrator Rights**: Running as Administrator
  ```powershell
  ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  ```

- [ ] **Execution Policy**: Can run scripts
  ```powershell
  Get-ExecutionPolicy
  # Should be: RemoteSigned, Unrestricted, or Bypass
  ```

### Disk Space

- [ ] **System Drive**: At least 5GB free
  ```powershell
  Get-PSDrive C | Select @{N='FreeGB';E={[Math]::Round($_.Free/1GB,2)}}
  ```

- [ ] **Temp Directory**: Space for logs and checkpoints
  ```powershell
  (Get-Item $env:TEMP).PSDrive | Select @{N='FreeGB';E={[Math]::Round($_.Free/1GB,2)}}
  ```

### Services

- [ ] **WMI Service**: Running
  ```powershell
  Get-Service winmgmt | Select Status
  ```

- [ ] **Volume Shadow Copy**: Running (for checkpoints)
  ```powershell
  Get-Service VSS | Select Status
  ```

### Battery (Mobile Devices Only)

- [ ] **Charge Level**: > 30% or plugged in
  ```powershell
  (Get-WmiObject Win32_Battery).EstimatedChargeRemaining
  ```

### Module Access

- [ ] **BattleMedic Location**: Can access module files
  ```powershell
  Test-Path "C:\kenl\modules\Surface_Pro_4_EoL_BattleMedic_v2.1\BattleMedic.psd1"
  ```

- [ ] **Module Import**: Can import without errors
  ```powershell
  Import-Module "C:\kenl\modules\Surface_Pro_4_EoL_BattleMedic_v2.1\BattleMedic.psd1" -Force
  Get-Module BattleMedic
  ```

---

## 🚨 If Requirements Fail

### PowerShell Version Too Old
**Problem**: PowerShell < 3.0

**Solution**:
```powershell
# Download and install WMF 5.1 (includes PowerShell 5.1)
# https://www.microsoft.com/en-us/download/details.aspx?id=54616
```

### Not Running as Administrator
**Problem**: Insufficient privileges

**Solution**:
```powershell
# Close current session
# Right-click PowerShell → "Run as Administrator"
```

### Execution Policy Blocked
**Problem**: Cannot run scripts

**Solution**:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

### Low Disk Space
**Problem**: < 5GB free on system drive

**Solution**:
```powershell
# Run Disk Cleanup
cleanmgr /verylowdisk

# Or manually clear temp files
Remove-Item $env:TEMP\* -Recurse -Force -ErrorAction SilentlyContinue
```

### WMI Service Not Running
**Problem**: Critical service stopped

**Solution**:
```powershell
Start-Service winmgmt
Set-Service winmgmt -StartupType Automatic
```

---

[[00_HOME|← Back to Home]] | [[03_STEP_BY_STEP_RECOVERY|Next: Step-by-Step Recovery →]]
