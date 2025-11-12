#Requires -Version 5.1
<#
.SYNOPSIS
    KENL Core Module - Cross-platform gaming and development infrastructure

.DESCRIPTION
    Core KENL module providing platform detection, ATOM trail integration,
    and foundational functionality for policy-as-code infrastructure.

    This module translates KENL bash functionality to PowerShell with the
    same elegance and governance principles.

.NOTES
    File Name      : KENL.psm1
    Author         : KENL Framework
    Prerequisite   : PowerShell 5.1+
    Version        : 1.0.0
    ATOM           : ATOM-PWSH-20251110-001

.LINK
    https://github.com/toolate28/kenl
#>

#region Module Variables

$script:KenlModuleRoot = $PSScriptRoot
$script:KenlConfigPath = Join-Path $env:USERPROFILE ".kenl"
$script:AtomTrailPath = Join-Path $script:KenlConfigPath "atom_trail.log"

# Module version
$script:KenlVersion = "1.0.0"

#endregion

#region Platform Detection

<#
.SYNOPSIS
    Detects the current platform (Windows, WSL2, or Linux)

.DESCRIPTION
    Identifies the execution environment to determine which commands
    and configurations to use.

.OUTPUTS
    PSCustomObject with platform details

.EXAMPLE
    Get-KenlPlatform
#>
function Get-KenlPlatform {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    $platform = [PSCustomObject]@{
        Type = "Unknown"
        IsWindows = $false
        IsWSL2 = $false
        IsLinux = $false
        IsBazzite = $false
        OSVersion = ""
        Architecture = if ([System.Environment]::Is64BitOperatingSystem) { "x64" } else { "x86" }
        HasSystemd = $false
        HasRpmOstree = $false
    }

    # Determine platform type
    if ($IsWindows -or $env:OS -eq "Windows_NT") {
        $platform.Type = "Windows"
        $platform.IsWindows = $true
        $platform.OSVersion = [System.Environment]::OSVersion.Version.ToString()

        # Check if running under WSL2 (PowerShell can run in WSL2)
        if (Test-Path "/proc/sys/fs/binfmt_misc/WSLInterop" -ErrorAction SilentlyContinue) {
            $platform.Type = "WSL2"
            $platform.IsWSL2 = $true
        }
    }
    elseif ($IsLinux) {
        $platform.IsLinux = $true

        # Check for WSL2
        if (Test-Path "/proc/sys/fs/binfmt_misc/WSLInterop") {
            $platform.Type = "WSL2"
            $platform.IsWSL2 = $true
        }
        else {
            $platform.Type = "Linux"

            # Check if Bazzite
            if (Test-Path "/etc/os-release") {
                $osRelease = Get-Content "/etc/os-release" | ConvertFrom-StringData
                if ($osRelease.ID -eq "bazzite") {
                    $platform.Type = "Bazzite"
                    $platform.IsBazzite = $true
                }
            }
        }

        # Check for systemd
        $platform.HasSystemd = (Get-Command systemctl -ErrorAction SilentlyContinue) -ne $null

        # Check for rpm-ostree
        $platform.HasRpmOstree = (Get-Command rpm-ostree -ErrorAction SilentlyContinue) -ne $null
    }

    return $platform
}

<#
.SYNOPSIS
    Tests if running on specified platform

.PARAMETER Platform
    Platform type to test for (Windows, WSL2, Linux, Bazzite)

.EXAMPLE
    Test-KenlPlatform -Platform Windows
#>
function Test-KenlPlatform {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [ValidateSet("Windows", "WSL2", "Linux", "Bazzite")]
        [string]$Platform
    )

    $current = Get-KenlPlatform
    return $current.Type -eq $Platform
}

#endregion

#region ATOM Trail Integration

<#
.SYNOPSIS
    Writes an entry to the ATOM audit trail

.DESCRIPTION
    Logs an action to the ATOM trail with timestamp, tag, and description.
    Provides cryptographic-grade audit trail for all infrastructure changes.

.PARAMETER Tag
    ATOM tag (e.g., ATOM-CFG-20251110-001)

.PARAMETER Action
    Description of the action performed

.PARAMETER Type
    Type of ATOM tag (MCP, SAGE, CFG, DEPLOY, TASK, RESEARCH, STATUS, PWSH)

.EXAMPLE
    Write-AtomTrail -Tag "ATOM-PWSH-20251110-001" -Action "Network optimization applied"

.EXAMPLE
    Write-AtomTrail -Type PWSH -Action "Created Play Card for Halo Infinite"
