---
title: "RWS-03: Dual-Boot Setup (Linux ↔ Windows)"
date: 2025-11-10
scenario: Real World Scenario - Terminal Screenshot
intent: "User wants to dual-boot their PC with Linux and Windows"
kenl-context: KENL0-system, KENL1-framework
hardware: "ASUS ROG STRIX B550-F, 1TB NVMe, RTX 3080"
atom-tag: ATOM-RWS-20251110-003
---

# RWS-03: Dual-Boot Setup (Linux ↔ Windows)

**User Perspective**: "I want to dual boot my PC (Linux-win, windows-linux)"

**Two scenarios covered**:
1. **Linux-first → Add Windows**: Bazzite already installed, adding Windows 11
2. **Windows-first → Add Linux**: Windows 11 already installed, adding Bazzite

---

## Scenario A: Linux-First → Add Windows

**Current State**: Bazzite-DX installed, entire 1TB NVMe used

```
┌──────────────────────────────────────────────────────────────────────┐
│ ⚙️  KENL0 bazza@bazzite-deck:~$                                      │
└──────────────────────────────────────────────────────────────────────┘

$ # User wants to add Windows 11 to existing Bazzite installation
$ dual-boot --add windows11

╔══════════════════════════════════════════════════════════════════════╗
║ 🔍 KENL1-SAGE: Dual-Boot Planner (Linux → Windows)                  ║
╚══════════════════════════════════════════════════════════════════════╝

[CTFWI Pre-Flight Checks]

1/7 Analyzing current disk layout...
    Device: /dev/nvme0n1 (1TB Samsung 980 Pro)

    Current partitions:
    ┌────────────────────────────────────────────────────────────────┐
    │ Partition │ Type      │ Size   │ Mount      │ Usage          │
    ├────────────────────────────────────────────────────────────────┤
    │ nvme0n1p1 │ ESP (FAT) │ 512MB  │ /boot/efi  │ Bootloader     │
    │ nvme0n1p2 │ /boot     │ 1GB    │ /boot      │ Kernel images  │
    │ nvme0n1p3 │ BTRFS     │ 998GB  │ /          │ Bazzite rootfs │
    └────────────────────────────────────────────────────────────────┘

    Total used: 999.5GB / 1TB
    Free space: ~500MB ❌ (Insufficient for Windows 11)

2/7 Checking prerequisites...
    ✅ UEFI mode (required for dual-boot)
    ✅ Secureboot enabled
    ✅ GPT partition table
    ❌ Unallocated space: 500MB (need 100GB minimum for Windows)

[CTFWI Risk Assessment]

⚠️  CRITICAL: Windows installation requires:
    • Shrinking existing Bazzite partition
    • Creating new NTFS partition
    • Modifying boot configuration

❗ WARNING: Data loss risk - BACKUP REQUIRED

Would you like to:
  1) Continue with partition resize (DANGEROUS - backup recommended)
  2) Exit and backup first (RECOMMENDED)
  3) Research non-destructive options

Choice: 2

╔══════════════════════════════════════════════════════════════════════╗
║ 💾 KENL10: Backup Recommended                                       ║
╚══════════════════════════════════════════════════════════════════════╝

Creating ATOM-aware snapshot before disk operations...

$ kenl10-snapshot create "before-dual-boot-resize" "Pre-Windows dual-boot backup"

[1/6] Capturing ATOM trail context...
  ✅ Captured 147 ATOM entries

[2/6] Capturing KENL configurations...
  ✅ KENL0-system
  ✅ KENL1-framework
  ✅ KENL2-gaming
  ✅ KENL3-dev
  ✅ KENL4-monitoring
  ✅ KENL5-facades
  ✅ KENL6-social
  ✅ KENL8-security
  ✅ KENL10-backup

[3/6] Capturing Play Cards...
  ✅ Captured 23 Play Cards

[4/6] Capturing system state...
  ✅ System state captured (rpm-ostree, flatpak, distrobox)

[5/6] Capturing user configurations...
  ✅ User configs captured

[6/6] Creating manifest...
  ✅ Manifest created

✅ Snapshot created: before-dual-boot-resize
   Location: /home/bazza/.local/share/kenl-backups/snapshots/before-dual-boot-resize
   Size: 2.3G

[CTFWI Backup Verification]

✅ Snapshot verified
✅ ATOM trail complete
✅ Restore tested (dry-run)

📸 Additional backup to external drive?
   (HIGHLY RECOMMENDED for disk operations)

$ # User plugs in 2TB external USB drive

Detecting external drives...
  ✅ /dev/sdb - SanDisk Extreme Pro 2TB (USB 3.2)

$ kenl10-snapshot export before-dual-boot-resize /mnt/backup-drive/

Exporting snapshot to external drive...
  ✅ ATOM trail: 147 entries (12MB)
  ✅ Play Cards: 23 cards (890KB)
  ✅ KENL configs: 89 files (45MB)
  ✅ System state: 1 file (234KB)

✅ External backup complete: /mnt/backup-drive/before-dual-boot-resize/
   Total size: 2.3G
   Verification: SHA256 checksums match

═══════════════════════════════════════════════════════════════════════

[CTFWI Safe to Proceed]

3/7 Planning partition resize...

    Proposed layout:
    ┌────────────────────────────────────────────────────────────────┐
    │ Partition │ Type      │ Size   │ Mount      │ Purpose        │
    ├────────────────────────────────────────────────────────────────┤
    │ nvme0n1p1 │ ESP (FAT) │ 512MB  │ /boot/efi  │ Shared EFI 🔗  │
    │ nvme0n1p2 │ /boot     │ 1GB    │ /boot      │ Bazzite kernel │
    │ nvme0n1p3 │ BTRFS     │ 698GB  │ /          │ Bazzite (↓300) │
    │ nvme0n1p4 │ NTFS      │ 250GB  │ -          │ Windows 11 🆕   │
    │ nvme0n1p5 │ NTFS      │ 50GB   │ -          │ Shared data 🆕  │
    └────────────────────────────────────────────────────────────────┘

    Changes:
    • Shrink Bazzite partition: 998GB → 698GB (-300GB)
    • Create Windows partition: 250GB (NTFS)
    • Create shared data partition: 50GB (NTFS, accessible from both)

⚠️  This will:
    ✅ Preserve all Bazzite data
    ✅ Keep EFI partition shared (both OSes boot from it)
    ✅ Allow file sharing via shared partition
    ❌ Require rebooting into GParted Live USB
    ❌ Take ~30-60 minutes to resize

Continue? [y/N]: y

4/7 Preparing GParted Live USB...

Checking for GParted ISO...
  ⬇️  Downloading: https://downloads.sourceforge.net/gparted/gparted-live-1.6.0-3-amd64.iso
  ✅ Downloaded: 510MB

Detecting USB drives...
  ⚠️  WARNING: This will ERASE the USB drive

  Available drives:
    1) /dev/sdc - SanDisk Ultra 32GB (USB 3.0)
    2) /dev/sdb - SanDisk Extreme Pro 2TB (USB 3.2) [SKIP - has backup]

  Select drive for GParted Live: 1

Creating bootable GParted USB...
  $ sudo dd if=gparted-live-1.6.0-3-amd64.iso of=/dev/sdc bs=4M status=progress conv=fsync

  510MB copied, 45s, 11.3 MB/s
  ✅ GParted Live USB created: /dev/sdc

5/7 Generating resize instructions...

┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ 📋 MANUAL STEPS (GParted Live USB)                               ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

1. Reboot into GParted Live USB:
   • Press F8/F12 during boot
   • Select "SanDisk Ultra 32GB" from boot menu

2. In GParted:
   • Select /dev/nvme0n1p3 (Bazzite BTRFS partition)
   • Right-click → Resize/Move
   • New size: 698GB (leave 300GB free at end)
   • Click "Resize"

3. Create Windows partition:
   • Right-click unallocated 300GB space
   • New → Partition
   • Filesystem: NTFS
   • Size: 250GB
   • Label: "Windows11"

4. Create shared data partition:
   • Right-click remaining 50GB unallocated
   • New → Partition
   • Filesystem: NTFS
   • Label: "SharedData"

5. Apply all operations:
   • Click green checkmark ✅
   • Confirm (this takes 30-60 minutes)

6. After completion:
   • Reboot back into Bazzite
   • Continue with this script

Saved to: ~/kenl/KENL0-system/dual-boot-gparted-steps.txt

⏸️  Pausing here - reboot into GParted Live USB now.
   When you return to Bazzite, run:

   $ dual-boot --add windows11 --continue-after-resize

═══════════════════════════════════════════════════════════════════════

[USER REBOOTS INTO GPARTED, RESIZES PARTITIONS, RETURNS TO BAZZITE]

═══════════════════════════════════════════════════════════════════════

$ # User is back in Bazzite after GParted resize
$ dual-boot --add windows11 --continue-after-resize

6/7 Verifying partition resize...

Checking disk layout...
  ✅ nvme0n1p1: ESP (512MB) - unchanged
  ✅ nvme0n1p2: /boot (1GB) - unchanged
  ✅ nvme0n1p3: BTRFS (698GB) - resized successfully ✅
  ✅ nvme0n1p4: NTFS (250GB) - created ✅
  ✅ nvme0n1p5: NTFS (50GB) - created ✅

Testing Bazzite filesystem...
  $ sudo btrfs filesystem show /
  ✅ BTRFS healthy
  ✅ No errors detected

  $ df -h
  Filesystem      Size  Used Avail Use% Mounted on
  /dev/nvme0n1p3  698G  234G  463G  34% /

  ✅ Bazzite partition functional

7/7 Creating Windows 11 installation USB...

Windows 11 ISO options:
  1) Download official ISO via wimboot (RECOMMENDED)
  2) Use existing ISO file
  3) Exit (I'll create it manually)

Choice: 1

Detecting USB drives...
  Available drives:
    1) /dev/sdc - SanDisk Ultra 32GB (USB 3.0) [Currently: GParted]

  ⚠️  Overwrite GParted with Windows 11 installer? [y/N]: y

Formatting USB for Ventoy + wimboot...
  $ sudo ventoy -i /dev/sdc

  ✅ Ventoy installed: /dev/sdc
  ✅ Creating wimboot plugin configuration...

Creating ventoy/ventoy_wimboot.txt:
  ════════════════════════════════════════════════════════════════
  [Windows 11 x64]
  WIN11_EN_X64=http://software-download.microsoft.com/sg/Win11_23H2_English_x64.iso
  ════════════════════════════════════════════════════════════════

✅ Ventoy + wimboot USB ready: /dev/sdc

┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ 📋 Windows 11 Installation Steps                                 ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

1. Reboot into Ventoy USB:
   • Press F8/F12 during boot
   • Select "SanDisk Ultra 32GB"

2. In Ventoy menu:
   • Select "Windows 11 x64"
   • Ventoy will download official ISO from Microsoft (~6GB)
   • Boot into Windows installer

3. During Windows installation:
   • Choose "Custom: Install Windows only (advanced)"
   • Select the 250GB NTFS partition (nvme0n1p4)
   • ⚠️  DO NOT touch other partitions
   • Install Windows

4. After Windows installation:
   • Windows will take over bootloader (this is normal)
   • You'll boot into Windows by default

5. Restore Bazzite bootloader:
   • Boot Bazzite Live USB
   • Run: dual-boot --restore-grub

6. Done! You'll have GRUB menu with both OSes

Saved to: ~/kenl/KENL0-system/dual-boot-windows-install-steps.txt

[CTFWI Completion Checklist]

✅ Backups created (local + external)
✅ Partitions resized safely
✅ Windows partition ready (250GB NTFS)
✅ Shared partition ready (50GB NTFS)
✅ Installation USB prepared
✅ Instructions saved

Next steps:
  1. Reboot and install Windows 11
  2. Return to Bazzite and run: dual-boot --restore-grub

[ATOM Trail]
ATOM-DUAL-BOOT-20251110-001: Planned dual-boot layout
ATOM-DUAL-BOOT-20251110-002: Created backups (local + external, 2.3GB)
ATOM-DUAL-BOOT-20251110-003: Resized partitions (Bazzite: 998→698GB)
ATOM-DUAL-BOOT-20251110-004: Created Windows partition (250GB NTFS)
ATOM-DUAL-BOOT-20251110-005: Prepared Windows 11 USB (Ventoy + wimboot)
```

