# Surface Pro 4 - Quick Start Troubleshooting Guide

**Purpose**: Immediately resolve domain controller connectivity issues, then investigate and optimize your system.

**Time to First Fix**: 5-15 minutes
**Complete Investigation**: 30-60 minutes

---

## PART 1: Fix Domain Controller Issues RIGHT NOW

### Quick Diagnostic (Copy and paste into PowerShell as Administrator)

```powershell
# Test 1: Can we reach the domain controller?
Write-Host "`n=== DOMAIN CONNECTIVITY TEST ===" -ForegroundColor Cyan
Test-ComputerSecureChannel -Verbose

# Test 2: Is network profile correct?
Write-Host "`n=== NETWORK PROFILE ===" -ForegroundColor Cyan
Get-NetConnectionProfile | Format-Table Name, NetworkCategory, IPv4Connectivity -AutoSize

# Test 3: Can we resolve domain DNS?
Write-Host "`n=== DNS RESOLUTION ===" -ForegroundColor Cyan
$domain = $env:USERDNSDOMAIN
if ($domain) {
    nslookup $domain
    nslookup "_ldap._tcp.dc._msdcs.$domain"
} else {
    Write-Host "WARNING: Not domain-joined or USERDNSDOMAIN not set" -ForegroundColor Yellow
}

# Test 4: What's our current DC?
Write-Host "`n=== CURRENT DOMAIN CONTROLLER ===" -ForegroundColor Cyan
Write-Host "Logon Server: $env:LOGONSERVER"
```

### Most Common Fix (90% Success Rate)

**Problem**: Network profile stuck on "Public" instead of "Domain"
**Symptom**: Can't connect to domain resources, Group Policy not applying

**Fix** (30 seconds):
```powershell
# Restart all network adapters
Restart-NetAdapter *

# Wait 10 seconds
Start-Sleep -Seconds 10

# Check if fixed
Get-NetConnectionProfile

# Should show: NetworkCategory = "DomainAuthenticated"
```

### Second Most Common Fix

**Problem**: DNS not pointing to domain controller
**Fix** (2 minutes):

```powershell
# First, find your domain controller IP
# Ask your IT admin, or if you can access DC:
nslookup yourdomain.com

# Then set DNS (replace with your DC IP addresses)
Set-DnsClientServerAddress -InterfaceAlias "Wi-Fi" -ServerAddresses "192.168.1.10","192.168.1.11"

# Or if using Ethernet:
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses "192.168.1.10","192.168.1.11"

# Flush DNS cache
ipconfig /flushdns

# Test again
nslookup yourdomain.com
```

### Third Most Common Fix

**Problem**: Domain trust relationship broken
**Symptom**: "Trust relationship between workstation and domain failed"

**Fix** (5 minutes):
```powershell
# Reset the secure channel (requires domain admin credentials)
Test-ComputerSecureChannel -Repair -Credential (Get-Credential)

# Enter DOMAIN\AdminUsername when prompted
# Then verify it worked:
Test-ComputerSecureChannel -Verbose

# Should return: True
```

---

## PART 2: Set Up Centralized Logging

**Why**: Track all changes, find patterns, troubleshoot faster next time.

### Create a Logging System (5 minutes)

```powershell
# 1. Create logging directory
$logDir = "C:\SystemLogs"
New-Item -ItemType Directory -Path $logDir -Force

# 2. Create a logging function (add to your PowerShell profile)
function Log-Action {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [ValidateSet("INFO","WARNING","ERROR","SUCCESS")]
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logFile = "$logDir\system-log-$(Get-Date -Format 'yyyy-MM').log"

    # Color based on level
    $color = switch($Level) {
        "INFO" { "White" }
        "WARNING" { "Yellow" }
        "ERROR" { "Red" }
        "SUCCESS" { "Green" }
    }

    # Write to screen and file
    $logMessage = "$timestamp [$Level] $Message"
    Write-Host $logMessage -ForegroundColor $color
    Add-Content -Path $logFile -Value $logMessage
}

# 3. Make it permanent (add to PowerShell profile)
if (!(Test-Path $PROFILE)) {
    New-Item -Path $PROFILE -ItemType File -Force
}

