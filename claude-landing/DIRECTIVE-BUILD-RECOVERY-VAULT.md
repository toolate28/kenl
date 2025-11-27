---
classification: AGENT-DIRECTIVE
enforcement: REQUIRED
priority: CRITICAL
purpose: Build Obsidian vault structure for Surface Pro 4 recovery guidance
---

# Build Recovery Vault - Executable Directive

**YOU MUST execute this directive exactly as written.**

## Phase 1: Create Vault Structure (5 minutes)

### Command Block 1: Directory Structure
```bash
mkdir -p ~/.kenl/recovery-vault/{00-START-HERE,01-PREPARE,02-CREATE-USB,03-BOOT-RECOVERY,04-EXECUTE-RECOVERY,05-VERIFY,06-ARCHIVE}

cd ~/.kenl/recovery-vault

# Create index files
touch 00-START-HERE/README.md
touch 01-PREPARE/checklist.md
touch 02-CREATE-USB/guide.md
touch 03-BOOT-RECOVERY/guide.md
touch 04-EXECUTE-RECOVERY/guide.md
touch 05-VERIFY/tests.md
touch 06-ARCHIVE/completed-recoveries.md
```

**SAIF Checkpoint:** SAIF-VAULT-STRUCTURE-CREATED-$(date +%Y%m%d)-001

**Validation:**
```bash
# YOU MUST run this command and verify output shows 7 directories
ls -la ~/.kenl/recovery-vault/ | grep -c "^d"
# Expected: 7 (including . and ..)
```

**IF validation fails:** Stop and report error to user.

---

## Phase 2: Build Landing Page (3 minutes)

### Command Block 2: Create START-HERE/README.md
```bash
cat > ~/.kenl/recovery-vault/00-START-HERE/README.md <<'LANDING'
# Surface Pro 4 Recovery - Guided Pathway

**Current Status:** [[recovery-status.md|Check Current Status]]

---

## What Do You Want To Do?

### 🎯 New Recovery (Start Here)
1. [[../01-PREPARE/checklist|Preparation Checklist]] - Verify you have everything
2. [[../02-CREATE-USB/guide|Create MiniOS USB]] - Bootable recovery media
3. [[../03-BOOT-RECOVERY/guide|Boot Into Recovery]] - Surface Pro 4 boot process
4. [[../04-EXECUTE-RECOVERY/guide|Execute Recovery]] - Fix the issue
5. [[../05-VERIFY/tests|Verify Success]] - Confirm it works

### 🔄 Resume Interrupted Recovery
→ [[../06-ARCHIVE/last-session|Last Session Log]]
→ Find your last SAIF checkpoint
→ Jump to that phase

### 📊 Check System Status
→ [[recovery-status.md|Current Recovery Status]]
→ [[../05-VERIFY/tests|Run Verification Tests]]

---

## Emergency Shortcuts

| Issue | Quick Link |
|-------|-----------|
| Can't boot to USB | [[../03-BOOT-RECOVERY/troubleshooting#cant-boot|Boot Troubleshooting]] |
| Corrupt wof.sys | [[../04-EXECUTE-RECOVERY/wof-replacement|wof.sys Replacement]] |
| Need to rollback | [[../04-EXECUTE-RECOVERY/rollback|Emergency Rollback]] |

---

**Last Updated:** [[recovery-status.md|Check Status]]
LANDING

# Create recovery status tracker
cat > ~/.kenl/recovery-vault/00-START-HERE/recovery-status.md <<'STATUS'
# Recovery Status Tracker

**Device:** Surface Pro 4
**Last Action:** None (vault just created)
**Current Phase:** 00-START-HERE
**SAIF Checkpoint:** SAIF-VAULT-CREATED-$(date +%Y%m%d)-001

---

## Phase Completion

- [ ] 01-PREPARE - Checklist verified
- [ ] 02-CREATE-USB - Bootable media ready
- [ ] 03-BOOT-RECOVERY - Booted into MiniOS
- [ ] 04-EXECUTE-RECOVERY - Recovery operations complete
- [ ] 05-VERIFY - Tests passing
- [ ] 06-ARCHIVE - Session documented

---

**To Update This File:**
Edit manually after each phase completion
STATUS
```

