#Requires -Version 5.1
<#
.SYNOPSIS
    Extracts ATOM tags from git commit history and syncs to ATOM trail

.DESCRIPTION
    Parses git log for ATOM-* tags in commit messages and adds them
    to the ATOM trail with proper timestamps and context markers.

    This demonstrates SAIF framework traceability - every code change
    is part of the audit trail.

.PARAMETER Since
    Only parse commits since this date (default: 7 days ago)

.PARAMETER RepoPath
    Path to git repository (default: ~/kenl)

.NOTES
    Author    : KENL Framework
    Version   : 1.0.0
    ATOM      : ATOM-SAIF-20251117-001
#>

[CmdletBinding()]
param(
    [DateTime]$Since = (Get-Date).AddDays(-7),
    [string]$RepoPath = "~/kenl"
)

$repoExpanded = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($RepoPath)
$atomTrail = "$HOME/.kenl/.atom-trail-git-history"

Write-Host "`n╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  SAIF Git History → ATOM Trail Sync      ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════╝`n" -ForegroundColor Cyan

if (-not (Test-Path "$repoExpanded/.git")) {
    Write-Error "Not a git repository: $repoExpanded"
    exit 1
}

Push-Location $repoExpanded

# Get git log with ATOM tags
$sinceStr = $Since.ToString("yyyy-MM-dd")
$gitLog = git log --since="$sinceStr" --pretty=format:"%H|%ai|%s|%b" --all

if (-not $gitLog) {
    Write-Host "[OK] No commits since $sinceStr" -ForegroundColor Yellow
    Pop-Location
    exit 0
}

$atomEntries = @()
$commitCount = 0

foreach ($line in $gitLog) {
    if (-not $line) { continue }

    $parts = $line -split '\|', 4
    if ($parts.Count -lt 3) { continue }

    $hash = $parts[0]
    $date = $parts[1]
    $subject = $parts[2]
    $body = if ($parts.Count -gt 3) { $parts[3] } else { "" }

    # Extract ATOM tags from subject and body
    $fullMessage = "$subject $body"
    $atomMatches = [regex]::Matches($fullMessage, '(ATOM-[A-Z]+-\d{8}-\d{3})')

    foreach ($match in $atomMatches) {
        $atomTag = $match.Value

        # Parse commit timestamp
        $timestamp = [DateTime]::Parse($date).ToString('yyyy-MM-ddTHH:mm:ss')

        # Create entry with git context
        $message = "Git commit: $subject ($($hash.Substring(0,7))) [Git]"
        $entry = "$timestamp | $atomTag | $message"

        $atomEntries += $entry
        $commitCount++
    }
}

if ($atomEntries.Count -eq 0) {
    Write-Host "[OK] No ATOM tags found in commits since $sinceStr" -ForegroundColor Yellow
    Pop-Location
    exit 0
}

# Write to git history trail
$atomEntries | Set-Content -Path $atomTrail -Encoding UTF8

Write-Host "[OK] Extracted $($atomEntries.Count) ATOM entries from $commitCount commits" -ForegroundColor Green
Write-Host "    Saved to: $atomTrail" -ForegroundColor Gray
Write-Host "`n    Next: Configure logdy to tail this file for full git history visibility" -ForegroundColor Cyan

Pop-Location
