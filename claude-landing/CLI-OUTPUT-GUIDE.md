---
title: CLI Output Best Practices
purpose: Guide for clean, scannable Claude Code CLI output
---

# CLI Output Formatting Guide

## Problems to Avoid

❌ **Don't:**
- Show the same system reminder 3+ times
- Output walls of text without structure
- Use verbose explanations when action is needed
- Mix completed/pending tasks without clear status

✓ **Do:**
- Use clear visual hierarchy (headers, bullets, spacing)
- Show progress indicators for long tasks
- Separate "what happened" from "what's next"
- Use emojis/symbols for quick scanning

---

## Output Templates

### Task Start

```
╔══════════════════════════════════════╗
║  PARTITIONING 2TB EXTERNAL DRIVE     ║
╚══════════════════════════════════════╝

Prerequisites:
  ✓ PowerShell (Administrator)
  ✓ External drive connected
  ⚠️  Will DESTROY all data on Disk 1

Next: Run STEP1-WINDOWS-WIPE-DISK1.ps1
```

### Progress Update

```
[2/5] Downloading Bazzite ISO

Progress: ████████░░░░░░░░ 45% (1.4GB / 3.1GB)
Speed: 12.3 MB/s
ETA: 2m 15s

✓ aria2c installed
✓ Download started
⚡ Verifying chunks...
```

### Task Complete

```
✓ STEP1 Complete - Disk Wiped

Created:
  📄 HANDOVER-DISK-WIPE-20251112-143022.md (Desktop)

Next:
  Run: .\scripts\STEP2-WINDOWS-PARTITION-DISK1.ps1
```

### Error State

```
❌ ERROR: Disk 1 Not Found

Diagnosis:
  - External drive may be unplugged
  - Drive letter may have changed
  - Permissions issue

Fix:
  1. Check Device Manager (Win+X → Device Manager)
  2. Reconnect external drive
  3. Run: Get-Disk | Format-Table

Retry: .\scripts\STEP1-WINDOWS-WIPE-DISK1.ps1
```

---

## Status Symbols

Use these for quick scanning:

```
✓ Done/Success
⚡ In Progress
⏸️  Queued/Pending
❌ Error/Failed
⚠️  Warning/Attention
📄 File Created
🔧 Configuration
💾 Disk Operation
🌐 Network Download
```

---

## Command Output

### Before (cluttered):
```
I'm going to check if the disk is available by running Get-Disk and then
I'll format the output as a table showing the disk number, friendly name,
size in gigabytes which I'll calculate using the math round function...

Bash(powershell -NoProfile -Command "Get-Disk -Number 1 | Format-Table...")
```

### After (clean):
```
Checking Disk 1...

Command: Get-Disk -Number 1
```

---

## Multi-Step Workflows

```
╔══════════════════════════════════════╗
║  WORKFLOW: Setup Gaming Drive        ║
╚══════════════════════════════════════╝

[1/5] ✓ Review Disk 1 (00:15)
[2/5] ⚡ Download ISO (04:32 remaining)
[3/5] ⏸️  Verify SHA256
[4/5] ⏸️  Wipe Disk 1
[5/5] ⏸️  Partition & Format

Current: Downloading Bazzite KDE ISO
  ████████████░░░░ 75% (2.3GB / 3.1GB)

No input needed - will auto-proceed to step 3
```

---

## Configuration

Tell CLI Claude:

> "From now on, use the output format from CLI-OUTPUT-GUIDE.md:
> - Start with task header box
> - Show progress for long operations
> - Use status symbols (✓⚡⏸️❌)
> - Clear 'Next Action' at end
> - Suppress repetitive system reminders"

---

Last Updated: 2025-11-12
