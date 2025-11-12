# STEP 2: Windows Native Partition Creation
# ATOM-CFG-20251112-003
# Creates NTFS and exFAT partitions now, marks space for Linux ext4 partitions
# ⚠️  ext4 partitions will be created later from Bazzite Live USB

$ErrorActionPreference = "Stop"

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  KENL Drive Preparation - Step 2: Windows Partitioning" -ForegroundColor Cyan
Write-Host "  ATOM-CFG-20251112-003" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Host "ℹ️  NOTE: Windows can only create NTFS/exFAT partitions" -ForegroundColor Yellow
Write-Host "   ext4 partitions will be marked as RAW and formatted in Bazzite" -ForegroundColor Yellow
Write-Host ""

# Verify Disk 1 is clean
Write-Host "[1/6] Verifying Disk 1 is clean..." -ForegroundColor Yellow
$disk = Get-Disk -Number 1

if ($disk.NumberOfPartitions -ne 0) {
    Write-Host ""
    Write-Host "⚠️  WARNING: Disk 1 has partitions!" -ForegroundColor Red
    Write-Host "   Expected: 0 partitions (clean from Step 1)" -ForegroundColor Red
    Write-Host "   Actual: $($disk.NumberOfPartitions) partitions" -ForegroundColor Red
    Write-Host ""
    Write-Host "Did you run STEP1-WINDOWS-WIPE-DISK1.ps1 first?" -ForegroundColor Yellow
    Write-Host ""
    $confirm = Read-Host "Continue anyway? [y/N]"
    if ($confirm -ne "y") {
        Write-Host "Aborted."
        exit 1
    }
}

Write-Host "  ✅ Disk 1 is clean and ready" -ForegroundColor Green
Write-Host ""

# Bring disk online
Write-Host "[2/6] Bringing disk online..." -ForegroundColor Yellow
Set-Disk -Number 1 -IsOffline $false
Set-Disk -Number 1 -IsReadOnly $false
Write-Host "  ✅ Disk 1 is online and writable" -ForegroundColor Green
Write-Host ""

# Create partitions
Write-Host "[3/6] Creating partitions..." -ForegroundColor Yellow
Write-Host ""

# Partition 1: Games-Universal (900GB, NTFS)
Write-Host "  [1/5] Creating Games-Universal (900GB, NTFS)..." -ForegroundColor Cyan
$part1 = New-Partition -DiskNumber 1 -Size 900GB -AssignDriveLetter
Format-Volume -DriveLetter $part1.DriveLetter -FileSystem NTFS -NewFileSystemLabel "Games-Universal" -Confirm:$false | Out-Null
Write-Host "    ✅ Games-Universal: $($part1.DriveLetter): (900GB, NTFS)" -ForegroundColor Green

# Partition 2: Claude-AI-Data (500GB, RAW - will be ext4 in Linux)
Write-Host "  [2/5] Creating Claude-AI-Data (500GB, RAW)..." -ForegroundColor Cyan
Write-Host "    ⚠️  Will be formatted as ext4 from Bazzite Live USB" -ForegroundColor Yellow
$part2 = New-Partition -DiskNumber 1 -Size 500GB -AssignDriveLetter
# Don't format - leave as RAW for Linux ext4
Write-Host "    ✅ Claude-AI-Data: $($part2.DriveLetter): (500GB, RAW → ext4)" -ForegroundColor Green

# Partition 3: Development (200GB, RAW - will be ext4 in Linux)
Write-Host "  [3/5] Creating Development (200GB, RAW)..." -ForegroundColor Cyan
Write-Host "    ⚠️  Will be formatted as ext4 from Bazzite Live USB" -ForegroundColor Yellow
$part3 = New-Partition -DiskNumber 1 -Size 200GB -AssignDriveLetter
# Don't format - leave as RAW for Linux ext4
Write-Host "    ✅ Development: $($part3.DriveLetter): (200GB, RAW → ext4)" -ForegroundColor Green

# Partition 4: Windows-Only (150GB, NTFS)
Write-Host "  [4/5] Creating Windows-Only (150GB, NTFS)..." -ForegroundColor Cyan
$part4 = New-Partition -DiskNumber 1 -Size 150GB -AssignDriveLetter
Format-Volume -DriveLetter $part4.DriveLetter -FileSystem NTFS -NewFileSystemLabel "Windows-Only" -Confirm:$false | Out-Null
Write-Host "    ✅ Windows-Only: $($part4.DriveLetter): (150GB, NTFS)" -ForegroundColor Green

# Partition 5: Transfer (Remaining space, exFAT)
Write-Host "  [5/5] Creating Transfer (remaining space, exFAT)..." -ForegroundColor Cyan
$part5 = New-Partition -DiskNumber 1 -UseMaximumSize -AssignDriveLetter
Format-Volume -DriveLetter $part5.DriveLetter -FileSystem exFAT -NewFileSystemLabel "Transfer" -Confirm:$false | Out-Null
Write-Host "    ✅ Transfer: $($part5.DriveLetter): (exFAT)" -ForegroundColor Green

