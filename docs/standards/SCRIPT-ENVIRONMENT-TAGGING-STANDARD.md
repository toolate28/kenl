---
title: KENL Script Environment Tagging Standard
date: 2025-11-17
atom: ATOM-DOC-20251117-002
classification: STANDARD
status: production
---

# KENL Script Environment Tagging Standard

**Purpose:** Prevent users from running scripts in incompatible environments by using clear tagging and directory structure

**Problem:** Shell scripts fail when run in wrong environment:
- Bash scripts written for Linux fail in Git Bash (Windows)
- WSL2-specific scripts fail in native Linux
- PowerShell scripts can't run in bash at all

**Solution:** Environment tags in script headers + directory structure that reads left-to-right for clarity

---

## Script Header Tagging Convention

### Bash Scripts (.sh)

**Template:**

```bash
#!/usr/bin/env bash
#
# Script Name: script-name.sh
# Description: What this script does
# Environment: [TAG] (see tags below)
# Platform: [linux|windows|macos|universal]
# ATOM: ATOM-TYPE-YYYYMMDD-NNN
#
# Safe Environments:
#   ✅ Native Linux (Fedora, Ubuntu, Bazzite)
#   ❌ WSL2 Ubuntu (missing kernel features)
#   ❌ Git Bash (Windows) (POSIX incompatibility)
#
# Dependencies: package1, package2
# Tested On: Bazzite-DX KDE 43.20251117
#

# Environment detection (auto-fail if incompatible)
if [[ ! -f /etc/os-release ]]; then
    echo "❌ Error: This script requires native Linux" >&2
    echo "   Current environment: $(uname -s)" >&2
    exit 1
fi
```

### Environment Tags

| Tag | Meaning | Where It Runs | Examples |
|-----|---------|---------------|----------|
| `[LINUX-NATIVE]` | Requires native Linux kernel | ✅ Bazzite, Fedora, Ubuntu<br>❌ WSL2<br>❌ Git Bash | `STEP2-LINUX-PARTITION-DISK.sh` |
| `[WSL2-SAFE]` | Works in WSL2 or native Linux | ✅ WSL2<br>✅ Native Linux<br>❌ Git Bash | Most utility scripts |
| `[GITBASH-SAFE]` | Works in Git Bash (limited POSIX) | ✅ Git Bash<br>✅ WSL2<br>✅ Native Linux | Simple scripts with no kernel deps |
| `[BAZZITE-ONLY]` | Requires Bazzite-specific tools | ✅ Bazzite only (ujust, rpm-ostree)<br>❌ Other Linux | `bazzite-metrics.sh` |
| `[UNIVERSAL]` | Pure POSIX, runs anywhere | ✅ All bash environments | `validate-links.sh` |

### PowerShell Scripts (.ps1)

**Template:**

```powershell
<#
.SYNOPSIS
    What this script does

.DESCRIPTION
    Longer description

.ENVIRONMENT
    [WINDOWS-POWERSHELL] or [PWSH-CROSS-PLATFORM]

.PLATFORM
    Windows 10/11, PowerShell 5.1+

.SAFE_ENVIRONMENTS
    ✅ Windows PowerShell 5.1+
    ✅ PowerShell 7+ (pwsh)
    ❌ WSL2 bash
    ❌ Git Bash

.DEPENDENCIES
    - Module: KENL.Network
    - Elevation: Required/Optional

.TESTED_ON
    Windows 11 23H2, PowerShell 5.1.22621

.ATOM
    ATOM-TYPE-YYYYMMDD-NNN
#>

#Requires -Version 5.1

# Environment detection
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Error "This script requires PowerShell 5.1 or higher"
    exit 1
}

if ($PSVersionTable.Platform -eq 'Unix') {
    Write-Warning "This script is designed for Windows. Running on Unix may cause issues."
}
```

### PowerShell Environment Tags

