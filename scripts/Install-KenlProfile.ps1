#Requires -Version 5.1
<#
.SYNOPSIS
    KENL Profile Installation Script - Adds KENL functions and dynamic banners to PowerShell profile

.DESCRIPTION
    Installs KENL profile integration including:
    - Dynamic banner showing current context
    - Current playcard display
    - Quick access functions for KENL modules
    - ATOM trail integration

.PARAMETER NoBackup
    Skip backing up existing profile

.PARAMETER Force
    Overwrite existing KENL profile content

.EXAMPLE
    .\Install-KenlProfile.ps1

.EXAMPLE
    .\Install-KenlProfile.ps1 -Force

.NOTES
    File Name      : Install-KenlProfile.ps1
    Author         : KENL Framework
    Prerequisite   : PowerShell 5.1+
    Version        : 1.0.0
    ATOM           : ATOM-PROFILE-20251126-001

    Rollback Instructions:
    1. Restore from backup: Copy-Item "$PROFILE.backup.YYYYMMDDHHMMSS" $PROFILE -Force
       (Replace YYYYMMDDHHMMSS with your actual backup timestamp)
    2. Or manually remove KENL section: Edit $PROFILE and delete lines between
       "# === KENL PROFILE INTEGRATION ===" and "# === END KENL PROFILE INTEGRATION ==="
    3. Reload profile: . $PROFILE
#>

[CmdletBinding()]
param(
    [switch]$NoBackup,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# ============================================
# Configuration
# ============================================

$KenlHome = if ($env:KENL_HOME) { $env:KENL_HOME } else { Join-Path $env:USERPROFILE ".kenl" }
$ProfileMarker = "# === KENL PROFILE INTEGRATION ==="
$ProfileEndMarker = "# === END KENL PROFILE INTEGRATION ==="

# ============================================
# Profile Content
# ============================================

$ProfileContent = @'
# === KENL PROFILE INTEGRATION ===
# Installed by Install-KenlProfile.ps1
# ATOM: ATOM-PROFILE-20251126-001

# ============================================
# KENL Environment Variables
# ============================================

$env:KENL_HOME = if ($env:KENL_HOME) { $env:KENL_HOME } else { Join-Path $env:USERPROFILE ".kenl" }
$env:KENL_CURRENT_PLAYCARD = ""
$env:KENL_CURRENT_MODULE = ""

# ============================================
# Helper Functions
# ============================================

function Write-KenlAtomTrail {
    <#
    .SYNOPSIS
        Safely writes to ATOM trail, using Write-AtomTrail if available or direct file write
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Type,
        [Parameter(Mandatory)]
        [string]$Action
    )
    
    # Try using the module function first
    if (Get-Command Write-AtomTrail -ErrorAction SilentlyContinue) {
        Write-AtomTrail -Type $Type -Action $Action
        return
    }
    
    # Fallback to direct file write
    $atomPath = Join-Path $env:KENL_HOME "atom_trail.log"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $platform = if ($IsWindows -or $env:OS -eq "Windows_NT") { "Windows" } elseif ($IsLinux) { "Linux" } else { "Unknown" }
    # Sequence counter for uniqueness
    $dateTag = Get-Date -Format 'yyyyMMdd'
    $sequenceFile = Join-Path $env:KENL_HOME "atom_sequence_${dateTag}.txt"
    if (Test-Path $sequenceFile) {
        $sequence = ([int](Get-Content $sequenceFile)) + 1
    } else {
        $sequence = 1
    }
    Set-Content -Path $sequenceFile -Value $sequence
    $entry = "[$timestamp] [ATOM-$Type-$dateTag-$('{0:D3}' -f $sequence)] [$platform] $Action"
    
    try {
        Add-Content -Path $atomPath -Value $entry -ErrorAction Stop
    } catch {
        Write-Verbose "Could not write to ATOM trail: $_"
    }
}

# ============================================
# Module Loading
# ============================================

