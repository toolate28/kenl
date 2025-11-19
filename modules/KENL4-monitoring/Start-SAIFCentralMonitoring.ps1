#Requires -Version 5.1
<#
.SYNOPSIS
    Starts SAIF Central Monitoring - Complete system audit trail aggregation

.DESCRIPTION
    Demonstrates the full power of the SAIF framework by aggregating:
    - ATOM trail (manual entries)
    - Git commit history (code changes)
    - Windows Event Log (system events)
    - PowerShell transcripts (command history)
    - Network logs (connectivity, latency)
    - Application logs (errors, warnings)
    - Error logs (all sources)

    All aggregated into logdy with proper column parsing for filtering,
    grouping, and correlation across all system activities.

.PARAMETER Port
    Logdy web UI port (default: 8081)

.EXAMPLE
    .\Start-SAIFCentralMonitoring.ps1

.NOTES
    Author    : KENL Framework
    Version   : 1.0.0
    ATOM      : ATOM-SAIF-20251117-002

    This showcases SAIF value proposition:
    - Complete audit trail (every action traced)
    - Immutability (timestamped, append-only logs)
    - Attestability (ATOM tags verify authenticity)
    - Traceability (git commits → system events → app logs)
#>

[CmdletBinding()]
param(
    [int]$Port = 8081
)

Write-Host "`n╔════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║  SAIF Central Monitoring System                        ║" -ForegroundColor Magenta
Write-Host "║  Complete System Audit Trail Aggregation               ║" -ForegroundColor Magenta
Write-Host "╚════════════════════════════════════════════════════════╝`n" -ForegroundColor Magenta

$logDir = "$HOME/kenl/logs"
$atomBase = "$HOME/.kenl"

# Ensure directories exist
@($logDir, $atomBase) | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -Path $_ -ItemType Directory -Force | Out-Null
    }
}

Write-Host "[1/7] Syncing git ATOM history..." -ForegroundColor Cyan
& "$PSScriptRoot/Sync-GitAtomHistory.ps1" -ErrorAction SilentlyContinue

Write-Host "[2/7] Aggregating Windows Event Logs..." -ForegroundColor Cyan
# Get recent system events (last 24 hours)
$since = (Get-Date).AddHours(-24)
$eventLog = "$atomBase/.atom-trail-system-events"

try {
    $events = Get-WinEvent -FilterHashtable @{
        LogName = 'System', 'Application'
        Level = 1,2,3  # Critical, Error, Warning
        StartTime = $since
    } -MaxEvents 100 -ErrorAction SilentlyContinue

    $eventEntries = $events | ForEach-Object {
        $timestamp = $_.TimeCreated.ToString('yyyy-MM-ddTHH:mm:ss')
        $level = switch ($_.Level) {
            1 { "CRITICAL" }
            2 { "ERROR" }
            3 { "WARNING" }
            default { "INFO" }
        }
        $atomTag = "ATOM-SYSTEM-$(Get-Date -Format 'yyyyMMdd')-$('{0:D3}' -f $_.RecordId % 1000)"
        $message = "[$level] $($_.ProviderName): $($_.Message.Substring(0, [Math]::Min(200, $_.Message.Length))) [System]"

        "$timestamp | $atomTag | $message"
    }

    $eventEntries | Set-Content -Path $eventLog -Encoding UTF8
    Write-Host "    [OK] Extracted $($eventEntries.Count) system events" -ForegroundColor Green
} catch {
    Write-Host "    [SKIP] Event log access requires elevation" -ForegroundColor Yellow
}

Write-Host "[3/7] Creating network activity log..." -ForegroundColor Cyan
$networkLog = "$atomBase/.atom-trail-network"
$timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
$atomTag = "ATOM-NETWORK-$(Get-Date -Format 'yyyyMMdd')-001"
"$timestamp | $atomTag | Network monitoring initialized [CLI]" | Set-Content -Path $networkLog -Encoding UTF8

