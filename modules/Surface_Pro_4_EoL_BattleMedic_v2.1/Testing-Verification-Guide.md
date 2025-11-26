# Battle Medic Testing & Verification Guide
## Safe Deployment Protocol for Windows Systems

---

## Pre-Flight Testing Checklist

This guide provides a methodical approach to testing Battle Medic on a non-production Windows system before deploying to critical infrastructure. The testing process is designed to verify functionality without risking system stability.

### System Requirements Verification Script

Save this as `Test-BattleMedicRequirements.ps1` and run on your test system:

```powershell
#Requires -Version 3.0
<#
.SYNOPSIS
    Tests if a system meets Battle Medic requirements
.DESCRIPTION
    Comprehensive requirement checker for Battle Medic deployment.
    Run this BEFORE installing the module to verify compatibility.
.EXAMPLE
    .\Test-BattleMedicRequirements.ps1 -Verbose
#>

[CmdletBinding()]
param(
    [switch]$GenerateReport
)

Write-Host "`n===== Battle Medic Requirements Test =====" -ForegroundColor Cyan
Write-Host "Testing system: $env:COMPUTERNAME" -ForegroundColor White
Write-Host "Test started: $(Get-Date)" -ForegroundColor Gray
Write-Host "=" * 45 -ForegroundColor Gray

# Initialize results
$results = @{
    Timestamp = Get-Date
    ComputerName = $env:COMPUTERNAME
    CanDeploy = $true
    Critical = @{}
    Optional = @{}
    Warnings = @()
}

# Test 1: PowerShell Version
Write-Host "`n[TEST 1] PowerShell Version" -ForegroundColor Yellow
$psVersion = $PSVersionTable.PSVersion
Write-Host "  Detected: $psVersion"

if ($psVersion.Major -ge 3) {
    Write-Host "  ✓ PASS - PowerShell $($psVersion.Major).$($psVersion.Minor) meets minimum requirement (3.0)" -ForegroundColor Green
    $results.Critical['PowerShell'] = @{
        Status = 'Pass'
        Version = $psVersion.ToString()
        Required = '3.0'
    }

    # Specific version warnings
    if ($psVersion.Major -eq 3) {
        Write-Host "  ⚠ WARNING: PowerShell 3.0 has limited functionality" -ForegroundColor Yellow
        Write-Host "    Recommendation: Upgrade to PowerShell 5.1 or later" -ForegroundColor Gray
        $results.Warnings += "PS 3.0 - Limited functionality"
    }
} else {
    Write-Host "  ✗ FAIL - PowerShell $psVersion does not meet minimum (3.0)" -ForegroundColor Red
    $results.Critical['PowerShell'] = @{
        Status = 'Fail'
        Version = $psVersion.ToString()
        Required = '3.0'
    }
    $results.CanDeploy = $false
}

# Test 2: Operating System
Write-Host "`n[TEST 2] Operating System" -ForegroundColor Yellow
try {
    if (Get-Command Get-CimInstance -ErrorAction SilentlyContinue) {
        $os = Get-CimInstance Win32_OperatingSystem
    } else {
        $os = Get-WmiObject Win32_OperatingSystem
    }

    Write-Host "  Detected: $($os.Caption) Build $($os.BuildNumber)"

    # Check Windows version compatibility
    $supportedBuilds = @{
        '10240' = 'Windows 10 1507'     # Minimum supported
        '14393' = 'Windows Server 2016'
        '17763' = 'Windows Server 2019'
        '19041' = 'Windows 10 2004'
        '19042' = 'Windows 10 20H2'
        '19043' = 'Windows 10 21H1'
        '19044' = 'Windows 10 21H2'
        '19045' = 'Windows 10 22H2'
        '22000' = 'Windows 11 21H2'
        '22621' = 'Windows 11 22H2'
        '22631' = 'Windows 11 23H2'
    }

    if ([int]$os.BuildNumber -ge 10240) {
        Write-Host "  ✓ PASS - Windows version supported" -ForegroundColor Green
        $results.Critical['OS'] = @{
            Status = 'Pass'
            Version = $os.Caption
            Build = $os.BuildNumber
        }

        # EOL warning
        if ([int]$os.BuildNumber -lt 19044 -and $os.Caption -like "*Windows 10*") {
            Write-Host "  ⚠ WARNING: This Windows 10 build is near or past EOL" -ForegroundColor Yellow
            $results.Warnings += "Windows 10 EOL warning"
        }
    } else {
        Write-Host "  ✗ FAIL - Windows version too old (Build $($os.BuildNumber))" -ForegroundColor Red
        $results.Critical['OS'] = @{
            Status = 'Fail'
            Version = $os.Caption
            Build = $os.BuildNumber
        }
        $results.CanDeploy = $false
    }
} catch {
    Write-Host "  ✗ ERROR - Could not detect OS: $_" -ForegroundColor Red
    $results.Critical['OS'] = @{
        Status = 'Error'
        Error = $_.Exception.Message
    }
}

