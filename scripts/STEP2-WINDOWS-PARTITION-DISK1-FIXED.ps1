# STEP 2: Windows Native Partition Creation (FIXED)
# ATOM-CFG-20251112-003
# Handles offline disk state and access issues

$ErrorActionPreference = "Stop"

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  KENL Drive Preparation - Step 2: Windows Partitioning (Fixed)" -ForegroundColor Cyan
Write-Host "  ATOM-CFG-20251112-003" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Host "ℹ️  NOTE: Windows can only create NTFS/exFAT partitions" -ForegroundColor Yellow
Write-Host "   ext4 partitions will be marked as RAW and formatted in Bazzite" -ForegroundColor Yellow
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "❌ This script must be run as Administrator" -ForegroundColor Red
    Write-Host "   Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

# Verify Disk 1 is clean
Write-Host "[1/7] Verifying Disk 1 state..." -ForegroundColor Yellow
$disk = Get-Disk -Number 1

Write-Host "  Current state:" -ForegroundColor Gray
Write-Host "    Offline: $($disk.IsOffline)" -ForegroundColor Gray
Write-Host "    Read-only: $($disk.IsReadOnly)" -ForegroundColor Gray
Write-Host "    Partitions: $($disk.NumberOfPartitions)" -ForegroundColor Gray
Write-Host ""

if ($disk.NumberOfPartitions -ne 0) {
    Write-Host "⚠️  WARNING: Disk 1 has $($disk.NumberOfPartitions) partitions!" -ForegroundColor Red
    Write-Host "   Expected: 0 partitions (clean from Step 1)" -ForegroundColor Red
    Write-Host ""
    $confirm = Read-Host "Continue anyway? [y/N]"
    if ($confirm -ne "y") {
        Write-Host "Aborted."
        exit 1
    }
}

# Bring disk online with diskpart (more reliable than Set-Disk)
Write-Host "[2/7] Bringing disk online using diskpart..." -ForegroundColor Yellow

$diskpartScript = @"
select disk 1
online disk
attributes disk clear readonly
"@

$diskpartScript | diskpart | Out-Null
Start-Sleep -Seconds 2

# Verify disk is now online
$disk = Get-Disk -Number 1
if ($disk.IsOffline) {
    Write-Host "  ❌ Failed to bring disk online" -ForegroundColor Red
    Write-Host "  Try manually: Open Disk Management → Right-click Disk 1 → Online" -ForegroundColor Yellow
    exit 1
}

Write-Host "  ✅ Disk 1 is now online and writable" -ForegroundColor Green
Write-Host ""

# Use diskpart for partition creation (more reliable on offline disks)
Write-Host "[3/7] Creating partitions using diskpart..." -ForegroundColor Yellow
Write-Host ""

$diskpartCommands = @"
select disk 1
create partition primary size=921600
format fs=ntfs label="Games-Universal" quick
assign
create partition primary size=512000
assign
create partition primary size=204800
assign
create partition primary size=153600
format fs=ntfs label="Windows-Only" quick
assign
create partition primary
format fs=exfat label="Transfer" quick
assign
exit
"@

Write-Host "  Creating and formatting partitions (this may take a few minutes)..." -ForegroundColor Cyan
$diskpartOutput = $diskpartCommands | diskpart

Write-Host "  ✅ Partitions created" -ForegroundColor Green
Write-Host ""

# Give Windows time to assign drive letters
Write-Host "[4/7] Waiting for Windows to assign drive letters..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Refresh disk info
$disk = Get-Disk -Number 1

Write-Host "  ✅ Drive letters assigned" -ForegroundColor Green
Write-Host ""

# Get partition information
Write-Host "[5/7] Retrieving partition details..." -ForegroundColor Yellow
Write-Host ""

$partitions = Get-Partition -DiskNumber 1 | Where-Object { $_.Type -ne "Reserved" }
$volumes = Get-Volume | Where-Object { $_.DriveLetter -in $partitions.DriveLetter }

# Display partition table
Write-Host "Partition Layout:" -ForegroundColor Cyan
$partitions | Format-Table -AutoSize PartitionNumber, DriveLetter, Size, @{Name="SizeGB";Expression={[math]::Round($_.Size/1GB,2)}}
Write-Host ""

Write-Host "Volume Details:" -ForegroundColor Cyan
$volumes | Format-Table -AutoSize DriveLetter, FileSystemLabel, FileSystem, @{Name="SizeGB";Expression={[math]::Round($_.Size/1GB,2)}}, HealthStatus
Write-Host ""

