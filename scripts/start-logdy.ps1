#Requires -Version 5.1

<#
.SYNOPSIS
    Start Logdy log viewer with KENL configuration

.DESCRIPTION
    Starts logdy pointing to:
    - ATOM trail logs
    - Claude logs
    - KENL application logs
    - Windows System logs
    - Windows Application logs

.PARAMETER Port
    Port to listen on (default: 8080)

.EXAMPLE
    .\start-logdy.ps1
    .\start-logdy.ps1 -Port 8081

.NOTES
    Logdy Web UI: http://localhost:8080
    Config: ~/.config/logdy/config.yaml
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [int]$Port = 8080
)

$configPath = "$env:USERPROFILE\.config\logdy\config.yaml"

# Check if logdy is already running
$existing = Get-Process logdy -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "⚠️  Logdy already running (PID: $($existing.Id))" -ForegroundColor Yellow
    Write-Host "   Stop it first: Stop-Process -Id $($existing.Id)" -ForegroundColor Gray
    Write-Host "   Or access: http://localhost:$Port" -ForegroundColor Cyan
    exit 0
}

Write-Host "`n╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         Starting Logdy Log Viewer        ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Verify config exists
if (-not (Test-Path $configPath)) {
    Write-Error "Config not found: $configPath"
    exit 1
}

Write-Host "Config: $configPath" -ForegroundColor Gray
Write-Host "Port: $Port" -ForegroundColor Gray
Write-Host ""

# Start logdy in background
$process = Start-Process -FilePath "logdy" `
    -ArgumentList "serve --config `"$configPath`"" `
    -PassThru `
    -WindowStyle Hidden

Start-Sleep -Seconds 2

# Verify it started
if ($process.HasExited) {
    Write-Error "Logdy failed to start"
    exit 1
}

Write-Host "✅ Logdy started (PID: $($process.Id))" -ForegroundColor Green
Write-Host ""

Write-Host "═══════════════════════════════════════════" -ForegroundColor Green
Write-Host "LOGDY WEB UI" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "  🌐 Open in browser: http://localhost:$Port" -ForegroundColor Cyan
Write-Host ""

Write-Host "Log Sources:" -ForegroundColor Yellow
Write-Host "  • ATOM Trail:      ~/.kenl/atom_trail.log" -ForegroundColor Gray
Write-Host "  • Claude Logs:     ~/.kenl/claude-logs/" -ForegroundColor Gray
Write-Host "  • KENL App Logs:   ~/kenl/logs/" -ForegroundColor Gray
Write-Host "  • Windows System:  Event Log (System)" -ForegroundColor Gray
Write-Host "  • Windows App:     Event Log (Application)" -ForegroundColor Gray
Write-Host ""

Write-Host "Commands:" -ForegroundColor Yellow
Write-Host "  Stop logdy:        Stop-Process -Id $($process.Id)" -ForegroundColor Gray
Write-Host "  View ATOM logs:    Get-Content ~/.kenl/atom_trail.log -Wait" -ForegroundColor Gray
Write-Host "  Send to logdy:     echo 'test' | logdy stdin" -ForegroundColor Gray
Write-Host ""

Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "  1. Open http://localhost:$Port in your browser" -ForegroundColor White
Write-Host "  2. Verify ATOM logs are showing" -ForegroundColor White
Write-Host "  3. Filter by 'ATOM-' to see audit trail" -ForegroundColor White
Write-Host ""

# Save PID for cleanup
$process.Id | Out-File "$env:USERPROFILE\.kenl\logdy.pid"

return @{
    ProcessId = $process.Id
    Port = $Port
    URL = "http://localhost:$Port"
}