---

## Scenario B: Windows-First → Add Linux

**Current State**: Windows 11 installed, entire 1TB NVMe used

```
┌──────────────────────────────────────────────────────────────────────┐
│ C:\Users\Bazza> (Windows PowerShell - Administrator)                │
└──────────────────────────────────────────────────────────────────────┘

$ # User boots Bazzite Live USB (hasn't installed yet)
$ # Switches to terminal in Live environment

┌──────────────────────────────────────────────────────────────────────┐
│ 🔴 Bazzite Live (KENL0 context automatically activated)              │
└──────────────────────────────────────────────────────────────────────┘

liveuser@bazzite-live:~$ dual-boot --add bazzite

╔══════════════════════════════════════════════════════════════════════╗
║ 🔍 KENL1-SAGE: Dual-Boot Planner (Windows → Linux)                  ║
╚══════════════════════════════════════════════════════════════════════╝

[CTFWI Pre-Flight Checks]

1/6 Detecting existing OS...
    ✅ Windows 11 detected on /dev/nvme0n1
    ✅ UEFI boot mode
    ✅ Secureboot enabled
    ✅ GPT partition table

2/6 Analyzing current disk layout...
    Device: /dev/nvme0n1 (1TB Samsung 980 Pro)

    Current partitions (Windows):
    ┌────────────────────────────────────────────────────────────────┐
    │ Partition │ Type       │ Size   │ Label      │ Purpose        │
    ├────────────────────────────────────────────────────────────────┤
    │ nvme0n1p1 │ ESP (FAT)  │ 100MB  │ EFI        │ Windows Boot   │
    │ nvme0n1p2 │ Reserved   │ 16MB   │ MSR        │ Windows        │
    │ nvme0n1p3 │ NTFS       │ 998GB  │ Windows    │ C: drive       │
    │ nvme0n1p4 │ NTFS       │ 980MB  │ Recovery   │ WinRE          │
    └────────────────────────────────────────────────────────────────┘

    Total used: 999.1GB / 1TB
    Free space: ~900MB ❌ (Insufficient for Bazzite)

3/6 Checking Windows partition for free space...

    Analyzing C: drive usage...
    ┌────────────────────────────────────────────────────────────────┐
    │ C: Drive (998GB NTFS)                                          │
    ├────────────────────────────────────────────────────────────────┤
    │ Used:             287GB (28.7%)                                │
    │ Free:             711GB (71.3%) ✅                              │
    │ Fragmentation:    12% (acceptable for resize)                  │
    └────────────────────────────────────────────────────────────────┘

    ✅ Sufficient free space available for dual-boot

[CTFWI Risk Assessment]

⚠️  Bazzite installation will:
    • Shrink Windows C: drive
    • Create new partitions for Bazzite
    • Modify EFI bootloader (add GRUB)

❗ Risks:
    • Windows partition resize (can cause data loss if interrupted)
    • Power loss during operation = potential corruption
    • Bootloader modification (Windows may not boot if failed)

Recommended: Backup Windows before proceeding

Would you like to:
  1) Continue with Bazzite installation (resize Windows)
  2) Exit and backup Windows first (RECOMMENDED)
  3) Show me how to backup Windows

Choice: 3

╔══════════════════════════════════════════════════════════════════════╗
║ 💾 Windows Backup Recommendations                                   ║
╚══════════════════════════════════════════════════════════════════════╝

Since you're in Bazzite Live USB, you can't use Windows backup tools.

Options:
  1) Reboot into Windows → Create system image → Return to Live USB
  2) Clone important files to external drive from Live USB (quick)
  3) Skip backup (not recommended)

Choice: 2

Detecting external drives...
  ✅ /dev/sdb - SanDisk Extreme Pro 2TB (USB 3.2)

Mount Windows partition as read-only...
  $ sudo mkdir -p /mnt/windows
  $ sudo mount -o ro /dev/nvme0n1p3 /mnt/windows

  ✅ C: drive mounted at /mnt/windows

Detecting critical Windows data...
  ┌──────────────────────────────────────────────────────────────────┐
  │ Path                          │ Size   │ Backup? │ Priority     │
  ├──────────────────────────────────────────────────────────────────┤
  │ Users/Bazza/Documents         │ 12GB   │ ✅      │ HIGH         │
  │ Users/Bazza/Pictures          │ 45GB   │ ✅      │ HIGH         │
  │ Users/Bazza/Videos            │ 89GB   │ ⚠️      │ MEDIUM       │
  │ Users/Bazza/Downloads         │ 23GB   │ ⚠️      │ LOW          │
  │ Program Files/Steam           │ 234GB  │ ❌      │ SKIP         │
  │ Windows/                      │ 56GB   │ ❌      │ SKIP (OS)    │
  └──────────────────────────────────────────────────────────────────┘

Recommended backup: Documents + Pictures (57GB)
External drive space: 1.8TB available ✅

Backup now? [y/N]: y

Copying to /dev/sdb...
  $ sudo rsync -ah --progress /mnt/windows/Users/Bazza/Documents /mnt/backup/
  $ sudo rsync -ah --progress /mnt/windows/Users/Bazza/Pictures /mnt/backup/

  Documents: 12GB [====================================] 100%
  Pictures:  45GB [====================================] 100%

  ✅ Backup complete: 57GB copied
  ✅ Verification: SHA256 checksums match

Saved backup manifest: /mnt/backup/BACKUP-MANIFEST-20251110.txt

[CTFWI Safe to Proceed]

4/6 Planning partition layout...

    Proposed layout:
    ┌────────────────────────────────────────────────────────────────┐
    │ Partition │ Type       │ Size   │ Label      │ Purpose        │
    ├────────────────────────────────────────────────────────────────┤
    │ nvme0n1p1 │ ESP (FAT)  │ 512MB↑ │ EFI        │ Shared EFI 🔗  │
    │ nvme0n1p2 │ Reserved   │ 16MB   │ MSR        │ Windows        │
    │ nvme0n1p3 │ NTFS       │ 448GB↓ │ Windows    │ C: (↓550GB)    │
    │ nvme0n1p4 │ /boot      │ 1GB    │ BazziteBt  │ Bazzite 🆕      │
    │ nvme0n1p5 │ BTRFS      │ 549GB  │ BazziteRt  │ Bazzite 🆕      │
    │ nvme0n1p6 │ NTFS       │ 980MB  │ Recovery   │ WinRE          │
    └────────────────────────────────────────────────────────────────┘

    Changes:
    • Expand EFI: 100MB → 512MB (for GRUB + Windows Boot)
    • Shrink Windows: 998GB → 448GB (-550GB)
    • Create /boot: 1GB (ext4)
    • Create Bazzite root: 549GB (BTRFS)
    • Move Recovery to end

⚠️  EFI expansion requires:
    • Backup EFI partition
    • Delete and recreate (preserves Windows bootloader)
    • Restore Windows bootloader after expansion

This is COMPLEX. Alternative: Skip EFI expansion (may cause issues later)

Recommendation:
  1) Full plan (expand EFI 100→512MB, safer long-term) ⭐
  2) Simple plan (use existing 100MB EFI, may be tight)

Choice: 1

5/6 Backing up EFI partition...

    $ sudo mkdir -p /tmp/efi-backup
    $ sudo mount /dev/nvme0n1p1 /tmp/efi-backup
    $ sudo tar czf /mnt/backup/efi-backup-20251110.tar.gz -C /tmp/efi-backup .

    ✅ EFI backed up: 89MB archived
    ✅ Contains: Windows Boot Manager, bootx64.efi, BCD

6/6 Ready to install Bazzite

    AUTOMATED STEPS (Bazzite installer will handle):
    ════════════════════════════════════════════════════════════════
    1. Shrink Windows partition (998GB → 448GB)
    2. Expand EFI partition (100MB → 512MB, restore backup)
    3. Create /boot partition (1GB ext4)
    4. Create Bazzite root (549GB BTRFS)
    5. Install Bazzite to new partitions
    6. Install GRUB to expanded EFI
    7. Detect Windows and add to GRUB menu
    ════════════════════════════════════════════════════════════════

Launching Bazzite installer with custom partitioning...

liveuser@bazzite-live:~$ anaconda-installer --dual-boot \
    --shrink-windows=/dev/nvme0n1p3:448GB \
    --expand-efi=/dev/nvme0n1p1:512MB \
    --create-boot=/dev/nvme0n1p4:1GB \
    --create-root=/dev/nvme0n1p5:549GB \
    --install-grub=yes \
    --detect-windows=yes

╔══════════════════════════════════════════════════════════════════════╗
║ 🚀 Bazzite Installer (Dual-Boot Mode)                               ║
╚══════════════════════════════════════════════════════════════════════╝

[1/8] Shrinking Windows partition...
      $ ntfsresize --size 448G /dev/nvme0n1p3

      NTFS resize progress: [================================] 100%

      ✅ Windows partition resized: 998GB → 448GB
      ✅ NTFS filesystem check: PASSED

[2/8] Backing up current EFI...
      ✅ EFI contents preserved

[3/8] Expanding EFI partition...
      $ parted /dev/nvme0n1 resizepart 1 512MB

      ✅ EFI partition expanded: 100MB → 512MB
      ✅ Restoring Windows bootloader...
      ✅ Windows Boot Manager restored

[4/8] Creating /boot partition...
      $ mkfs.ext4 -L BazziteBoot /dev/nvme0n1p4

      ✅ /boot partition created: 1GB ext4

[5/8] Creating Bazzite root partition...
      $ mkfs.btrfs -L BazziteRoot /dev/nvme0n1p5

      ✅ Bazzite root created: 549GB BTRFS

[6/8] Installing Bazzite...
      Copying system files...
      [====================================] 100% (12,847 files)

      ✅ Bazzite installed to /dev/nvme0n1p5

[7/8] Installing GRUB bootloader...
      $ grub2-install --target=x86_64-efi --efi-directory=/boot/efi \
                      --bootloader-id=Bazzite

      ✅ GRUB installed to EFI partition

[8/8] Detecting other operating systems...
      $ os-prober

      Found Windows 11 on /dev/nvme0n1p3
      ✅ Windows 11 added to GRUB menu

Generating GRUB configuration...
  $ grub2-mkconfig -o /boot/grub2/grub.cfg

  ════════════════════════════════════════════════════════════════
  Menuentry 'Bazzite' (default)
  Menuentry 'Bazzite (previous deployment)'
  Menuentry 'Windows 11'
  ════════════════════════════════════════════════════════════════

  ✅ GRUB menu configured

Installation complete! 🎉

Summary:
  ✅ Windows 11: Preserved on /dev/nvme0n1p3 (448GB)
  ✅ Bazzite: Installed on /dev/nvme0n1p5 (549GB)
  ✅ Bootloader: GRUB with dual-boot menu
  ✅ Default OS: Bazzite (10 second timeout)

Reboot now? [y/N]: y

Rebooting...

═══════════════════════════════════════════════════════════════════════

[SYSTEM REBOOTS - GRUB MENU APPEARS]

═══════════════════════════════════════════════════════════════════════

┌──────────────────────────────────────────────────────────────────────┐
│                          GNU GRUB  version 2.12                      │
│                                                                      │
│   Bazzite                                                      ⬅️ ✅ │
│   Bazzite (previous deployment)                                      │
│   Windows 11                                                         │
│                                                                      │
│                                                                      │
│                                                                      │
│                                                                      │
│   Use ↑ and ↓ to select which entry is highlighted.                 │
│   Press enter to boot the selected OS, 'e' to edit the              │
│   commands before booting or 'c' for a command-line.                │
│                                                                      │
│   The highlighted entry will be executed automatically in 10s.       │
└──────────────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════════

[USER BOOTS INTO BAZZITE - FIRST BOOT]

═══════════════════════════════════════════════════════════════════════

Welcome to Bazzite!

[KENL0 context auto-activated on first boot]

⚙️  KENL0 bazza@bazzite-deck:~$ dual-boot --verify

╔══════════════════════════════════════════════════════════════════════╗
║ ✅ Dual-Boot Verification                                            ║
╚══════════════════════════════════════════════════════════════════════╝

[1/5] Checking partition layout...
      ✅ EFI: 512MB (healthy)
      ✅ Windows: 448GB (NTFS, healthy)
      ✅ Bazzite /boot: 1GB (ext4, healthy)
      ✅ Bazzite /: 549GB (BTRFS, healthy)

[2/5] Testing GRUB menu...
      ✅ GRUB config valid
      ✅ Windows entry present
      ✅ Bazzite entries present (2 deployments)

[3/5] Verifying Windows bootability...
      (Testing from GRUB, not booting)
      ✅ Windows Boot Manager found in EFI
      ✅ BCD store valid
      ✅ Windows should boot correctly

[4/5] Checking Bazzite system...
      $ rpm-ostree status

      State: idle
      Deployments:
      ● bazzite:bazzite/stable/x86_64/desktop
                   Version: 41.20251110.0 (2025-11-10)

      ✅ Bazzite fully operational

[5/5] Creating shared data partition (optional)...

      You have 50GB unallocated space remaining.
      Create NTFS shared partition for file exchange?

      This partition will be accessible from both Bazzite and Windows.

      Create now? [y/N]: y

      $ sudo parted /dev/nvme0n1 mkpart primary ntfs 949GB 999GB
      $ sudo mkfs.ntfs -L "SharedData" /dev/nvme0n1p7

      ✅ Shared partition created: /dev/nvme0n1p7 (50GB NTFS)

Creating auto-mount for shared partition...
  $ sudo mkdir -p /mnt/shared
  $ echo "UUID=$(blkid -s UUID -o value /dev/nvme0n1p7) /mnt/shared ntfs-3g defaults,uid=1000,gid=1000 0 0" | \
    sudo tee -a /etc/fstab

  ✅ Shared partition will auto-mount at /mnt/shared

[CTFWI Final Verification]

✅ Dual-boot working correctly
✅ Bazzite fully functional
✅ Windows preserved
✅ GRUB menu operational
✅ Shared data partition ready

Dual-boot setup complete! 🎉

════════════════════════════════════════════════════════════════════════

[ATOM Trail]
ATOM-DUAL-BOOT-20251110-006: Detected Windows 11 (998GB NTFS)
ATOM-DUAL-BOOT-20251110-007: Backed up Windows data (57GB to external)
ATOM-DUAL-BOOT-20251110-008: Backed up EFI partition (89MB)
ATOM-DUAL-BOOT-20251110-009: Shrunk Windows partition (998→448GB)
ATOM-DUAL-BOOT-20251110-010: Expanded EFI partition (100→512MB)
ATOM-DUAL-BOOT-20251110-011: Installed Bazzite (549GB BTRFS)
ATOM-DUAL-BOOT-20251110-012: Installed GRUB with Windows detection
ATOM-DUAL-BOOT-20251110-013: Created shared data partition (50GB NTFS)
ATOM-DUAL-BOOT-20251110-014: Verified dual-boot configuration
```

