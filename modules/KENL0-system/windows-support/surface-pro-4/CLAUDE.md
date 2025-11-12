# Surface Pro 4 - Current System Status

**Date**: 2025-11-09
**Platform**: Windows 10 Pro - Surface Pro 4
**Purpose**: Document current issues and investigation findings

---

## Investigation Summary

Based on initial diagnostics and conversation history, this Surface Pro 4 has:

### Primary Issue: Domain Controller Connectivity
- **Status**: ACTIVE PROBLEM
- **Symptom**: Intermittent "cannot contact domain controller" errors
- **Impact**: Network resource access failures, authentication delays
- **Priority**: HIGH - requires immediate resolution

### Secondary Concerns
- **Windows 10 EOL**: October 14, 2025 (approaching or passed)
- **Hardware Age**: 8-9 years old (released October 2015)
- **Support Status**: Microsoft hardware support ended October 2021

---

## Current Issues Checklist

Run these diagnostics to confirm current state:

```powershell
# 1. Domain connectivity
Test-ComputerSecureChannel -Verbose

# 2. Network profile
Get-NetConnectionProfile

# 3. DNS resolution
nslookup $env:USERDNSDOMAIN
nslookup "_ldap._tcp.dc._msdcs.$env:USERDNSDOMAIN"

# 4. Current DC
Write-Host "Logon Server: $env:LOGONSERVER"
```

**Results to Document:**
- [ ] Secure channel test: PASS / FAIL
- [ ] Network profile: DomainAuthenticated / Public / Private
- [ ] DNS resolution: WORKING / FAILED
- [ ] Current DC: [name] / NONE

---

## Immediate Actions (Based on Findings)

### If Network Profile = "Public" (Most Common)
```powershell
Restart-NetAdapter *
Start-Sleep -Seconds 10
Get-NetConnectionProfile  # Should now show "DomainAuthenticated"
```

### If Secure Channel Failed
```powershell
# Reset domain trust (requires domain admin credentials)
Test-ComputerSecureChannel -Repair -Credential (Get-Credential)
```

### If DNS Failed
```powershell
# Check current DNS servers
Get-DnsClientServerAddress -AddressFamily IPv4

# If not pointing to domain DNS, fix it (get DC IP from IT)
# Set-DnsClientServerAddress -InterfaceAlias "Wi-Fi" -ServerAddresses "DC_IP_HERE"
```

---

## System Health Checks

### Check Windows Version & EOL Status
```powershell
# What version are we running?
(Get-WmiObject -Class Win32_OperatingSystem).Caption
(Get-WmiObject -Class Win32_OperatingSystem).BuildNumber

# Have we passed Windows 10 EOL (Oct 14, 2025)?
$eolDate = Get-Date "2025-10-14"
if ((Get-Date) -gt $eolDate) {
    Write-Host "WARNING: Windows 10 is past EOL - no security updates!" -ForegroundColor Red
    Write-Host "ACTION NEEDED: Enroll in ESU or plan migration" -ForegroundColor Yellow
}
```

### Check for Hardware Issues
```powershell
# Battery health
powercfg /batteryreport /output "C:\battery-report.html"
# Open C:\battery-report.html and check Design Capacity vs Full Charge Capacity
# If < 50%: battery needs replacement or use tethered

# Screen flicker check (manual)
# Look for constant flickering, duplicated taskbar, black lines
# If present: hardware defect "Flickergate" - no software fix available
```

### Check Security Status
```powershell
# Windows Defender
Get-MpComputerStatus | Select-Object RealTimeProtectionEnabled, AntivirusSignatureAge

# Firewall
Get-NetFirewallProfile | Select-Object Name, Enabled

# Pending updates
Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 5
```

---

## Investigation Logs

Create logging directory and capture baseline:

