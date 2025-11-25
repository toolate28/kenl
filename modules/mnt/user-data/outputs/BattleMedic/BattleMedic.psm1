#
# BattleMedic.psm1
# Root module for Battle Medic Recovery Suite
# Version: 2.0.0
#

#region Module Configuration

# Module version for internal tracking
$script:BattleMedicVersion = '2.0.0'

# Module configuration storage
$script:BattleMedicConfig = @{
    LogPath = "$env:TEMP\BattleMedic"
    MaxLogFiles = 30
    DefaultPriority = 'P2'
    AutoBackup = $true
    VerboseLogging = $false
    SP4Mode = $false
    WinREIntegration = $false
}

# Export variables for external access
$BattleMedicVersion = $script:BattleMedicVersion
$BattleMedicConfig = $script:BattleMedicConfig

#endregion

#region Module Initialization

# Create log directory if it doesn't exist
if (-not (Test-Path $script:BattleMedicConfig.LogPath)) {
    New-Item -ItemType Directory -Path $script:BattleMedicConfig.LogPath -Force | Out-Null
}

# Detect if running on Surface Pro 4
$computerInfo = Get-CimInstance -ClassName Win32_ComputerSystem
if ($computerInfo.Model -like "*Surface Pro 4*") {
    $script:BattleMedicConfig.SP4Mode = $true
    Write-Verbose "Surface Pro 4 detected - enabling SP4-specific features"
}

# Check if running in Windows RE
if ($env:SystemDrive -ne 'C:' -and (Test-Path 'X:\Windows\System32')) {
    $script:BattleMedicConfig.WinREMode = $true
    Write-Verbose "Windows Recovery Environment detected"
}

#endregion

#region Core Functions

<#
.SYNOPSIS
    Initializes the Battle Medic Recovery Suite with specified configuration.
.DESCRIPTION
    This function sets up the Battle Medic environment with custom settings,
    validates the system state, and prepares for recovery operations.
.PARAMETER Config
    Hashtable containing configuration overrides
.PARAMETER Force
    Skip confirmation prompts
.EXAMPLE
    Initialize-BattleMedic -Config @{VerboseLogging = $true} -Force
#>
function Initialize-BattleMedic {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()]
        [hashtable]$Config = @{},
        
        [Parameter()]
        [switch]$Force
    )
    
    begin {
        Write-Verbose "Initializing Battle Medic Recovery Suite v$($script:BattleMedicVersion)"
    }
    
    process {
        if ($PSCmdlet.ShouldProcess("Battle Medic Configuration", "Initialize")) {
            # Merge provided config with defaults
            foreach ($key in $Config.Keys) {
                if ($script:BattleMedicConfig.ContainsKey($key)) {
                    $script:BattleMedicConfig[$key] = $Config[$key]
                    Write-Verbose "Updated configuration: $key = $($Config[$key])"
                }
            }
            
            # Validate environment
            $validation = Test-BattleMedicEnvironment
            if (-not $validation.IsValid) {
                if (-not $Force) {
                    throw "Environment validation failed: $($validation.Errors -join ', ')"
                }
                Write-Warning "Environment validation failed but Force flag set - continuing"
            }
            
            # Create recovery checkpoint if auto-backup enabled
            if ($script:BattleMedicConfig.AutoBackup) {
                Write-Verbose "Creating initialization checkpoint"
                New-RecoveryCheckpoint -Name "BattleMedic_Init_$(Get-Date -Format 'yyyyMMdd_HHmmss')" -Silent
            }
            
            Write-Information "Battle Medic initialized successfully" -InformationAction Continue
            
            return @{
                Version = $script:BattleMedicVersion
                Config = $script:BattleMedicConfig
                SP4Mode = $script:BattleMedicConfig.SP4Mode
                WinREMode = $script:BattleMedicConfig.WinREMode
                Validation = $validation
            }
        }
    }
}

<#
.SYNOPSIS
    Tests the Battle Medic environment for compatibility and requirements.
