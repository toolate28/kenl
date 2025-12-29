# Test Logdy Central Status
# Verifies all components are working

$ErrorActionPreference = "Continue"

Write-Host "`nLogdy Central Status Check" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Gray

# Check 1: Logdy process
Write-Host "`n1. Logdy Process:" -ForegroundColor Yellow
$process = Get-Process logdy -ErrorAction SilentlyContinue
if ($process) {
    Write-Host "  [OK] Running (PID: $($process.Id))" -ForegroundColor Green
    Write-Host "  CPU: $([math]::Round($process.CPU, 2))s" -ForegroundColor Gray
    Write-Host "  Memory: $([math]::Round($process.WorkingSet64 / 1MB, 2)) MB" -ForegroundColor Gray
} else {
    Write-Host "  [FAIL] Not running" -ForegroundColor Red
}

# Check 2: Port 8081
Write-Host "`n2. Port 8081:" -ForegroundColor Yellow
$port = netstat -ano | findstr ":8081"
if ($port) {
    Write-Host "  [OK] Listening" -ForegroundColor Green
    Write-Host "  $($port.Trim())" -ForegroundColor Gray
} else {
    Write-Host "  [FAIL] Not listening" -ForegroundColor Red
}

# Check 3: Web UI
Write-Host "`n3. Web UI:" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    Write-Host "  [OK] Accessible (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "  [FAIL] Not accessible" -ForegroundColor Red
}

# Check 4: ATOM trail file
Write-Host "`n4. ATOM Trail:" -ForegroundColor Yellow
$kenlRoot = Join-Path $env:USERPROFILE ".kenl"
$atomTrail = Join-Path $kenlRoot ".atom-trail"
if (Test-Path $atomTrail) {
    $entries = Get-Content $atomTrail
    Write-Host "  [OK] File exists" -ForegroundColor Green
    Write-Host "  Path: $atomTrail" -ForegroundColor Gray
    Write-Host "  Entries: $($entries.Count)" -ForegroundColor Gray
    Write-Host "  Size: $([math]::Round((Get-Item $atomTrail).Length / 1KB, 2)) KB" -ForegroundColor Gray
} else {
    Write-Host "  [FAIL] File not found" -ForegroundColor Red
}

# Check 5: Last 5 entries
if (Test-Path $atomTrail) {
    Write-Host "`n5. Recent ATOM Entries:" -ForegroundColor Yellow
    $entries = Get-Content $atomTrail
    $last5 = $entries | Select-Object -Last 5
    foreach ($entry in $last5) {
        Write-Host "  $entry" -ForegroundColor White
    }
}

Write-Host "`n" + "=" * 60 -ForegroundColor Gray
Write-Host "Status check complete.`n" -ForegroundColor Cyan