# Load KENL core modules if available
$kenlModulePath = Join-Path $env:KENL_HOME "modules\KENL0-system\powershell"
if (Test-Path $kenlModulePath) {
    $modules = @(
        "KENL.psm1",
        "KENL.SAIF.psm1",
        "KENL.Network.psm1"
    )
    foreach ($mod in $modules) {
        $modPath = Join-Path $kenlModulePath $mod
        if (Test-Path $modPath) {
            Import-Module $modPath -ErrorAction SilentlyContinue -DisableNameChecking
        }
    }
}

# Load BattleMedic if available
$battleMedicPath = Join-Path $env:KENL_HOME "modules\Surface_Pro_4_EoL_BattleMedic_v2.1\BattleMedic.psm1"
if (Test-Path $battleMedicPath) {
    Import-Module $battleMedicPath -ErrorAction SilentlyContinue -DisableNameChecking
}

# ============================================
# Dynamic Banner Function
# ============================================

function Show-KenlBanner {
    <#
    .SYNOPSIS
        Displays dynamic KENL banner with current context
    .DESCRIPTION
        Shows current playcard, module, platform, and recent ATOM activity
    #>
    [CmdletBinding()]
    param(
        [switch]$Minimal
    )

    # Detect platform
    $platform = if ($IsWindows -or $env:OS -eq "Windows_NT") {
        if ($env:WSL_DISTRO_NAME) { "WSL2 ($($env:WSL_DISTRO_NAME))" }
        else { "Windows" }
    } elseif ($IsLinux) {
        if (Test-Path "/etc/os-release") {
            $osRelease = Get-Content "/etc/os-release" | Where-Object { $_ -match "^PRETTY_NAME=" }
            if ($osRelease) { ($osRelease -split "=")[1].Trim('"') }
            else { "Linux" }
        } else { "Linux" }
    } else { "Unknown" }

    # Get current playcard
    $playcard = if ($env:KENL_CURRENT_PLAYCARD) {
        $env:KENL_CURRENT_PLAYCARD
    } else {
        $playcardPath = Join-Path $env:KENL_HOME "current-playcard.yaml"
        if (Test-Path $playcardPath) {
            $content = Get-Content $playcardPath -Raw
            if ($content -match "game:\s*(.+)") { $Matches[1].Trim() }
            else { "(none)" }
        } else { "(none)" }
    }

    # Get current module context
    $moduleContext = if ($env:KENL_CURRENT_MODULE) {
        $env:KENL_CURRENT_MODULE
    } else {
        $pwd = Get-Location
        if ($pwd.Path -match "KENL(\d+)") { "KENL$($Matches[1])" }
        else { "Global" }
    }

    # Get recent ATOM entry
    $recentAtom = "(none)"
    $atomPath = Join-Path $env:KENL_HOME "atom_trail.log"
    if (Test-Path $atomPath) {
        $lastLine = Get-Content $atomPath -Tail 1 -ErrorAction SilentlyContinue
        if ($lastLine -match '\[(ATOM-[^\]]+)\]') {
            $recentAtom = $Matches[1]
        }
    }

    # Check SAIF status
    $saifFlag = "(none)"
    $saifPath = Join-Path $env:KENL_HOME "saif-trail.log"
    if (Test-Path $saifPath) {
        $lastSaif = Get-Content $saifPath -Tail 1 -ErrorAction SilentlyContinue
        if ($lastSaif) {
            try {
                $saifJson = $lastSaif | ConvertFrom-Json -ErrorAction SilentlyContinue
                if ($saifJson.flag) { $saifFlag = $saifJson.flag }
            } catch { }
        }
    }

    if ($Minimal) {
        Write-Host "KENL | $moduleContext | 🎮 $playcard" -ForegroundColor Cyan
    } else {
        Write-Host ""
        Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "║  " -NoNewline -ForegroundColor Cyan
        Write-Host "KENL " -NoNewline -ForegroundColor White
        Write-Host "- Intent-Driven Infrastructure" -NoNewline -ForegroundColor Gray
        Write-Host "                       ║" -ForegroundColor Cyan
        Write-Host "╠══════════════════════════════════════════════════════════════╣" -ForegroundColor Cyan
        
        # Platform
        Write-Host "║  Platform:  " -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-49}" -f $platform) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan
        
        # Module Context
        Write-Host "║  Context:   " -NoNewline -ForegroundColor Cyan
        $contextColor = switch -Regex ($moduleContext) {
            "KENL0" { "Yellow" }
            "KENL2" { "Red" }
            "KENL3" { "Blue" }
            default { "White" }
        }
        Write-Host ("{0,-49}" -f $moduleContext) -NoNewline -ForegroundColor $contextColor
        Write-Host "║" -ForegroundColor Cyan
        
        # Current Playcard
        Write-Host "║  Playcard:  " -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-49}" -f "🎮 $playcard") -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
        
        # Recent ATOM
        Write-Host "║  ATOM:      " -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-49}" -f $recentAtom) -NoNewline -ForegroundColor Yellow
        Write-Host "║" -ForegroundColor Cyan
        
        # SAIF Flag
        Write-Host "║  SAIF:      " -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-49}" -f $saifFlag) -NoNewline -ForegroundColor Magenta
        Write-Host "║" -ForegroundColor Cyan
        
        Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
        Write-Host ""
    }
}

