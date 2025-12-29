# Write ATOM Trail Entry
# Adds properly formatted entry to ATOM trail

param(
    [Parameter(Mandatory)]
    [ValidateSet("NETWORK", "CONFIG", "MONITORING", "STATUS", "FIX", "DEPLOY", "TEST", "SECURITY")]
    [string]$Type,

    [Parameter(Mandatory)]
    [string]$Message,

    [ValidateSet("CLI", "IDE", "Web", "Desktop", "Git", "System")]
    [string]$Context = "CLI",

    [ValidateSet("Local", "Remote")]
    [string]$Location = "Local"
)

$ErrorActionPreference = "Stop"

$kenlRoot = Join-Path $env:USERPROFILE ".kenl"
$atomTrail = Join-Path $kenlRoot ".atom-trail"

# Ensure ATOM trail exists
if (-not (Test-Path $atomTrail)) {
    Write-Host "Error: ATOM trail not found at $atomTrail" -ForegroundColor Red
    Write-Host "Run: Setup-LogdyInfrastructure.ps1" -ForegroundColor Yellow
    exit 1
}

# Get next sequence number
$entries = Get-Content $atomTrail
$dateTag = Get-Date -Format "yyyyMMdd"
$todayEntries = $entries | Where-Object { $_ -match "ATOM-\w+-$dateTag-(\d+)" }
if ($todayEntries) {
    $lastId = ($todayEntries | ForEach-Object {
        if ($_ -match "ATOM-\w+-$dateTag-(\d+)") { [int]$matches[1] }
    } | Measure-Object -Maximum).Maximum
    $nextId = $lastId + 1
} else {
    $nextId = 1
}

# Create new entry
$timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
$atomTag = "ATOM-$Type-$dateTag-$($nextId.ToString('000'))"
$entry = "$timestamp | $atomTag | [$Context] | $Location | $Message"

# Append to trail
Add-Content -Path $atomTrail -Value $entry -Encoding UTF8

Write-Host "ATOM entry added:" -ForegroundColor Green
Write-Host "  $entry" -ForegroundColor White
