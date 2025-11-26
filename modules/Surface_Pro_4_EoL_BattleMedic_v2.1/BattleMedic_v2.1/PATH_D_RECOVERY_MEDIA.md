---
title: Path D - Recovery Media Required
tags: [path-d, recovery-media, very-hard, last-resort]
created: 2025-11-26
priority: P0
estimated-time: 2-3 hours
difficulty: Very Hard
---

# 🔴 Path D: Recovery Media Required

[[01_DECISION_TREE|← Back to Decision Tree]] | [[00_HOME|← Home]]

---

## ⚠️ You're Here Because

- Cannot boot to Windows
- Cannot boot to Safe Mode
- Cannot access WinRE
- **Need external recovery media** to repair

**This is last resort recovery - requires another computer and USB drive**

---

## ⏱️ Time Required

- **Estimated**: 2-3 hours
- **Success Rate**: 60-70%
- **Difficulty**: Very Hard

---

## 📦 What You'll Need

- [ ] **USB drive** (16GB minimum, will be erased)
- [ ] **Another working computer** (Windows, Mac, or Linux)
- [ ] **Internet connection** (to download Windows 10/11 ISO)
- [ ] **Product key** (usually embedded in BIOS, but good to have)
- [ ] **Patience** (this takes time)

---

## 💿 Part 1: Create Recovery Media (On Another Computer)

### Step 1: Download Windows Media Creation Tool

**On a working Windows computer**:

1. Go to: https://www.microsoft.com/software-download/windows10
   - For Windows 11: https://www.microsoft.com/software-download/windows11

2. Click: **Download tool now**

3. Run: `MediaCreationTool.exe`

---

### Step 2: Create Bootable USB

1. **Accept** license terms
2. Select: **Create installation media (USB flash drive, DVD, or ISO file)**
3. Click: **Next**
4. Select:
   - Language: **English (United States)**
   - Edition: **Windows 10** (or 11)
   - Architecture: **64-bit (x64)**
5. Click: **Next**
6. Select: **USB flash drive**
7. Choose your USB drive from list
8. Click: **Next**

**Wait 30-45 minutes** for download and creation

---

### Step 3: Copy BattleMedic to USB

**On the computer with BattleMedic**:

```powershell
# Assuming USB is E: (check in File Explorer)
$usbDrive = "E:"

# Copy entire BattleMedic folder
Copy-Item "C:\kenl\modules\Surface_Pro_4_EoL_BattleMedic_v2.1" -Destination "$usbDrive\BattleMedic" -Recurse
```

**Verify it copied**:
```powershell
Test-Path "$usbDrive\BattleMedic\BattleMedic.psd1"
# Should return: True
```

---

## 🔧 Part 2: Boot From USB (On Affected Surface Pro 4)

### Step 1: Insert USB and Boot

1. **Shut down** Surface Pro 4 completely
2. **Insert** USB drive
3. **Hold Volume Down button**
4. **Press Power button** (while still holding Volume Down)
5. **Release Volume Down** when you see Surface logo
6. **Boot menu** should appear

**Select**: Boot from USB

---

### Step 2: Windows Setup - DON'T INSTALL!

1. You'll see **Windows Setup** screen
2. Select **Language** and **Keyboard**
3. **DO NOT** click "Install now"
4. Click: **Repair your computer** (bottom left corner)

---

### Step 3: Access Advanced Options

1. Select: **Troubleshoot**
2. Select: **Advanced options**
3. Select: **Command Prompt**

**You're now in WinRE from USB!**

---

## 🛠️ Part 3: Offline Recovery

### Step 1: Identify Drives

```cmd
diskpart
list volume
```

**Identify**:
- **USB drive** (labeled "ESD-USB" or similar) - Note letter (e.g., E:)
- **System drive** (Windows install, ~200GB NTFS) - Note letter (e.g., C:)

```cmd
exit
```

**In commands below**:
- Replace `E:` with your USB drive letter
- Replace `C:` with your Windows drive letter

---

### Step 2: Navigate to BattleMedic on USB

```cmd
E:
cd BattleMedic
```

**Verify**:
```cmd
dir BattleMedic.psd1
# Should show the file
```

---

### Step 3: Run Full Offline Recovery

```cmd
powershell.exe -ExecutionPolicy Bypass -File .\Modules\BattleMedic.WinRE.psm1 -FullOfflineRecovery -TargetDrive C: -IncludeSP4Fixes
```

**Replace `C:` with your Windows drive letter**

**What this does** (comprehensive):
1. Disk integrity check
2. wof.sys corruption repair
3. System file restoration
4. Driver store rebuild
5. SP4-specific optimizations (screen flicker fix, thermal settings)
6. Boot configuration repair