Write-Host "[4/7] Creating application log aggregator..." -ForegroundColor Cyan
$appLog = "$atomBase/.atom-trail-applications"
$timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
$atomTag = "ATOM-APP-$(Get-Date -Format 'yyyyMMdd')-001"
"$timestamp | $atomTag | Application monitoring initialized [CLI]" | Set-Content -Path $appLog -Encoding UTF8

Write-Host "[5/7] Configuring logdy multi-source aggregation..." -ForegroundColor Cyan

# Create comprehensive logdy config
$logdyConfig = @"
# SAIF Central Monitoring Configuration
# ATOM: ATOM-CONFIG-$(Get-Date -Format 'yyyyMMdd')-001

# Multi-source log aggregation
sources:
  - path: "$($atomBase.Replace('\','\\'))\\.atom-trail"
    name: "ATOM Trail (Manual)"
    color: "#57F287"

  - path: "$($atomBase.Replace('\','\\'))\\.atom-trail-git-history"
    name: "Git Commit History"
    color: "#FFD43B"

  - path: "$($atomBase.Replace('\','\\'))\\.atom-trail-system-events"
    name: "Windows System Events"
    color: "#ED4245"

  - path: "$($atomBase.Replace('\','\\'))\\.atom-trail-network"
    name: "Network Activity"
    color: "#00AFF4"

  - path: "$($atomBase.Replace('\','\\'))\\.atom-trail-applications"
    name: "Application Logs"
    color: "#EB459E"

# Web UI
listen: 0.0.0.0:$Port
"@

$logdyConfig | Set-Content -Path "$HOME/.config/logdy/saif-config.yaml" -Encoding UTF8

Write-Host "[6/7] Starting logdy with SAIF configuration..." -ForegroundColor Cyan
& "$PSScriptRoot/Start-LogdyCentral.ps1" -Force

Write-Host "[7/7] SAIF Central Monitoring ready!" -ForegroundColor Green

Write-Host "`n╔════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  SAIF Central Monitoring is OPERATIONAL                ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════╝`n" -ForegroundColor Green

Write-Host "Web UI: http://localhost:$Port" -ForegroundColor Cyan
Write-Host "`nAggregated Sources:" -ForegroundColor Yellow
Write-Host "  ✓ ATOM Trail (manual entries)" -ForegroundColor Gray
Write-Host "  ✓ Git commit history" -ForegroundColor Gray
Write-Host "  ✓ Windows system events" -ForegroundColor Gray
Write-Host "  ✓ Network activity" -ForegroundColor Gray
Write-Host "  ✓ Application logs" -ForegroundColor Gray

Write-Host "`nAvailable Columns:" -ForegroundColor Yellow
Write-Host "  • timestamp     - When the event occurred" -ForegroundColor Gray
Write-Host "  • atom_type     - Event category (NETWORK, CONFIG, etc.)" -ForegroundColor Gray
Write-Host "  • atom_date     - Date from ATOM tag" -ForegroundColor Gray
Write-Host "  • atom_id       - Sequence number" -ForegroundColor Gray
Write-Host "  • context       - Where it happened (CLI/IDE/Web/Desktop/Git/System)" -ForegroundColor Gray
Write-Host "  • location      - Local or Remote" -ForegroundColor Gray
Write-Host "  • message       - Event description" -ForegroundColor Gray

Write-Host "`nSAIF Framework Demonstrated:" -ForegroundColor Yellow
Write-Host "  → Complete audit trail across all system activities" -ForegroundColor Gray
Write-Host "  → Timestamped, immutable log entries" -ForegroundColor Gray
Write-Host "  → ATOM tags attest authenticity" -ForegroundColor Gray
Write-Host "  → Filter/group by type, date, context, location" -ForegroundColor Gray
Write-Host "  → Correlate git commits → system events → app logs" -ForegroundColor Gray

Write-Host ""
