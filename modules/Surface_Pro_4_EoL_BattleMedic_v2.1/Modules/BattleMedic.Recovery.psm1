#
# BattleMedic.Recovery.psm1
# Recovery and repair functions for Battle Medic Recovery Suite
#

#region Recovery Functions

<#
.SYNOPSIS
    Starts the Battle Medic recovery process based on system diagnostics.
.DESCRIPTION
    This function orchestrates the recovery process, automatically selecting
    appropriate interventions based on the current system state and priority level.
    It creates checkpoints, executes repairs, and verifies results.
.PARAMETER Mode
    Recovery mode: Guided, Automated, or Expert
.PARAMETER Priority
    Minimum priority level to address (P0, P1, P2, P3)
.PARAMETER Force
    Skip confirmation prompts
.EXAMPLE
    Start-BattleMedicRecovery -Mode Automated -Priority P1
    Automatically fixes all P0 and P1 issues
#>
function Start-BattleMedicRecovery {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter()]
        [ValidateSet('Guided', 'Automated', 'Expert')]
        [string]$Mode = 'Guided',

        [Parameter()]
        [ValidateSet('P0', 'P1', 'P2', 'P3')]
        [string]$Priority = 'P2',

        [Parameter()]
        [switch]$Force
    )

    begin {
        Write-Host "`nStarting Battle Medic Recovery Process" -ForegroundColor Cyan
        Write-Host "Mode: $Mode | Priority Threshold: $Priority" -ForegroundColor Gray
        Write-Host "=" * 60 -ForegroundColor Gray

        # Create pre-recovery checkpoint
        if ($PSCmdlet.ShouldProcess("System", "Create recovery checkpoint")) {
            $checkpoint = New-RecoveryCheckpoint -Name "BattleMedic_Pre_Recovery_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Write-Host "✓ Recovery checkpoint created: $($checkpoint.Name)" -ForegroundColor Green
        }

        # Get current diagnostics
        Write-Host "`nRunning system diagnostics..." -ForegroundColor Yellow
        $diagnostic = Get-BattleMedicDiagnostic -Quick

        Write-Host "`nDiagnostic Results:" -ForegroundColor White
        Write-Host "  System Priority: " -NoNewline
        $priorityColor = switch ($diagnostic.Priority) {
            'P0' { 'Red' }
            'P1' { 'Magenta' }
            'P2' { 'Yellow' }
            'P3' { 'Green' }
        }
        Write-Host $diagnostic.Priority -ForegroundColor $priorityColor
        Write-Host "  Issues Found: $($diagnostic.Issues.Count)"
        Write-Host "  Warnings: $($diagnostic.Warnings.Count)"

        # Check if action needed
        $priorityValues = @{ 'P0' = 0; 'P1' = 1; 'P2' = 2; 'P3' = 3 }
        if ($priorityValues[$diagnostic.Priority] -gt $priorityValues[$Priority]) {
            Write-Host "`nSystem priority ($($diagnostic.Priority)) is lower than threshold ($Priority)" -ForegroundColor Green
            Write-Host "No recovery actions needed." -ForegroundColor Green
            return
        }
    }

    process {
        $recoveryPlan = New-RecoveryPlan -Diagnostic $diagnostic -Priority $Priority

        if ($recoveryPlan.Actions.Count -eq 0) {
            Write-Host "`nNo recovery actions identified." -ForegroundColor Green
            return
        }

        Write-Host "`nRecovery Plan:" -ForegroundColor Cyan
        foreach ($action in $recoveryPlan.Actions) {
            Write-Host "  [$($action.Priority)] $($action.Name)" -ForegroundColor White
        }

        if (-not $Force) {
            $confirm = Read-Host "`nExecute recovery plan? (Y/N)"
            if ($confirm -ne 'Y') {
                Write-Host "Recovery cancelled by user." -ForegroundColor Yellow
                return
            }
        }

        # Execute recovery actions
        $results = @()
        $actionCount = 0

        foreach ($action in $recoveryPlan.Actions) {
            $actionCount++
            Write-Progress -Activity "Executing Recovery Plan" `
                         -Status "Running: $($action.Name)" `
                         -PercentComplete (($actionCount / $recoveryPlan.Actions.Count) * 100)

            Write-Host "`n[$actionCount/$($recoveryPlan.Actions.Count)] Executing: $($action.Name)" -ForegroundColor Cyan

            try {
                $result = & $action.ScriptBlock

                $results += [PSCustomObject]@{
                    Action = $action.Name
                    Priority = $action.Priority
                    Success = $true
                    Result = $result
                    Error = $null
                }

                Write-Host "  ✓ Completed successfully" -ForegroundColor Green
            }
            catch {
                $results += [PSCustomObject]@{
                    Action = $action.Name
                    Priority = $action.Priority
                    Success = $false
                    Result = $null
                    Error = $_.Exception.Message
                }

                Write-Host "  ✗ Failed: $_" -ForegroundColor Red

                if ($action.Priority -eq 'P0' -and -not $Force) {
                    $continue = Read-Host "Critical action failed. Continue? (Y/N)"
                    if ($continue -ne 'Y') {
                        Write-Host "Recovery aborted." -ForegroundColor Red
                        break
                    }
                }
            }
        }

        Write-Progress -Activity "Executing Recovery Plan" -Completed
    }

    end {
        # Verify recovery results
        Write-Host "`nVerifying recovery results..." -ForegroundColor Yellow
        $postDiagnostic = Get-BattleMedicDiagnostic -Quick

        Write-Host "`nRecovery Summary:" -ForegroundColor Cyan
        Write-Host "  Actions Executed: $($results.Count)"
        Write-Host "  Successful: $($results | Where-Object Success | Measure-Object).Count)" -ForegroundColor Green
        Write-Host "  Failed: $($results | Where-Object { -not $_.Success } | Measure-Object).Count)" -ForegroundColor Red

        Write-Host "`nPriority Change:"
        Write-Host "  Before: $($diagnostic.Priority)" -ForegroundColor $priorityColor

        $postPriorityColor = switch ($postDiagnostic.Priority) {
            'P0' { 'Red' }
            'P1' { 'Magenta' }
            'P2' { 'Yellow' }
            'P3' { 'Green' }
        }
        Write-Host "  After:  $($postDiagnostic.Priority)" -ForegroundColor $postPriorityColor

        # Log recovery session
        $recoveryLog = [PSCustomObject]@{
            Timestamp = Get-Date
            Mode = $Mode
            PrePriority = $diagnostic.Priority
            PostPriority = $postDiagnostic.Priority
            Actions = $results
            Success = $postDiagnostic.Priority -ne 'P0'
        }

        Write-BattleMedicLog -Message "Recovery session completed" -Level Info -Data $recoveryLog

        if ($postDiagnostic.Priority -eq 'P0' -and $diagnostic.Priority -eq 'P0') {
            Write-Warning "Critical issues remain unresolved. Manual intervention may be required."
        }
        elseif ($priorityValues[$postDiagnostic.Priority] -gt $priorityValues[$diagnostic.Priority]) {
            Write-Host "`nSystem health improved!" -ForegroundColor Green
        }

        return $recoveryLog
    }
}

