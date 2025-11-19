#Requires -Version 5.1
<#
.SYNOPSIS
    KENL Dashboard Module - Real-time system monitoring dashboard

.DESCRIPTION
    Provides a comprehensive dashboard for monitoring system performance,
    network status, and gaming metrics in real-time.

.NOTES
    Author    : KENL Framework
    Version   : 1.0.0
    ATOM      : ATOM-DASHBOARD-20251110-001
#>

#region Dashboard Functions

function Show-KenlDashboard {
    <#
    .SYNOPSIS
        Displays the KENL real-time dashboard

    .DESCRIPTION
        Shows comprehensive system, network, and gaming status
        in a formatted dashboard view.

    .PARAMETER RefreshInterval
        Auto-refresh interval in seconds (0 = no refresh)

    .PARAMETER Compact
        Show compact view

    .EXAMPLE
        Show-KenlDashboard
        Show-KenlDashboard -RefreshInterval 5
    #>
    [CmdletBinding()]
    param(
        [int]$RefreshInterval = 0,

        [switch]$Compact
    )

    do {
        Clear-Host

        # Header
        Write-Host "╔══════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "║                           KENL SYSTEM DASHBOARD                           ║" -ForegroundColor Cyan
        Write-Host "║                     Gaming & Development Infrastructure                     ║" -ForegroundColor Cyan
        Write-Host "╚══════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
        Write-Host ""

        # Timestamp
        Write-Host "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
        Write-Host ""

        # System Section
        Show-KenlDashboardSystem -Compact:$Compact

        # Network Section
        Show-KenlDashboardNetwork -Compact:$Compact

        # Gaming Section
        Show-KenlDashboardGaming -Compact:$Compact

        # Footer
        Write-Host ""
        Write-Host "Press Ctrl+C to exit" -ForegroundColor Gray
        if ($RefreshInterval -gt 0) {
            Write-Host "Auto-refresh: ${RefreshInterval}s" -ForegroundColor Gray
            Start-Sleep -Seconds $RefreshInterval
        } else {
            break
        }
    } while ($true)
}

function Show-KenlDashboardSystem {
    <#
    .SYNOPSIS
        Shows system status section
    #>
    [CmdletBinding()]
    param([switch]$Compact)

    Write-Host "┌─ System Status ──────────────────────────────────────────────────────────────┐" -ForegroundColor Yellow
    Write-Host "│" -NoNewline

    try {
        # Ensure KENL.System is loaded
        if (-not (Get-Module KENL.System -ErrorAction SilentlyContinue)) {
            Import-Module KENL.System -ErrorAction SilentlyContinue
        }

        $cpu = Get-KenlCPU
        $memory = Get-KenlMemory
        $uptime = Get-KenlSystemUptime

        if ($Compact) {
            Write-Host " CPU: $($cpu.LoadPercentage)% │ MEM: $([math]::Round(($memory.TotalGB - ($memory.TotalGB * 0.1)), 1))GB │ UPTIME: $($uptime.UptimeString)" -NoNewline
        } else {
            Write-Host ""
            Write-Host "│ CPU: $($cpu.Name)" -ForegroundColor White
            Write-Host "│     Load: $($cpu.LoadPercentage)% │ Cores: $($cpu.Cores) │ Threads: $($cpu.Threads)" -ForegroundColor White
            Write-Host "│" -NoNewline
            Write-Host ""
            Write-Host "│ Memory: $($memory.TotalGB)GB Total │ Slots: $($memory.SlotsUsed)/$($memory.SlotsTotal)" -ForegroundColor White
            Write-Host "│" -NoNewline
            Write-Host ""
            Write-Host "│ Uptime: $($uptime.UptimeString)" -ForegroundColor White
        }
    } catch {
        Write-Host " System info unavailable" -ForegroundColor Red
    }

    Write-Host " │" -ForegroundColor Yellow
    Write-Host "└─────────────────────────────────────────────────────────────────────────────┘" -ForegroundColor Yellow
    Write-Host ""
}