.DESCRIPTION
    Performs comprehensive validation of the system environment to ensure
    all Battle Medic features will function correctly.
.EXAMPLE
    $validation = Test-BattleMedicEnvironment
    if ($validation.IsValid) { Start-Recovery }
#>
function Test-BattleMedicEnvironment {
    [CmdletBinding()]
    param()
    
    $result = [PSCustomObject]@{
        IsValid = $true
        Errors = @()
        Warnings = @()
        SystemInfo = @{}
    }
    
    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        $result.IsValid = $false
        $result.Errors += "PowerShell 5.1 or higher required (current: $($PSVersionTable.PSVersion))"
    }
    
    # Check administrative privileges
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        $result.Warnings += "Not running as Administrator - some features will be unavailable"
    }
    $result.SystemInfo.IsAdmin = $isAdmin
    
    # Check disk space
    $systemDrive = Get-PSDrive -Name ($env:SystemDrive -replace ':','')
    $freeGB = [Math]::Round($systemDrive.Free / 1GB, 2)
    $result.SystemInfo.FreeSpaceGB = $freeGB
    
    if ($freeGB -lt 1) {
        $result.IsValid = $false
        $result.Errors += "Insufficient disk space: ${freeGB}GB free (minimum 1GB required)"
    } elseif ($freeGB -lt 5) {
        $result.Warnings += "Low disk space: ${freeGB}GB free"
    }
    
    # Check WMI/CIM availability
    try {
        $null = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
        $result.SystemInfo.WMIAvailable = $true
    }
    catch {
        $result.IsValid = $false
        $result.Errors += "WMI/CIM not available - required for diagnostics"
        $result.SystemInfo.WMIAvailable = $false
    }
    
    # Check battery (for mobile devices)
    $battery = Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue
    if ($battery) {
        $result.SystemInfo.BatteryPresent = $true
        $result.SystemInfo.BatteryLevel = $battery.EstimatedChargeRemaining
        
        if ($battery.EstimatedChargeRemaining -lt 30 -and $battery.BatteryStatus -eq 1) {
            $result.Warnings += "Low battery: $($battery.EstimatedChargeRemaining)% - connect AC adapter"
        }
    }
    
    # Check if running in WinRE
    if (Test-Path 'X:\Windows\System32') {
        $result.SystemInfo.InWinRE = $true
        $result.SystemInfo.WindowsDrive = Find-WindowsPartition
    }
    else {
        $result.SystemInfo.InWinRE = $false
        $result.SystemInfo.WindowsDrive = $env:SystemDrive
    }
    
    return $result
}

<#
.SYNOPSIS
    Displays the Battle Medic recovery menu.
.DESCRIPTION
    Shows an interactive menu for selecting recovery options based on
    the current system state and user preference.
.PARAMETER Mode
    Menu mode: Interactive, Guided, Expert, or Automated
.EXAMPLE
    Show-RecoveryMenu -Mode Guided
#>
function Show-RecoveryMenu {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet('Interactive', 'Guided', 'Expert', 'Automated')]
        [string]$Mode = 'Interactive'
    )
    
    # Display header
    Write-Host "`n" -NoNewline
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║          BATTLE MEDIC RECOVERY SUITE v$($script:BattleMedicVersion)           ║" -ForegroundColor Cyan
    if ($script:BattleMedicConfig.SP4Mode) {
        Write-Host "║             Surface Pro 4 Mode - Enhanced Features Active      ║" -ForegroundColor Yellow
    }
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    # Get system status
    $diagnostic = Get-BattleMedicDiagnostic -Quick
    
    # Display system status
    Write-Host "System Status:" -ForegroundColor White
    Write-Host "  Priority Level: " -NoNewline
    
    $priorityColor = switch ($diagnostic.Priority) {
        'P0' { 'Red' }
        'P1' { 'Magenta' }
        'P2' { 'Yellow' }
        'P3' { 'Green' }
        default { 'Gray' }
    }
    Write-Host $diagnostic.Priority -ForegroundColor $priorityColor
    
    if ($diagnostic.Issues.Count -gt 0) {
        Write-Host "  Issues Detected: $($diagnostic.Issues.Count)" -ForegroundColor Red
    }
    
    Write-Host ""
    
    switch ($Mode) {
        'Interactive' {
            Show-InteractiveMenu -Diagnostic $diagnostic
        }
        'Guided' {
            Start-GuidedRecovery -Diagnostic $diagnostic
        }
        'Expert' {
            Show-ExpertMenu -Diagnostic $diagnostic
        }
        'Automated' {
            Start-AutomatedRecovery -Diagnostic $diagnostic -Confirm
        }
    }
}