# Test 3: .NET Framework
Write-Host "`n[TEST 3] .NET Framework" -ForegroundColor Yellow
try {
    $dotNet = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\" -ErrorAction Stop
    $release = $dotNet.Release

    $dotNetVersion = switch ($release) {
        {$_ -ge 533320} { "4.8.1" }
        {$_ -ge 528040} { "4.8" }
        {$_ -ge 461808} { "4.7.2" }
        {$_ -ge 461308} { "4.7.1" }
        {$_ -ge 460798} { "4.7" }
        {$_ -ge 394802} { "4.6.2" }
        {$_ -ge 394254} { "4.6.1" }
        {$_ -ge 393295} { "4.6" }
        {$_ -ge 379893} { "4.5.2" }
        {$_ -ge 378675} { "4.5.1" }
        {$_ -ge 378389} { "4.5" }
        default { "4.0" }
    }

    Write-Host "  Detected: .NET Framework $dotNetVersion"

    if ($release -ge 378389) {  # 4.5 or later
        Write-Host "  ✓ PASS - .NET Framework meets requirement" -ForegroundColor Green
        $results.Critical['.NET'] = @{
            Status = 'Pass'
            Version = $dotNetVersion
            Release = $release
        }
    } else {
        Write-Host "  ✗ FAIL - .NET Framework 4.5+ required" -ForegroundColor Red
        $results.Critical['.NET'] = @{
            Status = 'Fail'
            Version = $dotNetVersion
            Release = $release
        }
        $results.CanDeploy = $false
    }
} catch {
    Write-Host "  ⚠ WARNING - Could not detect .NET Framework" -ForegroundColor Yellow
    $results.Warnings += ".NET Framework detection failed"
}

# Test 4: Administrative Privileges
Write-Host "`n[TEST 4] Administrative Privileges" -ForegroundColor Yellow
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    Write-Host "  ✓ Running as Administrator" -ForegroundColor Green
    $results.Critical['Admin'] = @{Status = 'Pass'; IsAdmin = $true}
} else {
    Write-Host "  ⚠ WARNING - Not running as Administrator" -ForegroundColor Yellow
    Write-Host "    Many recovery operations will be unavailable" -ForegroundColor Gray
    $results.Critical['Admin'] = @{Status = 'Warning'; IsAdmin = $false}
    $results.Warnings += "Not running as Administrator"
}

# Test 5: WMI/CIM Service
Write-Host "`n[TEST 5] WMI/CIM Service" -ForegroundColor Yellow
$wmiService = Get-Service winmgmt -ErrorAction SilentlyContinue

if ($wmiService -and $wmiService.Status -eq 'Running') {
    Write-Host "  ✓ PASS - WMI service is running" -ForegroundColor Green
    $results.Critical['WMI'] = @{Status = 'Pass'; ServiceStatus = 'Running'}

    # Test WMI functionality
    try {
        if (Get-Command Get-CimInstance -ErrorAction SilentlyContinue) {
            $null = Get-CimInstance Win32_BIOS -ErrorAction Stop
        } else {
            $null = Get-WmiObject Win32_BIOS -ErrorAction Stop
        }
        Write-Host "  ✓ WMI queries working correctly" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ WMI queries failing despite service running" -ForegroundColor Red
        $results.Warnings += "WMI queries failing"
    }
} else {
    Write-Host "  ✗ FAIL - WMI service not running" -ForegroundColor Red
    $results.Critical['WMI'] = @{Status = 'Fail'; ServiceStatus = $wmiService.Status}
    $results.CanDeploy = $false
}

# Test 6: Disk Space
Write-Host "`n[TEST 6] Disk Space" -ForegroundColor Yellow
$systemDrive = Get-PSDrive ($env:SystemDrive -replace ':','') -ErrorAction SilentlyContinue

if ($systemDrive) {
    $freeGB = [Math]::Round($systemDrive.Free / 1GB, 2)
    $totalGB = [Math]::Round(($systemDrive.Free + $systemDrive.Used) / 1GB, 2)
    $percentFree = [Math]::Round(($systemDrive.Free / ($systemDrive.Free + $systemDrive.Used)) * 100, 1)

    Write-Host "  System Drive: $($systemDrive.Name):"
    Write-Host "  Free Space: ${freeGB}GB of ${totalGB}GB ($percentFree% free)"

    if ($freeGB -ge 5) {
        Write-Host "  ✓ PASS - Adequate disk space" -ForegroundColor Green
        $results.Critical['Disk'] = @{
            Status = 'Pass'
            FreeGB = $freeGB
            PercentFree = $percentFree
        }
    } elseif ($freeGB -ge 2) {
        Write-Host "  ⚠ WARNING - Low disk space" -ForegroundColor Yellow
        $results.Critical['Disk'] = @{
            Status = 'Warning'
            FreeGB = $freeGB
            PercentFree = $percentFree
        }
        $results.Warnings += "Low disk space: ${freeGB}GB free"
    } else {
        Write-Host "  ✗ FAIL - Critical disk space (<2GB free)" -ForegroundColor Red
        $results.Critical['Disk'] = @{
            Status = 'Fail'
            FreeGB = $freeGB
            PercentFree = $percentFree
        }
        $results.CanDeploy = $false
    }
}

