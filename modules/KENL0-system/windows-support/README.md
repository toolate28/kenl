---
title: Windows Support Documentation
classification: OWI-DOC
atom: ATOM-DOC-20251109-004
version: 1.0.0
status: active
---

# Windows Support Documentation

This directory contains comprehensive documentation for Windows-based testing and validation of the Bazza-DX ecosystem, with specific focus on **Surface Pro 4** as a representative Windows 10 EOL platform.

---

## Purpose

The Windows support initiative serves two primary goals:

1. **Long-term Goal**: Develop and test Windows variations of Bazza-DX migration tooling and strategies
2. **Immediate Goal**: Investigate and resolve domain controller connectivity problems on Windows 10 devices

**Target Hardware**: Microsoft Surface Pro 4 (representative of 240M+ Windows 10 EOL-affected devices)

---

## Directory Structure

```
windows-support/
├── README.md                                    # This file
└── surface-pro-4/                               # Surface Pro 4 specific documentation
    ├── CLAUDE.md                                # Claude Code guidance for Surface Pro 4 platform
    ├── DOMAIN_CONTROLLER_TROUBLESHOOTING.md     # Complete DC connectivity troubleshooting guide
    └── WINDOWS_10_EOL_ISSUES.md                 # Windows 10 end-of-life comprehensive guide
```

---

## Documentation Overview

### Surface Pro 4 Platform Guide

**File**: [`surface-pro-4/CLAUDE.md`](surface-pro-4/CLAUDE.md)

Provides comprehensive guidance for working with Surface Pro 4 devices as Windows testing platforms, including:

- Platform specifications and EOL status
- Critical issues (Flickergate, battery degradation, Windows 11 incompatibility)
- Development environment setup (PowerShell, Git, WSL)
- ATOM tag system integration for Windows
- Governance framework adaptations (ARCREF, ADR for Windows changes)
- Testing workflow and validation procedures
- Security considerations for post-EOL Windows 10

**When to Reference**: Starting any work on Surface Pro 4, setting up development environment, understanding Windows-specific ATOM tagging.

---

### Domain Controller Connectivity Guide

**File**: [`surface-pro-4/DOMAIN_CONTROLLER_TROUBLESHOOTING.md`](surface-pro-4/DOMAIN_CONTROLLER_TROUBLESHOOTING.md)

**Priority**: HIGH - Active investigation focus

Complete troubleshooting guide for Active Directory domain controller connectivity issues on Windows 10, covering:

- **Common Error Messages**: "DC could not be contacted", trust relationship failures
- **Diagnostic Procedures**: 4-phase systematic troubleshooting (Network → DNS → Trust → Group Policy)
- **Quick Fixes**: Network adapter restart, DNS flush, secure channel reset, Group Policy update
- **Windows Server 2025 Issues**: Firewall profile misapplication (KB5060842), temporary workarounds
- **Root Causes**: DNS misconfiguration (60% of cases), firewall blocking, computer account issues, time sync, VPN split-tunnel
- **Advanced Diagnostics**: Event log analysis, packet capture, DCDiag, LDAP query testing
- **Prevention**: Proactive monitoring, DNS best practices, maintenance tasks
- **Complete Diagnostic Script**: `Test-DCConnectivity.ps1` for automated testing

**When to Reference**: Domain join failures, authentication issues, Group Policy not applying, network profile stuck on "Public", after Windows updates that break DC connectivity.

**Example Workflows**:
- Quick triage: Run diagnostic commands → identify phase failure → apply corresponding quick fix
- Deep investigation: Event log analysis → packet capture → root cause identification → ARCREF for system changes
- Preventive: Implement monitoring script → weekly security reviews → proactive issue detection

---

### Windows 10 End of Life Guide

**File**: [`surface-pro-4/WINDOWS_10_EOL_ISSUES.md`](surface-pro-4/WINDOWS_10_EOL_ISSUES.md)

Comprehensive resource for Windows 10 EOL (October 14, 2025) challenges and migration strategies:

- **EOL Impact**: What stops working immediately vs. gradually, compliance risks, cost of breach vs. migration
- **Surface Pro 4 Double EOL**: Windows 10 EOL + Surface hardware EOL (October 2021) = no supported path
- **Extended Security Updates (ESU)**: Free (with sync) or $30 for 1 year until Oct 2026, enrollment procedures, limitations
- **Windows 11 Upgrade**: Why Surface Pro 4 is incompatible, unofficial workarounds (NOT RECOMMENDED), user experience reports
- **Migration Options**:
  - **Option 1**: Stay on Windows 10 + ESU (temporary, 1 year)
  - **Option 2**: New Windows 11 hardware ($400-$2000)
  - **Option 3**: Migrate to Linux/Bazzite-DX (RECOMMENDED for Surface Pro 4)
  - **Option 4**: Repurpose as offline device
- **Linux Migration Path**: Bazzite-DX installation guide, Surface Pro 4 hardware compatibility, dual-boot strategy
- **Quick Fix Guides**: ESU enrollment, compatibility check, recovery media creation, system image backup, live Linux testing
- **Security Hardening**: 14-step post-EOL hardening (Windows Defender, SMBv1 disable, firewall, UAC, BitLocker, monitoring)

**When to Reference**: Planning EOL migration, evaluating options, enrolling in ESU, migrating to Linux, hardening post-EOL Windows 10, making business case for migration.

**Decision Tree**:
```
Surface Pro 4 Windows 10 EOL Approaching
    ↓
Can afford new hardware ($500-$1000)?
    YES → Purchase Windows 11 compatible device (Surface Pro 9+)
    NO  → Continue below
    ↓
Need Windows-specific software?
    YES → Enroll in ESU (1 year extension) → Plan migration by Oct 2026
    NO  → Continue below
    ↓
Willing to learn Linux?
    YES → Migrate to Bazzite-DX (RECOMMENDED)
    NO  → Enroll in ESU + security hardening (high risk)
```

---

## Quick Reference

### For Domain Controller Issues

```powershell
# Quick diagnostic (Surface Pro 4)
Test-ComputerSecureChannel -Verbose           # Test domain trust
Get-NetConnectionProfile                      # Check network profile (should be "DomainAuthenticated")
nslookup _ldap._tcp.dc._msdcs.yourdomain.com  # Test DNS resolution

# Quick fix (if network profile stuck on "Public")
Restart-NetAdapter *
Get-NetConnectionProfile  # Verify changed to "DomainAuthenticated"

# See: DOMAIN_CONTROLLER_TROUBLESHOOTING.md for full guide
```

**ATOM Tag**: `atom STATUS "Started DC connectivity diagnostics - quick fix applied"`

---

### For Windows 10 EOL Planning

```powershell
# Check Windows version and EOL status
winver
# Look for "Version 22H2" or similar

# Check if after October 14, 2025
Get-Date  # Compare to 2025-10-14

# Enroll in ESU (after EOL date)
# Settings → Update & Security → Windows Update
# Look for "Extended Security Updates" enrollment

# See: WINDOWS_10_EOL_ISSUES.md for migration options
```

**ATOM Tag**: `atom RESEARCH "Evaluated Windows 10 EOL options - planning migration path"`

---

### For New Surface Pro 4 Setup

1. **Read**: [`surface-pro-4/CLAUDE.md`](surface-pro-4/CLAUDE.md) for platform overview
2. **Configure**: PowerShell execution policy, Git, ATOM tag functions
3. **Baseline**: Create system restore point, backup Windows license key
4. **Document**: `atom STATUS "Surface Pro 4 setup complete - baseline established"`

---

## Integration with kenl Project

### Relationship to Main Project

The Windows support documentation extends the main **kenl** (Bazza-DX SAGE Framework) project:

**Main Project Focus**: Linux (Bazzite-DX/Fedora Atomic) gaming-with-intent ecosystem
**Windows Support Focus**: Testing, validation, and migration tooling for Windows 10 EOL affected devices