```powershell
# Setup
$invDate = Get-Date -Format "yyyy-MM-dd"
$invDir = "C:\Investigation-$invDate"
New-Item -ItemType Directory -Path $invDir -Force

# Capture current state
systeminfo > "$invDir\systeminfo.txt"
ipconfig /all > "$invDir\network.txt"
Test-ComputerSecureChannel -Verbose > "$invDir\domain-trust.txt" 2>&1
Get-NetConnectionProfile > "$invDir\network-profile.txt"
gpresult /r > "$invDir\group-policy.txt"

# Check event logs for errors
Get-EventLog -LogName System -EntryType Error -After (Get-Date).AddDays(-7) |
    Export-Csv "$invDir\system-errors.csv" -NoTypeInformation

Write-Host "`nInvestigation data saved to: $invDir" -ForegroundColor Green
explorer $invDir
```

---

## Next Steps (Based on Findings)

### If Domain Issue is Active NOW:
1. Apply quick fix (restart network adapters)
2. Verify with diagnostic commands
3. Document what fixed it
4. See `DOMAIN_CONTROLLER_TROUBLESHOOTING.md` if quick fix fails

### If Domain is Working (Intermittent Issue):
1. Set up monitoring (see below)
2. Capture logs when issue occurs
3. Review event logs for patterns
4. Consider: VPN reconnection trigger? Windows Update? Time-based?

### If Windows 10 EOL Passed:
1. **Immediate**: Enroll in ESU program (free or $30)
   - Settings → Update & Security → Look for ESU option
2. **This Month**: Decide migration strategy
   - Options: New hardware / Linux / Keep with hardening
3. **See**: `WINDOWS_10_EOL_ISSUES.md` for detailed planning

### If Hardware Issues Found:
1. **Screen Flicker**: External monitor or device replacement
2. **Battery Swelling**: STOP USING - safety hazard
3. **Battery Drain**: Use tethered or replace battery

---

## Monitoring Setup (For Intermittent Issues)

```powershell
# Create monitoring script
$monitorScript = @'
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$logFile = "C:\SystemLogs\dc-monitor.log"

$secureChannel = Test-ComputerSecureChannel -ErrorAction SilentlyContinue
$networkProfile = (Get-NetConnectionProfile).NetworkCategory

$result = "$timestamp | SecureChannel: $secureChannel | NetworkProfile: $networkProfile"

if (-not $secureChannel -or $networkProfile -ne "DomainAuthenticated") {
    $result += " | ERROR"
}

Add-Content -Path $logFile -Value $result
'@

# Save script
New-Item -ItemType Directory -Path "C:\SystemLogs" -Force
$monitorScript | Out-File "C:\SystemLogs\Monitor-DC.ps1" -Encoding UTF8

# Run every 15 minutes (manual check)
Write-Host "To monitor, run:"
Write-Host "  while(`$true) { C:\SystemLogs\Monitor-DC.ps1; Start-Sleep 900 }"
```

---

## Documentation References

**For immediate troubleshooting:**
- `QUICK_START_GUIDE.md` - Copy-paste PowerShell fixes
- `START_HERE.md` - Non-technical user guide

**For deep investigation:**
- `DOMAIN_CONTROLLER_TROUBLESHOOTING.md` - Complete DC diagnostic procedures
- `WINDOWS_10_EOL_ISSUES.md` - Migration planning and options

---

## Update This File After Investigation

Once diagnostics are run, update this section with findings:

**Current State (Fill in after running checks):**
- Domain Trust: _______________
- Network Profile: _______________
- DNS Resolution: _______________
- Windows Version: _______________
- Past EOL?: _______________
- Hardware Issues: _______________
- Last Windows Update: _______________

**Root Cause (If Found):**
_____________________________________________

**Fix Applied:**
_____________________________________________

**Result:**
_____________________________________________

**Follow-up Actions:**
_____________________________________________

---

**Last Investigation**: 2025-11-09
**Status**: Awaiting diagnostic results
**Next Review**: After running diagnostic checks above