<#
.SYNOPSIS
    Repairs the WOF.SYS driver and resolves BSOD 0xD3 errors.
.DESCRIPTION
    This function comprehensively addresses WOF driver issues by disabling
    CompactOS, repairing system files, and resetting the WOF service configuration.
.PARAMETER DisableCompactOS
    Permanently disable CompactOS compression
.PARAMETER Force
    Skip confirmation prompts
.EXAMPLE
    Repair-WOFDriver -DisableCompactOS -Force
#>
function Repair-WOFDriver {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()]
        [switch]$DisableCompactOS,

        [Parameter()]
        [switch]$Force
    )

    Write-Host "`nWOF.SYS Driver Recovery" -ForegroundColor Cyan
    Write-Host "=" * 40 -ForegroundColor Gray

    # Check current WOF status
    Write-Host "Checking WOF driver status..." -ForegroundColor Yellow
    $wofStatus = Test-WOFDriver

    if ($wofStatus.Corrupted) {
        Write-Warning "WOF.SYS is corrupted (0 bytes)"
    }
    elseif (-not $wofStatus.Present) {
        Write-Warning "WOF.SYS is missing"
    }
    else {
        Write-Host "WOF.SYS appears intact ($($wofStatus.Size) bytes)" -ForegroundColor Green
    }

    if ($wofStatus.CompactOSEnabled) {
        Write-Host "CompactOS is currently ENABLED" -ForegroundColor Yellow
    }
    else {
        Write-Host "CompactOS is currently disabled" -ForegroundColor Green
    }

    # Recovery steps
    $steps = @()

    if ($wofStatus.CompactOSEnabled -or $DisableCompactOS) {
        $steps += "Disable CompactOS compression"
    }

    if ($wofStatus.Corrupted -or -not $wofStatus.Present) {
        $steps += "Restore WOF.SYS driver file"
    }

    $steps += "Run System File Checker"
    $steps += "Reset WOF service configuration"

    if ($steps.Count -gt 0 -and -not $Force) {
        Write-Host "`nRecovery steps to be performed:" -ForegroundColor Cyan
        foreach ($step in $steps) {
            Write-Host "  • $step" -ForegroundColor White
        }

        $confirm = Read-Host "`nProceed with WOF recovery? (Y/N)"
        if ($confirm -ne 'Y') {
            Write-Host "Recovery cancelled." -ForegroundColor Yellow
            return
        }
    }

    # Execute recovery
    if ($PSCmdlet.ShouldProcess("WOF Driver", "Repair")) {

        # Step 1: Disable CompactOS if needed
        if ($wofStatus.CompactOSEnabled -or $DisableCompactOS) {
            Write-Host "`n[1/4] Disabling CompactOS..." -ForegroundColor Cyan
            try {
                $compactResult = & compact /compactos:never 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "  ✓ CompactOS disabled successfully" -ForegroundColor Green
                    Write-Verbose "Compact output: $compactResult"
                }
                else {
                    throw "Compact.exe returned error code: $LASTEXITCODE"
                }
            }
            catch {
                Write-Error "Failed to disable CompactOS: $_"
            }
        }

        # Step 2: Run SFC
        Write-Host "`n[2/4] Running System File Checker..." -ForegroundColor Cyan
        Write-Host "  This may take 10-15 minutes..." -ForegroundColor Gray

        try {
            $sfcResult = & sfc /scannow 2>&1

            if ($sfcResult -match "Windows Resource Protection found corrupt files and successfully repaired them") {
                Write-Host "  ✓ Corrupt files found and repaired" -ForegroundColor Green
            }
            elseif ($sfcResult -match "Windows Resource Protection did not find any integrity violations") {
                Write-Host "  ✓ No integrity violations found" -ForegroundColor Green
            }
            else {
                Write-Warning "  SFC completed with warnings. Check CBS.log for details."
            }
        }
        catch {
            Write-Error "SFC failed: $_"
        }

        # Step 3: DISM repair if in WinRE
        if ($env:SystemDrive -ne 'C:' -or (Test-Path 'X:\Windows\System32')) {
            Write-Host "`n[3/4] Running DISM repair (WinRE mode)..." -ForegroundColor Cyan

            $windowsDrive = Find-WindowsPartition
            if ($windowsDrive) {
                try {
                    $dismResult = & dism /image:$windowsDrive\ /cleanup-image /restorehealth 2>&1
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "  ✓ Component store repaired" -ForegroundColor Green
                    }
                    else {
                        Write-Warning "  DISM completed with warnings"
                    }
                }
                catch {
                    Write-Error "DISM failed: $_"
                }
            }
        }
        else {
            Write-Host "`n[3/4] Running DISM repair..." -ForegroundColor Cyan
            try {
                $dismResult = & dism /online /cleanup-image /restorehealth 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "  ✓ Component store repaired" -ForegroundColor Green
                }
            }
            catch {
                Write-Error "DISM failed: $_"
            }
        }

        # Step 4: Reset WOF registry configuration
        Write-Host "`n[4/4] Resetting WOF service configuration..." -ForegroundColor Cyan

        try {
            $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Wof"

            if (Test-Path $regPath) {
                Set-ItemProperty -Path $regPath -Name "Start" -Value 0 -Type DWord
                Write-Host "  ✓ WOF service set to boot start" -ForegroundColor Green

                # Verify other critical values
                $errorControl = Get-ItemProperty -Path $regPath -Name "ErrorControl" -ErrorAction SilentlyContinue
                if ($errorControl.ErrorControl -ne 1) {
                    Set-ItemProperty -Path $regPath -Name "ErrorControl" -Value 1 -Type DWord
                }

                $type = Get-ItemProperty -Path $regPath -Name "Type" -ErrorAction SilentlyContinue
                if ($type.Type -ne 2) {
                    Set-ItemProperty -Path $regPath -Name "Type" -Value 2 -Type DWord
                }

                Write-Host "  ✓ WOF registry configuration verified" -ForegroundColor Green
            }
            else {
                Write-Warning "WOF service registry key not found"
            }
        }
        catch {
            Write-Error "Failed to reset WOF configuration: $_"
        }

        # Verify repair
        Write-Host "`nVerifying WOF repair..." -ForegroundColor Yellow
        $postStatus = Test-WOFDriver

        if (-not $postStatus.Corrupted -and $postStatus.Present) {
            Write-Host "✓ WOF.SYS driver repaired successfully!" -ForegroundColor Green

            if (-not $postStatus.CompactOSEnabled) {
                Write-Host "✓ CompactOS is disabled" -ForegroundColor Green
            }

            Write-Host "`nReboot required to complete recovery." -ForegroundColor Yellow

            return @{
                Success = $true
                WOFStatus = $postStatus
                RebootRequired = $true
            }
        }
        else {
            Write-Warning "WOF repair incomplete. Manual intervention may be required."

            return @{
                Success = $false
                WOFStatus = $postStatus
                RebootRequired = $true
            }
        }
    }
}

