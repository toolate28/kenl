#Requires -RunAsAdministrator
<#
.SYNOPSIS
    STEP 3: Verify partition layout and test Windows accessibility
.DESCRIPTION
    Verifies all 5 partitions are created correctly and Windows can access NTFS/exFAT partitions:
    - Checks partition count (should be 5)
    - Verifies filesystem types (NTFS, RAW, exFAT)
    - Tests read/write access on Windows-accessible partitions
    - Provides guidance for Linux formatting steps

.NOTES
    ATOM Tag: ATOM-CFG-20251112-003
    Project: kenl - Bazza-DX SAGE Framework
    Author: Claude Code
    Date: 2025-11-12

    PREREQUISITES: STEP2-WINDOWS-PARTITION-DISK1-FIXED.ps1 must be completed successfully
#>

# Configuration
$DISK_NUMBER = 1
$HANDOVER_DIR = "$env:USERPROFILE\Desktop"
$TIMESTAMP = Get-Date -Format "yyyyMMdd-HHmmss"

# Expected layout
$EXPECTED_LAYOUT = @(
    @{ Number = 1; Label = "Games-Universal"; SizeGB = 900; FileSystem = "NTFS"; DriveLetter = "H" },
    @{ Number = 2; Label = "Claude-AI-Data"; SizeGB = 500; FileSystem = "RAW"; DriveLetter = "I" },
    @{ Number = 3; Label = "Development"; SizeGB = 200; FileSystem = "RAW"; DriveLetter = "L" },
    @{ Number = 4; Label = "Windows-Only"; SizeGB = 150; FileSystem = "NTFS"; DriveLetter = "K" },
    @{ Number = 5; Label = "Transfer"; SizeGB = 50; FileSystem = "exFAT"; DriveLetter = "J" }
)

# Colors
$RED = "Red"
$GREEN = "Green"
$YELLOW = "Yellow"
$CYAN = "Cyan"
$GRAY = "Gray"

Write-Host "`n========================================" -ForegroundColor $CYAN
Write-Host "STEP 3: VERIFY PARTITION LAYOUT" -ForegroundColor $CYAN
Write-Host "========================================`n" -ForegroundColor $CYAN

