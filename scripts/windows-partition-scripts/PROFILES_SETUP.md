---
project: kenl - Bazza-DX SAGE Framework
status: active
version: 1.0.0
classification: OWI-DOC
atom: ATOM-CFG-20251112-006
owi-version: 1.0.0
---

# Profile Configuration - PowerShell & Bash

**Purpose:** Auto-load functions and aliases for partition scripts

**ATOM Tag:** `ATOM-CFG-20251112-006`

---

## PowerShell Profile Setup (Windows)

### Locate Your Profile

```powershell
# Check if profile exists
Test-Path $PROFILE

# Show profile path
$PROFILE

# Common locations:
# C:\Users\USERNAME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
# C:\Users\USERNAME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
```

### Create Profile (If Doesn't Exist)

```powershell
# Create profile file
if (!(Test-Path $PROFILE)) {
    New-Item -Path $PROFILE -ItemType File -Force
    Write-Host "✓ Created profile at: $PROFILE" -ForegroundColor Green
}

# Open in notepad
notepad $PROFILE
```

---

## PowerShell Profile Content

Add this to your `$PROFILE`:

```powershell
# ============================================
# KENL Partition Scripts - Profile Setup
# ============================================

# Set scripts directory
$env:KENL_SCRIPTS = "C:\Users\$env:USERNAME\kenl\scripts\windows-partition-scripts"

# Change to your actual path if different
# $env:KENL_SCRIPTS = "D:\Projects\kenl\scripts\windows-partition-scripts"

# ============================================
# Helper Functions
# ============================================

function kenl-disk {
    <#
    .SYNOPSIS
        Quick disk information display
    .DESCRIPTION
        Shows all disks with key info for partition script planning
    #>
    Get-Disk | Format-Table Number, FriendlyName,
        @{Label="Size(GB)"; Expression={[math]::Round($_.Size / 1GB, 2)}},
        PartitionStyle, IsSystem, IsBoot -AutoSize
}

function kenl-wipe {
    <#
    .SYNOPSIS
        Run STEP1 disk wipe script
    #>
    param(
        [switch]$WhatIf
    )

    Push-Location $env:KENL_SCRIPTS
    if ($WhatIf) {
        Write-Host "Would run: .\STEP1-WINDOWS-WIPE-DISK1.ps1" -ForegroundColor Yellow
    } else {
        .\STEP1-WINDOWS-WIPE-DISK1.ps1
    }
    Pop-Location
}

function kenl-partition {
    <#
    .SYNOPSIS
        Run STEP2 partition creation script
    #>
    param(
        [switch]$WhatIf
    )

    Push-Location $env:KENL_SCRIPTS
    if ($WhatIf) {
        Write-Host "Would run: .\STEP2-WINDOWS-PARTITION-DISK1.ps1" -ForegroundColor Yellow
    } else {
        .\STEP2-WINDOWS-PARTITION-DISK1.ps1
    }
    Pop-Location
}

function kenl-verify {
    <#
    .SYNOPSIS
        Run STEP3 verification script
    #>
    param(
        [switch]$WhatIf
    )

    Push-Location $env:KENL_SCRIPTS
    if ($WhatIf) {
        Write-Host "Would run: .\STEP3-WINDOWS-MOUNT-CHECK.ps1" -ForegroundColor Yellow
    } else {
        .\STEP3-WINDOWS-MOUNT-CHECK.ps1
    }
    Pop-Location
}

function kenl-setup {
    <#
    .SYNOPSIS
        Navigate to partition scripts directory
    #>
    Set-Location $env:KENL_SCRIPTS
    Write-Host "📁 KENL Partition Scripts" -ForegroundColor Cyan
    Get-ChildItem *.ps1 | Format-Table Name, Length, LastWriteTime -AutoSize
}

function kenl-handover {
    <#
    .SYNOPSIS
        List handover documents
    #>
    $desktop = [Environment]::GetFolderPath("Desktop")
    Get-ChildItem "$desktop\HANDOVER-*.md" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Format-Table Name, LastWriteTime -AutoSize
}

function kenl-archive {
    <#
    .SYNOPSIS
        Archive handover docs to .archive directory
    #>
    $desktop = [Environment]::GetFolderPath("Desktop")
    $archiveDir = Join-Path $env:KENL_SCRIPTS ".archive\handover-docs"

    if (!(Test-Path $archiveDir)) {
        New-Item -Path $archiveDir -ItemType Directory -Force | Out-Null
    }

    $handovers = Get-ChildItem "$desktop\HANDOVER-*.md" -ErrorAction SilentlyContinue
    if ($handovers) {
        $handovers | Move-Item -Destination $archiveDir -Force
        Write-Host "✓ Archived $($handovers.Count) handover document(s)" -ForegroundColor Green
    } else {
        Write-Host "No handover documents found on Desktop" -ForegroundColor Yellow
    }
}

function kenl-config {
    <#
    .SYNOPSIS
        Open or create config.local.ps1
    #>
    Push-Location $env:KENL_SCRIPTS

    $configLocal = "config.local.ps1"
    $configExample = "config.example.ps1"

    if (!(Test-Path $configLocal)) {
        if (Test-Path $configExample) {
            Copy-Item $configExample $configLocal
            Write-Host "✓ Created $configLocal from example" -ForegroundColor Green
        } else {
            Write-Host "❌ $configExample not found" -ForegroundColor Red
            Pop-Location
            return
        }
    }

    notepad $configLocal
    Pop-Location
}

# ============================================
# Aliases
# ============================================

Set-Alias -Name kdisk -Value kenl-disk
Set-Alias -Name kwipe -Value kenl-wipe
Set-Alias -Name kpart -Value kenl-partition
Set-Alias -Name kverify -Value kenl-verify
Set-Alias -Name ksetup -Value kenl-setup
Set-Alias -Name khand -Value kenl-handover
Set-Alias -Name karc -Value kenl-archive
Set-Alias -Name kconf -Value kenl-config

# ============================================
# Safety Warnings
# ============================================

function Show-KenlWarning {
    Write-Host ""
    Write-Host "⚠️  KENL Partition Functions Loaded" -ForegroundColor Yellow
    Write-Host "   Quick commands: kdisk, kwipe, kpart, kverify" -ForegroundColor Gray
    Write-Host "   ❌ NEVER run these from WSL2 - Use native Windows PowerShell only" -ForegroundColor Red
    Write-Host ""
}

# Show warning on profile load (comment out if annoying)
# Show-KenlWarning

# ============================================
# Tab Completion
# ============================================

Register-ArgumentCompleter -CommandName kenl-wipe,kenl-partition,kenl-verify -ParameterName WhatIf -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    @('$true', '$false') | Where-Object { $_ -like "$wordToComplete*" }
}

Write-Host "✓ KENL partition functions loaded" -ForegroundColor Green
```