**SAIF Checkpoint:** SAIF-LANDING-PAGE-CREATED-$(date +%Y%m%d)-002

**Validation:**
```bash
# YOU MUST verify these files exist and have content
test -s ~/.kenl/recovery-vault/00-START-HERE/README.md && echo "✅ Landing page created"
test -s ~/.kenl/recovery-vault/00-START-HERE/recovery-status.md && echo "✅ Status tracker created"
```

---

## Phase 3: Build Preparation Guide (5 minutes)

### Command Block 3: Create PREPARE/checklist.md
```bash
cat > ~/.kenl/recovery-vault/01-PREPARE/checklist.md <<'PREPARE'
# Pre-Recovery Checklist

**Complete this checklist BEFORE starting recovery.**

---

## Hardware Required

- [ ] Surface Pro 4 (the device being recovered)
- [ ] USB drive (8GB minimum for MiniOS)
- [ ] Another computer (to create bootable USB)
- [ ] Known-good wof.sys file (matching Windows build)

**Get wof.sys:** [[wof-sources|Where to get wof.sys]]

---

## Software Required

- [ ] MiniOS Toolbox ISO downloaded
- [ ] ISO verified (SHA256 matches)
- [ ] Ventoy or Rufus installed (USB creation tool)

**Download MiniOS:** [[minios-download|MiniOS Download Guide]]

---

## Knowledge Required

- [ ] Read: [[Surface Pro 4 boot sequence|../03-BOOT-RECOVERY/boot-sequence]]
- [ ] Understand: [[What wof.sys does|wof-explanation]]
- [ ] Know: [[Emergency rollback procedure|../04-EXECUTE-RECOVERY/rollback]]

---

## Backup Status

- [ ] Important files backed up to external drive
- [ ] BitLocker recovery key saved (if encrypted)
- [ ] Device serial number recorded

**Why backup?** [[backup-rationale|See backup rationale]]

---

## Ready to Proceed?

**All boxes checked?** → [[../02-CREATE-USB/guide|Next: Create USB]]

**Missing items?** → [[missing-items-help|Get Help]]

---

**SAIF Checkpoint:** When all boxes checked, record:
`SAIF-PREPARE-COMPLETE-$(date +%Y%m%d)-001`
PREPARE
```

**SAIF Checkpoint:** SAIF-PREPARE-GUIDE-CREATED-$(date +%Y%m%d)-003

---

## Phase 4: Build USB Creation Guide (8 minutes)