| Tag | Meaning | Where It Runs |
|-----|---------|---------------|
| `[WINDOWS-POWERSHELL]` | Windows-only (uses Windows APIs) | ✅ Windows PowerShell<br>❌ pwsh on Linux |
| `[PWSH-CROSS-PLATFORM]` | PowerShell Core 7+ (cross-platform) | ✅ Windows<br>✅ Linux<br>✅ macOS |
| `[ADMIN-REQUIRED]` | Needs administrator/root privileges | ✅ Must run elevated |

---

## Directory Structure Convention

**Principle:** Path reads left-to-right, conveying environment/purpose clearly

### Proposed Structure

```
kenl/
└── scripts/
    ├── linux/                          # Native Linux only
    │   ├── bazzite/                    # Bazzite-specific (rpm-ostree, ujust)
    │   │   ├── bazzite-metrics.sh      # [BAZZITE-ONLY]
    │   │   └── update-system.sh        # ujust wrapper
    │   ├── debian/                     # Debian/Ubuntu-specific
    │   └── universal/                  # Works on any Linux
    │       ├── validate-links.sh       # [LINUX-NATIVE] but portable
    │       └── bootstrap.sh
    │
    ├── wsl2/                           # WSL2 Ubuntu/Debian
    │   ├── mount-external-drive.sh     # [WSL2-SAFE]
    │   ├── access-windows-files.sh
    │   └── README.md                   # WSL2-specific notes
    │
    ├── windows/                        # Windows-only scripts
    │   ├── powershell/                 # PowerShell scripts
    │   │   ├── Install-Bazzite.ps1     # [WINDOWS-POWERSHELL]
    │   │   ├── Test-Network.ps1
    │   │   └── admin/                  # Requires elevation
    │   │       ├── Set-MTU.ps1
    │   │       └── Optimize-Network.ps1
    │   └── batch/                      # .bat files (legacy)
    │       └── launch-steam.bat
    │
    ├── cross-platform/                 # Works on Linux + Windows
    │   ├── pwsh/                       # PowerShell Core 7+
    │   │   └── Get-SystemInfo.ps1      # [PWSH-CROSS-PLATFORM]
    │   └── posix/                      # POSIX shell (sh, not bash)
    │       └── check-deps.sh           # [UNIVERSAL]
    │
    ├── gitbash/                        # Git Bash (Windows) compatible
    │   ├── simple-utils.sh             # [GITBASH-SAFE]
    │   └── README.md                   # Limitations of Git Bash
    │
    ├── archived/                       # Old/deprecated scripts
    │   └── YYYY-MM-DD/
    │       ├── old-script-v1.sh
    │       └── ARCHIVED-REASON.md
    │
    └── README.md                       # Scripts directory index
```

### Path Readability Examples

**Good (clear environment from path):**
```
./kenl/scripts/linux/bazzite/bazzite-metrics.sh
                └─Linux─┘ └Bazzite┘
                  Clear: This runs on Bazzite Linux only

./kenl/scripts/windows/powershell/admin/Set-MTU.ps1
                └Windows┘ └PowerShell┘ └Admin┘
                  Clear: Windows PowerShell, needs elevation

./kenl/scripts/cross-platform/pwsh/Get-SystemInfo.ps1
                └Cross-platform────┘ └pwsh┘
                  Clear: Works on Windows + Linux (PowerShell 7+)
```

**Bad (ambiguous):**
```
./kenl/scripts/set-mtu.sh
                ❓ What environment? Linux? WSL2? Git Bash?

./kenl/scripts/install.ps1
                ❓ Windows only? Cross-platform? Admin required?
```

---

## Environment Detection Functions

### Bash: Detect Environment

**File:** `scripts/lib/env-detect.sh`