#endregion

#region Private Helper Functions

function Find-WindowsPartition {
    [CmdletBinding()]
    param()
    
    $drives = Get-PSDrive -PSProvider FileSystem
    foreach ($drive in $drives) {
        $windowsPath = Join-Path -Path "$($drive.Name):" -ChildPath 'Windows\System32'
        if (Test-Path $windowsPath) {
            Write-Verbose "Found Windows installation at $($drive.Name):"
            return "$($drive.Name):"
        }
    }
    
    Write-Warning "No Windows installation found"
    return $null
}

function Show-InteractiveMenu {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Diagnostic
    )
    
    do {
        Write-Host "`nSelect Recovery Option:" -ForegroundColor Cyan
        Write-Host "[1] Quick Diagnostic Report" -ForegroundColor White
        Write-Host "[2] Guided Recovery (Recommended)" -ForegroundColor Green
        Write-Host "[3] Expert Mode (All Tools)" -ForegroundColor Yellow
        Write-Host "[4] Automated Recovery" -ForegroundColor Yellow
        
        if ($script:BattleMedicConfig.SP4Mode) {
            Write-Host "[5] Surface Pro 4 Specific Fixes" -ForegroundColor Magenta
        }
        
        Write-Host "[L] View Logs" -ForegroundColor Gray
        Write-Host "[S] Settings" -ForegroundColor Gray
        Write-Host "[X] Exit" -ForegroundColor Gray
        Write-Host ""
        
        $choice = Read-Host "Enter your choice"
        
        switch ($choice.ToUpper()) {
            '1' {
                Get-SystemHealthReport -Detailed | Format-List
                Read-Host "`nPress Enter to continue"
            }
            '2' {
                Start-GuidedRecovery -Diagnostic $Diagnostic
            }
            '3' {
                Show-ExpertMenu -Diagnostic $Diagnostic
            }
            '4' {
                Start-AutomatedRecovery -Diagnostic $Diagnostic -Confirm
            }
            '5' {
                if ($script:BattleMedicConfig.SP4Mode) {
                    Show-SP4Menu
                }
            }
            'L' {
                Get-BattleMedicLog -Latest 10 | Format-Table
                Read-Host "`nPress Enter to continue"
            }
            'S' {
                Show-SettingsMenu
            }
            'X' {
                Write-Host "Exiting Battle Medic Recovery Suite..." -ForegroundColor Green
                return
            }
            default {
                Write-Warning "Invalid choice. Please try again."
            }
        }
    } while ($choice.ToUpper() -ne 'X')
}

