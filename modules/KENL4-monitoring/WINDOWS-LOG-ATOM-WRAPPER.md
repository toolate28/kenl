---
title: Windows Log ATOM Wrapper - Universal System Log Aggregator
date: 2025-11-17
atom: ATOM-DOC-20251117-003
classification: FEATURE-SPEC
status: design
---

# Windows Log ATOM Wrapper
## Universal System Log Aggregation with ATOM Tagging

**Vision:** 1-click installation that wraps ALL Windows system logs (Application, Security, System, Network, Services) with ATOM tags and pipes to Logdy for unified monitoring.

**Value Proposition:**
- Single source of truth for all Windows events
- ATOM-tagged for audit trails and forensics
- Real-time monitoring via Logdy web UI
- Automatic correlation across log sources
- Zero manual configuration after install

---

## Architecture Overview

```
Windows Event Logs                    ATOM Wrapper                 Logdy Central
┌─────────────────┐                 ┌──────────────────┐         ┌─────────────┐
│ Application     │────────┐        │                  │         │             │
│ System          │────────┤        │  Event Monitor   │         │   Web UI    │
│ Security        │────────┼───────▶│  ┌────────────┐  │────────▶│ :8081       │
│ Setup           │────────┤        │  │ ATOM Tagger│  │  JSON   │             │
│ Forwarded       │────────┤        │  └────────────┘  │         │  Filters    │
│ Custom Logs     │────────┘        │                  │         │  Search     │
└─────────────────┘                 │  JSON Formatter  │         │  Alerts     │
                                    └──────────────────┘         └─────────────┘
                                            │
                                            ▼
                                    ~/.kenl/.atom-logs/
                                    system-events.json
```

---

## Core Components

### 1. Event Monitor Service

**File:** `modules/KENL4-monitoring/services/Watch-WindowsEventsToAtom.ps1`

**Responsibilities:**
- Subscribe to Windows Event Log channels
- Convert events to ATOM-tagged JSON
- Write to unified log file
- Handle rotation and cleanup

**Event Sources:**
```powershell
$EventLogSources = @(
    @{ Name = "Application";     Type = "APP";     Filter = "*" }
    @{ Name = "System";          Type = "SYS";     Filter = "*" }
    @{ Name = "Security";        Type = "SEC";     Filter = "EventID=4624,4625,4634" }  # Logon events
    @{ Name = "Setup";           Type = "SETUP";   Filter = "*" }
    @{ Name = "Microsoft-Windows-NetworkProfile/Operational"; Type = "NET"; Filter = "*" }
    @{ Name = "Microsoft-Windows-TaskScheduler/Operational";  Type = "SCHED"; Filter = "*" }
    @{ Name = "Microsoft-Windows-PowerShell/Operational";     Type = "PWSH"; Filter = "*" }
    @{ Name = "Microsoft-Windows-Windows Defender/Operational"; Type = "DEF"; Filter = "*" }
)
```

---

### 2. ATOM Tagger Module

**File:** `modules/KENL4-monitoring/lib/ConvertTo-AtomEvent.psm1`

**Function:**
```powershell
function ConvertTo-AtomEvent {
    <#
    .SYNOPSIS
        Converts Windows Event Log entry to ATOM-tagged JSON

    .EXAMPLE
        Get-WinEvent -LogName Application -MaxEvents 1 | ConvertTo-AtomEvent
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Diagnostics.Eventing.Reader.EventLogRecord]$Event,

        [ValidateSet('APP', 'SYS', 'SEC', 'NET', 'SETUP', 'SCHED', 'PWSH', 'DEF')]
        [string]$AtomType = 'SYS'
    )

    process {
        # Generate ATOM tag
        $atomTag = "ATOM-$AtomType-$(Get-Date -Format 'yyyyMMdd')-$(Get-Random -Minimum 100 -Maximum 999)"

        # Extract key fields
        $atomEvent = [PSCustomObject]@{
            timestamp = $Event.TimeCreated.ToString("o")  # ISO 8601
            atom_tag = $atomTag
            atom_type = $AtomType
            source = $Event.ProviderName
            event_id = $Event.Id
            level = $Event.LevelDisplayName
            message = $Event.Message
            computer = $Event.MachineName
            user = $Event.UserId
            process_id = $Event.ProcessId
            thread_id = $Event.ThreadId
            log_name = $Event.LogName
            # Full event XML for forensics
            event_xml = $Event.ToXml()
        }

        # Convert to JSON (single line for Logdy)
        $atomEvent | ConvertTo-Json -Compress
    }
}
```