```bash
#!/usr/bin/env bash
# Environment Detection Library
# Source this in scripts: source "$(dirname "$0")/../lib/env-detect.sh"

# Colors
RED="\033[0;31m"
YELLOW="\033[1;33m"
GREEN="\033[0;32m"
RESET="\033[0m"

# Detect current environment
detect_environment() {
    # Check if WSL
    if grep -qEi "(Microsoft|WSL)" /proc/version 2>/dev/null; then
        echo "WSL2"
        return
    fi

    # Check if Git Bash (Windows)
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        echo "GITBASH"
        return
    fi

    # Check if macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "MACOS"
        return
    fi

    # Check if native Linux
    if [[ -f /etc/os-release ]]; then
        # Check for Bazzite
        if grep -qi "bazzite" /etc/os-release; then
            echo "BAZZITE"
            return
        fi

        # Check for Fedora
        if grep -qi "fedora" /etc/os-release; then
            echo "FEDORA"
            return
        fi

        # Check for Ubuntu
        if grep -qi "ubuntu" /etc/os-release; then
            echo "UBUNTU"
            return
        fi

        # Generic Linux
        echo "LINUX"
        return
    fi

    # Unknown
    echo "UNKNOWN"
}

# Require specific environment
require_environment() {
    local required="$1"
    local current=$(detect_environment)

    case "$required" in
        LINUX-NATIVE)
            if [[ ! "$current" =~ ^(LINUX|BAZZITE|FEDORA|UBUNTU)$ ]]; then
                echo -e "${RED}❌ Error: This script requires native Linux${RESET}" >&2
                echo -e "   Current environment: $current" >&2
                echo -e "   Cannot run in WSL2 or Git Bash" >&2
                exit 1
            fi
            ;;

        WSL2-SAFE)
            if [[ ! "$current" =~ ^(WSL2|LINUX|BAZZITE|FEDORA|UBUNTU)$ ]]; then
                echo -e "${RED}❌ Error: This script requires WSL2 or native Linux${RESET}" >&2
                echo -e "   Current environment: $current" >&2
                exit 1
            fi
            ;;

        BAZZITE-ONLY)
            if [[ "$current" != "BAZZITE" ]]; then
                echo -e "${RED}❌ Error: This script requires Bazzite${RESET}" >&2
                echo -e "   Current environment: $current" >&2
                echo -e "   Install Bazzite or use Bazzite-specific container" >&2
                exit 1
            fi
            ;;

        GITBASH-SAFE)
            # Git Bash, WSL2, and native Linux all OK
            if [[ "$current" == "UNKNOWN" ]]; then
                echo -e "${YELLOW}⚠️  Warning: Unknown environment, may not work${RESET}" >&2
            fi
            ;;

        UNIVERSAL)
            # Any POSIX shell environment
            ;;

        *)
            echo -e "${RED}❌ Error: Invalid environment requirement: $required${RESET}" >&2
            exit 1
            ;;
    esac

    echo -e "${GREEN}✅ Environment check passed: $current${RESET}"
}

# Export functions
export -f detect_environment
export -f require_environment
```

**Usage in scripts:**

```bash
#!/usr/bin/env bash
# Environment: [BAZZITE-ONLY]

# Source environment detector
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/env-detect.sh"

# Require Bazzite
require_environment "BAZZITE-ONLY"

# Script continues only if on Bazzite
echo "Running on Bazzite, proceeding..."
```

---

### PowerShell: Detect Environment

**File:** `scripts/lib/Env-Detect.psm1`