#>
function Write-AtomTrail {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Tag,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Action,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet("MCP", "SAGE", "CFG", "DEPLOY", "TASK", "RESEARCH", "STATUS", "PWSH", "NETWORK", "GAMING")]
        [string]$Type = "PWSH"
    )

    begin {
        # Ensure KENL config directory exists
        if (-not (Test-Path $script:KenlConfigPath)) {
            New-Item -Path $script:KenlConfigPath -ItemType Directory -Force | Out-Null
        }
    }

    process {
        # Generate ATOM tag if not provided
        if (-not $Tag) {
            $timestamp = Get-Date -Format "yyyyMMdd"
            $counter = 1

            # Find next available counter
            if (Test-Path $script:AtomTrailPath) {
                $existingTags = Select-String -Path $script:AtomTrailPath -Pattern "ATOM-$Type-$timestamp-(\d+)" -AllMatches
                if ($existingTags) {
                    $counters = $existingTags.Matches | ForEach-Object { [int]$_.Groups[1].Value }
                    $counter = ($counters | Measure-Object -Maximum).Maximum + 1
                }
            }

            $Tag = "ATOM-$Type-$timestamp-{0:D3}" -f $counter
        }

        # Create ATOM entry
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $platform = (Get-KenlPlatform).Type
        $entry = "[{0}] [{1}] [{2}] {3}" -f $timestamp, $Tag, $platform, $Action

        if ($PSCmdlet.ShouldProcess($script:AtomTrailPath, "Write ATOM trail entry")) {
            Add-Content -Path $script:AtomTrailPath -Value $entry

            Write-Verbose "ATOM trail entry written: $Tag"

            # Return the tag for chaining
            return [PSCustomObject]@{
                Tag = $Tag
                Timestamp = $timestamp
                Platform = $platform
                Action = $Action
            }
        }
    }
}

<#
.SYNOPSIS
    Reads ATOM trail entries

.PARAMETER Tag
    Filter by specific ATOM tag

.PARAMETER Type
    Filter by ATOM type

.PARAMETER Last
    Return only the last N entries

.EXAMPLE
    Get-AtomTrail -Last 10

.EXAMPLE
    Get-AtomTrail -Type PWSH
#>
function Get-AtomTrail {
    [CmdletBinding()]
    param(
        [string]$Tag,

        [ValidateSet("MCP", "SAGE", "CFG", "DEPLOY", "TASK", "RESEARCH", "STATUS", "PWSH", "NETWORK", "GAMING")]
        [string]$Type,

        [int]$Last
    )

    if (-not (Test-Path $script:AtomTrailPath)) {
        Write-Warning "ATOM trail not found at: $script:AtomTrailPath"
        return
    }

    $entries = Get-Content $script:AtomTrailPath

    # Parse entries
    $parsed = $entries | ForEach-Object {
        if ($_ -match '^\[(.*?)\] \[(.*?)\] \[(.*?)\] (.*)$') {
            [PSCustomObject]@{
                Timestamp = [datetime]::Parse($Matches[1])
                Tag = $Matches[2]
                Platform = $Matches[3]
                Action = $Matches[4]
            }
        }
    }

    # Apply filters
    if ($Tag) {
        $parsed = $parsed | Where-Object { $_.Tag -eq $Tag }
    }

    if ($Type) {
        $parsed = $parsed | Where-Object { $_.Tag -like "ATOM-$Type-*" }
    }

    if ($Last) {
        $parsed = $parsed | Select-Object -Last $Last
    }

    return $parsed
}

#endregion

#region Configuration Management

<#
.SYNOPSIS
    Loads a KENL YAML configuration file

.DESCRIPTION
    Reads and parses YAML configuration files used by KENL modules.
    Requires PowerShell-Yaml module (install: Install-Module powershell-yaml)

.PARAMETER Path
    Path to YAML configuration file

.PARAMETER UseBuiltInParser
    Use simple built-in parser instead of PowerShell-Yaml module

.EXAMPLE
    Get-KenlConfig -Path "configs/hardware-profiles/ryzen5-5600h-vega.yaml"
#>
function Get-KenlConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [switch]$UseBuiltInParser
    )

    if (-not (Test-Path $Path)) {
        throw "Configuration file not found: $Path"
    }

    # Try to use PowerShell-Yaml module
    $yamlModule = Get-Module -ListAvailable -Name powershell-yaml

    if ($yamlModule -and -not $UseBuiltInParser) {
        Import-Module powershell-yaml -ErrorAction Stop
        $content = Get-Content -Path $Path -Raw
        return ConvertFrom-Yaml $content
    }
    else {
        # Simple YAML parser for basic configs
        Write-Warning "PowerShell-Yaml module not found. Using simple parser."
        Write-Warning "Install with: Install-Module powershell-yaml -Scope CurrentUser"

        $content = Get-Content -Path $Path
        $config = @{}

        # Very basic YAML parsing (key: value)
        foreach ($line in $content) {
            if ($line -match '^\s*([^#:]+):\s*(.+)$') {
                $key = $Matches[1].Trim()
                $value = $Matches[2].Trim()
                $config[$key] = $value
            }
        }

        return $config
    }
}

