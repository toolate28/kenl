#Requires -Version 5.1
<#
.SYNOPSIS
    KENL PowerShell Module Installer

.DESCRIPTION
    Installs KENL PowerShell modules to user's PowerShell module path.
    Idempotent, with version checking and capture/confirmation patterns.

.PARAMETER Scope
    Installation scope: CurrentUser (default) or AllUsers

.PARAMETER Force
    Skip confirmation prompts and force reinstall

.PARAMETER WhatIf
    Show what would be installed without making changes

.EXAMPLE
    .\Install-KENL.ps1
    # Interactive install for current user

.EXAMPLE
    .\Install-KENL.ps1 -Scope AllUsers -Force
    # Force reinstall for all users (requires elevation)

.EXAMPLE
    .\Install-KENL.ps1 -WhatIf
    # Preview installation without making changes

.NOTES
    Version: 2.0.0
    ATOM: ATOM-CFG-20251112-001
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [ValidateSet("CurrentUser", "AllUsers")]
    [string]$Scope = "CurrentUser",

    [switch]$Force
)

Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         KENL PowerShell Installer v2.0 (Idempotent)       ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Helper function: Get module version from .psm1 file
function Get-ModuleVersion {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return "0.0.0" }

    $content = Get-Content $Path -Raw -ErrorAction SilentlyContinue
    if ($content -match '(?m)^\s*#\s*Version:\s*(\d+\.\d+\.\d+)') {
        return $Matches[1]
    }
    return "Unknown"
}

# Helper function: Write ATOM trail log
function Write-AtomLog {
    param([string]$Message, [string]$Type = "CFG")

    $logDir = Join-Path $env:USERPROFILE ".atom-logs"
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }

    $date = Get-Date -Format "yyyyMMdd"
    $logFile = Join-Path $logDir "atom-$date.log"
    $counter = (Get-Content $logFile -ErrorAction SilentlyContinue | Measure-Object -Line).Lines + 1
    $atomTag = "ATOM-$Type-$date-$('{0:D3}' -f $counter)"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    "$timestamp [$atomTag] $Message" | Tee-Object -FilePath $logFile -Append | Out-Null
    return $atomTag
}

# Determine install path
$installPath = if ($Scope -eq "CurrentUser") {
    Join-Path $HOME "Documents\PowerShell\Modules"
} else {
    "$env:ProgramFiles\PowerShell\Modules"
}

# Check elevation for AllUsers
if ($Scope -eq "AllUsers") {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Error "AllUsers scope requires elevated PowerShell (Run as Administrator)"
        exit 1
    }
}

# Check if path exists
if (-not (Test-Path $installPath)) {
    Write-Host "Creating module directory: $installPath" -ForegroundColor Yellow
    New-Item -Path $installPath -ItemType Directory -Force | Out-Null
}

Write-Host "Install location: " -NoNewline
Write-Host $installPath -ForegroundColor Green
Write-Host ""

# Modules to install
$modules = @(
    @{ Name = "KENL"; File = "KENL.psm1" },
    @{ Name = "KENL.Network"; File = "KENL.Network.psm1" }
)

$scriptPath = $PSScriptRoot

# Pre-flight checks: Capture current state
Write-Host "Scanning installed modules..." -ForegroundColor Cyan
$installSummary = @()
$needsInstall = $false

foreach ($module in $modules) {
    $moduleName = $module.Name
    $moduleFile = $module.File
    $sourcePath = Join-Path $scriptPath $moduleFile
    $targetPath = Join-Path $installPath $moduleName
    $targetFile = Join-Path $targetPath "$moduleName.psm1"

    if (-not (Test-Path $sourcePath)) {
        Write-Warning "Source module not found: $sourcePath"
        continue
    }

    $sourceVersion = Get-ModuleVersion -Path $sourcePath
    $installedVersion = Get-ModuleVersion -Path $targetFile
    $status = if (-not (Test-Path $targetFile)) {
        $needsInstall = $true
        "NEW"
    } elseif ($sourceVersion -ne $installedVersion) {
        $needsInstall = $true
        "UPDATE ($installedVersion → $sourceVersion)"
    } else {
        "OK ($installedVersion)"
    }

    $installSummary += [PSCustomObject]@{
        Module = $moduleName
        Status = $status
        Source = $sourceVersion
        Installed = $installedVersion
    }
}

# Display summary
Write-Host ""
$installSummary | Format-Table -AutoSize
Write-Host ""

# Check if installation needed
if (-not $needsInstall -and -not $Force) {
    Write-Host "✓ All modules are up to date. Use -Force to reinstall." -ForegroundColor Green
    $atomTag = Write-AtomLog "Install-KENL.ps1: All modules up-to-date, no action taken"
    Write-Host "ATOM: $atomTag" -ForegroundColor Gray
    exit 0
}

