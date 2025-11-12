#Requires -RunAsAdministrator
<#
.SYNOPSIS
    STEP 1: Wipe 1.8TB external drive and prepare for partitioning
.DESCRIPTION
    Safely wipes Disk 1 (1.8TB Seagate FireCuda) to prepare for hybrid Linux/Windows partition layout
.NOTES
    ATOM Tag: ATOM-CFG-20251112-001
    Project: kenl - Bazza-DX SAGE Framework
    Author: Claude Code
    Date: 2025-11-12

    WARNING: This will DESTROY ALL DATA on Disk 1
    VERIFY disk number before running!
#>

# Configuration
$DISK_NUMBER = 1
$DISK_SIZE_MIN = 1700GB  # Minimum 1.7TB to match 1.8TB drive
$HANDOVER_DIR = "$env:USERPROFILE\Desktop"
$TIMESTAMP = Get-Date -Format "yyyyMMdd-HHmmss"

# Colors
$RED = "Red"
$GREEN = "Green"
$YELLOW = "Yellow"
$CYAN = "Cyan"

Write-Host "`n========================================" -ForegroundColor $CYAN
Write-Host "STEP 1: WIPE DISK $DISK_NUMBER" -ForegroundColor $CYAN
Write-Host "========================================`n" -ForegroundColor $CYAN

# Function to create handover document
function New-HandoverDoc {
    param(
        [string]$Status,
        [string]$Details
    )

    $handoverPath = Join-Path $HANDOVER_DIR "HANDOVER-DISK-WIPE-$TIMESTAMP.md"

    $content = @"
---
project: kenl - Bazza-DX SAGE Framework
status: $Status
timestamp: $TIMESTAMP
atom: ATOM-CFG-20251112-001
---

# STEP 1: Disk Wipe Results

**Timestamp:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Disk Number:** $DISK_NUMBER
**Status:** $Status

## Details

$Details

## Next Steps

"@ + @'
If successful, proceed to:
**STEP2-WINDOWS-PARTITION-DISK1-FIXED.ps1**

This will create 5 partitions:
1. Games-Universal (900GB, NTFS) - Both OSes
2. Claude-AI-Data (500GB, RAW → ext4 in Linux)
3. Development (200GB, RAW → ext4 in Linux)
4. Windows-Only (150GB, NTFS) - Windows anti-cheat games
5. Transfer (50GB, exFAT) - Cross-OS file exchange

## Related Documents

- `/home/user/kenl/scripts/1.8TB_EXTERNAL_DRIVE_LAYOUT.md` - Full design spec
- `/home/user/kenl/scripts/KENL_WIN11_DUALBOOT_SETUP.md` - Dual-boot guide

---
**ATOM-CFG-20251112-001**
'@

    $content | Out-File -FilePath $handoverPath -Encoding UTF8
    Write-Host "`n✓ Handover document created: $handoverPath" -ForegroundColor $GREEN
}

# Step 1: Verify disk exists and get info
Write-Host "[1/5] Verifying Disk $DISK_NUMBER exists..." -ForegroundColor $YELLOW

try {
    $disk = Get-Disk -Number $DISK_NUMBER -ErrorAction Stop
} catch {
    Write-Host "❌ ERROR: Cannot find Disk $DISK_NUMBER" -ForegroundColor $RED
    Write-Host "   $_" -ForegroundColor $RED
    Write-Host "`nAvailable disks:" -ForegroundColor $YELLOW
    Get-Disk | Format-Table Number, FriendlyName, Size, PartitionStyle -AutoSize
    New-HandoverDoc -Status "FAILED" -Details "Disk $DISK_NUMBER not found. Error: $_"
    exit 1
}

# Display disk information
Write-Host "✓ Found disk:" -ForegroundColor $GREEN
Write-Host "   Disk Number: $($disk.Number)" -ForegroundColor $CYAN
Write-Host "   Friendly Name: $($disk.FriendlyName)" -ForegroundColor $CYAN
Write-Host "   Size: $([math]::Round($disk.Size / 1GB, 2)) GB" -ForegroundColor $CYAN
Write-Host "   Bus Type: $($disk.BusType)" -ForegroundColor $CYAN
Write-Host "   Partition Style: $($disk.PartitionStyle)" -ForegroundColor $CYAN

# Step 2: Safety checks
Write-Host "`n[2/5] Running safety checks..." -ForegroundColor $YELLOW

# Check if it's the system disk
if ($disk.IsBoot -or $disk.IsSystem) {
    Write-Host "❌ ERROR: Disk $DISK_NUMBER is a boot or system disk!" -ForegroundColor $RED
    Write-Host "   Cannot wipe system disk for safety reasons." -ForegroundColor $RED
    New-HandoverDoc -Status "FAILED" -Details "Safety check failed: Disk $DISK_NUMBER is a boot/system disk"
    exit 1
}

