#Requires -Version 5.1
<#
.SYNOPSIS
    Safely updates modules that are actually available in PSGallery

.DESCRIPTION
    Filters out Windows built-in modules and only attempts to update
    modules that are genuinely available in the PowerShell Gallery.

.PARAMETER WhatIf
    Preview what would be updated without making changes

.EXAMPLE
    .\Update-PSGalleryModules.ps1

.EXAMPLE
    .\Update-PSGalleryModules.ps1 -WhatIf

.NOTES
    Version: 1.0.0
    ATOM: ATOM-PWSH-20251125-001
#>

[CmdletBinding(SupportsShouldProcess)]
param()

Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         Safe PSGallery Module Updater                     ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# List of Windows built-in modules that should NOT be attempted to install from PSGallery
$builtInModules = @(
    'CimCmdlets',
    'Microsoft.PowerShell.Diagnostics',
    'Microsoft.PowerShell.Host',
    'Microsoft.PowerShell.Management',
    'Microsoft.PowerShell.Security',
    'Microsoft.PowerShell.Utility',
    'Microsoft.WSMan.Management',
    'PSDiagnostics',
    'AppBackgroundTask',
    'Appx',
    'AssignedAccess',
    'BitLocker',
    'BitsTransfer',
    'BranchCache',
    'ConfigDefenderPerformance',
    'DefenderPerformance',
    'DeliveryOptimization',
    'DirectAccessClientComponents',
    'Dism',
    'DnsClient',
    'EventTracingManagement',
    'HgsClient',
    'HgsDiagnostics',
    'Hyper-V',
    'International',
    'Kds',
    'LanguagePackManagement',
    'LAPS',
    'Microsoft.PowerShell.LocalAccounts',
    'Microsoft.Windows.Bcd.Cmdlets',
    'MMAgent',
    'NetAdapter',
    'NetConnection',
    'NetEventPacketCapture',
    'NetLbfo',
    'NetNat',
    'NetQos',
    'NetSecurity',
    'NetSwitchTeam',
    'NetTCPIP',
    'NetworkConnectivityStatus',
    'NetworkSwitchManager',
    'NetworkTransition',
    'OsConfiguration',
    'PcsvDevice',
    'PKI',
    'PnpDevice',
    'PrintManagement',
    'Provisioning',
    'ScheduledTasks',
    'SecureBoot',
    'SmbShare',
    'SmbWitness',
    'StartLayout',
    'Storage',
    'TroubleshootingPack',
    'TrustedPlatformModule',
    'UEV',
    'VpnClient',
    'Wdac',
    'Whea',
    'WindowsDeveloperLicense',
    'WindowsErrorReporting',
    'WindowsSearch',
    'WindowsUpdate'
)

# Get all installed modules
Write-Host "Scanning installed modules..." -ForegroundColor Cyan
$allModules = Get-Module -ListAvailable |
    Group-Object Name |
    ForEach-Object { $_.Group | Sort-Object Version -Descending | Select-Object -First 1 }

$totalModules = $allModules.Count
Write-Host "Found $totalModules installed modules`n" -ForegroundColor Gray

# Filter out built-in modules
$candidateModules = $allModules | Where-Object {
    $_.Name -notin $builtInModules
}

Write-Host "Filtering out $($builtInModules.Count) Windows built-in modules..." -ForegroundColor Yellow
Write-Host "Checking $($candidateModules.Count) candidate modules for updates...`n" -ForegroundColor Cyan

# Check each candidate module in PSGallery
$updateableModules = @()
$skippedModules = @()

foreach ($module in $candidateModules) {
    Write-Host "  Checking $($module.Name)..." -NoNewline

    try {
        $galleryModule = Find-Module -Name $module.Name -ErrorAction Stop

        if ($galleryModule.Version -gt $module.Version) {
            Write-Host " UPDATE AVAILABLE ($($module.Version) → $($galleryModule.Version))" -ForegroundColor Green
            $updateableModules += [PSCustomObject]@{
                Name = $module.Name
                CurrentVersion = $module.Version
                AvailableVersion = $galleryModule.Version
                Module = $galleryModule
            }
        }
        else {
            Write-Host " Up to date ($($module.Version))" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host " Not in PSGallery" -ForegroundColor DarkGray
        $skippedModules += $module.Name
    }
}

Write-Host ""

# Summary
if ($updateableModules.Count -eq 0) {
    Write-Host "✓ All PSGallery modules are up to date!" -ForegroundColor Green
    exit 0
}

Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "║  Updates Available: $($updateableModules.Count) module(s)                         ║" -ForegroundColor Yellow
Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Yellow

$updateableModules | Format-Table -AutoSize Name, CurrentVersion, AvailableVersion

# Confirmation
if (-not $WhatIfPreference) {
    $response = Read-Host "`nUpdate these modules? (Y/N)"
    if ($response -notlike "y*") {
        Write-Host "Update cancelled.`n" -ForegroundColor Yellow
        exit 0
    }
}

# Perform updates
Write-Host "`nUpdating modules...`n" -ForegroundColor Cyan
$updated = @()
$failed = @()

foreach ($item in $updateableModules) {
    Write-Host "Updating $($item.Name)..." -ForegroundColor Yellow

    if ($PSCmdlet.ShouldProcess($item.Name, "Update to version $($item.AvailableVersion)")) {
        try {
            # Special handling for specific modules
            $installParams = @{
                Name = $item.Name
                Force = $true
                Scope = 'CurrentUser'
                ErrorAction = 'Stop'
            }

            # Add AllowClobber for known conflicting modules
            if ($item.Name -in @('Microsoft.PowerShell.ThreadJob', 'PowerShellGet')) {
                $installParams.AllowClobber = $true
            }

            Install-Module @installParams
            Write-Host "  [✓] Updated successfully" -ForegroundColor Green
            $updated += $item.Name
        }
        catch {
            Write-Warning "  [✗] Failed: $_"
            $failed += $item.Name
        }
    }
}

# Final summary
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  Update Complete                                           ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Green

if ($updated.Count -gt 0) {
    Write-Host "Updated modules: " -NoNewline
    Write-Host ($updated -join ", ") -ForegroundColor Green
}

if ($failed.Count -gt 0) {
    Write-Host "`nFailed modules: " -NoNewline
    Write-Host ($failed -join ", ") -ForegroundColor Red
}

Write-Host ""
