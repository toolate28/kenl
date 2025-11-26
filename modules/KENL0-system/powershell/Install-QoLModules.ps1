#Requires -Version 5.1
<#
.SYNOPSIS
    Install Quality of Life PowerShell modules and tools

.DESCRIPTION
    Installs essential admin, package management, and shell enhancement modules
    for improved PowerShell experience and system administration.

.PARAMETER Scope
    Installation scope: CurrentUser (default) or AllUsers

.EXAMPLE
    .\Install-QoLModules.ps1
    # Install for current user

.EXAMPLE
    .\Install-QoLModules.ps1 -Scope AllUsers
    # Install for all users (requires elevation)

.NOTES
    Version: 1.0.0
    ATOM: ATOM-CFG-20251126-003
#>

[CmdletBinding()]
param(
    [ValidateSet("CurrentUser", "AllUsers")]
    [string]$Scope = "CurrentUser"
)

Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║       PowerShell QoL Modules Installer v1.0               ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Check elevation for AllUsers
if ($Scope -eq "AllUsers") {
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Error "AllUsers scope requires elevated PowerShell (Run as Administrator)"
        exit 1
    }
}

# Ensure PSGallery is registered and trusted
Write-Host "Checking PSGallery repository..." -ForegroundColor Cyan
$psGallery = Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue

if (-not $psGallery) {
    Write-Host "  [!] PSGallery not found. Registering..." -ForegroundColor Yellow
    try {
        Register-PSRepository -Name PSGallery -SourceLocation 'https://www.powershellgallery.com/api/v2' -InstallationPolicy Trusted -ErrorAction Stop
        Write-Host "  [✓] PSGallery registered" -ForegroundColor Green
    }
    catch {
        Write-Warning "  [✗] Failed to register PSGallery: $_"
        Write-Host "`n  Try running manually:" -ForegroundColor Yellow
        Write-Host "  Register-PSRepository -Name PSGallery -SourceLocation 'https://www.powershellgallery.com/api/v2' -InstallationPolicy Trusted" -ForegroundColor Gray
    }
}

# Set PSGallery as trusted (to avoid prompts)
$psGallery = Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue
if ($psGallery -and $psGallery.InstallationPolicy -ne 'Trusted') {
    Write-Host "  [i] Setting PSGallery as trusted..." -ForegroundColor Cyan
    try {
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction Stop
        Write-Host "  [✓] PSGallery set as trusted" -ForegroundColor Green
    }
    catch {
        Write-Warning "  [!] Could not set PSGallery as trusted: $_"
    }
}

Write-Host ""

# Essential modules for admin and QoL
$modules = @(
    @{
        Name = "PSReadLine"
        Description = "Enhanced command-line editing with syntax highlighting"
        Essential = $true
    },
    @{
        Name = "posh-git"
        Description = "Git integration for PowerShell prompt"
        Essential = $true
    },
    @{
        Name = "Terminal-Icons"
        Description = "File and folder icons in terminal"
        Essential = $false
    },
    @{
        Name = "PSScriptAnalyzer"
        Description = "PowerShell script linter and best practices checker"
        Essential = $true
    },
    @{
        Name = "powershell-yaml"
        Description = "YAML support for PowerShell"
        Essential = $false
    },
    @{
        Name = "PowerShellGet"
        Description = "Package management for PowerShell modules"
        Essential = $true
    },
    @{
        Name = "Microsoft.PowerShell.SecretManagement"
        Description = "Secure credential storage"
        Essential = $false
    },
    @{
        Name = "Microsoft.PowerShell.SecretStore"
        Description = "Local secret vault for SecretManagement"
        Essential = $false
    }
)

Write-Host "Checking installed modules..." -ForegroundColor Cyan
Write-Host ""

$installSummary = @()
foreach ($module in $modules) {
    $moduleName = $module.Name
    $installed = Get-Module -ListAvailable -Name $moduleName -ErrorAction SilentlyContinue

    if ($installed) {
        $latestInstalled = $installed | Sort-Object Version -Descending | Select-Object -First 1
        $status = "Installed ($($latestInstalled.Version))"
        $color = "Green"
    } else {
        $status = "Not Installed"
        $color = "Yellow"
    }

    $installSummary += [PSCustomObject]@{
        Module = $moduleName
        Status = $status
        Priority = if ($module.Essential) { "Essential" } else { "Optional" }
        Description = $module.Description
    }
}

$installSummary | Format-Table -AutoSize Module, Status, Priority
Write-Host ""

# Install missing modules
$toInstall = $installSummary | Where-Object { $_.Status -eq "Not Installed" }

if ($toInstall.Count -eq 0) {
    Write-Host "✓ All modules already installed!" -ForegroundColor Green
    exit 0
}

Write-Host "The following modules will be installed:" -ForegroundColor Yellow
$toInstall | Format-Table -AutoSize Module, Priority, Description
Write-Host ""

$response = Read-Host "Continue? (Y/N)"
if ($response -notlike "y*") {
    Write-Host "`nInstallation cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host "`nInstalling modules..." -ForegroundColor Cyan
Write-Host ""

$installed = @()
$failed = @()

foreach ($item in $toInstall) {
    $moduleName = $item.Module
    Write-Host "Installing $moduleName..." -ForegroundColor Yellow

    try {
        Install-Module -Name $moduleName -Scope $Scope -Force -AllowClobber -SkipPublisherCheck -ErrorAction Stop
        Write-Host "  [✓] $moduleName installed successfully" -ForegroundColor Green
        $installed += $moduleName
    }
    catch {
        Write-Warning "  [✗] Failed to install $moduleName`: $_"
        $failed += $moduleName
    }
}

# Summary
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║           Installation Complete!                           ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Green

if ($installed.Count -gt 0) {
    Write-Host "Successfully installed: " -NoNewline
    Write-Host ($installed -join ", ") -ForegroundColor Green
}

if ($failed.Count -gt 0) {
    Write-Host "`nFailed to install: " -NoNewline
    Write-Host ($failed -join ", ") -ForegroundColor Red
}

Write-Host "`n" + "=" * 60 -ForegroundColor Gray
Write-Host "NEXT STEPS" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Gray

Write-Host "`n1. Enable PSReadLine enhanced editing:" -ForegroundColor Yellow
Write-Host "   Add to PowerShell profile (~\Documents\PowerShell\profile.ps1):"
Write-Host "   Set-PSReadLineOption -PredictionSource History"
Write-Host "   Set-PSReadLineOption -EditMode Windows"

Write-Host "`n2. Enable posh-git for Git integration:" -ForegroundColor Yellow
Write-Host "   Import-Module posh-git"

Write-Host "`n3. Enable Terminal-Icons:" -ForegroundColor Yellow
Write-Host "   Import-Module Terminal-Icons"

Write-Host "`n4. Configure secret management (optional):" -ForegroundColor Yellow
Write-Host "   Register-SecretVault -Name LocalStore -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault"

Write-Host "`nSample profile configuration:" -ForegroundColor Cyan
Write-Host @"

# PowerShell Profile - Add to ~\Documents\PowerShell\profile.ps1

# PSReadLine - Enhanced editing
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
}

# posh-git - Git integration
if (Get-Module -ListAvailable -Name posh-git) {
    Import-Module posh-git
}

# Terminal-Icons - Pretty file listings
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module Terminal-Icons
}

# KENL Modules
Import-Module KENL -ErrorAction SilentlyContinue
Import-Module KENL.Network -ErrorAction SilentlyContinue

# Aliases
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name which -Value Get-Command

"@ -ForegroundColor Gray

Write-Host ""