---

## PowerShell Profile Usage

### After Adding to Profile

```powershell
# Reload profile
. $PROFILE

# OR restart PowerShell
```

### Quick Commands

```powershell
# Show all disks
kdisk

# Navigate to scripts directory
ksetup

# Run partition workflow
kwipe          # STEP1: Wipe disk
kpart          # STEP2: Create partitions
kverify        # STEP3: Verify layout

# Manage results
khand          # List handover docs
karc           # Archive to .archive/

# Configuration
kconf          # Edit config.local.ps1
```

### WhatIf Mode (Dry Run)

```powershell
# Test without executing
kenl-wipe -WhatIf
kenl-partition -WhatIf
kenl-verify -WhatIf
```

---

## Bash Profile Setup (Linux - Native Bazzite-DX ONLY)

**⚠️ CRITICAL:** These functions are for **native Linux boot only**, NOT WSL2!

### Locate Your Profile

```bash
# Check which profile file exists
ls -la ~ | grep -E 'bashrc|bash_profile|profile'

# Common files (in order of precedence):
# ~/.bash_profile (login shells)
# ~/.bashrc (interactive shells)
# ~/.profile (fallback)
```

### Edit Profile

```bash
# Most systems use .bashrc
nano ~/.bashrc

# OR for login shells
nano ~/.bash_profile
```

---

## Bash Profile Content

Add this to your `~/.bashrc` or `~/.bash_profile`:

