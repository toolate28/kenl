---
title: CLI Output Formatting Standards
purpose: Industry practices and bleeding-edge techniques for terminal UX
classification: FORMATTING-GUIDE
---

# CLI Formatting Standards for Claude Code

## Industry Practices + Bleeding Edge Techniques

---

## 1. Visual Structure Elements

### Box Drawing (Unicode)

```
Standard Boxes:
┌──────────────────────────────┐
│  TASK: Download Bazzite ISO  │
└──────────────────────────────┘

Heavy Boxes (high priority):
╔══════════════════════════════╗
║  ⚠️  DESTRUCTIVE OPERATION   ║
╚══════════════════════════════╝

Rounded (friendly):
╭──────────────────────────────╮
│  ✓ Task Complete             │
╰──────────────────────────────╯

Double Line (reports):
╔══════════════════════════════╗
║  FINAL REPORT                ║
╟──────────────────────────────╢
║  Status: Success             ║
╚══════════════════════════════╝
```

### Tree Structures

```
Project Status:
├─ ✓ Download ISO (completed 14:32)
├─ ⚡ Partition Drive (in progress)
│  ├─ ✓ STEP1: Wipe disk
│  ├─ ⚡ STEP2: Create partitions (45% complete)
│  └─ ⏸️  STEP3: Verify layout
└─ ⏸️  Boot to Bazzite
```

### Horizontal Rules

```
═══════════════════════════════  (heavy, separates major sections)
───────────────────────────────  (light, separates items)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  (medium, subsections)
```

---

## 2. Output Types - Industry Templates

### A) FINAL REPORT

```
╔══════════════════════════════════════════════════════╗
║  FINAL REPORT: Disk Partitioning                    ║
╟──────────────────────────────────────────────────────╢
║  Started:  2025-11-12 14:15:32                       ║
║  Completed: 2025-11-12 14:47:18                      ║
║  Duration:  31m 46s                                  ║
╚══════════════════════════════════════════════════════╝

┌─ SUMMARY ─────────────────────────────────────────┐
│ ✓ Disk wiped successfully                         │
│ ✓ 5 partitions created                            │
│ ✓ Filesystems formatted (NTFS, exFAT)             │
│ ⚠️  2 partitions pending (format as ext4 in Linux) │
└────────────────────────────────────────────────────┘

┌─ CREATED ARTIFACTS ───────────────────────────────┐
│ 📄 HANDOVER-DISK-WIPE-20251112-141532.md          │
│ 📄 HANDOVER-PARTITION-20251112-143045.md          │
│ 📄 HANDOVER-VERIFICATION-20251112-144718.md       │
└────────────────────────────────────────────────────┘

┌─ PARTITION LAYOUT ────────────────────────────────┐
│ [1] Games-Universal  900GB  NTFS    H:  ✓ Ready  │
│ [2] Claude-AI-Data   500GB  RAW     I:  ⚠️  ext4  │
│ [3] Development      200GB  RAW     L:  ⚠️  ext4  │
│ [4] Windows-Only     150GB  NTFS    K:  ✓ Ready  │
│ [5] Transfer          50GB  exFAT   J:  ✓ Ready  │
└────────────────────────────────────────────────────┘

┌─ NEXT STEPS ──────────────────────────────────────┐
│ 1. Boot into Bazzite-DX Linux (USB or installed)  │
│ 2. Format partitions 2 & 3 as ext4:               │
│    sudo mkfs.ext4 -L "Claude-AI-Data" /dev/sdb2   │
│    sudo mkfs.ext4 -L "Development" /dev/sdb3      │
│ 3. Configure /etc/fstab (see handover docs)       │
└────────────────────────────────────────────────────┘

ATOM: ATOM-CFG-20251112-002
```

### B) REQUEST FOR APPROVAL