# Check disk size (should be ~1.8TB)
$diskSizeGB = [math]::Round($disk.Size / 1GB, 2)
if ($diskSizeGB -lt 1700) {
    Write-Host "⚠️  WARNING: Disk size is $diskSizeGB GB (expected ~1800 GB)" -ForegroundColor $YELLOW
    Write-Host "   This might not be the 1.8TB external drive!" -ForegroundColor $YELLOW

    $confirm = Read-Host "`nContinue anyway? (type YES to proceed)"
    if ($confirm -ne "YES") {
        Write-Host "❌ Aborted by user" -ForegroundColor $RED
        New-HandoverDoc -Status "ABORTED" -Details "User aborted due to disk size mismatch"
        exit 1
    }
}

Write-Host "✓ Safety checks passed" -ForegroundColor $GREEN

# Step 3: Final confirmation
Write-Host "`n[3/5] Final confirmation required..." -ForegroundColor $YELLOW
Write-Host "⚠️  WARNING: This will PERMANENTLY DELETE ALL DATA on:" -ForegroundColor $RED
Write-Host "   Disk $DISK_NUMBER - $($disk.FriendlyName) ($diskSizeGB GB)" -ForegroundColor $RED
Write-Host "`n   This action CANNOT be undone!" -ForegroundColor $RED

$confirmation = Read-Host "`nType 'WIPE DISK $DISK_NUMBER' to proceed"
if ($confirmation -ne "WIPE DISK $DISK_NUMBER") {
    Write-Host "❌ Confirmation failed. Aborted." -ForegroundColor $RED
    New-HandoverDoc -Status "ABORTED" -Details "User did not confirm wipe operation"
    exit 1
}

Write-Host "✓ Confirmation received" -ForegroundColor $GREEN

# Step 4: Bring disk online if offline
Write-Host "`n[4/5] Preparing disk..." -ForegroundColor $YELLOW

if ($disk.IsOffline) {
    Write-Host "   Bringing disk online..." -ForegroundColor $YELLOW
    try {
        Set-Disk -Number $DISK_NUMBER -IsOffline $false -ErrorAction Stop
        Write-Host "   ✓ Disk is now online" -ForegroundColor $GREEN
    } catch {
        Write-Host "   ⚠️  Warning: Could not bring disk online: $_" -ForegroundColor $YELLOW
    }
}

if ($disk.IsReadOnly) {
    Write-Host "   Removing read-only attribute..." -ForegroundColor $YELLOW
    try {
        Set-Disk -Number $DISK_NUMBER -IsReadOnly $false -ErrorAction Stop
        Write-Host "   ✓ Read-only removed" -ForegroundColor $GREEN
    } catch {
        Write-Host "   ⚠️  Warning: Could not remove read-only: $_" -ForegroundColor $YELLOW
    }
}

# Refresh disk object
$disk = Get-Disk -Number $DISK_NUMBER

# Step 5: Wipe the disk
Write-Host "`n[5/5] Wiping disk (this may take several minutes)..." -ForegroundColor $YELLOW

try {
    # Remove all partitions
    Write-Host "   Removing existing partitions..." -ForegroundColor $YELLOW
    Get-Partition -DiskNumber $DISK_NUMBER -ErrorAction SilentlyContinue |
        Where-Object { $_.Type -ne 'Reserved' } |
        Remove-Partition -Confirm:$false -ErrorAction Stop

    # Clear the disk
    Write-Host "   Clearing partition table..." -ForegroundColor $YELLOW
    Clear-Disk -Number $DISK_NUMBER -RemoveData -RemoveOEM -Confirm:$false -ErrorAction Stop

    Write-Host "✓ Disk wiped successfully" -ForegroundColor $GREEN

    # Verify disk is clean
    Start-Sleep -Seconds 2
    $disk = Get-Disk -Number $DISK_NUMBER
    $partitions = Get-Partition -DiskNumber $DISK_NUMBER -ErrorAction SilentlyContinue

    if ($partitions) {
        Write-Host "⚠️  Warning: Some partitions still exist after wipe" -ForegroundColor $YELLOW
    } else {
        Write-Host "✓ Verified: Disk is clean (no partitions)" -ForegroundColor $GREEN
    }

    # Success handover
    $details = @"
Disk $DISK_NUMBER wiped successfully.

**Disk Information:**
- Friendly Name: $($disk.FriendlyName)
- Size: $diskSizeGB GB
- Bus Type: $($disk.BusType)
- Partition Style: $($disk.PartitionStyle)

**Partitions Removed:** $(if ($partitions) { $partitions.Count } else { 0 })

Disk is ready for partitioning.
"@

    New-HandoverDoc -Status "SUCCESS" -Details $details

    Write-Host "`n========================================" -ForegroundColor $GREEN
    Write-Host "✓ STEP 1 COMPLETE" -ForegroundColor $GREEN
    Write-Host "========================================" -ForegroundColor $GREEN
    Write-Host "`nNext step: Run STEP2-WINDOWS-PARTITION-DISK1-FIXED.ps1" -ForegroundColor $CYAN

} catch {
    Write-Host "❌ ERROR during disk wipe: $_" -ForegroundColor $RED
    New-HandoverDoc -Status "FAILED" -Details "Wipe operation failed: $_"
    exit 1
}
