#Requires -Version 5.1

<#
.SYNOPSIS
    Create CTFWI (Capture The Flag With Intent) handover documentation

.DESCRIPTION
    Dual-instance validation framework:
    - Instance A (Planning): Writes expected state, commands, outcomes
    - Instance B (Execution): Runs commands, documents actual results
    - Automatic diff shows alignment or discrepancies
    - Creates audit trail + documentation in one process

.PARAMETER Phase
    Handover phase: Expect (planning), Execute (doing), Validate (compare)

.PARAMETER TaskName
    Name of the task being documented

.PARAMETER HandoverId
    Unique handover ID (auto-generated if not provided)

.EXAMPLE
    # Instance A (Planning Claude):
    New-KenlHandover -Phase Expect -TaskName "Fix Network Module" -Expected @{
        Command = "Import-Module KENL.Network; Test-KenlNetwork -IncludeGaming"
        Outcome = "8 servers tested, avg latency <10ms"
        Files = @("KENL.Network.psm1")
    }

    # Instance B (Executing Claude):
    New-KenlHandover -Phase Execute -TaskName "Fix Network Module" -HandoverId "HAND-001" -Actual @{
        Command = "Import-Module KENL.Network; Test-KenlNetwork -IncludeGaming"
        Outcome = "8 servers tested, avg latency 6.5ms"
        Files = @("KENL.Network.psm1")
    }

    # Automatic validation:
    New-KenlHandover -Phase Validate -HandoverId "HAND-001"

.NOTES
    Author: KENL Framework
    Version: 1.0.0
    ATOM: ATOM-HANDOVER-20251119-001

    This implements "expect before, document after, validate alignment" pattern.
    Perfect for Claude → Claude handovers or human → Claude workflows.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Expect", "Execute", "Validate")]
    [string]$Phase,

    [Parameter(Mandatory=$false)]
    [string]$TaskName,

    [Parameter(Mandatory=$false)]
    [string]$HandoverId,

    [Parameter(Mandatory=$false)]
    [hashtable]$Expected,

    [Parameter(Mandatory=$false)]
    [hashtable]$Actual
)

$handoverDir = "$env:USERPROFILE\.kenl\handovers"
New-Item -Path $handoverDir -ItemType Directory -Force | Out-Null

#region Expect Phase (Instance A - Planning)
if ($Phase -eq "Expect") {
    if (-not $TaskName) {
        Write-Error "TaskName required for Expect phase"
        exit 1
    }

    # Generate handover ID
    $handoverId = "HAND-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    $handoverPath = "$handoverDir\$handoverId"
    New-Item -Path $handoverPath -ItemType Directory -Force | Out-Null

    Write-Host "`n╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║         CTFWI Handover - EXPECT Phase                    ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

    Write-Host "Task: $TaskName" -ForegroundColor Yellow
    Write-Host "Handover ID: $handoverId" -ForegroundColor Gray
    Write-Host ""

    # Create expectation document
    $expectation = @{
        HandoverId = $handoverId
        TaskName = $TaskName
        Phase = "Expect"
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        PlanningInstance = "Claude Code (Expect)"
        Expected = $Expected
        Flags = @()
    }

    # Auto-generate flags from expectations
    if ($Expected) {
        Write-Host "Expected State (Flags to Capture):" -ForegroundColor Green

        if ($Expected.Command) {
            Write-Host "  [FLAG-CMD] Command: $($Expected.Command)" -ForegroundColor Cyan
            $expectation.Flags += @{
                Type = "Command"
                Expected = $Expected.Command
                Description = "Command to execute"
            }
        }

        if ($Expected.Outcome) {
            Write-Host "  [FLAG-OUT] Outcome: $($Expected.Outcome)" -ForegroundColor Cyan
            $expectation.Flags += @{
                Type = "Outcome"
                Expected = $Expected.Outcome
                Description = "Expected result"
            }
        }

        if ($Expected.Files) {
            Write-Host "  [FLAG-FILE] Files: $($Expected.Files -join ', ')" -ForegroundColor Cyan
            $expectation.Flags += @{
                Type = "Files"
                Expected = $Expected.Files
                Description = "Files created/modified"
            }
        }

        if ($Expected.State) {
            Write-Host "  [FLAG-STATE] System State: $($Expected.State)" -ForegroundColor Cyan
            $expectation.Flags += @{
                Type = "State"
                Expected = $Expected.State
                Description = "Expected system state"
            }
        }

        if ($Expected.Metrics) {
            Write-Host "  [FLAG-METRIC] Metrics: $($Expected.Metrics | ConvertTo-Json -Compress)" -ForegroundColor Cyan
            $expectation.Flags += @{
                Type = "Metrics"
                Expected = $Expected.Metrics
                Description = "Performance/quality metrics"
            }
        }
    }

    # Save expectation
    $expectation | ConvertTo-Json -Depth 5 | Out-File "$handoverPath\expectation.json"

    Write-Host ""
    Write-Host "✅ Expectation document created" -ForegroundColor Green
    Write-Host ""
    Write-Host "NEXT STEPS FOR EXECUTING INSTANCE:" -ForegroundColor Cyan
    Write-Host "  1. Run the planned commands" -ForegroundColor White
    Write-Host "  2. Document actual results:" -ForegroundColor White
    Write-Host "     New-KenlHandover -Phase Execute -HandoverId '$handoverId' -Actual @{" -ForegroundColor Yellow
    Write-Host "         Command = 'actual command run'" -ForegroundColor Yellow
    Write-Host "         Outcome = 'actual outcome'" -ForegroundColor Yellow
    Write-Host "         Files = @('actual files changed')" -ForegroundColor Yellow
    Write-Host "     }" -ForegroundColor Yellow
    Write-Host "  3. Validate alignment:" -ForegroundColor White
    Write-Host "     New-KenlHandover -Phase Validate -HandoverId '$handoverId'" -ForegroundColor Yellow
    Write-Host ""

    return @{
        HandoverId = $handoverId
        Path = $handoverPath
        Flags = $expectation.Flags.Count
    }
}
#endregion

