---
project: kenl - Bazza-DX SAGE Framework
status: active
version: 1.0.0
classification: OWI-DOC
atom: ATOM-CFG-20251112-004
owi-version: 1.0.0
---

# Privacy & Security Guide - Windows Partition Scripts

**Purpose:** Ensure user-specific execution data stays local while keeping generic templates shareable

**ATOM Tag:** `ATOM-CFG-20251112-004`

---

## Problem: Scripts Generate Personal Data

When you run the partition scripts, they create files containing:

**Sensitive Information:**
- ✗ Your Windows username (`C:\Users\Matthew Ruhnau\Desktop\...`)
- ✗ Disk serial numbers and hardware IDs
- ✗ Partition UUIDs (unique identifiers)
- ✗ Your custom disk sizes and drive letter preferences
- ✗ Timestamp patterns revealing your timezone/schedule

**Example from handover document:**
```markdown
**Timestamp:** 2025-11-12 16:48:33
**User:** C:\Users\Matthew Ruhnau\Desktop
**Disk:** Seagate FireCuda (Serial: ZCT2X9GK)
**UUIDs:**
- sdb1: A8F2-4D91
- sdb2: 3f4a8c2d-1b9e-4f5a-8c3d-2e1f6a9b4c8d
```

This data should NOT be committed to public Git repositories.

---

## Solution: .gitignore + Local Archive

### 1. Repository Structure

```
kenl/scripts/windows-partition-scripts/
├── .gitignore                           ← Blocks private data
├── README.md                            ✓ Public - Generic guide
├── config.example.ps1                   ✓ Public - Template only
├── STEP1-WINDOWS-WIPE-DISK1.ps1         ✓ Public - Generic script
├── STEP2-WINDOWS-PARTITION-DISK1.ps1    ✓ Public - Generic script
├── STEP3-WINDOWS-MOUNT-CHECK.ps1        ✓ Public - Generic script
├── USAGE_PRIVACY.md                     ✓ Public - This file
│
├── .archive/                            ✗ Private - Gitignored
│   ├── handover-docs/                   ✗ Your execution results
│   ├── logs/                            ✗ PowerShell transcripts
│   ├── backups/                         ✗ Old script versions
│   └── notes/                           ✗ Personal notes
│
├── config.local.ps1                     ✗ Private - Your settings
├── HANDOVER-*.md                        ✗ Private - Generated docs
└── *.ps1.local                          ✗ Private - Modified scripts
```

### 2. Gitignore Rules Explained

**`.gitignore` file:**

```gitignore
# Category 1: Execution Results (contain personal data)
HANDOVER-*.md                    # User paths, disk serials, UUIDs
*.log                            # Execution logs with timestamps
PowerShell_transcript.*.txt      # Full command history

# Category 2: User Configuration (preferences)
config.local.ps1                 # Your disk number, sizes, paths
*.ps1.local                      # Modified scripts for your system
user-settings.json               # Personal preferences

# Category 3: Archive/History (local-only tracking)
.archive/                        # All execution history
archive/                         # Alternative archive location
*.old, *.bak, *.backup           # Old file versions

# Category 4: Sensitive Hardware Info
*-UUID*.txt                      # Partition UUIDs
partition-uuids.txt              # Linux blkid output
*-serial*.txt                    # Disk serial numbers
disk-info-*.txt                  # Hardware details

# Category 5: Test/Temporary Files
KENL-TEST*.txt                   # Write test artifacts
KENL-VERIFY*.txt                 # Verification test files
test-write-*.txt                 # Generic test files
```

---

## Usage Workflows

### Workflow 1: First-Time User (Generic Scripts)

```powershell
# Clone repository
git clone https://github.com/toolate28/kenl.git
cd kenl\scripts\windows-partition-scripts

# Scripts work immediately with defaults
.\STEP1-WINDOWS-WIPE-DISK1.ps1
# Targets: Disk 1 (you can edit $DISK_NUMBER if different)
# Output: Desktop\HANDOVER-*.md (gitignored automatically)
```

### Workflow 2: Customized Setup (Recommended)

