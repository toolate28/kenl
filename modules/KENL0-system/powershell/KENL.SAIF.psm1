#Requires -Version 5.1
<#
.SYNOPSIS
    KENL SAIF Module - System-Aware Intent Flagging for guided user journeys

.DESCRIPTION
    Provides SAIF flag generation, CTFWI (Checkpoint To Follow-up With Intent) handover,
    and next-step guidance for all KENL operations. Ensures users always know:
    - What just happened (ATOM tag)
    - What to do next (guidance)
    - Where to look for logs/results
    - How to rollback if needed

.NOTES
    File Name      : KENL.SAIF.psm1
    Author         : KENL Framework
    Prerequisite   : PowerShell 5.1+, KENL.psm1
    Version        : 1.0.0
    ATOM           : ATOM-SAIF-20251125-001

.LINK
    https://github.com/toolate28/kenl
#>

#region Module Variables

$script:SAIFVersion = "1.0.0"
$script:SAIFLogPath = Join-Path $env:USERPROFILE ".kenl\saif-trail.log"
$script:SAIFCounterPath = Join-Path $env:USERPROFILE ".kenl\.saif-counter"

# SAIF action types and their descriptions
$script:SAIFTypes = @{
    'VALIDATE'    = 'Validation operation completed'
    'PARTITION'   = 'Disk partitioning operation'
    'INSTALL'     = 'Installation step'
    'CONFIG'      = 'Configuration change'
    'OPTIMIZE'    = 'Optimization applied'
    'TEST'        = 'Test executed'
    'DEPLOY'      = 'Deployment operation'
    'BACKUP'      = 'Backup operation'
    'RESTORE'     = 'Restore operation'
    'HOOK'        = 'Hook registered'
    'CMD'         = 'Command registered'
    'ATOM'        = 'ATOM trail operation'
    'HANDOVER'    = 'Handover document created'
    'CHECKLIST'   = 'Checklist validated'
    'NETWORK'     = 'Network operation'
    'GAMING'      = 'Gaming configuration'
    'MONITORING'  = 'Monitoring operation'
}

# Next step templates for common operations
$script:NextStepTemplates = @{
    'VALIDATE' = @{
        Success = @(
            "All validations passed"
            "Proceed to next phase or run: {0}"
            "Check logs at: {1}"
        )
        Failure = @(
            "Validation failed: {0}"
            "Review errors and retry"
            "Check logs at: {1}"
        )
    }
    'PARTITION' = @{
        Success = @(
            "Partitioning completed successfully"
            "Next: Format partitions or proceed to installation"
            "Verify with: lsblk -o NAME,SIZE,FSTYPE,LABEL"
        )
        Failure = @(
            "Partitioning failed: {0}"
            "Check disk status and retry"
            "Emergency: Use GParted Live for recovery"
        )
    }
    'CONFIG' = @{
        Success = @(
            "Configuration applied successfully"
            "Next: Verify with {0}"
            "Rollback: {1}"
        )
        Failure = @(
            "Configuration failed: {0}"
            "Restore previous config: {1}"
            "Check logs at: {2}"
        )
    }
    'NETWORK' = @{
        Success = @(
            "Network operation completed"
            "Verify with: Test-KenlNetwork or Test-NetConnection"
            "Check logs at: ~/.kenl/logs/network.log"
        )
        Failure = @(
            "Network operation failed: {0}"
            "Check network adapter status"
            "Rollback MTU: Set-KenlMTU -MTU 1500"
        )
    }
}

#endregion

#region Core SAIF Functions

<#
.SYNOPSIS
    Generates a new SAIF flag with guidance information

.DESCRIPTION
    Creates a SAIF flag following the format SAIF-{ACTION}-{YYYYMMDD}-{NNN}
    and returns an object with the flag, timestamp, and next-step guidance.

.PARAMETER Action
    The action type (VALIDATE, PARTITION, CONFIG, etc.)

.PARAMETER Subject
    The subject of the action (e.g., 'PREINSTALL', 'NETWORK', 'EXTERNAL-DRIVE')

.PARAMETER Description
    Human-readable description of what was done

.PARAMETER Status
    Success or Failure status

.PARAMETER NextSteps
    Array of next step guidance strings

.PARAMETER LogPath
    Path to relevant log file for this operation

.PARAMETER RollbackCommand
    Command to rollback this operation if needed

.EXAMPLE
    New-SAIFFlag -Action 'VALIDATE' -Subject 'PREINSTALL' -Description 'Pre-installation checks passed'

