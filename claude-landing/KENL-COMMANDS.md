---
title: KENL Commands for Claude Code CLI
purpose: Registry of available KENL commands that Claude Code can invoke
classification: COMMAND-REGISTRY
---

# KENL Commands for Claude Code

This file documents all KENL commands available to Claude Code CLI sessions.

---

## How Claude Code Should Use This

```
1. Read this file at session start
2. Use commands directly when tasks match their purpose
3. Always show user what command you're running
4. Capture output and interpret for next steps
```

---

## PowerShell Commands (Windows)

### Disk Management

#### `Get-KENLDisk`
**Purpose:** Show all disks with key info for partitioning
**Invocation:**
```powershell
powershell -NoProfile -Command "Import-Module .\modules\KENL0-system\powershell\KENL.psm1; Get-KENLDisk"
```
**Output:** Formatted table with Disk Number, Name, Size(GB), Type, Boot status

#### `Get-KENLPartitions <DiskNumber>`
**Purpose:** Show partitions on specific disk
**Invocation:**
```powershell
powershell -NoProfile -Command "Import-Module .\modules\KENL0-system\powershell\KENL.psm1; Get-KENLPartitions -DiskNumber 1"
```

#### `Test-KENLDiskSafe <DiskNumber>`
**Purpose:** Verify disk is safe to partition (not system/boot)
**Invocation:**
```powershell
powershell -NoProfile -Command "Import-Module .\modules\KENL0-system\powershell\KENL.psm1; Test-KENLDiskSafe -DiskNumber 1"
```
**Returns:** `$true` if safe, `$false` with warning if system disk

---

### Partition Scripts

#### `STEP1: Wipe Disk`
**Purpose:** Safely wipe external drive
**Location:** `scripts/STEP1-WINDOWS-WIPE-DISK1.ps1`
**Invocation:**
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\STEP1-WINDOWS-WIPE-DISK1.ps1
```
**Safety:** Requires user confirmation, will NOT run on system disks
**Output:** Creates `HANDOVER-DISK-WIPE-YYYYMMDD-HHMMSS.md` on Desktop

#### `STEP2: Partition Disk`
**Purpose:** Create 5-partition hybrid layout
**Location:** `scripts/STEP2-WINDOWS-PARTITION-DISK1.ps1`
**Invocation:**
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\STEP2-WINDOWS-PARTITION-DISK1.ps1
```
**Creates:**
- Partition 1: Games-Universal (900GB, NTFS)
- Partition 2: Claude-AI-Data (500GB, RAW → format as ext4 in Linux)
- Partition 3: Development (200GB, RAW → format as ext4 in Linux)
- Partition 4: Windows-Only (150GB, NTFS)
- Partition 5: Transfer (50GB, exFAT)

#### `STEP3: Verify Layout`
**Purpose:** Verify all partitions created correctly
**Location:** `scripts/STEP3-WINDOWS-MOUNT-CHECK.ps1`
**Invocation:**
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\STEP3-WINDOWS-MOUNT-CHECK.ps1
```
**Validates:** Partition count, filesystem types, write access

---

### Network & Downloads

#### `Get-KENLNetworkStatus`
**Purpose:** Show current network performance
**Invocation:**
```powershell
powershell -NoProfile -Command "Import-Module .\modules\KENL0-system\powershell\KENL.Network.psm1; Get-KENLNetworkStatus"
```
**Output:** Latency, adapter status, Tailscale state

#### `Download-BazziteISO`
**Purpose:** Download latest Bazzite KDE ISO with aria2c
**Location:** `scripts/BAZZITE_ISO_DOWNLOAD.md` (instructions)
**Recommended Command:**
```powershell
# Install aria2c first if needed
choco install aria2 -y

# Download ISO
aria2c -x16 -s16 `
  --dir="C:\Users\$env:USERNAME\Downloads" `
  --out="bazzite-deck-gnome-stable.iso" `
  "https://download.bazzite.gg/bazzite-deck-gnome-stable.iso"
```

---

## Bash Commands (Linux - Native Boot Only)

**⚠️ WARNING:** Do NOT run these from WSL2. Native Linux boot only.

### Disk Detection

#### `kenl-disk`
**Purpose:** List all disks with partition info
**Invocation:**
```bash
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE,LABEL
```

#### `kenl-check-external <device>`
**Purpose:** Verify external drive exists and show layout
**Example:**
```bash
# Check if /dev/sdb exists and show partitions
lsblk -o NAME,SIZE,FSTYPE,LABEL /dev/sdb
```

