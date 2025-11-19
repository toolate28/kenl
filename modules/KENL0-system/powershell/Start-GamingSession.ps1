#Requires -Version 5.1

<#
.SYNOPSIS
    Start a monitored gaming session with network and performance tracking

.DESCRIPTION
    Comprehensive gaming session wrapper that:
    - Optimizes network routing
    - Tests latency baselines
    - Starts background monitoring (network, firewall, performance)
    - Logs session metrics for ATOM trail
    - Suggests post-session analysis

.PARAMETER Game
    Game name (e.g., "Battlefield6", "Steam", "EA")

.PARAMETER SkipOptimization
    Skip network optimization (if already done)

.PARAMETER MonitorInterval
    Monitoring interval in seconds (default: 30)

.EXAMPLE
    .\Start-GamingSession.ps1 -Game "Battlefield6"
    .\Start-GamingSession.ps1 -Game "Steam" -SkipOptimization

.NOTES
    Author: KENL Framework
    Version: 1.0.0
    ATOM: ATOM-GAMING-20251119-001

    Next steps after running this:
    - Launch your game
    - When done: .\Stop-GamingSession.ps1 to analyze metrics
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Game = "Generic",

    [Parameter(Mandatory=$false)]
    [switch]$SkipOptimization,

    [Parameter(Mandatory=$false)]
    [int]$MonitorInterval = 30
)

$ErrorActionPreference = "Continue"

#region Header
Write-Host "`n╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         KENL Gaming Session Monitor                      ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

Write-Host "Game: $Game" -ForegroundColor Yellow
Write-Host "Monitor Interval: ${MonitorInterval}s" -ForegroundColor Gray
Write-Host ""
#endregion

#region Session Setup
$sessionId = Get-Date -Format "yyyyMMdd-HHmmss"
$sessionPath = "$env:USERPROFILE\.kenl\sessions\$Game-$sessionId"

# Create session directory
New-Item -Path $sessionPath -ItemType Directory -Force | Out-Null
Write-Host "[1/6] Session directory created: $sessionPath" -ForegroundColor Green

# Log session start
$sessionLog = @{
    SessionId = $sessionId
    Game = $Game
    StartTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Platform = "Windows"
    Optimizations = @()
}
#endregion

#region Network Optimization
if (-not $SkipOptimization) {
    Write-Host "`n[2/6] Optimizing network routing..." -ForegroundColor Yellow

    # Check if Tailscale is running (should be stopped for gaming)
    $tailscale = Get-Service -Name "Tailscale" -ErrorAction SilentlyContinue
    if ($tailscale -and $tailscale.Status -eq "Running") {
        Write-Host "  [!] Tailscale is running - this adds ~170ms latency!" -ForegroundColor Red
        Write-Host "  Recommended: Stop-Service 'Tailscale'" -ForegroundColor Yellow
        $sessionLog.Optimizations += "WARNING: Tailscale running"
    } else {
        Write-Host "  [OK] Tailscale stopped" -ForegroundColor Green
        $sessionLog.Optimizations += "Tailscale: Stopped"
    }

    # Check routing priority
    $primaryInterface = Get-NetIPInterface -AddressFamily IPv4 |
        Where-Object { $_.InterfaceAlias -like "Ethernet*" -and $_.ConnectionState -eq "Connected" } |
        Sort-Object -Property InterfaceMetric |
        Select-Object -First 1

    if ($primaryInterface.InterfaceAlias -eq "Ethernet 3") {
        Write-Host "  [OK] Ethernet 3 (PCIe) is primary interface" -ForegroundColor Green
        $sessionLog.Optimizations += "Primary: Ethernet 3 (Metric: $($primaryInterface.InterfaceMetric))"
    } else {
        Write-Host "  [!] Primary interface is $($primaryInterface.InterfaceAlias) - consider optimizing" -ForegroundColor Yellow
        Write-Host "  Recommended: .\modules\KENL0-system\powershell\Fix-RoutingPriority.ps1 -GamingOptimized" -ForegroundColor Yellow
        $sessionLog.Optimizations += "WARNING: Primary is $($primaryInterface.InterfaceAlias)"
    }
} else {
    Write-Host "`n[2/6] Skipping network optimization (as requested)" -ForegroundColor Gray
}
#endregion