function Show-KenlDashboardNetwork {
    <#
    .SYNOPSIS
        Shows network status section
    #>
    [CmdletBinding()]
    param([switch]$Compact)

    Write-Host "┌─ Network Status ─────────────────────────────────────────────────────────────┐" -ForegroundColor Green
    Write-Host "│" -NoNewline

    try {
        # Ensure KENL.Network is loaded
        if (-not (Get-Module KENL.Network -ErrorAction SilentlyContinue)) {
            Import-Module KENL.Network -ErrorAction SilentlyContinue
        }

        $networkProfile = Get-KenlNetworkProfile
        $recentTest = Test-KenlNetwork -Quick 2>$null | Select-Object -Last 1

        if ($Compact) {
            $status = if ($recentTest -and $recentTest.Status -eq "EXCELLENT") { "EXCELLENT" } elseif ($recentTest.Status -eq "GOOD") { "GOOD" } else { "CHECK" }
            Write-Host " Status: $status │ MTU: $($networkProfile.MTU) │ Profile: $($networkProfile.Profile)" -NoNewline
        } else {
            Write-Host ""
            Write-Host "│ Status: " -NoNewline -ForegroundColor White
            if ($recentTest) {
                $color = switch ($recentTest.Status) {
                    "EXCELLENT" { "Green" }
                    "GOOD" { "Yellow" }
                    default { "Red" }
                }
                Write-Host "$($recentTest.Status)" -ForegroundColor $color
            } else {
                Write-Host "Not tested" -ForegroundColor Gray
            }
            Write-Host "│ MTU: $($networkProfile.MTU) │ TCP: $($networkProfile.TCP) │ Profile: $($networkProfile.Profile)" -ForegroundColor White
        }
    } catch {
        Write-Host " Network info unavailable" -ForegroundColor Red
    }

    Write-Host " │" -ForegroundColor Green
    Write-Host "└─────────────────────────────────────────────────────────────────────────────┘" -ForegroundColor Green
    Write-Host ""
}

function Show-KenlDashboardGaming {
    <#
    .SYNOPSIS
        Shows gaming status section
    #>
    [CmdletBinding()]
    param([switch]$Compact)

    Write-Host "┌─ Gaming Status ──────────────────────────────────────────────────────────────┐" -ForegroundColor Magenta
    Write-Host "│" -NoNewline

    try {
        # Ensure KENL.Gaming is loaded
        if (-not (Get-Module KENL.Gaming -ErrorAction SilentlyContinue)) {
            Import-Module KENL.Gaming -ErrorAction SilentlyContinue
        }

        $gamingStatus = Get-KenlGamingStatus
        $playCards = Get-KenlPlayCard 2>$null

        if ($Compact) {
            $cards = if ($playCards) { $playCards.Count } else { 0 }
            Write-Host " Play Cards: $cards │ Services: $($gamingStatus.services_disabled.Count) disabled │ Power: $($gamingStatus.power_plan)" -NoNewline
        } else {
            Write-Host ""
            Write-Host "│ Play Cards: " -NoNewline -ForegroundColor White
            if ($playCards) {
                Write-Host "$($playCards.Count) available" -ForegroundColor Green
            } else {
                Write-Host "None created" -ForegroundColor Gray
            }
            Write-Host "│ Optimized Services: $($gamingStatus.services_disabled.Count) disabled" -ForegroundColor White
            Write-Host "│ Power Plan: $($gamingStatus.power_plan)" -ForegroundColor White
            Write-Host "│ Network Priority: $($gamingStatus.network_optimized)" -ForegroundColor $(if ($gamingStatus.network_optimized) { "Green" } else { "Red" })
        }
    } catch {
        Write-Host " Gaming info unavailable" -ForegroundColor Red
    }

    Write-Host " │" -ForegroundColor Magenta
    Write-Host "└─────────────────────────────────────────────────────────────────────────────┘" -ForegroundColor Magenta
    Write-Host ""
}