**Shared Frameworks**:
- **ATOM Tag System**: Adapted for PowerShell on Windows
- **SAGE Methodology**: System-Aware Guided Evolution applied to Windows migrations
- **Governance**: ARCREF + ADR for Windows system changes

**Cross-Platform Goals**:
- Validate migration tooling on actual Windows 10 devices (Surface Pro 4)
- Document Windows → Linux migration paths with real-world testing
- Provide evidence-based guidance for 240M+ affected Windows 10 users

### ATOM Tag System on Windows

**PowerShell Implementation** (see `surface-pro-4/CLAUDE.md` for full setup):

```powershell
# Add to PowerShell $PROFILE
function atom {
    param([string]$Type, [string]$Message)
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

# Usage
atom STATUS "Starting domain controller troubleshooting"
atom CFG "Applied KB5060842 patch for DC firewall issue"
atom RESEARCH "Tested Bazzite-DX in live mode - hardware compatible"
```

**Log Location**: `C:\Users\YourName\.atom-logs\atom-YYYYMMDD.log`

**Analysis** (via WSL or Linux side):
```bash
# Copy Windows ATOM logs to Linux for analysis
cp /mnt/c/Users/YourName/.atom-logs/*.log ~/.atom-logs/

# Run atom-analytics
atom-analytics --summary
atom-analytics --recovery  # After crash/issue
```

### Governance Framework (Windows Adaptations)

**ARCREF for Windows Changes**:
- Must include registry backup commands or System Restore point creation in rollback plan
- PowerShell test scripts for verification
- List required Windows features, roles, or KB updates as dependencies

**Example** (domain controller fix):
```yaml
id: ARCREF::WIN::DC-CONNECTIVITY::001
title: "Fix Domain Controller Firewall Profile Misapplication"
platform: Windows 10 Pro (Surface Pro 4)
changes:
  - Applied KB5060842 patch
  - Configured startup script for network profile monitoring
rollback:
  restore_point: true
  restore_command: "Restore-Computer -RestorePoint 'Pre-DC-Fix'"
testing:
  powershell: |
    Test-ComputerSecureChannel -Verbose
    Get-NetConnectionProfile | Where-Object {$_.NetworkCategory -eq "DomainAuthenticated"}
```

**ADR for Windows Strategy Decisions** (create in `02-Decisions/`):
- `ADR-00X-WINDOWS-EOL-STRATEGY.md` - Decision to use Surface Pro 4 for testing
- `ADR-00X-ESU-ENROLLMENT.md` - ESU vs immediate migration decision
- `ADR-00X-LINUX-MIGRATION-PATH.md` - Bazzite-DX selection rationale

---

## Contribution Guidelines

### Adding Windows Documentation

When contributing Windows-specific documentation:

1. **Test on Actual Hardware**: Surface Pro 4 or equivalent Windows 10 device (not VMs when possible)
2. **Document Platform Details**:
   - Windows version and build number (`winver`)
   - PowerShell version (`$PSVersionTable.PSVersion`)
   - Domain-joined vs standalone differences
3. **Include ATOM Tags**: All procedures should integrate ATOM tag examples
4. **Rollback Procedures**: Every system change must have documented rollback
5. **Verification**: Test that fixes survive reboots

### File Naming Conventions

- `UPPERCASE_WITH_UNDERSCORES.md` for major guides (e.g., `DOMAIN_CONTROLLER_TROUBLESHOOTING.md`)
- `lowercase-with-hyphens.md` for case studies or specific scenarios
- `CLAUDE.md` for platform-specific Claude Code guidance

### Commit Message Format

```
<type>: <subject> [Windows/Surface Pro 4]

[Optional body with details]
[Optional PowerShell commands or procedures]

ATOM-<TYPE>-<YYYYMMDD>-<NNN>
Platform: Windows 10 Pro (Build XXXXX) - Surface Pro 4
```