```
╔══════════════════════════════════════════════════════╗
║  ⚠️  APPROVAL REQUIRED: DESTRUCTIVE OPERATION        ║
╚══════════════════════════════════════════════════════╝

ACTION: Wipe Disk 1 (2TB Seagate FireCuda)

┌─ IMPACT ANALYSIS ─────────────────────────────────┐
│ ❌ ALL DATA WILL BE PERMANENTLY DELETED           │
│ ❌ This action CANNOT be undone                    │
│ ✓ System disk is safe (Disk 0, C:\ unaffected)    │
│ ✓ Rollback: Reconnect old drive if available      │
└────────────────────────────────────────────────────┘

┌─ TARGET DISK ─────────────────────────────────────┐
│ Number:        1                                   │
│ Name:          Seagate FireCuda 520 SSD           │
│ Size:          1,863.01 GB                         │
│ Type:          External USB                        │
│ System Disk:   NO ✓                                │
│ Boot Disk:     NO ✓                                │
└────────────────────────────────────────────────────┘

┌─ CURRENT PARTITIONS (will be destroyed) ──────────┐
│ E:\ Data (1.2TB, NTFS) - Photos, videos           │
│ F:\ Games (600GB, NTFS) - Steam library            │
└────────────────────────────────────────────────────┘

┌─ SAFETY CHECKS ───────────────────────────────────┐
│ ✓ Verified disk is external (not internal NVMe)   │
│ ✓ Verified not system disk                        │
│ ✓ Verified not boot disk                          │
│ ⚠️  Backup recommended (none detected)             │
└────────────────────────────────────────────────────┘

┌─ OPTIONS ─────────────────────────────────────────┐
│ [1] PROCEED - Wipe Disk 1 (cannot undo)           │
│ [2] CANCEL  - Abort operation, keep current data  │
│ [3] BACKUP  - Show backup commands first          │
└────────────────────────────────────────────────────┘

Your choice (1/2/3):
```

### C) PROGRESS INDICATOR

```
╭──────────────────────────────────────────────────────╮
│  ⚡ Downloading: bazzite-deck-gnome-stable.iso      │
╰──────────────────────────────────────────────────────╯

Progress: [████████████████░░░░░░░░░░░░] 55.3%

Downloaded:   1.71 GB / 3.09 GB
Speed:        14.2 MB/s (avg: 12.8 MB/s)
ETA:          1m 47s
Connections:  16/16 active

Chunks: [8/16] ██████████████░░░░░░░░░░░░░░░░ 52%

Time Elapsed:  2m 14s
Started:       14:32:18
Est. Complete: 14:36:05
```

### D) ERROR REPORT

```
╔══════════════════════════════════════════════════════╗
║  ❌ ERROR: Disk Write Failed                         ║
╚══════════════════════════════════════════════════════╝

┌─ ERROR DETAILS ───────────────────────────────────┐
│ Command: Format-Volume -DriveLetter H -FileSystem NTFS │
│ Code:    0x80070015 (ERROR_DEVICE_NOT_READY)      │
│ Time:    14:42:33                                  │
│ Step:    STEP2 - Partition Creation               │
└────────────────────────────────────────────────────┘

┌─ DIAGNOSIS ───────────────────────────────────────┐
│ Likely Causes:                                     │
│ • Disk not fully initialized after format         │
│ • USB connection instability                       │
│ • Disk in sleep mode                               │
└────────────────────────────────────────────────────┘

┌─ RECOVERY STEPS ──────────────────────────────────┐
│ 1. Wait 5 seconds for disk to initialize:         │
│    Start-Sleep -Seconds 5                          │
│                                                     │
│ 2. Retry format command:                           │
│    Format-Volume -DriveLetter H -FileSystem NTFS   │
│                                                     │
│ 3. If still fails, reconnect USB drive:            │
│    - Safely eject drive                            │
│    - Unplug USB cable                              │
│    - Wait 10 seconds                               │
│    - Reconnect                                     │
│    - Re-run STEP2-WINDOWS-PARTITION-DISK1.ps1      │
│                                                     │
│ 4. Check disk health:                              │
│    Get-Disk -Number 1 | Get-StorageReliabilityCounter │
└────────────────────────────────────────────────────┘

┌─ AUTOMATED FIX AVAILABLE ─────────────────────────┐
│ Would you like me to:                              │
│ [1] Wait 5s and retry automatically                │
│ [2] Show manual recovery commands                  │
│ [3] Abort and investigate further                  │
└────────────────────────────────────────────────────┘

Logs saved to: .archive\logs\error-20251112-144233.log
```

### E) STATUS UPDATE

