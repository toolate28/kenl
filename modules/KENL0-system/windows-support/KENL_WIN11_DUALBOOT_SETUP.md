---
project: Bazza-DX SAGE Framework
status: active
version: 2025-11-07
classification: OWI-DOC
atom: ATOM-CFG-20251107-021
owi-version: 1.0.0
---

# KENL: Debloated Windows 11 Dual-Boot Setup Framework

**Purpose:** Complete framework for installing debloated Windows 11 as dual-boot on Bazzite-DX immutable Linux system

**ATOM Tag:** `ATOM-CFG-20251107-021`
**Target System:** Bazzite-DX (Fedora Atomic), AMD Radeon Renoir
**Target Drive:** `/dev/sdb` (1.8TB External HDD)

---

## Executive Summary

This framework provides a complete, rollback-safe procedure for dual-booting Bazzite-DX with a debloated Windows 11 installation on an external 1.8TB drive. All changes preserve the immutable Linux system integrity with complete traceability.

**Key Points:**
- ✅ Linux system remains untouched (nvme0n1)
- ✅ Windows installed on separate drive (sdb)
- ✅ Full rollback capability
- ✅ Gaming-optimized debloated Windows
- ✅ ATOM-tracked configuration changes

---

## Table of Contents

1. [System Analysis](#system-analysis)
2. [Debloated Windows 11 Options](#debloated-windows-11-options)
3. [Pre-Installation Checklist](#pre-installation-checklist)
4. [Phase 1: Drive Preparation](#phase-1-drive-preparation)
5. [Phase 2: Windows Installation](#phase-2-windows-installation)
6. [Phase 3: Post-Install Debloating](#phase-3-post-install-debloating)
7. [Phase 4: GRUB Dual-Boot Configuration](#phase-4-grub-dual-boot-configuration)
8. [Phase 5: Gaming Optimizations](#phase-5-gaming-optimizations)
9. [Rollback Procedures](#rollback-procedures)
10. [Troubleshooting](#troubleshooting)

---

## System Analysis

### Current Disk Layout (Pre-Installation)

```
Current System Snapshot (2025-11-07):

nvme0n1 (476.9GB) - PRIMARY SYSTEM (DO NOT TOUCH)
├─ nvme0n1p1: /boot/efi (600MB, vfat)
├─ nvme0n1p2: /boot (1GB, ext4)
└─ nvme0n1p3: LUKS encrypted root (475.4GB)
   └─ Bazzite-DX ostree deployment

sda (465.8GB) - GAMING STORAGE
└─ sda1: /run/media/toolated/GAMING (465.8GB)

sdb (1.8TB) - TARGET FOR WINDOWS 11
└─ CORRUPTED - Will be wiped and repartitioned

sdc (0B) - Empty removable drive
```

### Hardware Specifications

```bash
# Extracted from steam-runtime-system-info

CPU: AMD (x86_64, SSE3, cmpxchg16b)
GPU: AMD Radeon Graphics (RADV RENOIR)
  - Vulkan: 1.4.318 (radv driver)
  - OpenGL: Mesa 25.2.6 (radeonsi)
  - VA-API: Supported
RAM: 4GB zram swap configured
OS: Bazzite 43 (Fedora Kinoite base)
Session: KDE Wayland
```

---

## Debloated Windows 11 Options

### Option 1: Tiny11 (Recommended for Gaming)

**Source:** https://archive.org/details/tiny11-2311

**Pros:**
- ✅ Pre-debloated (2.5GB ISO vs 5GB+ stock)
- ✅ Removes Microsoft bloatware, telemetry
- ✅ Retains Windows Update, Store (for game launchers)
- ✅ ~8GB installed footprint vs 20GB+ stock

**Cons:**
- ❌ Community-built (not official Microsoft)
- ❌ May trigger Windows Defender warnings initially

**Download:**
```bash
# On Linux, download via aria2c (faster, resumable)
aria2c -x 16 -s 16 \
  "https://archive.org/download/tiny11-2311/tiny11%202311%20x64.iso" \
  -o ~/Downloads/tiny11-2311-x64.iso
```

---

### Option 2: AtlasOS (Maximum Performance)

**Source:** https://atlasos.net/

**Pros:**
- ✅ Extreme performance optimization
- ✅ Removes Windows Defender, telemetry, bloat
- ✅ Gaming-focused tweaks (latency reduction)
- ✅ Active community support

**Cons:**
- ❌ Requires manual debloating playbook after stock install
- ❌ No Windows Security (install 3rd-party AV or risk it)
- ❌ Breaks some Windows Update functionality

**Installation Method:**
1. Install stock Windows 11 from Microsoft ISO
2. Run AtlasOS Playbook post-install

---

### Option 3: ReviOS (Balanced)

**Source:** https://revi.cc/

**Pros:**
- ✅ Balanced debloating (keeps more functionality than Atlas)
- ✅ Retains Windows Defender
- ✅ Automated playbook installation
- ✅ Better compatibility with anti-cheat

**Cons:**
- ❌ Larger footprint than Tiny11 (~12GB installed)
- ❌ Still requires stock Windows install first

---

### Option 4: Custom Debloat (Advanced)

Use stock Windows 11 + manual debloating scripts.

**Tools:**
- **Win11Debloat:** https://github.com/Raphire/Win11Debloat
- **Chris Titus Tech Utility:** https://christitus.com/windows-tool/
- **O&O ShutUp10++:** https://www.oo-software.com/en/shutup10

**Pros:**
- ✅ Full control over what's removed
- ✅ Official Microsoft ISO (safer for anti-cheat)
- ✅ Can re-enable features if needed

**Cons:**
- ❌ Time-consuming (2-3 hours post-install)
- ❌ Requires Windows familiarity

---

## Recommended Choice

**For BF6 Gaming → Tiny11**

**Rationale:**
- Pre-debloated (saves time)
- Retains Windows Update (important for drivers)
- Smaller footprint = faster install
- Community-tested for gaming

---

## Pre-Installation Checklist

### Required Hardware

- [ ] USB drive (8GB+ for bootable installer)
- [ ] External drive confirmed as `/dev/sdb` (1.8TB)
- [ ] Backup of any data on `/dev/sdb` (WILL BE ERASED)
- [ ] Windows 11 product key (or use unactivated)

### Required Software (Linux Side)

```bash
# Install required tools on Bazzite-DX
rpm-ostree install --apply-live \
  gparted \
  ntfs-3g \
  efibootmgr \
  os-prober

# Install WoeUSB-ng for creating Windows USB (Flatpak)
flatpak install flathub com.github.woeusb.woeusb-ng
```

### Backup Critical Data

```bash
# Backup current EFI boot entries
efibootmgr -v > ~/efi-backup-$(date +%Y%m%d).txt

# Backup GRUB config
sudo cp /boot/grub2/grub.cfg ~/grub-backup-$(date +%Y%m%d).cfg

# Create ostree deployment pin (rollback safety)
sudo ostree admin pin 0

# Check current deployment
rpm-ostree status
```

---

## Phase 1: Drive Preparation

### Step 1.1: Verify Target Drive

```bash
# Confirm /dev/sdb is the 1.8TB drive
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT

# Expected output:
# sdb           1.8T disk

# Check for existing partitions
sudo fdisk -l /dev/sdb
```

⚠️ **CRITICAL:** Ensure `/dev/sdb` is the CORRECT drive. All data will be permanently erased!

---

### Step 1.2: Securely Wipe Drive (Optional)

If the drive has corruption issues, perform a secure wipe:

```bash
# DANGER: This erases ALL data on /dev/sdb
# Verify THREE TIMES this is the correct drive!

# Quick zero-fill (faster, ~30 min for 1.8TB)
sudo dd if=/dev/zero of=/dev/sdb bs=1M status=progress

# OR secure wipe (slower, ~2-3 hours)
sudo shred -vfz -n 1 /dev/sdb
```

---

### Step 1.3: Create Partition Layout

**Recommended Layout for `/dev/sdb` (1.8TB):**

```
sdb (1.8TB Total)
├─ sdb1: EFI System Partition (500MB, FAT32)
├─ sdb2: Microsoft Reserved (128MB, unformatted)
├─ sdb3: Windows C:\ (150GB, NTFS)
└─ sdb4: Games/Storage (remaining ~1.65TB, NTFS)
```

**Create Partitions:**

```bash
# Launch GParted (GUI method - easier)
sudo gparted /dev/sdb

# OR use parted (CLI method):
sudo parted /dev/sdb

(parted) mklabel gpt
(parted) mkpart ESP fat32 1MiB 501MiB
(parted) set 1 boot on
(parted) set 1 esp on
(parted) mkpart MSR 501MiB 629MiB
(parted) set 2 msftres on
(parted) mkpart primary ntfs 629MiB 150629MiB
(parted) mkpart primary ntfs 150629MiB 100%
(parted) quit

# Format partitions
sudo mkfs.vfat -F32 /dev/sdb1
# sdb2 stays unformatted (MSR)
sudo mkfs.ntfs -f -L "Windows11" /dev/sdb3
sudo mkfs.ntfs -f -L "Games" /dev/sdb4
```

---

### Step 1.4: Verify Partition Layout

```bash
lsblk -o NAME,SIZE,FSTYPE,LABEL /dev/sdb

# Expected output:
# sdb                 1.8T
# ├─sdb1              500M vfat
# ├─sdb2              128M
# ├─sdb3              150G ntfs   Windows11
# └─sdb4              1.6T ntfs   Games
```

---

## Phase 2: Windows Installation

### Step 2.1: Create Bootable Windows USB

**Option A: Using WoeUSB-ng (Flatpak)**

```bash
# Download Tiny11 ISO (if not already done)
cd ~/Downloads
aria2c -x 16 "https://archive.org/download/tiny11-2311/tiny11%202311%20x64.iso"

# Create bootable USB with WoeUSB-ng
# Insert USB drive (becomes /dev/sdc or similar)
lsblk  # Identify USB device

# Launch WoeUSB-ng GUI
flatpak run com.github.woeusb.woeusb-ng

# GUI Steps:
# 1. Select ISO: ~/Downloads/tiny11-2311-x64.iso
# 2. Target device: /dev/sdc (YOUR USB DRIVE)
# 3. Click "Install"
# 4. Wait ~10 minutes
```

**Option B: Using Ventoy (Alternative)**

```bash
# Download Ventoy
wget https://github.com/ventoy/Ventoy/releases/download/v1.0.99/ventoy-1.0.99-linux.tar.gz
tar xf ventoy-1.0.99-linux.tar.gz
cd ventoy-1.0.99

# Install Ventoy to USB
sudo ./Ventoy2Disk.sh -i /dev/sdc  # Replace sdc with your USB

# Copy ISO directly to USB
cp ~/Downloads/tiny11-2311-x64.iso /run/media/toolated/Ventoy/
```

---

### Step 2.2: Boot into Windows Installer

```bash
# Reboot to BIOS/UEFI boot menu
# Typical keys: F12, F11, F2, ESC, or DEL (spam during boot)
sudo systemctl reboot

# In boot menu:
# 1. Select USB drive
# 2. Boot to Windows installer
```

---

### Step 2.3: Windows Installation Steps

**Critical Windows Installer Settings:**

1. **Language/Region:** Select preferences
2. **Install Now**
3. **Product Key:**
   - Enter key if you have one
   - OR select "I don't have a product key" (can activate later)
4. **Edition:** Windows 11 Pro (if Tiny11) or Home
5. **License Agreement:** Accept
6. **Installation Type:** **Custom: Install Windows only (advanced)**

**CRITICAL - Partition Selection:**

⚠️ **DO NOT select nvme0n1!** ⚠️

7. Select **Disk 1** (or whichever is labeled as 1.8TB)
8. Select **Partition 3** (150GB NTFS "Windows11")
9. Click **Next** (do NOT format from here if already formatted)
10. Wait ~15-30 minutes for installation

---

### Step 2.4: Windows OOBE (Out-of-Box Experience)

**Tiny11 OOBE Steps:**

1. **Region:** Select your region
2. **Keyboard Layout:** Select layout
3. **Network:**
   - **SKIP** (press "I don't have internet" or Shift+F10 → `OOBE\BYPASSNRO` → reboot)
   - Reason: Avoid forced Microsoft account
4. **Account:**
   - Username: `gamer` (or your preference)
   - Password: Set a password (required for some games)
5. **Privacy Settings:** **Disable all** telemetry options
6. **Cortana:** Skip/Disable

---

## Phase 3: Post-Install Debloating

### Step 3.1: If Using Tiny11 (Minimal Additional Debloating)

Tiny11 is already debloated, but you can optimize further:

```powershell
# Open PowerShell as Administrator
# Right-click Start → Windows Terminal (Admin)

# Disable Windows Defender (optional, for performance)
Set-MpPreference -DisableRealtimeMonitoring $true

# Disable telemetry services
Get-Service DiagTrack,Dmwappushservice | Stop-Service -Force
Get-Service DiagTrack,Dmwappushservice | Set-Service -StartupType Disabled

# Disable Windows Update (optional, not recommended for gaming)
# Stop-Service wuauserv
# Set-Service wuauserv -StartupType Disabled
```

---

### Step 3.2: If Using Stock Windows 11 (Full Debloating)

**Option A: Chris Titus Tech Utility (Recommended)**

```powershell
# Open PowerShell as Administrator
irm christitus.com/win | iex

# GUI will appear:
# 1. Go to "Tweaks" tab
# 2. Select "Desktop" preset
# 3. Click "Run Tweaks"
# 4. Reboot when prompted
```

**Option B: Win11Debloat Script**

```powershell
# Download script
Invoke-WebRequest -Uri "https://github.com/Raphire/Win11Debloat/releases/latest/download/Win11Debloat.ps1" `
  -OutFile "$env:TEMP\Win11Debloat.ps1"

# Run script
Set-ExecutionPolicy Bypass -Scope Process -Force
& "$env:TEMP\Win11Debloat.ps1"

# Interactive menu appears:
# - Remove Edge
# - Remove OneDrive
# - Disable telemetry
# - Disable Cortana
# - Remove bloatware apps
```

---

### Step 3.3: Install Essential Drivers

```powershell
# AMD Radeon Graphics Drivers
# Download from: https://www.amd.com/en/support

# OR use Windows Update
# Settings → Windows Update → Check for updates
# Let it install AMD drivers automatically
```

---

### Step 3.4: Install Gaming Essentials

```powershell
# Install DirectX
# Download: https://www.microsoft.com/en-us/download/details.aspx?id=35

# Install Visual C++ Redistributables (ALL VERSIONS)
# Download: https://github.com/abbodi1406/vcredist/releases

# Install .NET Framework 4.8
# Download: https://dotnet.microsoft.com/en-us/download/dotnet-framework/net48

# Install Steam
# Download: https://store.steampowered.com/about/

# Install EA App (for BF2042/BF6)
# Download: https://www.ea.com/ea-app
```

---

## Phase 4: GRUB Dual-Boot Configuration

### Step 4.1: Boot Back to Linux

```bash
# Reboot, press F12/F11 (boot menu)
# Select nvme0n1 (Bazzite-DX)
# Boot back into Linux
```

---

### Step 4.2: Detect Windows Boot Entry

```bash
# Check current EFI boot entries
efibootmgr -v

# Should show entries like:
# Boot0000* Bazzite
# Boot0001* Windows Boot Manager

# If Windows entry doesn't exist, os-prober will find it
```

---

### Step 4.3: Enable os-prober and Regenerate GRUB

```bash
# Edit GRUB config to enable os-prober
# NOTE: On immutable systems, edit in /etc, not /boot

sudo nano /etc/default/grub

# Add this line at the end:
GRUB_DISABLE_OS_PROBER=false

# Save and exit (Ctrl+X, Y, Enter)
```

---

### Step 4.4: Regenerate GRUB Configuration

```bash
# Mount EFI partition if not already mounted
sudo mount /dev/nvme0n1p1 /boot/efi

# Run os-prober to detect Windows
sudo os-prober

# Expected output:
# /dev/sdb1@/EFI/Microsoft/Boot/bootmgfw.efi:Windows Boot Manager:Windows:efi

# Regenerate GRUB config
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# Should see:
# "Found Windows Boot Manager on /dev/sdb1"
```

---

### Step 4.5: Verify GRUB Menu

```bash
# Check generated GRUB config
grep -i windows /boot/grub2/grub.cfg

# Should see menuentry for Windows

# Reboot to test
sudo systemctl reboot

# GRUB menu should now show:
# - Bazzite
# - Windows Boot Manager
```

---

### Step 4.6: Set Default Boot Entry (Optional)

```bash
# List GRUB entries
grep 'menuentry ' /boot/grub2/grub.cfg

# Set default (0 = first entry, 1 = second, etc.)
# To default to Bazzite:
sudo grub2-set-default 0

# To default to Windows:
# sudo grub2-set-default 1

# Rebuild GRUB
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

---

## Phase 5: Gaming Optimizations

### Step 5.1: Windows Gaming Tweaks

**Disable Windows Bloat Services:**

```powershell
# Open PowerShell as Administrator

# Disable Xbox Game Bar (causes issues with some games)
Get-AppxPackage Microsoft.XboxGamingOverlay | Remove-AppxPackage

# Disable Superfetch (helps with HDDs)
Stop-Service SysMain
Set-Service SysMain -StartupType Disabled

# Set Windows for best performance
SystemPropertiesPerformance.exe
# Visual Effects → "Adjust for best performance"

# Disable hibernation (saves disk space)
powercfg /hibernate off
```

---

### Step 5.2: NVIDIA/AMD Specific Tweaks

**AMD Radeon Settings (for your system):**

```powershell
# Install AMD Adrenalin drivers
# Download: https://www.amd.com/en/support

# In AMD Radeon Software:
# - Graphics → Radeon Anti-Lag: ON
# - Graphics → Radeon Boost: ON
# - Graphics → Radeon Chill: OFF (for competitive)
# - Display → GPU Scaling: OFF (let monitor handle it)
```

---

### Step 5.3: Game-Specific Launch Options

**Battlefield 2042/6 on Windows:**

Since anti-cheat works natively on Windows, you can use:

```
Steam Launch Options (Windows):
(none needed - runs natively)

Optional Performance Tweaks:
-high -threads 4 -refresh 60
```

---

## Rollback Procedures

### Rollback 1: Remove Windows from GRUB

```bash
# Edit GRUB config
sudo nano /etc/default/grub

# Change:
GRUB_DISABLE_OS_PROBER=false
# To:
GRUB_DISABLE_OS_PROBER=true

# Regenerate GRUB
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# Windows still exists on /dev/sdb, but won't show in GRUB
```

---

### Rollback 2: Remove Windows Boot Entry from EFI

```bash
# List EFI entries
efibootmgr -v

# Remove Windows entry (e.g., Boot0001)
sudo efibootmgr -b 0001 -B

# This doesn't delete Windows, just removes EFI boot entry
```

---

### Rollback 3: Complete Windows Removal

```bash
# Wipe /dev/sdb entirely
sudo wipefs -a /dev/sdb

# Recreate as Linux storage
sudo parted /dev/sdb mklabel gpt
sudo parted /dev/sdb mkpart primary ext4 1MiB 100%
sudo mkfs.ext4 -L "Storage" /dev/sdb1
```

---

### Rollback 4: Linux System Rollback (if GRUB breaks)

```bash
# Boot from Bazzite USB installer
# Choose "Troubleshoot" → "Rescue System"

# Mount root
mount /dev/mapper/luks-* /mnt
mount /dev/nvme0n1p2 /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot/efi

# Chroot
chroot /mnt

# Restore GRUB backup
cp ~/grub-backup-YYYYMMDD.cfg /boot/grub2/grub.cfg

# Reinstall GRUB
grub2-install /dev/nvme0n1

# Exit and reboot
exit
umount -R /mnt
reboot
```

---

## Troubleshooting

### Issue 1: Windows Not Appearing in GRUB

**Solution:**

```bash
# Ensure os-prober is enabled
grep GRUB_DISABLE_OS_PROBER /etc/default/grub
# Should say: GRUB_DISABLE_OS_PROBER=false

# Manually run os-prober
sudo os-prober

# If it finds Windows but GRUB doesn't:
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# Reboot
```

---

### Issue 2: GRUB Shows "Minimal BASH-like Editing"

**Cause:** GRUB can't find boot files

**Solution:**

```bash
# Boot from USB installer → Rescue mode
# Reinstall GRUB (see Rollback 4 above)
```

---

### Issue 3: Windows "No Bootable Device"

**Cause:** EFI partition on /dev/sdb not set correctly

**Solution (from Windows installer USB):**

```
# Boot from Windows USB
# Select "Repair your computer"
# Troubleshoot → Command Prompt

diskpart
list disk
select disk 1  # The 1.8TB drive
list partition
select partition 1  # The EFI partition
active
exit

bootrec /fixmbr
bootrec /fixboot
bootrec /rebuildbcd
```

---

### Issue 4: Bazzite-DX Won't Boot After Windows Install

**Cause:** Windows overwrote EFI boot order

**Solution:**

```bash
# Boot into BIOS/UEFI
# Boot menu → Change boot order
# Move nvme0n1 ABOVE sdb
# Save and reboot
```

---

## ATOM Traceability

**Document:** `KENL_WIN11_DUALBOOT_SETUP.md`
**ATOM Tag:** `ATOM-CFG-20251107-021`

**Related Tags:**
- `ATOM-DOC-20251107-020` - BF6 Linux launch options research
- `ATOM-SAGE-20251106-019` - SAGE framework launch

**Configuration Changes Tracked:**

| Change | File/System | Rollback | ATOM Tag |
|--------|-------------|----------|----------|
| GRUB os-prober enable | `/etc/default/grub` | Edit file, set to `true` | ATOM-CFG-021 |
| GRUB regeneration | `/boot/grub2/grub.cfg` | Restore from backup | ATOM-CFG-021 |
| EFI boot entry | `efibootmgr` | Remove with `-B` flag | ATOM-CFG-021 |
| Partition /dev/sdb | Block device | Wipe with `wipefs` | ATOM-CFG-021 |

**Testing Checklist:**

- [ ] Linux boots normally
- [ ] Windows appears in GRUB
- [ ] Windows boots successfully
- [ ] Can switch between Linux/Windows
- [ ] Linux system unchanged (verify ostree status)
- [ ] Games launch on Windows
- [ ] Anti-cheat works (BF2042/BF6)

---

## Post-Installation Notes

### Maintenance Schedule

**Weekly:**
- Windows Update check (for drivers/security)
- Verify GRUB still shows both entries

**Monthly:**
- Check /dev/sdb filesystem health (`chkdsk /F C:` in Windows)
- Update AMD drivers (Linux and Windows)

**As Needed:**
- Re-run debloat scripts if Windows updates re-enable bloat
- Update GRUB if Linux kernel updates break boot

---

## Additional Resources

- **Tiny11:** https://archive.org/details/tiny11-2311
- **AtlasOS:** https://atlasos.net/
- **ReviOS:** https://revi.cc/
- **WoeUSB-ng:** https://github.com/WoeUSB/WoeUSB-ng
- **Ventoy:** https://www.ventoy.net/
- **Chris Titus Tech:** https://christitus.com/windows-tool/
- **Bazzite Docs:** https://docs.bazzite.gg/

---

**Last Updated:** 2025-11-07
**Maintainer:** Bazza-DX Community
**License:** MIT

**ATOM-CFG-20251107-021**