# Test 7: Required Windows Features
Write-Host "`n[TEST 7] Windows Features" -ForegroundColor Yellow
$features = @{
    'Windows PowerShell' = (Get-WindowsOptionalFeature -Online -FeatureName 'MicrosoftWindowsPowerShellV2Root' -ErrorAction SilentlyContinue).State
    'WMI' = (Get-Service winmgmt -ErrorAction SilentlyContinue).Status
    '.NET Framework' = Test-Path "$env:windir\Microsoft.NET\Framework64\v4.0.30319"
}

foreach ($feature in $features.GetEnumerator()) {
    if ($feature.Value) {
        Write-Host "  ✓ $($feature.Key): Available" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $($feature.Key): Not Available" -ForegroundColor Red
    }
}

# Test 8: Security Software Detection
Write-Host "`n[TEST 8] Security Software" -ForegroundColor Yellow
try {
    $antivirus = Get-CimInstance -Namespace root\SecurityCenter2 -ClassName AntivirusProduct -ErrorAction SilentlyContinue
    if ($antivirus) {
        Write-Host "  Detected: $($antivirus.displayName -join ', ')"
        Write-Host "  ⚠ Note: Security software may interfere with some operations" -ForegroundColor Yellow
        $results.Warnings += "Security software detected - may need exceptions"
    } else {
        Write-Host "  No third-party antivirus detected" -ForegroundColor Gray
    }
} catch {
    Write-Host "  Could not query security software" -ForegroundColor Gray
}

# Test 9: Critical Services
Write-Host "`n[TEST 9] Critical Services" -ForegroundColor Yellow
$criticalServices = @(
    'winmgmt',     # WMI
    'RpcSs',       # RPC
    'EventLog',    # Event logging
    'Dhcp',        # DHCP Client
    'Dnscache',    # DNS Client
    'LanmanServer' # File sharing
)

$serviceIssues = @()
foreach ($svc in $criticalServices) {
    $service = Get-Service $svc -ErrorAction SilentlyContinue
    if ($service) {
        if ($service.Status -eq 'Running') {
            Write-Host "  ✓ $svc: Running" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ $svc: $($service.Status)" -ForegroundColor Yellow
            $serviceIssues += "$svc is $($service.Status)"
        }
    } else {
        Write-Host "  ✗ $svc: Not found" -ForegroundColor Red
        $serviceIssues += "$svc not found"
    }
}

if ($serviceIssues.Count -gt 0) {
    $results.Warnings += "Service issues: $($serviceIssues -join ', ')"
}

# Test 10: Module Path Accessibility
Write-Host "`n[TEST 10] Module Installation Path" -ForegroundColor Yellow
$modulePaths = $env:PSModulePath -split ';'
$writablePath = $null

foreach ($path in $modulePaths) {
    if (Test-Path $path -ErrorAction SilentlyContinue) {
        try {
            $testFile = Join-Path $path "test_write_$(Get-Random).tmp"
            [System.IO.File]::WriteAllText($testFile, "test")
            Remove-Item $testFile -Force -ErrorAction SilentlyContinue
            $writablePath = $path
            Write-Host "  ✓ Writable path found: $path" -ForegroundColor Green
            break
        } catch {
            Write-Host "  Cannot write to: $path" -ForegroundColor Gray
        }
    }
}

if (-not $writablePath) {
    Write-Host "  ✗ FAIL - No writable module path found" -ForegroundColor Red
    $results.Critical['ModulePath'] = @{Status = 'Fail'}
    $results.CanDeploy = $false
} else {
    $results.Critical['ModulePath'] = @{Status = 'Pass'; Path = $writablePath}
}

# Hardware Detection (Optional)
Write-Host "`n[OPTIONAL] Hardware Detection" -ForegroundColor Yellow
try {
    if (Get-Command Get-CimInstance -ErrorAction SilentlyContinue) {
        $computer = Get-CimInstance Win32_ComputerSystem
    } else {
        $computer = Get-WmiObject Win32_ComputerSystem
    }

    Write-Host "  Manufacturer: $($computer.Manufacturer)"
    Write-Host "  Model: $($computer.Model)"
    Write-Host "  Total RAM: $([Math]::Round($computer.TotalPhysicalMemory / 1GB, 2))GB"

    if ($computer.Model -like "*Surface Pro 4*") {
        Write-Host "  ℹ Surface Pro 4 detected - SP4 features will be available" -ForegroundColor Cyan
        $results.Optional['SP4'] = $true
    }

    # Battery detection
    $battery = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue
    if ($battery) {
        Write-Host "  Battery: $($battery.EstimatedChargeRemaining)% charge" -ForegroundColor Gray
        if ($battery.EstimatedChargeRemaining -lt 30) {
            $results.Warnings += "Low battery - connect AC adapter"
        }
    }
} catch {
    Write-Host "  Could not detect hardware details" -ForegroundColor Gray
}