```powershell
#Requires -Version 5.1

<#
.SYNOPSIS
    Environment Detection Module for PowerShell

.DESCRIPTION
    Detects whether running on Windows, Linux, macOS, and checks
    for administrator/root privileges.
#>

function Get-KenlEnvironment {
    <#
    .SYNOPSIS
        Detects current PowerShell environment
    #>
    [CmdletBinding()]
    param()

    $env = [PSCustomObject]@{
        Platform = $null
        OS = $null
        IsAdmin = $false
        PSVersion = $PSVersionTable.PSVersion.ToString()
        IsCore = $PSVersionTable.PSEdition -eq 'Core'
    }

    # Detect platform
    if ($IsWindows -or $PSVersionTable.Platform -eq 'Win32NT' -or $env:OS -eq 'Windows_NT') {
        $env.Platform = 'Windows'
        $env.OS = (Get-CimInstance Win32_OperatingSystem).Caption
        $env.IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    elseif ($IsLinux -or $PSVersionTable.Platform -eq 'Unix') {
        $env.Platform = 'Linux'
        if (Test-Path /etc/os-release) {
            $env.OS = (Get-Content /etc/os-release | Select-String '^PRETTY_NAME=' | ForEach-Object { $_ -replace 'PRETTY_NAME=|"', '' })
        }
        $env.IsAdmin = (id -u) -eq 0
    }
    elseif ($IsMacOS) {
        $env.Platform = 'macOS'
        $env.OS = sw_vers -productVersion
        $env.IsAdmin = (id -u) -eq 0
    }
    else {
        $env.Platform = 'Unknown'
    }

    return $env
}

function Assert-KenlEnvironment {
    <#
    .SYNOPSIS
        Requires specific environment or exits

    .PARAMETER RequiredPlatform
        Required platform (Windows, Linux, macOS)

    .PARAMETER RequireAdmin
        Requires administrator/root privileges
    #>
    [CmdletBinding()]
    param(
        [ValidateSet('Windows', 'Linux', 'macOS', 'Any')]
        [string]$RequiredPlatform = 'Any',

        [switch]$RequireAdmin
    )

    $env = Get-KenlEnvironment

    # Check platform
    if ($RequiredPlatform -ne 'Any' -and $env.Platform -ne $RequiredPlatform) {
        Write-Error "❌ This script requires $RequiredPlatform"
        Write-Host "   Current platform: $($env.Platform)" -ForegroundColor Red
        exit 1
    }

    # Check admin
    if ($RequireAdmin -and -not $env.IsAdmin) {
        Write-Error "❌ This script requires administrator/root privileges"
        Write-Host "   Run PowerShell as Administrator" -ForegroundColor Yellow
        exit 1
    }

    Write-Host "✅ Environment check passed: $($env.Platform), Admin: $($env.IsAdmin)" -ForegroundColor Green
}

Export-ModuleMember -Function Get-KenlEnvironment, Assert-KenlEnvironment
```

**Usage in PowerShell scripts:**

```powershell
#Requires -Version 5.1

<#
.ENVIRONMENT
    [WINDOWS-POWERSHELL]
    [ADMIN-REQUIRED]
#>

# Import environment detector
Import-Module "$PSScriptRoot\..\lib\Env-Detect.psm1" -Force

# Require Windows + Admin
Assert-KenlEnvironment -RequiredPlatform Windows -RequireAdmin

# Script continues only if on Windows with admin privileges
Write-Host "Running on Windows with admin rights, proceeding..."
```

---

## Migration Plan for Existing Scripts

### Phase 1: Tag Existing Scripts (Immediate)

Add environment tags to headers of all existing scripts:

**Audit List:**

```bash
# To be tagged:
scripts/
├── add-owi-metadata.sh              → [WSL2-SAFE]
├── bootstrap.sh                     → [UNIVERSAL]
├── DOWNLOAD-BAZZITE-ISO.ps1         → [WINDOWS-POWERSHELL] → ARCHIVE (superseded)
├── generate-manifests.sh            → [WSL2-SAFE]
├── Install-Bazzite.ps1              → [WINDOWS-POWERSHELL]
├── kenl-dashboard.sh                → [LINUX-NATIVE] (uses /proc, /sys)
├── New-GamingPartition.sh           → [LINUX-NATIVE] (parted, mkfs)
├── owi-report.sh                    → [WSL2-SAFE]
├── parallel-work-guard.ps1          → [PWSH-CROSS-PLATFORM]
├── STEP1-WINDOWS-WIPE-DISK1.ps1     → [WINDOWS-POWERSHELL] [ADMIN-REQUIRED]
├── STEP2-LINUX-PARTITION-DISK.sh    → [LINUX-NATIVE]
├── STEP2-WINDOWS-PARTITION-DISK1.ps1 → [WINDOWS-POWERSHELL] [ADMIN-REQUIRED]
├── STEP2-WINDOWS-PARTITION-DISK1-FIXED.ps1 → ARCHIVE (old version)
├── STEP2-WSL2-PARTITION-DISK.sh     → [WSL2-SAFE]
├── STEP3-WINDOWS-MOUNT-CHECK.ps1    → [WINDOWS-POWERSHELL]
└── validate-links.sh                → [UNIVERSAL]
```