# ============================================
# Current Playcard Management
# ============================================

function Get-CurrentPlaycard {
    <#
    .SYNOPSIS
        Gets the current active playcard
    #>
    [CmdletBinding()]
    param()

    $playcardPath = Join-Path $env:KENL_HOME "current-playcard.yaml"
    
    if (Test-Path $playcardPath) {
        Get-Content $playcardPath -Raw
    } else {
        Write-Host "No current playcard set." -ForegroundColor Yellow
        Write-Host "Set one with: Set-CurrentPlaycard -Path <playcard.yaml>" -ForegroundColor Gray
    }
}

function Set-CurrentPlaycard {
    <#
    .SYNOPSIS
        Sets the current active playcard
    .PARAMETER Path
        Path to the playcard YAML file
    .PARAMETER Name
        Name of a playcard in the play-cards directory
    #>
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName='Path')]
        [string]$Path,
        
        [Parameter(ParameterSetName='Name')]
        [string]$Name
    )

    $targetPath = Join-Path $env:KENL_HOME "current-playcard.yaml"
    
    if ($Name) {
        # Validate name doesn't contain path separators or relative path components
        if ($Name -match '[/\\]' -or $Name -match '\.\.') {
            Write-Host "Invalid playcard name. Name cannot contain path separators or relative path components." -ForegroundColor Red
            return
        }
        $Path = Join-Path $env:KENL_HOME "modules\KENL2-gaming\play-cards\games\$Name.yaml"
    }
    
    if (-not $Path -or -not (Test-Path $Path)) {
        Write-Host "Playcard not found: $Path" -ForegroundColor Red
        return
    }
    
    Copy-Item $Path $targetPath -Force
    
    # Extract game name
    $content = Get-Content $Path -Raw
    if ($content -match "game:\s*(.+)") {
        $env:KENL_CURRENT_PLAYCARD = $Matches[1].Trim()
    }
    
    Write-Host "✅ Current playcard set to: $($env:KENL_CURRENT_PLAYCARD)" -ForegroundColor Green
    
    # Log to ATOM trail using helper
    Write-KenlAtomTrail -Type GAMING -Action "Set current playcard: $($env:KENL_CURRENT_PLAYCARD)"
}

