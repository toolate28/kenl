#Requires -Version 5.1
<#
.SYNOPSIS
    Starts Logdy Central server for KENL ATOM trail monitoring

.DESCRIPTION
    Starts logdy.exe to tail the ATOM trail and serve the web UI.
    Designed to run on Windows startup or manually.

.NOTES
    Author    : KENL Framework
    Version   : 1.0.0
    ATOM      : ATOM-MONITORING-20251116-001
#>

[CmdletBinding()]
param(
    [int]$Port = 8081,
    [string]$AtomTrailPath = "~/.kenl/.atom-trail",
    [switch]$Force
)

$logdyBinary = "$HOME/.local/bin/logdy.exe"
$logFile = "$HOME/kenl/logs/logdy.log"

# Check if logdy is already running
$existing = Get-Process -Name "logdy" -ErrorAction SilentlyContinue

if ($existing -and -not $Force) {
    Write-Host "[OK] Logdy is already running (PID: $($existing.Id))" -ForegroundColor Green
    Write-Host "    Web UI: http://localhost:$Port" -ForegroundColor Cyan
    exit 0
}

if ($existing -and $Force) {
    Write-Host "Stopping existing logdy process..." -ForegroundColor Yellow
    Stop-Process -Name "logdy" -Force
    Start-Sleep -Seconds 2
}

# Verify binary exists
if (-not (Test-Path $logdyBinary)) {
    Write-Error "Logdy binary not found at $logdyBinary"
    Write-Host "Install with: curl -L https://github.com/logdyhq/logdy-core/releases/latest/download/logdy_windows_amd64.exe -o ~/.local/bin/logdy.exe" -ForegroundColor Yellow
    exit 1
}

# Create directories if needed
$atomTrailExpanded = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($AtomTrailPath)
$atomTrailDir = Split-Path -Parent $atomTrailExpanded

if (-not (Test-Path $atomTrailDir)) {
    New-Item -Path $atomTrailDir -ItemType Directory -Force | Out-Null
    Write-Host "[OK] Created directory: $atomTrailDir" -ForegroundColor Green
}

if (-not (Test-Path $atomTrailExpanded)) {
    New-Item -Path $atomTrailExpanded -ItemType File -Force | Out-Null
    Write-Host "[OK] Created ATOM trail file" -ForegroundColor Green
}

# Create logs directory
$logDir = Split-Path -Parent $logFile
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

# Start logdy
Write-Host "Starting Logdy Central..." -ForegroundColor Cyan
Write-Host "  Port: $Port" -ForegroundColor Gray
Write-Host "  ATOM Trail: $atomTrailExpanded" -ForegroundColor Gray
Write-Host "  Log File: $logFile" -ForegroundColor Gray

$startArgs = @(
    "follow"
    $atomTrailExpanded
    "--port", $Port
    "--ui-ip", "0.0.0.0"
)

$processInfo = Start-Process -FilePath $logdyBinary `
    -ArgumentList $startArgs `
    -RedirectStandardOutput $logFile `
    -RedirectStandardError (Join-Path (Split-Path $logFile) "logdy-error.log") `
    -WindowStyle Hidden `
    -PassThru

Start-Sleep -Seconds 2

if ($processInfo.HasExited) {
    Write-Error "Logdy failed to start. Check log: $logFile"
    Get-Content $logFile -Tail 20
    exit 1
}

Write-Host "`n[OK] Logdy Central started successfully!" -ForegroundColor Green
Write-Host "    PID: $($processInfo.Id)" -ForegroundColor Gray
Write-Host "    Web UI: http://localhost:$Port" -ForegroundColor Cyan
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "  - Open http://localhost:$Port in your browser"
Write-Host "  - Add ATOM trail entries: echo 'ATOM-TEST-...' >> ~/.kenl/.atom-trail"
Write-Host "  - Verify with: Test-LogdyCentral"
Write-Host ""

# Log to ATOM trail
Add-Content -Path $atomTrailExpanded -Value "ATOM-MONITORING-$(Get-Date -Format 'yyyyMMdd')-001 Logdy Central started on port $Port (PID: $($processInfo.Id))"