### Phase 2: Reorganize Directory Structure (Next Week)

Move scripts to new structure:

```bash
# Example migrations:
mv scripts/kenl-dashboard.sh scripts/linux/universal/kenl-dashboard.sh
mv scripts/Install-Bazzite.ps1 scripts/windows/powershell/Install-Bazzite.ps1
mv scripts/STEP2-WSL2-PARTITION-DISK.sh scripts/wsl2/partition-disk.sh

# Create symlinks for backward compatibility
ln -s linux/universal/kenl-dashboard.sh scripts/kenl-dashboard.sh
```

### Phase 3: Create Environment Detection Library (This Week)

```bash
# Create library files
touch scripts/lib/env-detect.sh
touch scripts/lib/Env-Detect.psm1

# Update scripts to use library
# (via GitHub Copilot task)
```

### Phase 4: Archive Old Scripts (Immediate)

```bash
# Create archive
mkdir -p scripts/archived/2025-11-17

# Move duplicates
mv scripts/DOWNLOAD-BAZZITE-ISO.ps1 scripts/archived/2025-11-17/
mv scripts/STEP2-WINDOWS-PARTITION-DISK1-FIXED.ps1 scripts/archived/2025-11-17/

# Document why archived
cat > scripts/archived/2025-11-17/ARCHIVED-REASON.md << 'EOF'
# Scripts Archived: 2025-11-17

## DOWNLOAD-BAZZITE-ISO.ps1
- **Reason:** Superseded by Install-Bazzite.ps1
- **Replacement:** Use scripts/windows/powershell/Install-Bazzite.ps1
- **ATOM:** ATOM-ARCHIVE-20251117-001

## STEP2-WINDOWS-PARTITION-DISK1-FIXED.ps1
- **Reason:** Old version, bug fixes merged into STEP2-WINDOWS-PARTITION-DISK1.ps1
- **Replacement:** Use STEP2-WINDOWS-PARTITION-DISK1.ps1
- **ATOM:** ATOM-ARCHIVE-20251117-002
EOF
```

---

## Script Header Templates

### Complete Bash Template

```bash
#!/usr/bin/env bash
#
# ╔═══════════════════════════════════════════════════════════╗
# ║  Script Name: example-script.sh                           ║
# ║  Description: What this script does                       ║
# ║  Environment: [WSL2-SAFE]                                 ║
# ║  Platform: Linux (Ubuntu, Fedora, Bazzite)                ║
# ║  ATOM: ATOM-TYPE-YYYYMMDD-NNN                             ║
# ╚═══════════════════════════════════════════════════════════╝
#
# Safe Environments:
#   ✅ WSL2 Ubuntu/Debian
#   ✅ Native Linux (Fedora, Bazzite, Ubuntu)
#   ❌ Git Bash (Windows) - requires native Linux filesystem
#
# Dependencies:
#   - jq (JSON parser)
#   - curl (HTTP client)
#
# Tested On:
#   - Bazzite-DX KDE 43.20251117
#   - WSL2 Ubuntu 24.04
#
# Usage:
#   ./example-script.sh [options]
#
# Examples:
#   ./example-script.sh --verbose
#

set -euo pipefail  # Exit on error, undefined variables, pipe failures

# Source environment detector
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/env-detect.sh"

# Require WSL2 or native Linux
require_environment "WSL2-SAFE"

# Script logic here
echo "Environment check passed, proceeding..."
```