```powershell
# Create your local configuration
Copy-Item config.example.ps1 config.local.ps1

# Edit your settings
notepad config.local.ps1
# Change: $DISK_NUMBER, partition sizes, drive letters, handover path

# Create archive directory
mkdir .archive\handover-docs
mkdir .archive\logs

# Run scripts with your config
# (Scripts auto-detect config.local.ps1)
.\STEP1-WINDOWS-WIPE-DISK1.ps1
.\STEP2-WINDOWS-PARTITION-DISK1.ps1
.\STEP3-WINDOWS-MOUNT-CHECK.ps1

# Results saved to .archive/ (gitignored)
```

### Workflow 3: Multiple Disks

```powershell
# Create disk-specific configs
Copy-Item STEP2-WINDOWS-PARTITION-DISK1.ps1 STEP2-DISK2.ps1.local

# Edit STEP2-DISK2.ps1.local:
# Change $DISK_NUMBER = 2
# Adjust partition sizes

# Run modified script
.\STEP2-DISK2.ps1.local
# Output: HANDOVER-DISK2-*.md (gitignored via *.md.local pattern)
```

---

## Git Commit Safety

### What Gets Committed (Safe)

```bash
# These changes are safe to commit/push:
git add STEP1-WINDOWS-WIPE-DISK1.ps1     # Generic script changes
git add README.md                        # Documentation updates
git add config.example.ps1               # Template changes
git add .gitignore                       # Privacy rules
```

### What NEVER Gets Committed (Blocked by .gitignore)

```bash
# These are automatically blocked:
git add HANDOVER-*.md                    # ✗ Ignored
git add config.local.ps1                 # ✗ Ignored
git add .archive/                        # ✗ Ignored
git add *-UUID*.txt                      # ✗ Ignored

# Git status won't even show them:
git status
# On branch main
# nothing to commit, working tree clean
```

### Check Before Pushing

```bash
# Always verify before push
git status                               # Check staged files
git diff --cached                        # Review changes
grep -r "Matthew Ruhnau" *               # Search for personal data (example)

# Only push if clean
git push origin main
```

---

## Archive Directory Management

### Creating Archive Structure

```powershell
# One-time setup
$archiveRoot = "$PSScriptRoot\.archive"
mkdir $archiveRoot\handover-docs
mkdir $archiveRoot\logs
mkdir $archiveRoot\backups
mkdir $archiveRoot\notes

# Create README (not committed)
@"
# Execution Archive

This directory contains your personal execution history.
It is gitignored and never pushed to remote repositories.

**Contents:**
- handover-docs/ - All HANDOVER-*.md files
- logs/ - PowerShell transcripts
- backups/ - Old script versions
- notes/ - Personal notes and decisions
"@ | Out-File $archiveRoot\README.md
```

### Archiving Old Results

```powershell
# After successful execution, archive results
$timestamp = Get-Date -Format "yyyyMMdd"
Move-Item HANDOVER-*.md .archive\handover-docs\

# Archive old script versions
Copy-Item STEP2-WINDOWS-PARTITION-DISK1.ps1 `
          .archive\backups\STEP2-$timestamp.ps1.old
```

### Cleaning Old Archives

```powershell
# Remove old handover docs (keep last 10)
Get-ChildItem .archive\handover-docs\HANDOVER-*.md |
    Sort-Object LastWriteTime -Descending |
    Select-Object -Skip 10 |
    Remove-Item

# Remove logs older than 30 days
Get-ChildItem .archive\logs\*.log |
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } |
    Remove-Item
```

---

## Sharing Results Safely

### Scenario 1: Report Success to Issue Tracker

**Problem:** You want to confirm scripts worked without exposing personal data.

**Solution:**
```powershell
# Generic success report (safe to share)
@"
✅ STEP1, STEP2, STEP3 completed successfully on Windows 11

**System:**
- Disk: 1.8TB External HDD
- Partitions: 5 (NTFS, ext4, exFAT)
- Verification: All write tests passed

**Next:** Booting into Bazzite-DX to format ext4 partitions
"@ | Out-File success-report.txt

# Share success-report.txt (no personal data)
```

### Scenario 2: Report Error for Debugging

**Problem:** Script failed, need to share error details.

**Solution:**
```powershell
# Sanitize handover document
$handover = Get-Content HANDOVER-PARTITION-*.md -Raw