#region Baseline Latency Test
Write-Host "`n[3/6] Testing baseline latency..." -ForegroundColor Yellow

Import-Module "$PSScriptRoot\KENL.Network.psm1" -Force -ErrorAction SilentlyContinue

if (Get-Command Test-KenlNetwork -ErrorAction SilentlyContinue) {
    $latencyResults = Test-KenlNetwork -IncludeGaming -ErrorAction SilentlyContinue

    if ($latencyResults) {
        $avgLatency = ($latencyResults.LatencyMs | Measure-Object -Average).Average
        Write-Host "  [OK] Average latency: $([math]::Round($avgLatency, 1))ms" -ForegroundColor Green

        $sessionLog.BaselineLatency = @{
            Average = [math]::Round($avgLatency, 1)
            Results = $latencyResults
        }

        # Save baseline
        $latencyResults | ConvertTo-Json -Depth 3 | Out-File "$sessionPath\baseline-latency.json"
    }
} else {
    Write-Host "  [!] KENL.Network module not loaded - skipping" -ForegroundColor Yellow
}
#endregion

#region Start Background Monitoring
Write-Host "`n[4/6] Starting background monitors..." -ForegroundColor Yellow

# Network connection monitoring (netstat equivalent)
$netstatScript = {
    param($sessionPath, $interval)

    while ($true) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $connections = Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue |
            Where-Object { $_.RemotePort -in @(80, 443, 3074, 25565, 27015) } |  # Common gaming ports
            Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State

        $logEntry = @{
            Timestamp = $timestamp
            ActiveConnections = $connections.Count
            Connections = $connections
        }

        $logEntry | ConvertTo-Json -Compress | Out-File "$sessionPath\network-connections.jsonl" -Append
        Start-Sleep -Seconds $interval
    }
}

# Start netstat monitor
$netstatJob = Start-Job -ScriptBlock $netstatScript -ArgumentList $sessionPath, $MonitorInterval
Write-Host "  [OK] Network connection monitor started (Job ID: $($netstatJob.Id))" -ForegroundColor Green

# Latency monitoring
$latencyScript = {
    param($sessionPath, $interval)

    while ($true) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

        # Quick ping to common gaming servers
        $targets = @("8.8.8.8", "1.1.1.1")
        $results = @()

        foreach ($target in $targets) {
            $ping = Test-Connection -ComputerName $target -Count 1 -ErrorAction SilentlyContinue
            if ($ping) {
                $latency = if ($ping.ResponseTime) { $ping.ResponseTime } elseif ($ping.Latency) { $ping.Latency } else { 0 }
                $results += @{ Target = $target; Latency = $latency }
            }
        }

        $logEntry = @{
            Timestamp = $timestamp
            Results = $results
            AverageLatency = if ($results.Count -gt 0) { ($results.Latency | Measure-Object -Average).Average } else { 0 }
        }

        $logEntry | ConvertTo-Json -Compress | Out-File "$sessionPath\latency-monitor.jsonl" -Append
        Start-Sleep -Seconds $interval
    }
}

$latencyJob = Start-Job -ScriptBlock $latencyScript -ArgumentList $sessionPath, $MonitorInterval
Write-Host "  [OK] Latency monitor started (Job ID: $($latencyJob.Id))" -ForegroundColor Green

# Save job IDs
$sessionLog.MonitoringJobs = @{
    NetworkConnections = $netstatJob.Id
    Latency = $latencyJob.Id
}

# Firewall rules check
Write-Host "  [OK] Checking firewall rules..." -ForegroundColor Green
$firewallRules = Get-NetFirewallRule | Where-Object {
    $_.Enabled -eq $true -and
    $_.Direction -eq "Inbound" -and
    ($_.DisplayName -like "*Steam*" -or $_.DisplayName -like "*EA*" -or $_.DisplayName -like "*Game*")
}

