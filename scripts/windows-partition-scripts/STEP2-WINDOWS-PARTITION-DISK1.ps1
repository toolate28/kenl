#Requires -RunAsAdministrator
<#
.SYNOPSIS
    STEP 2: Create hybrid Linux/Windows partition layout on 1.8TB external drive
.DESCRIPTION
    Creates 5 partitions with correct filesystem types for dual-boot gaming setup:
    1. Games-Universal (900GB, NTFS) - Shared Steam library
    2. Claude-AI-Data (500GB, RAW → format as ext4 in Linux)
    3. Development (200GB, RAW → format as ext4 in Linux)
    4. Windows-Only (150GB, NTFS) - Anti-cheat games like BF6
    5. Transfer (50GB, exFAT) - Cross-OS file exchange

.NOTES
    ATOM Tag: ATOM-CFG-20251112-002
    Project: kenl - Bazza-DX SAGE Framework
    Author: Claude Code
    Date: 2025-11-12

    PREREQUISITES: STEP1-WINDOWS-WIPE-DISK1.ps1 must be completed successfully
#>

# Configuration
$DISK_NUMBER = 1
$HANDOVER_DIR = "$env:USERPROFILE\Desktop"
$TIMESTAMP = Get-Date -Format "yyyyMMdd-HHmmss"

# Partition sizes (in GB)
$PARTITION_SIZES = @{
    GamesUniversal = 900
    ClaudeAI       = 500
    Development    = 200
    WindowsOnly    = 150
    Transfer       = 0  # Use remaining space
}

# Colors
$RED = "Red"
$GREEN = "Green"
$YELLOW = "Yellow"
$CYAN = "Cyan"
$GRAY = "Gray"

Write-Host "`n========================================" -ForegroundColor $CYAN
Write-Host "STEP 2: PARTITION DISK $DISK_NUMBER" -ForegroundColor $CYAN
Write-Host "========================================`n" -ForegroundColor $CYAN

# Function to create handover document
function New-HandoverDoc {
    param(
        [string]$Status,
        [array]$PartitionInfo,
        [string]$Details
    )

    $handoverPath = Join-Path $HANDOVER_DIR "HANDOVER-PARTITION-$TIMESTAMP.md"

    $partitionTable = ""
    if ($PartitionInfo) {
        $partitionTable = "`n## Partition Summary`n`n"
        $partitionTable += "| # | Label | Size | FS | Drive | Status |`n"
        $partitionTable += "|---|-------|------|----|-------|--------|`n"
        foreach ($part in $PartitionInfo) {
            $partitionTable += "| $($part.Number) | $($part.Label) | $($part.Size) | $($part.FileSystem) | $($part.DriveLetter) | $($part.Status) |`n"
        }
    }

    $content = @"
---
project: kenl - Bazza-DX SAGE Framework
status: $Status
timestamp: $TIMESTAMP
atom: ATOM-CFG-20251112-002
---

# STEP 2: Partition Creation Results

**Timestamp:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Disk Number:** $DISK_NUMBER
**Status:** $Status

$partitionTable

## Details

$Details

## Next Steps

"@ + @'
If successful, proceed to:
**STEP3-WINDOWS-MOUNT-CHECK.ps1**

This will verify all partitions are accessible and formatted correctly.

## Linux Side (After Booting Bazzite-DX)

Format the RAW partitions as ext4:
```bash
# Identify the partitions (should be /dev/sdb2, /dev/sdb3)
lsblk -o NAME,SIZE,FSTYPE,LABEL /dev/sdb

# Format Claude-AI-Data (Partition 2)
sudo mkfs.ext4 -L "Claude-AI-Data" /dev/sdb2

# Format Development (Partition 3)
sudo mkfs.ext4 -L "Development" /dev/sdb3

# Verify
lsblk -o NAME,SIZE,FSTYPE,LABEL /dev/sdb
```

## Related Documents

- `/home/user/kenl/scripts/1.8TB_EXTERNAL_DRIVE_LAYOUT.md` - Full design spec
- `/home/user/kenl/scripts/KENL_WIN11_DUALBOOT_SETUP.md` - Dual-boot guide

---
**ATOM-CFG-20251112-002**
'@

    $content | Out-File -FilePath $handoverPath -Encoding UTF8
    Write-Host "`n✓ Handover document created: $handoverPath" -ForegroundColor $GREEN
}

# Step 1: Verify disk is ready
Write-Host "[1/7] Verifying Disk $DISK_NUMBER is ready..." -ForegroundColor $YELLOW