```bash
# ============================================
# KENL Partition Scripts - Bash Profile
# ============================================

# Detect if running in WSL2 (block dangerous operations)
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
    export KENL_WSL2=1
    export KENL_DANGER="WSL2-DETECTED"
else
    export KENL_WSL2=0
    export KENL_DANGER=""
fi

# ============================================
# Helper Functions
# ============================================

kenl-disk() {
    # Show all disks with partition info
    echo "=== Available Disks ==="
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE,LABEL
}

kenl-check-external() {
    # Identify likely external drive
    local target="${1:-sdb}"

    if [ "$KENL_WSL2" -eq 1 ]; then
        echo "❌ ERROR: Running in WSL2"
        echo "   Boot native Linux to format partitions"
        return 1
    fi

    if [ ! -b "/dev/$target" ]; then
        echo "❌ ERROR: /dev/$target not found"
        echo "   Available disks:"
        lsblk -d -o NAME,SIZE,TYPE
        return 1
    fi

    echo "✓ Found /dev/$target"
    lsblk -o NAME,SIZE,FSTYPE,LABEL "/dev/$target"
}

kenl-format-ext4() {
    # Format Linux partitions as ext4
    # Usage: kenl-format-ext4 sdb2 "Claude-AI-Data"
    #        kenl-format-ext4 sdb3 "Development"

    if [ "$KENL_WSL2" -eq 1 ]; then
        echo "❌ BLOCKED: Cannot format from WSL2"
        echo "   Boot native Bazzite-DX and run from there"
        return 1
    fi

    local partition="$1"
    local label="$2"

    if [ -z "$partition" ] || [ -z "$label" ]; then
        echo "Usage: kenl-format-ext4 <partition> <label>"
        echo "Example: kenl-format-ext4 sdb2 Claude-AI-Data"
        return 1
    fi

    if [ ! -b "/dev/$partition" ]; then
        echo "❌ ERROR: /dev/$partition not found"
        return 1
    fi

    echo "⚠️  WARNING: This will FORMAT /dev/$partition"
    echo "   All data will be DESTROYED"
    read -p "Type 'FORMAT $partition' to confirm: " confirm

    if [ "$confirm" != "FORMAT $partition" ]; then
        echo "❌ Aborted"
        return 1
    fi

    echo "Formatting /dev/$partition as ext4..."
    sudo mkfs.ext4 -L "$label" "/dev/$partition"

    if [ $? -eq 0 ]; then
        echo "✓ Formatted successfully"
        lsblk -o NAME,SIZE,FSTYPE,LABEL "/dev/$partition"
    else
        echo "❌ Format failed"
        return 1
    fi
}

kenl-mount-check() {
    # Check if KENL partitions are mounted
    echo "=== KENL Partition Mounts ==="
    df -h | grep -E "(games-universal|claude-ai|development|windows-only|transfer)"
}

kenl-fstab-edit() {
    # Safely edit /etc/fstab
    if [ "$KENL_WSL2" -eq 1 ]; then
        echo "❌ BLOCKED: Do not edit /etc/fstab in WSL2"
        return 1
    fi

    echo "Opening /etc/fstab for editing..."
    echo "⚠️  Make sure you have UUIDs from: blkid /dev/sdb*"

    sudo nano /etc/fstab
}

kenl-get-uuids() {
    # Get partition UUIDs for /etc/fstab
    local disk="${1:-sdb}"

    echo "=== Partition UUIDs for /dev/$disk ==="
    sudo blkid /dev/${disk}* | grep -v "TYPE=\"ext4_case\"" || true

    echo ""
    echo "💾 Saving to ~/partition-uuids.txt"
    sudo blkid /dev/${disk}* > ~/partition-uuids.txt
    chmod 644 ~/partition-uuids.txt

    echo "✓ Saved. Use these UUIDs in /etc/fstab"
}

kenl-mount-all() {
    # Mount all KENL partitions
    if [ "$KENL_WSL2" -eq 1 ]; then
        echo "❌ BLOCKED: Do not mount from WSL2"
        return 1
    fi

    echo "Mounting all partitions from /etc/fstab..."
    sudo mount -a

    if [ $? -eq 0 ]; then
        echo "✓ Mount completed"
        kenl-mount-check
    else
        echo "❌ Mount failed - check /etc/fstab syntax"
        return 1
    fi
}

kenl-steam-setup() {
    # Create Steam library directory
    local games_mount="/mnt/games-universal"

    if [ ! -d "$games_mount" ]; then
        echo "❌ ERROR: $games_mount not mounted"
        echo "   Run: kenl-mount-all"
        return 1
    fi

    echo "Creating Steam library directory..."
    mkdir -p "$games_mount/SteamLibrary"

    echo "✓ Created: $games_mount/SteamLibrary"
    echo ""
    echo "Next steps:"
    echo "1. Open Steam"
    echo "2. Settings → Storage → Add Drive"
    echo "3. Select: $games_mount/SteamLibrary"
}

# ============================================
# Aliases
# ============================================

alias kdisk='kenl-disk'
alias kcheck='kenl-check-external'
alias kformat='kenl-format-ext4'
alias kmount='kenl-mount-check'
alias kuuid='kenl-get-uuids'
alias kfstab='kenl-fstab-edit'
alias kmountall='kenl-mount-all'
alias ksteam='kenl-steam-setup'

# ============================================
# Safety Warnings
# ============================================

if [ "$KENL_WSL2" -eq 1 ]; then
    echo ""
    echo "❌❌❌ WSL2 DETECTED ❌❌❌"
    echo "KENL partition functions are BLOCKED in WSL2"
    echo "Boot native Bazzite-DX Linux to format ext4 partitions"
    echo ""
else
    echo "✓ KENL partition functions loaded (Native Linux)"
fi
```