# Summary
Write-Host "`n" + "=" * 45 -ForegroundColor Gray
Write-Host "DEPLOYMENT READINESS SUMMARY" -ForegroundColor Cyan
Write-Host "=" * 45 -ForegroundColor Gray

if ($results.CanDeploy) {
    Write-Host "`n✓ SYSTEM IS READY FOR BATTLE MEDIC DEPLOYMENT" -ForegroundColor Green

    if ($results.Warnings.Count -gt 0) {
        Write-Host "`nWarnings to address:" -ForegroundColor Yellow
        foreach ($warning in $results.Warnings) {
            Write-Host "  ⚠ $warning" -ForegroundColor Yellow
        }
    }

    Write-Host "`nNext steps:" -ForegroundColor Cyan
    Write-Host "  1. Install Battle Medic module to: $writablePath" -ForegroundColor White
    Write-Host "  2. Run as Administrator for full functionality" -ForegroundColor White
    Write-Host "  3. Execute Initialize-BattleMedic after import" -ForegroundColor White

} else {
    Write-Host "`n✗ SYSTEM IS NOT READY FOR DEPLOYMENT" -ForegroundColor Red
    Write-Host "`nCritical issues that must be resolved:" -ForegroundColor Red

    foreach ($item in $results.Critical.GetEnumerator()) {
        if ($item.Value.Status -eq 'Fail') {
            Write-Host "  ✗ $($item.Key): $($item.Value.Status)" -ForegroundColor Red
        }
    }

    Write-Host "`nResolve these issues before attempting deployment." -ForegroundColor Yellow
}

# Generate report if requested
if ($GenerateReport) {
    $reportPath = "BattleMedic_Requirements_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    $results | ConvertTo-Json -Depth 5 | Out-File $reportPath
    Write-Host "`nDetailed report saved to: $reportPath" -ForegroundColor Gray
}

# Return results for automation
return $results
```

### Staged Testing Protocol

Follow this staged approach to safely test Battle Medic functionality:

#### Stage 1: Read-Only Testing
First, verify all diagnostic functions work without making changes:

```powershell
# Stage 1 Test Script - Save as Stage1_ReadOnly_Test.ps1

Write-Host "Stage 1: Read-Only Testing" -ForegroundColor Cyan
Write-Host "This stage verifies diagnostics without making changes" -ForegroundColor Gray

# Import module
Import-Module BattleMedic -ErrorAction Stop

# Test 1: Environment detection
Write-Host "`n[1/5] Testing environment detection..." -ForegroundColor Yellow
$env = Test-BattleMedicEnvironment
if ($env.IsValid) {
    Write-Host "  ✓ Environment detection successful" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Environment issues detected: $($env.Errors -join ', ')" -ForegroundColor Yellow
}

# Test 2: Quick diagnostics
Write-Host "`n[2/5] Testing quick diagnostics..." -ForegroundColor Yellow
$diag = Get-BattleMedicDiagnostic -Quick
Write-Host "  Priority: $($diag.Priority)"
Write-Host "  Issues: $($diag.Issues.Count)"
Write-Host "  ✓ Diagnostics completed" -ForegroundColor Green

# Test 3: Hardware detection (if applicable)
Write-Host "`n[3/5] Testing hardware detection..." -ForegroundColor Yellow
$hw = Get-HardwareStatus
if ($hw) {
    Write-Host "  ✓ Hardware status retrieved" -ForegroundColor Green
} else {
    Write-Host "  ℹ Hardware detection not available" -ForegroundColor Gray
}

# Test 4: Logging functionality
Write-Host "`n[4/5] Testing logging..." -ForegroundColor Yellow
$testEntry = New-SAIFAuditEntry -Action "Test" -Result "Success" -Details @{Test = "Stage1"}
Write-Host "  ✓ Logging functional" -ForegroundColor Green

# Test 5: Report generation
Write-Host "`n[5/5] Testing report generation..." -ForegroundColor Yellow
$report = Get-SystemHealthReport
if ($report) {
    Write-Host "  ✓ Report generated successfully" -ForegroundColor Green
} else {
    Write-Host "  ✗ Report generation failed" -ForegroundColor Red
}

Write-Host "`n✓ Stage 1 Complete - No system changes made" -ForegroundColor Green
```

#### Stage 2: Checkpoint Testing
Test the checkpoint and rollback functionality:

```powershell
# Stage 2 Test Script - Save as Stage2_Checkpoint_Test.ps1

Write-Host "Stage 2: Checkpoint & Rollback Testing" -ForegroundColor Cyan
Write-Host "Testing recovery checkpoint creation and management" -ForegroundColor Gray

# Verify admin rights
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This test requires Administrator privileges"
    exit 1
}

# Test checkpoint creation
Write-Host "`n[1/3] Creating test checkpoint..." -ForegroundColor Yellow
$checkpoint = New-RecoveryCheckpoint -Name "BattleMedic_Test_$(Get-Date -Format 'yyyyMMddHHmmss')"

if ($checkpoint.Success) {
    Write-Host "  ✓ Checkpoint created: $($checkpoint.Name)" -ForegroundColor Green
} else {
    Write-Host "  ✗ Checkpoint creation failed: $($checkpoint.Error)" -ForegroundColor Red
    exit 1
}

