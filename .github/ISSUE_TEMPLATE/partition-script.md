---
name: Partition Script Issue
about: Report bugs or request features for STEP1-STEP3 partition scripts
title: "[PARTITION]: Brief description"
labels: "domain: partition-scripts, status: needs-triage"
assignees: ""
---

## Script Information
- **Script:** (STEP1-WINDOWS-WIPE-DISK1.ps1, STEP2, STEP3, etc.)
- **OS:** (Windows 11, Bazzite-DX Live USB, WSL2)
- **Disk:** (2TB Seagate, etc.)
- **Execution Method:** (Native PowerShell, Git Bash, tmux, screen)

## Issue Description
<!-- Clear description of what went wrong -->

## Expected Partition Layout
```
Partition 1: Games-Universal (900GB, NTFS)
Partition 2: Claude-AI-Data (500GB, ext4)
...
```

## Actual Result
<!-- What happened instead? -->

## Steps to Reproduce
1. 
2. 
3. 

## Error Output
```powershell
# Paste error messages, handover doc snippets, or script output
```

## Disk Status Before Script
```powershell
# Output of: Get-Disk | Format-Table Number, FriendlyName, Size
# OR: lsblk /dev/sdb
```

## Handover Documents Created
- [ ] HANDOVER-DISK-WIPE-*.md
- [ ] HANDOVER-PARTITION-*.md
- [ ] HANDOVER-VERIFICATION-*.md

<!-- Attach or paste relevant sections -->

## Safety Checks
- [ ] Verified disk number before running
- [ ] Confirmed not a system disk
- [ ] Backed up important data

## ATOM Context
- Related ATOM: ATOM-CFG-20251112-001 through 003
- Intent: <!-- What were you trying to achieve? -->

---
*For destructive operations, always include handover docs to help diagnose issues.*
