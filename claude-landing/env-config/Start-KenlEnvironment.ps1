<#
.SYNOPSIS
    KENL Development Environment Startup Script
.DESCRIPTION
    Comprehensive startup script for the KENL development environment.
    Optimized for Battlemedic-type early phases and directory optimization.
    Starts all services, configures networking, and launches monitoring dashboards.
.NOTES
    Version: 1.0.0
    Platform: Windows 11
    Hardware: AMD Ryzen 5 5600H + Vega
#>

param(
    [switch]$FullDiagnostics,
    [switch]$SkipNetwork,
    [switch]$QuietMode
)

$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

# Color output helpers
function Write-Success { param($Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Info { param($Message) Write-Host "ℹ️  $Message" -ForegroundColor Cyan }
function Write-Warning { param($Message) Write-Host "⚠️  $Message" -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host "❌ $Message" -ForegroundColor Red }
function Write-Header { param($Message) Write-Host "`n=== $Message ===" -ForegroundColor Magenta }

# Main execution
Write-Header "KENL Development Environment Startup"
Write-Info "Platform: Windows 11 | CPU: AMD Ryzen 5 5600H | RAM: 16GB"
Write-Info "Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

# 1. Directory Verification
Write-Header "Phase 1: Directory Structure Verification"
$KenlRoot = "C:\Users\iamto\.kenl\claude-landing"

if (Test-Path $KenlRoot) {
    Write-Success "KENL root directory found: $KenlRoot"
    Set-Location $KenlRoot
} else {
    Write-Error "KENL root directory not found!"
    exit 1
}

# Verify critical directories
$CriticalDirs = @(
    "claude-bun-win11-hooks",
    "claudenpc-server-suite",
    "env-config",
    ".claude"
)

foreach ($dir in $CriticalDirs) {
    if (Test-Path $dir) {
        Write-Success "Directory verified: $dir"
    } else {
        Write-Warning "Directory missing: $dir"
    }
}

# 2. Load KENL PowerShell Modules
Write-Header "Phase 2: Loading KENL PowerShell Modules"

$KenlModulePath = ".\modules\KENL0-system\powershell\KENL.psm1"
$KenlNetworkPath = ".\modules\KENL0-system\powershell\KENL.Network.psm1"

if (Test-Path $KenlModulePath) {
    try {
        Import-Module $KenlModulePath -Force
        Write-Success "KENL.psm1 loaded successfully"
    } catch {
        Write-Warning "Failed to load KENL.psm1: $_"
    }
} else {
    Write-Warning "KENL.psm1 not found at $KenlModulePath"
}

if (Test-Path $KenlNetworkPath) {
    try {
        Import-Module $KenlNetworkPath -Force
        Write-Success "KENL.Network.psm1 loaded successfully"
    } catch {
        Write-Warning "Failed to load KENL.Network.psm1: $_"
    }
} else {
    Write-Warning "KENL.Network.psm1 not found"
}

# 3. Network Diagnostics (if not skipped)
if (-not $SkipNetwork) {
    Write-Header "Phase 3: Network Diagnostics"

    try {
        if (Get-Command Test-KenlNetwork -ErrorAction SilentlyContinue) {
            Write-Info "Running network diagnostics..."
            Test-KenlNetwork
        } else {
            Write-Warning "Test-KenlNetwork not available, running basic checks..."
            $ping = Test-Connection -ComputerName 8.8.8.8 -Count 2 -Quiet
            if ($ping) {
                Write-Success "Internet connectivity verified"
            } else {
                Write-Warning "Internet connectivity check failed"
            }
        }
    } catch {
        Write-Warning "Network diagnostics failed: $_"
    }
} else {
    Write-Info "Network diagnostics skipped (-SkipNetwork)"
}

# 4. Firewall Configuration
Write-Header "Phase 4: Firewall Configuration Check"

$RequiredPorts = @(
    @{Port=3456; Name="Claude Dashboard"; Protocol="TCP"},
    @{Port=8081; Name="Logdy Central"; Protocol="TCP"},
    @{Port=25565; Name="Minecraft Server"; Protocol="TCP"}
)

foreach ($portConfig in $RequiredPorts) {
    $existing = netstat -ano | Select-String ":$($portConfig.Port)" | Select-Object -First 1
    if ($existing) {
        Write-Success "$($portConfig.Name) port $($portConfig.Port) is active"
    } else {
        Write-Info "$($portConfig.Name) port $($portConfig.Port) is available"
    }
}

# 5. Start Claude Dashboard
Write-Header "Phase 5: Starting Claude Dashboard"

$DashboardPath = ".\claude-bun-win11-hooks\.claude\hooks"
if (Test-Path $DashboardPath) {
    Write-Info "Checking if Claude Dashboard is already running..."
    $dashboardRunning = netstat -ano | Select-String ":3456" | Select-Object -First 1

    if ($dashboardRunning) {
        Write-Success "Claude Dashboard already running at http://localhost:3456"
    } else {
        Write-Info "Starting Claude Dashboard..."
        try {
            $job = Start-Job -ScriptBlock {
                param($Path)
                Set-Location $Path
                & bun run viewer
            } -ArgumentList (Resolve-Path $DashboardPath).Path

            Start-Sleep -Seconds 2

            $check = netstat -ano | Select-String ":3456" | Select-Object -First 1
            if ($check) {
                Write-Success "Claude Dashboard started at http://localhost:3456"
                Write-Info "Job ID: $($job.Id)"
            } else {
                Write-Warning "Claude Dashboard may not have started successfully"
            }
        } catch {
            Write-Error "Failed to start Claude Dashboard: $_"
        }
    }
} else {
    Write-Warning "Claude Dashboard path not found: $DashboardPath"
}

# 6. Service Status Summary
Write-Header "Phase 6: Service Status Summary"

Write-Info "Active Network Connections:"
netstat -ano | Select-String "LISTENING" | Select-String "3456|8081|25565" | ForEach-Object {
    Write-Host "  $_" -ForegroundColor Gray
}

# 7. Git Repository Status
Write-Header "Phase 7: Git Repository Status"

if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Info "Current branch: $(git branch --show-current)"
    Write-Info "Recent commits:"
    git log --oneline -3 | ForEach-Object {
        Write-Host "  $_" -ForegroundColor Gray
    }

    $gitStatus = git status --short
    if ($gitStatus) {
        Write-Warning "Uncommitted changes detected:"
        $gitStatus | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
    } else {
        Write-Success "Working directory clean"
    }
} else {
    Write-Warning "Git not found in PATH"
}

# 8. Environment Variables
Write-Header "Phase 8: Environment Configuration"

Write-Info "PowerShell Version: $($PSVersionTable.PSVersion)"
Write-Info "OS: $($PSVersionTable.OS)"
Write-Info "Platform: $($PSVersionTable.Platform)"

if (Get-Command bun -ErrorAction SilentlyContinue) {
    $bunVersion = & bun --version
    Write-Success "Bun runtime: v$bunVersion"
} else {
    Write-Warning "Bun runtime not found in PATH"
}

# 9. Full Diagnostics (optional)
if ($FullDiagnostics) {
    Write-Header "Phase 9: Full System Diagnostics"

    Write-Info "System Information:"
    Get-ComputerInfo | Select-Object CsName, WindowsProductName, OsArchitecture, TotalPhysicalMemory | Format-List

    Write-Info "Disk Space:"
    Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -gt 0 } |
        Select-Object Name, @{N="Size(GB)";E={[math]::Round($_.Used/1GB + $_.Free/1GB,2)}},
                           @{N="Free(GB)";E={[math]::Round($_.Free/1GB,2)}} |
        Format-Table -AutoSize
}

# 10. Summary and Next Steps
Write-Header "Environment Startup Complete"

Write-Success "KENL Development Environment is ready!"
Write-Info "`nQuick Access URLs:"
Write-Host "  • Claude Dashboard: http://localhost:3456" -ForegroundColor Cyan
Write-Host "  • Logdy Central: http://localhost:8081 (if configured)" -ForegroundColor Cyan

Write-Info "`nAvailable Commands:"
Write-Host "  • Test-KenlNetwork - Run network diagnostics" -ForegroundColor Yellow
Write-Host "  • Get-KenlPlatform - Show platform information" -ForegroundColor Yellow
Write-Host "  • Optimize-KenlNetwork - Optimize network settings" -ForegroundColor Yellow

Write-Info "`nWorkspace: kenl-workspace.code-workspace"
Write-Info "Profiles: env-config/waveterm-profiles.json"
Write-Info "         env-config/windows-terminal-profiles.json"

if (-not $QuietMode) {
    Write-Host "`nPress any key to continue..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
