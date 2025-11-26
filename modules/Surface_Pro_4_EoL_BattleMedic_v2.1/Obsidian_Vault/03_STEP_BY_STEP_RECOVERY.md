---
title: Step-by-Step wof.sys Recovery Guide
tags: [recovery, step-by-step, detailed-guide]
created: 2025-11-26
estimated-time: 45-60 minutes
---

# 📖 Step-by-Step wof.sys Recovery Guide

[[00_HOME|← Back to Home]] | [[02_REQUIREMENTS_CHECKLIST|← Previous: Requirements]] | [[05_VERIFICATION_TESTS|Next: Verification →]]

---

## 🎯 Overview

This guide provides detailed, numbered steps for recovering from wof.sys BSOD errors using BattleMedic v2.1.

**Before Starting**: Ensure you've completed [[02_REQUIREMENTS_CHECKLIST]]

---

## 📝 Pre-Recovery Documentation

### System Information Snapshot
Document your system state before recovery:

```powershell
# Run this and save output
$snapshot = @{
    ComputerName = $env:COMPUTERNAME
    Date = Get-Date
    OS = Get-ComputerInfo | Select WindowsVersion, WindowsBuildLabEx
    PowerShell = $PSVersionTable.PSVersion
    LastBoot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
}
$snapshot | ConvertTo-Json | Out-File "Recovery_PreSnapshot_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
```

### Identify Current Issues
```powershell
# Check Event Viewer for wof.sys errors
Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2,3} -MaxEvents 50 |
    Where-Object {$_.Message -like '*wof*'} |
    Select TimeCreated, Id, Message |
    Format-List
```

Save this output to document the problem.

---

## 🚀 Recovery Procedure

### Phase 1: Environment Setup (10 minutes)

#### Step 1: Open PowerShell as Administrator
1. Press `Win + X`
2. Select **Windows PowerShell (Admin)** or **Terminal (Admin)**
3. Confirm UAC prompt

**Verification**: Window title shows "Administrator"

#### Step 2: Navigate to BattleMedic Directory
```powershell
cd C:\Users\iamto\kenl\modules\Surface_Pro_4_EoL_BattleMedic_v2.1
```

**Verification**:
```powershell
# Should return True
Test-Path .\BattleMedic.psd1
```

#### Step 3: Run Requirements Test
```powershell
.\Test-BattleMedicRequirements.ps1 -Verbose
```

**Expected Output**: Green "✓ SYSTEM IS READY" message at end