---

### Partition Formatting (Native Linux Only)

#### `kenl-format-ext4 <partition> <label>`
**Purpose:** Format partition as ext4
**Example:**
```bash
# Format Claude-AI-Data partition
sudo mkfs.ext4 -L "Claude-AI-Data" /dev/sdb2

# Format Development partition
sudo mkfs.ext4 -L "Development" /dev/sdb3
```
**Safety:** Requires user confirmation "FORMAT <partition>"

#### `kenl-get-uuids <disk>`
**Purpose:** Get partition UUIDs for /etc/fstab
**Invocation:**
```bash
sudo blkid /dev/sdb* | tee ~/partition-uuids.txt
```
**Output:** Saves to `~/partition-uuids.txt`

#### `kenl-mount-all`
**Purpose:** Mount all KENL partitions from /etc/fstab
**Invocation:**
```bash
sudo mount -a
df -h | grep sdb
```

---

## Usage Examples for Claude Code

### Example 1: Check Disk Before Partitioning

```markdown
User: "Check if my external drive is connected"

Claude Code:
1. Run: powershell Get-Disk | Format-Table Number, FriendlyName, Size -AutoSize
2. Interpret output
3. Respond: "Disk 1 is your 2TB Seagate FireCuda, safe to partition"
```

### Example 2: Download ISO

```markdown
User: "Download Bazzite KDE ISO"

Claude Code:
1. Check if aria2c installed:
   powershell -Command "Get-Command aria2c -ErrorAction SilentlyContinue"
2. If not found:
   powershell -Command "choco install aria2 -y"
3. Download:
   aria2c -x16 -s16 https://download.bazzite.gg/...
4. Show progress
5. Verify SHA256 when complete
```

### Example 3: Full Partition Workflow

```markdown
User: "Partition my 2TB drive for gaming and AI work"

Claude Code:
1. Safety check:
   powershell Test-KENLDiskSafe -DiskNumber 1
2. Show current layout:
   powershell Get-KENLPartitions -DiskNumber 1
3. Ask confirmation:
   "This will DESTROY all data on Disk 1. Type YES to proceed:"
4. Run STEP1 (wipe):
   powershell .\scripts\STEP1-WINDOWS-WIPE-DISK1.ps1
5. Run STEP2 (partition):
   powershell .\scripts\STEP2-WINDOWS-PARTITION-DISK1.ps1
6. Run STEP3 (verify):
   powershell .\scripts\STEP3-WINDOWS-MOUNT-CHECK.ps1
7. Show handover docs:
   "Created: Desktop\HANDOVER-PARTITION-20251112-*.md"
```

---

## Command Discovery

Claude Code should check for these files at session start:

```
1. claude-landing/KENL-COMMANDS.md (this file)
2. modules/KENL0-system/powershell/KENL.psm1
3. modules/KENL0-system/powershell/KENL.Network.psm1
4. scripts/STEP*.ps1
5. scripts/windows-partition-scripts/PROFILES_SETUP.md
```

---

## Safety Rules for Claude Code

**NEVER:**
- ❌ Run partition commands without user confirmation
- ❌ Assume disk numbers (always verify with user)
- ❌ Run WSL2 commands for disk partitioning
- ❌ Skip safety checks (Test-KENLDiskSafe)

**ALWAYS:**
- ✓ Show user what command you're running before execution
- ✓ Verify disk is external before wiping
- ✓ Capture and save handover documents
- ✓ Provide clear next steps after each operation

---

## Integration with Profiles

If user has PowerShell/Bash profiles set up (from PROFILES_SETUP.md):

**PowerShell shortcuts:**
```powershell
kdisk          # Get-KENLDisk
kwipe          # Run STEP1
kpart          # Run STEP2
kverify        # Run STEP3
```

**Bash shortcuts (native Linux):**
```bash
kdisk          # lsblk formatted
kformat        # Format ext4
kuuid          # Get UUIDs
kmountall      # Mount all
```

---

## Error Handling

When commands fail, Claude Code should:

1. **Capture error output**
2. **Diagnose common issues:**
   - Disk not connected → Check Device Manager
   - Access denied → Run as Administrator
   - Disk in use → Close apps using disk
3. **Provide fix command:**
   - Show exact command to retry
   - Explain what changed

---

Last Updated: 2025-11-12
ATOM: ATOM-CFG-20251112-007
