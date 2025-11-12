---
title: Long-Running Task Pattern - Separate Terminal Windows
purpose: Standard approach for tasks requiring user monitoring
classification: DESIGN-PATTERN
---

# Long-Running Task Pattern

**Problem:** Tasks >30s block CLI and provide no visual feedback

**Solution:** Launch in separate terminal window with progress monitoring

---

## Windows Implementation (PowerShell)

### Pattern 1: New PowerShell Window

```powershell
# Download-In-New-Window.ps1
param(
    [string]$Url,
    [string]$Output,
    [string]$TaskName = "Download"
)

$script = @"
`$ErrorActionPreference = 'Stop'

# Header
Write-Host '═══════════════════════════════════════════════════════════' -ForegroundColor Cyan
Write-Host '  $TaskName' -ForegroundColor Cyan
Write-Host '  Started: `$(Get-Date -Format 'HH:mm:ss')' -ForegroundColor Cyan
Write-Host '═══════════════════════════════════════════════════════════' -ForegroundColor Cyan
Write-Host ''

# Status file for main CLI to poll
`$statusFile = "`$env:TEMP\kenl-task-$([guid]::NewGuid().ToString()).status"
'RUNNING' | Out-File -FilePath `$statusFile

try {
    # Download with progress
    aria2c -x16 -s16 \
        --dir='$(Split-Path $Output)' \
        --out='$(Split-Path $Output -Leaf)' \
        --console-log-level=info \
        '$Url'

    Write-Host ''
    Write-Host '═══════════════════════════════════════════════════════════' -ForegroundColor Green
    Write-Host '  ✓ Download Complete' -ForegroundColor Green
    Write-Host '  Time: `$(Get-Date -Format 'HH:mm:ss')' -ForegroundColor Green
    Write-Host '═══════════════════════════════════════════════════════════' -ForegroundColor Green

    'SUCCESS' | Out-File -FilePath `$statusFile
} catch {
    Write-Host ''
    Write-Host '═══════════════════════════════════════════════════════════' -ForegroundColor Red
    Write-Host '  ❌ Download Failed' -ForegroundColor Red
    Write-Host '  Error: `$_' -ForegroundColor Red
    Write-Host '═══════════════════════════════════════════════════════════' -ForegroundColor Red

    "FAILED:`$_" | Out-File -FilePath `$statusFile
}

Write-Host ''
Write-Host 'Press any key to close this window...' -ForegroundColor Gray
`$null = `$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
"@

# Save script to temp
$tempScript = "$env:TEMP\kenl-download-$([guid]::NewGuid()).ps1"
$script | Out-File -FilePath $tempScript -Encoding UTF8

# Launch in new window
Start-Process powershell.exe -ArgumentList "-NoExit", "-ExecutionPolicy", "Bypass", "-File", $tempScript

# Return status file path for polling
return $statusFile
```

### Usage:

```powershell
# Main CLI launches download
$statusFile = .\Download-In-New-Window.ps1 `
    -Url "https://download.bazzite.gg/bazzite-kde-stable.iso" `
    -Output "C:\Users\$env:USERNAME\Downloads\bazzite.iso" `
    -TaskName "Bazzite KDE ISO Download"

# Main CLI can continue working, poll status periodically
Write-Host "Download started in new window"
Write-Host "Status file: $statusFile"
Write-Host "Monitor progress in the new terminal window"
Write-Host ""

# Optional: Poll until complete
while ($true) {
    $status = Get-Content $statusFile -ErrorAction SilentlyContinue

    switch -Wildcard ($status) {
        "RUNNING" {
            Write-Host "⚡ Download in progress..." -ForegroundColor Yellow
            Start-Sleep -Seconds 5
        }
        "SUCCESS" {
            Write-Host "✓ Download complete!" -ForegroundColor Green
            break
        }
        "FAILED:*" {
            Write-Host "❌ Download failed: $($status -replace 'FAILED:', '')" -ForegroundColor Red
            break
        }
    }
}
```

---

## Linux Implementation (screen/tmux)

### Pattern 2: Screen Session

```bash
#!/bin/bash
# download-in-screen.sh

URL="$1"
OUTPUT="$2"
TASK_NAME="${3:-Download}"

SESSION_NAME="kenl-download-$(date +%s)"
STATUS_FILE="/tmp/${SESSION_NAME}.status"

# Create status file
echo "RUNNING" > "$STATUS_FILE"

# Create download script
cat > "/tmp/${SESSION_NAME}.sh" << 'SCRIPT'
#!/bin/bash