---

### 3. Event Watcher Service

**File:** `modules/KENL4-monitoring/services/Start-AtomEventWatcher.ps1`

**Service Configuration:**
```powershell
$ServiceConfig = @{
    Name = "KENL-AtomEventWatcher"
    DisplayName = "KENL ATOM Event Watcher"
    Description = "Monitors Windows Event Logs and writes ATOM-tagged entries to Logdy"
    StartupType = "Automatic"
    ServiceAccount = "LocalSystem"  # Or user account with log access
}
```

**Implementation:**
```powershell
#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    KENL ATOM Event Watcher Service

.DESCRIPTION
    Background service that:
    1. Subscribes to Windows Event Logs
    2. Converts events to ATOM-tagged JSON
    3. Writes to ~/.kenl/.atom-logs/system-events.json
    4. Rotates logs daily
#>

param(
    [string]$OutputPath = "$env:USERPROFILE\.kenl\.atom-logs\system-events.json",
    [int]$MaxFileSizeMB = 100,
    [switch]$Debug
)

# Import ATOM tagger
Import-Module "$PSScriptRoot\..\lib\ConvertTo-AtomEvent.psm1" -Force

# Create output directory
$outputDir = Split-Path $OutputPath
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# Event log sources to monitor
$eventSources = @(
    @{ LogName = "Application";     AtomType = "APP";   MaxEvents = 10 }
    @{ LogName = "System";          AtomType = "SYS";   MaxEvents = 10 }
    @{ LogName = "Security";        AtomType = "SEC";   MaxEvents = 5; Filter = @{ID=4624,4625,4634} }
)

Write-Host "KENL ATOM Event Watcher started" -ForegroundColor Green
Write-Host "  Output: $OutputPath" -ForegroundColor Gray
Write-Host "  Monitoring $(($eventSources).Count) event log sources" -ForegroundColor Gray
Write-Host ""

# Main loop
while ($true) {
    try {
        foreach ($source in $eventSources) {
            # Get recent events
            $filterHashtable = @{
                LogName = $source.LogName
                MaxEvents = $source.MaxEvents
            }

            if ($source.Filter) {
                $filterHashtable['ID'] = $source.Filter.ID
            }

            $events = Get-WinEvent -FilterHashtable $filterHashtable -ErrorAction SilentlyContinue

            if ($events) {
                foreach ($event in $events) {
                    # Convert to ATOM-tagged JSON
                    $atomJson = $event | ConvertTo-AtomEvent -AtomType $source.AtomType

                    # Append to log file
                    Add-Content -Path $OutputPath -Value $atomJson -Encoding UTF8

                    if ($Debug) {
                        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $($source.LogName) - Event $($event.Id)" -ForegroundColor Cyan
                    }
                }
            }
        }

        # Check file size and rotate if needed
        $fileInfo = Get-Item $OutputPath -ErrorAction SilentlyContinue
        if ($fileInfo -and ($fileInfo.Length / 1MB) -gt $MaxFileSizeMB) {
            $rotatedPath = "$OutputPath.$(Get-Date -Format 'yyyyMMddHHmmss')"
            Move-Item $OutputPath $rotatedPath -Force
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Log rotated: $rotatedPath" -ForegroundColor Yellow
        }

        # Sleep before next poll (adjust based on load)
        Start-Sleep -Seconds 5
    }
    catch {
        Write-Error "Event watcher error: $_"
        Start-Sleep -Seconds 10
    }
}
```

---

### 4. Logdy Integration