if ($firewallRules) {
    Write-Host "      Found $($firewallRules.Count) gaming-related firewall rules" -ForegroundColor Gray
    $sessionLog.FirewallRules = $firewallRules.Count
} else {
    Write-Host "      No gaming-specific firewall rules found" -ForegroundColor Yellow
}

#endregion

#region Save Session Metadata
Write-Host "`n[5/6] Saving session metadata..." -ForegroundColor Yellow
$sessionLog | ConvertTo-Json -Depth 5 | Out-File "$sessionPath\session-metadata.json"
Write-Host "  [OK] Metadata saved" -ForegroundColor Green

# Create stop script
$stopScript = @"
# Stop Gaming Session: $Game ($sessionId)
`$sessionPath = "$sessionPath"
`$jobs = @($($netstatJob.Id), $($latencyJob.Id))

Write-Host "Stopping monitoring jobs..." -ForegroundColor Yellow
`$jobs | ForEach-Object { Stop-Job -Id `$_ -ErrorAction SilentlyContinue }
`$jobs | ForEach-Object { Remove-Job -Id `$_ -Force -ErrorAction SilentlyContinue }

Write-Host "Session data saved to: `$sessionPath" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  View network connections: Get-Content `$sessionPath\network-connections.jsonl | ConvertFrom-Json" -ForegroundColor Gray
Write-Host "  View latency log: Get-Content `$sessionPath\latency-monitor.jsonl | ConvertFrom-Json" -ForegroundColor Gray
Write-Host "  Send to logdy: Get-Content `$sessionPath\latency-monitor.jsonl | logdy stdin" -ForegroundColor Gray
"@

$stopScript | Out-File "$sessionPath\Stop-Session.ps1"
#endregion

#region Final Instructions
Write-Host "`n[6/6] Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║              Gaming Session Active                        ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Host "Session ID: $sessionId" -ForegroundColor Cyan
Write-Host "Session Path: $sessionPath" -ForegroundColor Gray
Write-Host ""

Write-Host "Background Monitors Running:" -ForegroundColor Yellow
Write-Host "  ✓ Network connections (every ${MonitorInterval}s)" -ForegroundColor Green
Write-Host "  ✓ Latency monitoring (every ${MonitorInterval}s)" -ForegroundColor Green
Write-Host ""

Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "  1. Launch your game: $Game" -ForegroundColor White
Write-Host "  2. Play your session (monitors running in background)" -ForegroundColor White
Write-Host "  3. When done, run: " -NoNewline -ForegroundColor White
Write-Host "$sessionPath\Stop-Session.ps1" -ForegroundColor Yellow
Write-Host ""

Write-Host "Live Monitoring (optional):" -ForegroundColor Cyan
Write-Host "  Check firewall: Get-NetFirewallRule | Where-Object Enabled -eq `$true | Select-Object DisplayName, Direction, Action" -ForegroundColor Gray
Write-Host "  Watch connections: Get-NetTCPConnection -State Established | Where-Object RemotePort -in @(80,443,3074,27015)" -ForegroundColor Gray
Write-Host "  Monitor latency: while (`$true) { Test-Connection 8.8.8.8 -Count 1; Start-Sleep 5 }" -ForegroundColor Gray
Write-Host ""

Write-Host "Send logs to Logdy:" -ForegroundColor Cyan
Write-Host "  tail -f `"$sessionPath\latency-monitor.jsonl`" | logdy stdin" -ForegroundColor Gray
Write-Host "  Get-Content `"$sessionPath\network-connections.jsonl`" | logdy stdin" -ForegroundColor Gray
Write-Host ""

# Write ATOM trail entry
if (Get-Command Write-AtomTrail -ErrorAction SilentlyContinue) {
    Write-AtomTrail -Type "GAMING" -Action "Session started: $Game ($sessionId)" -Context @{ SessionPath = $sessionPath }
}

#endregion