# Function to create handover document
function New-HandoverDoc {
    param(
        [string]$Status,
        [string]$Details,
        [array]$VerificationResults
    )

    $handoverPath = Join-Path $HANDOVER_DIR "HANDOVER-VERIFICATION-$TIMESTAMP.md"

    $resultTable = ""
    if ($VerificationResults) {
        $resultTable = "`n## Verification Results`n`n"
        $resultTable += "| # | Label | Expected | Actual | Status |`n"
        $resultTable += "|---|-------|----------|--------|--------|`n"
        foreach ($result in $VerificationResults) {
            $resultTable += "| $($result.Number) | $($result.Label) | $($result.Expected) | $($result.Actual) | $($result.Status) |`n"
        }
    }

    $content = @"
---
project: kenl - Bazza-DX SAGE Framework
status: $Status
timestamp: $TIMESTAMP
atom: ATOM-CFG-20251112-003
---

# STEP 3: Partition Verification Results

**Timestamp:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Disk Number:** $DISK_NUMBER
**Status:** $Status

$resultTable

## Details

$Details

## Next Steps (Linux Side)

Boot into Bazzite-DX and format the RAW partitions:

\`\`\`bash
# Identify partitions
lsblk -o NAME,SIZE,FSTYPE,LABEL /dev/sdb

# Should show:
# sdb                      1.8T
# ├─sdb1   Games-Universal 900G ntfs
# ├─sdb2   (no label)      500G       ← Format as ext4
# ├─sdb3   (no label)      200G       ← Format as ext4
# ├─sdb4   Windows-Only    150G ntfs
# └─sdb5   Transfer         ~50G exfat

# Format Claude-AI-Data (Partition 2)
sudo mkfs.ext4 -L "Claude-AI-Data" /dev/sdb2

# Format Development (Partition 3)
sudo mkfs.ext4 -L "Development" /dev/sdb3

# Verify formatting
lsblk -o NAME,SIZE,FSTYPE,LABEL /dev/sdb

# Create mount points
sudo mkdir -p /mnt/{games-universal,claude-ai,development,windows-only,transfer}

# Get UUIDs for /etc/fstab
sudo blkid /dev/sdb*

# Add to /etc/fstab (replace UUIDs with your actual values):
# UUID=XXXX-XXXX /mnt/games-universal ntfs-3g defaults,uid=1000,gid=1000,umask=022 0 0
# UUID=YYYY-YYYY /mnt/claude-ai ext4 defaults,noatime 0 2
# UUID=ZZZZ-ZZZZ /mnt/development ext4 defaults,noatime 0 2
# UUID=AAAA-AAAA /mnt/windows-only ntfs-3g defaults,uid=1000,gid=1000,umask=022 0 0
# UUID=BBBB-BBBB /mnt/transfer exfat defaults,uid=1000,gid=1000,umask=022 0 0

# Mount all
sudo mount -a

# Verify
df -h | grep sdb
\`\`\`

## Related Documents

- \`/home/user/kenl/scripts/1.8TB_EXTERNAL_DRIVE_LAYOUT.md\` - Full design spec
- \`/home/user/kenl/scripts/KENL_WIN11_DUALBOOT_SETUP.md\` - Dual-boot guide

---
**ATOM-CFG-20251112-003**
"@

    $content | Out-File -FilePath $handoverPath -Encoding UTF8
    Write-Host "`n✓ Handover document created: $handoverPath" -ForegroundColor $GREEN
}

# Step 1: Verify disk exists
Write-Host "[1/3] Checking Disk $DISK_NUMBER exists..." -ForegroundColor $YELLOW

try {
    $disk = Get-Disk -Number $DISK_NUMBER -ErrorAction Stop
    Write-Host "✓ Found disk: $($disk.FriendlyName) ($([math]::Round($disk.Size / 1GB, 2)) GB)" -ForegroundColor $GREEN
} catch {
    Write-Host "❌ ERROR: Cannot find Disk $DISK_NUMBER" -ForegroundColor $RED
    Write-Host "   Did you run STEP1 and STEP2 first?" -ForegroundColor $RED
    exit 1
}

# Step 2: Get all partitions
Write-Host "`n[2/3] Checking partition layout..." -ForegroundColor $YELLOW

$partitions = Get-Partition -DiskNumber $DISK_NUMBER -ErrorAction SilentlyContinue |
    Where-Object { $_.Type -ne 'Reserved' } |
    Sort-Object PartitionNumber

if (-not $partitions) {
    Write-Host "❌ ERROR: No partitions found on Disk $DISK_NUMBER" -ForegroundColor $RED
    Write-Host "   Run STEP2-WINDOWS-PARTITION-DISK1-FIXED.ps1 first" -ForegroundColor $RED
    New-HandoverDoc -Status "FAILED" -Details "No partitions found on disk" -VerificationResults $null
    exit 1
}

$partitionCount = $partitions.Count
Write-Host "✓ Found $partitionCount partitions" -ForegroundColor $(if ($partitionCount -eq 5) { $GREEN } else { $YELLOW })

if ($partitionCount -ne 5) {
    Write-Host "⚠️  WARNING: Expected 5 partitions, found $partitionCount" -ForegroundColor $YELLOW
}

# Step 3: Verify each partition
Write-Host "`n[3/3] Verifying partition details...`n" -ForegroundColor $YELLOW

$verificationResults = @()
$allGood = $true

