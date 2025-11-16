#Requires -Version 5.1
<#
.SYNOPSIS
    Tests if Logdy Central is running and accessible

.DESCRIPTION
    Verifies logdy process is running and web UI is accessible.
    Use for pre/post reboot verification.

.NOTES
    Author    : KENL Framework
    Version   : 1.0.0
    ATOM      : ATOM-MONITORING-20251116-001
#>

[CmdletBinding()]
param(
    [int]$Port = 8081
)

Write-Host "`n╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║    Logdy Central Verification            ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════╝`n" -ForegroundColor Cyan

$allPassed = $true

# Test 1: Process running
Write-Host "[1/4] Checking if logdy process is running..." -NoNewline
$process = Get-Process -Name "logdy" -ErrorAction SilentlyContinue

if ($process) {
    Write-Host " [OK]" -ForegroundColor Green
    Write-Host "      PID: $($process.Id), Memory: $([math]::Round($process.WorkingSet64/1MB, 2)) MB" -ForegroundColor Gray
} else {
    Write-Host " [FAILED]" -ForegroundColor Red
    Write-Host "      Logdy process not found" -ForegroundColor Red
    $allPassed = $false
}

# Test 2: Port listening
Write-Host "[2/4] Checking if port $Port is listening..." -NoNewline
$listening = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue

if ($listening) {
    Write-Host " [OK]" -ForegroundColor Green
} else {
    Write-Host " [FAILED]" -ForegroundColor Red
    $allPassed = $false
}

# Test 3: Web UI accessible
Write-Host "[3/4] Testing web UI accessibility..." -NoNewline
try {
    $response = Invoke-WebRequest -Uri "http://localhost:$Port" -TimeoutSec 3 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host " [OK]" -ForegroundColor Green
    } else {
        Write-Host " [FAILED] (HTTP $($response.StatusCode))" -ForegroundColor Red
        $allPassed = $false
    }
} catch {
    Write-Host " [FAILED]" -ForegroundColor Red
    Write-Host "      Error: $_" -ForegroundColor Red
    $allPassed = $false
}

# Test 4: ATOM trail file exists
Write-Host "[4/4] Checking ATOM trail file..." -NoNewline
$atomTrail = "$HOME/.kenl/.atom-trail"
if (Test-Path $atomTrail) {
    $lines = (Get-Content $atomTrail | Measure-Object).Count
    Write-Host " [OK]" -ForegroundColor Green
    Write-Host "      Path: $atomTrail" -ForegroundColor Gray
    Write-Host "      Lines: $lines" -ForegroundColor Gray
} else {
    Write-Host " [FAILED]" -ForegroundColor Red
    $allPassed = $false
}

# Summary
Write-Host ""
if ($allPassed) {
    Write-Host "╔═══════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║    All checks PASSED!                     ║" -ForegroundColor Green
    Write-Host "╚═══════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "Logdy Central is running correctly" -ForegroundColor Green
    Write-Host "Web UI: http://localhost:$Port" -ForegroundColor Cyan
    exit 0
} else {
    Write-Host "╔═══════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║    Some checks FAILED                     ║" -ForegroundColor Red
    Write-Host "╚═══════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    Write-Host "To start Logdy Central:" -ForegroundColor Yellow
    Write-Host "  .\Start-LogdyCentral.ps1" -ForegroundColor Gray
    exit 1
}