echo "═══════════════════════════════════════════════════════════"
echo "  TASK_NAME_PLACEHOLDER"
echo "  Started: $(date +%T)"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Download with progress
if aria2c -x16 -s16 \
    --dir="$(dirname OUTPUT_PLACEHOLDER)" \
    --out="$(basename OUTPUT_PLACEHOLDER)" \
    --console-log-level=info \
    "URL_PLACEHOLDER"; then

    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  ✓ Download Complete"
    echo "  Time: $(date +%T)"
    echo "═══════════════════════════════════════════════════════════"

    echo "SUCCESS" > STATUS_FILE_PLACEHOLDER
else
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  ❌ Download Failed"
    echo "  Error: $?"
    echo "═══════════════════════════════════════════════════════════"

    echo "FAILED:Exit code $?" > STATUS_FILE_PLACEHOLDER
fi

echo ""
echo "Press Enter to close this session..."
read
SCRIPT

# Substitute variables
sed -i "s|URL_PLACEHOLDER|$URL|g" "/tmp/${SESSION_NAME}.sh"
sed -i "s|OUTPUT_PLACEHOLDER|$OUTPUT|g" "/tmp/${SESSION_NAME}.sh"
sed -i "s|TASK_NAME_PLACEHOLDER|$TASK_NAME|g" "/tmp/${SESSION_NAME}.sh"
sed -i "s|STATUS_FILE_PLACEHOLDER|$STATUS_FILE|g" "/tmp/${SESSION_NAME}.sh"

chmod +x "/tmp/${SESSION_NAME}.sh"

# Launch in screen
screen -dmS "$SESSION_NAME" bash "/tmp/${SESSION_NAME}.sh"

# Output instructions
echo "╔════════════════════════════════════════════════════════╗"
echo "║  Download started in screen session                    ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Session name: $SESSION_NAME"
echo "Status file:  $STATUS_FILE"
echo ""
echo "Commands:"
echo "  Monitor:   screen -r $SESSION_NAME"
echo "  Detach:    Ctrl+A, then D"
echo "  Kill:      screen -X -S $SESSION_NAME quit"
echo ""

# Return status file
echo "$STATUS_FILE"
```

### Usage:

```bash
# Launch download in screen
status_file=$(./download-in-screen.sh \
    "https://download.bazzite.gg/bazzite-kde-stable.iso" \
    "$HOME/Downloads/bazzite.iso" \
    "Bazzite KDE ISO Download")

# Main script continues
echo "Download running in background"
echo "Attach to monitor: screen -r kenl-download-*"

# Poll status
while true; do
    status=$(cat "$status_file" 2>/dev/null)

    case "$status" in
        RUNNING)
            echo "⚡ Download in progress..."
            sleep 5
            ;;
        SUCCESS)
            echo "✓ Download complete!"
            break
            ;;
        FAILED:*)
            echo "❌ Download failed: ${status#FAILED:}"
            break
            ;;
    esac
done
```

---

## Pattern 3: tmux (Preferred on Linux)

```bash
#!/bin/bash
# run-in-tmux.sh

TASK_NAME="$1"
COMMAND="$2"
SESSION_NAME="kenl-${TASK_NAME}-$(date +%s)"

# Create tmux session
tmux new-session -d -s "$SESSION_NAME"

# Send commands to session
tmux send-keys -t "$SESSION_NAME" "clear" Enter
tmux send-keys -t "$SESSION_NAME" "echo '═══════════════════════════════════════'" Enter
tmux send-keys -t "$SESSION_NAME" "echo '  $TASK_NAME'" Enter
tmux send-keys -t "$SESSION_NAME" "echo '  Started: \$(date +%T)'" Enter
tmux send-keys -t "$SESSION_NAME" "echo '═══════════════════════════════════════'" Enter
tmux send-keys -t "$SESSION_NAME" "echo ''" Enter
tmux send-keys -t "$SESSION_NAME" "$COMMAND" Enter

# Output instructions
echo "╔════════════════════════════════════════════════════════╗"
echo "║  Task started in tmux session                          ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Session name: $SESSION_NAME"
echo ""
echo "Commands:"
echo "  Attach:    tmux attach -t $SESSION_NAME"
echo "  Detach:    Ctrl+B, then D"
echo "  Kill:      tmux kill-session -t $SESSION_NAME"
echo "  List all:  tmux list-sessions"
echo ""
```

### Usage:

```bash
# Download ISO in tmux
./run-in-tmux.sh "Bazzite-Download" \
    "aria2c -x16 https://download.bazzite.gg/bazzite-kde-stable.iso"

# Partition disk in tmux
./run-in-tmux.sh "Disk-Partition" \
    "sudo ./scripts/STEP2-LINUX-PARTITION-DISK.sh"

# Multiple tasks in parallel
./run-in-tmux.sh "Download-ISO" "aria2c ..."
./run-in-tmux.sh "Format-Disk" "mkfs.ext4 ..."
./run-in-tmux.sh "Compile-Code" "make -j8"