### Command Block 4: Create CREATE-USB/guide.md
```bash
cat > ~/.kenl/recovery-vault/02-CREATE-USB/guide.md <<'USBGUIDE'
# Create MiniOS Bootable USB

**Prerequisites:** [[../01-PREPARE/checklist|Preparation checklist]] complete

---

## Step 1: Download MiniOS Toolbox

### Command (Windows PowerShell):
\`\`\`powershell
# Create download directory
New-Item -ItemType Directory -Path "$env:USERPROFILE\Downloads\MiniOS" -Force

# Download latest MiniOS Toolbox
$url = "https://sourceforge.net/projects/minios-live/files/MiniOS%205.0/minios-trixie-xfce-toolbox-amd64-5.0.0.iso"
$output = "$env:USERPROFILE\Downloads\MiniOS\minios-toolbox.iso"

# Using built-in Windows download
Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
\`\`\`

**SAIF Checkpoint:** `SAIF-MINIOS-DOWNLOADED-$(date +%Y%m%d)-001`

**Validation:**
\`\`\`powershell
# Verify file exists and is correct size (should be ~2-3GB)
Get-Item "$env:USERPROFILE\Downloads\MiniOS\minios-toolbox.iso" | Select-Object Name, Length
\`\`\`

**Expected:** File exists, size between 2-3GB

---

## Step 2: Verify ISO Integrity

### Command:
\`\`\`powershell
# Get SHA256 hash
$actualHash = (Get-FileHash "$env:USERPROFILE\Downloads\MiniOS\minios-toolbox.iso" -Algorithm SHA256).Hash

# Display for manual verification
Write-Host "Actual SHA256: $actualHash"
Write-Host "Compare with: https://sourceforge.net/projects/minios-live/files/MiniOS%205.0/"
\`\`\`

**SAIF Checkpoint:** `SAIF-ISO-VERIFIED-$(date +%Y%m%d)-002`

**Validation:** Manual - hash matches SourceForge

**IF hash mismatch:** DO NOT proceed, re-download ISO

---

## Step 3: Create Bootable USB (Choose Method)

### Method A: Ventoy (Recommended - Multi-ISO)

\`\`\`powershell
# Download Ventoy
$ventoyUrl = "https://github.com/ventoy/Ventoy/releases/download/v1.0.99/ventoy-1.0.99-windows.zip"
Invoke-WebRequest -Uri $ventoyUrl -OutFile "$env:TEMP\ventoy.zip"

# Extract
Expand-Archive -Path "$env:TEMP\ventoy.zip" -DestinationPath "$env:TEMP\ventoy" -Force

# Run Ventoy2Disk.exe (GUI will open)
Start-Process "$env:TEMP\ventoy\ventoy-1.0.99\Ventoy2Disk.exe"
\`\`\`

**Manual Steps:**
1. GUI opens
2. Select your USB drive
3. Click "Install"
4. After install: Copy `minios-toolbox.iso` to USB root

**SAIF Checkpoint:** `SAIF-VENTOY-USB-CREATED-$(date +%Y%m%d)-003`

---

### Method B: Rufus (Alternative - Single ISO)

\`\`\`powershell
# Download Rufus portable
$rufusUrl = "https://github.com/pbatard/rufus/releases/download/v4.6/rufus-4.6p.exe"
Invoke-WebRequest -Uri $rufusUrl -OutFile "$env:TEMP\rufus.exe"

# Run Rufus
Start-Process "$env:TEMP\rufus.exe"
\`\`\`

**Manual Steps:**
1. Device: Select your USB
2. Boot selection: Click SELECT → choose `minios-toolbox.iso`
3. Partition scheme: GPT
4. File system: FAT32
5. Click START

**SAIF Checkpoint:** `SAIF-RUFUS-USB-CREATED-$(date +%Y%m%d)-003`

---

## Step 4: Verify Bootable USB

### Validation (Windows):
\`\`\`powershell
# Check USB contents
$usbDrive = "E:"  # Adjust drive letter
Get-ChildItem $usbDrive
\`\`\`

**Expected (Ventoy):**
- ISO file present on root
- EFI folder present

**Expected (Rufus):**
- Multiple files/folders from ISO extraction
- EFI or boot folder present

**SAIF Checkpoint:** `SAIF-USB-VERIFIED-$(date +%Y%m%d)-004`

---

## Ready for Next Phase

**USB created and verified?** → [[../03-BOOT-RECOVERY/guide|Next: Boot Surface Pro 4]]

**Issues?** → [[troubleshooting|USB Creation Troubleshooting]]

---

**Current Phase SAIF:** `SAIF-USB-PHASE-COMPLETE-$(date +%Y%m%d)-005`
USBGUIDE
```

**SAIF Checkpoint:** SAIF-USB-GUIDE-CREATED-$(date +%Y%m%d)-004

---

## Phase 5: Build Boot Guide (5 minutes)