**Expected duration**: 60-90 minutes

---

### Step 4: Manual Boot Repair

**After offline recovery completes**:

```cmd
# Fix boot records
bootrec /fixmbr
bootrec /fixboot
bootrec /scanos
bootrec /rebuildbcd

# When prompted, type: A (to add all installations)
```

---

### Step 5: Remove USB and Restart

```cmd
exit
```

**From menu**: Select **Continue** or **Turn off your PC**

**Remove USB drive** before restart

---

## 🔍 Post-Recovery Verification

### First Boot

Watch for:
- [ ] No green screen/BSOD
- [ ] Windows logo appears
- [ ] Login screen loads
- [ ] Desktop loads

**If BSOD**: → [[#Still Failing|Troubleshooting: Still Failing]]

### Once Booted

```powershell
# Check for wof.sys errors
Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2} -MaxEvents 50 |
Where-Object {$_.Message -like '*wof*'}

# Run diagnostic
cd C:\Users\iamto\kenl\modules\Surface_Pro_4_EoL_BattleMedic_v2.1
Import-Module .\BattleMedic.psd1
Get-BattleMedicDiagnostic -Quick
```

---

## ✅ Success! Next Steps

1. **Full verification**: [[05_VERIFICATION_TESTS|Verification Tests]]
2. **Create system image** for future rapid recovery
3. **Document** in [[06_RECOVERY_LOG_TEMPLATE|Recovery Log]]

---

## ❌ Troubleshooting

### Can't Boot from USB

**Problem**: Surface Pro 4 won't boot from USB

**Verify Secure Boot settings**:
1. **Shutdown** Surface
2. **Hold Volume Up** + **Press Power**
3. **Release when UEFI appears**
4. Go to: **Boot configuration**
5. **Disable Secure Boot** temporarily
6. **Save and exit**
7. Try USB boot again (Volume Down + Power)

---

### USB Drive Not Recognized

**Problem**: USB not showing in diskpart

**Solutions**:
- Try different USB port
- Use USB 2.0 drive (not 3.0)
- Recreate USB using Rufus instead of Media Creation Tool

---

### BattleMedic Not on USB

**Problem**: Forgot to copy BattleMedic to USB

**Manual wof.sys repair**:
```cmd
# Identify Windows drive (e.g., C:)
diskpart
list volume
exit

# Navigate to drivers
cd C:\Windows\System32\drivers

# Backup corrupted driver
copy wof.sys wof.sys.corrupt

# Find clean driver in component store
cd C:\Windows\WinSxS
dir /s wof.sys

# Copy clean version (use actual path from dir output)
copy "amd64_microsoft-windows-wof...\wof.sys" C:\Windows\System32\drivers\wof.sys

# Run SFC
sfc /scannow /offbootdir=C:\ /offwindir=C:\Windows

# Run DISM
DISM /Image:C:\ /Cleanup-Image /RestoreHealth

# Disable CompactOS
compact /u /s:C:\Windows\System32\drivers\wof.sys

# Boot repair
bootrec /fixmbr
bootrec /fixboot
bootrec /rebuildbcd
```

---

### Still Failing After Recovery Media

**Problem**: Tried everything, still won't boot

**At this point, consider**:

**Option 1: In-Place Upgrade (Repair Install)**
- Boot from USB
- Select "Upgrade this PC"
- Choose "Keep personal files and apps"
- Windows reinstalls while preserving data

**Option 2: Data Backup + Clean Install**
1. Boot from USB
2. Access Command Prompt
3. Copy important data:
   ```cmd
   # Copy to external drive (e.g., D:)
   xcopy C:\Users D:\Backup\Users /E /H /C /I
   ```
4. Then perform clean Windows install

**Option 3: Professional Help**
- If data is critical, consider professional data recovery
- Microsoft Store Geek Squad
- Local computer repair shop

---

## 🆘 When to Give Up

**Signs recovery won't work**:
- Hardware failure (clicking sounds from SSD)
- Physical damage to Surface
- Repeated BSODs with different error codes
- Surface won't power on at all

**In these cases**: Hardware replacement needed

---

## 🔗 Quick Links

- [[01_DECISION_TREE|← Back to Decision Tree]]
- [[PATH_C_WINRE_OFFLINE|Try Path C (if WinRE now accessible)]]
- [[05_VERIFICATION_TESTS|Verification Tests]]
- [[00_HOME|← Home]]

---

*Path D: Recovery Media Required*
*Success Rate: 60-70% (hardware-dependent)*
*Last Updated: 2025-11-26*
