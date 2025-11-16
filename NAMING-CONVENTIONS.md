---
title: KENL Naming Conventions
atom: ATOM-DOC-20251116-007
classification: USER-FACING-DOCUMENTATION
status: production
purpose: Canonical naming schema for branches, files, and directories
---

# KENL Naming Conventions

**Purpose:** Consistent, ATOM-integrated naming schema across the repository.

**Scope:** Branches, files, directories, ATOM tags

**Non-Breaking:** All conventions are backwards-compatible with existing scripts/commands.

---

## Branch Naming Schema

### Standard Format

```
{type}/{atom-tag}-{short-description}
```

**Pattern:** `{type}/{ATOM-TYPE-YYYYMMDD-NNN}-{kebab-case-slug}`

**Examples:**
```
docs/ATOM-DOC-20251116-004-table-formatting
feat/ATOM-FEAT-20251116-010-live-dashboard
fix/ATOM-FIX-20251116-012-link-validation
chore/ATOM-CHORE-20251116-015-pre-commit-update
```

### Types (Conventional Commits)

| Type | Purpose | Example Branch |
|------|---------|----------------|
| `feat/` | New features | `feat/ATOM-FEAT-20251116-010-live-dashboard` |
| `fix/` | Bug fixes | `fix/ATOM-FIX-20251116-012-broken-links` |
| `docs/` | Documentation only | `docs/ATOM-DOC-20251116-004-table-guide` |
| `chore/` | Maintenance, tooling | `chore/ATOM-CHORE-20251116-015-pre-commit` |
| `refactor/` | Code refactoring | `refactor/ATOM-REFACTOR-20251116-020-modules` |
| `test/` | Test additions | `test/ATOM-TEST-20251116-025-network-tests` |
| `ci/` | CI/CD changes | `ci/ATOM-CI-20251116-030-github-actions` |

### AI Agent Branches (Special Case)

**For Claude Code sessions:**

```
claude/{type}/{atom-tag}-{description}
```

**Example:**
```
claude/docs/ATOM-DOC-20251116-004-table-formatting
claude/feat/ATOM-FEAT-20251116-010-dashboard
```

**For GitHub Copilot:**
```
copilot/{type}/{atom-tag}-{description}
```

**Legacy format (grandfathered):**
```
claude/{description}-{session-id}
copilot/{description}
```

**Examples (legacy):**
- `claude/add-performance-dashboard-01EXPguiGyWCByxLMp5ujVRV` ✅ (allowed)
- `copilot/setup-copilot-instructions` ✅ (allowed)

**Migration:** Existing branches don't need renaming. New branches SHOULD use new format.

---

## File Naming Schema

### Documentation Files

**Format:** `{CAPS-WITH-DASHES}.md`

**Pattern:** All caps, words separated by dashes, `.md` extension

**Examples:**
```
MARKDOWN-TABLE-FORMATTING.md
AGENT-FACING-CONTENT-DESIGN.md
DASHBOARD-VALUE-PROPOSITION.md
AI-MAINTENANCE-GUIDE.md
```

**ATOM Integration:** ATOM tag in frontmatter ONLY, not filename

```yaml
---
atom: ATOM-DOC-20251116-004
---
```

**Why not in filename:**
- Keeps filenames short and readable
- ATOM tags change (superseded, deprecated), filenames stay stable
- Non-breaking: Scripts reference `CURRENT-STATE.md`, not `CURRENT-STATE-ATOM-DOC-20251115-002.md`

### Script Files

**Bash scripts (.sh):**

```
{kebab-case-action}.sh
```

**Examples:**
```
kenl-dashboard.sh
validate-links.sh
bootstrap.sh
```

**PowerShell scripts (.ps1):**

```
{PascalCase-VerbNoun}.ps1
```

**Examples:**
```
Install-Bazzite.ps1
Test-KenlNetwork.ps1
New-GamingPartition.ps1
```

**ATOM Integration:** In script header comment

```bash
#!/usr/bin/env bash
# ATOM: ATOM-SYS-20251116-001
# Purpose: Live KENL dashboard
```

```powershell
# ATOM: ATOM-CFG-20251112-002
# Purpose: Create gaming partitions
```

### Configuration Files

**YAML:**
```
{kebab-case-purpose}.yaml
```

**Examples:**
```
.sage-manifest.yaml
play-card-example.yaml
amd-ryzen5-5600h-vega-optimal.yaml
```

**JSON:**
```
{kebab-case-purpose}.json
```

**Examples:**
```
package.json
document-registry.json
network-baseline.json
```

---

## Directory Naming Schema

### Top-Level Directories

**Format:** `{kebab-case}` (lowercase, dash-separated)

**Examples:**
```
claude-landing/
case-studies/
governance/
scripts/
modules/
docs/
```

