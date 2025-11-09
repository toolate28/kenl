---
project: Bazza-DX Surface Pro 4 Windows Testing Platform
status: testing
version: 2025-11-09
classification: OWI-DOC
atom: ATOM-DOC-20251109-001
owi-version: 1.0.0
platform: Windows 10 (Surface Pro 4)
---

# CLAUDE.md - Surface Pro 4 Windows Testing Platform

This file provides guidance to Claude Code when working with Surface Pro 4 devices for Windows-based testing and validation of the Bazza-DX ecosystem migration strategies.

## Platform Overview

**Surface Pro 4** serves as a representative Windows 10 EOL testing platform for the Bazza-DX project's Windows migration strategies.

**Device Specifications:**
- **Release Date**: October 2015
- **Operating System**: Windows 10 (EOL: October 14, 2025)
- **Windows 11 Compatible**: No (lacks TPM 2.0 and minimum CPU requirements)
- **Surface Support EOL**: October 2021 (hardware support ended)
- **Status**: Critical EOL platform - representative of 240M+ affected PCs

## Repository Purpose

This Surface Pro 4 platform serves dual purposes:

1. **Long-term Goal**: Test and validate Windows variations of Bazza-DX migration tooling
2. **Immediate Goal**: Investigate and resolve domain controller connectivity problems on Windows 10

## Critical Issues & Known Problems

### 1. Windows 10 End of Life (October 14, 2025)

**Impact**: No security updates, increased vulnerability, no technical support

**Mitigation Options**:
- Extended Security Updates (ESU) program (free with Microsoft account sync, or $30/year until Oct 2026)
- Migration to Linux (Bazzite-DX recommended)
- Device replacement (Surface Pro 5 or newer for Windows 11 support)

**Related Documentation**: `WINDOWS_10_EOL_ISSUES.md`

### 2. Windows 11 Incompatibility

**Surface Pro 4 cannot officially upgrade to Windows 11** due to:
- Missing TPM 2.0 chip
- CPU below minimum requirements (6th gen Intel, requires 8th gen+)
- Released before November 2017 cutoff

**Workarounds** (unsupported, high risk):
- Bypass installation checks (see `WINDOWS_11_UNOFFICIAL_INSTALL.md` - NOT RECOMMENDED)
- Known issues: Surface Pen glitches, Type Cover failures, system instability

### 3. "Flickergate" - Screen Flickering Issue

**Severity**: High - Hardware defect affecting 1,600+ reported users

**Symptoms**:
- Constant screen flickering during/after startup
- Duplicated or stretched taskbar
- Black lines flashing across display
- Progressive worsening over time

**Root Cause**: Hardware defect (display controller failure), not software-fixable

**Status**: Microsoft replacement program ended (device EOL October 2021)

**Temporary Mitigations**:
- Update Intel HD Graphics drivers (may help in early stages)
- Reduce screen brightness
- External monitor usage (workaround for critical work)
- **Not Recommended**: Freezer method (temporary, risks condensation damage)

**Related Documentation**: `SURFACE_PRO_4_HARDWARE_ISSUES.md`

### 4. Battery Issues

**Common Problems**:
- Rapid battery degradation (8+ year old devices)
- Swollen batteries (safety hazard - discontinue use immediately)
- Won't hold charge / requires constant connection

**Diagnosis**:
```powershell
# Generate battery health report
powercfg /batteryreport /output "C:\battery-report.html"

# Check battery capacity
# Design Capacity vs Full Charge Capacity ratio
# <50% indicates replacement needed
```

**Solutions**:
- Battery replacement (iFixit difficulty: Difficult, requires heat gun)
- Use as desktop-tethered device
- Device retirement/replacement

### 5. Domain Controller Connectivity Issues

**High Priority** - Active investigation focus

**Common Scenarios**:
- "Active Directory Domain Controller could not be contacted"
- Authentication failures after Windows updates
- Network location detection failures
- Firewall profile misapplication (Domain vs Public)

**Related Documentation**: `DOMAIN_CONTROLLER_TROUBLESHOOTING.md`

## Development Environment Setup

### PowerShell Execution Policy

```powershell
# Check current execution policy
Get-ExecutionPolicy

# Set for current user (recommended for development)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Verify
Get-ExecutionPolicy -List
```

### Git Configuration

```powershell
# Configure Git for Windows
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global core.autocrlf true  # Windows line endings
git config --global init.defaultBranch main

# Verify
git config --list
```

### Windows Subsystem for Linux (WSL) - Optional

For ATOM+SAGE framework compatibility:

```powershell
# Install WSL2 (requires Windows 10 version 1903+)
wsl --install

# Default: Ubuntu (compatible with KENL distrobox environment)
# Reboot required

# After reboot, set up Ubuntu user
# Then install framework:
cd /mnt/c/Users/YourName/kenl/atom-sage-framework
./install.sh
```