```
┌─ SYSTEM STATUS ───────────────────────────────────┐
│ 🖥️  Platform:    Windows 11 Pro (Build 22631.4602) │
│ 💾 Working Dir:  %USERPROFILE%\kenl                │
│ 🌿 Git Branch:   main (clean)                      │
│ ⏰ Session Time: 14m 32s                           │
└────────────────────────────────────────────────────┘

┌─ ACTIVE TASKS ────────────────────────────────────┐
│ [1/3] ✓ Download Bazzite ISO (completed 14:36)    │
│ [2/3] ⚡ Partition Drive (step 2 of 3)             │
│       ├─ ✓ STEP1: Wipe                             │
│       ├─ ⚡ STEP2: Create partitions (55%)         │
│       └─ ⏸️  STEP3: Verify                          │
│ [3/3] ⏸️  Boot to Bazzite                           │
└────────────────────────────────────────────────────┘

┌─ RESOURCES ───────────────────────────────────────┐
│ Disk I/O:    ████░░░░░░ 38% (142 MB/s write)      │
│ Network:     ██░░░░░░░░ 15% (idle)                │
│ CPU:         ███░░░░░░░ 28% (PowerShell, aria2c)  │
└────────────────────────────────────────────────────┘
```

---

## 3. Color & Emphasis (ANSI Codes)

### Status Colors

```bash
# Bash/Terminal (ANSI)
echo -e "\033[32m✓ Success\033[0m"    # Green
echo -e "\033[33m⚠️  Warning\033[0m"   # Yellow
echo -e "\033[31m❌ Error\033[0m"      # Red
echo -e "\033[36mℹ️  Info\033[0m"      # Cyan
echo -e "\033[35m⚡ Progress\033[0m"   # Magenta
```

### PowerShell

```powershell
Write-Host "✓ Success" -ForegroundColor Green
Write-Host "⚠️  Warning" -ForegroundColor Yellow
Write-Host "❌ Error" -ForegroundColor Red
Write-Host "ℹ️  Info" -ForegroundColor Cyan
Write-Host "⚡ Progress" -ForegroundColor Magenta
```

### Text Styles

```
Bold:          **CRITICAL**
Italic:        *emphasis*
Underline:     __important__
Strikethrough: ~~deprecated~~
Code:          `command`
Block:         ```code block```
```

---

## 4. Data Tables

### Aligned Columns

```
┌─ PARTITION SUMMARY ───────────────────────────────────────────┐
│ #   Label              Size    FS      Drive  Status          │
├───────────────────────────────────────────────────────────────┤
│ 1   Games-Universal    900GB   NTFS    H:     ✓ Ready         │
│ 2   Claude-AI-Data     500GB   RAW     I:     ⚠️  Format ext4   │
│ 3   Development        200GB   RAW     L:     ⚠️  Format ext4   │
│ 4   Windows-Only       150GB   NTFS    K:     ✓ Ready         │
│ 5   Transfer            50GB   exFAT   J:     ✓ Ready         │
└───────────────────────────────────────────────────────────────┘
```

### Compact Lists

```
Partitions Created:
  1. Games-Universal ........ 900GB NTFS  (H:) ✓
  2. Claude-AI-Data ......... 500GB RAW   (I:) ⚠️
  3. Development ............ 200GB RAW   (L:) ⚠️
  4. Windows-Only ........... 150GB NTFS  (K:) ✓
  5. Transfer ................. 50GB exFAT (J:) ✓
```

---

## 5. Bleeding Edge Techniques

### A) Hyperlinks in Terminal (iTerm2, Windows Terminal)

```
\033]8;;https://download.bazzite.gg/\033\\Download Bazzite\033]8;;\033\\

Renders as clickable: Download Bazzite
```

### B) Inline Images (kitty, iTerm2)

```bash
# Display QR code for WiFi config
echo -e "\033]1337;File=inline=1:`base64 qrcode.png`\007"
```

### C) Rich Progress (Python Rich library style)

```
╭──────────────────────────────────────╮
│ ⏳ Installing Dependencies           │
├──────────────────────────────────────┤
│ ⚡ aria2c ████████████████░░ 89%     │
│ ✓ choco  ████████████████████ 100%  │
│ ⏸️  python ░░░░░░░░░░░░░░░░░░  0%   │
╰──────────────────────────────────────╯
```

### D) Spinners