**Special:** `.` prefix for hidden/config directories

```
.github/
.claude/
.private/
```

### Module Directories

**Format:** `KENL{N}-{kebab-case}`

**Pattern:** `KENL` + number (0-13) + dash + lowercase purpose

**Examples:**
```
modules/KENL0-system/
modules/KENL1-framework/
modules/KENL2-gaming/
modules/KENL3-dev/
modules/KENL13-iwi/
```

**Why numbered:**
- Enforces load order (KENL0 loads before KENL2)
- Clear hierarchy (0=system, 1=framework, 2+=features)
- Prevents "where does this go?" ambiguity

### Subdirectories

**Format:** `{kebab-case}` (lowercase, dash-separated)

**Examples:**
```
modules/KENL2-gaming/play-cards/
modules/KENL2-gaming/configs/hardware/
modules/KENL3-dev/guides/
governance/mcp-governance/
governance/02-Decisions/
```

**Special case:** Numbered subdirs for ordering

```
governance/01-Architecture/
governance/02-Decisions/
governance/03-Templates/
```

---

## ATOM Tag Schema

### Format

```
ATOM-{TYPE}-{YYYYMMDD}-{NNN}
```

**Components:**
- `ATOM-` prefix (always)
- `{TYPE}` = Category (uppercase, 3-10 chars)
- `{YYYYMMDD}` = ISO date (year, month, day)
- `{NNN}` = Sequential number (001-999, zero-padded)

**Example:** `ATOM-DOC-20251116-004`

### ATOM Types

| Type | Usage | Example |
|------|-------|---------|
| `ATOM-MCP` | MCP tool invocations | `ATOM-MCP-20251112-001` |
| `ATOM-SAGE` | SAGE methodology execution | `ATOM-SAGE-20251112-002` |
| `ATOM-CFG` | Configuration changes | `ATOM-CFG-20251112-003` |
| `ATOM-DEPLOY` | Production deployments | `ATOM-DEPLOY-20251112-004` |
| `ATOM-TASK` | Task tracking | `ATOM-TASK-20251112-005` |
| `ATOM-RESEARCH` | Research queries | `ATOM-RESEARCH-20251112-006` |
| `ATOM-STATUS` | Status reports | `ATOM-STATUS-20251112-007` |
| `ATOM-DOC` | Documentation updates | `ATOM-DOC-20251116-004` |
| `ATOM-FEAT` | Feature development | `ATOM-FEAT-20251116-010` |
| `ATOM-FIX` | Bug fixes | `ATOM-FIX-20251116-012` |
| `ATOM-SYS` | System operations | `ATOM-SYS-20251116-001` |
| `ATOM-SEC` | Security changes | `ATOM-SEC-20251114-009` |
| `ATOM-GWI` | Gaming with Intent | `ATOM-GWI-20251115-003` |

### ATOM Tag Locations

**Required:**
- Commit messages (footer)
- Document frontmatter (YAML)
- Script headers (comment)

**Optional:**
- Branch names (new convention)
- ARCREF artifacts (governance)
- ADR documents (decisions)

**Examples:**

**Commit message:**
```
feat: add live KENL dashboard

[body]

ATOM-FEAT-20251116-010
```

**Document frontmatter:**
```yaml
---
title: Dashboard Guide
atom: ATOM-DOC-20251116-004
---
```

**Script header:**
```bash
#!/usr/bin/env bash
# ATOM: ATOM-SYS-20251116-001
```

**Branch name:**
```
feat/ATOM-FEAT-20251116-010-live-dashboard
```

---

## Non-Breaking Guarantees

### Scripts and Commands

**File references MUST remain stable:**

```bash
# ✅ GOOD: Reference by stable filename
source ./modules/KENL0-system/powershell/KENL.psm1
./scripts/kenl-dashboard.sh

# ❌ BAD: Reference by ATOM tag (breaks when tag changes)
source ./modules/KENL0-system/powershell/KENL-ATOM-CFG-20251112-001.psm1
```

### Imports and Includes

**Module paths MUST NOT include ATOM tags:**

```python
# ✅ GOOD
from kenl.modules.KENL2_gaming import play_cards

# ❌ BAD
from kenl.modules.KENL2_gaming_ATOM_CFG_20251112_001 import play_cards
```

### URLs and Links

**Documentation links MUST use stable filenames:**

```markdown
<!-- ✅ GOOD -->
See [Dashboard Guide](./scripts/README-DASHBOARD.md)

<!-- ❌ BAD -->
See [Dashboard Guide](./scripts/README-DASHBOARD-ATOM-DOC-20251116-004.md)
```

---

## Validation Rules

### Branch Names