<#
.SYNOPSIS
    Performs comprehensive system file repair using SFC and DISM.
.DESCRIPTION
    Runs System File Checker and DISM to repair corrupted system files
    and restore the Windows component store.
.PARAMETER Online
    Run against the active Windows installation
.PARAMETER Path
    Path to offline Windows installation
.EXAMPLE
    Repair-SystemFiles -Online
#>
function Repair-SystemFiles {
    [CmdletBinding(DefaultParameterSetName = 'Online')]
    param(
        [Parameter(ParameterSetName = 'Online')]
        [switch]$Online,

        [Parameter(ParameterSetName = 'Offline', Mandatory)]
        [string]$Path
    )

    Write-Host "`nSystem File Repair" -ForegroundColor Cyan
    Write-Host "=" * 40 -ForegroundColor Gray

    if ($PSCmdlet.ParameterSetName -eq 'Offline') {
        Write-Host "Target: Offline image at $Path" -ForegroundColor Yellow

        # Offline SFC
        Write-Host "`n[1/2] Running offline SFC scan..." -ForegroundColor Cyan
        $sfcArgs = "/scannow /offbootdir=$Path /offwindir=$Path\Windows"

        try {
            $sfcResult = & sfc $sfcArgs 2>&1
            Write-Verbose "SFC Result: $sfcResult"
            Write-Host "  ✓ SFC scan completed" -ForegroundColor Green
        }
        catch {
            Write-Error "Offline SFC failed: $_"
        }

        # Offline DISM
        Write-Host "`n[2/2] Running offline DISM repair..." -ForegroundColor Cyan
        $dismArgs = "/image:$Path /cleanup-image /restorehealth"

        try {
            $dismResult = & dism $dismArgs 2>&1
            Write-Verbose "DISM Result: $dismResult"
            Write-Host "  ✓ DISM repair completed" -ForegroundColor Green
        }
        catch {
            Write-Error "Offline DISM failed: $_"
        }
    }
    else {
        # Online repair
        Write-Host "Target: Active Windows installation" -ForegroundColor Yellow

        # Check admin rights
        $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

        if (-not $isAdmin) {
            Write-Warning "Administrator privileges required for system file repair"
            return
        }

        # DISM health check first
        Write-Host "`n[1/3] Checking component store health..." -ForegroundColor Cyan
        try {
            $checkHealth = & dism /online /cleanup-image /checkhealth 2>&1

            if ($checkHealth -match "No component store corruption detected") {
                Write-Host "  ✓ Component store is healthy" -ForegroundColor Green
            }
            else {
                Write-Warning "  Component store corruption detected"
            }
        }
        catch {
            Write-Warning "Health check failed: $_"
        }

        # DISM restore
        Write-Host "`n[2/3] Repairing component store..." -ForegroundColor Cyan
        Write-Host "  This may take 10-20 minutes..." -ForegroundColor Gray

        try {
            $restoreResult = & dism /online /cleanup-image /restorehealth 2>&1

            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ Component store repaired successfully" -ForegroundColor Green
            }
            else {
                Write-Warning "  DISM completed with warnings (exit code: $LASTEXITCODE)"
            }
        }
        catch {
            Write-Error "DISM restore failed: $_"
        }

        # SFC scan
        Write-Host "`n[3/3] Running System File Checker..." -ForegroundColor Cyan
        Write-Host "  This may take 10-15 minutes..." -ForegroundColor Gray

        try {
            $sfcResult = & sfc /scannow 2>&1

            if ($sfcResult -match "Windows Resource Protection found corrupt files and successfully repaired them") {
                Write-Host "  ✓ Corrupt files found and repaired" -ForegroundColor Green
            }
            elseif ($sfcResult -match "Windows Resource Protection did not find any integrity violations") {
                Write-Host "  ✓ No integrity violations found" -ForegroundColor Green
            }
            elseif ($sfcResult -match "Windows Resource Protection found corrupt files but was unable to fix") {
                Write-Warning "  Some files could not be repaired. Check CBS.log for details."
            }
            else {
                Write-Warning "  SFC completed with unknown status"
            }
        }
        catch {
            Write-Error "SFC scan failed: $_"
        }
    }

    Write-Host "`nSystem file repair completed." -ForegroundColor Green
    Write-Host "Reboot recommended to ensure all repairs take effect." -ForegroundColor Yellow
}

