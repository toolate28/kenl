# Windows Partition Scripts - 1.8TB External Drive Setup

**Purpose:** Automated PowerShell scripts to partition 1.8TB external drive for hybrid Linux/Windows gaming setup

**ATOM Tag:** `ATOM-CFG-20251112-001` through `ATOM-CFG-20251112-003`

---

## Overview

These scripts implement the **Hybrid Approach (Option C)** from `/home/user/kenl/scripts/1.8TB_EXTERNAL_DRIVE_LAYOUT.md`:

```
1.8TB External Drive Layout:
├─ Partition 1: Games-Universal (900GB, NTFS)     - Shared Steam library
├─ Partition 2: Claude-AI-Data (500GB, ext4)      - LLM models, datasets
├─ Partition 3: Development (200GB, ext4)         - Distrobox, Git repos
├─ Partition 4: Windows-Only (150GB, NTFS)        - BF6, anti-cheat games
└─ Partition 5: Transfer (50GB, exFAT)            - Cross-OS file exchange
```

---

## Prerequisites

- **Administrator privileges** (all scripts require `Run as Administrator`)
- **PowerShell 5.1+** (built into Windows 10/11)
- **1.8TB external drive** connected and recognized as Disk 1
- **Backup all data** - these scripts will DESTROY all data on the target disk

**⚠️ VERIFY DISK NUMBER BEFORE RUNNING ⚠️**

Check disk number in PowerShell:
```powershell
Get-Disk | Format-Table Number, FriendlyName, Size, PartitionStyle -AutoSize
```

If your external drive is NOT Disk 1, edit the `$DISK_NUMBER` variable in each script.

---

## Execution Order

Run scripts in sequence:

### STEP 1: Wipe Disk
**File:** `STEP1-WINDOWS-WIPE-DISK1.ps1`

Safely wipes all data and partitions from Disk 1.

```powershell
# Open PowerShell as Administrator
cd path\to\kenl\scripts\windows-partition-scripts

# Run STEP 1
.\STEP1-WINDOWS-WIPE-DISK1.ps1

# Confirmation required: type "WIPE DISK 1" when prompted
```

**What it does:**
- Verifies disk exists and is not a system disk
- Safety checks (size, boot status)
- Removes all partitions
- Clears partition table
- Creates handover document

**Output:** `HANDOVER-DISK-WIPE-YYYYMMDD-HHMMSS.md` on Desktop

---

### STEP 2: Create Partitions
**File:** `STEP2-WINDOWS-PARTITION-DISK1.ps1`

Creates 5 partitions with correct filesystem types.

```powershell
.\STEP2-WINDOWS-PARTITION-DISK1.ps1
```

**What it does:**
- Initializes disk as GPT
- Creates Partition 1 (H:, 900GB, NTFS) - Games-Universal
- Creates Partition 2 (I:, 500GB, RAW) - Claude-AI-Data ⚠️ Format in Linux
- Creates Partition 3 (L:, 200GB, RAW) - Development ⚠️ Format in Linux
- Creates Partition 4 (K:, 150GB, NTFS) - Windows-Only ✅ FIXED: Now NTFS (was wrong)
- Creates Partition 5 (J:, ~50GB, exFAT) - Transfer ✅ FIXED: Now exFAT (was wrong)
- Runs write tests on formatted partitions
- Creates handover document

**Key features:**
- ✅ Partition 4 formatted as NTFS (for Windows anti-cheat games like BF6)
- ✅ Partition 5 formatted as exFAT (for cross-OS file transfer)
- ✅ Robust error handling for "device not ready" issues
- ✅ Proper write testing with delays for filesystem initialization

**Output:** `HANDOVER-PARTITION-YYYYMMDD-HHMMSS.md` on Desktop

---

### STEP 3: Verify Layout
**File:** `STEP3-WINDOWS-MOUNT-CHECK.ps1`

Verifies all partitions are accessible and working.

```powershell
.\STEP3-WINDOWS-MOUNT-CHECK.ps1
```

**What it does:**
- Checks all 5 partitions exist
- Verifies filesystem types match expected layout
- Tests write access on NTFS and exFAT partitions
- Counts Windows-accessible vs Linux-only partitions
- Creates comprehensive verification report

**Expected results:**
- ✅ 2 NTFS partitions (Games-Universal, Windows-Only)
- ✅ 1 exFAT partition (Transfer)
- ✅ 2 RAW partitions (Claude-AI-Data, Development)
- ✅ All write tests pass

**Output:** `HANDOVER-VERIFICATION-YYYYMMDD-HHMMSS.md` on Desktop

---

## Troubleshooting

### Issue: "Device not ready" during write test

**Cause:** Filesystem not fully initialized after format

**Fix:** Script now includes delays (`Start-Sleep`) before write tests. If still failing:
```powershell
# Manually verify in File Explorer
Start-Process "explorer.exe" "H:\"

# Try creating a test file manually
"Test" | Out-File H:\test.txt
```

### Issue: "No NTFS or exFAT partitions found"

**Cause:** Partitions not formatted in STEP2

**Fix:**
1. Open Disk Management: `Win+R` → `diskmgmt.msc`
2. Check if partitions show as "RAW" or "Unformatted"
3. Re-run STEP2