try {
    $disk = Get-Disk -Number $DISK_NUMBER -ErrorAction Stop
} catch {
    Write-Host "❌ ERROR: Cannot find Disk $DISK_NUMBER" -ForegroundColor $RED
    Write-Host "   Did you run STEP1-WINDOWS-WIPE-DISK1.ps1 first?" -ForegroundColor $RED
    exit 1
}

# Check if disk is clean (no partitions)
$existingPartitions = Get-Partition -DiskNumber $DISK_NUMBER -ErrorAction SilentlyContinue |
    Where-Object { $_.Type -ne 'Reserved' }

if ($existingPartitions) {
    Write-Host "⚠️  WARNING: Disk $DISK_NUMBER already has partitions:" -ForegroundColor $YELLOW
    $existingPartitions | Format-Table PartitionNumber, DriveLetter, Size, Type -AutoSize

    $confirm = Read-Host "`nWipe disk and continue? (type YES)"
    if ($confirm -eq "YES") {
        Write-Host "   Wiping disk..." -ForegroundColor $YELLOW
        Clear-Disk -Number $DISK_NUMBER -RemoveData -RemoveOEM -Confirm:$false
        Start-Sleep -Seconds 2
        $disk = Get-Disk -Number $DISK_NUMBER
    } else {
        Write-Host "❌ Aborted" -ForegroundColor $RED
        exit 1
    }
}

Write-Host "✓ Disk is clean and ready" -ForegroundColor $GREEN
Write-Host "   Size: $([math]::Round($disk.Size / 1GB, 2)) GB" -ForegroundColor $CYAN

# Step 2: Initialize disk as GPT
Write-Host "`n[2/7] Initializing disk as GPT..." -ForegroundColor $YELLOW

try {
    if ($disk.PartitionStyle -eq 'RAW') {
        Initialize-Disk -Number $DISK_NUMBER -PartitionStyle GPT -ErrorAction Stop
        Start-Sleep -Seconds 1
        $disk = Get-Disk -Number $DISK_NUMBER
        Write-Host "✓ Disk initialized as GPT" -ForegroundColor $GREEN
    } elseif ($disk.PartitionStyle -eq 'GPT') {
        Write-Host "✓ Disk already GPT" -ForegroundColor $GREEN
    } else {
        Write-Host "❌ ERROR: Disk is $($disk.PartitionStyle), expected GPT or RAW" -ForegroundColor $RED
        exit 1
    }
} catch {
    Write-Host "❌ ERROR: Failed to initialize disk: $_" -ForegroundColor $RED
    exit 1
}

# Step 3: Create Partition 1 - Games-Universal (NTFS)
Write-Host "`n[3/7] Creating Partition 1: Games-Universal (900GB, NTFS)..." -ForegroundColor $YELLOW

