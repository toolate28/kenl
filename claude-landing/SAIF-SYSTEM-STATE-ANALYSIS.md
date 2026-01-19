---
title: SAIF System State Analysis - KENL-13 i-W-i First Real Test
date: 2025-12-05
classification: SAIF-WORKFLOW
atom: ATOM-SAIF-20251205-001
owi-version: 1.0.0
saif-version: 1.0.0
status: in-progress
environment: Bazzite (rpm-ostree/immutable) + Debian distrobox
hardware: AMD Ryzen 5 5600H + Radeon Vega iGPU
---

# SAIF System State Analysis
## KENL-13 i-W-i (Installer With Intelligence) - First Real System Test

**Purpose:** Match current system state to desired state using SAIF workflow principles

**Context:**
- Host System: Bazzite (Fedora immutable, rpm-ostree)
- Current Environment: Debian distrobox container
- Hardware: AMD Ryzen 5 5600H + Radeon Vega iGPU, 16GB RAM
- Status: PRE-REBASE (as of Nov 2025 docs)

---

## Table of Contents

1. [System State Matrix](#system-state-matrix)
2. [SAIF Workflow Phases](#saif-workflow-phases)
3. [API/OAuth Credential Collection](#apioauth-credential-collection)
4. [MCP Server Configuration](#mcp-server-configuration)
5. [Distrobox Configuration](#distrobox-configuration)
6. [Gaming Stack Configuration](#gaming-stack-configuration)
7. [Dashboard & Monitoring](#dashboard--monitoring)
8. [System Playcard Update](#system-playcard-update)
9. [ATOM Trail](#atom-trail)

---

## System State Matrix

### Current State Analysis

| Component | Current State | Desired State | Gap | Priority | SAIF Flag |
|-----------|---------------|---------------|-----|----------|-----------|
| **Environment** | Debian distrobox on Bazzite host | Fully configured distrobox with host access | Needs verification | HIGH | `SAIF-ENV-20251205-001` |
| **MCP Servers** | Cloudflare partially cloned | All MCP servers configured with OAuth | Missing credentials | CRITICAL | `SAIF-MCP-20251205-001` |
| **Claude Desktop Config** | Windows paths in Linux config | Linux-native paths | Incompatible config | CRITICAL | `SAIF-CLAUDE-20251205-001` |
| **Host System** | Pre-rebase state, known issues | Updated, issues resolved | beszel/gamemode/RADV_DEBUG errors | HIGH | `SAIF-HOST-20251205-001` |
| **Gaming Stack** | Unknown status | gamescope + mangohud + MangoJuice configured | Needs validation | MEDIUM | `SAIF-GAMING-20251205-001` |
| **Dashboards** | Not enabled | Live dashboards + dynamics | Not configured | MEDIUM | `SAIF-DASH-20251205-001` |
| **Playcard** | AMD hardware spec only | Current rpm-ostree status + distrobox config | Incomplete | LOW | `SAIF-PLAYCARD-20251205-001` |
| **ATOM System** | Counters exist | Full trail with workflow tracking | Needs integration | HIGH | `SAIF-ATOM-20251205-001` |

---

## SAIF Workflow Phases

### Phase 0: Discovery & Baseline
**SAIF Flag:** `SAIF-DISCOVERY-20251205-001`

**Actions:**
1. Detect if we're in distrobox or on host
2. Map host system access from container
3. Inventory installed tools and services
4. Check current rpm-ostree status
5. Document all known issues from system logs

**ATOM Trail:**
```bash
ATOM-DISCOVER-20251205-001: Environment detected (Debian distrobox on Bazzite host)
ATOM-DISCOVER-20251205-002: Host system PRE-REBASE state confirmed
ATOM-DISCOVER-20251205-003: Known issues cataloged (beszel-agent, gamemode, RADV_DEBUG)
```

---

### Phase 1: Credential Collection Workflow
**SAIF Flag:** `SAIF-CREDS-20251205-001`

**Objective:** Gather all API keys and OAuth tokens needed for full system operation

#### 1.1: Cloudflare API Token

**Current Status:** Placeholder in claude_desktop_config.json (`YOUR_API_TOKEN_HERE`)

**Desired State:** Valid Cloudflare API token with proper scopes

**Steps:**
1. Navigate to: https://dash.cloudflare.com/profile/api-tokens
2. Create token with scopes:
   - Account:Read
   - Workers Scripts:Edit
   - Workers KV:Edit
   - Pages:Edit
   - DNS:Edit (if managing DNS)
3. Copy token to secure location
4. Update MCP server configuration

**SAIF Flag:** `SAIF-CF-TOKEN-20251205-001`

**Result:** Cloudflare MCP server can manage Workers/KV/Pages

#### 1.2: GitHub Personal Access Token

**Current Status:** Unknown

**Desired State:** PAT with repo access for KENL repository

**Steps:**
1. Navigate to: https://github.com/settings/tokens
2. Generate new token (classic) with scopes:
   - repo (full control)
   - workflow (if using Actions)
   - read:org (if needed)
3. Copy token to secure location
4. Configure git credential helper

**SAIF Flag:** `SAIF-GH-TOKEN-20251205-001`

**Result:** Git MCP server and CLI can access private repos

#### 1.3: Proton VPN/Mail Credentials

**Current Status:** Unknown

**Desired State:** Credentials stored securely for VPN/mail access

**Steps:**
1. Locate Proton account credentials
2. Store in password manager or keyring
3. Configure Proton VPN client (if needed for gaming)

**SAIF Flag:** `SAIF-PROTON-20251205-001`

**Result:** Proton services accessible when needed

#### 1.4: Other API Keys (As Needed)

| Service | Purpose | Priority | SAIF Flag |
|---------|---------|----------|-----------|
| Anthropic API | Claude API access | MEDIUM | `SAIF-ANTHROPIC-20251205-001` |
| OpenAI API | GPT access | LOW | `SAIF-OPENAI-20251205-001` |
| Perplexity API | Search integration | LOW | `SAIF-PERPLEXITY-20251205-001` |

**ATOM Trail:**
```bash
ATOM-CRED-20251205-001: Cloudflare API token collected and validated
ATOM-CRED-20251205-002: GitHub PAT created with repo scope
ATOM-CRED-20251205-003: Proton credentials secured in keyring
```

---

### Phase 2: MCP Server Configuration
**SAIF Flag:** `SAIF-MCP-CONFIG-20251205-001`

#### 2.1: Fix Claude Desktop Config

**Current Config (Windows paths):**
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem",
        "%USERPROFILE%\\kenl", ...]
    },
    "git": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-git",
        "--repository", "%USERPROFILE%\\kenl"]
    },
    "cloudflare": {
      "command": "npx",
      "args": ["-y", "@cloudflare/mcp-server-cloudflare"],
      "env": {
        "CLOUDFLARE_API_TOKEN": "YOUR_API_TOKEN_HERE",
        "CLOUDFLARE_ACCOUNT_ID": "3ddeb355f4954bb1ee4f9486b2908e7e"
      }
    }
  }
}
```

**Desired Config (Linux paths):**
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem",
        "/home/toolated/.kenl",
        "/home/toolated/.config",
        "/home/toolated/projects"]
    },
    "git": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-git",
        "--repository", "/home/toolated/.kenl"]
    },
    "cloudflare": {
      "command": "npx",
      "args": ["-y", "@cloudflare/mcp-server-cloudflare"],
      "env": {
        "CLOUDFLARE_API_TOKEN": "<ACTUAL_TOKEN_FROM_PHASE_1>",
        "CLOUDFLARE_ACCOUNT_ID": "3ddeb355f4954bb1ee4f9486b2908e7e"
      }
    }
  },
  "globalShortcut": "CommandOrControl+Shift+Space"
}
```

**SAIF Flag:** `SAIF-MCP-CLAUDE-20251205-001`

**Result:** Claude Desktop can access Linux filesystem and git repos

#### 2.2: Configure Additional MCP Servers

**Available MCP servers to configure:**
- [ ] **@modelcontextprotocol/server-brave-search** - Web search
- [ ] **@modelcontextprotocol/server-memory** - Persistent memory
- [ ] **@modelcontextprotocol/server-postgres** - Database access (if needed)
- [ ] **@modelcontextprotocol/server-puppeteer** - Browser automation

**SAIF Flag:** `SAIF-MCP-ADDITIONAL-20251205-001`

**ATOM Trail:**
```bash
ATOM-MCP-20251205-001: Claude Desktop config updated for Linux paths
ATOM-MCP-20251205-002: Cloudflare MCP server configured with API token
ATOM-MCP-20251205-003: Filesystem MCP server paths validated
ATOM-MCP-20251205-004: Git MCP server repository access confirmed
```

---

### Phase 3: Distrobox Configuration
**SAIF Flag:** `SAIF-DISTROBOX-20251205-001`

#### 3.1: Verify Current Distrobox Setup

**Check current distrobox:**
```bash
distrobox list
# Expected: debian container (current environment)

distrobox-export --help
# Verify export functionality available
```

#### 3.2: Host System Access from Distrobox

**Test host access:**
```bash
# Check if we can access host commands
distrobox-host-exec rpm-ostree status
# Should show Bazzite status

# Test file system access
ls /run/host/
# Should show host system directories
```

#### 3.3: Create Additional Distroboxes (As Needed)

**Desired distroboxes:**
- [x] `debian` - General development (current)
- [ ] `arch` - AUR packages and gaming tools
- [ ] `ubuntu` - Ubuntu-specific testing
- [ ] `fedora` - Match host OS for testing

**SAIF Flag:** `SAIF-DISTROBOX-MULTI-20251205-001`

**ATOM Trail:**
```bash
ATOM-DISTROBOX-20251205-001: Debian distrobox verified operational
ATOM-DISTROBOX-20251205-002: Host system access validated
ATOM-DISTROBOX-20251205-003: Additional distroboxes created (arch, ubuntu)
```

---

### Phase 4: Gaming Stack Configuration
**SAIF Flag:** `SAIF-GAMING-20251205-001`

#### 4.1: Verify GameScope Installation

**On host system (via distrobox-host-exec):**
```bash
distrobox-host-exec which gamescope
# Expected: /usr/bin/gamescope

distrobox-host-exec gamescope --version
# Should show version
```

#### 4.2: Configure MangoHud

**Check MangoHud config:**
```bash
# Host config location
cat /run/host/home/toolated/.config/MangoHud/MangoHud.conf
# Or create if missing

# Desired config (from playcard):
# fps
# frametime
# gpu_stats
# gpu_temp
# gpu_core_clock
# gpu_mem_clock
# gpu_power
# cpu_stats
# cpu_temp
# cpu_power
# ram
# vram
# wine
# vulkan_driver
# engine_version
# font_size=24
# position=top-left
# toggle_hud=Shift_R+F12
```

**SAIF Flag:** `SAIF-MANGOHUD-20251205-001`

#### 4.3: Configure MangoJuice (Mobile Overlay)

**Check if MangoJuice is installed:**
```bash
distrobox-host-exec flatpak list | grep -i mango
# Look for MangoJuice or MangoHud
```

**SAIF Flag:** `SAIF-MANGOJUICE-20251205-001`

#### 4.4: Validate Gaming Environment

**Test gaming setup:**
```bash
# Check AMD GPU is detected
distrobox-host-exec glxinfo | grep "OpenGL renderer"
# Expected: AMD Radeon Vega

# Check Vulkan
distrobox-host-exec vulkaninfo --summary | grep deviceName
# Expected: AMD Radeon Vega

# Verify kernel parameters (from playcard)
distrobox-host-exec cat /proc/cmdline | grep amdgpu
# Should contain: amdgpu.ppfeaturemask=0xffffffff, amd_pstate=active, etc.
```

**SAIF Flag:** `SAIF-GAMING-VALIDATE-20251205-001`

**ATOM Trail:**
```bash
ATOM-GAMING-20251205-001: GameScope installation verified
ATOM-GAMING-20251205-002: MangoHud configured with performance overlay
ATOM-GAMING-20251205-003: MangoJuice mobile overlay enabled
ATOM-GAMING-20251205-004: AMD GPU acceleration validated
```

---

### Phase 5: Dashboard & Monitoring Configuration
**SAIF Flag:** `SAIF-DASHBOARD-20251205-001`

#### 5.1: Enable KENL Dashboard

**Check if dashboard exists:**
```bash
ls ~/.kenl/scripts/kenl-dashboard.sh
# Or equivalent dashboard script
```

**Configure dashboard to show:**
- Current rpm-ostree deployment status
- Distrobox status and active containers
- AMD GPU temps and clocks
- CPU governor and frequency
- Network latency baseline
- ATOM trail recent entries
- MCP server status

**SAIF Flag:** `SAIF-DASH-KENL-20251205-001`

#### 5.2: Configure Logdy Central Aggregation

**Check Logdy status (from pre-rebase docs):**
```bash
ls ~/.local/bin/logdy
systemctl --user status logdy-central.service
```

**If not configured, set up central log aggregation:**
- System logs (journald)
- ATOM trail
- Claude Desktop conversations
- Observer logs (if enabled)

**SAIF Flag:** `SAIF-DASH-LOGDY-20251205-001`

#### 5.3: Enable Live Metrics

**Dynamic features to enable:**
- Real-time FPS counter integration
- GPU/CPU temperature monitoring
- Network latency tracking
- Steam game session logging

**SAIF Flag:** `SAIF-DASH-LIVE-20251205-001`

**ATOM Trail:**
```bash
ATOM-DASH-20251205-001: KENL dashboard configured with system metrics
ATOM-DASH-20251205-002: Logdy central aggregation enabled
ATOM-DASH-20251205-003: Live metrics tracking activated
```

---

### Phase 6: Host System Issue Resolution
**SAIF Flag:** `SAIF-HOST-FIX-20251205-001`

#### 6.1: Fix beszel-agent.service

**Issue:** Failed 200+ times - `no key provided`

**Resolution:**
```bash
# On host (via distrobox-host-exec):
# Option A: Disable if not needed
distrobox-host-exec sudo systemctl disable --now beszel-agent.service

# Option B: Configure with key
distrobox-host-exec sudo systemctl edit beszel-agent.service
# Add: Environment="KEY=your-key-here"
```

**SAIF Flag:** `SAIF-HOST-BESZEL-20251205-001`

#### 6.2: Fix gamemode-monitor.sh

**Issue:** `gamemoded: command not found`

**Resolution:**
```bash
# Check if gamemode is installed
distrobox-host-exec rpm-ostree status | grep gamemode

# If not, layer it
distrobox-host-exec sudo rpm-ostree install gamemode
distrobox-host-exec sudo systemctl reboot
```

**SAIF Flag:** `SAIF-HOST-GAMEMODE-20251205-001`

#### 6.3: Fix RADV_DEBUG Configuration

**Issue:** `/usr/lib/environment.d/99-environment.conf:4` syntax error

**Resolution:**
```bash
# On host, check the file
distrobox-host-exec sudo cat /usr/lib/environment.d/99-environment.conf

# Fix syntax error on line 4
distrobox-host-exec sudo nano /usr/lib/environment.d/99-environment.conf
```

**SAIF Flag:** `SAIF-HOST-RADV-20251205-001`

**ATOM Trail:**
```bash
ATOM-HOST-20251205-001: beszel-agent.service disabled (not in use)
ATOM-HOST-20251205-002: gamemode layered via rpm-ostree
ATOM-HOST-20251205-003: RADV_DEBUG syntax error corrected
ATOM-HOST-20251205-004: Flatpak database repaired
```

---

### Phase 7: System Playcard Update
**SAIF Flag:** `SAIF-PLAYCARD-20251205-001`

#### 7.1: Add Current System State Section

**Update `~/.kenl/current-playcard.yaml` with:**

```yaml
# Add to existing playcard:

current_system_state:
  date_assessed: "2025-12-05"
  environment:
    host_os: "Bazzite 40 (Fedora immutable)"
    host_kernel: "6.17.7-ba19.fc43.x86_64"
    container_os: "Debian 12 (bookworm)"
    container_type: "distrobox"

  rpm_ostree_status:
    current_deployment: "Check with rpm-ostree status"
    state: "PRE-REBASE"  # or "POST-REBASE" after update
    pending_rebase: true
    target: "fedora:fedora/43/x86_64/bazzite-dx"

  distrobox_config:
    active_containers:
      - name: "debian"
        image: "debian:12"
        status: "running"
        purpose: "general development and Claude Code"
    host_access: true
    export_binaries: []

  mcp_servers:
    configured:
      - name: "filesystem"
        status: "operational"
        paths: ["/home/toolated/.kenl", "/home/toolated/.config"]
      - name: "git"
        status: "operational"
        repository: "/home/toolated/.kenl"
      - name: "cloudflare"
        status: "configured"
        auth: "API token set"

  gaming_stack:
    gamescope_version: "Check version"
    mangohud_installed: true
    mangohud_config: "~/.config/MangoHud/MangoHud.conf"
    steam_installed: true  # Bazzite default
    proton_version: "GE-Proton Latest"

  monitoring:
    logdy_central: false  # Enable in Phase 5
    kenl_dashboard: false  # Enable in Phase 5
    atom_trail: true
    atom_counter: "Check ~/.kenl/.atom-counter"

  known_issues:
    - "beszel-agent.service failing (key not configured)"
    - "gamemode-monitor.sh error (gamemoded not found)"
    - "RADV_DEBUG syntax error in /usr/lib/environment.d/99-environment.conf:4"
    - "Flatpak database errors (repair needed)"

  validation_status:
    hardware_detection: "passed"
    gpu_acceleration: "needs_validation"
    gaming_performance: "not_tested"
    mcp_servers: "partial"  # filesystem/git OK, cloudflare needs token
    distrobox_operational: "verified"

atom_trail:
  last_entry: "ATOM-SAIF-20251205-001"
  total_entries: "Check ~/.kenl/.saif-counter"
```

**SAIF Flag:** `SAIF-PLAYCARD-UPDATE-20251205-001`

---

### Phase 8: Validation & Testing
**SAIF Flag:** `SAIF-VALIDATE-20251205-001`

#### 8.1: System Validation Checklist

Run comprehensive validation tests:

```bash
# Environment validation
echo "=== Environment Check ==="
echo "Current environment: $(cat /etc/os-release | grep PRETTY_NAME)"
echo "Distrobox: $(which distrobox-enter)"
echo "Host access: $(distrobox-host-exec hostname)"

# MCP Server validation
echo "=== MCP Server Check ==="
cat ~/.kenl/claude_desktop_config.json | jq '.mcpServers | keys[]'

# Gaming stack validation
echo "=== Gaming Stack Check ==="
distrobox-host-exec which gamescope
distrobox-host-exec which mangohud
distrobox-host-exec glxinfo | grep "OpenGL renderer"

# Credential validation
echo "=== Credential Check ==="
# DO NOT echo actual tokens, just check they're set
test -n "$CLOUDFLARE_API_TOKEN" && echo "Cloudflare token: SET" || echo "Cloudflare token: NOT SET"

# Dashboard validation
echo "=== Dashboard Check ==="
ls ~/.kenl/scripts/*dashboard* 2>/dev/null | wc -l

# ATOM trail validation
echo "=== ATOM Trail Check ==="
tail -5 ~/.kenl/.atom-trail.log 2>/dev/null || echo "No ATOM trail yet"
```

**SAIF Flag:** `SAIF-VALIDATE-ALL-20251205-001`

#### 8.2: Gaming Performance Test

**Run quick gaming validation:**
```bash
# Test GPU stress
distrobox-host-exec glxgears  # Should show high FPS

# Test Vulkan
distrobox-host-exec vkcube  # Should render smoothly

# Check CPU governor
distrobox-host-exec cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
# Expected: performance (from playcard config)

# Check GPU power profile
distrobox-host-exec cat /sys/class/drm/card0/device/power_dpm_force_performance_level
# Expected: auto or high
```

**SAIF Flag:** `SAIF-VALIDATE-GAMING-20251205-001`

**ATOM Trail:**
```bash
ATOM-VALIDATE-20251205-001: System validation checklist completed
ATOM-VALIDATE-20251205-002: Gaming performance baseline established
ATOM-VALIDATE-20251205-003: All MCP servers responding
ATOM-VALIDATE-20251205-004: Distrobox host access confirmed
```

---

## SAIF Workflow Summary

### State Transition Table

| Phase | Start State | End State | SAIF Flags | ATOM Tags | Duration |
|-------|-------------|-----------|------------|-----------|----------|
| 0: Discovery | Unknown | Baseline documented | 1 | 3 | 15 min |
| 1: Credentials | No credentials | All API keys collected | 4 | 3 | 30 min |
| 2: MCP Config | Windows paths | Linux MCP servers | 2 | 4 | 20 min |
| 3: Distrobox | Single container | Multi-distrobox with host access | 2 | 3 | 25 min |
| 4: Gaming | Unknown status | Validated gaming stack | 4 | 4 | 30 min |
| 5: Dashboards | Not enabled | Live monitoring | 3 | 3 | 20 min |
| 6: Host Fixes | Known issues | Issues resolved | 3 | 4 | 40 min |
| 7: Playcard | Hardware only | Current state | 1 | 1 | 15 min |
| 8: Validation | Unvalidated | Fully tested | 3 | 4 | 25 min |
| **Total** | **Initial** | **KENL-13 i-W-i Operational** | **23** | **29** | **~3.5 hours** |

---

## ATOM Trail Template

### Complete Workflow ATOM Trail

```bash
# Phase 0: Discovery
ATOM-DISCOVER-20251205-001: Environment detected (Debian distrobox on Bazzite host)
ATOM-DISCOVER-20251205-002: Host system PRE-REBASE state confirmed
ATOM-DISCOVER-20251205-003: Known issues cataloged (beszel-agent, gamemode, RADV_DEBUG)

# Phase 1: Credentials
ATOM-CRED-20251205-001: Cloudflare API token collected and validated
ATOM-CRED-20251205-002: GitHub PAT created with repo scope
ATOM-CRED-20251205-003: Proton credentials secured in keyring

# Phase 2: MCP Configuration
ATOM-MCP-20251205-001: Claude Desktop config updated for Linux paths
ATOM-MCP-20251205-002: Cloudflare MCP server configured with API token
ATOM-MCP-20251205-003: Filesystem MCP server paths validated
ATOM-MCP-20251205-004: Git MCP server repository access confirmed

# Phase 3: Distrobox
ATOM-DISTROBOX-20251205-001: Debian distrobox verified operational
ATOM-DISTROBOX-20251205-002: Host system access validated
ATOM-DISTROBOX-20251205-003: Additional distroboxes created (arch, ubuntu)

# Phase 4: Gaming
ATOM-GAMING-20251205-001: GameScope installation verified
ATOM-GAMING-20251205-002: MangoHud configured with performance overlay
ATOM-GAMING-20251205-003: MangoJuice mobile overlay enabled
ATOM-GAMING-20251205-004: AMD GPU acceleration validated

# Phase 5: Dashboards
ATOM-DASH-20251205-001: KENL dashboard configured with system metrics
ATOM-DASH-20251205-002: Logdy central aggregation enabled
ATOM-DASH-20251205-003: Live metrics tracking activated

# Phase 6: Host Fixes
ATOM-HOST-20251205-001: beszel-agent.service disabled (not in use)
ATOM-HOST-20251205-002: gamemode layered via rpm-ostree
ATOM-HOST-20251205-003: RADV_DEBUG syntax error corrected
ATOM-HOST-20251205-004: Flatpak database repaired

# Phase 7: Playcard
ATOM-PLAYCARD-20251205-001: Current system state section added to playcard

# Phase 8: Validation
ATOM-VALIDATE-20251205-001: System validation checklist completed
ATOM-VALIDATE-20251205-002: Gaming performance baseline established
ATOM-VALIDATE-20251205-003: All MCP servers responding
ATOM-VALIDATE-20251205-004: Distrobox host access confirmed
```

---

## Next Steps After Workflow Completion

### Immediate (Same Session)
- [ ] Test Claude Desktop with new MCP configuration
- [ ] Run a simple game to validate gaming stack
- [ ] Check dashboard displays correctly
- [ ] Verify ATOM trail is being written

### Short-term (Next Session)
- [ ] Proceed with system rebase (if still PRE-REBASE)
- [ ] Run post-rebase validation
- [ ] Configure Logdy central aggregation
- [ ] Set up automated monitoring

### Long-term (Next Week)
- [ ] Create shareable Play Card from this configuration
- [ ] Document any discovered optimizations
- [ ] Contribute working config to KENL repository
- [ ] Test additional distroboxes for specific workflows

---

## Rollback Plan

### If Workflow Fails

**1. MCP Configuration Issues:**
```bash
# Restore original config
cp ~/.kenl/claude_desktop_config.json.backup ~/.kenl/claude_desktop_config.json
```

**2. Host System Issues:**
```bash
# Rollback rpm-ostree changes
distrobox-host-exec sudo rpm-ostree rollback
distrobox-host-exec sudo systemctl reboot
```

**3. Distrobox Issues:**
```bash
# Remove problematic distrobox
distrobox rm <container-name>

# Recreate from scratch
distrobox create --name debian --image debian:12
```

**4. Gaming Stack Issues:**
```bash
# Disable performance optimizations
distrobox-host-exec sudo systemctl disable cpu-performance.service
distrobox-host-exec sudo systemctl disable gpu-performance.service
```

---

## Success Criteria

Workflow is considered **COMPLETE** when:
- ✅ All MCP servers configured and responding
- ✅ Claude Desktop config uses Linux paths
- ✅ Distrobox can access host system
- ✅ Gaming stack validated (glxgears, vkcube work)
- ✅ Dashboard shows live metrics
- ✅ Known host issues resolved or documented
- ✅ System playcard reflects current state
- ✅ ATOM trail contains all workflow steps

---

## SAIF Metadata

**Framework Version:** SAIF v1.0.0
**ATOM Tag:** ATOM-SAIF-20251205-001
**Classification:** SAIF-WORKFLOW
**Status:** IN-PROGRESS
**Estimated Completion:** 3.5 hours from start
**Dependencies:** None (self-contained workflow)
**Rollback Safe:** Yes (all changes reversible)

---

**Last Updated:** 2025-12-05
**Author:** Claude (Sonnet 4.5) with user intent capture
**Purpose:** First real system test of KENL-13 i-W-i framework
**Expected Outcome:** Fully operational system with complete observability