### Complete PowerShell Template

```powershell
<#
.SYNOPSIS
    Example PowerShell Script

.DESCRIPTION
    Longer description of what this script does

.PARAMETER Param1
    Description of Param1

.ENVIRONMENT
    [WINDOWS-POWERSHELL]
    [ADMIN-REQUIRED]

.PLATFORM
    Windows 10/11, PowerShell 5.1+

.SAFE_ENVIRONMENTS
    ✅ Windows PowerShell 5.1+
    ✅ PowerShell 7+ (Windows)
    ❌ PowerShell 7 (Linux/macOS) - uses Windows APIs
    ❌ WSL2 bash
    ❌ Git Bash

.DEPENDENCIES
    - Module: KENL.Network
    - Elevation: Required

.TESTED_ON
    Windows 11 23H2, PowerShell 5.1.22621

.ATOM
    ATOM-TYPE-YYYYMMDD-NNN

.EXAMPLE
    .\Example-Script.ps1 -Param1 "value"

.NOTES
    Author: KENL Framework
    Version: 1.0.0
#>

#Requires -Version 5.1
#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Param1
)

# Import environment detector
Import-Module "$PSScriptRoot\..\lib\Env-Detect.psm1" -Force

# Require Windows + Admin
Assert-KenlEnvironment -RequiredPlatform Windows -RequireAdmin

# Script logic here
Write-Host "✅ Environment check passed, proceeding..." -ForegroundColor Green
```

---

## Quick Reference Guide

### For Script Authors

**When creating a new script:**

1. Choose appropriate directory:
   - Linux-only? → `scripts/linux/`
   - Windows PowerShell? → `scripts/windows/powershell/`
   - Cross-platform pwsh? → `scripts/cross-platform/pwsh/`
   - WSL2-specific? → `scripts/wsl2/`

2. Add environment tag to header:
   - `[LINUX-NATIVE]`, `[WSL2-SAFE]`, `[WINDOWS-POWERSHELL]`, etc.

3. Use environment detector:
   ```bash
   source "$SCRIPT_DIR/../lib/env-detect.sh"
   require_environment "WSL2-SAFE"
   ```

4. Document in header:
   - Safe environments (✅/❌ list)
   - Dependencies
   - Tested on

### For Script Users

**Before running a script:**

1. Check path for environment clues:
   ```
   ./kenl/scripts/linux/bazzite/script.sh → Needs Bazzite
   ./kenl/scripts/windows/powershell/script.ps1 → Windows only
   ```

2. Read script header:
   ```bash
   head -20 script.sh | grep -E "Environment:|Safe Environments:"
   ```

3. If environment mismatch, script will auto-fail with clear error

---

## SAIF Flags

| Operation | SAIF Flag |
|-----------|-----------|
| Create environment tagging standard | `SAIF-ENV-TAG-STANDARD-20251117-043` |
| Implement env-detect.sh library | `SAIF-ENV-DETECT-LIB-20251117-044` |
| Reorganize scripts directory | `SAIF-SCRIPTS-REORG-20251117-045` |
| Archive duplicate scripts | `SAIF-ARCHIVE-DUPES-20251117-046` |

---

## References

- **Visual Elements Standard:** `VISUAL-ELEMENTS-STANDARD.md` (color codes, formatting)
- **SAIF Pattern Analysis:** `SAIF-PATTERN-ANALYSIS.md` (command→flag semantics)
- **Installation Walkthrough:** `BAZZITE-DX-IWI-INSTALLATION-SAIF.md` (environment examples)

---

**ATOM:** ATOM-DOC-20251117-002
**Status:** Production
**Next:** Implement Phase 1 (Tag Existing Scripts) via GitHub Copilot