.EXAMPLE
    $saif = New-SAIFFlag -Action 'CONFIG' -Subject 'MTU' -Description 'MTU set to 1492' `
        -RollbackCommand 'Set-KenlMTU -MTU 1500' -LogPath '~/.kenl/logs/network.log'
#>
function New-SAIFFlag {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('VALIDATE', 'PARTITION', 'INSTALL', 'CONFIG', 'OPTIMIZE', 'TEST',
                     'DEPLOY', 'BACKUP', 'RESTORE', 'HOOK', 'CMD', 'ATOM', 'HANDOVER',
                     'CHECKLIST', 'NETWORK', 'GAMING', 'MONITORING')]
        [string]$Action,

        [Parameter(Mandatory)]
        [string]$Subject,

        [Parameter(Mandatory)]
        [string]$Description,

        [ValidateSet('Success', 'Failure', 'Warning', 'Info')]
        [string]$Status = 'Success',

        [string[]]$NextSteps,

        [string]$LogPath,

        [string]$RollbackCommand,

        [string]$VerifyCommand
    )

    # Ensure directory exists
    $saifDir = Split-Path $script:SAIFLogPath
    if (-not (Test-Path $saifDir)) {
        New-Item -Path $saifDir -ItemType Directory -Force | Out-Null
    }

    # Get or initialize counter
    $counter = if (Test-Path $script:SAIFCounterPath) {
        [int](Get-Content $script:SAIFCounterPath)
    } else {
        1
    }

    # Generate SAIF flag
    $timestamp = Get-Date -Format 'yyyyMMdd'
    $saifFlag = "SAIF-{0}-{1}-{2:D3}" -f $Action, $timestamp, $counter

    # Increment counter
    ($counter + 1) | Set-Content $script:SAIFCounterPath

    # Build next steps if not provided
    if (-not $NextSteps) {
        $template = $script:NextStepTemplates[$Action]
        if ($template) {
            $NextSteps = if ($Status -eq 'Success') { $template.Success } else { $template.Failure }
        } else {
            $NextSteps = @("Operation completed with status: $Status")
        }
    }

    # Create SAIF result object
    $result = [PSCustomObject]@{
        Flag            = $saifFlag
        Action          = $Action
        Subject         = $Subject
        Description     = $Description
        Status          = $Status
        Timestamp       = (Get-Date -Format "o")
        NextSteps       = $NextSteps
        LogPath         = $LogPath
        RollbackCommand = $RollbackCommand
        VerifyCommand   = $VerifyCommand
        Platform        = if ($PSVersionTable.PSEdition -eq 'Desktop' -or $env:OS -eq "Windows_NT") {
            "Windows"
        } elseif ($IsLinux) {
            "Linux"
        } elseif ($IsMacOS) {
            "macOS"
        } else {
            "Unknown"
        }
    }

    # Log to SAIF trail
    $logEntry = [PSCustomObject]@{
        timestamp = $result.Timestamp
        flag = $saifFlag
        action = $Action
        subject = $Subject
        description = $Description
        status = $Status
        platform = $result.Platform
    } | ConvertTo-Json -Compress

    Add-Content -Path $script:SAIFLogPath -Value $logEntry -Encoding UTF8

    return $result
}

<#
.SYNOPSIS
    Writes SAIF execution result with next-step guidance to console

.DESCRIPTION
    Displays a formatted execution result with color-coded status,
    SAIF flag, and actionable next steps for the user.

.PARAMETER SAIFResult
    The SAIF result object from New-SAIFFlag

.PARAMETER ShowDetails
    Show additional details including log path and rollback info

.EXAMPLE
    $result = New-SAIFFlag -Action 'CONFIG' -Subject 'MTU' -Description 'MTU set to 1492'
    Write-SAIFResult -SAIFResult $result
#>
function Write-SAIFResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSCustomObject]$SAIFResult,

        [switch]$ShowDetails
    )

    process {
        $statusColor = switch ($SAIFResult.Status) {
            'Success' { 'Green' }
            'Failure' { 'Red' }
            'Warning' { 'Yellow' }
            'Info'    { 'Cyan' }
            default   { 'White' }
        }

        $statusIcon = switch ($SAIFResult.Status) {
            'Success' { '✅' }
            'Failure' { '❌' }
            'Warning' { '⚠️' }
            'Info'    { 'ℹ️' }
            default   { '•' }
        }

        Write-Host ""
        Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "║  SAIF Execution Result                                     ║" -ForegroundColor Cyan
        Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
        Write-Host ""

        # Status and flag
        Write-Host "  $statusIcon " -NoNewline
        Write-Host $SAIFResult.Description -ForegroundColor $statusColor
        Write-Host ""
        Write-Host "  SAIF Flag: " -NoNewline -ForegroundColor Gray
        Write-Host $SAIFResult.Flag -ForegroundColor Yellow
        Write-Host ""

        # Next steps
        Write-Host "  📋 Next Steps:" -ForegroundColor Cyan
        foreach ($step in $SAIFResult.NextSteps) {
            Write-Host "     → $step" -ForegroundColor White
        }
        Write-Host ""

        if ($ShowDetails) {
            if ($SAIFResult.LogPath) {
                Write-Host "  📁 Log: " -NoNewline -ForegroundColor Gray
                Write-Host $SAIFResult.LogPath -ForegroundColor DarkGray
            }
            if ($SAIFResult.VerifyCommand) {
                Write-Host "  🔍 Verify: " -NoNewline -ForegroundColor Gray
                Write-Host $SAIFResult.VerifyCommand -ForegroundColor DarkGray
            }
            if ($SAIFResult.RollbackCommand) {
                Write-Host "  ↩️  Rollback: " -NoNewline -ForegroundColor Gray
                Write-Host $SAIFResult.RollbackCommand -ForegroundColor DarkGray
            }
            Write-Host ""
        }

        Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    }
}

<#
.SYNOPSIS
    Creates a CTFWI (Checkpoint To Follow-up With Intent) handover document

.DESCRIPTION
    Generates a handover document for transitions between operations,
    modules, or sessions. Captures current state, completed actions,
    and next steps for seamless continuation.

.PARAMETER Title
    Title of the handover document

.PARAMETER Phase
    Current phase or step in the process

.PARAMETER CompletedActions
    Array of completed actions with their SAIF/ATOM flags

.PARAMETER NextActions
    Array of next actions to be taken

.PARAMETER CriticalNotes
    Important notes or warnings for the next phase

.PARAMETER OutputPath
    Path to save the handover document (defaults to Desktop)

.EXAMPLE
    New-CTFWIHandover -Title "Disk Preparation Complete" -Phase "Step 2" `
        -CompletedActions @("Disk wiped (ATOM-CFG-20251125-001)", "GPT created") `
        -NextActions @("Boot Bazzite Live USB", "Run partition script")
#>
function New-CTFWIHandover {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Title,

        [string]$Phase = "Current",

        [string[]]$CompletedActions = @(),

        [string[]]$NextActions = @(),

        [string[]]$CriticalNotes = @(),

        [string]$OutputPath
    )

    # Generate SAIF flag for handover
    $saif = New-SAIFFlag -Action 'HANDOVER' -Subject $Title.Replace(' ', '-') `
        -Description "Created handover document: $Title" `
        -NextSteps @(
            "Review handover document at: $OutputPath"
            "Follow next steps in sequence"
            "Log continuation with ATOM tag"
        )

    # Default output path
    if (-not $OutputPath) {
        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $fileName = "HANDOVER-$($Title.Replace(' ', '-'))-$timestamp.md"
        $OutputPath = Join-Path ([Environment]::GetFolderPath('Desktop')) $fileName
    }

    # Build handover document
    $content = @"
---
title: $Title
classification: CTFWI-HANDOVER
saif: $($saif.Flag)
timestamp: $(Get-Date -Format 'o')
phase: $Phase
status: handover
---

# $Title
## CTFWI Handover Document

**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
**SAIF Flag:** $($saif.Flag)
**Phase:** $Phase

---

## Completed Actions

$(($CompletedActions | ForEach-Object { "- ✅ $_" }) -join "`n")