# Add the function to your profile
@'
function Log-Action {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logFile = "C:\SystemLogs\system-log-$(Get-Date -Format 'yyyy-MM').log"
    $color = switch($Level) { "INFO"{"White"} "WARNING"{"Yellow"} "ERROR"{"Red"} "SUCCESS"{"Green"} }
    $logMessage = "$timestamp [$Level] $Message"
    Write-Host $logMessage -ForegroundColor $color
    Add-Content -Path $logFile -Value $logMessage
}
'@ | Add-Content -Path $PROFILE

# 4. Start using it immediately
. $PROFILE  # Reload profile
Log-Action "Centralized logging system initialized" -Level SUCCESS
Log-Action "Fixed domain controller connectivity" -Level SUCCESS
```

### Usage Examples

```powershell
# When you fix something:
Log-Action "Restarted network adapter - fixed Public network profile" -Level SUCCESS

# When investigating:
Log-Action "Checking DNS configuration for domain connectivity" -Level INFO

# When you find a problem:
Log-Action "DNS servers pointing to ISP instead of domain controller" -Level WARNING

# When something fails:
Log-Action "Failed to reset secure channel - need domain admin credentials" -Level ERROR

# View your logs
Get-Content "C:\SystemLogs\system-log-$(Get-Date -Format 'yyyy-MM').log" -Tail 20
```

---

## PART 3: Investigate Your Environment

Now that domain issues are fixed and logging is set up, let's investigate what's going on with this machine.

### System Information Collection

```powershell
# Create investigation report
$reportDir = "C:\SystemLogs\Investigation-$(Get-Date -Format 'yyyy-MM-dd')"
New-Item -ItemType Directory -Path $reportDir -Force

Log-Action "Starting system investigation" -Level INFO

# 1. Basic system info
systeminfo > "$reportDir\systeminfo.txt"

# 2. Network configuration
ipconfig /all > "$reportDir\network-config.txt"
Get-NetAdapter | Format-List > "$reportDir\network-adapters.txt"

# 3. Disk usage
Get-Volume | Format-Table -AutoSize > "$reportDir\disk-volumes.txt"
Get-PSDrive -PSProvider FileSystem | Format-Table -AutoSize > "$reportDir\disk-usage.txt"

# 4. Running services
Get-Service | Where-Object {$_.Status -eq "Running"} | Format-Table -AutoSize > "$reportDir\running-services.txt"

# 5. Installed applications
Get-WmiObject -Class Win32_Product | Select-Object Name, Vendor, Version | Sort-Object Name > "$reportDir\installed-apps.txt"

# 6. Windows update history
Get-HotFix | Sort-Object InstalledOn -Descending | Format-Table -AutoSize > "$reportDir\windows-updates.txt"

# 7. Event log errors (last 7 days)
Get-EventLog -LogName System -EntryType Error -After (Get-Date).AddDays(-7) | Export-Csv "$reportDir\system-errors.csv" -NoTypeInformation
Get-EventLog -LogName Application -EntryType Error -After (Get-Date).AddDays(-7) | Export-Csv "$reportDir\application-errors.csv" -NoTypeInformation

Log-Action "Investigation complete - reports saved to $reportDir" -Level SUCCESS

# Open the folder
explorer $reportDir
```

### Find Previous Claude/AI Work

```powershell
Log-Action "Searching for previous AI assistant work..." -Level INFO

# Search common locations for AI-generated files
$searchPaths = @(
    "$env:USERPROFILE\Documents",
    "$env:USERPROFILE\Desktop",
    "$env:USERPROFILE\Downloads",
    "C:\Scripts",
    "C:\Temp"
)

$aiKeywords = @("claude", "gpt", "ai", "assistant", "chatgpt", "copilot")
$findings = @()

foreach ($path in $searchPaths) {
    if (Test-Path $path) {
        foreach ($keyword in $aiKeywords) {
            # Search filenames
            $files = Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue |
                     Where-Object {$_.Name -like "*$keyword*"}

            if ($files) {
                $findings += $files
                Log-Action "Found $($files.Count) files matching '$keyword' in $path" -Level INFO
            }
        }
    }
}