```
⠋ Loading...
⠙ Loading...
⠹ Loading...
⠸ Loading...
⠼ Loading...
⠴ Loading...
⠦ Loading...
⠧ Loading...
⠇ Loading...
⠏ Loading...
```

### E) Live Dashboard (TUI frameworks)

```
╔═══════════════════ KENL Dashboard ═══════════════════╗
║                                                        ║
║  Session: 2025-11-12 14:32              Uptime: 14m   ║
║                                                        ║
╟────────────────────────────────────────────────────────╢
║  TASKS                                     [2/3] 67%  ║
╟────────────────────────────────────────────────────────╢
║  ✓ Download ISO                             14:36     ║
║  ⚡ Partition Drive                          55%       ║
║    └─ STEP2: Creating partitions... [████░░] 4/5      ║
║  ⏸️  Boot to Bazzite                         --        ║
╟────────────────────────────────────────────────────────╢
║  LOGS (last 3)                                         ║
╟────────────────────────────────────────────────────────╢
║  14:42:18 ✓ Partition 3 formatted                     ║
║  14:42:15 ✓ Partition 2 formatted                     ║
║  14:42:10 ⚡ Creating partition 4...                   ║
╚════════════════════════════════════════════════════════╝

Press 'q' to quit, 'h' for help
```

---

## 6. Context-Aware Formatting

### When to Use Each Style

| Output Type | Style | Use Case |
|-------------|-------|----------|
| Critical Warning | Heavy box (╔═══╗) + Red | Destructive operations |
| Success | Light box (┌───┐) + Green | Task completion |
| Progress | No box, progress bar | Long-running tasks |
| Data Table | Bordered table | Structured data |
| Error | Heavy box + Red + Recovery | Failed operations |
| Request Input | Light box + Options | User decisions |
| Info | No box, cyan text | FYI messages |
| Report | Double-line box (╟───╢) | Final summaries |

---

## 7. Semantic Formatting Blocks

### Convention: Use these markers

```
############  Major Section Header
****          Critical/Warning Content
&&&           User Input Required
===           Subsection Divider
---           Item Separator
>>>           Next Action
```

### Example Implementation

```
############################################
#  DISK PARTITIONING WORKFLOW              #
############################################

*** CRITICAL WARNING ***
This will DESTROY all data on Disk 1.
Backup important files before proceeding.
*** END WARNING ***

═══════════════════════════════════════════
STEP 1: Disk Preparation
═══════════════════════════════════════════

✓ Disk identified: Seagate 2TB
✓ Safety checks passed
✓ Ready to proceed

───────────────────────────────────────────

&&& USER INPUT REQUIRED &&&
Type 'WIPE DISK 1' to confirm:
_

═══════════════════════════════════════════
STEP 2: Create Partitions
═══════════════════════════════════════════

⚡ Creating 5 partitions...
  [████████████████░░░░] 80% (4/5)

───────────────────────────────────────────

>>> NEXT ACTION >>>
Wait for partition creation to complete
Estimated time remaining: 45 seconds
```

---

## 8. Recommended Tooling

### For Python
```python
from rich.console import Console
from rich.progress import Progress
from rich.table import Table
from rich.panel import Panel

console = Console()
console.print("[bold green]✓ Success![/bold green]")
```

### For PowerShell
```powershell
# Use Write-Host with colors
# Use Format-Table for data
# Use custom functions for boxes
```

### For Bash
```bash
# Use echo -e with ANSI codes
# Use printf for alignment
# Use tput for terminal capabilities
```

---

## 9. KENL Standard Template

```
╔══════════════════════════════════════════════════════╗
║  [TASK NAME]                            ATOM-XXX-YYY ║
╚══════════════════════════════════════════════════════╝

┌─ STATUS ──────────────────────────────────────────────┐
│ [Progress indicator or completion status]             │
└────────────────────────────────────────────────────────┘

┌─ DETAILS ─────────────────────────────────────────────┐
│ [Relevant information, tables, or data]                │
└────────────────────────────────────────────────────────┘

┌─ NEXT STEPS ──────────────────────────────────────────┐
│ 1. [First action]                                      │
│ 2. [Second action]                                     │
└────────────────────────────────────────────────────────┘

Generated: 2025-11-12 14:32:18
```

---

Last Updated: 2025-11-12
ATOM: ATOM-CFG-20251112-008
