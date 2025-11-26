#
# BattleMedic.psm1
# Root module for Battle Medic Recovery Suite v2.1
# Full compatibility: PowerShell 3.0-7.x
#

#region Module Initialization and Compatibility Layer

# Detect PowerShell version and set compatibility mode
$script:PSVersionMajor = $PSVersionTable.PSVersion.Major
$script:PSVersionMinor = $PSVersionTable.PSVersion.Minor
$script:IsCore = $PSVersionTable.PSEdition -eq 'Core'
$script:IsDesktop = $PSVersionTable.PSEdition -eq 'Desktop' -or $PSVersionTable.PSEdition -eq $null

# Module configuration with defaults
$script:BattleMedicVersion = '2.1.0'
$script:BattleMedicConfig = @{
    # Paths
    LogPath = if ($env:TEMP) { "$env:TEMP\BattleMedic" } else { "$env:TMP\BattleMedic" }
    ConfigPath = if ($env:LOCALAPPDATA) { "$env:LOCALAPPDATA\BattleMedic" } else { "$env:USERPROFILE\.battlemedic" }

    # Behavior
    MaxLogFiles = 30
    DefaultPriority = 'P2'
    AutoBackup = $true
    VerboseLogging = $false
    IdempotentMode = $true  # Always check state before operations

    # Detection
    SP4Mode = $false
    WinREMode = $false
    CompatibilityMode = $script:PSVersionMajor -lt 5

    # SAIF Compliance
    SAIFEnabled = $true
    AuditLevel = 'Full'

    # Claude Code Integration
    ClaudeCodeCompatible = $true
}

# Export module variables
$BattleMedicVersion = $script:BattleMedicVersion
$BattleMedicConfig = $script:BattleMedicConfig
$BattleMedicCompatibilityMode = $script:PSVersionMajor -lt 5

#endregion

#region Compatibility Functions

# PowerShell 3.0 compatibility layer
if ($script:PSVersionMajor -lt 5) {
    Write-Verbose "Battle Medic: PowerShell $($script:PSVersionMajor).$($script:PSVersionMinor) detected - enabling compatibility mode"

    # Add Get-CimInstance wrapper if not available
    if (-not (Get-Command Get-CimInstance -ErrorAction SilentlyContinue)) {
        function Get-CimInstance {
            [CmdletBinding()]
            param(
                [string]$ClassName,
                [string]$Namespace = 'root\cimv2',
                [string]$ComputerName = '.',
                [hashtable]$Property,
                [string]$Filter
            )

            try {
                $query = "SELECT * FROM $ClassName"
                if ($Filter) { $query += " WHERE $Filter" }

                if ($Namespace -eq 'root\cimv2') {
                    Get-WmiObject -Class $ClassName -ComputerName $ComputerName -Filter $Filter -ErrorAction Stop
                } else {
                    Get-WmiObject -Class $ClassName -Namespace $Namespace -ComputerName $ComputerName -Filter $Filter -ErrorAction Stop
                }
            }
            catch {
                Write-Error "WMI query failed: $_"
            }
        }
    }

    # Add Test-NetConnection wrapper if not available
    if (-not (Get-Command Test-NetConnection -ErrorAction SilentlyContinue)) {
        function Test-NetConnection {
            [CmdletBinding()]
            param(
                [string]$ComputerName,
                [int]$Port,
                [switch]$InformationLevel
            )

            try {
                $ping = New-Object System.Net.NetworkInformation.Ping
                $result = $ping.Send($ComputerName)
                return $result.Status -eq 'Success'
            }
            catch {
                return $false
            }
        }
    }
}

# Ensure Write-Information compatibility (added in PS 5.0)
if ($script:PSVersionMajor -lt 5) {
    function Write-Information {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory, Position=0)]
            [string]$MessageData,

            [string[]]$Tags
        )

        # Fallback to Write-Verbose for older versions
        Write-Verbose "INFO: $MessageData"
    }
}

#endregion

#region Core Initialization

<#
.SYNOPSIS
    Initializes the Battle Medic Recovery Suite with comprehensive environment detection.

.DESCRIPTION
    This function performs a complete initialization of the Battle Medic Recovery Suite,
    including environment detection, compatibility checking, prerequisite validation,
    and configuration setup. All initialization steps are idempotent and safe to re-run.