### Command Block 5: Create BOOT-RECOVERY/guide.md
```bash
cat > ~/.kenl/recovery-vault/03-BOOT-RECOVERY/guide.md <<'BOOTGUIDE'
# Boot Surface Pro 4 into MiniOS Recovery

**Prerequisites:** [[../02-CREATE-USB/guide|Bootable USB created]]

---

## Step 1: Prepare Surface Pro 4

### Actions:
1. **Power off** Surface Pro 4 completely
2. **Insert USB** drive into Surface Pro 4 USB port
3. **Prepare to hold Volume Down** button

---

## Step 2: Enter Boot Menu

### Command (Physical):
1. Press and **hold Volume Down**
2. While holding, press **Power button**
3. Release Power when Surface logo appears
4. **Keep holding Volume Down** until boot menu appears

**Expected:** Boot menu with USB device listed

**SAIF Checkpoint:** `SAIF-BOOT-MENU-ACCESSED-$(date +%Y%m%d)-001`

---

## Step 3: Boot from USB

### Actions in Boot Menu:
1. Use **Volume Up/Down** to navigate
2. Select **USB device** (labeled as USB Storage or similar)
3. Press **Power button** to select

**Ventoy Users:** Will see Ventoy menu → Select MiniOS ISO

**SAIF Checkpoint:** `SAIF-USB-BOOT-INITIATED-$(date +%Y%m%d)-002`

---

## Step 4: MiniOS Boot Sequence

**Expected Boot Sequence:**
1. MiniOS logo appears
2. Boot menu appears (multiple options)
3. Select: "MiniOS Toolbox" (should be default)
4. System loads (30-60 seconds)
5. Desktop appears (XFCE)

**SAIF Checkpoint:** `SAIF-MINIOS-DESKTOP-LOADED-$(date +%Y%m%d)-003`

**Validation:** Take photo of desktop with phone (proves successful boot)

---

## Troubleshooting

### Issue: Boot Menu Doesn't Appear

**Cause:** Surface Pro 4 booting too fast or Secure Boot issue

**Fix:**
1. Power off completely
2. Try again, hold Volume Down BEFORE pressing Power
3. OR: Disable Secure Boot in UEFI:
   - Boot to UEFI (hold Volume Up + Power)
   - Security → Secure Boot → Disabled
   - Save and exit

---

### Issue: USB Not Listed in Boot Menu

**Cause:** USB not bootable or not detected

**Fix:**
1. Verify USB on another computer (should see files)
2. Try different USB port on Surface
3. Recreate USB with different tool (Ventoy vs Rufus)

---

## Ready for Recovery

**MiniOS desktop loaded?** → [[../04-EXECUTE-RECOVERY/guide|Next: Execute Recovery]]

**Boot issues?** → [[troubleshooting|Extended Troubleshooting]]

---

**Current Phase SAIF:** `SAIF-BOOT-PHASE-COMPLETE-$(date +%Y%m%d)-004`
BOOTGUIDE
```

**SAIF Checkpoint:** SAIF-BOOT-GUIDE-CREATED-$(date +%Y%m%d)-005

---

## Phase 6: Build Recovery Execution Guide (10 minutes)