foreach ($expected in $EXPECTED_LAYOUT) {
    $partNum = $expected.Number
    $partition = $partitions | Where-Object { $_.PartitionNumber -eq $partNum }

    Write-Host "Partition $partNum - $($expected.Label):" -ForegroundColor $CYAN

    if (-not $partition) {
        Write-Host "  ❌ NOT FOUND" -ForegroundColor $RED
        $verificationResults += @{
            Number   = $partNum
            Label    = $expected.Label
            Expected = "$($expected.SizeGB)GB $($expected.FileSystem)"
            Actual   = "NOT FOUND"
            Status   = "❌ Missing"
        }
        $allGood = $false
        continue
    }

    # Get volume info
    $volume = Get-Volume -Partition $partition -ErrorAction SilentlyContinue
    $actualFS = if ($volume -and $volume.FileSystem) { $volume.FileSystem } else { "RAW" }
    $actualLabel = if ($volume -and $volume.FileSystemLabel) { $volume.FileSystemLabel } else { "(no label)" }
    $actualSize = [math]::Round($partition.Size / 1GB, 2)
    $actualDrive = if ($partition.DriveLetter) { "$($partition.DriveLetter):" } else { "N/A" }

    # Display actual info
    Write-Host "  Drive Letter: $actualDrive" -ForegroundColor $GRAY
    Write-Host "  Size: $actualSize GB (expected ~$($expected.SizeGB) GB)" -ForegroundColor $GRAY
    Write-Host "  Filesystem: $actualFS (expected $($expected.FileSystem))" -ForegroundColor $GRAY
    Write-Host "  Label: $actualLabel" -ForegroundColor $GRAY

    # Verify filesystem type
    $fsMatch = $actualFS -eq $expected.FileSystem
    if ($fsMatch) {
        Write-Host "  ✓ Filesystem type: CORRECT" -ForegroundColor $GREEN
    } elseif ($actualFS -eq "RAW" -or $actualFS -eq "") {
        Write-Host "  ⚠️  Filesystem: RAW (format as $($expected.FileSystem) in Linux)" -ForegroundColor $YELLOW
    } else {
        Write-Host "  ❌ Filesystem: WRONG (expected $($expected.FileSystem), got $actualFS)" -ForegroundColor $RED
        $allGood = $false
    }

    # Verify size (allow 10% tolerance)
    $sizeTolerance = $expected.SizeGB * 0.1
    $sizeMatch = [Math]::Abs($actualSize - $expected.SizeGB) -le $sizeTolerance
    if ($sizeMatch) {
        Write-Host "  ✓ Size: CORRECT" -ForegroundColor $GREEN
    } else {
        Write-Host "  ⚠️  Size: $actualSize GB (expected ~$($expected.SizeGB) GB)" -ForegroundColor $YELLOW
    }

    # Test write access for Windows-accessible filesystems
    if ($actualDrive -ne "N/A" -and $actualFS -in @("NTFS", "exFAT", "FAT32")) {
        $testFile = "$actualDrive\KENL-VERIFY-$TIMESTAMP.txt"
        try {
            # Wait a moment for filesystem to be ready
            Start-Sleep -Milliseconds 500

            "KENL verification test - $(Get-Date)" | Out-File -FilePath $testFile -ErrorAction Stop
            $testContent = Get-Content -Path $testFile -ErrorAction Stop
            Remove-Item -Path $testFile -Force -ErrorAction SilentlyContinue

            Write-Host "  ✓ Write test: PASSED" -ForegroundColor $GREEN
            $writeStatus = "✓ Writable"
        } catch {
            Write-Host "  ❌ Write test: FAILED - $($_.Exception.Message)" -ForegroundColor $RED
            $writeStatus = "❌ Write failed: $($_.Exception.Message)"
            $allGood = $false
        }
    } elseif ($actualFS -eq "RAW" -or $actualFS -eq "") {
        Write-Host "  ⏸️  Write test: SKIPPED (RAW partition - format in Linux)" -ForegroundColor $GRAY
        $writeStatus = "⏸️  Format in Linux"
    } else {
        Write-Host "  ⏸️  Write test: SKIPPED (no drive letter)" -ForegroundColor $GRAY
        $writeStatus = "⏸️  No drive letter"
    }

    Write-Host ""

    # Add to results
    $status = if ($fsMatch -or ($actualFS -eq "RAW" -and $expected.FileSystem -in @("RAW", "ext4"))) {
        if ($writeStatus -like "*failed*") { "⚠️ Format OK, write failed" } else { "✓ OK" }
    } else {
        "❌ Wrong filesystem"
    }

    $verificationResults += @{
        Number   = $partNum
        Label    = $actualLabel
        Expected = "$($expected.SizeGB)GB $($expected.FileSystem)"
        Actual   = "$actualSize GB $actualFS"
        Status   = "$status - $writeStatus"
    }
}