#region Execute Phase (Instance B - Doing)
elseif ($Phase -eq "Execute") {
    if (-not $HandoverId) {
        Write-Error "HandoverId required for Execute phase"
        exit 1
    }

    $handoverPath = "$handoverDir\$HandoverId"
    if (-not (Test-Path "$handoverPath\expectation.json")) {
        Write-Error "Expectation file not found for handover $HandoverId"
        exit 1
    }

    Write-Host "`n╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║         CTFWI Handover - EXECUTE Phase                   ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

    # Load expectation
    $expectation = Get-Content "$handoverPath\expectation.json" | ConvertFrom-Json

    Write-Host "Task: $($expectation.TaskName)" -ForegroundColor Yellow
    Write-Host "Handover ID: $HandoverId" -ForegroundColor Gray
    Write-Host ""

    # Create execution document
    $execution = @{
        HandoverId = $HandoverId
        TaskName = $expectation.TaskName
        Phase = "Execute"
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        ExecutingInstance = "Claude Code (Execute)"
        Actual = $Actual
        FlagResults = @()
    }

    # Capture flags
    if ($Actual) {
        Write-Host "Actual Results (Flag Capture):" -ForegroundColor Green

        if ($Actual.Command) {
            Write-Host "  [FLAG-CMD] Command: $($Actual.Command)" -ForegroundColor Cyan
            $execution.FlagResults += @{
                Type = "Command"
                Actual = $Actual.Command
                Captured = $true
            }
        }

        if ($Actual.Outcome) {
            Write-Host "  [FLAG-OUT] Outcome: $($Actual.Outcome)" -ForegroundColor Cyan
            $execution.FlagResults += @{
                Type = "Outcome"
                Actual = $Actual.Outcome
                Captured = $true
            }
        }

        if ($Actual.Files) {
            Write-Host "  [FLAG-FILE] Files: $($Actual.Files -join ', ')" -ForegroundColor Cyan
            $execution.FlagResults += @{
                Type = "Files"
                Actual = $Actual.Files
                Captured = $true
            }
        }

        if ($Actual.State) {
            Write-Host "  [FLAG-STATE] System State: $($Actual.State)" -ForegroundColor Cyan
            $execution.FlagResults += @{
                Type = "State"
                Actual = $Actual.State
                Captured = $true
            }
        }

        if ($Actual.Metrics) {
            Write-Host "  [FLAG-METRIC] Metrics: $($Actual.Metrics | ConvertTo-Json -Compress)" -ForegroundColor Cyan
            $execution.FlagResults += @{
                Type = "Metrics"
                Actual = $Actual.Metrics
                Captured = $true
            }
        }
    }

    # Save execution
    $execution | ConvertTo-Json -Depth 5 | Out-File "$handoverPath\execution.json"

    Write-Host ""
    Write-Host "✅ Execution document created" -ForegroundColor Green
    Write-Host ""
    Write-Host "NEXT STEP:" -ForegroundColor Cyan
    Write-Host "  Validate alignment:" -ForegroundColor White
    Write-Host "  New-KenlHandover -Phase Validate -HandoverId '$HandoverId'" -ForegroundColor Yellow
    Write-Host ""

    return @{
        HandoverId = $HandoverId
        Path = $handoverPath
        FlagsCaptured = $execution.FlagResults.Count
    }
}
#endregion

