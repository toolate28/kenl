#Requires -Version 5.1

<#
.SYNOPSIS
    KENL ATOM Trail Logger - JSON Format

.DESCRIPTION
    Writes ATOM-tagged JSON entries to unified trail for Logdy ingestion and AI analysis.
    JSON format enables:
    - Native AI parsing (Claude, Qwen, etc.)
    - Logdy column auto-detection
    - Structured queries via jq/PowerShell
    - MCP integration

.NOTES
    Author    : KENL Framework
    Version   : 2.0.0 (JSON format)
    ATOM      : ATOM-CFG-20251117-001
#>

# Module-level variables
$script:AtomTrailPath = "$env:USERPROFILE\.kenl\.atom-trail.json"
$script:AtomCounterPath = "$env:USERPROFILE\.kenl\.atom-counter"

function Write-AtomLog {
    <#
    .SYNOPSIS
        Writes ATOM-tagged JSON entry to trail

    .DESCRIPTION
        Creates a structured JSON log entry with ATOM tag, timestamp, and metadata.
        Automatically increments counter and appends to trail file.

    .PARAMETER Type
        ATOM type (CFG, DEPLOY, TASK, TEST, etc.)

    .PARAMETER Message
        Human-readable message describing the event

    .PARAMETER Context
        Additional context as hashtable (user, host, PID, etc.)

    .PARAMETER Severity
        Log severity (INFO, WARNING, ERROR, CRITICAL)

    .EXAMPLE
        Write-AtomLog -Type "CFG" -Message "Logdy started on port 8081"

    .EXAMPLE
        Write-AtomLog -Type "DEPLOY" -Message "Bazzite installed" -Context @{duration="45min"}

    .EXAMPLE
        $tag = Write-AtomLog -Type "TEST" -Message "Network test passed"
        # Returns: ATOM-TEST-20251117-001
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('CFG', 'DEPLOY', 'TASK', 'TEST', 'FIX', 'DOC', 'SEC', 'NET', 'SYS',
                     'APP', 'GAMING', 'DEV', 'IWI', 'MONITORING', 'STATUS', 'RESEARCH')]
        [string]$Type,

        [Parameter(Mandatory)]
        [string]$Message,

        [hashtable]$Context = @{},

        [ValidateSet('INFO', 'WARNING', 'ERROR', 'CRITICAL')]
        [string]$Severity = 'INFO'
    )

    # Ensure directory exists
    $trailDir = Split-Path $script:AtomTrailPath
    if (-not (Test-Path $trailDir)) {
        New-Item -ItemType Directory -Path $trailDir -Force | Out-Null
    }

    # Get or initialize counter
    $counter = if (Test-Path $script:AtomCounterPath) {
        [int](Get-Content $script:AtomCounterPath)
    } else {
        1
    }

    # Generate ATOM tag
    $atomTag = "ATOM-$Type-$(Get-Date -Format 'yyyyMMdd')-$('{0:D3}' -f $counter)"

    # Build context with system metadata
    $enrichedContext = $Context + @{
        computer = $env:COMPUTERNAME
        user = $env:USERNAME
        process_id = $PID
        powershell_version = $PSVersionTable.PSVersion.ToString()
    }

    # Create JSON entry
    $entry = [PSCustomObject]@{
        timestamp = (Get-Date -Format "o")  # ISO 8601
        atom_tag = $atomTag
        atom_type = $Type
        severity = $Severity
        message = $Message
        context = $enrichedContext
    } | ConvertTo-Json -Compress

    # Append to trail (UTF8 for cross-platform compatibility)
    Add-Content -Path $script:AtomTrailPath -Value $entry -Encoding UTF8

    # Increment counter
    ($counter + 1) | Set-Content $script:AtomCounterPath

    # Return tag for SAIF compliance
    Write-Verbose "ATOM entry created: $atomTag"
    return $atomTag
}

function Get-AtomTrail {
    <#
    .SYNOPSIS
        Retrieves ATOM trail entries

    .DESCRIPTION
        Reads and parses JSON ATOM trail entries with filtering options

    .PARAMETER Last
        Return last N entries

    .PARAMETER Type
        Filter by ATOM type (CFG, DEPLOY, etc.)

    .PARAMETER Since
        Filter by date (e.g., "2025-11-17")

    .PARAMETER Severity
        Filter by severity level

    .EXAMPLE
        Get-AtomTrail -Last 10

    .EXAMPLE
        Get-AtomTrail -Type "CFG" -Since "2025-11-17"

    .EXAMPLE
        Get-AtomTrail -Severity "ERROR"
    #>
    [CmdletBinding()]
    param(
        [int]$Last,

        [ValidateSet('CFG', 'DEPLOY', 'TASK', 'TEST', 'FIX', 'DOC', 'SEC', 'NET', 'SYS',
                     'APP', 'GAMING', 'DEV', 'IWI', 'MONITORING', 'STATUS', 'RESEARCH')]
        [string]$Type,

        [datetime]$Since,

        [ValidateSet('INFO', 'WARNING', 'ERROR', 'CRITICAL')]
        [string]$Severity
    )

    if (-not (Test-Path $script:AtomTrailPath)) {
        Write-Warning "ATOM trail not found: $script:AtomTrailPath"
        return @()
    }

    # Read all entries
    $entries = Get-Content $script:AtomTrailPath | ForEach-Object {
        $_ | ConvertFrom-Json
    }

    # Apply filters
    if ($Type) {
        $entries = $entries | Where-Object { $_.atom_type -eq $Type }
    }

    if ($Since) {
        $entries = $entries | Where-Object {
            [datetime]::Parse($_.timestamp) -ge $Since
        }
    }

    if ($Severity) {
        $entries = $entries | Where-Object { $_.severity -eq $Severity }
    }

    # Return last N if specified
    if ($Last) {
        $entries = $entries | Select-Object -Last $Last
    }

    return $entries
}