# Summary
Write-Host "========================================" -ForegroundColor $CYAN
Write-Host "VERIFICATION SUMMARY" -ForegroundColor $CYAN
Write-Host "========================================`n" -ForegroundColor $CYAN

# Count Windows-accessible partitions
$ntfsPartitions = $partitions | Where-Object {
    $vol = Get-Volume -Partition $_ -ErrorAction SilentlyContinue
    $vol -and $vol.FileSystem -eq "NTFS"
}

$exfatPartitions = $partitions | Where-Object {
    $vol = Get-Volume -Partition $_ -ErrorAction SilentlyContinue
    $vol -and $vol.FileSystem -eq "exFAT"
}

$rawPartitions = $partitions | Where-Object {
    $vol = Get-Volume -Partition $_ -ErrorAction SilentlyContinue
    (-not $vol) -or (-not $vol.FileSystem) -or $vol.FileSystem -eq ""
}

Write-Host "Windows-accessible partitions:" -ForegroundColor $YELLOW
Write-Host "  NTFS: $($ntfsPartitions.Count) (expected 2)" -ForegroundColor $(if ($ntfsPartitions.Count -eq 2) { $GREEN } else { $YELLOW })
if ($ntfsPartitions) {
    foreach ($part in $ntfsPartitions) {
        $vol = Get-Volume -Partition $part
        Write-Host "    - $($part.DriveLetter): $($vol.FileSystemLabel) ($([math]::Round($part.Size / 1GB, 2)) GB)" -ForegroundColor $GRAY
    }
}

Write-Host "  exFAT: $($exfatPartitions.Count) (expected 1)" -ForegroundColor $(if ($exfatPartitions.Count -eq 1) { $GREEN } else { $YELLOW })
if ($exfatPartitions) {
    foreach ($part in $exfatPartitions) {
        $vol = Get-Volume -Partition $part
        Write-Host "    - $($part.DriveLetter): $($vol.FileSystemLabel) ($([math]::Round($part.Size / 1GB, 2)) GB)" -ForegroundColor $GRAY
    }
}

Write-Host "`nLinux-only partitions (RAW - format as ext4):" -ForegroundColor $YELLOW
Write-Host "  RAW: $($rawPartitions.Count) (expected 2)" -ForegroundColor $(if ($rawPartitions.Count -eq 2) { $GREEN } else { $YELLOW })
if ($rawPartitions) {
    foreach ($part in $rawPartitions) {
        Write-Host "    - Partition $($part.PartitionNumber) ($([math]::Round($part.Size / 1GB, 2)) GB) → Format as ext4 in Linux" -ForegroundColor $GRAY
    }
}