# Confirmation prompt (unless -Force or -WhatIf)
if (-not $Force -and -not $WhatIfPreference) {
    Write-Host "The following modules will be installed/updated:" -ForegroundColor Yellow
    $installSummary | Where-Object { $_.Status -notlike "OK*" } | Format-Table -AutoSize

    $response = Read-Host "`nContinue? (Y/N)"
    if ($response -notlike "y*") {
        Write-Host "`nInstallation cancelled by user." -ForegroundColor Yellow
        exit 0
    }
    Write-Host ""
}

# Perform installation
$installedModules = @()
$failedModules = @()

foreach ($module in $modules) {
    $moduleName = $module.Name
    $moduleFile = $module.File
    $sourcePath = Join-Path $scriptPath $moduleFile
    $targetPath = Join-Path $installPath $moduleName
    $targetFile = Join-Path $targetPath "$moduleName.psm1"

    if (-not (Test-Path $sourcePath)) {
        $failedModules += $moduleName
        continue
    }

    # Skip if already up-to-date (unless -Force)
    $sourceVersion = Get-ModuleVersion -Path $sourcePath
    $installedVersion = Get-ModuleVersion -Path $targetFile
    if ($sourceVersion -eq $installedVersion -and (Test-Path $targetFile) -and -not $Force) {
        continue
    }

    Write-Host "Installing module: " -NoNewline
    Write-Host $moduleName -ForegroundColor Cyan

    # Create module directory
    if (-not (Test-Path $targetPath)) {
        New-Item -Path $targetPath -ItemType Directory -Force | Out-Null
    }

    # Copy module file
    if ($PSCmdlet.ShouldProcess($targetFile, "Install module")) {
        try {
            Copy-Item -Path $sourcePath -Destination $targetFile -Force -ErrorAction Stop
            Write-Host "  [✓] Installed: $targetFile" -ForegroundColor Green
            $installedModules += $moduleName
        }
        catch {
            Write-Warning "  [✗] Failed to install $moduleName: $_"
            $failedModules += $moduleName
        }
    }
}

# Installation summary
Write-Host ""
if ($installedModules.Count -gt 0) {
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║           Installation Complete!                           ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Green

    Write-Host "Installed modules: " -NoNewline
    Write-Host ($installedModules -join ", ") -ForegroundColor Green

    # Write ATOM log
    $atomTag = Write-AtomLog "Install-KENL.ps1: Installed modules [$($installedModules -join ', ')] to $Scope scope"
    Write-Host "ATOM: $atomTag" -ForegroundColor Gray
}

if ($failedModules.Count -gt 0) {
    Write-Host ""
    Write-Warning "Failed to install: $($failedModules -join ', ')"
}

Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Import modules:" -ForegroundColor Yellow
Write-Host "   Import-Module KENL"
Write-Host "   Import-Module KENL.Network"
Write-Host ""
Write-Host "2. Initialize framework:" -ForegroundColor Yellow
Write-Host "   Initialize-Kenl"
Write-Host ""
Write-Host "3. Test network:" -ForegroundColor Yellow
Write-Host "   Test-KenlNetwork"
Write-Host ""
Write-Host "4. Optimize network:" -ForegroundColor Yellow
Write-Host "   Optimize-KenlNetwork -BandwidthMbps 100 -LatencyMs 40 -ApplyMTU"
Write-Host ""
Write-Host "5. View all commands:" -ForegroundColor Yellow
Write-Host "   Get-Command -Module KENL,KENL.Network"
Write-Host ""

# Check for PowerShell-Yaml
$yamlModule = Get-Module -ListAvailable -Name powershell-yaml -ErrorAction SilentlyContinue
if (-not $yamlModule) {
    Write-Host "Optional: Install PowerShell-Yaml for full YAML support" -ForegroundColor Yellow
    Write-Host "  Install-Module powershell-yaml -Scope CurrentUser" -ForegroundColor Gray
    Write-Host ""
}

# Verification test
Write-Host "Verifying installation..." -ForegroundColor Cyan
$testResults = @()
foreach ($moduleName in $installedModules) {
    try {
        Import-Module $moduleName -Force -ErrorAction Stop
        $testResults += "✓ $moduleName"
        Remove-Module $moduleName -ErrorAction SilentlyContinue
    }
    catch {
        $testResults += "✗ $moduleName (import failed)"
    }
}

if ($testResults.Count -gt 0) {
    Write-Host ""
    $testResults | ForEach-Object {
        if ($_ -like "✓*") {
            Write-Host $_ -ForegroundColor Green
        } else {
            Write-Host $_ -ForegroundColor Red
        }
    }
}