**Example**:
```
docs: add domain controller troubleshooting guide [Windows/Surface Pro 4]

Complete guide for diagnosing and fixing Active Directory domain controller
connectivity issues on Windows 10. Includes 4-phase diagnostic procedure,
quick fixes, Windows Server 2025 KB5060842 issue, and prevention strategies.

Tested on:
- Surface Pro 4 (Windows 10 Pro Build 19045.5247)
- Domain-joined environment
- Reproduced and resolved network profile "Public" issue

ATOM-DOC-20251109-002
Platform: Windows 10 Pro (Build 19045.5247) - Surface Pro 4
```

---

## Roadmap

### Immediate Priorities (Q4 2025)

- [x] Document Surface Pro 4 platform setup
- [x] Complete domain controller troubleshooting guide
- [x] Create Windows 10 EOL comprehensive guide
- [ ] Test and validate DC connectivity fixes on live domain
- [ ] Create PowerShell diagnostic toolkit (scripts directory)
- [ ] Document Surface Pro 4 → Bazzite-DX migration (live case study)

### Short-term (Q1 2026)

- [ ] Develop automated Windows → Linux migration scripts
- [ ] Create video walkthrough for Bazzite-DX installation on Surface Pro 4
- [ ] Test Proton game compatibility on Surface Pro 4 + Bazzite-DX
- [ ] Document WSL integration for ATOM+SAGE framework
- [ ] Create Surface Pro 4 hardware diagnostic scripts (battery health, screen flicker detection)

### Long-term (2026+)

- [ ] Expand to other Windows 10 EOL-affected hardware (Dell XPS, HP EliteBook, Lenovo ThinkPad)
- [ ] Develop Windows-native ATOM analytics tools (C# or PowerShell-based)
- [ ] Create enterprise deployment guide (Group Policy, MDT, SCCM integration)
- [ ] Publish case studies from real-world migrations

---

## Support & Resources

### Internal Resources
- **Main Project**: [`/README.md`](../README.md) - kenl project overview
- **ATOM+SAGE Framework**: [`/atom-sage-framework/`](../atom-sage-framework/) - Core framework documentation
- **Governance Templates**: [`/mcp-governance/`](../mcp-governance/) (ARCREF), [`/02-Decisions/`](../02-Decisions/) (ADR)

### External Resources
- **Microsoft**: [Windows 10 EOL](https://support.microsoft.com/windows/windows-10-support-has-ended), [Surface Pro 4 Support](https://support.microsoft.com/surface/surface-pro-4-update-history)
- **Bazzite-DX**: [Official Site](https://bazzite.gg/), [Documentation](https://docs.bazzite.gg/)
- **Community**: [/r/Surface](https://reddit.com/r/Surface), [/r/Bazzite](https://reddit.com/r/Bazzite), [/r/linuxquestions](https://reddit.com/r/linuxquestions)

### Reporting Issues

**Windows Documentation Issues**:
1. Check existing documentation for answers
2. Test on actual Surface Pro 4 hardware if possible
3. Open issue at [github.com/toolate28/kenl/issues](https://github.com/toolate28/kenl/issues)
4. Tag with `windows`, `surface-pro-4`, or `documentation` labels

**Include in Issue**:
- Windows version and build number
- Surface Pro 4 or other hardware
- Steps to reproduce
- Expected vs actual behavior
- Relevant ATOM tags from troubleshooting session

---

## Document Metadata

- **Created**: 2025-11-09
- **Classification**: OWI-DOC
- **ATOM**: ATOM-DOC-20251109-004
- **Platform**: Windows 10 (Surface Pro 4 focus)
- **Status**: Active - Initial Documentation Phase
- **Last Updated**: 2025-11-09
- **Related Projects**: kenl (Bazza-DX SAGE Framework), ATOM+SAGE framework

---

**For questions or contributions, consult [`CONTRIBUTING.md`](../CONTRIBUTING.md) and follow the Windows-specific adaptations noted in [`surface-pro-4/CLAUDE.md`](surface-pro-4/CLAUDE.md).**