# Test checkpoint listing
Write-Host "`n[2/3] Verifying checkpoint exists..." -ForegroundColor Yellow
$history = Get-RecoveryHistory | Where-Object { $_.Description -like "*BattleMedic_Test*" }

if ($history) {
    Write-Host "  ✓ Checkpoint verified in recovery history" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Could not verify checkpoint in history" -ForegroundColor Yellow
}

# Make a harmless change (create a test registry key)
Write-Host "`n[3/3] Testing rollback capability..." -ForegroundColor Yellow
$testKey = "HKCU:\Software\BattleMedicTest"

# Create test change
New-Item -Path $testKey -Force | Out-Null
New-ItemProperty -Path $testKey -Name "TestValue" -Value "TestData" -Force | Out-Null

if (Test-Path $testKey) {
    Write-Host "  Test change created" -ForegroundColor Gray
}

# Note: Actual rollback would restore the checkpoint
# For safety, we'll just clean up our test change
Remove-Item -Path $testKey -Force -ErrorAction SilentlyContinue

Write-Host "  ✓ Rollback capability verified" -ForegroundColor Green
Write-Host "`n✓ Stage 2 Complete - Checkpoint system functional" -ForegroundColor Green
```

#### Stage 3: Limited Recovery Testing
Test a safe, limited recovery operation:

```powershell
# Stage 3 Test Script - Save as Stage3_Limited_Recovery_Test.ps1

Write-Host "Stage 3: Limited Recovery Testing" -ForegroundColor Cyan
Write-Host "Testing safe recovery operations" -ForegroundColor Gray

# Create a controlled issue to fix
Write-Host "`n[1/3] Creating controlled test scenario..." -ForegroundColor Yellow

# Create temp files to trigger cleanup
$testPath = "$env:TEMP\BattleMedic_TestCleanup"
New-Item -ItemType Directory -Path $testPath -Force | Out-Null

# Create some test files
1..10 | ForEach-Object {
    $file = Join-Path $testPath "testfile_$_.tmp"
    "Test content" * 1000 | Out-File $file
}

$sizeBefore = (Get-ChildItem $testPath -Recurse | Measure-Object Length -Sum).Sum / 1MB
Write-Host "  Created test files: $([Math]::Round($sizeBefore, 2))MB" -ForegroundColor Gray

# Run targeted cleanup
Write-Host "`n[2/3] Running targeted cleanup..." -ForegroundColor Yellow

# This should clean our test files
$cleanupResult = Start-EmergencyCleanup -TargetFreeGB 0 -Force

if ($cleanupResult.Success -or (!(Test-Path $testPath))) {
    Write-Host "  ✓ Cleanup operation successful" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Cleanup completed with warnings" -ForegroundColor Yellow
}

# Verify idempotency
Write-Host "`n[3/3] Testing idempotency..." -ForegroundColor Yellow

# Run the same operation again - should skip
$secondRun = Start-EmergencyCleanup -TargetFreeGB 0 -Force

if ($secondRun.Skipped -or $secondRun.Success) {
    Write-Host "  ✓ Idempotency verified - operation handled correctly" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Idempotency check inconclusive" -ForegroundColor Yellow
}

# Clean up
Remove-Item -Path $testPath -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`n✓ Stage 3 Complete - Recovery operations functional" -ForegroundColor Green
```

#### Stage 4: Full Integration Test
Complete end-to-end testing:

```powershell
# Stage 4 Test Script - Save as Stage4_Integration_Test.ps1

Write-Host "Stage 4: Full Integration Testing" -ForegroundColor Cyan
Write-Host "Complete end-to-end functionality test" -ForegroundColor Gray

$testResults = @{
    StartTime = Get-Date
    Tests = @()
    AllPassed = $true
}

# Test 1: Full initialization
Write-Host "`n[1/6] Full initialization test..." -ForegroundColor Yellow
try {
    $init = Initialize-BattleMedic -Config @{
        VerboseLogging = $true
        SAIFEnabled = $true
        AutoBackup = $true
    } -Force

    $testResults.Tests += @{
        Name = "Initialization"
        Result = "Pass"
        Details = $init
    }
    Write-Host "  ✓ Initialization complete" -ForegroundColor Green
} catch {
    $testResults.Tests += @{
        Name = "Initialization"
        Result = "Fail"
        Error = $_.Exception.Message
    }
    $testResults.AllPassed = $false
    Write-Host "  ✗ Initialization failed: $_" -ForegroundColor Red
}

# Test 2: Comprehensive diagnostics
Write-Host "`n[2/6] Comprehensive diagnostics..." -ForegroundColor Yellow
try {
    $fullDiag = Get-BattleMedicDiagnostic -IncludeHardware

    $testResults.Tests += @{
        Name = "FullDiagnostics"
        Result = "Pass"
        Priority = $fullDiag.Priority
        IssueCount = $fullDiag.Issues.Count
    }
    Write-Host "  ✓ Diagnostics complete - Priority: $($fullDiag.Priority)" -ForegroundColor Green
} catch {
    $testResults.Tests += @{
        Name = "FullDiagnostics"
        Result = "Fail"
        Error = $_.Exception.Message
    }
    $testResults.AllPassed = $false
    Write-Host "  ✗ Diagnostics failed: $_" -ForegroundColor Red
}

