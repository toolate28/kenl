# STEP 3: Windows Mount Verification (Optional)
# ATOM-CFG-20251112-004
# Verify NTFS/exFAT partitions are accessible after Linux partitioning

$ErrorActionPreference = "Stop"

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  KENL Drive Preparation - Step 3: Windows Mount Check" -ForegroundColor Cyan
Write-Host "  ATOM-CFG-20251112-004" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Detect Disk 1
Write-Host "[1/3] Detecting Disk 1 partitions..." -ForegroundColor Yellow
Write-Host ""

$disk = Get-Disk -Number 1
if ($disk.NumberOfPartitions -lt 5) {
    Write-Host "⚠️  WARNING: Expected 5 partitions, found $($disk.NumberOfPartitions)" -ForegroundColor Yellow
    Write-Host "   Did you run STEP2-LINUX-PARTITION-DISK.sh from Bazzite Live USB?" -ForegroundColor Yellow
    Write-Host ""
}

# Show all partitions
Get-Partition -DiskNumber 1 | Format-Table -AutoSize
Write-Host ""

# Check for expected NTFS/exFAT partitions
Write-Host "[2/3] Checking Windows-accessible partitions..." -ForegroundColor Yellow
Write-Host ""

$windowsPartitions = Get-Partition -DiskNumber 1 | Where-Object {
    $_.Type -eq "Basic" -and ($_.FileSystem -eq "NTFS" -or $_.FileSystem -eq "exFAT")
}

if ($windowsPartitions.Count -eq 0) {
    Write-Host "❌ No NTFS or exFAT partitions found" -ForegroundColor Red
    Write-Host "   Partitions may not have been created yet" -ForegroundColor Red
    exit 1
}

Write-Host "Found $($windowsPartitions.Count) Windows-accessible partitions:" -ForegroundColor Green
Write-Host ""

foreach ($partition in $windowsPartitions) {
    $volume = Get-Volume -Partition $partition -ErrorAction SilentlyContinue
    if ($volume) {
        Write-Host "  Partition $($partition.PartitionNumber):" -ForegroundColor Cyan
        Write-Host "    Drive Letter: $($partition.DriveLetter):" -ForegroundColor Gray
        Write-Host "    Label: $($volume.FileSystemLabel)" -ForegroundColor Gray
        Write-Host "    Filesystem: $($volume.FileSystem)" -ForegroundColor Gray
        Write-Host "    Size: $([math]::Round($volume.Size / 1GB, 2)) GB" -ForegroundColor Gray
        Write-Host "    Free Space: $([math]::Round($volume.SizeRemaining / 1GB, 2)) GB" -ForegroundColor Gray
        Write-Host "    Status: $($volume.HealthStatus)" -ForegroundColor Gray
        Write-Host ""
    } else {
        Write-Host "  Partition $($partition.PartitionNumber): No volume information" -ForegroundColor Yellow
        Write-Host ""
    }
}

# Test write access
Write-Host "[3/3] Testing write access..." -ForegroundColor Yellow
Write-Host ""

$testResults = @()

foreach ($partition in $windowsPartitions) {
    if ($partition.DriveLetter) {
        $driveLetter = "$($partition.DriveLetter):"
        $volume = Get-Volume -Partition $partition
        $testFile = "$driveLetter\KENL-TEST-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"

        try {
            # Write test file
            "KENL Drive Test - ATOM-CFG-20251112-004" | Out-File -FilePath $testFile -Encoding UTF8

            # Read test file
            $content = Get-Content -Path $testFile -Raw

            # Delete test file
            Remove-Item -Path $testFile -Force

            Write-Host "  ✅ $($volume.FileSystemLabel) ($driveLetter): Read/Write OK" -ForegroundColor Green
            $testResults += @{
                Label = $volume.FileSystemLabel
                Drive = $driveLetter
                Status = "OK"
            }
        } catch {
            Write-Host "  ❌ $($volume.FileSystemLabel) ($driveLetter): Write test failed" -ForegroundColor Red
            Write-Host "     Error: $($_.Exception.Message)" -ForegroundColor Red
            $testResults += @{
                Label = $volume.FileSystemLabel
                Drive = $driveLetter
                Status = "FAILED"
            }
        }
    }
}