---

## Common Dual-Boot Operations

### Switch Default OS

```bash
⚙️  KENL0 bazza@bazzite-deck:~$ dual-boot --set-default windows

Changing default boot OS to Windows...
  $ sudo grub2-editenv - set saved_entry="Windows 11"
  $ sudo grub2-mkconfig -o /boot/grub2/grub.cfg

  ✅ Default OS: Windows 11
  ✅ Timeout: 10 seconds (press ↑/↓ to choose Bazzite)

Reboot to apply? [y/N]:
```

### Access Windows Files from Bazzite

```bash
⚙️  KENL0 bazza@bazzite-deck:~$ dual-boot --mount windows

Mounting Windows partition read-only...
  $ sudo mkdir -p /mnt/windows
  $ sudo mount -o ro /dev/nvme0n1p3 /mnt/windows

  ✅ Windows C: mounted at /mnt/windows

Browse Windows files:
  $ ls /mnt/windows/Users/Bazza/Documents

  important-work.docx
  game-saves/
  screenshots/

To copy files:
  $ cp /mnt/windows/Users/Bazza/Documents/file.txt ~/
```

### Share Files Between OSes

```bash
⚙️  KENL0 bazza@bazzite-deck:~$ cd /mnt/shared

⚙️  KENL0 bazza@bazzite-deck:/mnt/shared$ ls
game-saves/  screenshots/  documents/

# Copy file to shared partition (accessible from Windows)
⚙️  KENL0 bazza@bazzite-deck:/mnt/shared$ cp ~/play-card-halo.yaml game-saves/

# From Windows, access: D:\game-saves\play-card-halo.yaml
```

