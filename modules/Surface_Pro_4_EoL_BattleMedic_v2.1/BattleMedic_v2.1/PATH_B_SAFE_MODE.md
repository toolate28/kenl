---
title: Path B - Safe Mode Recovery
tags: [path-b, safe-mode, medium-recovery]
created: 2025-11-26
priority: P0
estimated-time: 30-45 minutes
difficulty: Medium
---

# 🟡 Path B: Safe Mode Recovery

[[01_DECISION_TREE|← Back to Decision Tree]] | [[00_HOME|← Home]]

---

## ✅ You're Here Because

- Your Surface Pro 4 **cannot** boot to Windows normally
- Safe Mode **works** (you can boot to Safe Mode desktop)
- You need to repair system from Safe Mode

**This is the most common recovery path for wof.sys issues**

---

## ⏱️ Time Required

- **Estimated**: 30-45 minutes
- **Success Rate**: 85-90%
- **Difficulty**: Medium

---

## 🎯 Step 1: Boot to Safe Mode

### If Not Already in Safe Mode:

1. **Restart** Surface Pro 4
2. During startup, press **F8** repeatedly (or **Shift + F8**)
3. You'll see "Advanced Boot Options" menu
4. Select: **Safe Mode with Networking** (preferred)
   - Or: **Safe Mode with Command Prompt**

### Verify You're in Safe Mode:

- [ ] "Safe Mode" text in screen corners
- [ ] Low resolution display (800x600 or similar)
- [ ] Black desktop background
- [ ] Only essential drivers loaded

**If Safe Mode won't boot**: [[PATH_C_WINRE_OFFLINE|Escalate to Path C (WinRE)]]

---

## 🚀 Step 2: Open Command Prompt as Administrator

1. Press `Win + R`
2. Type: `cmd`
3. Press `Ctrl + Shift + Enter` (runs as admin)
4. Click **Yes** on UAC prompt

**Verify**: Title bar shows "Administrator: Command Prompt"

---

## 📂 Step 3: Navigate to BattleMedic

```cmd
cd C:\kenl\modules\Surface_Pro_4_EoL_BattleMedic_v2.1
```

**If path doesn't exist**, find it:
```cmd
dir C:\ /s /b | findstr BattleMedic
```
Then use that path.

---

## 🔧 Step 4: Run Safe Mode Recovery

**Single command that does everything:**

```powershell
powershell.exe -ExecutionPolicy Bypass -NoProfile -Command "Import-Module .\BattleMedic.psd1; Start-BattleMedicRecovery -SafeMode -Priority P0 -AutoApprove"
```

**What this does**:
1. Launches PowerShell in Safe Mode compatible mode
2. Imports BattleMedic with elevated privileges
3. Runs P0 (critical) recovery operations automatically
4. Targets wof.sys specifically

---

## ⏳ Step 5: Wait for Completion

**Expected duration**: 20-30 minutes

**You'll see progress like**:
```
[Safe Mode Recovery Initiated]
Detecting critical issues... Found 1 P0 issue
P0-001: wof.sys driver corruption detected

Creating Safe Mode checkpoint...
Analyzing file system integrity...
Disabling CompactOS (Safe Mode)...
Extracting clean wof.sys from component store...
Replacing corrupted driver...
Updating driver database...
Verifying repair...

[Recovery Complete - System restart required]
```

**⚠️ DO NOT close window or interrupt!**

---

## ✅ Step 6: Verify Success

Look for final message:
```
✓ Recovery completed successfully
⚠ System restart required to load new driver
```