function Show-ExpertMenu {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Diagnostic
    )
    
    Write-Host "`nExpert Recovery Tools:" -ForegroundColor Cyan
    Write-Host "┌─────────────────────────────────────────────────┐" -ForegroundColor Gray
    Write-Host "│ P0 - Critical Issues                           │" -ForegroundColor Gray
    Write-Host "├─────────────────────────────────────────────────┤" -ForegroundColor Gray
    Write-Host "│ [1] Repair WOF.SYS Driver                      │" -ForegroundColor Red
    Write-Host "│ [2] Emergency Disk Cleanup                     │" -ForegroundColor Red
    Write-Host "│ [3] Thermal Mitigation                         │" -ForegroundColor Red
    Write-Host "│                                                 │" -ForegroundColor Gray
    Write-Host "│ P1 - High Priority                             │" -ForegroundColor Gray
    Write-Host "├─────────────────────────────────────────────────┤" -ForegroundColor Gray
    Write-Host "│ [4] System File Repair (SFC/DISM)             │" -ForegroundColor Magenta
    Write-Host "│ [5] Reset Windows Update                       │" -ForegroundColor Magenta
    Write-Host "│ [6] Boot Configuration Repair                  │" -ForegroundColor Magenta
    
    if ($script:BattleMedicConfig.SP4Mode) {
        Write-Host "│                                                 │" -ForegroundColor Gray
        Write-Host "│ SP4 Specific                                   │" -ForegroundColor Gray
        Write-Host "├─────────────────────────────────────────────────┤" -ForegroundColor Gray
        Write-Host "│ [7] Fix Screen Flicker                         │" -ForegroundColor Yellow
        Write-Host "│ [8] Fix Type Cover Issues                      │" -ForegroundColor Yellow
        Write-Host "│ [9] Reset Intel GPU Driver                     │" -ForegroundColor Yellow
    }
    
    Write-Host "└─────────────────────────────────────────────────┘" -ForegroundColor Gray
    Write-Host ""
    
    $expertChoice = Read-Host "Select tool (1-9) or X to return"
    
    switch ($expertChoice) {
        '1' { Repair-WOFDriver -Verbose }
        '2' { Start-EmergencyCleanup -Verbose }
        '3' { Start-ThermalMitigation -Verbose }
        '4' { Repair-SystemFiles -Verbose }
        '5' { Reset-WindowsUpdate -Verbose }
        '6' { Repair-BootConfiguration -Verbose }
        '7' { if ($script:BattleMedicConfig.SP4Mode) { Repair-SP4ScreenFlicker -Verbose } }
        '8' { if ($script:BattleMedicConfig.SP4Mode) { Repair-SP4TypeCover -Verbose } }
        '9' { if ($script:BattleMedicConfig.SP4Mode) { Reset-SP4GPUDriver -Verbose } }
    }
    
    if ($expertChoice -ne 'X') {
        Read-Host "`nPress Enter to continue"
    }
}

#endregion

#region Module Aliases

New-Alias -Name 'bmr' -Value 'Start-BattleMedicRecovery' -Force
New-Alias -Name 'bmdiag' -Value 'Get-BattleMedicDiagnostic' -Force
New-Alias -Name 'bmlog' -Value 'Get-BattleMedicLog' -Force
New-Alias -Name 'sp4fix' -Value 'Start-SP4Recovery' -Force
New-Alias -Name 'woffix' -Value 'Repair-WOFDriver' -Force

#endregion

#region Module Cleanup

$ExecutionContext.SessionState.Module.OnRemove = {
    Write-Verbose "Unloading Battle Medic Recovery Suite"
    
    # Save current configuration
    if ($script:BattleMedicConfig.AutoBackup) {
        $configPath = Join-Path -Path $script:BattleMedicConfig.LogPath -ChildPath 'LastConfig.json'
        $script:BattleMedicConfig | ConvertTo-Json | Out-File -FilePath $configPath -Force
    }
    
    # Clean up any temporary files
    $tempFiles = Get-ChildItem -Path $env:TEMP -Filter 'BattleMedic_Temp_*' -ErrorAction SilentlyContinue
    if ($tempFiles) {
        $tempFiles | Remove-Item -Force -ErrorAction SilentlyContinue
    }
}

#endregion

# Display module load message
if (-not $script:Silent) {
    Write-Host "Battle Medic Recovery Suite v$($script:BattleMedicVersion) loaded successfully" -ForegroundColor Green
    
    if ($script:BattleMedicConfig.SP4Mode) {
        Write-Host "Surface Pro 4 detected - enhanced features enabled" -ForegroundColor Yellow
    }
    
    Write-Host "Type 'Show-RecoveryMenu' to begin or 'Get-Help about_BattleMedic' for more information" -ForegroundColor Cyan
}
