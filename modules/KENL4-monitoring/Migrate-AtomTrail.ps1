#Requires -Version 5.1
<#
.SYNOPSIS
    Migrates ATOM trail entries to timestamped pipe-delimited format

.DESCRIPTION
    Converts old format: ATOM-TYPE-YYYYMMDD-NNN Message
    To new format: TIMESTAMP | ATOM-TYPE-YYYYMMDD-NNN | Message

.NOTES
    Author    : KENL Framework
    Version   : 1.0.0
    ATOM      : ATOM-FIX-20251117-002
#>

[CmdletBinding()]
param(
    [string]$AtomTrailPath = "~/.kenl/.atom-trail"
)

$atomTrailExpanded = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($AtomTrailPath)

if (-not (Test-Path $atomTrailExpanded)) {
    Write-Error "ATOM trail file not found: $atomTrailExpanded"
    exit 1
}

# Backup original
$backupPath = "$atomTrailExpanded.backup"
Copy-Item -Path $atomTrailExpanded -Destination $backupPath -Force
Write-Host "[OK] Backed up to: $backupPath" -ForegroundColor Green

# Read entries
$entries = Get-Content $atomTrailExpanded -Encoding UTF8

# Migrate each entry
$migrated = @()
$baseTime = Get-Date '2025-11-17T06:00:00'

foreach ($entry in $entries) {
    # Check if already in new format
    if ($entry -match '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\s*\|') {
        Write-Verbose "Already migrated: $entry"
        $migrated += $entry
        continue
    }

    # Parse old format: ATOM-TYPE-YYYYMMDD-NNN Message
    if ($entry -match '^(ATOM-[A-Z]+-\d{8}-\d{3})\s+(.*)$') {
        $tag = $Matches[1]
        $message = $Matches[2]

        # Generate timestamp (incrementing for each entry)
        $timestamp = $baseTime.ToString('yyyy-MM-ddTHH:mm:ss')

        # New format
        $newEntry = "$timestamp | $tag | $message"
        $migrated += $newEntry

        Write-Verbose "Migrated: $entry -> $newEntry"

        # Increment time for next entry
        $baseTime = $baseTime.AddMinutes(1)
    } else {
        # Keep as-is if doesn't match expected format
        Write-Warning "Unrecognized format: $entry"
        $migrated += $entry
    }
}

# Write migrated entries
$migrated | Set-Content -Path $atomTrailExpanded -Encoding UTF8 -Force

Write-Host ""
Write-Host "╔═══════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║    Migration Complete!                    ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Total entries: $($entries.Count)" -ForegroundColor Cyan
Write-Host "Migrated to new format: $($migrated.Count)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Backup saved: $backupPath" -ForegroundColor Gray
Write-Host "ATOM trail: $atomTrailExpanded" -ForegroundColor Gray
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Restart logdy: .\Start-LogdyCentral.ps1 -Force" -ForegroundColor Gray
Write-Host "  2. Open UI: http://localhost:8081" -ForegroundColor Gray
Write-Host "  3. Verify columns are parsing correctly" -ForegroundColor Gray