**Valid:**
```bash
feat/ATOM-FEAT-20251116-010-dashboard
docs/ATOM-DOC-20251116-004-tables
claude/feat/ATOM-FEAT-20251116-010-dashboard
```

**Invalid:**
```bash
feature/dashboard  # Missing ATOM tag
feat/dashboard     # Missing ATOM tag
ATOM-FEAT-20251116-010  # Missing type prefix
```

**Validation script (future):**
```bash
#!/bin/bash
# scripts/validate-branch-name.sh

BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [[ "$BRANCH" =~ ^(feat|fix|docs|chore|refactor|test|ci)/ATOM-[A-Z]+-[0-9]{8}-[0-9]{3}-.+ ]]; then
    echo "✅ Valid branch name: $BRANCH"
    exit 0
elif [[ "$BRANCH" =~ ^(claude|copilot)/ ]]; then
    echo "✅ Legacy AI agent branch (grandfathered): $BRANCH"
    exit 0
else
    echo "❌ Invalid branch name: $BRANCH"
    echo "Expected format: {type}/ATOM-{TYPE}-YYYYMMDD-NNN-{description}"
    exit 1
fi
```

### File Names

**Valid:**
```
MARKDOWN-TABLE-FORMATTING.md
kenl-dashboard.sh
Install-Bazzite.ps1
play-card-example.yaml
```

**Invalid:**
```
markdown table formatting.md  # Spaces
Markdown-Table-Formatting.md  # Mixed case in .md
kenl_dashboard.sh             # Underscore (prefer dash)
installBazzite.ps1            # camelCase (should be PascalCase)
```

### Directory Names

**Valid:**
```
claude-landing/
modules/KENL2-gaming/
governance/mcp-governance/
```

**Invalid:**
```
Claude_Landing/        # Underscore
modules/kenl2gaming/   # Missing dash
Governance/            # Capitalized
```

---

## Migration Guide

### Existing Branches

**No action required.** Legacy branch names are grandfathered:

```
claude/add-performance-dashboard-01EXPguiGyWCByxLMp5ujVRV  ✅ OK (legacy)
```

**New branches SHOULD use new format:**

```
feat/ATOM-FEAT-20251116-010-dashboard  ✅ Preferred
```

### Existing Files

**No renaming needed.** Current files already follow conventions:

```
CURRENT-STATE.md           ✅ Correct
AI-MAINTENANCE-GUIDE.md    ✅ Correct
kenl-dashboard.sh          ✅ Correct
```

### Existing Directories

**No changes needed.** Directory structure is stable:

```
modules/KENL0-system/      ✅ Correct
claude-landing/            ✅ Correct
governance/02-Decisions/   ✅ Correct
```

---

## Quick Reference

### Branch Naming Template

```bash
# Create new branch with ATOM tag
ATOM_TAG="ATOM-FEAT-20251116-010"
DESCRIPTION="live-dashboard"
git checkout -b "feat/${ATOM_TAG}-${DESCRIPTION}"
```

### File Creation Template

```bash
# Documentation
touch UPPERCASE-WITH-DASHES.md

# Script (bash)
touch lowercase-with-dashes.sh

# Script (PowerShell)
touch PascalCase-VerbNoun.ps1
```

### ATOM Tag Generation

```bash
# Auto-generate next ATOM tag
LAST_NUM=$(grep -rh "^atom: ATOM-DOC-$(date +%Y%m%d)" . --include="*.md" | \
           grep -oP 'ATOM-DOC-[0-9]{8}-\K[0-9]{3}' | sort -n | tail -1)
NEXT_NUM=$(printf "%03d" $((10#$LAST_NUM + 1)))
ATOM_TAG="ATOM-DOC-$(date +%Y%m%d)-${NEXT_NUM}"
echo "$ATOM_TAG"
```

---

## Examples from KENL Repository

### Branches (Current Session)

**Legacy format (grandfathered):**
```
claude/add-performance-dashboard-01EXPguiGyWCByxLMp5ujVRV
```

**New format (would be):**
```
claude/feat/ATOM-FEAT-20251116-010-performance-dashboard
```

**Benefit:** Branch name contains ATOM tag → Traceability from `git branch -a`

### Files (Already Compliant)

```
✅ claude-landing/MARKDOWN-TABLE-FORMATTING.md
✅ claude-landing/AGENT-FACING-CONTENT-DESIGN.md
✅ scripts/kenl-dashboard.sh
✅ modules/KENL0-system/powershell/Test-KenlNetwork.ps1
```

### Directories (Already Compliant)

```
✅ modules/KENL0-system/
✅ modules/KENL2-gaming/play-cards/
✅ governance/mcp-governance/
✅ claude-landing/
```

---

## Enforcement

### Pre-Commit Hooks (Future)