<#
.SYNOPSIS
    Saves a PowerShell object as YAML configuration

.PARAMETER Path
    Path to save YAML file

.PARAMETER InputObject
    Object to convert to YAML

.EXAMPLE
    $config | Set-KenlConfig -Path "config.yaml"
#>
function Set-KenlConfig {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )

    process {
        # Try to use PowerShell-Yaml module
        $yamlModule = Get-Module -ListAvailable -Name powershell-yaml

        if ($yamlModule) {
            Import-Module powershell-yaml -ErrorAction Stop
            $yaml = ConvertTo-Yaml $InputObject

            if ($PSCmdlet.ShouldProcess($Path, "Save YAML configuration")) {
                Set-Content -Path $Path -Value $yaml
            }
        }
        else {
            throw "PowerShell-Yaml module required. Install with: Install-Module powershell-yaml -Scope CurrentUser"
        }
    }
}

#endregion

#region Utility Functions

<#
.SYNOPSIS
    Invokes a command with platform-specific handling

.DESCRIPTION
    Executes commands differently based on platform (Windows, WSL2, Linux)

.PARAMETER WindowsCommand
    Command to run on Windows

.PARAMETER LinuxCommand
    Command to run on Linux/WSL2

.PARAMETER UseWSL
    Force execution through WSL even on Windows

.EXAMPLE
    Invoke-KenlCommand -WindowsCommand "netsh interface show interface" -LinuxCommand "ip link show"
#>
function Invoke-KenlCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$WindowsCommand,

        [Parameter(Mandatory)]
        [string]$LinuxCommand,

        [switch]$UseWSL
    )

    $platform = Get-KenlPlatform

    if ($platform.IsWindows -and -not $UseWSL) {
        # Execute Windows command
        Invoke-Expression $WindowsCommand
    }
    elseif ($platform.IsWindows -and $UseWSL) {
        # Execute Linux command through WSL
        wsl bash -c $LinuxCommand
    }
    else {
        # Execute Linux command natively
        Invoke-Expression $LinuxCommand
    }
}

<#
.SYNOPSIS
    Tests if running with administrator/root privileges

.OUTPUTS
    Boolean indicating elevated status

.EXAMPLE
    Test-KenlElevated
#>
function Test-KenlElevated {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    $platform = Get-KenlPlatform

    if ($platform.IsWindows) {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($identity)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    else {
        # Check for root on Linux
        return (id -u) -eq 0
    }
}

<#
.SYNOPSIS
    Formats output with color coding

.PARAMETER Message
    Message to display

.PARAMETER Type
    Message type (Info, Success, Warning, Error, Highlight)

.EXAMPLE
    Write-KenlMessage "Optimization complete!" -Type Success
#>
function Write-KenlMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Message,

        [ValidateSet("Info", "Success", "Warning", "Error", "Highlight", "Debug")]
        [string]$Type = "Info"
    )

    $colors = @{
        Info = "Cyan"
        Success = "Green"
        Warning = "Yellow"
        Error = "Red"
        Highlight = "Magenta"
        Debug = "DarkGray"
    }

    $prefix = @{
        Info = "[i]"
        Success = "[OK]"
        Warning = "[!]"
        Error = "[X]"
        Highlight = "[*]"
        Debug = "[D]"
    }

    Write-Host "$($prefix[$Type]) " -ForegroundColor $colors[$Type] -NoNewline
    Write-Host $Message
}

<#
.SYNOPSIS
    Gets KENL module information

.EXAMPLE
    Get-KenlInfo
