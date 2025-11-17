---
title: GitHub Copilot Agent Briefing - Bazzite-DX Installation Tasks
date: 2025-11-17
classification: AGENT-FACING
audience: GitHub Copilot, Coding Agents, VS Code AI
---

# GitHub Copilot Agent Briefing
## Bazzite-DX Post-Installation Coding Tasks

**Context:** Bazzite-DX installation walkthrough created. These tasks require script development and can be handled by coding agents.

---

## Quick Context

**Hardware:**
- AMD Ryzen 5 5600H (6C/12T) + Radeon Vega Graphics
- 16GB RAM
- 512GB NVMe (Windows 11 + Bazzite-DX dual-boot)
- 2TB External HDD (5-partition hybrid layout)

**External Drive Layout:**
1. `/dev/sdb1` - Games-Universal (900GB, NTFS) - Steam library
2. `/dev/sdb2` - Claude-AI-Data (500GB, ext4) - LLM models, datasets
3. `/dev/sdb3` - Development (200GB, ext4) - Distrobox, venvs
4. `/dev/sdb4` - Windows-Only (150GB, NTFS) - BF6, anti-cheat games
5. `/dev/sdb5` - Transfer (50GB, exFAT) - File exchange

**Mount Points (Linux):**
- `/mnt/games-universal`
- `/mnt/claude-ai`
- `/mnt/development`
- `/mnt/windows-only`
- `/mnt/transfer`

**ATOM Framework:**
- Trail log: `~/.config/bazza-dx/atom_trail.log`
- Counter: `~/.config/bazza-dx/atom_counter`
- Function: `generate_atom_tag <TYPE> <description>`

---

## Task 1: External Drive Validation Script

**File:** `modules/KENL0-system/scripts/validate-external-drive.sh`

**Requirements:**
```bash
#!/usr/bin/env bash
# Validate external drive partition layout and filesystems
# ATOM: ATOM-VALIDATE-20251117-001

# Check:
# 1. All 5 partitions exist
# 2. Correct filesystem types (ntfs, ext4, exfat)
# 3. Partitions are mounted
# 4. Write permissions correct
# 5. Generate report with ATOM tag

# Expected output:
# ✅ sdb1: ntfs, mounted at /mnt/games-universal, writable
# ✅ sdb2: ext4, mounted at /mnt/claude-ai, writable
# ... etc

# Exit codes:
# 0 = All validations passed
# 1 = Validation failed
```

**SAIF Flag:** `SAIF-VALIDATE-FS-SCRIPT-20251117-038`

---

## Task 2: Steam Library Auto-Configuration Script

**File:** `modules/KENL2-gaming/scripts/sync-steam-library.sh`

**Requirements:**
```bash
#!/usr/bin/env bash
# Auto-configure Steam library folder on /mnt/games-universal
# ATOM: ATOM-STEAM-20251117-002

# Actions:
# 1. Check if /mnt/games-universal is mounted
# 2. Create SteamLibrary directory if missing
# 3. Detect existing Steam installation (Flatpak or native)
# 4. Create libraryfolders.vdf if needed
# 5. Add /mnt/games-universal/SteamLibrary to Steam library paths
# 6. Log to ATOM trail

# Steam library config location (Flatpak):
# ~/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/libraryfolders.vdf
```

**SAIF Flag:** `SAIF-STEAM-SYNC-20251117-039`

---

## Task 3: ATOM Trail Web Viewer

**Files:**
- `modules/KENL1-framework/atom-viewer/index.html`
- `modules/KENL1-framework/atom-viewer/viewer.js`
- `modules/KENL1-framework/atom-viewer/style.css`

**Requirements:**

**index.html:**
```html
<!DOCTYPE html>
<html>
<head>
    <title>KENL ATOM Trail Viewer</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <h1>KENL ATOM Trail Viewer</h1>

    <div class="controls">
        <input type="file" id="fileInput" accept=".log">
        <input type="text" id="searchBox" placeholder="Search...">
        <select id="typeFilter">
            <option value="">All Types</option>
            <option value="CFG">CFG</option>
            <option value="DEPLOY">DEPLOY</option>
            <option value="TASK">TASK</option>
            <option value="IWI">IWI</option>
        </select>
    </div>

    <div id="trailView"></div>

    <script src="viewer.js"></script>
</body>
</html>
```

**viewer.js:**
```javascript
// Parse ATOM trail log format:
// 2025-11-17T14:32:05+11:00 | ATOM-CFG-20251117-001 | Description

// Features:
// 1. Load trail log file
// 2. Parse timestamp, ATOM tag, description
// 3. Filter by type (CFG, DEPLOY, TASK, etc.)
// 4. Search by keyword
// 5. Display in table with color-coding by type
// 6. Export filtered results to JSON

// Color scheme:
// - CFG: blue
// - DEPLOY: green
// - TASK: yellow
// - IWI: purple
```