## ATOM Tag System on Windows

### PowerShell Functions

Create `$PROFILE` functions for ATOM tagging:

```powershell
# Edit PowerShell profile
notepad $PROFILE

# Add these functions:
function atom {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Type,
        [Parameter(Mandatory=$true)]
        [string]$Message
    )

    $date = Get-Date -Format "yyyyMMdd"
    $logDir = "$env:USERPROFILE\.atom-logs"
    $logFile = "$logDir\atom-$date.log"

    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir | Out-Null
    }

    $counter = (Get-Content $logFile -ErrorAction SilentlyContinue | Measure-Object -Line).Lines + 1
    $atomTag = "ATOM-$Type-$date-$('{0:D3}' -f $counter)"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    "$timestamp [$atomTag] $Message" | Tee-Object -FilePath $logFile -Append
}

# Usage examples:
# atom STATUS "Starting domain controller diagnostics"
# atom CFG "Modified firewall rules for DC connectivity"
# atom TASK "TODO: Test authentication after Group Policy update"
```

### Alternative: WSL-based ATOM

If WSL is installed, use native ATOM commands:

```powershell
wsl bash -c "atom STATUS 'Starting Windows testing session'"
wsl bash -c "atom-analytics --summary"
```

## Governance Framework - Windows Adaptations

### ARCREF for Windows Changes

When making Windows registry, Group Policy, or system-level changes, create ARCREF artifacts following the template:

**Required Sections for Windows**:
- **Rollback Plan**: Must include registry backup commands or System Restore point creation
- **Testing**: Include test scripts (PowerShell) for verification
- **Dependencies**: List required Windows features, roles, or KB updates

**Example**:
```yaml
id: ARCREF::WIN::DC-CONNECTIVITY::001
title: "Fix Domain Controller Firewall Profile Misapplication"
platform: Windows 10 Pro (Surface Pro 4)
rollback:
  restore_point: true
  registry_backup: "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess"
  powershell_command: "Restore-Computer -RestorePoint 'Pre-DC-Fix'"
```

### ADR for Windows Strategy Decisions

Document Windows-specific decisions in `02-Decisions/`:

- ADR-00X-WINDOWS-EOL-STRATEGY.md
- ADR-00X-WSL-INTEGRATION.md
- ADR-00X-DOMAIN-CONTROLLER-APPROACH.md

## Testing Workflow

### Pre-Test Checklist

- [ ] Create System Restore point
- [ ] Document current state (ATOM-STATUS tag)
- [ ] Backup critical registry keys
- [ ] Document Group Policy settings (if domain-joined)
- [ ] Run baseline diagnostics

### Domain Controller Testing

See `DOMAIN_CONTROLLER_TROUBLESHOOTING.md` for detailed procedures.

**Quick Diagnostic Commands**:

```powershell
# Test domain connectivity
Test-ComputerSecureChannel -Verbose

# Verify DNS resolution
nslookup your-domain.com
Resolve-DnsName -Name _ldap._tcp.dc._msdcs.your-domain.com -Type SRV

# Check firewall profiles
Get-NetConnectionProfile

# List domain controllers
nltest /dclist:your-domain.com

# Verify trust relationship
nltest /sc_verify:your-domain.com
```

### Post-Test Validation

- [ ] Verify system stability
- [ ] Check event logs (System, Application, Security)
- [ ] Test domain authentication
- [ ] Document results with ATOM tags
- [ ] Update ARCREF if configuration changed
- [ ] Commit findings to repository

## Branch Naming Convention

Follow kenl standards with Windows platform indicators:

```
feat/windows-<description>      # Windows-specific features
fix/surface-<description>        # Surface Pro 4 specific fixes
test/dc-connectivity-<issue>     # Domain controller tests
docs/windows-<topic>             # Windows documentation
```

## Commit Message Format

Use Conventional Commits with Windows platform tags:

```
<type>: <subject> [Windows/Surface Pro 4]

[Optional body with details]
[Optional commands run]

ATOM-<TYPE>-<YYYYMMDD>-<NNN>
Platform: Windows 10 (Surface Pro 4)
```

Example:
```
fix: resolve domain controller firewall profile issue [Windows/Surface Pro 4]

Applied KB5060842 patch to fix Public profile misapplication on
domain-joined Surface Pro 4 devices. Verified Domain profile now
applies correctly after restart.

Testing:
- Pre-patch: Get-NetConnectionProfile showed Public
- Post-patch: Get-NetConnectionProfile shows DomainAuthenticated
- DC connectivity: nltest /sc_verify succeeded

ATOM-CFG-20251109-002
Platform: Windows 10 Pro (Build 19045.5247) - Surface Pro 4
```