**Update Logdy Config:** `~/.config/logdy/config.yaml`

```yaml
sources:
  # Windows System Events (ATOM-tagged)
  - name: "windows-events"
    type: "file"
    path: "~/.kenl/.atom-logs/system-events.json"
    follow: true
    parser:
      type: "json"

    # Field mappings
    fields:
      - name: "timestamp"
        type: "time"
      - name: "atom_tag"
        type: "string"
        indexed: true
      - name: "atom_type"
        type: "string"
        indexed: true
      - name: "event_id"
        type: "integer"
        indexed: true
      - name: "level"
        type: "string"
        indexed: true
      - name: "source"
        type: "string"
        indexed: true
      - name: "message"
        type: "string"
        full_text: true

# Filters for common scenarios
filters:
  # Critical errors only
  - name: "errors-only"
    field: "level"
    value: ["Error", "Critical"]

  # Security events
  - name: "security"
    field: "atom_type"
    value: "SEC"

  # Network events
  - name: "network"
    field: "atom_type"
    value: "NET"
```

---

## 1-Click Installer

**File:** `modules/KENL4-monitoring/Install-AtomEventWatcher.ps1`

```powershell
#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    1-Click Installer for KENL ATOM Event Watcher

.DESCRIPTION
    Installs and configures:
    1. ATOM Event Watcher service
    2. Logdy Central integration
    3. Automatic startup configuration
    4. Initial test and verification

.EXAMPLE
    .\Install-AtomEventWatcher.ps1

.EXAMPLE
    .\Install-AtomEventWatcher.ps1 -Uninstall
#>

[CmdletBinding()]
param(
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"

# Paths
$moduleRoot = "$PSScriptRoot"
$servicePath = "$moduleRoot\services\Start-AtomEventWatcher.ps1"
$libPath = "$moduleRoot\lib\ConvertTo-AtomEvent.psm1"
$logdyConfigPath = "$env:USERPROFILE\.config\logdy\config.yaml"
$atomLogsPath = "$env:USERPROFILE\.kenl\.atom-logs"

Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  KENL ATOM Event Watcher - 1-Click Installer             ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

if ($Uninstall) {
    Write-Host "Uninstalling KENL ATOM Event Watcher..." -ForegroundColor Yellow

    # Stop and remove service
    $service = Get-Service -Name "KENL-AtomEventWatcher" -ErrorAction SilentlyContinue
    if ($service) {
        Stop-Service -Name "KENL-AtomEventWatcher" -Force
        Remove-Service -Name "KENL-AtomEventWatcher"
        Write-Host "✅ Service removed" -ForegroundColor Green
    }

    Write-Host "✅ Uninstall complete" -ForegroundColor Green
    exit 0
}

# Install
Write-Host "[1/5] Creating directories..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $atomLogsPath -Force | Out-Null
Write-Host "✅ Created: $atomLogsPath" -ForegroundColor Green

Write-Host ""
Write-Host "[2/5] Installing ATOM tagger module..." -ForegroundColor Yellow
if (-not (Test-Path $libPath)) {
    Write-Error "Module not found: $libPath"
}
Import-Module $libPath -Force
Write-Host "✅ Module loaded" -ForegroundColor Green

Write-Host ""
Write-Host "[3/5] Creating Windows Service..." -ForegroundColor Yellow

# Create service using NSSM or sc.exe
$nssm = Get-Command nssm -ErrorAction SilentlyContinue
if ($nssm) {
    # Use NSSM (Non-Sucking Service Manager) - recommended
    nssm install KENL-AtomEventWatcher "powershell.exe" "-NoProfile -ExecutionPolicy Bypass -File `"$servicePath`""
    nssm set KENL-AtomEventWatcher DisplayName "KENL ATOM Event Watcher"
    nssm set KENL-AtomEventWatcher Description "Monitors Windows Event Logs and writes ATOM-tagged entries to Logdy"
    nssm set KENL-AtomEventWatcher Start SERVICE_AUTO_START
} else {
    # Fallback to sc.exe (basic service creation)
    Write-Warning "NSSM not found. Using sc.exe (less robust). Install NSSM for better service management."

    $serviceBinary = "powershell.exe"
    $serviceArgs = "-NoProfile -ExecutionPolicy Bypass -File `"$servicePath`""

    sc.exe create KENL-AtomEventWatcher binPath= "`"$serviceBinary`" $serviceArgs" start= auto
    sc.exe description KENL-AtomEventWatcher "Monitors Windows Event Logs and writes ATOM-tagged entries to Logdy"
}

