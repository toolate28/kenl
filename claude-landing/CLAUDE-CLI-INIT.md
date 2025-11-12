---
title: Claude Code CLI Initialization
purpose: Auto-load at CLI session start for command discovery
classification: SESSION-INIT
---

# Claude Code CLI - Session Initialization

**Read this file at every new CLI session start.**

---

## Available Command Registry

✓ **Load:** `claude-landing/KENL-COMMANDS.md`

This file contains:
- All KENL PowerShell commands
- All partition scripts (STEP1-STEP3)
- Bash commands for Linux
- Usage examples
- Safety rules

**You have direct access to:**
- Disk management commands
- Partition scripts (destructive - require confirmation)
- ISO download helpers
- Network diagnostics

---

## Output Formatting Rules

✓ **Follow:** `claude-landing/CLI-OUTPUT-GUIDE.md`

Use clean, scannable output:
- Task headers in boxes
- Status symbols (✓⚡⏸️❌)
- Progress bars for downloads
- Clear "Next Action" at end

**Suppress:**
- Repetitive system reminders (user knows about file changes)
- Verbose explanations when action needed
- Multiple file reads when 1 would suffice

---

## Session Workflow

```
1. Load KENL-COMMANDS.md → Know what you can run
2. Load CLI-OUTPUT-GUIDE.md → Format output cleanly
3. Check user request → Match to available commands
4. Show command before running → User sees what's happening
5. Run → Capture output → Interpret → Next step
```

---

## Example Invocation

Instead of this (verbose):
```
I'll check if the external drive is connected by running a PowerShell
command that gets disk information formatted as a table showing the
disk number, friendly name, and size...

● Bash(powershell -Command "Get-Disk...")
```

Do this (clean):
```
Checking external drives...

Command: Get-Disk | Format-Table Number, FriendlyName, Size

● Bash(powershell -NoProfile -Command "Get-Disk | Format-Table...")
```

---

## Safety Checklist

Before running partition commands:
```
☐ Verified disk number (Get-Disk)
☐ Confirmed it's external (not system/boot)
☐ Asked user for explicit confirmation
☐ Explained data will be destroyed
☐ Captured disk info for handover doc
```

---

## Current Session Context

**Environment:** Windows 11
**Branch:** main
**Working Dir:** `C:\Users\Matthew Ruhnau\kenl`
**Shell:** Git Bash (PowerShell available via `powershell` command)

**External Drive:** 2TB Seagate (verify with Get-Disk)
**Pending Tasks:**
1. Download Bazzite KDE ISO
2. Partition external drive

**Important:** Scripts are in `scripts/` directory (STEP1-STEP3)

---

**Auto-load this at every session start for command discovery.**

Last Updated: 2025-11-12
