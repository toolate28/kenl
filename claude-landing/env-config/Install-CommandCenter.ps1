<#
.SYNOPSIS
    Install KENL Command Center into your PowerShell profile
.DESCRIPTION
    Adds the Command Center module to your profile for automatic loading.
    Safe - backs up your existing profile first.
#>

param(
    [switch]$Force
)

$profilePath = $PROFILE.CurrentUserAllHosts
$modulePath = "$PSScriptRoot\KENL-CommandCenter.psm1"
$backupPath = "$profilePath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"

Write-Host "KENL Command Center Installation" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

# Verify module exists
if (-not (Test-Path $modulePath)) {
    Write-Host "ERROR: Module not found at $modulePath" -ForegroundColor Red
    exit 1
}

# Create profile if it doesn't exist
if (-not (Test-Path $profilePath)) {
    Write-Host "Creating PowerShell profile at:" -ForegroundColor Yellow
    Write-Host "  $profilePath`n"
    New-Item -Path $profilePath -ItemType File -Force | Out-Null
}

# Backup existing profile
Write-Host "Backing up current profile to:" -ForegroundColor Green
Write-Host "  $backupPath`n"
Copy-Item $profilePath $backupPath

# Check if already installed
$profileContent = Get-Content $profilePath -Raw
$installMarker = "# KENL Command Center"

if ($profileContent -match [regex]::Escape($installMarker) -and -not $Force) {
    Write-Host "Command Center appears to be already installed." -ForegroundColor Yellow
    Write-Host "Use -Force to reinstall.`n"
    exit 0
}

# Installation code
$installCode = @"

# ============================================
# KENL Command Center
# ============================================
# Auto-displays context-aware dashboard
# Commands: cc, ccref, ccoff, ccon

Import-Module "$modulePath" -Force

# Show Command Center on startup
Show-CommandCenter -Mode Auto

"@

# Append to profile
Add-Content -Path $profilePath -Value $installCode

Write-Host "SUCCESS! Command Center installed." -ForegroundColor Green
Write-Host "`nTo activate immediately, run:" -ForegroundColor Cyan
Write-Host "  . `$PROFILE" -ForegroundColor Yellow
Write-Host "`nOr restart your PowerShell session.`n"

Write-Host "Quick Commands:" -ForegroundColor Cyan
Write-Host "  cc     - Show Command Center" -ForegroundColor White
Write-Host "  ccref  - Refresh display" -ForegroundColor White
Write-Host "  ccoff  - Disable" -ForegroundColor White
Write-Host "  ccon   - Enable" -ForegroundColor White
Write-Host "`nProfile backup saved to:" -ForegroundColor DarkGray
Write-Host "  $backupPath`n" -ForegroundColor DarkGray