.PARAMETER Config
    Hashtable containing configuration overrides. Any settings not specified will use defaults.

.PARAMETER SkipPrerequisites
    Skip prerequisite checking (not recommended for first run).

.PARAMETER Force
    Force initialization even if environment checks fail.

.EXAMPLE
    Initialize-BattleMedic

    Performs standard initialization with all checks.

.EXAMPLE
    Initialize-BattleMedic -Config @{VerboseLogging = $true; SAIFEnabled = $true} -Force

    Initializes with verbose logging and SAIF compliance, forcing through any warnings.
#>
function Initialize-BattleMedic {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()]
        [hashtable]$Config = @{},

        [Parameter()]
        [switch]$SkipPrerequisites,

        [Parameter()]
        [switch]$Force
    )

    begin {
        $initStart = Get-Date
        Write-Host "`nBattle Medic Recovery Suite v$($script:BattleMedicVersion)" -ForegroundColor Cyan
        Write-Host "=" * 60 -ForegroundColor Gray
        Write-Host "Initializing in PowerShell $($script:PSVersionMajor).$($script:PSVersionMinor)" -ForegroundColor White

        # Create required directories (idempotent)
        @($script:BattleMedicConfig.LogPath, $script:BattleMedicConfig.ConfigPath) | ForEach-Object {
            if ($_ -and -not (Test-Path $_)) {
                try {
                    New-Item -ItemType Directory -Path $_ -Force | Out-Null
                    Write-Verbose "Created directory: $_"
                }
                catch {
                    Write-Warning "Could not create directory: $_ - $_"
                }
            }
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess("Battle Medic Configuration", "Initialize")) {

            # Step 1: Merge configuration (idempotent)
            Write-Host "`n[1/6] Loading configuration..." -ForegroundColor Yellow
            foreach ($key in $Config.Keys) {
                if ($script:BattleMedicConfig.ContainsKey($key)) {
                    $oldValue = $script:BattleMedicConfig[$key]
                    $script:BattleMedicConfig[$key] = $Config[$key]
                    Write-Verbose "Configuration updated: $key = $($Config[$key]) (was: $oldValue)"
                }
            }
            Write-Host "  ✓ Configuration loaded" -ForegroundColor Green

            # Step 2: Detect environment (always runs for accuracy)
            Write-Host "`n[2/6] Detecting environment..." -ForegroundColor Yellow

            # OS Detection
            try {
                if ($script:PSVersionMajor -ge 5) {
                    $os = Get-CimInstance -ClassName Win32_OperatingSystem
                } else {
                    $os = Get-WmiObject -Class Win32_OperatingSystem
                }

                $osVersion = "$($os.Caption) Build $($os.BuildNumber)"
                Write-Host "  OS: $osVersion" -ForegroundColor Gray

                # Windows 10 EOL Check
                if ($os.BuildNumber -lt 19045 -and $os.Caption -like "*Windows 10*") {
                    Write-Warning "  ⚠ Windows 10 version approaching or past EOL"
                }
            }
            catch {
                Write-Warning "Could not detect OS version: $_"
            }

            # Hardware Detection
            try {
                if ($script:PSVersionMajor -ge 5) {
                    $computer = Get-CimInstance -ClassName Win32_ComputerSystem
                } else {
                    $computer = Get-WmiObject -Class Win32_ComputerSystem
                }

                Write-Host "  Hardware: $($computer.Manufacturer) $($computer.Model)" -ForegroundColor Gray

                # Surface Pro 4 Detection
                if ($computer.Model -like "*Surface Pro 4*") {
                    $script:BattleMedicConfig.SP4Mode = $true
                    Write-Host "  ✓ Surface Pro 4 detected - SP4 features enabled" -ForegroundColor Cyan
                }
            }
            catch {
                Write-Warning "Could not detect hardware: $_"
            }

            # WinRE Detection
            if ($env:SystemDrive -ne 'C:' -or (Test-Path 'X:\Windows\System32')) {
                $script:BattleMedicConfig.WinREMode = $true
                Write-Host "  ✓ Windows Recovery Environment detected" -ForegroundColor Cyan
            }

            # Admin Rights Detection
            $isAdmin = $false
            try {
                if ($script:PSVersionMajor -ge 4) {
                    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
                    $principal = New-Object Security.Principal.WindowsPrincipal $identity
                    $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
                } else {
                    # PowerShell 3.0 method
                    $isAdmin = ([Security.Principal.WindowsIdentity]::GetCurrent().Groups -contains 'S-1-5-32-544')
                }
            }
            catch {
                Write-Verbose "Could not determine admin status: $_"
            }

            if ($isAdmin) {
                Write-Host "  ✓ Running with Administrator privileges" -ForegroundColor Green
            } else {
                Write-Warning "  ⚠ Not running as Administrator - some features unavailable"
            }

            # Step 3: Check Prerequisites (unless skipped)
            if (-not $SkipPrerequisites) {
                Write-Host "`n[3/6] Checking prerequisites..." -ForegroundColor Yellow

                $prereqStatus = Test-Prerequisites -Verbose:$VerbosePreference

                if ($prereqStatus.AllPassed) {
                    Write-Host "  ✓ All prerequisites met" -ForegroundColor Green
                } elseif ($prereqStatus.Critical -and -not $Force) {
                    Write-Error "Critical prerequisites missing. Use -Force to override."
                    return
                } else {
                    Write-Warning "  ⚠ Some prerequisites missing - functionality may be limited"
                }
            }

            # Step 4: Validate Environment (idempotent check)
            Write-Host "`n[4/6] Validating environment..." -ForegroundColor Yellow

            $validation = Test-BattleMedicEnvironment

            if ($validation.IsValid) {
                Write-Host "  ✓ Environment validation passed" -ForegroundColor Green
            } elseif (-not $Force) {
                Write-Error "Environment validation failed: $($validation.Errors -join ', ')"
                return
            } else {
                Write-Warning "  ⚠ Environment validation failed but Force flag set"
            }

            # Step 5: Load saved state (for idempotency)
            Write-Host "`n[5/6] Loading saved state..." -ForegroundColor Yellow

            $stateFile = Join-Path $script:BattleMedicConfig.ConfigPath "LastState.json"
            if (Test-Path $stateFile) {
                try {
                    $lastState = Get-Content $stateFile -Raw | ConvertFrom-Json
                    Write-Host "  ✓ Previous state loaded from $(Get-Date $lastState.Timestamp)" -ForegroundColor Green
                    $script:BattleMedicConfig.LastState = $lastState
                }
                catch {
                    Write-Verbose "Could not load previous state: $_"
                }
            } else {
                Write-Host "  → No previous state found (first run)" -ForegroundColor Gray
            }

            # Step 6: Create initialization checkpoint
            if ($script:BattleMedicConfig.AutoBackup -and $isAdmin) {
                Write-Host "`n[6/6] Creating recovery checkpoint..." -ForegroundColor Yellow

                $checkpoint = New-RecoveryCheckpoint -Name "BattleMedic_Init_$(Get-Date -Format 'yyyyMMdd_HHmmss')" -Silent

                if ($checkpoint.Success) {
                    Write-Host "  ✓ Recovery checkpoint created" -ForegroundColor Green
                } else {
                    Write-Warning "  ⚠ Could not create checkpoint: $($checkpoint.Error)"
                }
            }

            # Save current state
            $currentState = @{
                Timestamp = Get-Date
                Version = $script:BattleMedicVersion
                Config = $script:BattleMedicConfig
                Environment = @{
                    OS = $osVersion
                    Hardware = "$($computer.Manufacturer) $($computer.Model)"
                    PSVersion = "$($script:PSVersionMajor).$($script:PSVersionMinor)"
                    IsAdmin = $isAdmin
                    SP4Mode = $script:BattleMedicConfig.SP4Mode
                    WinREMode = $script:BattleMedicConfig.WinREMode
                }
            }

            try {
                $currentState | ConvertTo-Json -Depth 5 | Out-File $stateFile -Force
                Write-Verbose "State saved to $stateFile"
            }
            catch {
                Write-Verbose "Could not save state: $_"
            }

            # Log initialization (SAIF compliant)
            if ($script:BattleMedicConfig.SAIFEnabled) {
                New-SAIFAuditEntry -Action "Initialize" -Result "Success" -Details $currentState
            }

            # Calculate initialization time
            $initDuration = (Get-Date) - $initStart

            # Final summary
            Write-Host "`n" + "=" * 60 -ForegroundColor Gray
            Write-Host "Initialization Complete" -ForegroundColor Green
            Write-Host "  Time: $([Math]::Round($initDuration.TotalSeconds, 2)) seconds"
            Write-Host "  Compatibility Mode: $(if ($script:BattleMedicConfig.CompatibilityMode) { 'Enabled' } else { 'Disabled' })"
            Write-Host "  SP4 Mode: $(if ($script:BattleMedicConfig.SP4Mode) { 'Enabled' } else { 'Disabled' })"
            Write-Host "  SAIF Logging: $(if ($script:BattleMedicConfig.SAIFEnabled) { 'Enabled' } else { 'Disabled' })"
            Write-Host "`nType 'Show-RecoveryMenu' to begin recovery operations" -ForegroundColor Cyan
            Write-Host "Type 'Get-Help about_BattleMedic' for documentation" -ForegroundColor Cyan

            return $currentState
        }
    }
}

