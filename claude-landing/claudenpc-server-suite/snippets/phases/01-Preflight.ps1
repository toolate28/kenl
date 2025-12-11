# 01-Preflight.ps1
# Prerequisites validation phase for ClaudeNPC Server Suite
# Version: 1.0.0
# Status: PRODUCTION READY - Drop-in snippet

function Invoke-PreflightChecks {
    <#
    .SYNOPSIS
        Validates all prerequisites before installation
    .PARAMETER SkipPreflight
        Skip preflight checks (not recommended)
    .OUTPUTS
        Hashtable with Success, Critical, Warnings, and Skipped keys
    #>
    param(
        [Parameter(Mandatory=$false)]
        [switch]$SkipPreflight
    )
    
    # Import core modules
    $coreRoot = Join-Path $PSScriptRoot "..\core"
    . "$coreRoot\Display.ps1"
    . "$coreRoot\Logger.ps1"
    . "$coreRoot\Safety.ps1"
    
    if ($SkipPreflight) {
        Write-StatusBox -Title "Preflight Checks" -Status "Skipped by user" -Type "Warning"
        Write-Log -Message "Preflight checks skipped by user request" -Level "WARNING"
        return @{Success = $true; Skipped = $true}
    }
    
    Write-Section -Title "Preflight Checks" -Icon "🛡️"
    Write-Log -Message "Starting preflight validation checks" -Level "INFO"
    
    $checks = @()
    
    # Check 1: PowerShell Version
    Write-Log -Message "Checking PowerShell version" -Level "INFO"
    $psVersion = $PSVersionTable.PSVersion
    $psOK = $psVersion.Major -ge 5 -and ($psVersion.Major -gt 5 -or $psVersion.Minor -ge 1)
    
    $checks += @{
        Check = "PowerShell Version"
        Status = if ($psOK) { "✓ $($psVersion.ToString())" } else { "✗ $($psVersion.ToString())" }
        Required = "5.1+"
        Critical = $true
    }
    
    Write-StatusBox -Title "PowerShell Version" -Status $psVersion.ToString() `
        -Details $(if ($psOK) { "Compatible" } else { "Requires 5.1 or higher" }) `
        -Type $(if ($psOK) { "Success" } else { "Error" })
    
    # Check 2: Administrator Privileges
    Write-Log -Message "Checking administrator privileges" -Level "INFO"
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    $checks += @{
        Check = "Administrator"
        Status = if ($isAdmin) { "✓ Yes" } else { "✗ No" }
        Required = "Required"
        Critical = $true
    }
    
    Write-StatusBox -Title "Administrator Rights" -Status $(if ($isAdmin) { "Verified" } else { "Missing" }) `
        -Details $(if ($isAdmin) { "Running with admin privileges" } else { "Restart PowerShell as Administrator" }) `
        -Type $(if ($isAdmin) { "Success" } else { "Error" })
    
    # Check 3: Java Installation
    Write-Log -Message "Checking Java installation" -Level "INFO"
    $javaOK = $false
    $javaVersion = "Not installed"
    $javaPath = $null
    
    try {
        $javaCheck = java -version 2>&1
        if ($javaCheck -match 'version "(\d+)\.?(\d*)') {
            $javaMajor = [int]$matches[1]
            if ($javaMajor -eq 1) {
                # Old versioning scheme (1.8, etc)
                $javaMajor = [int]$matches[2]
            }
            $javaOK = $javaMajor -ge 17
            $javaVersion = "Java $javaMajor"
        }
        
        # Try to find JAVA_HOME
        $javaPath = [Environment]::GetEnvironmentVariable("JAVA_HOME", "Machine")
    } catch {
        $javaVersion = "Not found in PATH"
        Write-Log -Message "Java not found: $($_.Exception.Message)" -Level "WARNING"
    }
    
    $checks += @{
        Check = "Java JDK"
        Status = if ($javaOK) { "✓ $javaVersion" } else { "⚠ $javaVersion" }
        Required = "17+"
        Critical = $false
    }
    
    Write-StatusBox -Title "Java JDK" -Status $javaVersion `
        -Details $(if ($javaOK) { "JAVA_HOME: $javaPath" } else { "Will be installed if needed" }) `
        -Type $(if ($javaOK) { "Success" } else { "Warning" })
    
    # Check 4: Disk Space
    Write-Log -Message "Checking disk space" -Level "INFO"
    $diskCheck = Test-DiskSpace -Path "C:\" -RequiredGB 10
    
    $checks += @{
        Check = "Disk Space (C:)"
        Status = if ($diskCheck.Success) { "✓ $($diskCheck.FreeSpaceGB) GB free" } else { "✗ $($diskCheck.FreeSpaceGB) GB free" }
        Required = "10+ GB"
        Critical = $diskCheck.FreeSpaceGB -lt 5  # Critical if less than 5GB
    }
    
    Write-StatusBox -Title "Disk Space" -Status "$($diskCheck.FreeSpaceGB) GB available" `
        -Details "Required: $($diskCheck.RequiredGB) GB minimum" `
        -Type $(if ($diskCheck.Success) { "Success" } elseif ($diskCheck.FreeSpaceGB -lt 5) { "Error" } else { "Warning" })
    
    # Check 5: Network Connectivity
    Write-Log -Message "Checking network connectivity" -Level "INFO"
    $netCheck = Test-NetworkConnectivity
    
    $connectedCount = ($netCheck.Results | Where-Object { $_.Connected }).Count
    $totalCount = $netCheck.Results.Count
    $netStatus = "$connectedCount/$totalCount services reachable"
    
    $checks += @{
        Check = "Network"
        Status = if ($netCheck.AllConnected) { "✓ Connected" } else { "⚠ $netStatus" }
        Required = "Internet"
        Critical = $false
    }
    
    Write-StatusBox -Title "Network Connectivity" -Status $netStatus `
        -Details $(if ($netCheck.AllConnected) { "All required services accessible" } else { "Some services unreachable (may affect downloads)" }) `
        -Type $(if ($netCheck.AllConnected) { "Success" } else { "Warning" })
    
    # Check 6: PaperMC JAR in Downloads
    Write-Log -Message "Checking for PaperMC JAR in Downloads" -Level "INFO"
    $downloadsPath = Join-Path $env:USERPROFILE "Downloads"
    $paperJar = $null
    
    if (Test-Path $downloadsPath) {
        $paperJar = Get-ChildItem $downloadsPath -Filter "paper-*.jar" -ErrorAction SilentlyContinue | 
                    Sort-Object LastWriteTime -Descending | 
                    Select-Object -First 1
    }
    
    $paperOK = $null -ne $paperJar
    
    $checks += @{
        Check = "PaperMC JAR"
        Status = if ($paperOK) { "✓ Found" } else { "⚠ Not found" }
        Required = "In Downloads"
        Critical = $false
    }
    
    Write-StatusBox -Title "PaperMC JAR" `
        -Status $(if ($paperOK) { $paperJar.Name } else { "Not in Downloads folder" }) `
        -Details $(if ($paperOK) { "Size: $([math]::Round($paperJar.Length / 1MB, 2)) MB" } else { "Download from https://papermc.io/downloads" }) `
        -Type $(if ($paperOK) { "Success" } else { "Warning" })
    
    # Display summary table
    Write-Host ""
    Write-ResultsTable -Data $checks -Headers @("Check", "Status", "Required")
    
    # Evaluate results
    Write-Log -Message "Evaluating preflight check results" -Level "INFO"
    $criticalFailures = $checks | Where-Object { $_.Critical -and $_.Status -notmatch '✓' }
    $warnings = $checks | Where-Object { -not $_.Critical -and $_.Status -notmatch '✓' }
    
    Write-Host ""
    
    if ($criticalFailures.Count -gt 0) {
        Write-StatusBox -Title "Preflight Failed" -Status "$($criticalFailures.Count) critical issue(s) found" -Type "Error"
        Write-Log -Message "Preflight failed: $($criticalFailures.Count) critical issues" -Level "ERROR"
        
        Write-Host ""
        Write-Host "  Critical issues must be resolved before continuing:" -ForegroundColor Red
        foreach ($failure in $criticalFailures) {
            Write-Host "    • $($failure.Check): $($failure.Status)" -ForegroundColor Yellow
        }
        Write-Host ""
        
        return @{
            Success = $false
            Critical = $criticalFailures.Count
            Warnings = $warnings.Count
            CriticalIssues = $criticalFailures
        }
    }
    
    if ($warnings.Count -gt 0) {
        Write-StatusBox -Title "Preflight Warning" -Status "$($warnings.Count) non-critical issue(s) found" -Type "Warning"
        Write-Log -Message "Preflight completed with $($warnings.Count) warnings" -Level "WARNING"
        
        Write-Host ""
        Write-Host "  Non-critical issues detected:" -ForegroundColor Yellow
        foreach ($warning in $warnings) {
            Write-Host "    • $($warning.Check): $($warning.Status)" -ForegroundColor Gray
        }
        Write-Host ""
        
        $proceed = Read-Confirmation -Message "Continue installation despite warnings?" -DefaultYes
        if (-not $proceed) {
            Write-Log -Message "User chose not to continue with warnings" -Level "INFO"
            return @{
                Success = $false
                UserCancelled = $true
                Warnings = $warnings.Count
            }
        }
        
        Write-Log -Message "User chose to continue despite warnings" -Level "INFO"
    } else {
        Write-StatusBox -Title "Preflight Complete" -Status "All checks passed" -Type "Success"
        Write-Log -Message "All preflight checks passed successfully" -Level "SUCCESS"
    }
    
    return @{
        Success = $true
        Critical = 0
        Warnings = $warnings.Count
        AllPassed = $warnings.Count -eq 0
    }
}

# Export the function
Export-ModuleMember -Function Invoke-PreflightChecks
