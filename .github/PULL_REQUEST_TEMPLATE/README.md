# Pull Request Templates

This directory contains PR templates to help with Windows 10 EOL and Surface Pro 4 support.

## Which Template Should I Use?

### 🆘 Need Help? → `windows_support_request.md`

**Use this if:**
- You're having domain controller connectivity issues
- You need help with Windows 10 end-of-life planning
- Your Surface Pro 4 has hardware problems (screen flicker, battery)
- You're stuck and need troubleshooting assistance

**Quick way to use it:**
When creating a PR, add `?template=windows_support_request.md` to the URL, or GitHub will prompt you to choose.

**What to include:**
- 📸 **Screenshots are easiest!** Just paste error dialogs, system info windows, or PowerShell output
- System information (Windows version, domain-joined status)
- What you've already tried
- Error messages or symptoms

---

### 📝 Found a Fix? → `issue_documentation.md`

**Use this if:**
- You discovered a solution to a common Windows issue
- You want to contribute a workaround or fix
- You've tested something that works and want to share

**What to include:**
- The problem and symptoms
- Step-by-step fix (PowerShell commands preferred)
- Testing results (does it survive reboot?)
- Rollback plan (how to undo if needed)
- Where in the documentation this should go

---

### ✏️ General Changes → `pull_request_template.md`

**Use this if:**
- Fixing typos or formatting
- Improving existing documentation
- Adding new non-support documentation
- Making process improvements

---

## Tips for Getting Help Fast

### 1. Screenshots Over Typing 📸
Instead of copying and pasting, just screenshot:
- Error dialogs
- `winver` window (Windows key + R, type `winver`)
- System Information window
- PowerShell output

### 2. All-in-One Diagnostic
Run this in PowerShell (Admin), then screenshot the window:

```powershell
Write-Host "`n=== SYSTEM INFO ===" -ForegroundColor Cyan
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsBuildNumber

Write-Host "`n=== DOMAIN STATUS ===" -ForegroundColor Cyan
Test-ComputerSecureChannel -Verbose
Get-NetConnectionProfile

Write-Host "`n=== RECENT ERRORS ===" -ForegroundColor Cyan
Get-EventLog -LogName System -EntryType Error -Newest 3 | Format-List TimeGenerated, Source, Message
```

### 3. Check Docs First
Before opening a support request, quickly review:
- `START_HERE.md` - One-page friendly guide
- `QUICK_START_GUIDE.md` - Common fixes (90% success rate)
- `DOMAIN_CONTROLLER_TROUBLESHOOTING.md` - Complete DC guide

Most issues have a 30-second fix already documented!

---

## For Reviewers

When helping with support requests:

1. **Diagnose First**: Look at screenshots/errors to identify issue
2. **Quick Fix**: Point to existing documentation if available
3. **Document**: If new issue, ask submitter to create `issue_documentation.md` PR with solution
4. **Close**: Add `resolved` label and summary comment

When reviewing issue documentation:

1. **Verify**: Commands are safe and tested
2. **Test**: Ideally test on similar system
3. **Place**: Add to appropriate documentation file
4. **Label**: Add `documented` label when merged

---

## Examples

### Support Request Example
```
Title: [HELP] Cannot access network shares after VPN connect

Screenshots: [paste of error dialog + PowerShell output]

Brief: Every time I reconnect to VPN, network profile shows "Public"
and I can't access company file shares.

Tried: Restarted computer, checked firewall, reviewed QUICK_START_GUIDE.md
```

### Documentation Example
```
Title: [DOC] Fix for network profile stuck on Public after VPN

Problem: Network profile shows Public instead of Domain after VPN reconnect
Fix: Restart-NetAdapter * (30 seconds, 95% success rate)
Tested: Windows 10 Pro 19045, domain-joined, survives reboot
Add to: QUICK_START_GUIDE.md, Part 1
```

---

**Questions?** Open a discussion or see `windows-support/README.md`
