# Start Logdy Central
# Launches Logdy to monitor ATOM trail

param(
    [switch]$Background
)

$ErrorActionPreference = "Stop"

$kenlRoot = Join-Path $env:USERPROFILE ".kenl"
$logdyExe = Join-Path $kenlRoot "bin\logdy.exe"
$atomTrail = Join-Path $kenlRoot ".atom-trail"

# Check if Logdy is installed
if (-not (Test-Path $logdyExe)) {
    Write-Host "Error: Logdy not found at $logdyExe" -ForegroundColor Red
    Write-Host "Download from: https://github.com/logdyhq/logdy-core/releases" -ForegroundColor Yellow
    exit 1
}

# Check if ATOM trail exists
if (-not (Test-Path $atomTrail)) {
    Write-Host "Error: ATOM trail not found at $atomTrail" -ForegroundColor Red
    Write-Host "Run: Setup-LogdyInfrastructure.ps1" -ForegroundColor Yellow
    exit 1
}

# Check if already running
$running = Get-Process logdy -ErrorAction SilentlyContinue
if ($running) {
    Write-Host "Logdy Central is already running (PID: $($running.Id))" -ForegroundColor Yellow
    Write-Host "  Open: http://localhost:8081" -ForegroundColor Cyan
    exit 0
}

# Start Logdy
Write-Host "Starting Logdy Central..." -ForegroundColor Cyan
Write-Host "  Monitoring: $atomTrail" -ForegroundColor Gray
Write-Host "  Port: 8081" -ForegroundColor Gray

$startArgs = @{
    FilePath = $logdyExe
    ArgumentList = @(
        "serve"
        "--follow"
        "`"$atomTrail`""
        "--port"
        "8081"
        "--ui-pass"
        "kenl123"
    )
}

if ($Background) {
    $startArgs.Add("WindowStyle", "Hidden")
    $startArgs.Add("PassThru", $true)
    $process = Start-Process @startArgs
    Write-Host "`nLogdy Central started in background (PID: $($process.Id))" -ForegroundColor Green
} else {
    $startArgs.Add("NoNewWindow", $true)
    Start-Process @startArgs
    Write-Host "`nLogdy Central started!" -ForegroundColor Green
}

Write-Host "  Open: http://localhost:8081" -ForegroundColor Cyan
Write-Host "  Username: admin" -ForegroundColor White
Write-Host "  Password: kenl123" -ForegroundColor White