<#
.SYNOPSIS
    Tests the Battle Medic environment for compatibility and requirements.

.DESCRIPTION
    Performs comprehensive validation of the system environment to ensure all
    Battle Medic features will function correctly. This function is idempotent
    and can be run multiple times safely.

.EXAMPLE
    Test-BattleMedicEnvironment

    Returns detailed environment validation results.
#>
function Test-BattleMedicEnvironment {
    [CmdletBinding()]
    param()

    $result = @{
        IsValid = $true
        Errors = @()
        Warnings = @()
        SystemInfo = @{}
        Recommendations = @()
    }

    Write-Verbose "Starting environment validation"

    # Check PowerShell version
    if ($script:PSVersionMajor -lt 3) {
        $result.IsValid = $false
        $result.Errors += "PowerShell 3.0 or higher required (current: $($PSVersionTable.PSVersion))"
    } elseif ($script:PSVersionMajor -eq 3) {
        $result.Warnings += "PowerShell 3.0 detected - some features may be limited"
        $result.Recommendations += "Consider upgrading to PowerShell 5.1 or later"
    }

    # Check .NET Framework (required for certain operations)
    try {
        $dotNet = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\" -Name Release -ErrorAction Stop
        $dotNetVersion = switch ($dotNet.Release) {
            { $_ -ge 528040 } { "4.8" }
            { $_ -ge 461808 } { "4.7.2" }
            { $_ -ge 461308 } { "4.7.1" }
            { $_ -ge 460798 } { "4.7" }
            { $_ -ge 394802 } { "4.6.2" }
            { $_ -ge 394254 } { "4.6.1" }
            { $_ -ge 393295 } { "4.6" }
            { $_ -ge 379893 } { "4.5.2" }
            { $_ -ge 378675 } { "4.5.1" }
            { $_ -ge 378389 } { "4.5" }
            default { "Unknown" }
        }
        $result.SystemInfo.DotNetVersion = $dotNetVersion
        Write-Verbose ".NET Framework version: $dotNetVersion"
    }
    catch {
        $result.Warnings += ".NET Framework version could not be determined"
    }

    # Check administrative privileges
    $isAdmin = $false
    try {
        if ($script:PSVersionMajor -ge 4) {
            $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
            $principal = New-Object Security.Principal.WindowsPrincipal $identity
            $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        } else {
            $isAdmin = ([Security.Principal.WindowsIdentity]::GetCurrent().Groups -contains 'S-1-5-32-544')
        }
    }
    catch {
        Write-Verbose "Could not determine admin status: $_"
    }

    $result.SystemInfo.IsAdmin = $isAdmin
    if (-not $isAdmin) {
        $result.Warnings += "Not running as Administrator - recovery functions limited"
        $result.Recommendations += "Run PowerShell as Administrator for full functionality"
    }

    # Check disk space
    try {
        $systemDrive = Get-PSDrive -Name ($env:SystemDrive -replace ':', '') -ErrorAction Stop
        $freeGB = [Math]::Round($systemDrive.Free / 1GB, 2)
        $result.SystemInfo.FreeSpaceGB = $freeGB

        if ($freeGB -lt 1) {
            $result.IsValid = $false
            $result.Errors += "Critical: Less than 1GB free space"
        } elseif ($freeGB -lt 5) {
            $result.Warnings += "Low disk space: ${freeGB}GB free"
            $result.Recommendations += "Free up disk space for optimal performance"
        }
    }
    catch {
        $result.Warnings += "Could not determine disk space"
    }

    # Check WMI/CIM availability (critical for diagnostics)
    try {
        if ($script:PSVersionMajor -ge 5) {
            $null = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
        } else {
            $null = Get-WmiObject -Class Win32_OperatingSystem -ErrorAction Stop
        }
        $result.SystemInfo.WMIAvailable = $true
    }
    catch {
        $result.IsValid = $false
        $result.Errors += "WMI/CIM not available - required for diagnostics"
        $result.SystemInfo.WMIAvailable = $false
    }

    # Check battery for mobile devices (non-critical)
    try {
        if ($script:PSVersionMajor -ge 5) {
            $battery = Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue
        } else {
            $battery = Get-WmiObject -Class Win32_Battery -ErrorAction SilentlyContinue
        }

        if ($battery) {
            $result.SystemInfo.BatteryPresent = $true
            $result.SystemInfo.BatteryLevel = $battery.EstimatedChargeRemaining

            if ($battery.EstimatedChargeRemaining -lt 30 -and $battery.BatteryStatus -eq 1) {
                $result.Warnings += "Low battery: $($battery.EstimatedChargeRemaining)%"
                $result.Recommendations += "Connect AC adapter before running recovery operations"
            }
        }
    }
    catch {
        Write-Verbose "Could not check battery status"
    }

    # Check for WinRE availability
    if (Test-Path "$env:windir\System32\Recovery\winre.wim") {
        $result.SystemInfo.WinREAvailable = $true
    } else {
        $result.SystemInfo.WinREAvailable = $false
        $result.Warnings += "Windows Recovery Environment not found"
    }

    # Check for critical Windows services
    $criticalServices = @('winmgmt', 'RpcSs', 'EventLog')
    foreach ($service in $criticalServices) {
        try {
            $svc = Get-Service -Name $service -ErrorAction Stop
            if ($svc.Status -ne 'Running') {
                $result.Warnings += "Critical service not running: $service"
            }
        }
        catch {
            $result.Errors += "Critical service not found: $service"
        }
    }

    return [PSCustomObject]$result
}