<#
.SYNOPSIS
    Performs emergency disk cleanup to recover critical disk space.
.DESCRIPTION
    Aggressively cleans temporary files, Windows Update cache, and other
    non-essential data when disk space is critically low.
.PARAMETER TargetFreeGB
    Target amount of free space in GB
.PARAMETER IncludeUserData
    Include user temporary files and caches
.EXAMPLE
    Start-EmergencyCleanup -TargetFreeGB 10 -IncludeUserData
#>
function Start-EmergencyCleanup {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()]
        [int]$TargetFreeGB = 5,

        [Parameter()]
        [switch]$IncludeUserData
    )

    Write-Host "`nEmergency Disk Cleanup" -ForegroundColor Red
    Write-Host "=" * 40 -ForegroundColor Gray

    # Get current disk status
    $disk = Get-PSDrive -Name C
    $initialFreeGB = [Math]::Round($disk.Free / 1GB, 2)

    Write-Host "Current free space: $initialFreeGB GB" -ForegroundColor Yellow
    Write-Host "Target free space:  $TargetFreeGB GB" -ForegroundColor Cyan

    if ($initialFreeGB -ge $TargetFreeGB) {
        Write-Host "Target free space already achieved." -ForegroundColor Green
        return
    }

    $spaceCleaned = 0

    # Windows Update cache
    if ($PSCmdlet.ShouldProcess("Windows Update Cache", "Clean")) {
        Write-Host "`n[1/7] Cleaning Windows Update cache..." -ForegroundColor Cyan

        try {
            Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue

            $updatePath = Join-Path -Path $env:windir -ChildPath "SoftwareDistribution\Download"
            if (Test-Path $updatePath) {
                $sizeBefore = (Get-ChildItem $updatePath -Recurse | Measure-Object -Property Length -Sum).Sum / 1GB
                Remove-Item "$updatePath\*" -Recurse -Force -ErrorAction SilentlyContinue
                $spaceCleaned += $sizeBefore
                Write-Host "  ✓ Cleaned $([Math]::Round($sizeBefore, 2)) GB" -ForegroundColor Green
            }

            Start-Service -Name wuauserv -ErrorAction SilentlyContinue
        }
        catch {
            Write-Warning "Failed to clean Windows Update cache: $_"
        }
    }

    # Temporary files
    if ($PSCmdlet.ShouldProcess("Temporary Files", "Clean")) {
        Write-Host "`n[2/7] Cleaning temporary files..." -ForegroundColor Cyan

        $tempPaths = @(
            $env:TEMP,
            "$env:windir\Temp",
            "$env:windir\Prefetch"
        )

        foreach ($tempPath in $tempPaths) {
            if (Test-Path $tempPath) {
                try {
                    $sizeBefore = (Get-ChildItem $tempPath -Recurse -ErrorAction SilentlyContinue |
                                  Measure-Object -Property Length -Sum).Sum / 1GB

                    Get-ChildItem $tempPath -Recurse -ErrorAction SilentlyContinue |
                        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

                    $spaceCleaned += $sizeBefore
                    Write-Host "  ✓ Cleaned $([Math]::Round($sizeBefore, 2)) GB from $tempPath" -ForegroundColor Green
                }
                catch {
                    Write-Verbose "Error cleaning $tempPath : $_"
                }
            }
        }
    }

    # Windows.old
    $windowsOld = Join-Path -Path $env:SystemDrive -ChildPath "Windows.old"
    if (Test-Path $windowsOld) {
        if ($PSCmdlet.ShouldProcess("Windows.old", "Remove")) {
            Write-Host "`n[3/7] Removing Windows.old..." -ForegroundColor Cyan

            try {
                $sizeBefore = (Get-ChildItem $windowsOld -Recurse | Measure-Object -Property Length -Sum).Sum / 1GB

                & takeown /F $windowsOld /R /D Y 2>&1 | Out-Null
                & icacls $windowsOld /grant administrators:F /T /Q 2>&1 | Out-Null
                Remove-Item $windowsOld -Recurse -Force

                $spaceCleaned += $sizeBefore
                Write-Host "  ✓ Removed Windows.old ($([Math]::Round($sizeBefore, 2)) GB)" -ForegroundColor Green
            }
            catch {
                Write-Warning "Failed to remove Windows.old: $_"
            }
        }
    }

    # Recycle Bin
    if ($PSCmdlet.ShouldProcess("Recycle Bin", "Empty")) {
        Write-Host "`n[4/7] Emptying Recycle Bin..." -ForegroundColor Cyan

        try {
            $shell = New-Object -ComObject Shell.Application
            $recycleBin = $shell.Namespace(0xA)
            $recycleBin.Items() | ForEach-Object {
                Remove-Item $_.Path -Recurse -Force -ErrorAction SilentlyContinue
            }
            Write-Host "  ✓ Recycle Bin emptied" -ForegroundColor Green
        }
        catch {
            Write-Verbose "Failed to empty Recycle Bin: $_"
        }
    }

    # User data cleanup (if requested)
    if ($IncludeUserData) {
        Write-Host "`n[5/7] Cleaning user caches..." -ForegroundColor Cyan

        $userPaths = @(
            "$env:LOCALAPPDATA\Temp",
            "$env:LOCALAPPDATA\Microsoft\Windows\INetCache",
            "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\*.db"
        )

        foreach ($userPath in $userPaths) {
            if (Test-Path $userPath) {
                try {
                    Get-ChildItem $userPath -Recurse -ErrorAction SilentlyContinue |
                        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                    Write-Host "  ✓ Cleaned $userPath" -ForegroundColor Green
                }
                catch {
                    Write-Verbose "Error cleaning user path: $_"
                }
            }
        }
    }

    # Component store cleanup
    Write-Host "`n[6/7] Cleaning component store..." -ForegroundColor Cyan
    try {
        & dism /online /cleanup-image /startcomponentcleanup /resetbase 2>&1 | Out-Null
        Write-Host "  ✓ Component store cleaned" -ForegroundColor Green
    }
    catch {
        Write-Warning "Component store cleanup failed: $_"
    }

    # Run Disk Cleanup utility
    Write-Host "`n[7/7] Running Windows Disk Cleanup..." -ForegroundColor Cyan
    try {
        # Configure disk cleanup
        $cleanupKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
        $categories = @(
            "Active Setup Temp Folders",
            "Downloaded Program Files",
            "Internet Cache Files",
            "Old ChkDsk Files",
            "Previous Installations",
            "Recycle Bin",
            "Setup Log Files",
            "System error memory dump files",
            "System error minidump files",
            "Temporary Files",
            "Temporary Setup Files",
            "Thumbnail Cache",
            "Upgrade Discarded Files",
            "Windows Error Reporting Archive Files",
            "Windows Error Reporting Queue Files",
            "Windows Error Reporting System Archive Files",
            "Windows Error Reporting System Queue Files",
            "Windows Upgrade Log Files"
        )

        foreach ($category in $categories) {
            $path = Join-Path -Path $cleanupKey -ChildPath $category
            if (Test-Path $path) {
                Set-ItemProperty -Path $path -Name StateFlags0100 -Value 2 -Type DWord -ErrorAction SilentlyContinue
            }
        }

        # Run cleanup
        & cleanmgr /sagerun:100 2>&1 | Out-Null
        Write-Host "  ✓ Disk Cleanup completed" -ForegroundColor Green
    }
    catch {
        Write-Warning "Disk Cleanup failed: $_"
    }

    # Final status
    $disk = Get-PSDrive -Name C
    $finalFreeGB = [Math]::Round($disk.Free / 1GB, 2)
    $recovered = $finalFreeGB - $initialFreeGB

    Write-Host "`n" + "=" * 40 -ForegroundColor Gray
    Write-Host "Cleanup Summary:" -ForegroundColor Cyan
    Write-Host "  Initial free space: $initialFreeGB GB" -ForegroundColor White
    Write-Host "  Final free space:   $finalFreeGB GB" -ForegroundColor White
    Write-Host "  Space recovered:    $([Math]::Round($recovered, 2)) GB" -ForegroundColor Green

    if ($finalFreeGB -ge $TargetFreeGB) {
        Write-Host "`n✓ Target free space achieved!" -ForegroundColor Green
    }
    else {
        Write-Warning "`nTarget not reached. Consider additional cleanup options."
    }

    return @{
        InitialFreeGB = $initialFreeGB
        FinalFreeGB = $finalFreeGB
        RecoveredGB = $recovered
        TargetReached = $finalFreeGB -ge $TargetFreeGB
    }
}