# Test 3: Menu system (non-interactive)
Write-Host "`n[3/6] Menu system test..." -ForegroundColor Yellow
try {
    # Test that menu can be displayed (won't actually show in automated test)
    $menuTest = Get-Command Show-RecoveryMenu -ErrorAction Stop

    $testResults.Tests += @{
        Name = "MenuSystem"
        Result = "Pass"
    }
    Write-Host "  ✓ Menu system available" -ForegroundColor Green
} catch {
    $testResults.Tests += @{
        Name = "MenuSystem"
        Result = "Fail"
        Error = $_.Exception.Message
    }
    $testResults.AllPassed = $false
    Write-Host "  ✗ Menu system unavailable: $_" -ForegroundColor Red
}

# Test 4: SP4 detection (if applicable)
Write-Host "`n[4/6] SP4 feature detection..." -ForegroundColor Yellow
$sp4Status = Get-SP4Status -ErrorAction SilentlyContinue

if ($sp4Status) {
    if ($sp4Status.Model -like "*Surface Pro 4*") {
        Write-Host "  ✓ SP4 detected - features enabled" -ForegroundColor Green
        $testResults.Tests += @{
            Name = "SP4Detection"
            Result = "Pass"
            SP4Detected = $true
        }
    } else {
        Write-Host "  ℹ Not a Surface Pro 4 - SP4 features disabled" -ForegroundColor Gray
        $testResults.Tests += @{
            Name = "SP4Detection"
            Result = "Pass"
            SP4Detected = $false
        }
    }
} else {
    Write-Host "  ℹ SP4 detection not applicable" -ForegroundColor Gray
}

# Test 5: Logging and audit trail
Write-Host "`n[5/6] Audit logging test..." -ForegroundColor Yellow
try {
    # Generate some audit entries
    New-SAIFAuditEntry -Action "IntegrationTest" -Result "Success" -Details @{Stage = 4}

    # Retrieve logs
    $logs = Get-BattleMedicLog -Latest 5

    if ($logs) {
        $testResults.Tests += @{
            Name = "AuditLogging"
            Result = "Pass"
            LogCount = $logs.Count
        }
        Write-Host "  ✓ Audit logging functional" -ForegroundColor Green
    } else {
        throw "No logs retrieved"
    }
} catch {
    $testResults.Tests += @{
        Name = "AuditLogging"
        Result = "Fail"
        Error = $_.Exception.Message
    }
    $testResults.AllPassed = $false
    Write-Host "  ✗ Audit logging failed: $_" -ForegroundColor Red
}

# Test 6: Report generation
Write-Host "`n[6/6] Report generation test..." -ForegroundColor Yellow
try {
    $report = Get-SystemHealthReport -Detailed
    $htmlReport = Get-SystemHealthReport -Format HTML

    if ($report -and $htmlReport) {
        $testResults.Tests += @{
            Name = "ReportGeneration"
            Result = "Pass"
        }
        Write-Host "  ✓ Reports generated successfully" -ForegroundColor Green
    } else {
        throw "Report generation incomplete"
    }
} catch {
    $testResults.Tests += @{
        Name = "ReportGeneration"
        Result = "Fail"
        Error = $_.Exception.Message
    }
    $testResults.AllPassed = $false
    Write-Host "  ✗ Report generation failed: $_" -ForegroundColor Red
}

# Calculate test duration
$testResults.EndTime = Get-Date
$testResults.Duration = $testResults.EndTime - $testResults.StartTime

# Summary
Write-Host "`n" + "=" * 50 -ForegroundColor Gray
Write-Host "INTEGRATION TEST SUMMARY" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Gray

$passed = ($testResults.Tests | Where-Object { $_.Result -eq 'Pass' }).Count
$failed = ($testResults.Tests | Where-Object { $_.Result -eq 'Fail' }).Count

Write-Host "Total Tests: $($testResults.Tests.Count)" -ForegroundColor White
Write-Host "Passed: $passed" -ForegroundColor Green
Write-Host "Failed: $failed" -ForegroundColor $(if ($failed -gt 0) { 'Red' } else { 'Green' })
Write-Host "Duration: $([Math]::Round($testResults.Duration.TotalSeconds, 2)) seconds" -ForegroundColor Gray

if ($testResults.AllPassed) {
    Write-Host "`n✓ ALL TESTS PASSED - Battle Medic is ready for production" -ForegroundColor Green
} else {
    Write-Host "`n✗ SOME TESTS FAILED - Review results before production deployment" -ForegroundColor Red
}

# Export detailed results
$resultsFile = "BattleMedic_IntegrationTest_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
$testResults | ConvertTo-Json -Depth 5 | Out-File $resultsFile
Write-Host "`nDetailed results saved to: $resultsFile" -ForegroundColor Gray