**If you see errors**: → [[#Troubleshooting|Troubleshooting]]

---

## 🔄 Step 7: Restart to Normal Mode

```cmd
shutdown /r /t 30 /c "BattleMedic recovery complete - restarting in 30 seconds"
```

**You have 30 seconds** to abort if needed: `shutdown /a`

---

## 🔍 Post-Restart Checks

After restarting to normal Windows:

### 1. Verify Normal Boot

- [ ] System boots past Windows logo
- [ ] No green screen/BSOD
- [ ] Login screen appears
- [ ] Desktop loads completely

**If still BSOD**: → [[#Still Getting BSOD|Troubleshooting: Still Getting BSOD]]

### 2. Check Event Viewer

```powershell
# Open PowerShell (normal mode, as admin)
Get-WinEvent -FilterHashtable @{
    LogName='System'
    Level=1,2,3
} -MaxEvents 50 |
Where-Object {$_.Message -like '*wof*'}
```

**Expected**: No recent wof.sys errors

### 3. Run Diagnostic

```powershell
cd C:\Users\iamto\kenl\modules\Surface_Pro_4_EoL_BattleMedic_v2.1
Import-Module .\BattleMedic.psd1

$diag = Get-BattleMedicDiagnostic -Quick
$diag.Priority  # Should be P2 or P3
```

---

## ✅ Success! Next Steps

If all checks passed:

1. **Full verification**: [[05_VERIFICATION_TESTS|Verification Tests]]
2. **Document recovery**: [[06_RECOVERY_LOG_TEMPLATE|Recovery Log Template]]
3. **Monitor 24-48 hours** for stability

---

## ❌ Troubleshooting

### Safe Mode Won't Boot

**Problem**: F8 menu doesn't appear or Safe Mode crashes

**Solution 1: Force Advanced Boot Options**
```cmd
# From normal (failing) boot, force shutdown 3 times
# Hold power button 10 seconds each time
# On 3rd boot, "Automatic Repair" appears
# Select: Troubleshoot → Advanced Options → Startup Settings → Restart
# Press 4 or F4 for Safe Mode
```

**Solution 2: Boot from WinRE**
→ [[PATH_C_WINRE_OFFLINE|Escalate to Path C (WinRE Offline)]]

---

### BattleMedic Not Found

**Problem**: `cd C:\kenl\...` fails

**Find BattleMedic location**:
```cmd
dir C:\ /s /b | findstr BattleMedic.psd1
```

**Or check common locations**:
```cmd
dir "C:\Users\iamto\kenl\modules\Surface_Pro_4_EoL_BattleMedic_v2.1\BattleMedic.psd1"
dir "C:\kenl\modules\Surface_Pro_4_EoL_BattleMedic_v2.1\BattleMedic.psd1"
dir "C:\BattleMedic\BattleMedic.psd1"
```

**Use whichever path exists** in subsequent commands.

---

### Recovery Command Fails

**Problem**: PowerShell command returns errors

**Common errors**:

| Error | Solution |
|-------|----------|
| "Execution policy" | Already bypassed in command, verify you copied it exactly |
| "Module not found" | Check path to BattleMedic.psd1 is correct |
| "Access denied" | Run Command Prompt as Administrator (Step 2) |
| "WOF driver in use" | Some services still running in Safe Mode, try Safe Mode with Command Prompt |

**Alternative: Manual Safe Mode repair**:
```powershell
# Run these commands one by one
powershell.exe -ExecutionPolicy Bypass -NoProfile

cd C:\kenl\modules\Surface_Pro_4_EoL_BattleMedic_v2.1
Import-Module .\BattleMedic.psd1 -Force

Initialize-BattleMedic
$checkpoint = New-RecoveryCheckpoint -Name "SafeMode_Repair"
Repair-WOFDriver -Force -DisableCompactOS -SafeMode
```

---

### Still Getting BSOD After Restart

**Problem**: Repaired in Safe Mode, but normal boot still crashes

**Possible causes**:
1. Other corrupted drivers loading in normal mode
2. WOF repair incomplete
3. Additional system file corruption

**Solutions**:

**Option 1: Boot back to Safe Mode and run full SFC**:
```cmd
# In Safe Mode Command Prompt
sfc /scannow
# Wait 15-20 minutes

DISM /Online /Cleanup-Image /RestoreHealth
# Wait another 15-20 minutes

shutdown /r /t 60
```

**Option 2: Try offline repair**:
→ [[PATH_C_WINRE_OFFLINE|Path C: WinRE Offline Recovery]]

**Option 3: Restore Safe Mode checkpoint**:
```powershell
# In Safe Mode
Get-ComputerRestorePoint | Format-List
Restore-Computer -RestorePoint <number>
```

---

### Recovery Says "No Issues Found"

**Problem**: BattleMedic says everything is OK, but system still crashes in normal mode

**Likely cause**: Issue is **not** wof.sys - different problem

**Next steps**:
1. **Check actual BSOD error**:
   - What STOP code appears?
   - Is it really 0xD3?
   - Take photo of BSOD screen

2. **Run full diagnostic**:
   ```powershell
   # In Safe Mode
   Get-BattleMedicDiagnostic -IncludeHardware -Detailed | Format-List
   ```

3. **Check other common SP4 issues**: [[08_SP4_KNOWN_ISSUES|SP4 Known Issues]]

---

## 🔗 Quick Links

- [[01_DECISION_TREE|← Back to Decision Tree]]
- [[PATH_C_WINRE_OFFLINE|Escalate to Path C (WinRE)]]
- [[PATH_A_NORMAL_BOOT|De-escalate to Path A (if normal boot works now)]]
- [[05_VERIFICATION_TESTS|Verification Tests]]
- [[00_HOME|← Home]]

---

*Path B: Safe Mode Recovery*
*Success Rate: 85-90%*
*Last Updated: 2025-11-26*