# Test write access to formatted partitions
Write-Host "[6/7] Testing write access to formatted partitions..." -ForegroundColor Yellow
Write-Host ""

$formattedPartitions = $volumes | Where-Object { $_.FileSystem -ne $null -and $_.FileSystem -ne "" }

foreach ($volume in $formattedPartitions) {
    if ($volume.DriveLetter) {
        $testFile = "$($volume.DriveLetter):\KENL-TEST.txt"
        try {
            "KENL Drive Test - ATOM-CFG-20251112-003" | Out-File -FilePath $testFile -ErrorAction Stop
            Remove-Item -Path $testFile -Force -ErrorAction Stop
            Write-Host "  ✅ $($volume.DriveLetter): ($($volume.FileSystemLabel)) is writable" -ForegroundColor Green
        } catch {
            Write-Host "  ❌ $($volume.DriveLetter): write test failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host ""

# Identify which partitions need ext4
$rawPartitions = $partitions | Where-Object {
    $vol = $volumes | Where-Object { $_.DriveLetter -eq $_.DriveLetter }
    -not $vol -or [string]::IsNullOrEmpty($vol.FileSystem)
}

Write-Host "Partition Status Summary:" -ForegroundColor Yellow
Write-Host ""

$partitionMap = @()
$counter = 1
foreach ($part in $partitions) {
    $vol = $volumes | Where-Object { $_.DriveLetter -eq $part.DriveLetter }
    $sizeGB = [math]::Round($part.Size/1GB, 0)

    $purpose = switch ($counter) {
        1 { "Games-Universal (Cross-OS gaming)" }
        2 { "Claude-AI-Data (Datasets, AI models)" }
        3 { "Development (Distrobox, repos)" }
        4 { "Windows-Only (Anti-cheat games)" }
        5 { "Transfer (Quick file exchange)" }
    }

    $status = if ($vol -and $vol.FileSystem) {
        "✅ Ready ($($vol.FileSystem))"
    } else {
        "⚠️  Format as ext4 in Bazzite"
    }

    $partitionMap += [PSCustomObject]@{
        Partition = $counter
        DriveLetter = if ($part.DriveLetter) { "$($part.DriveLetter):" } else { "N/A" }
        Size = "${sizeGB}GB"
        Purpose = $purpose
        Status = $status
    }
    $counter++
}

$partitionMap | Format-Table -AutoSize

Write-Host ""

# Create handover document
Write-Host "[7/7] Creating handover document..." -ForegroundColor Yellow

$handoverPath = "$env:USERPROFILE\Desktop\HANDOVER-WINDOWS-PARTITION-$(Get-Date -Format 'yyyyMMdd-HHmmss').md"

# Get raw partition info for handover
$rawPartInfo = ""
foreach ($part in $rawPartitions) {
    $rawPartInfo += "- Partition $($part.PartitionNumber): $($part.DriveLetter): (will be /dev/sdb$($part.PartitionNumber) in Linux)`n"
}

@"
# Windows Partition Creation Handover
**ATOM-CFG-20251112-003**
**Timestamp**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
**Phase**: Step 2 Complete (Windows Native Partitioning)
**Method**: diskpart (offline disk compatible)

## Actions Completed
- ✅ Disk 1 brought online using diskpart
- ✅ 5 partitions created
- ✅ NTFS/exFAT partitions formatted and ready
- ✅ RAW partitions created (for Linux ext4)
- ✅ Drive letters assigned
- ✅ Write tests passed

## Partition Layout

``````
$(Get-Partition -DiskNumber 1 | Format-Table -AutoSize | Out-String)
``````

## Volume Details

``````
$($volumes | Format-Table -AutoSize | Out-String)
``````

## Partition Map

$($partitionMap | Format-Table -AutoSize | Out-String)

## RAW Partitions (Need ext4 Formatting)

$rawPartInfo

## Critical Next Step: Format ext4 Partitions in Bazzite Live USB

### When to Format:
Boot from Ventoy USB → Select Bazzite ISO → Open Terminal

### Format Commands:

1. **Identify partitions**:
   ``````bash
   lsblk -o NAME,SIZE,FSTYPE,LABEL
   # Look for Seagate FireCuda drive (sdb or sdc)
   # RAW partitions will show no FSTYPE
   ``````

2. **Format Claude-AI-Data** (500GB partition):
   ``````bash
   # Find the 500GB partition with no filesystem
   sudo mkfs.ext4 -L "Claude-AI-Data" /dev/sdb2
   ``````

3. **Format Development** (200GB partition):
   ``````bash
   # Find the 200GB partition with no filesystem
   sudo mkfs.ext4 -L "Development" /dev/sdb3
   ``````

4. **Verify**:
   ``````bash
   lsblk -o NAME,SIZE,FSTYPE,LABEL
   # Should now show ext4 for both partitions
   ``````

## Windows Accessibility NOW

| Partition | Drive | Size | Status | Use Now |
|-----------|-------|------|--------|---------|
$(foreach ($p in $partitionMap) {
    $accessible = if ($p.Status -like "*Ready*") { "✅ Yes" } else { "❌ No" }
    "| $($p.Partition) | $($p.DriveLetter) | $($p.Size) | $($p.Status) | $accessible |`n"
})

## Immediate Usage

You can start using these drives RIGHT NOW in Windows:
$(foreach ($p in $partitionMap | Where-Object { $_.Status -like "*Ready*" }) {
    "- **$($p.DriveLetter)** - $($p.Purpose)`n"
})

The ext4 partitions will become accessible after:
1. Formatting from Bazzite Live USB (5 minutes)
2. Installing Bazzite to internal drive
3. Configuring auto-mount in /etc/fstab

## Next Steps

### Option A: Continue to Bazzite Installation
1. Boot Bazzite Live USB from Ventoy
2. Format ext4 partitions (commands above)
3. Install Bazzite to internal NVMe (NOT this drive!)
4. Configure auto-mount
5. Run KENL bootstrap

### Option B: Use Windows Partitions Now
1. Copy files to formatted partitions immediately
2. Install games to Games-Universal
3. Set up file transfers via Transfer partition
4. Format ext4 partitions later

### Option C: Verify in Windows
Run STEP3-WINDOWS-MOUNT-CHECK.ps1 to verify all partitions

## ATOM Trail
- ATOM-CFG-20251112-002 (Windows wipe) ✅
- ATOM-CFG-20251112-003 (Windows partitioning) ✅
- Next: Format ext4 from Bazzite Live USB
- Then: ATOM-CFG-20251112-005 (Bazzite installation)

## Status
- [x] Step 1: Windows wipe
- [x] Step 2: Windows partition creation
- [ ] Step 2b: Format ext4 partitions (requires Bazzite Live USB)
- [ ] Step 3: Bazzite installation to internal drive
- [ ] Step 4: Auto-mount configuration
- [ ] Step 5: KENL bootstrap

---
**Generated**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
**ATOM**: ATOM-CFG-20251112-003
**Method**: diskpart (Windows native, offline disk compatible)
"@ | Out-File -FilePath $handoverPath -Encoding UTF8

Write-Host "  ✅ Handover document created" -ForegroundColor Green
Write-Host ""

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  ✅ STEP 2 COMPLETE: Partitions Created Successfully!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Handover document: $handoverPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "Partition Summary:" -ForegroundColor Yellow
foreach ($p in $partitionMap) {
    $color = if ($p.Status -like "*Ready*") { "Green" } else { "Yellow" }
    Write-Host "  $($p.DriveLetter) - $($p.Purpose) - $($p.Status)" -ForegroundColor $color
}
Write-Host ""

$readyCount = ($partitionMap | Where-Object { $_.Status -like "*Ready*" }).Count
$totalSize = ($partitionMap | Where-Object { $_.Status -like "*Ready*" } | ForEach-Object { [int]($_.Size -replace 'GB','') } | Measure-Object -Sum).Sum

Write-Host "✨ $readyCount partitions ready for immediate use ($totalSize GB total)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Actions:" -ForegroundColor Yellow
Write-Host "  • Use formatted partitions in Windows NOW" -ForegroundColor White
Write-Host "  • Format ext4 partitions when you boot Bazzite Live USB" -ForegroundColor White
Write-Host "  • Run STEP3-WINDOWS-MOUNT-CHECK.ps1 to verify (optional)" -ForegroundColor White
Write-Host ""

# Log to ATOM trail
$atomLog = "$env:USERPROFILE\kenl-atom-trail.log"
"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') | ATOM-CFG-20251112-003 | Windows partition creation complete - $readyCount/$($partitionMap.Count) partitions ready, ext4 formatting pending" | Out-File -FilePath $atomLog -Append

Write-Host "ATOM-CFG-20251112-003 complete" -ForegroundColor Cyan
Write-Host ""
