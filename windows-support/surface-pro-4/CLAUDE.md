---
project: Surface Pro 4 Windows Support Documentation
status: active
version: 2025-11-09
platform: Windows 10 (Surface Pro 4)
---

# CLAUDE.md - Surface Pro 4 Platform Guide

This file provides guidance when working with Surface Pro 4 devices for Windows troubleshooting and support.

## Platform Overview

**Surface Pro 4** - Windows 10 testing and troubleshooting platform

**Device Specifications:**
- **Release Date**: October 2015
- **Operating System**: Windows 10 (EOL: October 14, 2025)
- **Windows 11 Compatible**: No (lacks TPM 2.0 and minimum CPU requirements)
- **Surface Support EOL**: October 2021 (hardware support ended)
- **Status**: End-of-life platform requiring migration planning

## Purpose

1. **Immediate**: Investigate and resolve domain controller connectivity problems
2. **Long-term**: Test Windows → Linux migration strategies

## Critical Issues

### 1. Domain Controller Connectivity (HIGH PRIORITY)

**Common Problems:**
- "Active Directory Domain Controller could not be contacted"
- Authentication failures after Windows updates
- Network profile stuck on "Public" instead of "Domain"
- Firewall blocking domain traffic

**Quick Fix (90% success rate):**
```powershell
Restart-NetAdapter *
Get-NetConnectionProfile  # Should show "DomainAuthenticated"
```

**See**: `DOMAIN_CONTROLLER_TROUBLESHOOTING.md` for complete guide

### 2. Windows 10 End of Life (October 14, 2025)

**Impact:** No security updates, increasing vulnerability

**Options:**
- **ESU Program**: Free (with Microsoft account) or $30/year until Oct 2026
- **New Hardware**: Windows 11 compatible device ($500-$1000)
- **Linux Migration**: Bazzite-DX (free, recommended for Surface Pro 4)
- **Keep Using**: High risk, only for offline/non-critical use

**See**: `WINDOWS_10_EOL_ISSUES.md` for detailed planning

### 3. Hardware Issues

**"Flickergate" - Screen Flickering:**
- Hardware defect affecting 1,600+ users
- Display controller failure (not fixable via software)
- Use external monitor as workaround
- No fix available (hardware EOL 2021)

**Battery Problems:**
- 8-9 year old batteries failing
- Swollen batteries = immediate safety hazard (stop using)
- Check health: `powercfg /batteryreport /output "C:\battery-report.html"`

### 4. Windows 11 Incompatibility

Surface Pro 4 **cannot** upgrade to Windows 11:
- Missing TPM 2.0
- CPU too old (6th gen Intel, needs 8th gen+)
- Unofficial workarounds NOT RECOMMENDED (Surface Pen/keyboard failures)

## Getting Started

### First-Time Setup

```powershell
# 1. Set PowerShell execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 2. Create working directory
New-Item -ItemType Directory -Path "C:\SystemLogs" -Force

# 3. Create system restore point
Checkpoint-Computer -Description "Before troubleshooting" -RestorePointType MODIFY_SETTINGS

# 4. Run baseline diagnostics
systeminfo > C:\SystemLogs\systeminfo.txt
ipconfig /all > C:\SystemLogs\network-baseline.txt
```

### Git Configuration (if using version control)

```powershell
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global core.autocrlf true
```

## Common Tasks

### Domain Controller Diagnostics

```powershell
# Quick diagnostic suite
Test-ComputerSecureChannel -Verbose
Get-NetConnectionProfile
nslookup your-domain.com
nltest /dclist:your-domain.com
```

### Fix Network Profile Issue

```powershell
# If stuck on "Public" network:
Restart-NetAdapter *
Start-Sleep -Seconds 10
Get-NetConnectionProfile  # Verify "DomainAuthenticated"
```

### Reset Domain Trust

```powershell
# Requires domain admin credentials
Test-ComputerSecureChannel -Repair -Credential (Get-Credential)
Test-ComputerSecureChannel -Verbose  # Verify fixed
```

### Check Windows Update Status

```powershell
# Check for pending updates
Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 10

# Force Group Policy update (after DC fix)
gpupdate /force
```

## Documentation Structure

**For End Users:**
- `START_HERE.md` - One-page friendly guide (non-technical)

**For Tech Support:**
- `QUICK_START_GUIDE.md` - Practical troubleshooting (copy-paste scripts)
- `DOMAIN_CONTROLLER_TROUBLESHOOTING.md` - Complete DC reference
- `WINDOWS_10_EOL_ISSUES.md` - EOL planning and migration

**For Development:**
- This file (`CLAUDE.md`) - Platform overview and quick reference

## Logging & Tracking

### Simple Logging System

```powershell
# Create logging function (add to PowerShell profile)
function Log-Action {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logFile = "C:\SystemLogs\system-log-$(Get-Date -Format 'yyyy-MM').log"
    "$timestamp [$Level] $Message" | Tee-Object -FilePath $logFile -Append
}

# Usage
Log-Action "Fixed network profile issue" -Level SUCCESS
Log-Action "Investigating DNS configuration" -Level INFO
```

**Logs Location**: `C:\SystemLogs\`

## Security Best Practices

### Post-EOL Hardening (if staying on Windows 10)

```powershell
# 1. Enable Windows Defender
Set-MpPreference -DisableRealtimeMonitoring $false

# 2. Enable ransomware protection
Set-MpPreference -EnableControlledFolderAccess Enabled

# 3. Enable firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