function Start-KenlDashboard {
    <#
    .SYNOPSIS
        Starts the dashboard in a separate window

    .DESCRIPTION
        Launches the dashboard in a new PowerShell window for continuous monitoring.

    .EXAMPLE
        Start-KenlDashboard
    #>
    [CmdletBinding()]
    param()

    $script = {
        Import-Module KENL.Dashboard
        Show-KenlDashboard -RefreshInterval 5
    }

    Start-Process powershell -ArgumentList "-NoProfile -Command $script" -WindowStyle Normal
    Write-KenlMessage "Dashboard started in new window" -Type Success

    # Log to ATOM trail
    if (Get-Command Write-AtomTrail -ErrorAction SilentlyContinue) {
        Write-AtomTrail -Type DASHBOARD -Action "Started dashboard in separate window"
    }
}

#endregion

#region Performance Monitoring

function Get-KenlPerformanceMetrics {
    <#
    .SYNOPSIS
        Gets real-time performance metrics

    .EXAMPLE
        Get-KenlPerformanceMetrics
    #>
    [CmdletBinding()]
    param()

    [PSCustomObject]@{
        timestamp = Get-Date
        cpu = (Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 1 -MaxSamples 1).CounterSamples.CookedValue
        memory = (Get-Counter '\Memory\% Committed Bytes In Use' -SampleInterval 1 -MaxSamples 1).CounterSamples.CookedValue
        disk = Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } | ForEach-Object {
            @{
                drive = $_.DeviceID
                usage_percent = [math]::Round((1 - ($_.FreeSpace / $_.Size)) * 100, 1)
            }
        }
        network = Get-CimInstance Win32_PerfRawData_Tcpip_NetworkInterface | ForEach-Object {
            @{
                name = $_.Name
                bytes_sent = $_.BytesSentPerSec
                bytes_received = $_.BytesReceivedPerSec
            }
        }
    }
}

function Watch-KenlPerformance {
    <#
    .SYNOPSIS
        Watches performance metrics in real-time

    .PARAMETER Seconds
        Duration to watch

    .EXAMPLE
        Watch-KenlPerformance -Seconds 30
    #>
    [CmdletBinding()]
    param(
        [int]$Seconds = 10
    )

    Write-Host "Watching performance for $Seconds seconds..." -ForegroundColor Cyan
    Write-Host ""

    $endTime = (Get-Date).AddSeconds($Seconds)
    while ((Get-Date) -lt $endTime) {
        $metrics = Get-KenlPerformanceMetrics

        Write-Host "$(Get-Date -Format 'HH:mm:ss') │ " -NoNewline -ForegroundColor Gray
        Write-Host "CPU: $([math]::Round($metrics.cpu, 1))% │ " -NoNewline -ForegroundColor Yellow
        Write-Host "MEM: $([math]::Round($metrics.memory, 1))% │ " -NoNewline -ForegroundColor Green
        Write-Host "DISK: $($metrics.disk[0].usage_percent)% │ " -NoNewline -ForegroundColor Cyan
        Write-Host "NET: $([math]::Round($metrics.network[0].bytes_sent / 1KB, 1))KB/s ↑ $([math]::Round($metrics.network[0].bytes_received / 1KB, 1))KB/s ↓" -ForegroundColor Magenta

        Start-Sleep -Seconds 1
    }
}

#endregion

#region Export

Export-ModuleMember -Function @(
    'Show-KenlDashboard',
    'Start-KenlDashboard',
    'Get-KenlPerformanceMetrics',
    'Watch-KenlPerformance'
) -Alias @(
    'kdash',
    'kdash-start',
    'kperf',
    'kperf-watch'
)

#endregion

# Module initialization with banner
$banner = @"

╔══════════════════════════════════════════════════════════════╗
║                    KENL DASHBOARD LOADED                    ║
║              Real-time System Monitoring Active             ║
╚══════════════════════════════════════════════════════════════╝

Quick Commands:
  Show-KenlDashboard          # View full dashboard
  Start-KenlDashboard         # Launch in new window
  Watch-KenlPerformance       # Monitor performance

"@
Write-Host $banner -ForegroundColor Cyan

Write-Host "KENL.Dashboard module loaded" -ForegroundColor Cyan
Write-Host "Run 'Show-KenlDashboard' to start monitoring" -ForegroundColor Gray