---

## Next Actions

$(($NextActions | ForEach-Object { "- ⏳ $_" }) -join "`n")

---

## Critical Notes

$(if ($CriticalNotes.Count -gt 0) {
    ($CriticalNotes | ForEach-Object { "⚠️ $_" }) -join "`n`n"
} else {
    "No critical notes for this handover."
})

---

## SAIF Trail

- Current: $($saif.Flag)
- Next: (will be generated in next phase)

---

## Status Checklist

$(($CompletedActions | ForEach-Object { "- [x] $_" }) -join "`n")
$(($NextActions | ForEach-Object { "- [ ] $_" }) -join "`n")

---

Generated by KENL SAIF Module v$script:SAIFVersion
"@

    # Save document
    $content | Out-File -FilePath $OutputPath -Encoding UTF8

    # Display result
    Write-SAIFResult -SAIFResult $saif -ShowDetails

    Write-Host "  📝 Handover saved to:" -ForegroundColor Cyan
    Write-Host "     $OutputPath" -ForegroundColor White
    Write-Host ""

    return [PSCustomObject]@{
        SAIFResult = $saif
        FilePath = $OutputPath
        Title = $Title
        Phase = $Phase
    }
}

#endregion

#region SAIF Query Functions

<#
.SYNOPSIS
    Gets SAIF trail entries with optional filtering