<#
.SYNOPSIS
    Tests prerequisites for Battle Medic operations.

.DESCRIPTION
    Checks for required and optional components, returning detailed status.
    This function helps identify what features will be available.

.EXAMPLE
    Test-Prerequisites

    Returns prerequisite check results.
#>
function Test-Prerequisites {
    [CmdletBinding()]
    param()

    $results = @{
        AllPassed = $true
        Critical = $false
        Required = @{}
        Optional = @{}
    }

    # Required components
    $required = @{
        'PowerShell' = { $PSVersionTable.PSVersion.Major -ge 3 }
        'WMI' = { Get-Service winmgmt -ErrorAction SilentlyContinue }
        'SystemDrive' = { Test-Path $env:SystemDrive }
    }

    foreach ($item in $required.GetEnumerator()) {
        try {
            $results.Required[$item.Key] = & $item.Value
            if (-not $results.Required[$item.Key]) {
                $results.AllPassed = $false
                $results.Critical = $true
            }
        }
        catch {
            $results.Required[$item.Key] = $false
            $results.AllPassed = $false
            $results.Critical = $true
        }
    }

    # Optional components
    $optional = @{
        'DISM' = { Get-Command dism -ErrorAction SilentlyContinue }
        'SFC' = { Get-Command sfc -ErrorAction SilentlyContinue }
        'BCDEdit' = { Get-Command bcdedit -ErrorAction SilentlyContinue }
        'SystemRestore' = { Get-Command Checkpoint-Computer -ErrorAction SilentlyContinue }
        'BitLocker' = { Get-Command Get-BitLockerVolume -ErrorAction SilentlyContinue }
    }

    foreach ($item in $optional.GetEnumerator()) {
        try {
            $results.Optional[$item.Key] = if (& $item.Value) { $true } else { $false }
            if (-not $results.Optional[$item.Key]) {
                $results.AllPassed = $false
            }
        }
        catch {
            $results.Optional[$item.Key] = $false
            $results.AllPassed = $false
        }
    }

    return [PSCustomObject]$results
}