### Restore GRUB (if Windows Update Breaks It)

```bash
# Boot Bazzite Live USB, then:

liveuser@bazzite-live:~$ dual-boot --restore-grub

Detecting existing Bazzite installation...
  ✅ Found Bazzite on /dev/nvme0n1p5

Mounting Bazzite system...
  $ sudo mount /dev/nvme0n1p5 /mnt
  $ sudo mount /dev/nvme0n1p4 /mnt/boot
  $ sudo mount /dev/nvme0n1p1 /mnt/boot/efi

Chrooting into Bazzite...
  $ sudo arch-chroot /mnt

Reinstalling GRUB...
  # grub2-install --target=x86_64-efi --efi-directory=/boot/efi \
                   --bootloader-id=Bazzite

  ✅ GRUB reinstalled

Detecting Windows...
  # os-prober

  Found Windows 11 on /dev/nvme0n1p3
  ✅ Windows added to GRUB menu

Regenerating GRUB config...
  # grub2-mkconfig -o /boot/grub2/grub.cfg

  ✅ GRUB menu restored

Exit chroot and reboot:
  # exit

liveuser@bazzite-live:~$ sudo umount -R /mnt
liveuser@bazzite-live:~$ sudo reboot

GRUB restored! You should see the dual-boot menu on next boot.
```

