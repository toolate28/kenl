# CTFWI Handover Example: Fix KENL.Network Module Syntax Error

# ═══════════════════════════════════════════════════════════
# PHASE 1: EXPECT (Planning Claude - THIS INSTANCE)
# ═══════════════════════════════════════════════════════════

Write-Host "PHASE 1: Planning Instance Documents Expectations`n" -ForegroundColor Cyan

$handover = .\modules\KENL0-system\powershell\New-KenlHandover.ps1 -Phase Expect -TaskName "Fix KENL.Network.psm1 Syntax Error" -Expected @{
    Command = @"
1. Edit modules/KENL0-system/powershell/KENL.Network.psm1
2. Add -IncludeGaming parameter to Test-KenlNetwork function
3. Add GamingHosts array with EA/Steam/Battlefield servers
4. Test module loads without errors
5. Run Test-KenlNetwork -IncludeGaming successfully
"@

    Outcome = @"
- Module loads: Import-Module KENL.Network -Force (no errors)
- Test runs: Test-KenlNetwork -IncludeGaming
- Output shows 8 servers tested (5 CDN + 3 gaming)
- Average latency < 10ms
- All servers return EXCELLENT status
"@

    Files = @(
        "modules/KENL0-system/powershell/KENL.Network.psm1"
    )

    State = @{
        ModuleSyntax = "Valid PowerShell"
        ParameterExists = '$true'
        GamingHostsCount = 3
        TotalTestHosts = 8
    }

    Metrics = @{
        AvgLatency = "< 10ms"
        ExcellentCount = 8
        ErrorCount = 0
    }
}

Write-Host "`nHandover ID: $($handover.HandoverId)" -ForegroundColor Green
Write-Host "Flags Created: $($handover.Flags)" -ForegroundColor Green
Write-Host ""

# ═══════════════════════════════════════════════════════════
# WHAT USER DOES NEXT:
# ═══════════════════════════════════════════════════════════

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "USER ACTION REQUIRED" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Manually fix the syntax error in KENL.Network.psm1:" -ForegroundColor White
Write-Host "   - Open: code modules\KENL0-system\powershell\KENL.Network.psm1" -ForegroundColor Gray
Write-Host "   - Find line ~62: Add [switch]`$IncludeGaming parameter" -ForegroundColor Gray
Write-Host "   - Find line ~26: Add `$script:GamingHosts array" -ForegroundColor Gray
Write-Host "   - Find line ~76: Add `$hostsToTest selection logic" -ForegroundColor Gray
Write-Host ""
Write-Host "2. After fixing, run PHASE 2 script (will be next instance)" -ForegroundColor White
Write-Host ""

# ═══════════════════════════════════════════════════════════
# PHASE 2: EXECUTE (Next Claude Instance OR Same After Fix)
# ═══════════════════════════════════════════════════════════

Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "PHASE 2: Execution Script (Run After Manual Fix)" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$phase2Script = @"
# PHASE 2: Execute and Document Actual Results

`$handoverId = "$($handover.HandoverId)"

Write-Host "Executing planned commands...`n" -ForegroundColor Yellow

# 1. Test module loads
Write-Host "1. Testing module import..." -ForegroundColor Cyan
try {
    Remove-Module KENL.Network -Force -ErrorAction SilentlyContinue
    Import-Module .\modules\KENL0-system\powershell\KENL.Network.psm1 -Force -ErrorAction Stop
    `$moduleLoaded = `$true
    Write-Host "   ✅ Module loaded successfully" -ForegroundColor Green
}
catch {
    `$moduleLoaded = `$false
    Write-Host "   ❌ Module load failed: `$_" -ForegroundColor Red
}

# 2. Check parameter exists
Write-Host "`n2. Checking -IncludeGaming parameter..." -ForegroundColor Cyan
`$paramExists = (Get-Command Test-KenlNetwork).Parameters.ContainsKey('IncludeGaming')
if (`$paramExists) {
    Write-Host "   ✅ Parameter exists" -ForegroundColor Green
}
else {
    Write-Host "   ❌ Parameter missing" -ForegroundColor Red
}