## Security Considerations

### Windows 10 Post-EOL Risks

- **No security updates** after October 14, 2025 (or Oct 2026 with ESU)
- **Increased vulnerability** to exploits
- **Compliance risks** for regulated environments

### Mitigation Strategies

1. **Network Isolation**: Separate VLAN for EOL testing devices
2. **Limited Privileges**: Non-admin account for daily use
3. **Endpoint Protection**: Third-party AV (Windows Defender updates ending)
4. **Snapshot/Backup**: Regular full-disk images
5. **Air-gap Critical Tests**: Disconnect from network when possible

### Domain Controller Testing Security

- Use **test domain** environment only
- Never test on production domain controllers
- Document all Group Policy changes
- Use staged rollout (test OU → production OU)

## Key Documentation Files

### Surface Pro 4 Specific
- `SURFACE_PRO_4_HARDWARE_ISSUES.md` - Flickergate, battery, known defects
- `WINDOWS_10_EOL_ISSUES.md` - End of life challenges and solutions
- `DOMAIN_CONTROLLER_TROUBLESHOOTING.md` - Active Directory connectivity

### Windows Testing Strategy
- `WINDOWS_MIGRATION_TESTING.md` - Test plans for Bazzite migration tools
- `WSL_INTEGRATION.md` - Windows Subsystem for Linux setup
- `POWERSHELL_ATOM_TOOLKIT.md` - Native Windows ATOM implementation

### Cross-Platform Compatibility
- Reference main `CLAUDE.md` for ATOM+SAGE framework core concepts
- Reference `atom-sage-framework/` for Linux-based tooling
- Document platform differences in ADRs

## Ecosystem Context - Windows Perspective

The Bazza-DX ecosystem targets Windows 10 EOL migration:

**Windows Side (this platform)**:
- **Current**: Windows 10 Pro (Surface Pro 4)
- **Challenges**: EOL, Windows 11 incompatibility, domain controller issues
- **Testing**: Migration tool validation, compatibility verification

**Linux Target (main project)**:
- **Target**: Bazzite-DX (Fedora Atomic/rpm-ostree)
- **Gaming**: Proton/GE-Proton, GameScope, MangoHud
- **Dev**: KENL distrobox (Ubuntu 24.04 + Claude Code)

**Migration Path**:
```
Windows 10 (Surface Pro 4)
    ↓
[Testing/Validation Phase - YOU ARE HERE]
    ↓
Bazzite-DX (Gaming-focused Fedora Atomic)
    ↓
Gaming-With-Intent ecosystem
```

## Immediate Priorities

### Active Investigation: Domain Controller Connectivity

**Goal**: Document, diagnose, and resolve DC connectivity issues on Windows 10

**Approach**:
1. Reproduce issue in controlled environment
2. Capture diagnostic data (Event Viewer, network traces)
3. Test known fixes (KB patches, firewall rules, registry tweaks)
4. Document rollback-safe solutions
5. Create ARCREF + ADR for validated fixes

**Expected Deliverables**:
- `DOMAIN_CONTROLLER_TROUBLESHOOTING.md` (step-by-step guide)
- ARCREF artifact for any system changes
- ADR documenting decision rationale
- PowerShell diagnostic scripts
- Test validation results

## Support & Resources

### Microsoft Resources
- [Surface Pro 4 Update History](https://support.microsoft.com/surface/surface-pro-4-update-history)
- [Windows 10 EOL Information](https://support.microsoft.com/windows/windows-10-support-has-ended)
- [Active Directory Troubleshooting](https://learn.microsoft.com/troubleshoot/windows-server/active-directory/active-directory-overview)

### Community Resources
- Surface Pro 4 Flickergate tracking thread (Microsoft Answers)
- /r/Surface subreddit (user-reported issues and fixes)
- TechNet forums (domain controller troubleshooting)

### Related Projects
- Main kenl repository: [github.com/toolate28/kenl](https://github.com/toolate28/kenl)
- ATOM+SAGE framework: `../atom-sage-framework/`
- Bazza-DX ecosystem documentation

## Contributing

When contributing Windows/Surface Pro 4 findings:

1. Test on actual Surface Pro 4 hardware (not VMs when possible)
2. Document Windows version and build number
3. Include PowerShell version in test reports
4. Note domain-joined vs standalone differences
5. Verify fixes survive reboots
6. Include rollback procedures

Follow standard kenl contribution guidelines (CONTRIBUTING.md) with Windows-specific adaptations noted above.

---

**Platform**: Windows 10 Pro (Build 19045.x) - Surface Pro 4
**Status**: Active Testing
**Last Updated**: 2025-11-09
**ATOM**: ATOM-DOC-20251109-001
