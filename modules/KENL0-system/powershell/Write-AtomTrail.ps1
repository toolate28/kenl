#Requires -Version 5.1
<#
.SYNOPSIS
    Writes structured ATOM trail entries for logdy parsing

.DESCRIPTION
    Writes ATOM trail entries in standardized format:
    TIMESTAMP | ATOM-TYPE-YYYYMMDD-NNN | Message

    This format enables logdy column parsing for filtering/grouping.

.PARAMETER Type
    ATOM type (e.g., CONFIG, NETWORK, MONITORING, STATUS, etc.)

.PARAMETER Message
    The log message

.PARAMETER SequenceId
    Optional sequence number (001-999). Auto-increments if not provided.

.PARAMETER AtomTrailPath
    Path to ATOM trail file. Defaults to ~/.kenl/.atom-trail

.EXAMPLE
    Write-AtomTrail -Type "CONFIG" -Message "Logdy Central started on port 8081"

.EXAMPLE
    Write-AtomTrail -Type "NETWORK" -Message "Latency test: 19.6ms" -SequenceId 5

.NOTES
    Author    : KENL Framework
    Version   : 1.0.0
    ATOM      : ATOM-PWSH-20251117-001
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("CONFIG", "NETWORK", "MONITORING", "STATUS", "PWSH", "DOC",
                 "RESEARCH", "DEPLOY", "TASK", "MCP", "SAGE", "FIX", "TEST",
                 "ASSESS", "CI")]
    [string]$Type,

    [Parameter(Mandatory=$true)]
    [string]$Message,

    [ValidateRange(1, 999)]
    [int]$SequenceId,

    [string]$AtomTrailPath = "~/.kenl/.atom-trail"
)

# Expand path
$atomTrailExpanded = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($AtomTrailPath)

# Create directory if needed
$atomTrailDir = Split-Path -Parent $atomTrailExpanded
if (-not (Test-Path $atomTrailDir)) {
    New-Item -Path $atomTrailDir -ItemType Directory -Force | Out-Null
}

# Auto-generate sequence ID if not provided
if (-not $SequenceId) {
    # Find last sequence for this type and date
    $today = Get-Date -Format "yyyyMMdd"
    $pattern = "ATOM-$Type-$today-(\d{3})"

    if (Test-Path $atomTrailExpanded) {
        $lastSeq = Get-Content $atomTrailExpanded -ErrorAction SilentlyContinue |
            Select-String -Pattern $pattern |
            ForEach-Object {
                if ($_.Matches[0].Groups[1].Value) {
                    [int]$_.Matches[0].Groups[1].Value
                }
            } |
            Measure-Object -Maximum |
            Select-Object -ExpandProperty Maximum

        $SequenceId = if ($lastSeq) { $lastSeq + 1 } else { 1 }
    } else {
        $SequenceId = 1
    }
}

# Generate ATOM tag
$timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
$date = Get-Date -Format "yyyyMMdd"
$seqFormatted = "{0:D3}" -f $SequenceId
$atomTag = "ATOM-$Type-$date-$seqFormatted"

# Format entry with pipe delimiters
$entry = "$timestamp | $atomTag | $Message"

# Append to trail
Add-Content -Path $atomTrailExpanded -Value $entry -Encoding UTF8

# Output the tag for reference
Write-Verbose "Wrote: $atomTag"
return $atomTag