#endregion

#region SAIF Compliance Functions

<#
.SYNOPSIS
    Creates a SAIF-compliant audit log entry.

.DESCRIPTION
    Logs actions in Security Automation and Integration Framework format
    for compliance and audit trail purposes.

.PARAMETER Action
    The action being performed.

.PARAMETER Result
    The result of the action (Success/Failure/Warning).

.PARAMETER Details
    Additional details about the action.

.EXAMPLE
    New-SAIFAuditEntry -Action "WOF Repair" -Result "Success" -Details @{Duration="120s"}
#>
function New-SAIFAuditEntry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Action,

        [Parameter(Mandatory)]
        [ValidateSet('Success', 'Failure', 'Warning', 'Info')]
        [string]$Result,

        [Parameter()]
        [object]$Details
    )

    if (-not $script:BattleMedicConfig.SAIFEnabled) {
        return
    }

    $entry = @{
        Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffZ"
        Version = "SAIF-1.0"
        Component = "BattleMedic"
        ComponentVersion = $script:BattleMedicVersion
        Action = $Action
        Result = $Result
        User = $env:USERNAME
        Computer = $env:COMPUTERNAME
        ProcessId = $PID
        SessionId = [Guid]::NewGuid().ToString()
    }

    if ($Details) {
        $entry.Details = $Details
    }

    # Add environment context
    $entry.Environment = @{
        PowerShellVersion = "$($script:PSVersionMajor).$($script:PSVersionMinor)"
        OSVersion = [System.Environment]::OSVersion.VersionString
        IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }

    # Write to SAIF log file
    $logFile = Join-Path $script:BattleMedicConfig.LogPath "SAIF_$(Get-Date -Format 'yyyyMMdd').json"

    try {
        $jsonEntry = $entry | ConvertTo-Json -Depth 10 -Compress
        Add-Content -Path $logFile -Value $jsonEntry -Encoding UTF8
        Write-Verbose "SAIF audit entry created: $Action - $Result"
    }
    catch {
        Write-Warning "Could not write SAIF audit entry: $_"
    }
}

