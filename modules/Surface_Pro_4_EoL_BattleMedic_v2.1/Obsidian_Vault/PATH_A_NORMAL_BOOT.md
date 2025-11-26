---
title: Path A - Normal Boot Recovery
tags: [path-a, normal-boot, easy-recovery]
created: 2025-11-26
priority: P0
estimated-time: 20-30 minutes
difficulty: Easy
---

# 🟢 Path A: Normal Boot Recovery

[[01_DECISION_TREE|← Back to Decision Tree]] | [[00_HOME|← Home]]

---

## ✅ You're Here Because

- Your Surface Pro 4 boots to Windows desktop
- You can log in normally
- System may be slow or showing errors, but it's usable

**Good news**: This is the easiest recovery path with highest success rate!

---

## ⏱️ Time Required

- **Estimated**: 20-30 minutes
- **Success Rate**: 90-95%
- **Difficulty**: Easy

---

## 📋 What You'll Need

- [ ] Administrative access to your Surface Pro 4
- [ ] Stable power source (plugged in, >30% battery)
- [ ] BattleMedic module accessible at: `C:\kenl\modules\Surface_Pro_4_EoL_BattleMedic_v2.1\`

---

## 🚀 Recovery Steps

### Step 1: Open PowerShell as Administrator

1. Press `Win + X`
2. Select **Windows PowerShell (Admin)** or **Terminal (Admin)**
3. Click **Yes** on UAC prompt

**Verify**: Window title shows "Administrator"

---

### Step 2: Navigate to BattleMedic

```powershell
cd C:\Users\iamto\kenl\modules\Surface_Pro_4_EoL_BattleMedic_v2.1
```

**Verify it worked**:
```powershell
Test-Path .\BattleMedic.psd1
# Should return: True
```

**If False**: BattleMedic not at this location
→ [[#BattleMedic Not Found|Troubleshooting: BattleMedic Not Found]]

---

### Step 3: Run Requirements Test

```powershell
.\Test-BattleMedicRequirements.ps1 -Verbose
```

**Expected output**: Green "✓ SYSTEM IS READY FOR BATTLE MEDIC DEPLOYMENT" at end

**If failed**: See [[02_REQUIREMENTS_CHECKLIST|Requirements Checklist]]

---

### Step 4: Import BattleMedic Module

```powershell
Import-Module .\BattleMedic.psd1 -Force -Verbose
```

**Expected output**:
```
VERBOSE: Loading module from path '...\BattleMedic.psd1'
VERBOSE: Importing function 'Initialize-BattleMedic'
VERBOSE: Importing function 'Repair-WOFDriver'
...
```

**Verify**:
```powershell
Get-Command -Module BattleMedic
# Should show 15+ commands
```

---

### Step 5: Create Recovery Checkpoint

**⚠️ IMPORTANT**: This creates a restore point before making changes

```powershell
$checkpoint = New-RecoveryCheckpoint -Name "Pre_WOF_Repair_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
```

**Save the checkpoint name** (you'll need it if rollback required):
```powershell
$checkpoint.Name | Tee-Object -FilePath "checkpoint_name.txt"
```

---

### Step 6: Run Automated wof.sys Repair

**🎯 This is the main repair operation**

```powershell
$repair = Repair-WOFDriver -Force -DisableCompactOS -CreateBackup -Verbose
```

**What happens**:
1. ✓ Checks wof.sys driver status
2. ✓ Creates backup of current driver
3. ✓ Disables CompactOS (common corruption cause)
4. ✓ Replaces corrupted driver with clean version
5. ✓ Re-registers driver
6. ✓ Verifies repair

**Expected duration**: 15-20 minutes

**⚠️ DO NOT interrupt this process!**

---

### Step 7: Monitor Progress

You'll see output like:
```
[Repair-WOFDriver]
Step 1/8: Checking wof.sys status... CORRUPTED
Step 2/8: Creating backup... Saved to C:\Windows\Temp\wof.sys.bak
Step 3/8: Disabling CompactOS... 324 files uncompressed
Step 4/8: Extracting clean driver...
Step 5/8: Replacing driver file... Success
Step 6/8: Re-registering driver... Done
Step 7/8: Updating integrity records... Done
Step 8/8: Verification... PASSED