Write-Host ""

# Summary
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Verification Summary" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$allPassed = $true
foreach ($result in $testResults) {
    $status = if ($result.Status -eq "OK") { "✅" } else { "❌"; $allPassed = $false }
    Write-Host "  $status $($result.Label) ($($result.Drive))" -ForegroundColor $(if ($result.Status -eq "OK") { "Green" } else { "Red" })
}

Write-Host ""

if ($allPassed) {
    Write-Host "✅ All Windows-accessible partitions are working correctly" -ForegroundColor Green
    Write-Host ""
    Write-Host "Expected Partitions (from documentation):" -ForegroundColor Yellow
    Write-Host "  1. Games-Universal (NTFS, 900GB) - Should be visible" -ForegroundColor Gray
    Write-Host "  2. Claude-AI-Data (ext4, 500GB) - NOT visible (Linux only)" -ForegroundColor Gray
    Write-Host "  3. Development (ext4, 200GB) - NOT visible (Linux only)" -ForegroundColor Gray
    Write-Host "  4. Windows-Only (NTFS, 150GB) - Should be visible" -ForegroundColor Gray
    Write-Host "  5. Transfer (exFAT, 50GB) - Should be visible" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. ext4 partitions will be accessible after Bazzite installation" -ForegroundColor White
    Write-Host "  2. Install Bazzite to internal drive (not this 1.8TB drive!)" -ForegroundColor White
    Write-Host "  3. After Bazzite install, configure auto-mount using UUIDs" -ForegroundColor White
    Write-Host "  4. Run: ~/kenl/scripts/bootstrap.sh" -ForegroundColor White
} else {
    Write-Host "⚠️  Some partitions failed verification" -ForegroundColor Yellow
    Write-Host "   Check Disk Management for partition status" -ForegroundColor Yellow
}

Write-Host ""

# Create verification report
$reportPath = "$env:USERPROFILE\Desktop\DRIVE-VERIFICATION-$(Get-Date -Format 'yyyyMMdd-HHmmss').md"
@"
# Drive Verification Report
**ATOM-CFG-20251112-004**
**Timestamp**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
**Phase**: Step 3 (Windows Mount Verification)

## Disk 1 Status
- **Total Partitions**: $($disk.NumberOfPartitions)
- **Windows-Accessible**: $($windowsPartitions.Count)
- **Overall Status**: $(if ($allPassed) { "✅ PASSED" } else { "⚠️ ISSUES DETECTED" })

## Partition Details
``````
$(Get-Partition -DiskNumber 1 | Format-Table -AutoSize | Out-String)
``````

## Volume Details
``````
$(foreach ($p in $windowsPartitions) { Get-Volume -Partition $p -ErrorAction SilentlyContinue | Format-Table -AutoSize | Out-String })
``````

## Write Test Results
$(foreach ($r in $testResults) { "- [$($r.Status)] $($r.Label) ($($r.Drive))`n" })

## Next Steps
1. ✅ Windows partitions verified working
2. ⏭️  Proceed with Bazzite installation
3. ⏭️  Configure auto-mount after Bazzite install
4. ⏭️  Run KENL bootstrap script

## ATOM Trail
- Step 1: ATOM-CFG-20251112-002 (Windows wipe)
- Step 2: ATOM-CFG-20251112-003 (Linux partitioning)
- Step 3: ATOM-CFG-20251112-004 (Windows verification)
- Next: ATOM-CFG-20251112-005 (Bazzite installation)

---
Generated by KENL Drive Preparation System
"@ | Out-File -FilePath $reportPath -Encoding UTF8

Write-Host "📝 Verification report saved to:" -ForegroundColor Cyan
Write-Host "   $reportPath" -ForegroundColor White
Write-Host ""