function Show-Playcards {
    <#
    .SYNOPSIS
        Lists all available playcards
    #>
    [CmdletBinding()]
    param()

    $playcardDir = Join-Path $env:KENL_HOME "modules\KENL2-gaming\play-cards\games"
    
    if (-not (Test-Path $playcardDir)) {
        Write-Host "Playcard directory not found: $playcardDir" -ForegroundColor Yellow
        return
    }
    
    Write-Host ""
    Write-Host "Available Playcards:" -ForegroundColor Cyan
    Write-Host "─" * 50 -ForegroundColor Gray
    
    Get-ChildItem $playcardDir -Filter "*.yaml" | ForEach-Object {
        $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
        $gameName = if ($content -match "game:\s*(.+)") { $Matches[1].Trim() } else { $_.BaseName }
        $verified = if ($content -match "verified:\s*(.+)") { $Matches[1].Trim() } else { "unknown" }
        
        Write-Host "  🎮 " -NoNewline
        Write-Host $gameName -NoNewline -ForegroundColor White
        Write-Host " (verified: $verified)" -ForegroundColor Gray
    }
    
    Write-Host ""
}

# ============================================
# Quick Module Navigation
# ============================================

function kenl-switch {
    <#
    .SYNOPSIS
        Switch to a specific KENL module directory
    .PARAMETER Module
        Module number (0-13) or name
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Module
    )

    $moduleMap = @{
        "0" = "KENL0-system"
        "1" = "KENL1-framework"
        "2" = "KENL2-gaming"
        "3" = "KENL3-dev"
        "4" = "KENL4-monitoring"
        "5" = "KENL5-facades"
        "6" = "KENL6-social"
        "7" = "KENL7-learning"
        "8" = "KENL8-security"
        "9" = "KENL9-library"
        "10" = "KENL10-backup"
        "11" = "KENL11-media"
        "12" = "KENL12-resources"
        "13" = "KENL13-iwi"
        "battlemedic" = "Surface_Pro_4_EoL_BattleMedic_v2.1"
    }

    $targetDir = $moduleMap[$Module]
    if (-not $targetDir) { 
        # Validate module name doesn't contain path separators or relative path components
        if ($Module -match '[/\\]' -or $Module -match '\.\.') {
            Write-Host "Invalid module name. Name cannot contain path separators or relative path components." -ForegroundColor Red
            return
        }
        $targetDir = $Module 
    }

    $fullPath = Join-Path $env:KENL_HOME "modules\$targetDir"
    
    if (Test-Path $fullPath) {
        Set-Location $fullPath
        $env:KENL_CURRENT_MODULE = $targetDir
        Write-Host "📁 Switched to: $targetDir" -ForegroundColor Cyan
        
        # Show module README hint
        if (Test-Path (Join-Path $fullPath "README.md")) {
            Write-Host "   Run: Get-Content README.md | more" -ForegroundColor Gray
        }
    } else {
        Write-Host "Module not found: $Module" -ForegroundColor Red
    }
}

function kenl-home {
    <#
    .SYNOPSIS
        Return to KENL home directory
    #>
    Set-Location $env:KENL_HOME
    $env:KENL_CURRENT_MODULE = "Global"
    Write-Host "📁 Returned to KENL home" -ForegroundColor Cyan
}

function kenl-status {
    <#
    .SYNOPSIS
        Show comprehensive KENL status
    #>
    [CmdletBinding()]
    param()

    Show-KenlBanner
    
    if (Get-Command Get-KenlInfo -ErrorAction SilentlyContinue) {
        Get-KenlInfo
    }
    
    if (Get-Command Get-BattleMedicVersion -ErrorAction SilentlyContinue) {
        Write-Host ""
        Write-Host "BattleMedic Status:" -ForegroundColor Cyan
        Get-BattleMedicVersion
    }
}

# ============================================
# Aliases
# ============================================

Set-Alias -Name kswitch -Value kenl-switch
Set-Alias -Name khome -Value kenl-home
Set-Alias -Name kstatus -Value kenl-status
Set-Alias -Name kbanner -Value Show-KenlBanner
Set-Alias -Name kplaycard -Value Get-CurrentPlaycard
Set-Alias -Name kplaycards -Value Show-Playcards

# ============================================
# Auto-Display Banner on Load
# ============================================

# Uncomment the next line to show banner on every PowerShell start:
# Show-KenlBanner -Minimal

Write-Host "✓ KENL profile loaded" -ForegroundColor Green
Write-Host "  Commands: kswitch, khome, kstatus, kbanner, kplaycard" -ForegroundColor Gray