### Issue: Wrong disk number

**Symptom:** Script targets wrong drive

**Fix:**
1. Check disk numbers:
   ```powershell
   Get-Disk | Format-Table Number, FriendlyName, Size -AutoSize
   ```
2. Edit `$DISK_NUMBER` variable at top of each script
3. Re-run

### Issue: "Access denied" errors

**Cause:** Not running as Administrator

**Fix:** Right-click PowerShell → Run as Administrator

---

## Handover Documents

Each script creates a handover document on your Desktop:

**STEP1:** `HANDOVER-DISK-WIPE-YYYYMMDD-HHMMSS.md`
- Disk wipe results
- Safety checks performed
- Next steps

**STEP2:** `HANDOVER-PARTITION-YYYYMMDD-HHMMSS.md`
- Partition creation summary
- Filesystem types for each partition
- Linux formatting commands
- Next steps

**STEP3:** `HANDOVER-VERIFICATION-YYYYMMDD-HHMMSS.md`
- Verification results table
- Write test results
- Linux setup instructions
- Mount point configuration

---

## Linux Side Setup

After completing Windows steps, boot into Bazzite-DX:

### Format ext4 Partitions

```bash
# Identify partitions (external drive should be /dev/sdb)
lsblk -o NAME,SIZE,FSTYPE,LABEL /dev/sdb

# Format Claude-AI-Data (Partition 2, usually /dev/sdb2)
sudo mkfs.ext4 -L "Claude-AI-Data" /dev/sdb2

# Format Development (Partition 3, usually /dev/sdb3)
sudo mkfs.ext4 -L "Development" /dev/sdb3

# Verify
lsblk -o NAME,SIZE,FSTYPE,LABEL /dev/sdb
```

### Configure Auto-Mount

```bash
# Create mount points
sudo mkdir -p /mnt/{games-universal,claude-ai,development,windows-only,transfer}

# Get UUIDs
sudo blkid /dev/sdb* | tee ~/partition-uuids.txt

# Edit /etc/fstab
sudo nano /etc/fstab

# Add these lines (replace UUIDs with your actual values from blkid):
UUID=XXXX-XXXX /mnt/games-universal ntfs-3g defaults,uid=1000,gid=1000,umask=022 0 0
UUID=YYYY-YYYY /mnt/claude-ai ext4 defaults,noatime 0 2
UUID=ZZZZ-ZZZZ /mnt/development ext4 defaults,noatime 0 2
UUID=AAAA-AAAA /mnt/windows-only ntfs-3g defaults,uid=1000,gid=1000,umask=022 0 0
UUID=BBBB-BBBB /mnt/transfer exfat defaults,uid=1000,gid=1000,umask=022 0 0

# Save (Ctrl+O, Enter, Ctrl+X)

# Test mount
sudo mount -a

# Verify all mounted
df -h | grep sdb
```

### Setup Steam Library

```bash
# Add shared Steam library
mkdir -p /mnt/games-universal/SteamLibrary

# In Steam:
# Settings → Storage → Add Drive → /mnt/games-universal/SteamLibrary

# Games installed here work on both Windows and Linux!
```

---

## Related Documentation

**Design Specifications:**
- `/home/user/kenl/scripts/1.8TB_EXTERNAL_DRIVE_LAYOUT.md` - Complete design with all three layout options
- `/home/user/kenl/scripts/KENL_WIN11_DUALBOOT_SETUP.md` - Dual-boot configuration guide

**Gaming Setup:**
- `/home/user/kenl/scripts/WINDOWS_GAMING_ESSENTIALS.md` - Windows libraries and optimizations
- `/home/user/kenl/case-studies/BF6_LINUX_LAUNCH_OPTIONS.md` - BF6 gaming on Linux (anti-cheat info)

**System Design:**
- `/home/user/kenl/README.md` - KENL framework overview
- `/home/user/kenl/CLAUDE.md` - Claude Code guidance

---

## ATOM Traceability

| Script | ATOM Tag | Purpose |
|--------|----------|---------|
| STEP1 | ATOM-CFG-20251112-001 | Disk wipe |
| STEP2 | ATOM-CFG-20251112-002 | Partition creation |
| STEP3 | ATOM-CFG-20251112-003 | Verification |

**Related ATOM Tags:**
- `ATOM-CFG-20251107-021` - Dual-boot setup
- `ATOM-CFG-20251107-022` - Windows gaming essentials
- `ATOM-CFG-20251107-023` - 1.8TB drive layout design

---

## Quick Reference

**Drive Letter Mapping:**
| Windows | Linux | Size | FS | Purpose |
|---------|-------|------|-----|---------|
| H: | /mnt/games-universal | 900GB | NTFS | Shared Steam library |
| I: | /mnt/claude-ai | 500GB | ext4 | LLM models, datasets |
| L: | /mnt/development | 200GB | ext4 | Distrobox, Git repos |
| K: | /mnt/windows-only | 150GB | NTFS | BF6, EA App, anti-cheat |
| J: | /mnt/transfer | 50GB | exFAT | Quick file exchange |

---

**Last Updated:** 2025-11-12
**Author:** Claude Code
**ATOM:** ATOM-CFG-20251112-001