try {
    $part1 = New-Partition -DiskNumber $DISK_NUMBER `
        -Size ($PARTITION_SIZES.GamesUniversal * 1GB) `
        -DriveLetter H `
        -ErrorAction Stop

    Start-Sleep -Seconds 2

    Write-Host "   Formatting as NTFS..." -ForegroundColor $YELLOW
    Format-Volume -DriveLetter H `
        -FileSystem NTFS `
        -NewFileSystemLabel "Games-Universal" `
        -Confirm:$false `
        -ErrorAction Stop | Out-Null

    Write-Host "✓ Partition 1 (H:) created: Games-Universal (900GB, NTFS)" -ForegroundColor $GREEN
    Write-Host "   Purpose: Shared Steam library (both Windows and Linux)" -ForegroundColor $GRAY
} catch {
    Write-Host "❌ ERROR: Failed to create Partition 1: $_" -ForegroundColor $RED
    New-HandoverDoc -Status "FAILED" -PartitionInfo $null -Details "Failed at Partition 1: $_"
    exit 1
}

# Step 4: Create Partition 2 - Claude-AI-Data (RAW → ext4 in Linux)
Write-Host "`n[4/7] Creating Partition 2: Claude-AI-Data (500GB, RAW)..." -ForegroundColor $YELLOW

try {
    $part2 = New-Partition -DiskNumber $DISK_NUMBER `
        -Size ($PARTITION_SIZES.ClaudeAI * 1GB) `
        -DriveLetter I `
        -ErrorAction Stop

    Write-Host "✓ Partition 2 (I:) created: Claude-AI-Data (500GB, RAW)" -ForegroundColor $GREEN
    Write-Host "   ⚠️  Format as ext4 in Bazzite-DX Linux" -ForegroundColor $YELLOW
    Write-Host "   Purpose: LLM models, datasets, vector databases" -ForegroundColor $GRAY
} catch {
    Write-Host "❌ ERROR: Failed to create Partition 2: $_" -ForegroundColor $RED
    New-HandoverDoc -Status "FAILED" -PartitionInfo $null -Details "Failed at Partition 2: $_"
    exit 1
}

# Step 5: Create Partition 3 - Development (RAW → ext4 in Linux)
Write-Host "`n[5/7] Creating Partition 3: Development (200GB, RAW)..." -ForegroundColor $YELLOW

try {
    $part3 = New-Partition -DiskNumber $DISK_NUMBER `
        -Size ($PARTITION_SIZES.Development * 1GB) `
        -DriveLetter L `
        -ErrorAction Stop

    Write-Host "✓ Partition 3 (L:) created: Development (200GB, RAW)" -ForegroundColor $GREEN
    Write-Host "   ⚠️  Format as ext4 in Bazzite-DX Linux" -ForegroundColor $YELLOW
    Write-Host "   Purpose: Distrobox containers, Git repos, Python venvs" -ForegroundColor $GRAY
} catch {
    Write-Host "❌ ERROR: Failed to create Partition 3: $_" -ForegroundColor $RED
    New-HandoverDoc -Status "FAILED" -PartitionInfo $null -Details "Failed at Partition 3: $_"
    exit 1
}

# Step 6: Create Partition 4 - Windows-Only (NTFS) ← FIXED: Was incorrectly marked for ext4
Write-Host "`n[6/7] Creating Partition 4: Windows-Only (150GB, NTFS)..." -ForegroundColor $YELLOW

try {
    $part4 = New-Partition -DiskNumber $DISK_NUMBER `
        -Size ($PARTITION_SIZES.WindowsOnly * 1GB) `
        -DriveLetter K `
        -ErrorAction Stop

    Start-Sleep -Seconds 2

    Write-Host "   Formatting as NTFS..." -ForegroundColor $YELLOW
    Format-Volume -DriveLetter K `
        -FileSystem NTFS `
        -NewFileSystemLabel "Windows-Only" `
        -Confirm:$false `
        -ErrorAction Stop | Out-Null

    Write-Host "✓ Partition 4 (K:) created: Windows-Only (150GB, NTFS)" -ForegroundColor $GREEN
    Write-Host "   Purpose: BF6, BF2042, EA App - Anti-cheat games that require Windows" -ForegroundColor $GRAY
} catch {
    Write-Host "❌ ERROR: Failed to create Partition 4: $_" -ForegroundColor $RED
    New-HandoverDoc -Status "FAILED" -PartitionInfo $null -Details "Failed at Partition 4: $_"
    exit 1
}

# Step 7: Create Partition 5 - Transfer (exFAT) ← FIXED: Was incorrectly marked for ext4
Write-Host "`n[7/7] Creating Partition 5: Transfer (remaining space, exFAT)..." -ForegroundColor $YELLOW

try {
    # Use all remaining space
    $part5 = New-Partition -DiskNumber $DISK_NUMBER `
        -UseMaximumSize `
        -DriveLetter J `
        -ErrorAction Stop

    Start-Sleep -Seconds 2

    Write-Host "   Formatting as exFAT..." -ForegroundColor $YELLOW
    Format-Volume -DriveLetter J `
        -FileSystem exFAT `
        -NewFileSystemLabel "Transfer" `
        -Confirm:$false `
        -ErrorAction Stop | Out-Null

    $part5Size = [math]::Round((Get-Partition -DriveLetter J).Size / 1GB, 2)

    Write-Host "✓ Partition 5 (J:) created: Transfer ($part5Size GB, exFAT)" -ForegroundColor $GREEN
    Write-Host "   Purpose: Quick file exchange between Windows, Linux, and macOS" -ForegroundColor $GRAY
} catch {
    Write-Host "❌ ERROR: Failed to create Partition 5: $_" -ForegroundColor $RED
    New-HandoverDoc -Status "FAILED" -PartitionInfo $null -Details "Failed at Partition 5: $_"
    exit 1
}

# Verification
Write-Host "`n========================================" -ForegroundColor $CYAN
Write-Host "Verifying partition layout..." -ForegroundColor $YELLOW
Write-Host "========================================`n" -ForegroundColor $CYAN

Start-Sleep -Seconds 2

$partitions = Get-Partition -DiskNumber $DISK_NUMBER | Where-Object { $_.Type -ne 'Reserved' }
$partitionInfo = @()

foreach ($partition in $partitions) {
    $vol = Get-Volume -Partition $partition -ErrorAction SilentlyContinue
    $sizeGB = [math]::Round($partition.Size / 1GB, 2)
    $fs = if ($vol) { $vol.FileSystem } else { "RAW" }
    $label = if ($vol) { $vol.FileSystemLabel } else { "Unformatted" }
    $driveLetter = if ($partition.DriveLetter) { "$($partition.DriveLetter):" } else { "N/A" }

    # Determine status
    $status = "✅ Ready"
    $statusColor = $GREEN

    if ($fs -eq "RAW" -or $fs -eq "") {
        $status = "⚠️ Format as ext4 in Linux"
        $statusColor = $YELLOW
    }

    # Display partition info
    Write-Host "Partition $($partition.PartitionNumber) ($driveLetter, $sizeGB GB) - $label ($fs)" -ForegroundColor $CYAN
    Write-Host "  Status: $status" -ForegroundColor $statusColor

    # Test write access for formatted partitions
    if ($partition.DriveLetter -and $fs -ne "RAW" -and $fs -ne "") {
        $testFile = "$($partition.DriveLetter):\KENL-TEST-$TIMESTAMP.txt"
        try {
            "KENL partition test - $(Get-Date)" | Out-File -FilePath $testFile -ErrorAction Stop
            Remove-Item -Path $testFile -ErrorAction SilentlyContinue
            Write-Host "  ✓ Write test: PASSED" -ForegroundColor $GREEN
        } catch {
            Write-Host "  ❌ Write test: FAILED - $($_.Exception.Message)" -ForegroundColor $RED
            $status = "❌ Write access failed"
        }
    }

    Write-Host ""

    # Add to info array
    $partitionInfo += @{
        Number      = $partition.PartitionNumber
        Label       = $label
        Size        = "$sizeGB GB"
        FileSystem  = $fs
        DriveLetter = $driveLetter
        Status      = $status
    }
}

# Summary
Write-Host "========================================" -ForegroundColor $GREEN
Write-Host "✓ ALL PARTITIONS CREATED SUCCESSFULLY" -ForegroundColor $GREEN
Write-Host "========================================`n" -ForegroundColor $GREEN

Write-Host "IMPORTANT NOTES:" -ForegroundColor $YELLOW
Write-Host "1. Partitions 2 (I:) and 3 (L:) are RAW - format as ext4 in Linux" -ForegroundColor $YELLOW
Write-Host "2. Partition 4 (K:) is NTFS for Windows anti-cheat games (BF6)" -ForegroundColor $YELLOW
Write-Host "3. Partition 5 (J:) is exFAT for cross-OS file transfer" -ForegroundColor $YELLOW
Write-Host "4. Partition 1 (H:) is NTFS for shared Steam library (both OSes)" -ForegroundColor $YELLOW

# Create handover document
$details = @"
All 5 partitions created successfully on Disk $DISK_NUMBER.

**Partition Layout:**

1. **Games-Universal (H:, 900GB, NTFS)** - ✅ Ready
   - Shared Steam library accessible from both Windows and Linux
   - Install games here to play on both OSes

2. **Claude-AI-Data (I:, 500GB, RAW)** - ⚠️ Format as ext4 in Linux
   - LLM models (Qwen, Ollama)
   - Vector databases (ChromaDB)
   - Training datasets

3. **Development (L:, 200GB, RAW)** - ⚠️ Format as ext4 in Linux
   - Distrobox containers
   - Git repositories
   - Python virtual environments

4. **Windows-Only (K:, 150GB, NTFS)** - ✅ Ready
   - Battlefield 6 / Battlefield 2042
   - EA App install location
   - Games requiring Windows anti-cheat

5. **Transfer (J:, $([math]::Round((Get-Partition -DriveLetter J).Size / 1GB, 2)) GB, exFAT)** - ✅ Ready
   - Quick file exchange between OSes
   - Screenshots, videos, documents
   - Compatible with Windows, Linux, macOS

**Next Steps:**
1. Run STEP3-WINDOWS-MOUNT-CHECK.ps1 to verify Windows partitions
2. Boot into Bazzite-DX Linux
3. Format partitions 2 and 3 as ext4 (see handover doc for commands)
4. Configure Steam library and Claude AI workspace
"@

New-HandoverDoc -Status "SUCCESS" -PartitionInfo $partitionInfo -Details $details

Write-Host "`nNext step: Run STEP3-WINDOWS-MOUNT-CHECK.ps1" -ForegroundColor $CYAN
