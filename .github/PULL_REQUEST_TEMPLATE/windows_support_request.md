---
name: Windows Support Request
about: Request help with Windows 10 EOL or Surface Pro 4 issues
title: "[HELP] Brief description of issue"
labels: windows, help-wanted
---

# Windows Support Request

**Please fill out this template to help us assist you quickly.**

---

## System Information

**Hardware:**
- [ ] Surface Pro 4
- [ ] Other Windows 10 device: _____________

**Windows Version:** (run `winver` and paste here)
```
Example: Windows 10 Pro, Build 19045.5247
```

**Domain-Joined:**
- [ ] Yes - connected to company/school network
- [ ] No - standalone home computer

**Primary Use:**
- [ ] Work/Business
- [ ] Personal/Home
- [ ] School/Education

---

## Quick Start: Screenshots & Error Messages

**🖼️ EASIEST: Just paste a screenshot or copy the error**

<!--
You can drag and drop screenshots here, or copy/paste text directly.
If you have error dialogs, system info windows, or diagnostic output - just screenshot and paste!
-->

**Screenshots:**
<!-- Drag images here: error dialogs, Event Viewer, system info, network settings, etc. -->

**Copied Errors/Output:**
```
Paste any error messages, dialog text, or command output here
```

---

## What's the Problem?

**Brief Description:**
<!-- Example: "Cannot connect to company network shares after VPN connection" -->

**When Did It Start:**
- [ ] Today
- [ ] This week
- [ ] After Windows Update
- [ ] After specific change: _____________
- [ ] Intermittent (comes and goes)

**Impact:**
- [ ] Blocking work - cannot do anything
- [ ] Major inconvenience - some things don't work
- [ ] Minor annoyance - mostly working

---

## Diagnostic Information

**💡 TIP: You can screenshot these instead of copy/paste if easier!**

### Quick System Snapshot (Screenshot This)

**Option 1 - Screenshot `winver`:**
1. Press Windows key + R
2. Type `winver` and press Enter
3. Screenshot the window that appears
4. Paste screenshot above in "Quick Start" section

**Option 2 - Screenshot System Information:**
1. Press Windows key
2. Type "System Information"
3. Screenshot the main window
4. Paste screenshot above

**Option 3 - Run commands and screenshot PowerShell window:**

Open PowerShell as Administrator and run:
```powershell
# Run all at once - then screenshot the PowerShell window
Write-Host "`n=== SYSTEM INFO ===" -ForegroundColor Cyan
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsBuildNumber

Write-Host "`n=== DOMAIN STATUS ===" -ForegroundColor Cyan
Test-ComputerSecureChannel -Verbose
Get-NetConnectionProfile

Write-Host "`n=== RECENT ERRORS ===" -ForegroundColor Cyan
Get-EventLog -LogName System -EntryType Error -Newest 3 | Format-List TimeGenerated, Source, Message
```

**Then screenshot the entire PowerShell window and paste in "Quick Start" section above.**

---

### Detailed Diagnostics (If Needed)

**Only fill this out if screenshots aren't clear or you prefer copy/paste:**

### 1. Domain Connectivity (if domain-joined)
```powershell
Test-ComputerSecureChannel -Verbose
```
<details>
<summary>Click to expand results</summary>

```
Paste output here
```
</details>

### 2. Network Profile
```powershell
Get-NetConnectionProfile | Format-List
```
<details>
<summary>Click to expand results</summary>

```
Paste output here
```
</details>

### 3. System Info
```powershell
systeminfo | Select-String "OS Name","OS Version","System Type"
```
<details>
<summary>Click to expand results</summary>

```
Paste output here
```
</details>

### 4. Recent Errors (last 24 hours)
```powershell
Get-EventLog -LogName System -EntryType Error -After (Get-Date).AddDays(-1) | Select-Object -First 5 | Format-List
```
<details>
<summary>Click to expand results</summary>

```
Paste output here
```
</details>

---

## What Have You Already Tried?

**Check all that apply:**
- [ ] Restarted computer
- [ ] Ran Windows Update
- [ ] Restarted network adapter (`Restart-NetAdapter *`)
- [ ] Flushed DNS cache (`ipconfig /flushdns`)
- [ ] Checked firewall settings
- [ ] Reviewed `START_HERE.md`
- [ ] Reviewed `QUICK_START_GUIDE.md`
- [ ] Reviewed `DOMAIN_CONTROLLER_TROUBLESHOOTING.md`
- [ ] Other: _____________

**What happened when you tried:**
<!-- Describe the results of what you tried above -->

---

## Specific Questions

**What do you need help with?** (check all that apply)
- [ ] Domain controller connectivity issues
- [ ] Windows 10 EOL planning (what to do next)
- [ ] Surface Pro 4 hardware issues (screen flicker, battery)
- [ ] Security hardening for post-EOL Windows 10
- [ ] Migration to Linux (Bazzite-DX)
- [ ] Other: _____________

---

## Additional Context

**Screenshots:** (if applicable)
<!-- Drag and drop images here -->

**Logs:** (if you've captured investigation logs)
<!-- Attach C:\Investigation-YYYY-MM-DD files or paste relevant excerpts -->

**Anything else we should know:**
<!-- Network setup (VPN, proxy), recent changes, specific software requirements, etc. -->

---

## Checklist Before Submitting

- [ ] I've filled out all required sections above
- [ ] I've run the diagnostic commands and pasted results
- [ ] I've checked existing documentation first
- [ ] I've described what I've already tried
- [ ] My issue is related to Windows 10 EOL or Surface Pro 4 support

---

## For Reviewers

**Once you've helped resolve this issue, please:**
1. Document the solution in the comments
2. Update relevant documentation if this is a common issue
3. Add labels: `resolved`, `documented`, or `needs-documentation`
4. Close with summary: "Fixed by [brief description]"

---

**Thank you for using our Windows support documentation! We'll help you as soon as possible.**
