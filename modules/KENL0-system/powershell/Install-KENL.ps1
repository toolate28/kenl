#Requires -Version 5.1
<#
.SYNOPSIS
    KENL PowerShell Module Installer

.DESCRIPTION
    Installs KENL PowerShell modules to user's PowerShell module path.
    Simple, focused installer following PowerShell conventions.

.EXAMPLE
    .\Install-KENL.ps1
    .\Install-KENL.ps1 -Scope CurrentUser
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [ValidateSet("CurrentUser", "AllUsers")]
    [string]$Scope = "CurrentUser"
)

Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                KENL PowerShell Installer                   ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Determine install path
$installPath = if ($Scope -eq "CurrentUser") {
    Join-Path $HOME "Documents\PowerShell\Modules"
} else {
    "$env:ProgramFiles\PowerShell\Modules"
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

foreach ($module in $modules) {
    $moduleName = $module.Name
    $moduleFile = $module.File
    $sourcePath = Join-Path $scriptPath $moduleFile
    $targetPath = Join-Path $installPath $moduleName

    if (-not (Test-Path $sourcePath)) {
        Write-Warning "Module file not found: $sourceFile"
        continue
    }

    Write-Host "Installing module: " -NoNewline
    Write-Host $moduleName -ForegroundColor Cyan

    # Create module directory
    if (-not (Test-Path $targetPath)) {
        New-Item -Path $targetPath -ItemType Directory -Force | Out-Null
    }

    # Copy module file
    $targetFile = Join-Path $targetPath "$moduleName.psm1"

    if ($PSCmdlet.ShouldProcess($targetFile, "Copy module")) {
        Copy-Item -Path $sourcePath -Destination $targetFile -Force
        Write-Host "  [✓] Installed: $targetFile" -ForegroundColor Green
    }
}

# Installation complete
Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║           Installation Complete!                           ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Green

Write-Host "Next steps:" -ForegroundColor Cyan
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