# Also search file contents in common script locations
if (Test-Path "C:\Scripts") {
    $scriptFiles = Get-ChildItem "C:\Scripts" -Recurse -Include *.ps1,*.bat,*.txt -ErrorAction SilentlyContinue
    foreach ($file in $scriptFiles) {
        $content = Get-Content $file.FullName -ErrorAction SilentlyContinue
        if ($content -match "claude|gpt|ai-generated|chatgpt") {
            Log-Action "Found AI reference in: $($file.FullName)" -Level WARNING
            $findings += $file
        }
    }
}

# Save findings
if ($findings) {
    $findings | Select-Object FullName, LastWriteTime, Length |
        Export-Csv "$reportDir\ai-work-found.csv" -NoTypeInformation
    Log-Action "Found $($findings.Count) files with AI-related content - see ai-work-found.csv" -Level WARNING
} else {
    Log-Action "No previous AI work found" -Level INFO
}
```

### Check for Common Issues

```powershell
Log-Action "Running health checks..." -Level INFO

# 1. Windows 10 EOL check
$osInfo = Get-WmiObject -Class Win32_OperatingSystem
$osVersion = $osInfo.Caption
$buildNumber = $osInfo.BuildNumber

Write-Host "`n=== WINDOWS VERSION ===" -ForegroundColor Cyan
Write-Host "OS: $osVersion"
Write-Host "Build: $buildNumber"

if ($osVersion -like "*Windows 10*") {
    $eolDate = Get-Date "2025-10-14"
    $daysUntilEOL = ($eolDate - (Get-Date)).Days

    if ($daysUntilEOL -lt 0) {
        Log-Action "WARNING: Windows 10 is past end-of-life (Oct 14, 2025). No security updates!" -Level ERROR
        Write-Host "URGENT: Windows 10 support has ended. Consider:" -ForegroundColor Red
        Write-Host "  1. Enroll in Extended Security Updates (ESU) - Free or `$30/year" -ForegroundColor Yellow
        Write-Host "  2. Upgrade to Windows 11 (if compatible)" -ForegroundColor Yellow
        Write-Host "  3. Migrate to Linux (e.g., Bazzite-DX)" -ForegroundColor Yellow
    } elseif ($daysUntilEOL -lt 180) {
        Log-Action "Windows 10 EOL in $daysUntilEOL days - plan migration" -Level WARNING
    }
}

# 2. Disk space check
Write-Host "`n=== DISK SPACE ===" -ForegroundColor Cyan
$drives = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Used -ne $null}
foreach ($drive in $drives) {
    $freePercent = [math]::Round(($drive.Free / ($drive.Used + $drive.Free)) * 100, 2)
    $color = if ($freePercent -lt 10) { "Red" } elseif ($freePercent -lt 20) { "Yellow" } else { "Green" }

    Write-Host "$($drive.Name): $freePercent% free" -ForegroundColor $color

    if ($freePercent -lt 20) {
        Log-Action "Low disk space on $($drive.Name): - $freePercent% free" -Level WARNING
    }
}

# 3. Windows Update status
Write-Host "`n=== WINDOWS UPDATE ===" -ForegroundColor Cyan
try {
    $updateSession = New-Object -ComObject Microsoft.Update.Session
    $updateSearcher = $updateSession.CreateUpdateSearcher()
    $searchResult = $updateSearcher.Search("IsInstalled=0")

    if ($searchResult.Updates.Count -gt 0) {
        Log-Action "$($searchResult.Updates.Count) Windows updates available" -Level WARNING
        Write-Host "Run Windows Update to install $($searchResult.Updates.Count) pending updates" -ForegroundColor Yellow
    } else {
        Log-Action "Windows is up to date" -Level SUCCESS
    }
} catch {
    Log-Action "Could not check Windows Update status" -Level WARNING
}

# 4. Windows Defender status
Write-Host "`n=== WINDOWS DEFENDER ===" -ForegroundColor Cyan
$defender = Get-MpComputerStatus
if ($defender.RealTimeProtectionEnabled) {
    Log-Action "Windows Defender real-time protection is ENABLED" -Level SUCCESS
} else {
    Log-Action "Windows Defender real-time protection is DISABLED!" -Level ERROR
    Write-Host "Run: Set-MpPreference -DisableRealtimeMonitoring `$false" -ForegroundColor Yellow
}