# === END KENL PROFILE INTEGRATION ===
'@

# ============================================
# Installation Logic
# ============================================

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        KENL Profile Installation                             ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Check KENL home exists
if (-not (Test-Path $KenlHome)) {
    Write-Host "KENL home not found: $KenlHome" -ForegroundColor Yellow
    Write-Host "Please clone KENL repository first:" -ForegroundColor Yellow
    Write-Host "  git clone https://github.com/toolate28/kenl.git $KenlHome" -ForegroundColor Gray
    exit 1
}

# Check profile path
if (-not $PROFILE) {
    Write-Error "PowerShell profile path not defined"
    exit 1
}

Write-Host "Profile path: $PROFILE" -ForegroundColor Gray

# Check if profile exists
$profileExists = Test-Path $PROFILE

if ($profileExists) {
    # Check if KENL already installed
    $existingContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
    
    if ($existingContent -match [regex]::Escape($ProfileMarker)) {
        if (-not $Force) {
            Write-Host "KENL profile integration already installed." -ForegroundColor Yellow
            Write-Host "Use -Force to reinstall." -ForegroundColor Gray
            exit 0
        }
        
        # Remove existing KENL section
        Write-Host "Removing existing KENL integration..." -ForegroundColor Yellow
        $pattern = "(?s)$([regex]::Escape($ProfileMarker)).*?$([regex]::Escape($ProfileEndMarker))"
        $existingContent = $existingContent -replace $pattern, ""
        $existingContent = $existingContent.Trim()
    }
    
    # Backup existing profile
    if (-not $NoBackup) {
        $backupPath = "$PROFILE.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
        Copy-Item $PROFILE $backupPath
        Write-Host "Profile backed up to: $backupPath" -ForegroundColor Green
    }
} else {
    # Create profile directory if needed
    $profileDir = Split-Path $PROFILE
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        Write-Host "Created profile directory: $profileDir" -ForegroundColor Green
    }
    $existingContent = ""
}

# Append KENL profile content
$newContent = if ($existingContent) {
    "$existingContent`n`n$ProfileContent"
} else {
    $ProfileContent
}

Set-Content -Path $PROFILE -Value $newContent -Encoding UTF8

Write-Host ""
Write-Host "✅ KENL profile integration installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "To activate, run:" -ForegroundColor Cyan
Write-Host "  . `$PROFILE" -ForegroundColor White
Write-Host ""
Write-Host "Or restart PowerShell." -ForegroundColor Gray
Write-Host ""
Write-Host "Available commands after activation:" -ForegroundColor Cyan
Write-Host "  Show-KenlBanner    - Display current context" -ForegroundColor White
Write-Host "  kenl-switch <n>    - Switch to module (0-13, battlemedic)" -ForegroundColor White
Write-Host "  kenl-home          - Return to KENL home" -ForegroundColor White
Write-Host "  kenl-status        - Comprehensive status" -ForegroundColor White
Write-Host "  Get-CurrentPlaycard - Show current playcard" -ForegroundColor White
Write-Host "  Set-CurrentPlaycard - Set active playcard" -ForegroundColor White
Write-Host "  Show-Playcards     - List all playcards" -ForegroundColor White
Write-Host ""

# Log installation
$atomPath = Join-Path $KenlHome "atom_trail.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$platform = if ($IsWindows -or $env:OS -eq "Windows_NT") { "Windows" } elseif ($IsLinux) { "Linux" } elseif ($IsMacOS) { "macOS" } else { "Unknown" }
$entry = "[$timestamp] [ATOM-PROFILE-20251126-001] [$platform] Installed KENL profile integration"
try {
    Add-Content -Path $atomPath -Value $entry -ErrorAction Stop
    Write-Verbose "ATOM trail entry written to: $atomPath"
} catch {
    Write-Warning "Could not write to ATOM trail: $_"
}

Write-Host "ATOM: ATOM-PROFILE-20251126-001" -ForegroundColor Yellow