#endregion

#region Module Functions Export Wrapper

# Wrapper function for idempotent operations
function Invoke-IdempotentOperation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [scriptblock]$Operation,

        [Parameter(Mandatory)]
        [string]$OperationName,

        [Parameter()]
        [scriptblock]$StateCheck,

        [Parameter()]
        [scriptblock]$Rollback
    )

    Write-Verbose "Starting idempotent operation: $OperationName"

    # Check current state if provided
    if ($StateCheck) {
        $needsExecution = -not (& $StateCheck)

        if (-not $needsExecution) {
            Write-Verbose "$OperationName already in desired state - skipping"
            return @{
                Success = $true
                Skipped = $true
                Message = "Already in desired state"
            }
        }
    }

    # Execute operation
    try {
        $result = & $Operation

        # Log success
        if ($script:BattleMedicConfig.SAIFEnabled) {
            New-SAIFAuditEntry -Action $OperationName -Result "Success" -Details $result
        }

        return @{
            Success = $true
            Skipped = $false
            Result = $result
        }
    }
    catch {
        Write-Error "Operation failed: $_"

        # Attempt rollback if provided
        if ($Rollback) {
            try {
                Write-Warning "Attempting rollback for $OperationName"
                & $Rollback
                Write-Warning "Rollback completed"
            }
            catch {
                Write-Error "Rollback failed: $_"
            }
        }

        # Log failure
        if ($script:BattleMedicConfig.SAIFEnabled) {
            New-SAIFAuditEntry -Action $OperationName -Result "Failure" -Details @{Error = $_.Exception.Message}
        }

        return @{
            Success = $false
            Skipped = $false
            Error = $_.Exception.Message
        }
    }
}

#endregion

#region Module Metadata Functions

<#
.SYNOPSIS
    Gets the current Battle Medic version and build information.
#>
function Get-BattleMedicVersion {
    [CmdletBinding()]
    param()

    return [PSCustomObject]@{
        Version = $script:BattleMedicVersion
        PowerShellVersion = "$($script:PSVersionMajor).$($script:PSVersionMinor)"
        CompatibilityMode = $script:BattleMedicConfig.CompatibilityMode
        SP4Mode = $script:BattleMedicConfig.SP4Mode
        SAIFEnabled = $script:BattleMedicConfig.SAIFEnabled
        ConfigPath = $script:BattleMedicConfig.ConfigPath
        LogPath = $script:BattleMedicConfig.LogPath
    }
}