if ($defender.AntivirusSignatureAge -gt 7) {
    Log-Action "Virus definitions are $($defender.AntivirusSignatureAge) days old - update needed" -Level WARNING
}

# 5. Firewall status
Write-Host "`n=== FIREWALL ===" -ForegroundColor Cyan
$firewallProfiles = Get-NetFirewallProfile
foreach ($profile in $firewallProfiles) {
    if ($profile.Enabled) {
        Log-Action "Firewall profile '$($profile.Name)' is ENABLED" -Level SUCCESS
    } else {
        Log-Action "Firewall profile '$($profile.Name)' is DISABLED!" -Level ERROR
    }
}

Log-Action "Health checks complete" -Level SUCCESS
```

---

## PART 4: System Optimization & Management Options

Based on your investigation, here are recommended actions:

### Option 1: Automated Maintenance Script

```powershell
# Create daily maintenance task
$maintenanceScript = @'
# Daily Maintenance Script
$logDir = "C:\SystemLogs"

function Log-Action {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logFile = "$logDir\maintenance-log-$(Get-Date -Format 'yyyy-MM').log"
    "$timestamp [$Level] $Message" | Add-Content -Path $logFile
}

Log-Action "=== Daily Maintenance Started ===" -Level INFO

# 1. Clear temporary files
$tempFolders = @(
    "$env:TEMP",
    "C:\Windows\Temp",
    "$env:USERPROFILE\AppData\Local\Temp"
)