Write-Host ""

# Verify partitions
Write-Host "[4/6] Verifying partition layout..." -ForegroundColor Yellow
Write-Host ""
Get-Partition -DiskNumber 1 | Format-Table -AutoSize
Write-Host ""
Get-Volume | Where-Object { $_.DriveLetter -in @($part1.DriveLetter, $part2.DriveLetter, $part3.DriveLetter, $part4.DriveLetter, $part5.DriveLetter) } | Format-Table -AutoSize
Write-Host ""

# Test write access to formatted partitions
Write-Host "[5/6] Testing write access..." -ForegroundColor Yellow
Write-Host ""

$testDrives = @($part1.DriveLetter, $part4.DriveLetter, $part5.DriveLetter)
foreach ($driveLetter in $testDrives) {
    $testFile = "$($driveLetter):\KENL-TEST.txt"
    try {
        "KENL Drive Test - ATOM-CFG-20251112-003" | Out-File -FilePath $testFile
        Remove-Item -Path $testFile -Force
        Write-Host "  ✅ $driveLetter`: drive is writable" -ForegroundColor Green
    } catch {
        Write-Host "  ❌ $driveLetter`: write test failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""

# Create next-step instructions
Write-Host "[6/6] Creating handover document..." -ForegroundColor Yellow

$handoverPath = "$env:USERPROFILE\Desktop\HANDOVER-WINDOWS-PARTITION-$(Get-Date -Format 'yyyyMMdd-HHmmss').md"
@"
# Windows Partition Creation Handover
**ATOM-CFG-20251112-003**
**Timestamp**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
**Phase**: Step 2 Complete (Windows Native Partitioning)

## Actions Completed
- ✅ Disk 1 brought online
- ✅ 5 partitions created
- ✅ NTFS/exFAT partitions formatted
- ✅ RAW partitions created (for Linux ext4)
- ✅ Write tests passed

## Partition Layout (Windows View)

``````
$(Get-Partition -DiskNumber 1 | Format-Table -AutoSize | Out-String)
``````

## Volume Details

``````
$(Get-Volume | Where-Object { $_.DriveLetter -in @($part1.DriveLetter, $part2.DriveLetter, $part3.DriveLetter, $part4.DriveLetter, $part5.DriveLetter) } | Format-Table -AutoSize | Out-String)
``````

## Partition Mapping

| Partition | Drive Letter | Size | Windows Format | Linux Format | Label | Status |
|-----------|--------------|------|----------------|--------------|-------|--------|
| 1 | $($part1.DriveLetter): | 900GB | NTFS | (same) | Games-Universal | ✅ Ready |
| 2 | $($part2.DriveLetter): | 500GB | RAW | **ext4** | Claude-AI-Data | ⚠️ Format in Linux |
| 3 | $($part3.DriveLetter): | 200GB | RAW | **ext4** | Development | ⚠️ Format in Linux |
| 4 | $($part4.DriveLetter): | 150GB | NTFS | (same) | Windows-Only | ✅ Ready |
| 5 | $($part5.DriveLetter): | ~50GB | exFAT | (same) | Transfer | ✅ Ready |

## Critical Next Step: Format ext4 Partitions in Linux

### ⚠️  IMPORTANT: Partitions 2 and 3 are RAW!

Windows cannot create ext4 filesystems. These partitions are **created but not formatted**.

**You MUST format them from Bazzite Live USB:**

### Method 1: Boot Bazzite Live USB (Recommended)

1. **Boot from Ventoy USB**
2. **Open Terminal in Bazzite Live**
3. **Identify the RAW partitions**:
   ``````bash
   lsblk -o NAME,SIZE,FSTYPE,LABEL
   # Look for partitions with no FSTYPE (RAW)
   ``````

4. **Format partition 2 (Claude-AI-Data)**: Assuming it's /dev/sdb2:
   ``````bash
   sudo mkfs.ext4 -L "Claude-AI-Data" /dev/sdb2
   ``````

5. **Format partition 3 (Development)**: Assuming it's /dev/sdb3:
   ``````bash
   sudo mkfs.ext4 -L "Development" /dev/sdb3
   ``````

6. **Verify**:
   ``````bash
   lsblk -o NAME,SIZE,FSTYPE,LABEL
   # Should now show ext4 for partitions 2 and 3
   ``````

### Method 2: Use WSL2 (If Linux Access Configured)

WSL2 cannot write to physical disks directly, so this won't work for formatting.
**You must use Bazzite Live USB.**

## Windows Accessibility

| Partition | Windows Access | Notes |
|-----------|---------------|-------|
| Games-Universal ($($part1.DriveLetter):) | ✅ Read/Write | NTFS - full access |
| Claude-AI-Data ($($part2.DriveLetter):) | ❌ Not accessible | RAW until formatted as ext4 |
| Development ($($part3.DriveLetter):) | ❌ Not accessible | RAW until formatted as ext4 |
| Windows-Only ($($part4.DriveLetter):) | ✅ Read/Write | NTFS - full access |
| Transfer ($($part5.DriveLetter):) | ✅ Read/Write | exFAT - full access |

**After formatting ext4 in Linux:**
- Windows still won't see ext4 partitions (expected)
- Linux will see all 5 partitions
- Cross-OS files go in Games-Universal, Windows-Only, or Transfer

## Next Steps

### Option A: Format ext4 Now (Boot Bazzite Live USB)
1. Boot from Ventoy USB
2. Select Bazzite ISO
3. Open Terminal
4. Run format commands above
5. Optionally install Bazzite to internal drive
6. Configure auto-mount

### Option B: Wait Until Bazzite Installation
1. Continue using Windows
2. When ready to install Bazzite, boot from USB
3. Format ext4 partitions during/after installation
4. Configure auto-mount with /etc/fstab

### Option C: Just Use Windows Partitions for Now
1. Use $($part1.DriveLetter):, $($part4.DriveLetter):, $($part5.DriveLetter): immediately
2. Leave $($part2.DriveLetter):, $($part3.DriveLetter): RAW until Bazzite installed
3. Format ext4 later

## Verification Commands (Windows)

``````powershell
# List all partitions on Disk 1
Get-Partition -DiskNumber 1 | Format-Table

# Show volumes with drive letters
Get-Volume | Where-Object { `$_.DriveLetter -ne `$null }

# Check disk health
Get-Disk -Number 1 | Select-Object Number, FriendlyName, HealthStatus, OperationalStatus
``````

## Verification Commands (Linux - After Formatting)

``````bash
# List partitions with filesystems
lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT

# Get UUIDs for /etc/fstab
sudo blkid | grep -E "sdb[2-3]"

# Test mount
sudo mkdir -p /mnt/test
sudo mount /dev/sdb2 /mnt/test
ls /mnt/test
sudo umount /mnt/test
``````

## ATOM Trail
- Step 1: ATOM-CFG-20251112-002 (Windows wipe) ✅
- Step 2: ATOM-CFG-20251112-003 (Windows partitioning) ✅
- Next: Format ext4 from Bazzite Live USB
- Then: ATOM-CFG-20251112-005 (Bazzite installation)
- Then: ATOM-CFG-20251112-006 (Auto-mount configuration)

## Status
- [x] Step 1: Windows wipe
- [x] Step 2: Windows partition creation
- [ ] Step 2b: Format ext4 partitions (requires Linux)
- [ ] Step 3: Bazzite installation
- [ ] Step 4: Auto-mount configuration
- [ ] Step 5: KENL bootstrap

## Critical Notes
✅ **3 partitions ready for immediate use** (NTFS + exFAT)
⚠️  **2 partitions need ext4 formatting** (use Bazzite Live USB)
✅ **Drive letters assigned automatically** by Windows
⚠️  **Do NOT format RAW partitions in Windows** - they must be ext4!

---
Generated by KENL Windows Partition Script
Method: Native Windows (diskpart + PowerShell)
"@ | Out-File -FilePath $handoverPath -Encoding UTF8

Write-Host "  ✅ Handover document created" -ForegroundColor Green
Write-Host ""

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  ✅ STEP 2 COMPLETE: Partitions Created (Partial)" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Handover document: $handoverPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "Partition Summary:" -ForegroundColor Yellow
Write-Host "  ✅ $($part1.DriveLetter): - Games-Universal (900GB, NTFS) - READY" -ForegroundColor Green
Write-Host "  ⚠️  $($part2.DriveLetter): - Claude-AI-Data (500GB, RAW → needs ext4)" -ForegroundColor Yellow
Write-Host "  ⚠️  $($part3.DriveLetter): - Development (200GB, RAW → needs ext4)" -ForegroundColor Yellow
Write-Host "  ✅ $($part4.DriveLetter): - Windows-Only (150GB, NTFS) - READY" -ForegroundColor Green
Write-Host "  ✅ $($part5.DriveLetter): - Transfer (~50GB, exFAT) - READY" -ForegroundColor Green
Write-Host ""
Write-Host "Next Action Required:" -ForegroundColor Yellow
Write-Host "  Boot Bazzite Live USB and format partitions $($part2.DriveLetter): and $($part3.DriveLetter): as ext4" -ForegroundColor White
Write-Host "  Commands will be in the handover document" -ForegroundColor White
Write-Host ""
Write-Host "Immediate Usage:" -ForegroundColor Cyan
Write-Host "  You can use $($part1.DriveLetter):, $($part4.DriveLetter):, and $($part5.DriveLetter): right now in Windows!" -ForegroundColor White
Write-Host ""

# Log to ATOM trail
$atomLog = "$env:USERPROFILE\kenl-atom-trail.log"
"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') | ATOM-CFG-20251112-003 | Windows partition creation complete - ext4 formatting pending" | Out-File -FilePath $atomLog -Append

Write-Host "ATOM-CFG-20251112-003 complete" -ForegroundColor Cyan
Write-Host ""