---

## Bash Profile Usage

### After Adding to Profile

```bash
# Reload profile
source ~/.bashrc

# OR restart terminal
```

### Quick Commands (Native Linux Only)

```bash
# Show all disks
kdisk

# Check external drive
kcheck sdb

# Get UUIDs for /etc/fstab
kuuid sdb

# Format ext4 partitions
kformat sdb2 "Claude-AI-Data"
kformat sdb3 "Development"

# Edit /etc/fstab
kfstab

# Mount all and verify
kmountall
kmount

# Setup Steam library
ksteam
```

---

## WSL2 Limitations & Dangers

### Why NOT to Use WSL2 for This

**❌ BLOCKED OPERATIONS:**

```powershell
# From WSL2 Ubuntu:
$ sudo mkfs.ext4 /dev/sdb2
❌ BLOCKED: Do not format from WSL2

$ sudo mount /dev/sdb2 /mnt/test
❌ BLOCKED: Do not mount from WSL2

$ sudo nano /etc/fstab
❌ BLOCKED: Do not edit /etc/fstab in WSL2
```

**Reasons:**

1. **WSL2 sees Windows disk access differently:**
   - `/dev/sdb` in WSL2 is NOT the same as native Linux `/dev/sdb`
   - WSL2 mounts are temporary and don't survive reboot
   - `/etc/fstab` in WSL2 is isolated from host Windows

2. **Data corruption risk:**
   - WSL2 and Windows can access same partition simultaneously
   - No proper locking mechanism
   - Race conditions lead to filesystem corruption

3. **Incomplete access:**
   - ext4 partitions formatted in WSL2 may not be readable in native Linux
   - Permissions/ownership get mangled
   - Metadata differs between WSL2 and native Linux

### Correct Workflow

```
❌ WRONG:
Windows → WSL2 → Format ext4 → Corrupted partitions

✅ CORRECT:
Windows → PowerShell → Create partitions (STEP1-3) →
Reboot → Native Bazzite-DX Linux → Format ext4 partitions
```

### Detection in Scripts

**PowerShell blocks WSL2 access:**

```powershell
# Profile function detects WSL2
if ($env:WSL_DISTRO_NAME) {
    Write-Host "❌ ERROR: Running in WSL2" -ForegroundColor Red
    Write-Host "   Use native Windows PowerShell" -ForegroundColor Yellow
    exit 1
}
```

**Bash blocks if in WSL2:**

```bash
# Profile checks /proc/version
if grep -qEi "(Microsoft|WSL)" /proc/version; then
    echo "❌ BLOCKED: WSL2 detected"
    return 1
fi
```

---

## Advanced: Test WSL2 Detection

### In PowerShell

```powershell
# Check if running in WSL2
if ($env:WSL_DISTRO_NAME) {
    Write-Host "Running in WSL2: $($env:WSL_DISTRO_NAME)"
} else {
    Write-Host "Running in native Windows"
}
```

### In Bash

```bash
# Check if WSL2
if grep -qEi "(Microsoft|WSL)" /proc/version; then
    echo "Running in WSL2"
    cat /proc/version
else
    echo "Running in native Linux"
fi
```

---

## Troubleshooting Profile Load

### PowerShell Profile Not Loading

```powershell
# Check execution policy
Get-ExecutionPolicy

# If Restricted, set to RemoteSigned
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

# Reload profile
. $PROFILE
```

### Bash Profile Not Loading

```bash
# Check which profile file is sourced
echo $SHELL
# If /bin/bash, uses ~/.bashrc

# Check if profile exists
ls -la ~/.bashrc

# Manually source
source ~/.bashrc

# Add to .bash_profile if needed
echo 'source ~/.bashrc' >> ~/.bash_profile
```

### Functions Not Found

```powershell
# PowerShell: List loaded functions
Get-Command kenl-* | Format-Table Name, Source

# If empty, profile didn't load
. $PROFILE
```

```bash
# Bash: List loaded functions
declare -F | grep kenl

# If empty, profile didn't load
source ~/.bashrc
```

---

## Related Documentation

- `README.md` - Main usage guide
- `WORKFLOW_DIAGRAM.md` - Visual workflow charts
- `USAGE_PRIVACY.md` - Privacy and safety
- `config.example.ps1` - Configuration template

---

**Last Updated:** 2025-11-12
**ATOM:** ATOM-CFG-20251112-006