✓ Repair completed successfully
⚠ System restart required
```

**If you see prompts**, answer:
- "Disable CompactOS?" → **Y**
- "Create backup?" → **Y**
- "Register driver?" → **Y**

---

### Step 8: Verify Repair Success

```powershell
$repair | Format-List
```

**Look for**:
- `Success = True` ✓
- `DriverStatus = Healthy` ✓
- `IntegrityCheck = Passed` ✓
- `RequiresRestart = True` ✓

**If `Success = False`**:
→ [[#Repair Failed|Troubleshooting: Repair Failed]]

---

### Step 9: Save Recovery Log

```powershell
$repair | ConvertTo-Json -Depth 5 | Out-File "Recovery_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
```

---

### Step 10: Restart System

```powershell
Restart-Computer -Force -Timeout 60
```

**You have 60 seconds** to abort: `shutdown /a`

---

## 🔍 Post-Restart Verification

After restart, complete these checks:

### 1. Did it boot normally?

- [ ] No green screen/BSOD
- [ ] Login screen appeared
- [ ] Desktop loaded
- [ ] No unexpected error messages

**If BSOD during restart**: → [[#Post-Repair BSOD|Troubleshooting: Post-Repair BSOD]]

### 2. Check Event Viewer

```powershell
Get-WinEvent -FilterHashtable @{
    LogName='System'
    StartTime=(Get-Date).AddHours(-1)
} -MaxEvents 100 |
Where-Object {$_.LevelDisplayName -in @('Error','Critical') -and $_.Message -like '*wof*'}
```

**Expected**: No results (empty)

### 3. Run Post-Recovery Diagnostic

```powershell
cd C:\Users\iamto\kenl\modules\Surface_Pro_4_EoL_BattleMedic_v2.1
Import-Module .\BattleMedic.psd1

$finalDiag = Get-BattleMedicDiagnostic -Quick
$finalDiag.Priority
```

**Expected**: P2 or P3 (should have dropped from P0/P1)

---

## ✅ Success! What Now?

If all checks passed:

1. **Complete full verification**: [[05_VERIFICATION_TESTS|Verification Tests]]
2. **Document your recovery**: [[06_RECOVERY_LOG_TEMPLATE|Recovery Log Template]]
3. **Monitor for 24 hours**: Watch for any recurring issues
4. **Update this vault**: Mark recovery as successful

---

## ❌ Troubleshooting

### BattleMedic Not Found

**Problem**: `Test-Path .\BattleMedic.psd1` returns False

**Solutions**:

1. **Search for BattleMedic**:
   ```powershell
   Get-ChildItem C:\ -Recurse -Filter "BattleMedic.psd1" -ErrorAction SilentlyContinue
   ```

2. **Clone from repository** (if needed):
   ```powershell
   cd C:\
   git clone https://github.com/toolate28/kenl.git
   cd kenl\modules\Surface_Pro_4_EoL_BattleMedic_v2.1
   ```

3. **Use alternative location**: Adjust path in commands above

---

### Repair Failed

**Problem**: `$repair.Success = False`

**Check error message**:
```powershell
$repair.Error
```

**Common errors**:

| Error | Solution |
|-------|----------|
| "Access Denied" | Run PowerShell as Administrator |
| "WOF driver in use" | Boot to Safe Mode → [[PATH_B_SAFE_MODE|Path B]] |
| "Component store corrupt" | Run DISM repair first (see below) |
| "Insufficient disk space" | Free up 5GB+ on C: drive |

**DISM repair** (if component store corrupt):
```powershell
DISM /Online /Cleanup-Image /RestoreHealth
# Wait 15-20 minutes, then retry repair
```

---

### Post-Repair BSOD

**Problem**: Green screen/BSOD after restart

**Immediate action**:

1. **Force shutdown**: Hold power button 10 seconds
2. **Boot to Safe Mode**: Press F8 during startup
3. **Restore checkpoint**:
   ```powershell
   # In Safe Mode
   Get-ComputerRestorePoint | Format-List
   # Note the checkpoint number from Step 5
   Restore-Computer -RestorePoint <number> -Confirm
   ```

4. **Try alternative path**: [[PATH_B_SAFE_MODE|Path B: Safe Mode Recovery]]

---

## 🔗 Quick Links

- [[01_DECISION_TREE|← Back to Decision Tree]]
- [[PATH_B_SAFE_MODE|Escalate to Path B (Safe Mode)]]
- [[05_VERIFICATION_TESTS|Verification Tests]]
- [[06_RECOVERY_LOG_TEMPLATE|Recovery Log Template]]
- [[00_HOME|← Home]]

---

*Path A: Normal Boot Recovery*
*Success Rate: 90-95%*
*Last Updated: 2025-11-26*