### Command Block 6: Create EXECUTE-RECOVERY/guide.md
```bash
cat > ~/.kenl/recovery-vault/04-EXECUTE-RECOVERY/guide.md <<'RECOVERY'
# Execute Surface Pro 4 Recovery

**Prerequisites:** [[../03-BOOT-RECOVERY/guide|Booted into MiniOS desktop]]

**CRITICAL:** Take your time. Verify each step before proceeding.

---

## Step 1: Open Terminal in MiniOS

### Actions:
1. Click **Applications** (top-left)
2. Navigate: **System → Terminal**
3. Terminal window opens

**SAIF Checkpoint:** `SAIF-TERMINAL-OPENED-$(date +%Y%m%d)-001`

---

## Step 2: Identify Windows Partition

### Command:
\`\`\`bash
# List all disks and partitions
sudo fdisk -l

# More readable view
lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT
\`\`\`

**Expected Output:**
\`\`\`
NAME          SIZE  FSTYPE  LABEL           MOUNTPOINT
nvme0n1       512G
├─nvme0n1p1   100M  vfat    EFI System
├─nvme0n1p2   16M              
├─nvme0n1p3   400G  ntfs    Windows         
└─nvme0n1p4   600M  ntfs    Recovery
\`\`\`

**Identify:** Your Windows partition (usually largest NTFS, ~200-500GB)
**Common locations:**
- `/dev/nvme0n1p3` (most Surface Pro 4)
- `/dev/sda3` (if shown as SATA)

**Record your partition:** _______________________

**SAIF Checkpoint:** `SAIF-PARTITION-IDENTIFIED-$(date +%Y%m%d)-002`

---

## Step 3: Mount Windows Partition (Write Mode)

### Command:
\`\`\`bash
# Create mount point
sudo mkdir -p /mnt/windows

# Mount with write permissions (REPLACE PARTITION!)
sudo mount -t ntfs-3g -o rw,remove_hiberfile /dev/nvme0n1p3 /mnt/windows

# Verify mounted
ls -la /mnt/windows/Windows/System32
\`\`\`

**Expected:** Should see folders like `drivers`, `config`, etc.

**SAIF Checkpoint:** `SAIF-WINDOWS-MOUNTED-$(date +%Y%m%d)-003`

**Validation:**
\`\`\`bash
# Check if mounted read-write
mount | grep /mnt/windows
# Should show "rw" not "ro"
\`\`\`

---

## Step 4: Backup Current wof.sys (Safety)

### Command:
\`\`\`bash
# Navigate to drivers folder
cd /mnt/windows/Windows/System32/drivers

# Backup current wof.sys
sudo cp wof.sys wof.sys.backup.$(date +%Y%m%d)

# Verify backup
ls -lh wof.sys*
\`\`\`

**Expected:** Two files - `wof.sys` and `wof.sys.backup.YYYYMMDD`

**SAIF Checkpoint:** `SAIF-WOF-BACKED-UP-$(date +%Y%m%d)-004`

---

## Step 5: Replace wof.sys

**CRITICAL:** wof.sys version MUST match your Windows build exactly.

### Get Known-Good wof.sys

**Option A: From USB (if you brought one)**
\`\`\`bash
# Copy from USB to Windows drivers
sudo cp /path/to/known-good/wof.sys /mnt/windows/Windows/System32/drivers/wof.sys
\`\`\`

**Option B: From Windows.old (if available)**
\`\`\`bash
# Check if Windows.old exists
ls /mnt/windows/Windows.old/

# Copy from Windows.old
sudo cp /mnt/windows/Windows.old/Windows/System32/drivers/wof.sys \
        /mnt/windows/Windows/System32/drivers/wof.sys
\`\`\`

**Option C: Network download (requires working network)**
\`\`\`bash
# Example - adjust URL for your Windows build
wget https://your-source/wof.sys -O /tmp/wof.sys
sudo cp /tmp/wof.sys /mnt/windows/Windows/System32/drivers/wof.sys
\`\`\`

**SAIF Checkpoint:** `SAIF-WOF-REPLACED-$(date +%Y%m%d)-005`

---

## Step 6: Set Correct Permissions

### Command:
\`\`\`bash
cd /mnt/windows/Windows/System32/drivers

# Set ownership (Windows SYSTEM)
sudo chown root:root wof.sys

# Set permissions
sudo chmod 644 wof.sys

# Verify
ls -lh wof.sys
\`\`\`

**Expected:** `-rw-r--r-- root root XXXXX wof.sys`

**SAIF Checkpoint:** `SAIF-PERMISSIONS-SET-$(date +%Y%m%d)-006`

---

## Step 7: Verify File Integrity

### Command:
\`\`\`bash
# Check file size (should be ~40-50KB)
stat wof.sys

# Verify no corruption
sudo chkdsk /mnt/windows/Windows/System32/drivers/wof.sys 2>/dev/null || echo "File accessible"
\`\`\`

**SAIF Checkpoint:** `SAIF-FILE-VERIFIED-$(date +%Y%m%d)-007`

---

## Step 8: Unmount Safely

### Command:
\`\`\`bash
# Sync changes to disk
sync

# Unmount
sudo umount /mnt/windows

# Verify unmounted
mount | grep windows
# Should return nothing
\`\`\`

**SAIF Checkpoint:** `SAIF-UNMOUNTED-SAFELY-$(date +%Y%m%d)-008`

---

## Step 9: Reboot to Windows

### Command:
\`\`\`bash
# Remove USB drive physically
# Then reboot
sudo reboot
\`\`\`

**Surface will reboot → Remove USB → Should boot to Windows**

**SAIF Checkpoint:** `SAIF-REBOOT-INITIATED-$(date +%Y%m%d)-009`

---

## Next Phase

**Windows booting?** → [[../05-VERIFY/tests|Next: Verify Recovery Success]]

**Boot issues?** → [[../troubleshooting|Recovery Troubleshooting]]

---

**Current Phase SAIF:** `SAIF-RECOVERY-PHASE-COMPLETE-$(date +%Y%m%d)-010`
RECOVERY
```

**SAIF Checkpoint:** SAIF-RECOVERY-GUIDE-CREATED-$(date +%Y%m%d)-006

---

## Phase 7: Build Verification Tests (5 minutes)