# List all active tasks
tmux list-sessions
```

---

## Standard Task Wrapper

### Universal Script (Works on Windows + Linux)

```powershell
# Run-LongTask.ps1
<#
.SYNOPSIS
    Universal wrapper for long-running tasks
.DESCRIPTION
    Launches task in separate terminal with progress monitoring
    Works on Windows (PowerShell) and Linux (tmux/screen)
#>

param(
    [Parameter(Mandatory)]
    [string]$TaskName,

    [Parameter(Mandatory)]
    [string]$Command,

    [ValidateSet("powershell", "tmux", "screen", "auto")]
    [string]$Method = "auto"
)

# Auto-detect method
if ($Method -eq "auto") {
    if ($IsWindows -or $env:OS -match "Windows") {
        $Method = "powershell"
    } elseif (Get-Command tmux -ErrorAction SilentlyContinue) {
        $Method = "tmux"
    } elseif (Get-Command screen -ErrorAction SilentlyContinue) {
        $Method = "screen"
    } else {
        throw "No suitable terminal multiplexer found (tmux/screen)"
    }
}

# Generate session ID
$sessionId = "kenl-$TaskName-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$statusFile = if ($IsWindows) { "$env:TEMP\$sessionId.status" } else { "/tmp/$sessionId.status" }

switch ($Method) {
    "powershell" {
        # Windows implementation (from Pattern 1 above)
        # ... (insert Pattern 1 code)
    }

    "tmux" {
        # Linux tmux implementation (from Pattern 3 above)
        # ... (insert Pattern 3 code)
    }

    "screen" {
        # Linux screen implementation (from Pattern 2 above)
        # ... (insert Pattern 2 code)
    }
}

# Return session info
[PSCustomObject]@{
    SessionId = $sessionId
    StatusFile = $statusFile
    Method = $Method
    TaskName = $TaskName
}
```

### Usage Examples:

```powershell
# Download ISO
$task = .\Run-LongTask.ps1 -TaskName "ISO-Download" -Command "aria2c -x16 https://..."

# Check status
Get-Content $task.StatusFile

# Partition disk
$task = .\Run-LongTask.ps1 -TaskName "Disk-Partition" -Command ".\STEP2-WINDOWS-PARTITION-DISK1.ps1"

# Multiple parallel tasks
$iso = .\Run-LongTask.ps1 "Download-ISO" "aria2c ..."
$disk = .\Run-LongTask.ps1 "Partition-Disk" ".\STEP2..."
$build = .\Run-LongTask.ps1 "Build-Code" "cmake --build ."

# Wait for all to complete
$iso, $disk, $build | ForEach-Object {
    while ((Get-Content $_.StatusFile) -eq "RUNNING") {
        Start-Sleep -Seconds 2
    }
    Write-Host "✓ $($_.TaskName) complete"
}
```

---

## Best Practices

### 1. Status File Format

```
RUNNING
SUCCESS
FAILED:<error message>
PROGRESS:45%
```

### 2. Session Naming Convention

```
kenl-<task-type>-<timestamp>

Examples:
kenl-iso-download-20251112-143022
kenl-disk-partition-20251112-143156
kenl-build-cmake-20251112-143401
```

### 3. Header Template

```
═══════════════════════════════════════════════════════════
  TASK NAME
  Started: HH:MM:SS
  Session: kenl-xxx-yyy
═══════════════════════════════════════════════════════════

[Task output here]

═══════════════════════════════════════════════════════════
  ✓ Complete / ❌ Failed
  Finished: HH:MM:SS
  Duration: Xm Ys
═══════════════════════════════════════════════════════════
```

### 4. Cleanup

```powershell
# Auto-cleanup after task completes
if ($status -match "SUCCESS|FAILED") {
    Start-Sleep -Seconds 30
    Remove-Item $statusFile -ErrorAction SilentlyContinue
    Remove-Item $tempScript -ErrorAction SilentlyContinue
}
```

---

## Tasks That Should Use This Pattern

```yaml
Always use separate window:
  - ISO downloads (>1GB)
  - Disk formatting/partitioning
  - Large file transfers
  - Database migrations
  - Compilation >1 minute
  - Video encoding
  - Machine learning training

Sometimes use (if >30s):
  - Package installations
  - Git clones of large repos
  - Archive extraction
  - File backups

Never use (keep in main CLI):
  - Quick checks (<5s)
  - User input prompts
  - Status queries
  - File reads
  - Simple calculations
```

---

## KENL Standard Implementation

Create these helper scripts in `scripts/`:

1. `scripts/Run-In-New-Window.ps1` - Windows launcher
2. `scripts/run-in-tmux.sh` - Linux tmux launcher
3. `scripts/run-in-screen.sh` - Linux screen launcher
4. `scripts/monitor-task.ps1` - Poll status and report

---

Last Updated: 2025-11-12
ATOM: ATOM-PATTERN-20251112-001