---

## Troubleshooting

### Windows Won't Boot After Resize

```
Error: "Windows failed to start. A recent hardware or software change might be
the cause."

Fix:
1. Boot Bazzite
2. Run: dual-boot --repair-windows-boot
   • Mounts Windows partition
   • Runs: ntfsfix /dev/nvme0n1p3
   • Rebuilds BCD store
3. Reboot and test
```

### GRUB Menu Missing

```
Boots directly to Windows, no GRUB menu

Fix:
1. Boot Bazzite Live USB
2. Run: dual-boot --restore-grub (see above)
3. If still broken: Check UEFI boot order
   • Enter BIOS (F2/Del)
   • Boot priority: "Bazzite" should be first
```

### Partition Resize Failed

```
Error: "NTFS is inconsistent. Run chkdsk /f"

Fix:
1. Reboot into Windows
2. Open CMD as Administrator:
   > chkdsk C: /f
3. Reboot (chkdsk runs before Windows loads)
4. Return to Bazzite Live and retry resize
```

---

## Summary

**Scenario A (Linux-first → Add Windows)**:
- Backup with KENL10 (local + external)
- Resize Bazzite partition using GParted Live USB
- Install Windows to new NTFS partition
- Restore GRUB bootloader

**Scenario B (Windows-first → Add Linux)**:
- Backup Windows data to external drive
- Bazzite installer handles partition resize automatically
- GRUB installed with Windows detection
- Creates shared NTFS partition for file exchange

**Key Safety Measures**:
- ✅ Always backup before partition operations
- ✅ ATOM trail tracks every step
- ✅ External backup for critical data
- ✅ EFI partition backed up before modification
- ✅ Verification steps after installation

**Result**: Fully functional dual-boot with GRUB menu, shared data partition, and ability to access files across both OSes.