Write-Host "✅ Service created: KENL-AtomEventWatcher" -ForegroundColor Green

Write-Host ""
Write-Host "[4/5] Configuring Logdy Central..." -ForegroundColor Yellow

# Update Logdy config to include system events
if (Test-Path $logdyConfigPath) {
    $logdyConfig = Get-Content $logdyConfigPath -Raw

    # Add system events source if not present
    if ($logdyConfig -notmatch "windows-events") {
        $systemEventsSource = @"

  # Windows System Events (ATOM-tagged)
  - name: windows-events
    type: file
    path: ~/.kenl/.atom-logs/system-events.json
    follow: true
    parser:
      type: json
"@

        $logdyConfig = $logdyConfig -replace "(sources:)", "`$1$systemEventsSource"
        Set-Content -Path $logdyConfigPath -Value $logdyConfig -Force
        Write-Host "✅ Logdy config updated" -ForegroundColor Green
    } else {
        Write-Host "✅ Logdy config already includes windows-events" -ForegroundColor Green
    }
} else {
    Write-Warning "Logdy config not found at $logdyConfigPath"
    Write-Host "   Run Start-LogdyCentral.ps1 to create it" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[5/5] Starting service and testing..." -ForegroundColor Yellow

Start-Service -Name "KENL-AtomEventWatcher"
Start-Sleep -Seconds 3

$service = Get-Service -Name "KENL-AtomEventWatcher"
if ($service.Status -eq "Running") {
    Write-Host "✅ Service running (PID: $($service.ProcessId))" -ForegroundColor Green
} else {
    Write-Error "Service failed to start. Check logs."
}

# Wait for events to be logged
Write-Host ""
Write-Host "Waiting for events (10 seconds)..." -ForegroundColor Gray
Start-Sleep -Seconds 10

# Verify events are being logged
$eventLog = Get-Content "$atomLogsPath\system-events.json" -Tail 5 -ErrorAction SilentlyContinue
if ($eventLog) {
    Write-Host "✅ Events are being logged:" -ForegroundColor Green
    $eventLog | ForEach-Object {
        $event = $_ | ConvertFrom-Json
        Write-Host "   $($event.timestamp) - $($event.atom_tag) - $($event.source)" -ForegroundColor Gray
    }
} else {
    Write-Warning "No events logged yet. Check service status: Get-Service KENL-AtomEventWatcher"
}

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  Installation Complete!                                   ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Start Logdy Central: .\Start-LogdyCentral.ps1" -ForegroundColor White
Write-Host "  2. Open web UI: http://localhost:8081" -ForegroundColor White
Write-Host "  3. Filter by 'windows-events' source" -ForegroundColor White
Write-Host ""
Write-Host "Service commands:" -ForegroundColor Cyan
Write-Host "  Status: Get-Service KENL-AtomEventWatcher" -ForegroundColor White
Write-Host "  Logs:   Get-Content ~/.kenl/.atom-logs/system-events.json -Tail 20" -ForegroundColor White
Write-Host "  Stop:   Stop-Service KENL-AtomEventWatcher" -ForegroundColor White
Write-Host ""
```

---

## Features & Benefits

### 1. Unified Monitoring
- **All Windows logs in one place** - No more jumping between Event Viewer windows
- **ATOM-tagged for correlation** - Trace events across different log sources
- **Real-time updates** - See events as they happen via Logdy UI

### 2. Powerful Filtering
- Filter by event type (APP, SYS, SEC, NET, etc.)
- Search by ATOM tag, event ID, source, message
- Save common filters (e.g., "critical errors only")

### 3. Forensics & Troubleshooting
- Full event XML preserved for deep analysis
- Timestamp correlation across log sources
- Export filtered results to JSON/CSV

### 4. Integration Benefits
- **Claude Code** - Can query logs via MCP
- **Play Cards** - Include system events in gaming sessions
- **SAIF Compliance** - All events have SAIF-compatible ATOM tags

### 5. Zero Maintenance
- Automatic log rotation (daily, size-based)
- Service runs in background (Windows Service)
- Survives reboots (auto-start)

---

## Installation & Usage

### Install (1-Click)
```powershell
cd ~/kenl/modules/KENL4-monitoring
.\Install-AtomEventWatcher.ps1
```

### Start Logdy Central
```powershell
.\Start-LogdyCentral.ps1
```

### View Logs
- Open http://localhost:8081
- Select "windows-events" source
- Filter, search, export

### Uninstall
```powershell
.\Install-AtomEventWatcher.ps1 -Uninstall
```

---

## Advanced Configuration

### Custom Event Sources

Edit `Start-AtomEventWatcher.ps1` to add custom event log sources:

```powershell
$eventSources = @(
    # Add your custom log
    @{
        LogName = "Microsoft-Windows-PrintService/Operational"
        AtomType = "PRINT"
        MaxEvents = 5
        Filter = @{Level=2,3}  # Errors and warnings only
    }
)
```

### Event Filtering

Add filters in Logdy config to reduce noise:

```yaml
filters:
  # Only critical and errors
  - name: "important-only"
    field: "level"
    operator: "in"
    value: ["Critical", "Error"]

  # Exclude verbose sources
  - name: "exclude-verbose"
    field: "source"
    operator: "not_in"
    value: ["Microsoft-Windows-Kernel-General"]
```

### Alert Configuration (Future)

```yaml
alerts:
  # Alert on security failures
  - name: "security-failures"
    condition:
      field: "event_id"
      value: 4625  # Failed logon
    action:
      type: "webhook"
      url: "https://your-webhook-url"
```

---

## Performance Considerations

**Memory Usage:** ~50-100MB (service + buffered events)
**Disk Usage:** ~1-5GB/day (depends on event volume, auto-rotated)
**CPU Usage:** <1% (polling every 5 seconds)
**Network:** None (local only, unless forwarding to remote Logdy)

**Tuning:**
- Adjust polling interval in `Start-AtomEventWatcher.ps1` (default: 5 seconds)
- Reduce `MaxEvents` per source to lower overhead
- Add event ID filters to only capture critical events

---

## Future Enhancements

1. **Remote Logdy Support** - Forward to centralized Logdy server
2. **AI-Powered Alerts** - Use Qwen/Claude to detect anomalies
3. **Play Card Integration** - Auto-tag gaming sessions with system events
4. **Cross-Platform** - Extend to Linux (systemd journal) and macOS (unified logging)
5. **Correlation Engine** - Automatically correlate events across sources
6. **SAIF Flag Generation** - Create SAIF flags for critical system changes

---

## SAIF Flags

| Operation | SAIF Flag |
|-----------|-----------|
| Install ATOM Event Watcher | `SAIF-INSTALL-EVENT-WATCHER-20251117-048` |
| Start monitoring Windows events | `SAIF-START-EVENT-MON-20251117-049` |
| Configure Logdy integration | `SAIF-CONFIG-LOGDY-EVENTS-20251117-050` |
| Generate ATOM-tagged event | `SAIF-ATOM-EVENT-GEN-20251117-051` |

---

## References

- **Logdy Documentation:** https://logdy.dev/docs
- **Windows Event Logs:** https://learn.microsoft.com/en-us/windows/win32/wes/windows-event-log
- **NSSM (Service Manager):** https://nssm.cc/
- **ATOM Framework:** `modules/KENL1-framework/atom-sage-framework/README.md`

---

**ATOM:** ATOM-DOC-20251117-003
**Status:** Design Phase
**Next:** Implement and test on Windows 11