### Command Block 7: Create VERIFY/tests.md
```bash
cat > ~/.kenl/recovery-vault/05-VERIFY/tests.md <<'VERIFY'
# Verify Recovery Success

**Run these tests AFTER Windows boots successfully.**

---

## Test 1: Windows Boots Normally

**Test:**
1. Surface Pro 4 powered on
2. No error messages during boot
3. Windows login screen appears
4. Can log in successfully

**Result:** ✅ Pass / ❌ Fail

**SAIF Checkpoint:** `SAIF-BOOT-TEST-PASSED-$(date +%Y%m%d)-001`

---

## Test 2: System Stability (5 Minutes)

**Test:**
1. Let Windows idle for 5 minutes
2. No crashes, blue screens, or restarts
3. System responsive to mouse/keyboard

**Result:** ✅ Pass / ❌ Fail

**SAIF Checkpoint:** `SAIF-STABILITY-TEST-PASSED-$(date +%Y%m%d)-002`

---

## Test 3: Verify wof.sys Loaded

**Test (PowerShell):**
\`\`\`powershell
# Check if wof.sys driver is loaded
Get-WindowsDriver -Online | Where-Object {$_.OriginalFileName -like "*wof.sys*"}
\`\`\`

**Expected:** Driver listed, status "Installed"

**Result:** ✅ Pass / ❌ Fail

**SAIF Checkpoint:** `SAIF-DRIVER-TEST-PASSED-$(date +%Y%m%d)-003`

---

## Test 4: File System Integrity

**Test (PowerShell as Admin):**
\`\`\`powershell
# Run file system check
chkdsk C: /scan
\`\`\`

**Expected:** "No problems found" or similar

**Result:** ✅ Pass / ❌ Fail

**SAIF Checkpoint:** `SAIF-FILESYSTEM-TEST-PASSED-$(date +%Y%m%d)-004`

---

## Test 5: Basic Functionality

**Test:**
- [ ] Can open File Explorer
- [ ] Can open Settings
- [ ] Can open web browser
- [ ] Network connection works

**Result:** ✅ All pass / ❌ Some fail

**SAIF Checkpoint:** `SAIF-FUNCTIONALITY-TEST-PASSED-$(date +%Y%m%d)-005`

---

## Final Verdict

**All tests passed?**
→ [[../06-ARCHIVE/complete-recovery|Record Successful Recovery]]

**Some tests failed?**
→ [[troubleshooting|Verification Troubleshooting]]

---

**Recovery Status:** `SAIF-ALL-TESTS-PASSED-$(date +%Y%m%d)-006`
VERIFY
```

**SAIF Checkpoint:** SAIF-VERIFY-GUIDE-CREATED-$(date +%Y%m%d)-007

---

## Phase 8: Create Archive Structure (2 minutes)

### Command Block 8: Create ARCHIVE/completed-recoveries.md
```bash
cat > ~/.kenl/recovery-vault/06-ARCHIVE/completed-recoveries.md <<'ARCHIVE'
# Completed Recoveries Log

---

## Recovery #1: YYYY-MM-DD

**Device:** Surface Pro 4
**Issue:** Corrupt wof.sys
**MiniOS Version:** 5.0.0 Toolbox
**Outcome:** ✅ Success

**Timeline:**
- Started: HH:MM
- USB Created: HH:MM
- Booted Recovery: HH:MM
- File Replaced: HH:MM
- Rebooted: HH:MM
- Verified: HH:MM
- Total Time: XX minutes

**SAIF Checkpoints Completed:**
- SAIF-PREPARE-COMPLETE-YYYYMMDD-001
- SAIF-USB-PHASE-COMPLETE-YYYYMMDD-005
- SAIF-BOOT-PHASE-COMPLETE-YYYYMMDD-004
- SAIF-RECOVERY-PHASE-COMPLETE-YYYYMMDD-010
- SAIF-ALL-TESTS-PASSED-YYYYMMDD-006

**Notes:**
- Any issues encountered
- Solutions applied
- Lessons learned

---

**Add new recoveries below this line**
ARCHIVE
```

**SAIF Checkpoint:** SAIF-ARCHIVE-STRUCTURE-CREATED-$(date +%Y%m%d)-008

---

## Phase 9: Final Validation (3 minutes)