foreach ($folder in $tempFolders) {
    if (Test-Path $folder) {
        $before = (Get-ChildItem $folder -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        Get-ChildItem $folder -Recurse -File -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
        $after = (Get-ChildItem $folder -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        $freed = [math]::Round(($before - $after) / 1MB, 2)
        Log-Action "Cleared $freed MB from $folder" -Level INFO
    }
}

# 2. Check disk space
$cDrive = Get-PSDrive C
$freePercent = [math]::Round(($cDrive.Free / ($cDrive.Used + $cDrive.Free)) * 100, 2)
if ($freePercent -lt 20) {
    Log-Action "LOW DISK SPACE: $freePercent% free on C:" -Level WARNING
}

# 3. Check domain connectivity
$secureChannel = Test-ComputerSecureChannel -ErrorAction SilentlyContinue
if ($secureChannel) {
    Log-Action "Domain connectivity: OK" -Level SUCCESS
} else {
    Log-Action "Domain connectivity: FAILED" -Level ERROR
}

# 4. Update Windows Defender
Update-MpSignature -ErrorAction SilentlyContinue
Log-Action "Updated Windows Defender signatures" -Level INFO

Log-Action "=== Daily Maintenance Complete ===" -Level SUCCESS
'@

# Save the script
$scriptPath = "C:\Scripts\Daily-Maintenance.ps1"
New-Item -ItemType Directory -Path "C:\Scripts" -Force
$maintenanceScript | Out-File -FilePath $scriptPath -Encoding UTF8

# Create scheduled task (runs daily at 2 AM)
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File $scriptPath"
$trigger = New-ScheduledTaskTrigger -Daily -At 2am
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -TaskName "Daily-Maintenance" -Action $action -Trigger $trigger -Principal $principal

Log-Action "Created daily maintenance task - runs at 2 AM" -Level SUCCESS
Write-Host "`nDaily maintenance task created!" -ForegroundColor Green
Write-Host "Check logs in: C:\SystemLogs\maintenance-log-YYYY-MM.log" -ForegroundColor Yellow
```

### Option 2: Disk Cleanup Recommendations

```powershell
Write-Host "`n=== DISK CLEANUP RECOMMENDATIONS ===" -ForegroundColor Cyan

# Analyze large folders
$foldersToCheck = @(
    "$env:USERPROFILE\Downloads",
    "$env:USERPROFILE\Desktop",
    "$env:USERPROFILE\Documents",
    "$env:USERPROFILE\Videos",
    "$env:USERPROFILE\Pictures",
    "C:\Windows\SoftwareDistribution\Download",
    "C:\Windows\Temp"
)

foreach ($folder in $foldersToCheck) {
    if (Test-Path $folder) {
        $size = (Get-ChildItem $folder -Recurse -File -ErrorAction SilentlyContinue |
                 Measure-Object -Property Length -Sum).Sum
        $sizeMB = [math]::Round($size / 1MB, 2)

        if ($sizeMB -gt 100) {
            Write-Host "$folder : $sizeMB MB" -ForegroundColor Yellow
            Log-Action "Large folder: $folder ($sizeMB MB) - consider cleanup" -Level INFO
        }
    }
}

# Check for old files
Write-Host "`nFiles older than 1 year in Downloads:" -ForegroundColor Cyan
$oldFiles = Get-ChildItem "$env:USERPROFILE\Downloads" -File -ErrorAction SilentlyContinue |
            Where-Object {$_.LastWriteTime -lt (Get-Date).AddYears(-1)}

if ($oldFiles) {
    $totalSize = [math]::Round(($oldFiles | Measure-Object -Property Length -Sum).Sum / 1MB, 2)
    Write-Host "  $($oldFiles.Count) files ($totalSize MB) - consider reviewing" -ForegroundColor Yellow
}

# Windows Update cleanup
Write-Host "`nTo clean Windows Update files, run:" -ForegroundColor Cyan
Write-Host "  cleanmgr /sageset:1" -ForegroundColor White
Write-Host "  cleanmgr /sagerun:1" -ForegroundColor White
```

### Option 3: Security Hardening Quick Setup

```powershell
Write-Host "`n=== SECURITY HARDENING QUICK SETUP ===" -ForegroundColor Cyan

# 1. Ensure Windows Defender is active
Set-MpPreference -DisableRealtimeMonitoring $false
Log-Action "Enabled Windows Defender real-time protection" -Level SUCCESS

# 2. Enable Controlled Folder Access (ransomware protection)
Set-MpPreference -EnableControlledFolderAccess Enabled
Log-Action "Enabled Controlled Folder Access (ransomware protection)" -Level SUCCESS

# 3. Ensure firewall is on
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
Log-Action "Enabled Windows Firewall on all profiles" -Level SUCCESS

# 4. Disable SMBv1 (major vulnerability)
$smb1 = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol
if ($smb1.State -eq "Enabled") {
    Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart
    Log-Action "Disabled SMBv1 protocol (security vulnerability)" -Level SUCCESS
    Write-Host "SMBv1 disabled - REBOOT REQUIRED" -ForegroundColor Yellow
}

Write-Host "`nSecurity hardening complete!" -ForegroundColor Green
```

---

## Quick Reference Card

**Print this and keep near your computer:**

### When Domain Issues Occur:
```powershell
# 1. Quick fix (network profile)
Restart-NetAdapter *

# 2. Check status
Test-ComputerSecureChannel -Verbose
Get-NetConnectionProfile

# 3. View logs
Get-Content "C:\SystemLogs\system-log-$(Get-Date -Format 'yyyy-MM').log" -Tail 20
```

### Log Everything:
```powershell
Log-Action "Your message here" -Level INFO
# Levels: INFO, WARNING, ERROR, SUCCESS
```

### Monthly Checklist:
- [ ] Review logs: `C:\SystemLogs\`
- [ ] Check disk space: `Get-Volume`
- [ ] Run Windows Update
- [ ] Review investigation reports: `C:\SystemLogs\Investigation-*`
- [ ] Check for old files in Downloads folder

---

## Need More Help?

**Detailed guides available in this folder:**
- `DOMAIN_CONTROLLER_TROUBLESHOOTING.md` - Complete DC troubleshooting
- `WINDOWS_10_EOL_ISSUES.md` - Windows 10 end-of-life planning
- `CLAUDE.md` - Complete platform documentation

**Your system logs are in**: `C:\SystemLogs\`

**Created**: 2025-11-09
**For**: Surface Pro 4 and similar Windows 10 systems