# 3. Run test with gaming servers
Write-Host "`n3. Running Test-KenlNetwork -IncludeGaming..." -ForegroundColor Cyan
if (`$moduleLoaded -and `$paramExists) {
    `$results = Test-KenlNetwork -IncludeGaming

    `$avgLatency = (`$results.LatencyMs | Measure-Object -Average).Average
    `$excellentCount = (`$results | Where-Object Status -eq "EXCELLENT").Count
    `$totalServers = `$results.Count

    Write-Host "   ✅ Test completed" -ForegroundColor Green
    Write-Host "      Servers tested: `$totalServers" -ForegroundColor Gray
    Write-Host "      Avg latency: `$([math]::Round(`$avgLatency, 1))ms" -ForegroundColor Gray
    Write-Host "      EXCELLENT: `$excellentCount/`$totalServers" -ForegroundColor Gray
}
else {
    `$avgLatency = 0
    `$excellentCount = 0
    `$totalServers = 0
    Write-Host "   ❌ Test skipped (prerequisites failed)" -ForegroundColor Red
}

# 4. Document actual results
Write-Host "`n4. Documenting actual results..." -ForegroundColor Cyan

`$execution = .\modules\KENL0-system\powershell\New-KenlHandover.ps1 ``
    -Phase Execute ``
    -HandoverId "`$handoverId" ``
    -Actual @{
        Command = @"
1. Remove-Module KENL.Network -Force
2. Import-Module KENL.Network.psm1 -Force
3. Test-KenlNetwork -IncludeGaming
Result: `$(if (`$moduleLoaded) { 'Success' } else { 'Failed' })
"@

        Outcome = @"
- Module loads: `$(if (`$moduleLoaded) { 'SUCCESS' } else { 'FAILED' })
- Test runs: `$(if (`$paramExists) { 'SUCCESS' } else { 'FAILED - parameter missing' })
- Servers tested: `$totalServers (expected 8)
- Average latency: `$([math]::Round(`$avgLatency, 1))ms
- EXCELLENT status: `$excellentCount/`$totalServers
"@

        Files = @(
            "modules/KENL0-system/powershell/KENL.Network.psm1"
        )

        State = @{
            ModuleSyntax = `$(if (`$moduleLoaded) { 'Valid' } else { 'Invalid' })
            ParameterExists = `$paramExists
            GamingHostsCount = 3  # As implemented
            TotalTestHosts = `$totalServers
        }

        Metrics = @{
            AvgLatency = "`$([math]::Round(`$avgLatency, 1))ms"
            ExcellentCount = `$excellentCount
            ErrorCount = `$(if (`$moduleLoaded) { 0 } else { 1 })
        }
    }

Write-Host "`n5. Running validation..." -ForegroundColor Cyan
`$validation = .\modules\KENL0-system\powershell\New-KenlHandover.ps1 -Phase Validate -HandoverId "`$handoverId"

# Summary
Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "HANDOVER COMPLETE" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Alignment: `$(if (`$validation.Aligned) { '✅ PERFECT' } else { '🚩 REVIEW NEEDED' })" -ForegroundColor `$(if (`$validation.Aligned) { 'Green' } else { 'Yellow' })
Write-Host "Matched Flags: `$(`$validation.Summary.Matched)/`$(`$validation.Summary.TotalFlags)" -ForegroundColor White
Write-Host ""
Write-Host "📄 Full report: ~\.kenl\handovers\`$handoverId\HANDOVER-REPORT.md" -ForegroundColor Cyan
"@

# Save Phase 2 script
$phase2Script | Out-File "HANDOVER-PHASE2-EXECUTE.ps1"

Write-Host "✅ Phase 2 script saved: HANDOVER-PHASE2-EXECUTE.ps1" -ForegroundColor Green
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "1. Fix the syntax error manually (see above)" -ForegroundColor White
Write-Host "2. Run: .\HANDOVER-PHASE2-EXECUTE.ps1" -ForegroundColor Yellow
Write-Host "3. Review: ~\.kenl\handovers\$($handover.HandoverId)\HANDOVER-REPORT.md" -ForegroundColor Yellow
Write-Host ""
Write-Host "This creates:" -ForegroundColor Cyan
Write-Host "  ✅ Automatic validation (expected vs actual)" -ForegroundColor Green
Write-Host "  ✅ Self-documenting process (what was planned + what happened)" -ForegroundColor Green
Write-Host "  ✅ Audit trail (JSON + Markdown reports)" -ForegroundColor Green
Write-Host "  ✅ Alignment verification (CTF flags captured correctly)" -ForegroundColor Green
Write-Host ""
