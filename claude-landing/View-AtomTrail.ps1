# View ATOM Trail Entries
# Shows recent ATOM trail entries with optional filtering

param(
    [int]$Last = 10,
    [string]$Type,
    [string]$Context,
    [switch]$Count
)

$ErrorActionPreference = "Stop"

$kenlRoot = Join-Path $env:USERPROFILE ".kenl"
$atomTrail = Join-Path $kenlRoot ".atom-trail"

if (-not (Test-Path $atomTrail)) {
    Write-Host "Error: ATOM trail not found at $atomTrail" -ForegroundColor Red
    exit 1
}

$entries = Get-Content $atomTrail

# Apply filters
if ($Type) {
    $entries = $entries | Where-Object { $_ -match "ATOM-$Type-" }
}
if ($Context) {
    $entries = $entries | Where-Object { $_ -match "\[$Context\]" }
}

if ($Count) {
    Write-Host "Total ATOM entries: $($entries.Count)" -ForegroundColor Cyan

    # Count by type
    Write-Host "`nEntries by type:" -ForegroundColor Yellow
    $types = @("NETWORK", "CONFIG", "MONITORING", "STATUS", "FIX", "DEPLOY", "TEST", "SECURITY")
    foreach ($t in $types) {
        $count = ($entries | Where-Object { $_ -match "ATOM-$t-" }).Count
        if ($count -gt 0) {
            Write-Host "  $t : $count" -ForegroundColor White
        }
    }
} else {
    $recent = $entries | Select-Object -Last $Last
    Write-Host "`nRecent ATOM Entries (Last $Last):" -ForegroundColor Cyan
    Write-Host "=" * 100 -ForegroundColor Gray

    foreach ($entry in $recent) {
        # Parse entry
        $parts = $entry -split ' \| '
        if ($parts.Count -eq 5) {
            $timestamp = $parts[0]
            $atomTag = $parts[1]
            $context = $parts[2]
            $location = $parts[3]
            $message = $parts[4]

            # Color code by type
            $color = "White"
            if ($atomTag -match "NETWORK") { $color = "Cyan" }
            elseif ($atomTag -match "CONFIG") { $color = "Yellow" }
            elseif ($atomTag -match "MONITORING") { $color = "Green" }
            elseif ($atomTag -match "STATUS") { $color = "Blue" }
            elseif ($atomTag -match "FIX") { $color = "Red" }

            Write-Host "$timestamp " -ForegroundColor Gray -NoNewline
            Write-Host "$atomTag " -ForegroundColor $color -NoNewline
            Write-Host "$context $location" -ForegroundColor DarkGray -NoNewline
            Write-Host " $message" -ForegroundColor White
        } else {
            Write-Host $entry -ForegroundColor White
        }
    }

    Write-Host "=" * 100 -ForegroundColor Gray
}
