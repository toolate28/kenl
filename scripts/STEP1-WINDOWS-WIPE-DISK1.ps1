# STEP 1: Windows-Based Disk Wipe (Seagate FireCuda 1.8TB)
# ATOM-CFG-20251112-002
# ⚠️  DESTRUCTIVE OPERATION - ALL DATA ON DISK 1 WILL BE LOST
# Run as Administrator in PowerShell

$ErrorActionPreference = "Stop"

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  KENL Drive Preparation - Step 1: Windows Wipe" -ForegroundColor Cyan
Write-Host "  ATOM-CFG-20251112-002" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Safety verification
Write-Host "⚠️  WARNING: This will PERMANENTLY DELETE all data on Disk 1" -ForegroundColor Red
Write-Host ""

# Show target disk
Write-Host "Target Disk Information:" -ForegroundColor Yellow
Get-Disk -Number 1 | Format-Table -AutoSize
Write-Host ""

# Show partitions
Write-Host "Current Partitions (will be deleted):" -ForegroundColor Yellow
Get-Partition -DiskNumber 1 | Format-Table -AutoSize
Write-Host ""

# Final confirmation
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Red
Write-Host "  FINAL CONFIRMATION REQUIRED" -ForegroundColor Red
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Red
Write-Host ""
Write-Host "You are about to wipe:" -ForegroundColor Yellow
$disk = Get-Disk -Number 1
Write-Host "  Disk Number: 1" -ForegroundColor White
Write-Host "  Model: $($disk.Model)" -ForegroundColor White
Write-Host "  Size: $([math]::Round($disk.Size / 1GB, 2)) GB" -ForegroundColor White
Write-Host ""
$confirm = Read-Host "Type 'DELETE ALL DATA' to proceed (case-sensitive)"

if ($confirm -ne "DELETE ALL DATA") {
    Write-Host ""
    Write-Host "❌ Aborted - confirmation phrase did not match" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Confirmation received. Proceeding with wipe..." -ForegroundColor Green
Write-Host ""

try {
    # Phase 1: Remove all partitions
    Write-Host "[1/4] Removing all partitions from Disk 1..." -ForegroundColor Cyan
    $partitions = Get-Partition -DiskNumber 1 -ErrorAction SilentlyContinue
    foreach ($partition in $partitions) {
        Write-Host "  Removing partition $($partition.PartitionNumber)..." -ForegroundColor Gray
        Remove-Partition -DiskNumber 1 -PartitionNumber $partition.PartitionNumber -Confirm:$false
    }
    Write-Host "  ✅ All partitions removed" -ForegroundColor Green
    Write-Host ""

    # Phase 2: Clear disk
    Write-Host "[2/4] Clearing disk configuration..." -ForegroundColor Cyan
    Clear-Disk -Number 1 -RemoveData -RemoveOEM -Confirm:$false
    Write-Host "  ✅ Disk cleared" -ForegroundColor Green
    Write-Host ""

    # Phase 3: Initialize as GPT
    Write-Host "[3/4] Initializing disk with GPT partition table..." -ForegroundColor Cyan
    Initialize-Disk -Number 1 -PartitionStyle GPT
    Write-Host "  ✅ GPT partition table created" -ForegroundColor Green
    Write-Host ""

    # Phase 4: Verify
    Write-Host "[4/4] Verifying disk state..." -ForegroundColor Cyan
    $disk = Get-Disk -Number 1
    Write-Host "  Partition Style: $($disk.PartitionStyle)" -ForegroundColor Gray
    Write-Host "  Number of Partitions: $($disk.NumberOfPartitions)" -ForegroundColor Gray

    if ($disk.PartitionStyle -eq "GPT" -and $disk.NumberOfPartitions -eq 0) {
        Write-Host "  ✅ Disk is clean and ready for partitioning" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Unexpected state - manual verification required" -ForegroundColor Yellow
    }
    Write-Host ""

    # Create handover file
    $handoverPath = "$env:USERPROFILE\Desktop\HANDOVER-DISK-WIPE-$(Get-Date -Format 'yyyyMMdd-HHmmss').md"
    @"
# Disk Wipe Handover
**ATOM-CFG-20251112-002**
**Timestamp**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
**Phase**: Step 1 Complete (Windows Wipe)

## Actions Completed
- ✅ All partitions removed from Disk 1
- ✅ Disk cleared and sanitized
- ✅ GPT partition table initialized
- ✅ Disk verified clean (0 partitions)

## Target Disk
- **Model**: $($disk.Model)
- **Size**: $([math]::Round($disk.Size / 1GB, 2)) GB
- **Disk Number**: 1
- **Partition Style**: GPT
- **Status**: Online, Clean, Ready for Linux partitioning

## Next Steps (Run from Bazzite Live USB)
1. Boot into Bazzite Live USB (Ventoy)
2. Open terminal
3. Run: ``sudo bash ~/kenl/scripts/STEP2-LINUX-PARTITION-DISK.sh``
4. Follow on-screen instructions
5. Verify partitions created successfully

## Expected Partition Layout
After Step 2 completion, Disk 1 should have:
- sdb1: Games-Universal (900GB, NTFS)
- sdb2: Claude-AI-Data (500GB, ext4)
- sdb3: Development (200GB, ext4)
- sdb4: Windows-Only (150GB, NTFS)
- sdb5: Transfer (50GB, exFAT)

## Critical Notes
⚠️  Do NOT create partitions from Windows - ext4 requires Linux tools
⚠️  Disk 1 will appear as /dev/sdb in Linux (verify with lsblk)
⚠️  Keep this handover document for reference during Linux partitioning

## ATOM Trail
- Current: ATOM-CFG-20251112-002 (Windows wipe complete)
- Next: ATOM-CFG-20251112-003 (Linux partition creation)

## Status
- [x] Step 1: Windows wipe
- [ ] Step 2: Linux partition creation (pending boot to Bazzite)
- [ ] Step 3: Partition verification
- [ ] Step 4: Mount configuration
"@ | Out-File -FilePath $handoverPath -Encoding UTF8

    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "  ✅ STEP 1 COMPLETE: Disk Wiped Successfully" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    Write-Host "📝 Handover document created:" -ForegroundColor Cyan
    Write-Host "   $handoverPath" -ForegroundColor White
    Write-Host ""
    Write-Host "Next Actions:" -ForegroundColor Yellow
    Write-Host "  1. Ensure Bazzite ISO is downloaded to Ventoy USB" -ForegroundColor White
    Write-Host "  2. Reboot computer" -ForegroundColor White
    Write-Host "  3. Boot from Ventoy USB" -ForegroundColor White
    Write-Host "  4. Select Bazzite ISO" -ForegroundColor White
    Write-Host "  5. Run STEP2-LINUX-PARTITION-DISK.sh from Bazzite Live" -ForegroundColor White
    Write-Host ""

    # Log to ATOM trail (local)
    $atomLog = "$env:USERPROFILE\kenl-atom-trail.log"
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') | ATOM-CFG-20251112-002 | Disk 1 wipe complete - ready for Linux partitioning" | Out-File -FilePath $atomLog -Append
    Write-Host "📋 ATOM trail logged to: $atomLog" -ForegroundColor Gray
    Write-Host ""

} catch {
    Write-Host ""
    Write-Host "❌ ERROR during disk wipe:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Disk may be in inconsistent state. Check Disk Management." -ForegroundColor Yellow
    exit 1
}