#region Validate Phase (Automatic Diff)
elseif ($Phase -eq "Validate") {
    if (-not $HandoverId) {
        Write-Error "HandoverId required for Validate phase"
        exit 1
    }

    $handoverPath = "$handoverDir\$HandoverId"

    if (-not (Test-Path "$handoverPath\expectation.json")) {
        Write-Error "Expectation file not found"
        exit 1
    }

    if (-not (Test-Path "$handoverPath\execution.json")) {
        Write-Error "Execution file not found"
        exit 1
    }

    Write-Host "`n╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║         CTFWI Handover - VALIDATE Phase                  ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

    # Load both documents
    $expectation = Get-Content "$handoverPath\expectation.json" | ConvertFrom-Json
    $execution = Get-Content "$handoverPath\execution.json" | ConvertFrom-Json

    Write-Host "Task: $($expectation.TaskName)" -ForegroundColor Yellow
    Write-Host "Handover ID: $HandoverId" -ForegroundColor Gray
    Write-Host ""

    # Validate alignment
    $validation = @{
        HandoverId = $HandoverId
        TaskName = $expectation.TaskName
        Phase = "Validate"
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Aligned = $true
        Discrepancies = @()
        Summary = @{
            TotalFlags = $expectation.Flags.Count
            Captured = 0
            Matched = 0
            Mismatched = 0
            Missing = 0
        }
    }

    Write-Host "Flag Validation Results:" -ForegroundColor Green
    Write-Host ""

    foreach ($flag in $expectation.Flags) {
        $actualFlag = $execution.FlagResults | Where-Object { $_.Type -eq $flag.Type }

        if ($actualFlag) {
            $validation.Summary.Captured++

            # Compare expected vs actual
            $expectedValue = $flag.Expected
            $actualValue = $actualFlag.Actual

            # Simple string comparison (can be enhanced)
            if ($expectedValue -eq $actualValue) {
                Write-Host "  ✅ [FLAG-$($flag.Type)] MATCHED" -ForegroundColor Green
                Write-Host "     Expected: $expectedValue" -ForegroundColor Gray
                Write-Host "     Actual:   $actualValue" -ForegroundColor Gray
                $validation.Summary.Matched++
            }
            else {
                Write-Host "  🚩 [FLAG-$($flag.Type)] MISMATCH" -ForegroundColor Red
                Write-Host "     Expected: $expectedValue" -ForegroundColor Yellow
                Write-Host "     Actual:   $actualValue" -ForegroundColor Yellow
                $validation.Summary.Mismatched++
                $validation.Aligned = $false

                $validation.Discrepancies += @{
                    FlagType = $flag.Type
                    Expected = $expectedValue
                    Actual = $actualValue
                    Impact = "Review required"
                }
            }
        }
        else {
            Write-Host "  ⚠️  [FLAG-$($flag.Type)] MISSING" -ForegroundColor Yellow
            Write-Host "     Expected: $($flag.Expected)" -ForegroundColor Gray
            Write-Host "     Actual:   (not captured)" -ForegroundColor Gray
            $validation.Summary.Missing++
            $validation.Aligned = $false

            $validation.Discrepancies += @{
                FlagType = $flag.Type
                Expected = $flag.Expected
                Actual = "(not captured)"
                Impact = "Documentation incomplete"
            }
        }

        Write-Host ""
    }

    # Summary
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "VALIDATION SUMMARY" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Total Flags:      $($validation.Summary.TotalFlags)" -ForegroundColor White
    Write-Host "Captured:         $($validation.Summary.Captured)" -ForegroundColor White
    Write-Host "✅ Matched:       $($validation.Summary.Matched)" -ForegroundColor Green
    Write-Host "🚩 Mismatched:    $($validation.Summary.Mismatched)" -ForegroundColor $(if ($validation.Summary.Mismatched -gt 0) { "Red" } else { "Green" })
    Write-Host "⚠️  Missing:       $($validation.Summary.Missing)" -ForegroundColor $(if ($validation.Summary.Missing -gt 0) { "Yellow" } else { "Green" })
    Write-Host ""

    if ($validation.Aligned) {
        Write-Host "✅ HANDOVER VALIDATED - Instances Fully Aligned" -ForegroundColor Green
    }
    else {
        Write-Host "🚩 HANDOVER PARTIAL - Review Discrepancies" -ForegroundColor Red
    }

    Write-Host ""

    # Save validation
    $validation | ConvertTo-Json -Depth 5 | Out-File "$handoverPath\validation.json"

    # Create human-readable report
    $report = @"
# CTFWI Handover Report
**Task:** $($expectation.TaskName)
**Handover ID:** $HandoverId
**Generated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Expectation (Planning Instance)
- **Timestamp:** $($expectation.Timestamp)
- **Instance:** $($expectation.PlanningInstance)

$(foreach ($flag in $expectation.Flags) {
"### $($flag.Type)
- **Expected:** $($flag.Expected)
- **Description:** $($flag.Description)
"
})

## Execution (Doing Instance)
- **Timestamp:** $($execution.Timestamp)
- **Instance:** $($execution.ExecutingInstance)

$(foreach ($flag in $execution.FlagResults) {
"### $($flag.Type)
- **Actual:** $($flag.Actual)
- **Captured:** $($flag.Captured)
"
})

## Validation Results
- **Aligned:** $($validation.Aligned)
- **Total Flags:** $($validation.Summary.TotalFlags)
- **Matched:** $($validation.Summary.Matched)
- **Mismatched:** $($validation.Summary.Mismatched)
- **Missing:** $($validation.Summary.Missing)

$(if ($validation.Discrepancies.Count -gt 0) {
"### Discrepancies
$(foreach ($disc in $validation.Discrepancies) {
"#### $($disc.FlagType)
- **Expected:** $($disc.Expected)
- **Actual:** $($disc.Actual)
- **Impact:** $($disc.Impact)
"
})"
} else {
"### ✅ No Discrepancies - Perfect Alignment"
})

---
*Generated by KENL CTFWI Handover System*
*ATOM: ATOM-HANDOVER-20251119-001*
"@

    $report | Out-File "$handoverPath\HANDOVER-REPORT.md"

    Write-Host "📄 Reports saved to: $handoverPath" -ForegroundColor Cyan
    Write-Host "   - expectation.json" -ForegroundColor Gray
    Write-Host "   - execution.json" -ForegroundColor Gray
    Write-Host "   - validation.json" -ForegroundColor Gray
    Write-Host "   - HANDOVER-REPORT.md" -ForegroundColor Gray
    Write-Host ""

    Write-Host "NEXT STEPS:" -ForegroundColor Cyan
    if ($validation.Aligned) {
        Write-Host "  ✅ Handover complete - both instances aligned" -ForegroundColor Green
        Write-Host "  📋 Documentation automatically generated" -ForegroundColor Green
        Write-Host "  💾 Archive: $handoverPath" -ForegroundColor Gray
    }
    else {
        Write-Host "  🔍 Review discrepancies in HANDOVER-REPORT.md" -ForegroundColor Yellow
        Write-Host "  📝 Update documentation if needed" -ForegroundColor Yellow
        Write-Host "  🔄 Re-run if expectations need adjustment" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "View report: code '$handoverPath\HANDOVER-REPORT.md'" -ForegroundColor Gray

    return $validation
}
#endregion