# Final status
Write-Host ""
if ($allGood -and $ntfsPartitions.Count -eq 2 -and $exfatPartitions.Count -eq 1 -and $rawPartitions.Count -eq 2) {
    Write-Host "========================================" -ForegroundColor $GREEN
    Write-Host "✓ VERIFICATION PASSED" -ForegroundColor $GREEN
    Write-Host "========================================" -ForegroundColor $GREEN

    $details = @"
All partitions verified successfully!

**Summary:**
- 2 NTFS partitions (Games-Universal, Windows-Only): ✅ Ready in Windows
- 1 exFAT partition (Transfer): ✅ Ready in Windows
- 2 RAW partitions (Claude-AI-Data, Development): ⚠️ Format as ext4 in Linux

**Windows-accessible storage:**
$(foreach ($part in $ntfsPartitions + $exfatPartitions) {
    $vol = Get-Volume -Partition $part
    "- $($part.DriveLetter): $($vol.FileSystemLabel) ($([math]::Round($part.Size / 1GB, 2)) GB, $($vol.FileSystem))"
})

**Next Steps:**
1. Boot into Bazzite-DX Linux
2. Format partitions 2 and 3 as ext4 (see handover document)
3. Configure /etc/fstab for auto-mounting
4. Set up Steam library and Claude AI workspace

Partition layout is complete and ready for use!
"@

    New-HandoverDoc -Status "SUCCESS" -Details $details -VerificationResults $verificationResults

    Write-Host "`nAll Windows partitions are accessible and working!" -ForegroundColor $GREEN
    Write-Host "Boot into Bazzite-DX to format the RAW partitions as ext4." -ForegroundColor $CYAN

} elseif ($ntfsPartitions.Count -eq 0 -and $exfatPartitions.Count -eq 0) {
    Write-Host "========================================" -ForegroundColor $RED
    Write-Host "❌ VERIFICATION FAILED" -ForegroundColor $RED
    Write-Host "========================================" -ForegroundColor $RED

    $details = @"
No NTFS or exFAT partitions detected!

This indicates the partitions may not have been formatted correctly in STEP2.

**Troubleshooting:**
1. Run STEP2-WINDOWS-PARTITION-DISK1-FIXED.ps1 again
2. Check if Windows can see the partitions in Disk Management:
   - Press Win+R, type 'diskmgmt.msc', press Enter
   - Look for Disk $DISK_NUMBER
   - Check if partitions show correct filesystems

**Possible causes:**
- Partitions created but not formatted
- Formatting failed silently
- Drive letters not assigned
- Disk not initialized as GPT

Re-run STEP2 to recreate partitions with proper formatting.
"@

    New-HandoverDoc -Status "FAILED" -Details $details -VerificationResults $verificationResults

    Write-Host "`n❌ No NTFS or exFAT partitions found!" -ForegroundColor $RED
    Write-Host "Re-run STEP2-WINDOWS-PARTITION-DISK1-FIXED.ps1" -ForegroundColor $YELLOW

} else {
    Write-Host "========================================" -ForegroundColor $YELLOW
    Write-Host "⚠️  VERIFICATION INCOMPLETE" -ForegroundColor $YELLOW
    Write-Host "========================================" -ForegroundColor $YELLOW

    $details = @"
Verification completed with warnings.

**Issues detected:**
$(if ($ntfsPartitions.Count -ne 2) { "- Expected 2 NTFS partitions, found $($ntfsPartitions.Count)" } else { "" })
$(if ($exfatPartitions.Count -ne 1) { "- Expected 1 exFAT partition, found $($exfatPartitions.Count)" } else { "" })
$(if ($rawPartitions.Count -ne 2) { "- Expected 2 RAW partitions, found $($rawPartitions.Count)" } else { "" })

**Current status:**
- NTFS partitions: $($ntfsPartitions.Count)
- exFAT partitions: $($exfatPartitions.Count)
- RAW partitions: $($rawPartitions.Count)

Review the verification results above and re-run STEP2 if needed.
"@

    New-HandoverDoc -Status "INCOMPLETE" -Details $details -VerificationResults $verificationResults

    Write-Host "`nSome partitions may need attention." -ForegroundColor $YELLOW
    Write-Host "Check handover document for details." -ForegroundColor $CYAN
}