.PARAMETER Last
    Return last N entries

.PARAMETER Action
    Filter by action type

.PARAMETER Since
    Filter by date

.EXAMPLE
    Get-SAIFTrail -Last 10
    Get-SAIFTrail -Action 'CONFIG' -Since (Get-Date).AddDays(-7)
#>
function Get-SAIFTrail {
    [CmdletBinding()]
    param(
        [int]$Last,

        [ValidateSet('VALIDATE', 'PARTITION', 'INSTALL', 'CONFIG', 'OPTIMIZE', 'TEST',
                     'DEPLOY', 'BACKUP', 'RESTORE', 'HOOK', 'CMD', 'ATOM', 'HANDOVER',
                     'CHECKLIST', 'NETWORK', 'GAMING', 'MONITORING')]
        [string]$Action,

        [datetime]$Since
    )

    if (-not (Test-Path $script:SAIFLogPath)) {
        Write-Warning "SAIF trail not found at: $script:SAIFLogPath"
        return @()
    }

    $entries = Get-Content $script:SAIFLogPath | ForEach-Object {
        try {
            $_ | ConvertFrom-Json
        } catch {
            # Skip invalid lines
        }
    } | Where-Object { $_ -ne $null }

    # Apply filters
    if ($Action) {
        $entries = $entries | Where-Object { $_.action -eq $Action }
    }

    if ($Since) {
        $entries = $entries | Where-Object {
            [datetime]::ParseExact($_.timestamp, "o", [System.Globalization.CultureInfo]::InvariantCulture) -ge $Since
        }
    }

    if ($Last) {
        $entries = $entries | Select-Object -Last $Last
    }

    return $entries
}

<#
.SYNOPSIS
    Displays SAIF trail in formatted table

.EXAMPLE
    Show-SAIFTrail -Last 10
#>
function Show-SAIFTrail {
    [CmdletBinding()]
    param(
        [int]$Last = 20,
        [string]$Action
    )

    $params = @{ Last = $Last }
    if ($Action) { $params.Action = $Action }

    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  SAIF Trail (Last $Last entries)                           ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    Get-SAIFTrail @params | Format-Table -Property `
        @{Label="Time"; Expression={([datetime]$_.timestamp).ToString("HH:mm:ss")}; Width=10},
        @{Label="SAIF Flag"; Expression={$_.flag}; Width=30},
        @{Label="Status"; Expression={$_.status}; Width=10},
        @{Label="Description"; Expression={$_.description}; Width=40} `
        -Wrap
}

#endregion

#region Initialization

<#
.SYNOPSIS
    Initializes SAIF system

.EXAMPLE
    Initialize-SAIF
#>
function Initialize-SAIF {
    [CmdletBinding()]
    param()

    Write-Host "Initializing KENL SAIF Module v$script:SAIFVersion..." -ForegroundColor Cyan

    # Create directory
    $saifDir = Split-Path $script:SAIFLogPath
    if (-not (Test-Path $saifDir)) {
        New-Item -Path $saifDir -ItemType Directory -Force | Out-Null
        Write-Host "  ✅ Created SAIF directory: $saifDir" -ForegroundColor Green
    }

    # Initialize counter
    if (-not (Test-Path $script:SAIFCounterPath)) {
        "1" | Set-Content $script:SAIFCounterPath
        Write-Host "  ✅ Initialized SAIF counter" -ForegroundColor Green
    }

    # Create initial entry
    $saif = New-SAIFFlag -Action 'CONFIG' -Subject 'SAIF-INIT' `
        -Description "SAIF Module initialized" `
        -NextSteps @(
            "SAIF system ready for use"
            "Generate flags with: New-SAIFFlag"
            "View trail with: Show-SAIFTrail"
        )

    Write-SAIFResult -SAIFResult $saif

    return $saif
}

#endregion

#region Aliases

New-Alias -Name 'saif' -Value New-SAIFFlag -Force
New-Alias -Name 'saif-show' -Value Show-SAIFTrail -Force
New-Alias -Name 'saif-handover' -Value New-CTFWIHandover -Force

#endregion

#region Export

Export-ModuleMember -Function @(
    'New-SAIFFlag',
    'Write-SAIFResult',
    'New-CTFWIHandover',
    'Get-SAIFTrail',
    'Show-SAIFTrail',
    'Initialize-SAIF'
) -Alias @(
    'saif',
    'saif-show',
    'saif-handover'
)

#endregion

# Module load message
Write-Host "KENL.SAIF module loaded (v$script:SAIFVersion)" -ForegroundColor Cyan
Write-Host "  Quick start: saif -Action CONFIG -Subject 'MyChange' -Description 'What I did'" -ForegroundColor Gray