<#
.SYNOPSIS
    Resets Windows Update components to resolve update failures.
.DESCRIPTION
    Stops update services, cleans update cache, re-registers DLLs,
    and restarts services to fix Windows Update issues.
.EXAMPLE
    Reset-WindowsUpdate
#>
function Reset-WindowsUpdate {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    Write-Host "`nWindows Update Reset" -ForegroundColor Cyan
    Write-Host "=" * 40 -ForegroundColor Gray

    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Warning "Administrator privileges required"
        return
    }

    if ($PSCmdlet.ShouldProcess("Windows Update", "Reset components")) {

        # Stop services
        Write-Host "[1/6] Stopping Windows Update services..." -ForegroundColor Cyan
        $services = @('wuauserv', 'cryptsvc', 'bits', 'msiserver')

        foreach ($service in $services) {
            try {
                Stop-Service -Name $service -Force -ErrorAction Stop
                Write-Host "  ✓ Stopped $service" -ForegroundColor Green
            }
            catch {
                Write-Warning "  Failed to stop $service"
            }
        }

        # Rename SoftwareDistribution and catroot2
        Write-Host "`n[2/6] Renaming update folders..." -ForegroundColor Cyan

        $folders = @(
            @{
                Path = "$env:windir\SoftwareDistribution"
                NewName = "SoftwareDistribution.old"
            },
            @{
                Path = "$env:windir\System32\catroot2"
                NewName = "catroot2.old"
            }
        )

        foreach ($folder in $folders) {
            if (Test-Path $folder.Path) {
                $newPath = $folder.Path + ".old"

                if (Test-Path $newPath) {
                    Remove-Item $newPath -Recurse -Force -ErrorAction SilentlyContinue
                }

                try {
                    Rename-Item -Path $folder.Path -NewName $folder.NewName -Force
                    Write-Host "  ✓ Renamed $(Split-Path $folder.Path -Leaf)" -ForegroundColor Green
                }
                catch {
                    Write-Warning "  Failed to rename $(Split-Path $folder.Path -Leaf)"
                }
            }
        }

        # Re-register DLLs
        Write-Host "`n[3/6] Re-registering Windows Update DLLs..." -ForegroundColor Cyan

        $dlls = @(
            'atl.dll', 'urlmon.dll', 'mshtml.dll', 'shdocvw.dll',
            'browseui.dll', 'jscript.dll', 'vbscript.dll', 'scrrun.dll',
            'msxml.dll', 'msxml3.dll', 'msxml6.dll', 'actxprxy.dll',
            'softpub.dll', 'wintrust.dll', 'dssenh.dll', 'rsaenh.dll',
            'gpkcsp.dll', 'sccbase.dll', 'slbcsp.dll', 'cryptdlg.dll',
            'oleaut32.dll', 'ole32.dll', 'shell32.dll', 'initpki.dll',
            'wuapi.dll', 'wuaueng.dll', 'wuaueng1.dll', 'wucltui.dll',
            'wups.dll', 'wups2.dll', 'wuweb.dll', 'qmgr.dll',
            'qmgrprxy.dll', 'wucltux.dll', 'muweb.dll', 'wuwebv.dll'
        )

        $registered = 0
        foreach ($dll in $dlls) {
            $result = & regsvr32.exe /s $dll 2>&1
            if ($LASTEXITCODE -eq 0) {
                $registered++
            }
        }

        Write-Host "  ✓ Re-registered $registered DLLs" -ForegroundColor Green

        # Reset WinSock
        Write-Host "`n[4/6] Resetting WinSock..." -ForegroundColor Cyan
        & netsh winsock reset 2>&1 | Out-Null
        & netsh winhttp reset proxy 2>&1 | Out-Null
        Write-Host "  ✓ WinSock reset complete" -ForegroundColor Green

        # Start services
        Write-Host "`n[5/6] Starting Windows Update services..." -ForegroundColor Cyan

        foreach ($service in $services) {
            try {
                Start-Service -Name $service -ErrorAction Stop
                Write-Host "  ✓ Started $service" -ForegroundColor Green
            }
            catch {
                Write-Warning "  Failed to start $service"
            }
        }

        # Force update detection
        Write-Host "`n[6/6] Forcing update detection..." -ForegroundColor Cyan

        try {
            $updateSession = New-Object -ComObject Microsoft.Update.Session
            $updateSearcher = $updateSession.CreateUpdateSearcher()
            Write-Host "  Searching for updates..." -ForegroundColor Gray
            $updates = $updateSearcher.Search("IsInstalled=0")
            Write-Host "  ✓ Found $($updates.Updates.Count) available updates" -ForegroundColor Green
        }
        catch {
            Write-Warning "  Update detection failed: $_"
        }

        Write-Host "`nWindows Update reset completed." -ForegroundColor Green
        Write-Host "Reboot required to complete the reset." -ForegroundColor Yellow

        return @{
            Success = $true
            RebootRequired = $true
        }
    }
}