```yaml
# .pre-commit-config.yaml
- repo: local
  hooks:
    - id: validate-branch-name
      name: Validate branch name format
      entry: ./scripts/validate-branch-name.sh
      language: system
      pass_filenames: false
      stages: [commit]
```

### GitHub Actions (Future)

```yaml
# .github/workflows/validate-naming.yml
name: Validate Naming Conventions

on: [pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Validate branch name
        run: ./scripts/validate-branch-name.sh
```

---

## Integration with Monitoring Systems

### Logdy Server Integration

**Requirement:** Local and remote ATOM trail directories MUST be linked so Logdy parses both to the same web interface.

**Directory Structure:**

```
~/.kenl/logs/                    # Local ATOM trail logs
  ├── atom-trails/               # ATOM trail entries
  │   ├── 2025-11-16/
  │   │   ├── ATOM-DOC-20251116-007.json
  │   │   ├── ATOM-FEAT-20251116-010.json
  │   │   └── ATOM-FIX-20251116-012.json
  │   └── 2025-11-15/
  │       └── ATOM-DOC-20251115-003.json
  └── network-health/            # Network metrics (from Test-KenlNetwork)
      └── 2025-11-16-baseline.json
```

**Logdy Configuration:**

```bash
# ~/.config/logdy/config.yaml
sources:
  - name: "KENL ATOM Trails"
    path: "/home/user/.kenl/logs/atom-trails/**/*.json"
    format: "json"
    watch: true

  - name: "KENL Network Health"
    path: "/home/user/.kenl/logs/network-health/**/*.json"
    format: "json"
    watch: true

  - name: "Remote ATOM Trails"
    path: "/mnt/remote-kenl/.kenl/logs/atom-trails/**/*.json"
    format: "json"
    watch: true
```

**Link Remote Logs (via SSH mount or symlink):**

```bash
# Option 1: SSHFS mount (if remote system accessible)
sshfs remote-host:/home/user/.kenl/logs /mnt/remote-kenl/.kenl/logs

# Option 2: Symlink (if logs are synced via rsync/git)
ln -s ~/kenl/.kenl/logs/remote ~/.kenl/logs/remote

# Option 3: Shared network mount
mount -t nfs remote-host:/home/user/.kenl/logs /mnt/remote-kenl/.kenl/logs
```

**ATOM Trail Log Format (JSON):**

```json
{
  "timestamp": "2025-11-16T14:32:05Z",
  "atom_tag": "ATOM-DOC-20251116-007",
  "type": "DOC",
  "file": "NAMING-CONVENTIONS.md",
  "intent": "Standardize naming across branches, files, directories",
  "agent": "claude",
  "session": "claude/add-performance-dashboard-01EXPguiGyWCByxLMp5ujVRV",
  "commit": "a230720"
}
```

**Benefits:**
- Logdy watches file directories (no HTTP sync needed)
- Local + remote logs in single Logdy UI
- Real-time tail on ATOM trail changes
- Queryable via Logdy filters (by agent, type, date)
- Offline-capable (logs are files, not API calls)

**Logdy Web Interface View:**

```
╔═══════════════════════════════════════════════════════════╗
║  LOGDY - KENL ATOM Trail Monitor                          ║
╟───────────────────────────────────────────────────────────╢
║  Filter: [All Sources ▼] [Last 24h ▼] [All Types ▼]      ║
╟───────────────────────────────────────────────────────────╢
║  ● 14:32:05  ATOM-DOC-20251116-007  (local/claude)        ║
║    NAMING-CONVENTIONS.md - Standardize naming             ║
║                                                            ║
║  ● 14:15:20  ATOM-DOC-20251116-004  (local/claude)        ║
║    MARKDOWN-TABLE-FORMATTING.md - Table formatting        ║
║                                                            ║
║  ● 14:02:18  ATOM-FEAT-20251116-010 (remote/claude)       ║
║    kenl-dashboard.sh - Live dashboard implementation      ║
╚═══════════════════════════════════════════════════════════╝
```

---

## ATOM Trail

```
ATOM-DOC-20251116-007: Created canonical naming conventions guide
Intent: Standardize naming across branches, files, directories with ATOM integration
Problem: Inconsistent naming, ATOM tags only in frontmatter (not discoverable from git)
Solution: Unified schema with ATOM tags in branch names + Logdy sync for remote sessions
Impact: Improved traceability (branch name → ATOM tag → commits → docs → Logdy)
Validation: All new branches follow {type}/ATOM-{TYPE}-YYYYMMDD-NNN-{slug}
Rollback: N/A (documentation only, backwards-compatible)
Next: Create validate-branch-name.sh, add to pre-commit hooks, implement Logdy sync
```

---

**Last Updated:** 2025-11-16
**Status:** Production
**Classification:** USER-FACING-DOCUMENTATION
**Enforcement:** Recommended (not breaking)