**If Failed**: See [[02_REQUIREMENTS_CHECKLIST#If Requirements Fail]]

#### Step 4: Import BattleMedic Module
```powershell
Import-Module .\BattleMedic.psd1 -Force -Verbose
```

**Expected Output**:
```
VERBOSE: Loading module from path 'C:\...\BattleMedic.psd1'
VERBOSE: Importing function 'Initialize-BattleMedic'
VERBOSE: Importing function 'Repair-WOFDriver'
...
```

**Verification**:
```powershell
Get-Command -Module BattleMedic | Measure-Object | Select Count
# Should show multiple commands (20+)
```

### Phase 2: Diagnostic Assessment (5-10 minutes)

#### Step 5: Initialize BattleMedic
```powershell
Initialize-BattleMedic -VerboseLogging
```

**What this does**:
- Creates log directory structure
- Configures SAIF compliance
- Loads SP4-specific profiles (if applicable)
- Prepares recovery environment

**Expected Output**:
```
[BattleMedic Initialization]
✓ Log directory created: C:\ProgramData\BattleMedic\Logs
✓ SAIF compliance enabled
✓ Surface Pro 4 profile loaded
✓ Recovery environment ready
```

#### Step 6: Run Full Diagnostic
```powershell
$diag = Get-BattleMedicDiagnostic -IncludeHardware -Detailed
$diag | Format-List
```

**What to look for**:
- **Priority**: Should show P0 or P1 if wof.sys is corrupted
- **Issues**: Should list wof.sys corruption explicitly
- **Critical**: Any issues marked as critical

**Example Output**:
```
Priority     : P0
Severity     : Critical
Issues       : {wof.sys driver corruption detected}
DiskSpace    : 45.2 GB free
Temperature  : 42°C
CanAutoFix   : True
RequiresRestart : True
```

#### Step 7: Review Diagnostic Report
```powershell
# Save diagnostic for documentation
$diag | ConvertTo-Json -Depth 5 | Out-File "Diagnostic_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
```

### Phase 3: Recovery Checkpoint (5 minutes)

#### Step 8: Create Recovery Checkpoint
```powershell
$checkpoint = New-RecoveryCheckpoint -Name "Pre_WOF_Repair_$(Get-Date -Format 'yyyyMMdd_HHmmss')" -Description "Checkpoint before wof.sys repair"
```

**Expected Output**:
```
Creating recovery checkpoint...
✓ Volume shadow copy created
✓ Checkpoint registered: Pre_WOF_Repair_20251126_143022
✓ Rollback point available
```

**Important**: Note the checkpoint name - save it for rollback if needed:
```powershell
$checkpoint.Name | Out-File "checkpoint_name.txt"
```

#### Step 9: Verify Checkpoint Created
```powershell
Get-ComputerRestorePoint | Select-Object -First 1 | Format-List
```

Should show your newly created checkpoint at the top.

### Phase 4: wof.sys Repair (15-25 minutes)

#### Step 10: Execute Automated Repair
```powershell
$repair = Repair-WOFDriver -Force -DisableCompactOS -CreateBackup -Verbose
```

**What this does** (in order):
1. Checks current wof.sys driver status
2. Creates backup of existing driver
3. Disables Windows CompactOS feature (common cause)
4. Extracts clean wof.sys from Windows component store
5. Replaces corrupted driver file
6. Re-registers driver in driver database
7. Updates system file integrity records
8. Verifies repair success

**Expected Duration**: 15-20 minutes

**Progress Indicators**:
```
[Repair-WOFDriver]
Step 1/8: Checking wof.sys status... CORRUPTED (0xD3 signature mismatch)
Step 2/8: Creating backup... Saved to C:\Windows\Temp\wof.sys.bak
Step 3/8: Disabling CompactOS... 324 files uncompressed
Step 4/8: Extracting clean driver from component store...
Step 5/8: Replacing driver file... Success
Step 6/8: Re-registering driver... Driver database updated
Step 7/8: Updating file integrity records... SFC database refreshed
Step 8/8: Verification... PASSED (signature valid, no corruption)

✓ Repair completed successfully
⚠ System restart required to load new driver
```

#### Step 11: Monitor Repair Process
**DO NOT** close PowerShell or interrupt this process!

If prompted for confirmation, type `Y` and press Enter.

**Common prompts**:
- "Disable CompactOS? This may take several minutes." → **Yes**
- "Create backup before replacing driver?" → **Yes**
- "Register new driver immediately?" → **Yes**

#### Step 12: Review Repair Results
```powershell
$repair | Format-List
```

**Success indicators**:
- `Success = True`
- `DriverStatus = Healthy`
- `IntegrityCheck = Passed`
- `RequiresRestart = True`

**Failure indicators**:
- `Success = False`
- `Error = <error message>`

**If Failed**: See [[04_TROUBLESHOOTING#Repair Failed]]

### Phase 5: System File Integrity (10-15 minutes)

#### Step 13: Run System File Checker
```powershell
# This verifies all system files, not just wof.sys
sfc /scannow
```

**Expected Duration**: 10-15 minutes

**Expected Output**:
```
Beginning system scan. This process will take some time.
...
Verification 100% complete.

Windows Resource Protection did not find any integrity violations.
```

**Alternative output** (also good):
```
Windows Resource Protection found corrupt files and successfully repaired them.
Details are included in CBS.Log
```

**If it says "could not repair"**: Continue anyway, the wof.sys specific repair was already done.

#### Step 14: Check for Remaining Issues
```powershell
$postDiag = Get-BattleMedicDiagnostic -Quick
$postDiag.Priority
```

**Expected**: P2 or P3 (priority should have dropped from P0/P1)

### Phase 6: System Restart (5 minutes)

#### Step 15: Save All Recovery Information
```powershell
# Create comprehensive recovery log
$recoveryLog = @{
    Date = Get-Date
    PreDiagnostic = $diag
    Repair = $repair
    PostDiagnostic = $postDiag
    Checkpoint = $checkpoint
}

$recoveryLog | ConvertTo-Json -Depth 5 | Out-File "Recovery_Complete_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
```

#### Step 16: Prepare for Restart
```powershell
# Close all applications and save work
# BattleMedic will restart in 60 seconds
Restart-Computer -Force -Timeout 60
```

**You have 60 seconds** to abort if needed: `shutdown /a`

#### Step 17: Monitor Restart
Watch for:
- ✅ No green screen/BSOD during restart
- ✅ Windows logo appears normally
- ✅ Login screen loads
- ✅ Desktop appears without errors

**If BSOD during restart**:
1. Force shutdown (hold power button)
2. Boot to Safe Mode
3. Restore checkpoint from Step 8
4. See [[04_TROUBLESHOOTING#Post-Repair BSOD]]

### Phase 7: Post-Restart Verification (10 minutes)

#### Step 18: Log Back In
Log in to Windows normally.

#### Step 19: Verify System Health
```powershell
# Re-open PowerShell as Administrator
cd C:\Users\iamto\kenl\modules\Surface_Pro_4_EoL_BattleMedic_v2.1
Import-Module .\BattleMedic.psd1

# Run post-recovery diagnostic
$finalDiag = Get-BattleMedicDiagnostic -IncludeHardware
$finalDiag | Format-List
```

**Success Indicators**:
- `Priority`: P3 (Low) or P2 (Medium)
- `WOFStatus`: Healthy
- `DriverIntegrity`: Valid
- `SystemFileHealth`: Clean

#### Step 20: Check Event Viewer
```powershell
# Look for wof.sys errors (should be NONE)
Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=(Get-Date).AddHours(-1)} -MaxEvents 100 |
    Where-Object {$_.LevelDisplayName -in @('Error','Critical') -and $_.Message -like '*wof*'}
```

**Expected Result**: No results (empty)

**If errors found**: Document them and see [[04_TROUBLESHOOTING]]

#### Step 21: Run Full Verification Suite
Navigate to [[05_VERIFICATION_TESTS]] and complete all tests.

---

## ✅ Recovery Success Criteria

You can consider recovery successful when ALL of these are true:

- [ ] System boots to desktop without green screen
- [ ] No wof.sys errors in Event Viewer (last 24 hours)
- [ ] `Get-BattleMedicDiagnostic` shows Priority P2 or P3
- [ ] System File Checker reports no violations
- [ ] DISM health check passes (if run)
- [ ] System remains stable for 1+ hours
- [ ] Sleep/wake cycle works (if tested)
- [ ] No unexpected reboots

---

## 📝 Document Your Recovery

Complete [[06_RECOVERY_LOG_TEMPLATE]] with:
- Diagnostic results (before/after)
- Repair output
- Any errors encountered
- Time taken for each phase
- Final system status

This creates a record for future reference and helps if issues recur.

---

## 🔗 Navigation

- [[00_HOME|← Back to Home]]
- [[02_REQUIREMENTS_CHECKLIST|← Previous: Requirements Checklist]]
- [[04_TROUBLESHOOTING|Next: Troubleshooting Guide →]]
- [[05_VERIFICATION_TESTS|Next: Verification Tests →]]

---

*Last Updated: 2025-11-26*
*Estimated Total Time: 45-60 minutes*
*Success Rate: 85-95% (typical scenarios)*