function Show-AtomTrail {
    <#
    .SYNOPSIS
        Displays ATOM trail in formatted table

    .EXAMPLE
        Show-AtomTrail -Last 10

    .EXAMPLE
        Show-AtomTrail -Type "CFG"
    #>
    [CmdletBinding()]
    param(
        [int]$Last = 20,
        [string]$Type
    )

    $params = @{ Last = $Last }
    if ($Type) { $params.Type = $Type }

    Get-AtomTrail @params | Format-Table -Property `
        @{Label="Time"; Expression={([datetime]$_.timestamp).ToString("HH:mm:ss")}; Width=10},
        @{Label="ATOM Tag"; Expression={$_.atom_tag}; Width=30},
        @{Label="Severity"; Expression={$_.severity}; Width=10},
        @{Label="Message"; Expression={$_.message}; Width=60} `
        -Wrap
}

function Initialize-AtomTrail {
    <#
    .SYNOPSIS
        Initializes ATOM trail system

    .DESCRIPTION
        Creates directories, counter file, and initial entry
    #>
    [CmdletBinding()]
    param()

    Write-Host "Initializing KENL ATOM Trail (JSON format)..." -ForegroundColor Cyan

    # Create directory
    $trailDir = Split-Path $script:AtomTrailPath
    if (-not (Test-Path $trailDir)) {
        New-Item -ItemType Directory -Path $trailDir -Force | Out-Null
        Write-Host "  ✅ Created: $trailDir" -ForegroundColor Green
    }

    # Initialize counter
    if (-not (Test-Path $script:AtomCounterPath)) {
        "1" | Set-Content $script:AtomCounterPath
        Write-Host "  ✅ Counter initialized" -ForegroundColor Green
    }

    # Create initial entry
    $tag = Write-AtomLog -Type "SYS" -Message "ATOM Trail initialized (JSON format)" -Context @{
        format = "JSON"
        version = "2.0.0"
    }

    Write-Host "  ✅ Initial entry: $tag" -ForegroundColor Green
    Write-Host ""
    Write-Host "ATOM Trail ready at: $script:AtomTrailPath" -ForegroundColor Green
}

function Export-AtomTrailToCsv {
    <#
    .SYNOPSIS
        Exports ATOM trail to CSV for analysis

    .EXAMPLE
        Export-AtomTrailToCsv -Path "atom-trail-export.csv"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [int]$Last
    )

    $params = @{}
    if ($Last) { $params.Last = $Last }

    $entries = Get-AtomTrail @params | ForEach-Object {
        [PSCustomObject]@{
            Timestamp = $_.timestamp
            AtomTag = $_.atom_tag
            AtomType = $_.atom_type
            Severity = $_.severity
            Message = $_.message
            Computer = $_.context.computer
            User = $_.context.user
        }
    }

    $entries | Export-Csv -Path $Path -NoTypeInformation
    Write-Host "✅ Exported $(($entries).Count) entries to: $Path" -ForegroundColor Green
}

# Aliases for convenience
New-Alias -Name "atom-log" -Value Write-AtomLog -Force
New-Alias -Name "atom-show" -Value Show-AtomTrail -Force
New-Alias -Name "atom-get" -Value Get-AtomTrail -Force
New-Alias -Name "atom-init" -Value Initialize-AtomTrail -Force

# Export module members
Export-ModuleMember -Function @(
    'Write-AtomLog',
    'Get-AtomTrail',
    'Show-AtomTrail',
    'Initialize-AtomTrail',
    'Export-AtomTrailToCsv'
) -Alias @(
    'atom-log',
    'atom-show',
    'atom-get',
    'atom-init'
)

# Module initialization message
Write-Host "✅ KENL ATOM Logger loaded (JSON format)" -ForegroundColor Green
Write-Host "   Trail: $script:AtomTrailPath" -ForegroundColor Gray
Write-Host "   Quick start: atom-log -Type CFG -Message 'Your message'" -ForegroundColor Gray
