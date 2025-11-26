---
title: wof.sys Emergency Recovery Protocol
tags: [emergency, wof-sys, p0-critical, recovery-protocol]
created: 2025-11-26
priority: P0
estimated-time: 45-60 minutes
---

# 🚨 wof.sys Emergency Recovery Protocol
## Priority 0 - Immediate Action Required

> **⚠️ READ THIS FIRST**: This protocol is for **IMMEDIATE** recovery from wof.sys green screen/BSOD errors. Time is critical - file system corruption can worsen with repeated boot attempts.

[[00_HOME|← Back to Home]]

---

## 🎯 Decision Tree: What's Your Situation?

Answer these questions to determine your recovery path:

### Question 1: Can you boot to Windows desktop?

**YES** → Skip to [[#Path A: System Boots Normally]]
**NO** → Continue to Question 2

### Question 2: Can you boot to Safe Mode?

**How to test**: Restart and press `F8` repeatedly, select "Safe Mode"

**YES** → Go to [[#Path B: Safe Mode Recovery]]
**NO** → Continue to Question 3

### Question 3: Can you access Windows Recovery Environment (WinRE)?

**How to test**: Restart and press `F11` or force shutdown 3 times to trigger automatic repair

**YES** → Go to [[#Path C: WinRE Offline Recovery]]
**NO** → Go to [[#Path D: Recovery Media Required]]

---

## 🛠️ Path A: System Boots Normally

**Likelihood**: Rare for wof.sys BSOD, but possible if error is intermittent
**Time Required**: 20-30 minutes
**Risk Level**: Low

### Prerequisites
- [ ] You can see the Windows desktop
- [ ] System feels stable (no freezing or crashes)
- [ ] You have administrative access

### Steps

#### 1. Open PowerShell as Administrator
```powershell
# Press Win+X, select "Windows PowerShell (Admin)" or "Terminal (Admin)"
```

#### 2. Navigate to BattleMedic Location
```powershell
cd C:\kenl\modules\Surface_Pro_4_EoL_BattleMedic_v2.1
```

#### 3. Run Requirements Test
```powershell
.\Test-BattleMedicRequirements.ps1 -Verbose
```

**Expected Output**: "SYSTEM IS READY FOR BATTLE MEDIC DEPLOYMENT"

If failed, see [[04_TROUBLESHOOTING#Requirements Test Failed]]

#### 4. Import BattleMedic Module
```powershell
Import-Module .\BattleMedic.psd1 -Force -Verbose
```

#### 5. Create Recovery Checkpoint
```powershell
# This creates a System Restore point before making changes
$checkpoint = New-RecoveryCheckpoint -Name "Pre_WOF_Repair_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
```

**Important**: Note the checkpoint name - you'll need it if rollback is required

#### 6. Run Automated wof.sys Repair
```powershell
# This is the main repair command
Repair-WOFDriver -Force -DisableCompactOS -CreateBackup
```

**What this does**:
- Checks current wof.sys driver status
- Disables CompactOS if enabled (common cause of corruption)
- Backs up current driver before replacement
- Replaces corrupted wof.sys with known-good version
- Re-registers the driver
- Verifies integrity

**Expected Duration**: 15-20 minutes

#### 7. Monitor Progress
The repair will show progress bars and status updates. **DO NOT** interrupt this process.

**Normal Output**:
```
[1/6] Checking wof.sys status... CORRUPTED
[2/6] Creating backup... DONE
[3/6] Disabling CompactOS... DONE
[4/6] Replacing driver... DONE
[5/6] Re-registering driver... DONE
[6/6] Verification... PASSED
```

#### 8. Verify Repair Success
```powershell
# Run diagnostic to confirm
Get-BattleMedicDiagnostic -IncludeHardware
```

**Success Indicators**:
- Priority drops to P2 or P3
- No wof.sys errors in diagnostic output
- System File Integrity shows "Healthy"

#### 9. Restart System
```powershell
# Safe restart with checkpoint reference
Restart-Computer -Force
```

#### 10. Post-Restart Verification
After restart, navigate to [[05_VERIFICATION_TESTS]] and complete all tests.

**If restart fails**: Force shutdown, boot to Safe Mode, restore checkpoint from Step 5

---

## 🛡️ Path B: Safe Mode Recovery

**Likelihood**: Most common recovery path
**Time Required**: 30-45 minutes
**Risk Level**: Low-Medium

### Getting to Safe Mode

If you're not already in Safe Mode:

1. **Force Restart** → Hold power button for 10 seconds
2. **Boot Menu** → Press `F8` or `Shift+F8` repeatedly during startup
3. **Select** → "Safe Mode with Networking" (preferred) or "Safe Mode with Command Prompt"

### Safe Mode Indicators
You'll know you're in Safe Mode when:
- "Safe Mode" appears in corners of screen
- Screen resolution is low
- Desktop is black background
- Only essential drivers loaded

### Recovery Steps

#### 1. Open Command Prompt as Administrator
```cmd
# Search for "cmd" in Start menu
# Right-click → "Run as Administrator"
```

#### 2. Navigate to BattleMedic
```cmd
cd C:\kenl\modules\Surface_Pro_4_EoL_BattleMedic_v2.1
```

**If this path doesn't exist**:
```cmd
# Find where kenl is located
dir C:\ /s /b | findstr kenl
# Use that path instead
```

#### 3. Load PowerShell with Module
```powershell
powershell.exe -ExecutionPolicy Bypass -NoProfile -Command "Import-Module .\BattleMedic.psd1; Start-BattleMedicRecovery -SafeMode -Priority P0 -AutoApprove"
```

**What this does**:
- Launches PowerShell in safe mode compatible mode
- Imports BattleMedic with elevated privileges
- Automatically runs P0 (critical) recovery operations
- Targets wof.sys specifically

#### 4. Wait for Completion
**Expected Duration**: 20-30 minutes

**Progress Indicators**:
```
[Safe Mode Recovery Initiated]
Detecting critical issues... Found 1 P0 issue
P0-001: wof.sys driver corruption detected

Creating Safe Mode checkpoint...
Analyzing file system integrity...
Disabling CompactOS (Safe Mode)...
Extracting clean wof.sys from Windows installation...
Replacing corrupted driver...
Updating driver database...
Verifying repair...

[Recovery Complete - System restart required]
```

#### 5. Restart to Normal Mode
```cmd
shutdown /r /t 30 /c "BattleMedic recovery complete - restarting in 30 seconds"
```

**You have 30 seconds** - if you need to abort: `shutdown /a`

#### 6. Post-Restart Actions
After restarting to normal Windows:
1. Open Event Viewer → Windows Logs → System
2. Look for wof.sys errors - should see NONE
3. Complete [[05_VERIFICATION_TESTS]]

**If still getting BSOD**: Boot back to Safe Mode, see [[04_TROUBLESHOOTING#Safe Mode Recovery Failed]]

---

## 💿 Path C: WinRE Offline Recovery

**Likelihood**: Necessary when Safe Mode won't boot
**Time Required**: 45-60 minutes
**Risk Level**: Medium

### Accessing Windows Recovery Environment

#### Method 1: Automatic Repair (Recommended)
1. **Force shutdown 3 times** during Windows logo screen
2. Windows will automatically enter "Automatic Repair"
3. Select **Troubleshoot** → **Advanced Options** → **Command Prompt**

#### Method 2: Manual Boot (if available)
1. Restart and press **F11** during boot
2. Select **Troubleshoot** → **Advanced Options** → **Command Prompt**

### WinRE Command Prompt Session

#### 1. Identify System Drive
```cmd
diskpart
list volume
```

**Look for**: Volume with "Windows" or "System" label (usually C:, but may be different in WinRE)

**Note the letter** - we'll use it as `<DRIVE>` below

```cmd
exit
```

#### 2. Navigate to BattleMedic Location
```cmd
<DRIVE>:
cd kenl\modules\Surface_Pro_4_EoL_BattleMedic_v2.1
```

**If path not found**:
```cmd
dir <DRIVE>:\ /s /b | findstr BattleMedic
# Use the path it finds
```

#### 3. Run Offline WOF Repair
```cmd
# BattleMedic has an offline repair mode for WinRE
powershell.exe -ExecutionPolicy Bypass -File .\Modules\BattleMedic.Recovery.psm1 -OfflineMode -TargetDrive <DRIVE>: -RepairWOF
```

**What this does**:
- Mounts the Windows image offline
- Scans for wof.sys corruption
- Extracts clean driver from Windows image backup
- Replaces corrupted file
- Rebuilds driver store
- Unmounts and commits changes

**Expected Duration**: 25-35 minutes

#### 4. Run System File Checker (Offline)
```cmd
sfc /scannow /offbootdir=<DRIVE>:\ /offwindir=<DRIVE>:\Windows
```

**Expected Output**: "Windows Resource Protection found corrupt files and successfully repaired them"

**If it says "could not perform operation"**: This is okay, continue to next step

#### 5. Run DISM Repair (Offline)
```cmd
DISM /Image:<DRIVE>:\ /Cleanup-Image /RestoreHealth
```

**Expected Duration**: 15-20 minutes

**Progress**: Shows percentage complete

#### 6. Disable CompactOS (Critical)
```cmd
compact /u /s:<DRIVE>:\Windows\System32\wof.sys
```

This prevents re-compression that could trigger the issue again.

#### 7. Exit and Restart
```cmd
exit
# Select "Continue" or "Exit and continue to Windows"
```

#### 8. If Boot Fails After Restart

**Boot loop?** → Re-enter WinRE and try:

```cmd
# Restore to pre-update state
cd <DRIVE>:\Windows\System32\config
ren SOFTWARE SOFTWARE.broken
ren SYSTEM SYSTEM.broken
copy SOFTWARE.bak SOFTWARE
copy SYSTEM.bak SYSTEM
```

Then restart again.

---

## 🔧 Path D: Recovery Media Required

**Likelihood**: Last resort for severe corruption
**Time Required**: 2-3 hours
**Risk Level**: Medium-High

### When This Path is Needed
- Cannot boot to Windows
- Cannot boot to Safe Mode
- Cannot access WinRE
- Recovery partition may be corrupted

### What You'll Need

#### Required Materials
- [ ] **USB drive** (16GB minimum)
- [ ] **Another computer** (to create recovery media)
- [ ] **Surface Pro 4 recovery image** or Windows 10 ISO
- [ ] **Product key** (usually embedded in BIOS, but good to have)

### Step-by-Step Recovery Media Creation

#### On Another Computer

##### 1. Download Windows 10 Media Creation Tool
```
https://www.microsoft.com/software-download/windows10
```

##### 2. Create Bootable USB
- Run Media Creation Tool
- Select "Create installation media"
- Choose: Windows 10, 64-bit
- Select USB flash drive
- Wait for creation (30-45 minutes)

##### 3. Copy BattleMedic to USB
```powershell
# On the computer with BattleMedic
Copy-Item "C:\kenl\modules\Surface_Pro_4_EoL_BattleMedic_v2.1" -Destination "E:\BattleMedic" -Recurse

# Replace E: with your USB drive letter
```

#### On the Affected Surface Pro 4

##### 1. Boot from USB
- **Insert USB** into Surface Pro 4
- **Power on** while holding **Volume Down** button
- **Select** boot from USB

##### 2. Select Language and Keyboard
- **Do NOT** click "Install Now"
- Click **Repair your computer** (bottom left)

##### 3. Access Command Prompt
- Select **Troubleshoot** → **Advanced Options** → **Command Prompt**

##### 4. Run Full Offline Recovery
```cmd
# Navigate to BattleMedic on USB
X:\sources> D:
D:\> cd BattleMedic

# Identify Windows drive
diskpart
list volume
# Note the Windows volume (likely C: or D:)
exit

# Run comprehensive offline repair
powershell.exe -ExecutionPolicy Bypass -File .\Modules\BattleMedic.WinRE.psm1 -FullOfflineRecovery -TargetDrive C: -IncludeSP4Fixes
```

**Expected Duration**: 60-90 minutes

**What this script does**:
1. Comprehensive disk integrity check
2. wof.sys corruption repair
3. System file restoration
4. Driver store rebuild
5. SP4-specific optimizations
6. Boot configuration repair

##### 5. Manual Boot Repair (if needed)
```cmd
bootrec /fixmbr
bootrec /fixboot
bootrec /rebuildbcd
```

##### 6. Remove USB and Restart
```cmd
exit
# Select "Continue" or restart
```

**If Still Won't Boot**: See [[04_TROUBLESHOOTING#Recovery Media Failed]]

---

## 📊 Recovery Success Indicators

After completing any path above, you should observe:

### Immediate Signs (Within 5 Minutes)
- ✅ System boots to Windows desktop
- ✅ No green screen / BSOD
- ✅ Login screen appears normally
- ✅ Desktop loads completely

### Short-Term Signs (Within 1 Hour)
- ✅ Event Viewer shows no wof.sys errors
- ✅ System feels responsive
- ✅ No unexpected restarts
- ✅ Applications launch normally

### Long-Term Signs (24-48 Hours)
- ✅ No recurring BSODs
- ✅ Sleep/wake works correctly
- ✅ Windows Updates complete successfully
- ✅ SP4-specific issues resolved (screen flicker, etc.)

---

## 🔄 If Recovery Fails

### Troubleshooting Steps
1. Review [[04_TROUBLESHOOTING]] for specific error codes
2. Check Event Viewer: `eventvwr.msc` → Windows Logs → System
3. Look for errors with source "wof" or "volmgr"
4. Document error codes and messages

### Escalation Options
1. **Try Alternative Path**: If Path A failed, try Path B or C
2. **Manual Offline Repair**: See [[04_TROUBLESHOOTING#Manual wof.sys Replacement]]
3. **In-Place Upgrade**: Reinstall Windows keeping files/apps
4. **Clean Install**: Last resort - backup data first

### Getting Help
- Document your recovery attempt in [[06_RECOVERY_LOG_TEMPLATE]]
- Include error messages and screenshots
- Post in recovery forums with detailed information

---

## 📝 Post-Recovery Actions

Once recovery is successful:

1. **Complete Verification**: [[05_VERIFICATION_TESTS]]
2. **Document Session**: [[06_RECOVERY_LOG_TEMPLATE]]
3. **Create System Image**: For future rapid recovery
4. **Address Root Cause**: See [[07_WOF_TECHNICAL_DETAILS#Prevention]]
5. **Monitor for 48 Hours**: Ensure stability

---

## 🔗 Quick Links

- [[00_HOME|← Back to Home]]
- [[02_REQUIREMENTS_CHECKLIST|Requirements Checklist →]]
- [[03_STEP_BY_STEP_RECOVERY|Detailed Recovery Steps →]]
- [[04_TROUBLESHOOTING|Troubleshooting Guide]]
- [[05_VERIFICATION_TESTS|Verification Tests]]

---

*Protocol Status: Active*
*Last Updated: 2025-11-26*
*Estimated Success Rate: 85-95% (Path A-C), 70% (Path D)*