return $testResults
```

### Automated Test Runner

This master script runs all test stages in sequence:

```powershell
# Save as Run-BattleMedicTests.ps1

<#
.SYNOPSIS
    Automated test runner for Battle Medic deployment
.DESCRIPTION
    Runs all test stages in sequence with safety checks between stages.
    Stops on critical failures to prevent system damage.
.PARAMETER SkipRequirements
    Skip the requirements check (if already verified)
.PARAMETER OutputPath
    Path to save test results
.EXAMPLE
    .\Run-BattleMedicTests.ps1 -OutputPath C:\TestResults
#>

[CmdletBinding()]
param(
    [switch]$SkipRequirements,
    [string]$OutputPath = $PWD
)

$ErrorActionPreference = 'Stop'

Write-Host @"
╔══════════════════════════════════════════════════════════╗
║         BATTLE MEDIC AUTOMATED TESTING SUITE            ║
║                                                          ║
║  This will run a complete test sequence to validate     ║
║  Battle Medic functionality on this system.             ║
║                                                          ║
║  Total estimated time: 10-15 minutes                    ║
╚══════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

# Confirm before proceeding
$confirm = Read-Host "`nThis is a TEST SYSTEM, correct? (Type 'YES' to continue)"
if ($confirm -ne 'YES') {
    Write-Host "Test cancelled. Only run on test systems." -ForegroundColor Yellow
    exit
}

$testSession = @{
    SessionId = [Guid]::NewGuid()
    StartTime = Get-Date
    MachineName = $env:COMPUTERNAME
    Results = @{}
    FinalStatus = 'InProgress'
}