#>
function Get-KenlInfo {
    [CmdletBinding()]
    param()

    $platform = Get-KenlPlatform

    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                 KENL Framework v$script:KenlVersion                ║" -ForegroundColor Cyan
    Write-Host "║         Gaming & Development Infrastructure                ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Platform:        " -NoNewline
    Write-Host $platform.Type -ForegroundColor Green

    Write-Host "OS Version:      " -NoNewline
    Write-Host $platform.OSVersion

    Write-Host "Architecture:    " -NoNewline
    Write-Host $platform.Architecture

    Write-Host "Elevated:        " -NoNewline
    $elevated = Test-KenlElevated
    Write-Host $elevated -ForegroundColor $(if ($elevated) { "Green" } else { "Yellow" })

    if ($platform.IsLinux) {
        Write-Host "systemd:         " -NoNewline
        Write-Host $platform.HasSystemd

        Write-Host "rpm-ostree:      " -NoNewline
        Write-Host $platform.HasRpmOstree
    }

    Write-Host ""
    Write-Host "Config Path:     " -NoNewline
    Write-Host $script:KenlConfigPath -ForegroundColor Gray

    Write-Host "ATOM Trail:      " -NoNewline
    $atomExists = Test-Path $script:AtomTrailPath
    Write-Host $(if ($atomExists) { "Found" } else { "Not initialized" }) -ForegroundColor $(if ($atomExists) { "Green" } else { "Yellow" })

    if ($atomExists) {
        $entryCount = (Get-Content $script:AtomTrailPath).Count
        Write-Host "  Entries:       $entryCount"
    }

    Write-Host ""
    Write-Host "Available Modules:" -ForegroundColor Cyan

    $modules = @("KENL.Gaming", "KENL.Network", "KENL.System")
    foreach ($module in $modules) {
        $loaded = Get-Module $module -ErrorAction SilentlyContinue
        Write-Host "  $module" -NoNewline
        if ($loaded) {
            Write-Host " [Loaded]" -ForegroundColor Green
        }
        else {
            Write-Host " [Available]" -ForegroundColor Gray
        }
    }

    Write-Host ""
}

#endregion

#region Module Initialization

<#
.SYNOPSIS
    Initializes KENL framework on the system

.DESCRIPTION
    Sets up KENL configuration directory, initializes ATOM trail,
    and performs platform-specific setup.

.EXAMPLE
    Initialize-Kenl
#>
function Initialize-Kenl {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    Write-KenlMessage "Initializing KENL framework..." -Type Info

    # Create config directory
    if (-not (Test-Path $script:KenlConfigPath)) {
        if ($PSCmdlet.ShouldProcess($script:KenlConfigPath, "Create KENL config directory")) {
            New-Item -Path $script:KenlConfigPath -ItemType Directory -Force | Out-Null
            Write-KenlMessage "Created config directory: $script:KenlConfigPath" -Type Success
        }
    }

    # Initialize ATOM trail
    if (-not (Test-Path $script:AtomTrailPath)) {
        if ($PSCmdlet.ShouldProcess($script:AtomTrailPath, "Initialize ATOM trail")) {
            $header = @"
# KENL ATOM Trail
# Cryptographic-grade audit trail for infrastructure changes
# Format: [timestamp] [ATOM-TAG] [platform] action
# Initialized: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@
            Set-Content -Path $script:AtomTrailPath -Value $header
            Write-KenlMessage "Initialized ATOM trail" -Type Success
        }
    }

    # Log initialization
    Write-AtomTrail -Type PWSH -Action "KENL framework initialized"

    # Platform-specific setup
    $platform = Get-KenlPlatform

    if ($platform.IsWindows) {
        Write-KenlMessage "Platform: Windows" -Type Info
        Write-KenlMessage "Checking for WSL2..." -Type Info

        $wslInstalled = Get-Command wsl -ErrorAction SilentlyContinue
        if ($wslInstalled) {
            Write-KenlMessage "WSL2 available" -Type Success
        }
        else {
            Write-KenlMessage "WSL2 not found (optional for cross-platform testing)" -Type Warning
        }
    }
    elseif ($platform.IsWSL2) {
        Write-KenlMessage "Platform: WSL2" -Type Info
    }
    elseif ($platform.IsBazzite) {
        Write-KenlMessage "Platform: Bazzite (full KENL support)" -Type Success
    }

    Write-KenlMessage "Initialization complete!" -Type Success
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Import modules: Import-Module KENL.Gaming, KENL.Network, KENL.System"
    Write-Host "  2. View info: Get-KenlInfo"
    Write-Host "  3. Check documentation in modules/KENL*-*/README.md"
    Write-Host ""
}

#endregion

#region Export

# Export functions
Export-ModuleMember -Function @(
    # Platform
    'Get-KenlPlatform',
    'Test-KenlPlatform',

    # ATOM Trail
    'Write-AtomTrail',
    'Get-AtomTrail',

    # Configuration
    'Get-KenlConfig',
    'Set-KenlConfig',

    # Utility
    'Invoke-KenlCommand',
    'Test-KenlElevated',
    'Write-KenlMessage',
    'Get-KenlInfo',

    # Initialization
    'Initialize-Kenl'
)

# Export module variables
Export-ModuleMember -Variable @(
    'KenlModuleRoot',
    'KenlConfigPath',
    'AtomTrailPath',
    'KenlVersion'
)

#endregion

# Module initialization message
if ($MyInvocation.InvocationName -ne '.') {
    Write-Host "KENL Core Module loaded (v$script:KenlVersion)" -ForegroundColor Cyan
    Write-Host "Run 'Initialize-Kenl' to set up the framework" -ForegroundColor Gray
    Write-Host "Run 'Get-KenlInfo' for platform information" -ForegroundColor Gray
}