**SAIF Flag:** `SAIF-ATOM-VIEWER-20251117-040`

---

## Task 4: Logdy Integration Script

**File:** `modules/KENL4-monitoring/scripts/start-logdy-atom-monitor.sh`

**Requirements:**
```bash
#!/usr/bin/env bash
# Start Logdy server and feed ATOM trail logs
# ATOM: ATOM-LOGDY-20251117-003

# Actions:
# 1. Check if Logdy is installed (~/.local/bin/logdy.exe or logdy)
# 2. Start Logdy server on port 8080
# 3. Tail ATOM trail log and pipe to Logdy
# 4. Generate SAIF flag: SAIF-LOGDY-START-20251117-042

# Usage:
# ./start-logdy-atom-monitor.sh &

# Expected SAIF flag on success:
# SAIF-LOGDY-START-20251117-042: Logdy server started, monitoring ATOM trail
```

**SAIF Flag:** `SAIF-LOGDY-START-20251117-042`

---

## Task 5: Bazzite Dashboard Integration

**File:** `modules/KENL4-monitoring/bazzite-metrics.sh`

**Requirements:**
```bash
#!/usr/bin/env bash
# Bazzite-specific metrics for KENL dashboard
# ATOM: ATOM-DASHBOARD-20251117-004

# Metrics to collect:
# 1. rpm-ostree status (deployment, version)
# 2. External drive status (all 5 partitions)
# 3. AMD CPU frequency (current/max)
# 4. AMD GPU temp and usage
# 5. Steam library size (/mnt/games-universal)
# 6. ATOM trail entry count

# Output format: JSON
# {
#   "deployment": "bazzite-dx:stable",
#   "version": "43.20251117",
#   "external_drive": {
#     "games": { "mounted": true, "used": "45GB", "free": "855GB" },
#     ...
#   },
#   "cpu_freq": "4.2GHz",
#   "gpu_temp": "65C",
#   "atom_entries": 42
# }
```

**Integration:** Merge with `scripts/kenl-dashboard.sh`

**SAIF Flag:** `SAIF-DASHBOARD-INTEGRATION-20251117-037`

---

## Code Style Guidelines

**Bash Scripts:**
```bash
#!/usr/bin/env bash
# Script description
# ATOM: ATOM-TYPE-YYYYMMDD-NNN

set -euo pipefail  # Exit on error, undefined variables, pipe failures

# Color codes (from VISUAL-ELEMENTS-STANDARD.md)
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

# Always include error handling
error_exit() {
    echo -e "${RED}❌ Error: $1${RESET}" >&2
    exit 1
}

# Always log to ATOM trail if framework available
if command -v generate_atom_tag &>/dev/null; then
    generate_atom_tag TASK "Script executed: $(basename $0)"
fi
```

**SAIF Flag Generation:**
```bash
# Generate SAIF flag on success
SAIF_FLAG="SAIF-$(echo ${SCRIPT_NAME} | tr '[:lower:]' '[:upper:]')-$(date +%Y%m%d)-NNN"
echo "✅ $SAIF_FLAG: Operation completed successfully"
```

---

## Testing Requirements

All scripts must:
- [ ] Run without errors on Bazzite-DX KDE
- [ ] Handle missing dependencies gracefully
- [ ] Generate ATOM tags for all operations
- [ ] Include SAIF flags for major milestones
- [ ] Have usage examples in comments
- [ ] Exit with proper exit codes (0=success, 1=failure)

---

## References

**Installation Docs:**
- `BAZZITE-DX-IWI-INSTALLATION-SAIF.md` (full walkthrough)
- `modules/KENL13-iwi/README.md` (Installing With Intent spec)

**Partition Layout:**
- `modules/KENL2-gaming/guides/1.8TB_EXTERNAL_DRIVE_LAYOUT.md`

**Visual Standards:**
- `VISUAL-ELEMENTS-STANDARD.md` (colors, emojis, formatting)

**SAIF Pattern:**
- `SAIF-PATTERN-ANALYSIS.md` (command→flag semantics)

---

## Acceptance Criteria

Scripts are ready for merge when:
1. All shellcheck warnings resolved
2. Tested on Bazzite-DX (or documented as untested)
3. ATOM integration working
4. SAIF flags documented
5. README with usage examples

---

**Agent:** GitHub Copilot / VS Code AI
**Target Branch:** `copilot/post-install-scripts`
**PR Title:** "feat: Bazzite-DX post-installation automation scripts"
**Estimated Complexity:** Medium (5 scripts, ~500 lines total)