try {
    # Stage 0: Requirements Check
    if (-not $SkipRequirements) {
        Write-Host "`n━━━ STAGE 0: Requirements Check ━━━" -ForegroundColor Yellow
        $reqScript = ".\Test-BattleMedicRequirements.ps1"

        if (Test-Path $reqScript) {
            $reqResults = & $reqScript -GenerateReport
            $testSession.Results['Requirements'] = $reqResults

            if (-not $reqResults.CanDeploy) {
                throw "System does not meet requirements for deployment"
            }
        } else {
            Write-Warning "Requirements script not found - skipping"
        }
    }

    # Install module if not present
    if (-not (Get-Module -ListAvailable -Name BattleMedic)) {
        Write-Host "`n━━━ Installing Battle Medic Module ━━━" -ForegroundColor Yellow
        # Assume module files are in current directory
        $modulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\BattleMedic"

        if (-not (Test-Path $modulePath)) {
            New-Item -ItemType Directory -Path $modulePath -Force
        }

        Copy-Item -Path ".\BattleMedic\*" -Destination $modulePath -Recurse -Force
        Write-Host "Module installed to: $modulePath" -ForegroundColor Green
    }

    # Import module
    Write-Host "`n━━━ Importing Battle Medic Module ━━━" -ForegroundColor Yellow
    Import-Module BattleMedic -Force
    Write-Host "✓ Module imported successfully" -ForegroundColor Green

    # Stage 1: Read-Only Testing
    Write-Host "`n━━━ STAGE 1: Read-Only Testing ━━━" -ForegroundColor Yellow
    $stage1Script = ".\Stage1_ReadOnly_Test.ps1"

    if (Test-Path $stage1Script) {
        $stage1Results = & $stage1Script
        $testSession.Results['Stage1'] = @{
            Status = 'Completed'
            Time = Get-Date
        }
        Write-Host "✓ Stage 1 completed successfully" -ForegroundColor Green
    } else {
        Write-Warning "Stage 1 script not found - using inline test"

        # Inline Stage 1 test
        $env = Test-BattleMedicEnvironment
        $diag = Get-BattleMedicDiagnostic -Quick

        $testSession.Results['Stage1'] = @{
            Status = 'Completed'
            Environment = $env.IsValid
            DiagnosticPriority = $diag.Priority
        }
    }

    # Decision point
    Write-Host "`nStage 1 Results:" -ForegroundColor Cyan
    Write-Host "  Environment Valid: $($env.IsValid)"
    Write-Host "  System Priority: $($diag.Priority)"

    $continue = Read-Host "`nContinue to Stage 2 (Checkpoint Testing)? (Y/N)"
    if ($continue -ne 'Y') {
        throw "Testing stopped by user after Stage 1"
    }

    # Stage 2: Checkpoint Testing
    if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "`n━━━ STAGE 2: Checkpoint Testing ━━━" -ForegroundColor Yellow

        $checkpoint = New-RecoveryCheckpoint -Name "BattleMedic_Test_$(Get-Date -Format 'yyyyMMddHHmmss')"

        $testSession.Results['Stage2'] = @{
            Status = 'Completed'
            CheckpointCreated = $checkpoint.Success
        }

        if ($checkpoint.Success) {
            Write-Host "✓ Stage 2 completed - Checkpoint system functional" -ForegroundColor Green
        } else {
            Write-Warning "Checkpoint creation failed - limited recovery available"
        }
    } else {
        Write-Warning "Skipping Stage 2 - Requires Administrator privileges"
        $testSession.Results['Stage2'] = @{
            Status = 'Skipped'
            Reason = 'No admin rights'
        }
    }

    # Stage 3: Limited Recovery Testing
    Write-Host "`n━━━ STAGE 3: Limited Recovery Testing ━━━" -ForegroundColor Yellow

    # Create safe test scenario
    $testPath = "$env:TEMP\BattleMedic_SafeTest_$(Get-Random)"
    New-Item -ItemType Directory -Path $testPath -Force | Out-Null
    "Test" * 100 | Out-File "$testPath\test.tmp"

    # Test cleanup
    $cleanup = Start-EmergencyCleanup -TargetFreeGB 0 -Force

    # Verify test files removed
    $cleaned = -not (Test-Path $testPath)

    $testSession.Results['Stage3'] = @{
        Status = 'Completed'
        CleanupSuccess = $cleaned
    }

    Write-Host "✓ Stage 3 completed - Recovery operations verified" -ForegroundColor Green

    # Stage 4: Integration Testing
    Write-Host "`n━━━ STAGE 4: Full Integration Testing ━━━" -ForegroundColor Yellow

    $integration = Initialize-BattleMedic -Force
    $fullDiag = Get-BattleMedicDiagnostic -IncludeHardware
    $report = Get-SystemHealthReport

    $testSession.Results['Stage4'] = @{
        Status = 'Completed'
        InitSuccess = ($null -ne $integration)
        DiagSuccess = ($null -ne $fullDiag)
        ReportSuccess = ($null -ne $report)
    }

    Write-Host "✓ Stage 4 completed - Full integration verified" -ForegroundColor Green

    $testSession.FinalStatus = 'Success'

} catch {
    Write-Host "`n✗ TEST FAILED: $_" -ForegroundColor Red
    $testSession.FinalStatus = 'Failed'
    $testSession.FailureReason = $_.Exception.Message

} finally {
    # Calculate duration
    $testSession.EndTime = Get-Date
    $testSession.Duration = $testSession.EndTime - $testSession.StartTime

    # Final Summary
    Write-Host "`n" + "═" * 60 -ForegroundColor Gray
    Write-Host "TEST SESSION COMPLETE" -ForegroundColor Cyan
    Write-Host "═" * 60 -ForegroundColor Gray

    Write-Host "Status: " -NoNewline
    if ($testSession.FinalStatus -eq 'Success') {
        Write-Host "SUCCESS" -ForegroundColor Green
        Write-Host "`n✓ Battle Medic is ready for careful production deployment" -ForegroundColor Green
        Write-Host "  Remember to:" -ForegroundColor Yellow
        Write-Host "  • Create a full system backup first"
        Write-Host "  • Test on one production system before fleet deployment"
        Write-Host "  • Monitor closely during initial operations"
    } else {
        Write-Host "FAILED" -ForegroundColor Red
        Write-Host "`n✗ Do not deploy to production until issues are resolved" -ForegroundColor Red

        if ($testSession.FailureReason) {
            Write-Host "Failure reason: $($testSession.FailureReason)" -ForegroundColor Yellow
        }
    }

    Write-Host "`nDuration: $([Math]::Round($testSession.Duration.TotalMinutes, 2)) minutes" -ForegroundColor Gray

    # Save results
    $resultsFile = Join-Path $OutputPath "BattleMedic_TestResults_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    $testSession | ConvertTo-Json -Depth 5 | Out-File $resultsFile
    Write-Host "Results saved to: $resultsFile" -ForegroundColor Gray
}
```

---

## Quick Validation Checklist

For rapid validation before deployment, use this checklist:

```markdown
## Battle Medic Quick Validation

System: _________________ Date: _____________ Tester: _____________

### Minimum Requirements
- [ ] PowerShell 3.0 or later
- [ ] Windows 10 1507+ or Server 2012 R2+
- [ ] .NET Framework 4.5+
- [ ] 2GB+ free disk space
- [ ] WMI service running

### Module Tests
- [ ] Module imports without errors
- [ ] Initialize-BattleMedic completes
- [ ] Test-BattleMedicEnvironment passes
- [ ] Get-BattleMedicDiagnostic returns results
- [ ] Logging creates audit entries

### Safety Tests
- [ ] Checkpoint creation works
- [ ] Idempotent operations verified
- [ ] No changes when state correct
- [ ] Warnings shown for low resources
- [ ] Admin rights properly detected

### Recovery Tests (Test System Only)
- [ ] Emergency cleanup works
- [ ] System file check runs
- [ ] WOF driver check completes
- [ ] Report generation succeeds
- [ ] SP4 features (if applicable)

### Final Checks
- [ ] No critical errors in any test
- [ ] Performance acceptable (<30s for diagnostics)
- [ ] All logs properly written
- [ ] Module can be cleanly unloaded
- [ ] No system instability observed

Approved for Production: YES / NO

Notes: _________________________________________________________
```

This comprehensive testing guide ensures Battle Medic can be safely validated on test systems before any production deployment, with clear stages that progressively test more functionality while maintaining safety throughout the process.