#endregion

#region Helper Functions

function New-RecoveryPlan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Diagnostic,

        [Parameter()]
        [string]$Priority = 'P2'
    )

    $plan = [PSCustomObject]@{
        Created = Get-Date
        Priority = $Priority
        Actions = @()
    }

    # P0 Actions
    if ($Diagnostic.Priority -eq 'P0') {

        # WOF corruption
        if ($Diagnostic.SystemInfo.WOFStatus.Corrupted) {
            $plan.Actions += [PSCustomObject]@{
                Priority = 'P0'
                Name = 'Repair WOF.SYS Driver'
                ScriptBlock = { Repair-WOFDriver -DisableCompactOS -Force }
            }
        }

        # Critical disk space
        if ($Diagnostic.SystemInfo.DiskStatus.Critical) {
            $plan.Actions += [PSCustomObject]@{
                Priority = 'P0'
                Name = 'Emergency Disk Cleanup'
                ScriptBlock = { Start-EmergencyCleanup -TargetFreeGB 5 }
            }
        }

        # Critical temperature
        if ($Diagnostic.SystemInfo.ThermalStatus.Status -eq 'Critical') {
            $plan.Actions += [PSCustomObject]@{
                Priority = 'P0'
                Name = 'Thermal Mitigation'
                ScriptBlock = { Start-ThermalMitigation -Aggressive }
            }
        }
    }

    # P1 Actions
    if ($Priority -in @('P1', 'P2', 'P3') -and $Diagnostic.Priority -in @('P0', 'P1')) {

        # System file corruption
        if ($Diagnostic.SystemInfo.IntegrityStatus.CorruptFiles) {
            $plan.Actions += [PSCustomObject]@{
                Priority = 'P1'
                Name = 'System File Repair'
                ScriptBlock = { Repair-SystemFiles -Online }
            }
        }

        # Windows Update failures
        if ($Diagnostic.SystemInfo.UpdateStatus.Failed) {
            $plan.Actions += [PSCustomObject]@{
                Priority = 'P1'
                Name = 'Reset Windows Update'
                ScriptBlock = { Reset-WindowsUpdate }
            }
        }
    }

    return $plan
}

