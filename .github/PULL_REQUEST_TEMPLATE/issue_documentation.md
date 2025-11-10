---
name: Document New Issue/Solution
about: Contribute a fix or workaround you discovered
title: "[DOC] Brief description of issue and fix"
labels: documentation, windows
---

# Issue Documentation Contribution

**Thank you for contributing! This template helps document new fixes for common issues.**

---

## Issue Summary

**Problem Title:**
<!-- Example: "Network profile stuck on Public after VPN reconnect" -->

**Affected Systems:**
- [ ] Surface Pro 4
- [ ] Other Windows 10 devices
- [ ] Domain-joined only
- [ ] Standalone only
- [ ] All Windows 10 systems

**Severity:**
- [ ] Critical - blocks all work
- [ ] High - major functionality broken
- [ ] Medium - inconvenient but workaround exists
- [ ] Low - minor annoyance

---

## Environment

**When does this occur:**
<!-- Example: "After connecting to corporate VPN on public WiFi" -->

**Prerequisites:** (what must be true for this issue to happen)
- [ ] Domain-joined computer
- [ ] Specific Windows version: _____________
- [ ] After Windows Update: _____________
- [ ] VPN connection required
- [ ] Other: _____________

---

## Symptoms

**What users will see:**

1.
2.
3.

**Error messages:** (if any)
```
Paste exact error messages here
```

**How to verify the issue exists:**
```powershell
# PowerShell commands to confirm the problem
# Example: Get-NetConnectionProfile
```

---

## Root Cause

**What's actually happening:**
<!-- Technical explanation of why this occurs -->

**How we know:**
<!-- Diagnostic commands, event logs, or research that confirmed the root cause -->

---

## The Fix

### Quick Fix (if available)
```powershell
# Copy-paste solution (30 seconds - 2 minutes)
# Example:
Restart-NetAdapter *
Start-Sleep -Seconds 10
Get-NetConnectionProfile  # Verify fixed
```

**Success rate:** ___% (if known)

### Complete Fix (if different from quick fix)
```powershell
# Step-by-step PowerShell commands
# Include verification steps
```

**Permanent:**
- [ ] Yes - fix survives reboots
- [ ] No - must reapply after restart
- [ ] Partial - works until [specific event]

### Prerequisites for fix:
- [ ] Administrator privileges required
- [ ] Domain admin credentials required
- [ ] Specific KB update: _____________
- [ ] System restart required
- [ ] Other: _____________

---

## Verification

**How to confirm it worked:**
```powershell
# Commands to verify the fix
# Example: Test-ComputerSecureChannel -Verbose
```

**Expected result:**
```
What the output should show when fixed
```

---

## Rollback Plan

**If the fix breaks something:**
```powershell
# Commands to undo the fix
# OR restore from System Restore point
```

**No rollback needed:**
- [ ] Fix is safe and non-destructive

---

## Testing

**I tested this fix on:**
- Windows Version: _____________
- Build Number: _____________
- Domain-joined: Yes / No
- Number of times tested: _____________
- Success rate: _____________

**Survives reboot:**
- [ ] Yes - tested
- [ ] No - does not survive
- [ ] Unknown - not tested

---

## Documentation Update

**Where should this be documented:** (check all that apply)
- [ ] `QUICK_START_GUIDE.md` - Add to Part 1 (immediate fixes)
- [ ] `DOMAIN_CONTROLLER_TROUBLESHOOTING.md` - Add to Quick Fixes or Root Causes section
- [ ] `WINDOWS_10_EOL_ISSUES.md` - Add to Quick Fix Guides
- [ ] `START_HERE.md` - Add to "Quick Fix" section (if very common)
- [ ] New document: _____________

**Suggested section/location:**
<!-- Where in the document would this fit best? -->

---

## Related Information

**Similar issues:**
<!-- Link to similar problems or related fixes -->

**Microsoft KB articles:** (if any)
<!-- https://support.microsoft.com/... -->

**Community references:**
<!-- Reddit, TechNet forums, etc. -->

**Known limitations:**
<!-- Does this fix work in all cases? Are there edge cases? -->

---

## Files Changed

**Modified files:**
- [ ] `windows-support/surface-pro-4/QUICK_START_GUIDE.md`
- [ ] `windows-support/surface-pro-4/DOMAIN_CONTROLLER_TROUBLESHOOTING.md`
- [ ] `windows-support/surface-pro-4/WINDOWS_10_EOL_ISSUES.md`
- [ ] `windows-support/surface-pro-4/START_HERE.md`
- [ ] New file: _____________

**Changes made:**
<!-- Briefly describe what you added/changed -->

---

## Checklist Before Submitting

- [ ] I've tested this fix on actual hardware
- [ ] I've documented the exact commands/steps
- [ ] I've included verification steps
- [ ] I've tested that the fix survives a reboot
- [ ] I've included rollback instructions (if needed)
- [ ] I've updated the appropriate documentation file(s)
- [ ] My changes follow the existing documentation style

---

## For Reviewers

**Review checklist:**
- [ ] Fix is safe and non-destructive
- [ ] Commands are correct and tested
- [ ] Documentation is clear and complete
- [ ] Placed in appropriate section of docs
- [ ] Rollback plan included (if needed)
- [ ] Verified formatting and links work

**Merge notes:**
<!-- Add any notes about merging, conflicts, or follow-up needed -->

---

**Thank you for contributing to Windows support documentation!**
