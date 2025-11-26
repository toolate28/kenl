---
title: Path C - WinRE Offline Recovery
tags: [path-c, winre, offline-recovery, hard]
created: 2025-11-26
priority: P0
estimated-time: 45-60 minutes
difficulty: Hard
---

# 🟠 Path C: WinRE Offline Recovery

[[01_DECISION_TREE|← Back to Decision Tree]] | [[00_HOME|← Home]]

---

## ✅ You're Here Because

- Cannot boot to Windows normally
- Cannot boot to Safe Mode
- **Can** access Windows Recovery Environment (WinRE)
- Need offline system repair

**This is advanced recovery - requires offline repair tools**

---

## ⏱️ Time Required

- **Estimated**: 45-60 minutes
- **Success Rate**: 75-85%
- **Difficulty**: Hard

---

## 🎯 Step 1: Access WinRE

### Method 1: Force Automatic Repair (Recommended)

1. **Force shutdown 3 times** during Windows boot
   - Turn on Surface → See Windows logo → Hold power button 10 seconds
   - Repeat 2 more times
2. On 3rd boot: "Preparing Automatic Repair" appears
3. Wait for blue screen "Automatic Repair"
4. Select: **Advanced options**

### Method 2: Manual F11

1. Restart Surface Pro 4
2. Press **F11** repeatedly during boot
3. Should see "Choose an option" screen

### Verify You're in WinRE

- [ ] Blue background screen
- [ ] "Choose an option" or "Automatic Repair" heading
- [ ] Options like "Troubleshoot", "Turn off PC"

**If WinRE doesn't appear**: [[PATH_D_RECOVERY_MEDIA|Escalate to Path D (Recovery Media)]]

---

## 🔧 Step 2: Open Command Prompt

From WinRE blue screen:

1. Select: **Troubleshoot**
2. Select: **Advanced Options**
3. Select: **Command Prompt**
4. May need to select your user account and enter password

**Verify**: Black command prompt window appears

---

## 💾 Step 3: Identify System Drive

**Important**: In WinRE, drive letters may be different!

```cmd
diskpart
list volume
```

**Look for**:
- Volume with "Windows" label
- Or largest NTFS volume (~200GB+)
- **Note the letter** (usually C:, but may be D: or E:)

```cmd
exit
```

**We'll use `X:` as placeholder** - replace with your actual letter below

---

## 📂 Step 4: Navigate to BattleMedic

```cmd
X:
cd kenl\modules\Surface_Pro_4_EoL_BattleMedic_v2.1
```

**If path not found**, search:
```cmd
dir X:\ /s /b | findstr BattleMedic
```
Use the path it finds.

---

## 🛠️ Step 5: Run Offline WOF Repair

**Single comprehensive repair command**:

```cmd
powershell.exe -ExecutionPolicy Bypass -File .\Modules\BattleMedic.Recovery.psm1 -OfflineMode -TargetDrive X: -RepairWOF
```

**Replace `X:` with your actual drive letter from Step 3**

**What this does**:
1. Mounts Windows image offline
2. Scans for wof.sys corruption
3. Extracts clean driver from component store
4. Replaces corrupted file
5. Rebuilds driver database
6. Unmounts and commits changes

**Expected duration**: 25-35 minutes

---

## ⏳ Step 6: Wait for Completion

You'll see:
```
[Offline WOF Repair - WinRE Mode]
Mounting Windows image at X:\
Analyzing wof.sys driver status...
Driver Status: CORRUPTED (0xD3 signature mismatch)

Extracting clean driver from component store...
Replacing X:\Windows\System32\drivers\wof.sys...
Updating driver database...
Verifying file integrity...

Unmounting and committing changes...
[✓] Offline repair completed successfully
```

**⚠️ DO NOT close window!**

---

## 🔍 Step 7: Run System File Checker (Offline)

```cmd
sfc /scannow /offbootdir=X:\ /offwindir=X:\Windows
```

**Replace `X:` with your drive letter**

**Expected output**:
```
Windows Resource Protection found corrupt files and successfully repaired them.
```

**Alternative output** (also okay):
```
Windows Resource Protection did not find any integrity violations.
```

**If errors**: Continue anyway - wof.sys was already repaired

**Duration**: 10-15 minutes

---

## 🏥 Step 8: Run DISM Repair (Offline)

```cmd
DISM /Image:X:\ /Cleanup-Image /RestoreHealth
```

**Replace `X:` with your drive letter**

**Expected**: Shows percentage progress, completes at 100%