function New-RecoveryCheckpoint {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter()]
        [switch]$Silent
    )

    try {
        # Enable System Restore if needed
        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue

        # Create restore point
        Checkpoint-Computer -Description $Name -RestorePointType MODIFY_SETTINGS

        if (-not $Silent) {
            Write-Host "Recovery checkpoint created: $Name" -ForegroundColor Green
        }

        return [PSCustomObject]@{
            Success = $true
            Name = $Name
            Timestamp = Get-Date
        }
    }
    catch {
        Write-Warning "Failed to create checkpoint: $_"

        return [PSCustomObject]@{
            Success = $false
            Name = $Name
            Error = $_.Exception.Message
        }
    }
}

function Start-ThermalMitigation {
    [CmdletBinding()]
    param(
        [switch]$Aggressive
    )

    Write-Host "`nThermal Mitigation" -ForegroundColor Cyan
    Write-Host "=" * 40 -ForegroundColor Gray

    # Set power plan to balanced
    Write-Host "Setting balanced power plan..." -ForegroundColor Yellow
    & powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e

    if ($Aggressive) {
        # Disable CPU turbo boost
        Write-Host "Disabling CPU Turbo Boost..." -ForegroundColor Yellow
        & powercfg /setacvalueindex scheme_current sub_processor PERFBOOSTMODE 0
        & powercfg /setactive scheme_current

        # Set maximum processor state
        Write-Host "Limiting maximum processor state to 80%..." -ForegroundColor Yellow
        & powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMAX 80
        & powercfg /setdcvalueindex scheme_current sub_processor PROCTHROTTLEMAX 60
        & powercfg /setactive scheme_current
    }

    # Clean temp files to reduce I/O heat
    Write-Host "Cleaning temporary files..." -ForegroundColor Yellow
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue

    # Stop unnecessary services
    $services = @('WSearch', 'SysMain', 'DiagTrack')
    foreach ($service in $services) {
        Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
    }

    Write-Host "Thermal mitigation applied." -ForegroundColor Green
}

function Find-WindowsPartition {
    [CmdletBinding()]
    param()

    $drives = Get-PSDrive -PSProvider FileSystem
    foreach ($drive in $drives) {
        $windowsPath = Join-Path -Path "$($drive.Name):" -ChildPath 'Windows\System32'
        if (Test-Path $windowsPath) {
            return "$($drive.Name):"
        }
    }

    return $null
}

#endregion

# Export module functions
Export-ModuleMember -Function @(
    'Start-BattleMedicRecovery',
    'Repair-WOFDriver',
    'Repair-SystemFiles',
    'Start-EmergencyCleanup',
    'Reset-WindowsUpdate',
    'New-RecoveryCheckpoint',
    'Start-ThermalMitigation'
)