<#
.SYNOPSIS
    Gets the current Battle Medic configuration.
#>
function Get-BattleMedicConfig {
    [CmdletBinding()]
    param()

    return $script:BattleMedicConfig
}

<#
.SYNOPSIS
    Sets Battle Medic configuration values.
#>
function Set-BattleMedicConfig {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Config
    )

    if ($PSCmdlet.ShouldProcess("Battle Medic Configuration", "Update")) {
        foreach ($key in $Config.Keys) {
            if ($script:BattleMedicConfig.ContainsKey($key)) {
                $script:BattleMedicConfig[$key] = $Config[$key]
                Write-Verbose "Updated config: $key = $($Config[$key])"
            } else {
                Write-Warning "Unknown configuration key: $key"
            }
        }

        # Save configuration
        $configFile = Join-Path $script:BattleMedicConfig.ConfigPath "Config.json"
        try {
            $script:BattleMedicConfig | ConvertTo-Json -Depth 5 | Out-File $configFile -Force
            Write-Verbose "Configuration saved to $configFile"
        }
        catch {
            Write-Warning "Could not save configuration: $_"
        }
    }
}

#endregion

#region Module Aliases

New-Alias -Name 'bmr' -Value 'Start-BattleMedicRecovery' -Force -ErrorAction SilentlyContinue
New-Alias -Name 'bmdiag' -Value 'Get-BattleMedicDiagnostic' -Force -ErrorAction SilentlyContinue
New-Alias -Name 'bmlog' -Value 'Get-BattleMedicLog' -Force -ErrorAction SilentlyContinue
New-Alias -Name 'bmhelp' -Value 'Get-BattleMedicHelp' -Force -ErrorAction SilentlyContinue
New-Alias -Name 'sp4fix' -Value 'Start-SP4Recovery' -Force -ErrorAction SilentlyContinue
New-Alias -Name 'woffix' -Value 'Repair-WOFDriver' -Force -ErrorAction SilentlyContinue
New-Alias -Name 'bmcheck' -Value 'Test-BattleMedicEnvironment' -Force -ErrorAction SilentlyContinue
New-Alias -Name 'bminit' -Value 'Initialize-BattleMedic' -Force -ErrorAction SilentlyContinue

#endregion

#region Module Cleanup

$ExecutionContext.SessionState.Module.OnRemove = {
    Write-Verbose "Unloading Battle Medic Recovery Suite"

    # Save final state
    if ($script:BattleMedicConfig.AutoBackup) {
        $stateFile = Join-Path $script:BattleMedicConfig.ConfigPath "LastState.json"
        @{
            Timestamp = Get-Date
            Version = $script:BattleMedicVersion
            Config = $script:BattleMedicConfig
            CleanShutdown = $true
        } | ConvertTo-Json -Depth 5 | Out-File $stateFile -Force
    }

    # Clean up temporary files
    if (Test-Path $env:TEMP) {
        Get-ChildItem -Path $env:TEMP -Filter 'BattleMedic_Temp_*' -ErrorAction SilentlyContinue |
            Remove-Item -Force -ErrorAction SilentlyContinue
    }

    # Final SAIF audit entry
    if ($script:BattleMedicConfig.SAIFEnabled) {
        New-SAIFAuditEntry -Action "Module Unload" -Result "Success" -Details @{CleanShutdown = $true}
    }
}

#endregion

# Display load message (can be suppressed with -Silent)
if (-not $Silent) {
    Write-Host "`nBattle Medic Recovery Suite v$($script:BattleMedicVersion) loaded" -ForegroundColor Green

    if ($script:BattleMedicConfig.CompatibilityMode) {
        Write-Host "Compatibility mode enabled for PowerShell $($script:PSVersionMajor).$($script:PSVersionMinor)" -ForegroundColor Yellow
    }

    if ($script:BattleMedicConfig.SP4Mode) {
        Write-Host "Surface Pro 4 detected - enhanced features enabled" -ForegroundColor Cyan
    }

    Write-Host "`nQuick Start:" -ForegroundColor White
    Write-Host "  Initialize-BattleMedic    # First time setup" -ForegroundColor Gray
    Write-Host "  Show-RecoveryMenu         # Interactive recovery" -ForegroundColor Gray
    Write-Host "  Get-Help about_BattleMedic # Full documentation" -ForegroundColor Gray
}