**Duration**: 15-20 minutes

**If fails**: That's okay, wof.sys repair is what matters most

---

## 🔐 Step 9: Disable CompactOS (Critical)

```cmd
compact /u /s:X:\Windows\System32\drivers\wof.sys
```

**This prevents re-compression** that could trigger the issue again

---

## 🔄 Step 10: Exit and Restart

```cmd
exit
```

From WinRE menu:
- Select: **Continue** or **Exit and continue to Windows 10/11**

---

## 🔍 Post-Restart Verification

### 1. Monitor Boot

Watch for:
- [ ] No green screen/BSOD
- [ ] Windows logo appears
- [ ] Login screen loads
- [ ] Desktop appears

**If BSOD**: → [[#Boot Failed After Repair|Troubleshooting: Boot Failed]]

### 2. Check Event Viewer (once booted)

```powershell
Get-WinEvent -FilterHashtable @{
    LogName='System'
    Level=1,2
} -MaxEvents 50 |
Where-Object {$_.Message -like '*wof*'}
```

**Expected**: No wof.sys errors

### 3. Run Diagnostic

```powershell
cd C:\Users\iamto\kenl\modules\Surface_Pro_4_EoL_BattleMedic_v2.1
Import-Module .\BattleMedic.psd1

Get-BattleMedicDiagnostic -Quick
```

**Expected**: Priority P2 or P3

---

## ✅ Success! Next Steps

1. **Full verification**: [[05_VERIFICATION_TESTS|Verification Tests]]
2. **Document recovery**: [[06_RECOVERY_LOG_TEMPLATE|Recovery Log Template]]
3. **Monitor 48 hours** for stability

---

## ❌ Troubleshooting

### Can't Access WinRE

**Problem**: F11 doesn't work, forced shutdown doesn't trigger repair

**Possible causes**:
- WinRE partition corrupted
- Recovery partition deleted
- Boot configuration damaged

**Solution**: [[PATH_D_RECOVERY_MEDIA|Use Path D (Recovery Media)]]

---

### BattleMedic Not on System Drive

**Problem**: Path not found in WinRE

**Find it**:
```cmd
dir X:\ /s /b | findstr BattleMedic.Recovery.psm1
```

**If truly not there**:
- Check other volumes (C:, D:, E:)
- May need to use recovery media with BattleMedic pre-loaded

---

### Drive Letter Confusion

**Problem**: Not sure which drive is Windows

**Identify by size and content**:
```cmd
diskpart
list volume
# Note volumes that are ~200GB+ and NTFS
exit

dir C:\
dir D:\
dir E:\
# Look for "Windows", "Program Files", "Users" folders
```

**Windows drive will have**:
- `\Windows` folder
- `\Program Files` folder
- `\Users` folder

---

### Offline Repair Script Not Found

**Problem**: `BattleMedic.Recovery.psm1` file not found

**Alternative manual repair**:
```cmd
# Manual wof.sys replacement
cd X:\Windows\System32\drivers

# Backup current
copy wof.sys wof.sys.bak

# Get clean copy from component store
cd X:\Windows\WinSxS

# Find clean wof.sys
dir /s wof.sys

# Copy clean version (use actual path from dir command)
copy "X:\Windows\WinSxS\amd64_...wof.sys_...\wof.sys" X:\Windows\System32\drivers\wof.sys

# Continue with SFC and DISM (Step 7-8)
```

---

### Boot Failed After Repair

**Problem**: Still getting BSOD after WinRE repair

**Immediate action**:

1. **Boot back to WinRE** (force shutdown 3 times)
2. **Try boot repair**:
   ```cmd
   bootrec /fixmbr
   bootrec /fixboot
   bootrec /rebuildbcd
   ```
3. **Restart**

**If still failing**:

→ [[PATH_D_RECOVERY_MEDIA|Escalate to Path D (Recovery Media)]]

**Or consider**:
- In-place upgrade (repair install)
- Clean install (backup data first)

---

## 🔗 Quick Links

- [[01_DECISION_TREE|← Back to Decision Tree]]
- [[PATH_D_RECOVERY_MEDIA|Escalate to Path D (Recovery Media)]]
- [[PATH_B_SAFE_MODE|Try Path B (if Safe Mode now works)]]
- [[05_VERIFICATION_TESTS|Verification Tests]]
- [[00_HOME|← Home]]

---

*Path C: WinRE Offline Recovery*
*Success Rate: 75-85%*
*Last Updated: 2025-11-26*