# 4. Disable SMBv1 (major vulnerability)
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart
```

### Backup Strategy

```
1. System Image: Weekly (Control Panel → Backup and Restore)
2. File Backup: Daily (File History or cloud sync)
3. Offsite Copy: Cloud storage or external drive
```

## Common Workflows

### Domain Connectivity Issue

1. **Reproduce**: Document exact error message
2. **Quick Fix**: Try `Restart-NetAdapter *`
3. **Diagnose**: Run diagnostic commands (see above)
4. **Fix**: Apply appropriate solution from troubleshooting guide
5. **Verify**: Test domain authentication, Group Policy
6. **Document**: Log what fixed it for future reference

### Windows 10 EOL Planning

1. **Assess**: Determine criticality and usage patterns
2. **Options**: Review ESU, new hardware, Linux, or keep-using
3. **Test**: If Linux, boot Bazzite-DX live USB (no changes)
4. **Decide**: Choose migration path within 3-6 months
5. **Execute**: Implement chosen solution
6. **Verify**: Ensure all workflows functional

### Hardware Issue Triage

1. **Screen Flicker**: No software fix → External monitor or replace
2. **Battery Swelling**: STOP USING → Safety hazard
3. **Battery Drain**: Check report → Replace or use tethered
4. **Performance**: Disk cleanup, check for malware

## Troubleshooting Priorities

**Immediate (Fix Now):**
1. Domain controller connectivity failures
2. Swollen battery (safety)
3. Critical security updates missing

**Short-term (This Week):**
1. Enroll in ESU program (if Windows 10 EOL passed)
2. Backup system image
3. Investigate screen flickering (if present)

**Medium-term (This Month):**
1. Decide on Windows 10 EOL strategy
2. Test migration path (if Linux)
3. Clean up disk space

**Long-term (This Quarter):**
1. Execute migration plan
2. Archive old system
3. Retire or repurpose device

## Quick Reference Commands

### Diagnostics
```powershell
systeminfo                                    # System information
ipconfig /all                                 # Network configuration
Test-ComputerSecureChannel -Verbose           # Domain trust
Get-NetConnectionProfile                      # Network profile
nltest /dclist:domain.com                     # List domain controllers
gpresult /r                                   # Group Policy status
```

### Fixes
```powershell
Restart-NetAdapter *                          # Reset network adapters
ipconfig /flushdns                            # Clear DNS cache
gpupdate /force                               # Force Group Policy update
Test-ComputerSecureChannel -Repair            # Reset domain trust
```

### Maintenance
```powershell
powercfg /batteryreport                       # Battery health
cleanmgr /sageset:1                           # Disk cleanup setup
Get-HotFix                                    # Installed updates
Get-MpComputerStatus                          # Windows Defender status
```

## When to Escalate

**Call IT Support Immediately:**
- Complete domain connectivity failure (quick fix doesn't work)
- "Trust relationship failed" error
- Cannot access any network resources
- Security breach suspected

**Contact Vendor/Hardware Support:**
- Screen flickering worsening
- Battery swollen or hot
- Hardware damage or failure

**Self-Service (Use Documentation):**
- Intermittent network issues
- Windows 10 EOL planning
- General performance optimization
- Software installation questions

## Resources

### Microsoft Official
- [Surface Pro 4 Support](https://support.microsoft.com/surface/surface-pro-4-update-history)
- [Windows 10 EOL](https://support.microsoft.com/windows/windows-10-support-has-ended)
- [Active Directory Troubleshooting](https://learn.microsoft.com/troubleshoot/windows-server/active-directory/)

### Community
- /r/Surface - Surface-specific issues
- /r/sysadmin - Domain/enterprise troubleshooting
- TechNet Forums - Windows Server/AD issues

### This Repository
- Main project: `/README.md`
- Windows support: `windows-support/README.md`
- All Surface Pro 4 docs: `windows-support/surface-pro-4/`

## Contributing

When documenting fixes or issues:

1. **Test on actual hardware** (Surface Pro 4 if possible)
2. **Document environment**: Windows version, build number, domain-joined status
3. **Include commands**: PowerShell/cmd commands that worked
4. **Verify persistence**: Does fix survive reboot?
5. **Note rollback**: How to undo if it breaks something
6. **Update docs**: Add to appropriate guide

### Commit Message Format

```
<type>: <subject> [Windows/Surface Pro 4]

Brief description of what was done and why.

Tested on: Windows 10 Pro Build XXXXX
Domain-joined: Yes/No
Result: Success/Partial/Failed
```

**Example:**
```
fix: resolve Public network profile on domain network [Windows/Surface Pro 4]

Restarting network adapters fixes network location detection issue.
Network profile now correctly shows DomainAuthenticated.

Tested on: Windows 10 Pro Build 19045.5247
Domain-joined: Yes
Result: Success - fix persists after reboot
```

## Migration Path

If migrating away from Surface Pro 4 + Windows 10:

```
Current State: Windows 10 (Surface Pro 4)
    ↓
Temporary Extension: ESU Program (Oct 2026)
    ↓
Choose Migration Path:
    ├─→ New Windows 11 Hardware ($500-$1000)
    ├─→ Linux (Bazzite-DX, free)
    └─→ Retire Device (repurpose or recycle)
```

**Recommendation**: ESU (1 year) → Test Linux in dual-boot → Full migration or new hardware

---

**Platform**: Windows 10 Pro - Surface Pro 4
**Status**: Active Support
**Last Updated**: 2025-11-09
**Focus**: Domain connectivity + EOL planning
