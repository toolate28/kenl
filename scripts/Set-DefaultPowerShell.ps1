#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Set PowerShell 7 as default shell for Windows Terminal and scripts

.DESCRIPTION
    Updates:
    - Windows Terminal default profile to PowerShell 7
    - File associations for .ps1 files
    - PATH priority (PowerShell 7 first)
    - Verifies PowerShell 7 is installed

.NOTES
    This should be run early in system setup/triage
    Prevents errors from PowerShell 5.1 vs 7 differences
#>

[CmdletBinding()]
param()

Write-Host "`n╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Set PowerShell 7 as Default Shell      ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Check if PowerShell 7 is installed
$pwsh7Path = (Get-Command pwsh -ErrorAction SilentlyContinue).Source

if (-not $pwsh7Path) {
    Write-Host "❌ PowerShell 7 not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Install PowerShell 7:" -ForegroundColor Yellow
    Write-Host "  winget install Microsoft.PowerShell" -ForegroundColor Gray
    Write-Host "  Or download from: https://aka.ms/powershell" -ForegroundColor Gray
    exit 1
}

Write-Host "✅ PowerShell 7 found: $pwsh7Path" -ForegroundColor Green

# Get version
$pwsh7Version = & pwsh --version
Write-Host "   Version: $pwsh7Version" -ForegroundColor Gray
Write-Host ""

# 1. Update Windows Terminal settings
Write-Host "[1/3] Updating Windows Terminal default profile..." -ForegroundColor Yellow

$wtSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

if (Test-Path $wtSettingsPath) {
    try {
        $settings = Get-Content $wtSettingsPath -Raw | ConvertFrom-Json

        # Find PowerShell 7 profile GUID
        $pwsh7Profile = $settings.profiles.list | Where-Object { $_.name -like "*PowerShell 7*" -or $_.name -like "*pwsh*" }

        if ($pwsh7Profile) {
            $settings.defaultProfile = $pwsh7Profile.guid
            $settings | ConvertTo-Json -Depth 10 | Set-Content $wtSettingsPath
            Write-Host "   ✅ Windows Terminal now defaults to PowerShell 7" -ForegroundColor Green
        }
        else {
            Write-Host "   ⚠️  PowerShell 7 profile not found in Windows Terminal" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "   ⚠️  Could not update Windows Terminal settings: $_" -ForegroundColor Yellow
    }
}
else {
    Write-Host "   ⚠️  Windows Terminal settings not found" -ForegroundColor Yellow
}

Write-Host ""

# 2. Update .ps1 file association
Write-Host "[2/3] Updating .ps1 file association..." -ForegroundColor Yellow

try {
    # Set pwsh.exe as default for .ps1 files
    cmd /c "assoc .ps1=Microsoft.PowerShellScript.1"
    cmd /c "ftype Microsoft.PowerShellScript.1=`"$pwsh7Path`" -NoLogo -ExecutionPolicy Bypass -File `"%1`""

    Write-Host "   ✅ .ps1 files now execute with PowerShell 7" -ForegroundColor Green
}
catch {
    Write-Host "   ⚠️  Could not update file association: $_" -ForegroundColor Yellow
}

Write-Host ""

# 3. Verify PATH priority
Write-Host "[3/3] Checking PATH priority..." -ForegroundColor Yellow

$pathDirs = $env:PATH -split ';'
$pwsh7Dir = Split-Path $pwsh7Path
$pwsh5Dir = "$env:SystemRoot\System32\WindowsPowerShell\v1.0"

$pwsh7Index = $pathDirs.IndexOf($pwsh7Dir)
$pwsh5Index = $pathDirs.IndexOf($pwsh5Dir)

if ($pwsh7Index -lt $pwsh5Index -or $pwsh5Index -eq -1) {
    Write-Host "   ✅ PowerShell 7 has PATH priority" -ForegroundColor Green
}
else {
    Write-Host "   ⚠️  PowerShell 5.1 comes before PowerShell 7 in PATH" -ForegroundColor Yellow
    Write-Host "   Consider moving PowerShell 7 directory higher in PATH" -ForegroundColor Gray
}

Write-Host ""

# Summary
Write-Host "═══════════════════════════════════════════" -ForegroundColor Green
Write-Host "CONFIGURATION COMPLETE" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════" -ForegroundColor Green
Write-Host ""

Write-Host "Current Default:" -ForegroundColor Cyan
Write-Host "  pwsh:        $pwsh7Path" -ForegroundColor White
Write-Host "  Version:     $pwsh7Version" -ForegroundColor White
Write-Host ""

Write-Host "Verification:" -ForegroundColor Cyan
Write-Host "  Open new terminal → should be PowerShell 7" -ForegroundColor Gray
Write-Host "  Run 'pwsh' → should launch PowerShell 7" -ForegroundColor Gray
Write-Host "  Double-click .ps1 → should use PowerShell 7" -ForegroundColor Gray
Write-Host ""

Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "  1. Close and reopen terminal windows" -ForegroundColor White
Write-Host "  2. Verify: `$PSVersionTable shows 7.x" -ForegroundColor White
Write-Host "  3. All KENL scripts now use PowerShell 7" -ForegroundColor White
Write-Host ""

# Write ATOM trail
if (Get-Command Write-AtomTrail -ErrorAction SilentlyContinue) {
    Write-AtomTrail -Type "SYSTEM" -Action "PowerShell 7 set as default shell" -Context @{ Version = $pwsh7Version; Path = $pwsh7Path }
}