# Redact personal info
$sanitized = $handover `
    -replace "C:\\Users\\.*?\\Desktop", "C:\Users\USER\Desktop" `
    -replace "Serial Number:.*", "Serial Number: [REDACTED]" `
    -replace "UUID=[\w-]+", "UUID=[REDACTED]" `
    -replace "Timestamp: \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}", "Timestamp: [REDACTED]"

$sanitized | Out-File HANDOVER-SANITIZED.md

# Share HANDOVER-SANITIZED.md (safe)
```

### Scenario 3: Contributing Script Improvements

**Problem:** You fixed a bug, want to contribute back.

**Solution:**
```bash
# Fork repository
git checkout -b fix/partition-write-test

# Edit generic script (no personal data)
# STEP2-WINDOWS-PARTITION-DISK1.ps1

# Test with your config.local.ps1 (gitignored)
.\STEP2-WINDOWS-PARTITION-DISK1.ps1

# Commit only generic script changes
git add STEP2-WINDOWS-PARTITION-DISK1.ps1
git commit -m "fix: add retry logic for partition write tests"

# Push and create PR (no personal data exposed)
git push origin fix/partition-write-test
```

---

## Privacy Audit Checklist

Before committing/pushing, verify:

**File Content Audit:**
- [ ] No usernames in paths (e.g., `C:\Users\YourName\`)
- [ ] No disk serial numbers
- [ ] No partition UUIDs
- [ ] No personal notes or comments
- [ ] No timestamps revealing timezone/schedule

**File Names Audit:**
- [ ] No `HANDOVER-*.md` files
- [ ] No `*-UUID*.txt` files
- [ ] No `config.local.ps1`
- [ ] No `.archive/` directory

**Git Status Check:**
```bash
git status                    # Should only show generic files
git diff --cached             # Review all changes
git log -1 --stat             # Check last commit
```

**Manual Search:**
```bash
# Linux/Git Bash
grep -r "Matthew Ruhnau" .    # Replace with your name
grep -r "Serial Number:" .
grep -r "UUID=" . --include="*.ps1"

# PowerShell
Select-String -Path .\*.ps1 -Pattern "C:\\Users"
Select-String -Path .\*.ps1 -Pattern "Serial Number"
```

---

## ATOM Traceability (Safe)

ATOM tags are metadata identifiers, NOT personal data. Safe to commit:

```powershell
# Script header (SAFE - generic metadata)
<#
.NOTES
    ATOM Tag: ATOM-CFG-20251112-002
    Project: kenl - Bazza-DX SAGE Framework
    Date: 2025-11-12
#>
```

ATOM tags provide:
- Version tracking (which script version you ran)
- Design decision links (why partition layout was chosen)
- Git history traceability (find related commits)

**No personal data in ATOM tags.**

---

## Recovery Scenarios

### Lost Local Config

**Problem:** Accidentally deleted `config.local.ps1`, handover docs

**Solution:**
```powershell
# Restore config from example
Copy-Item config.example.ps1 config.local.ps1

# Restore handover docs from Windows Recycle Bin
# Or check .archive/backups/ if you copied them

# Re-run verification script to regenerate status
.\STEP3-WINDOWS-MOUNT-CHECK.ps1
```

### Accidentally Committed Personal Data

**Problem:** `HANDOVER-*.md` got committed and pushed

**Solution:**
```bash
# Remove from Git history (DANGEROUS - coordinate with collaborators)
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch HANDOVER-*.md" \
  --prune-empty --tag-name-filter cat -- --all

# Force push (if you control the repository)
git push origin --force --all

# Alternative: Revert and re-commit properly
git revert <commit-hash>
git commit -m "refactor: remove accidentally committed handover docs"
```

---

## Related Documentation

- `README.md` - Main usage guide with step-by-step instructions
- `.gitignore` - Complete list of ignored patterns
- `config.example.ps1` - Template for user configuration
- `/home/user/kenl/SECURITY.md` - Security policy

---

**Last Updated:** 2025-11-12
**ATOM:** ATOM-CFG-20251112-004