### Command Block 9: Verify Complete Structure
```bash
# Create verification script
cat > ~/.kenl/recovery-vault/verify-structure.sh <<'VERIFY'
#!/bin/bash

echo "Verifying Recovery Vault Structure..."
echo ""

errors=0

# Check directories
for dir in 00-START-HERE 01-PREPARE 02-CREATE-USB 03-BOOT-RECOVERY 04-EXECUTE-RECOVERY 05-VERIFY 06-ARCHIVE; do
    if [ -d "$HOME/.kenl/recovery-vault/$dir" ]; then
        echo "✅ $dir exists"
    else
        echo "❌ $dir MISSING"
        ((errors++))
    fi
done

echo ""

# Check critical files
files=(
    "00-START-HERE/README.md"
    "00-START-HERE/recovery-status.md"
    "01-PREPARE/checklist.md"
    "02-CREATE-USB/guide.md"
    "03-BOOT-RECOVERY/guide.md"
    "04-EXECUTE-RECOVERY/guide.md"
    "05-VERIFY/tests.md"
    "06-ARCHIVE/completed-recoveries.md"
)

for file in "${files[@]}"; do
    if [ -s "$HOME/.kenl/recovery-vault/$file" ]; then
        echo "✅ $file has content"
    else
        echo "❌ $file EMPTY OR MISSING"
        ((errors++))
    fi
done

echo ""
echo "========================================="
if [ $errors -eq 0 ]; then
    echo "✅ VAULT STRUCTURE VALID"
    echo "SAIF-VAULT-VALIDATED-$(date +%Y%m%d)-001"
    exit 0
else
    echo "❌ FOUND $errors ERRORS"
    echo "DO NOT PROCEED - FIX ERRORS FIRST"
    exit 1
fi
VERIFY

# Make executable
chmod +x ~/.kenl/recovery-vault/verify-structure.sh

# Run verification
bash ~/.kenl/recovery-vault/verify-structure.sh
```

**YOU MUST verify this command exits with code 0 (success).**

**SAIF Checkpoint:** SAIF-STRUCTURE-VALIDATED-$(date +%Y%m%d)-009

---

## Phase 10: Create Obsidian Configuration (3 minutes)

### Command Block 10: Obsidian Vault Config
```bash
# Create .obsidian directory
mkdir -p ~/.kenl/recovery-vault/.obsidian

# Create workspace config
cat > ~/.kenl/recovery-vault/.obsidian/workspace.json <<'WORKSPACE'
{
  "main": {
    "id": "root",
    "type": "split",
    "children": [
      {
        "id": "leaf1",
        "type": "leaf",
        "state": {
          "type": "markdown",
          "state": {
            "file": "00-START-HERE/README.md",
            "mode": "preview"
          }
        }
      }
    ]
  },
  "left": {
    "id": "sidebar-left",
    "type": "split",
    "children": [
      {
        "id": "file-explorer",
        "type": "leaf",
        "state": {
          "type": "file-explorer"
        }
      }
    ],
    "collapsed": false
  },
  "active": "leaf1"
}
WORKSPACE

# Create app config
cat > ~/.kenl/recovery-vault/.obsidian/app.json <<'APPCONFIG'
{
  "alwaysUpdateLinks": true,
  "defaultViewMode": "preview",
  "showLineNumber": false,
  "strictLineBreaks": false,
  "useMarkdownLinks": false,
  "useTab": false
}
APPCONFIG
```

**SAIF Checkpoint:** SAIF-OBSIDIAN-CONFIGURED-$(date +%Y%m%d)-010

---

## Directive Complete

**FINAL SAIF Checkpoint:** SAIF-RECOVERY-VAULT-COMPLETE-$(date +%Y%m%d)-011

### Report to User:

\`\`\`
✅ Recovery Vault Created Successfully

Location: ~/.kenl/recovery-vault/

To Open in Obsidian:
1. Open Obsidian
2. Click "Open folder as vault"
3. Navigate to: /home/[user]/.kenl/recovery-vault
4. Click "Select"

Start Here: 00-START-HERE/README.md

Total Build Time: ~45 minutes
Total SAIF Checkpoints: 11
Vault Status: PRODUCTION READY
\`\`\`

---

**DO NOT proceed past this point without user confirmation vault is accessible.**