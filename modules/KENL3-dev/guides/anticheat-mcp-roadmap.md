# Anti-Cheat MCP Server Implementation Roadmap

**Version:** 1.0.0
**Status:** Planning
**Owner:** KENL3-dev
**Target Platform:** Windows (primary), Linux (secondary)
**ATOM Tags:** `kenl3`, `mcp`, `anticheat`, `windows`, `planning`

---

## Executive Summary

This roadmap outlines the development of a Model Context Protocol (MCP) server that provides anti-cheat system awareness, service management, and security posture tracking for gaming systems. The server enables AI agents (Claude Code, local LLMs) to:

- Query anti-cheat compatibility databases
- Manage anti-cheat services (start/stop/status)
- Detect Windows LSA/Credential Guard conflicts
- Generate Play Cards with anti-cheat documentation
- Automate gaming session workflows with ATOM trail logging

**Key Constraint:** This MCP server provides **workarounds and automation**, not solutions to kernel-level conflicts between anti-cheat software (e.g., EasyAntiCheat) and Windows security features (LSA protection, Credential Guard).

---

## Problem Statement

### The Core Conflict

Many anti-cheat systems (EasyAntiCheat, BattlEye, Vanguard) operate at kernel level (ring 0) and conflict with Windows security features:

- **LSA Protection (Credential Guard)**: Uses VBS (Virtualization-Based Security) to isolate credentials
- **Anti-Cheat Drivers**: Require deep system access that LSA protection blocks

**Impact:** Users must choose between:
1. Gaming with anti-cheat (reduced security posture)
2. Maximum security with LSA enabled (incompatible with many games)

### What Users Need

1. **Visibility**: Know which games require which anti-cheat systems
2. **Automation**: Toggle security settings for gaming sessions without manual registry/service edits
3. **Auditability**: ATOM trails tracking security posture changes (who, what, when, why)
4. **Guidance**: AI agents that understand anti-cheat compatibility before game purchase/install

---

## Goals and Non-Goals

### Goals

✅ **Automate anti-cheat service management** (enable/disable on demand)
✅ **Detect security posture conflicts** (LSA vs anti-cheat status)
✅ **Query compatibility databases** (AreWeAntiCheatYet, ProtonDB)
✅ **Generate Play Cards** with anti-cheat documentation
✅ **ATOM trail integration** for all security state changes
✅ **Cross-platform awareness** (Windows service vs Linux systemd)
✅ **Gaming session workflows** (pre-game setup, post-game cleanup)

### Non-Goals

❌ **Fix kernel-level conflicts** (impossible without OS/anti-cheat vendor cooperation)
❌ **Bypass or disable anti-cheat** (security/ToS violation)
❌ **Make Linux-incompatible games work** (EasyAntiCheat/BattlEye decisions)
❌ **Guarantee game compatibility** (just provide data and automation)

---

## Architecture Overview

### MCP Server Components

```
kenl-anticheat-mcp/
├── src/
│   ├── index.ts              # MCP server entry point
│   ├── tools/
│   │   ├── compatibility.ts  # Query databases (AreWeAntiCheatYet, ProtonDB)
│   │   ├── service.ts        # Windows service management (PowerShell)
│   │   ├── security.ts       # LSA/Credential Guard detection
│   │   ├── playcard.ts       # Generate YAML Play Cards
│   │   └── session.ts        # Gaming session workflows
│   ├── providers/
│   │   ├── awacy.ts          # AreWeAntiCheatYet API client
│   │   ├── protondb.ts       # ProtonDB scraper/API
│   │   └── registry.ts       # Windows registry queries (LSA status)
│   ├── atom/
│   │   ├── logger.ts         # ATOM trail integration
│   │   └── schemas.ts        # ATOM metadata schemas
│   └── utils/
│       ├── powershell.ts     # PowerShell command execution
│       └── platform.ts       # Cross-platform detection
├── package.json
├── tsconfig.json
└── README.md
```

### Integration Points

- **Claude Code**: MCP client via `claude_desktop_config.json`
- **PowerShell Modules**: `KENL.psm1`, `KENL.Network.psm1` (Windows automation)
- **ATOM Framework**: `~/.atom-logs/` (Windows), `~/.local/share/atom-logs/` (Linux)
- **Play Cards**: `~/kenl/modules/KENL2-gaming/play-cards/`
- **KENL4 Monitoring**: Prometheus metrics (future integration)

---

## Implementation Phases

### Phase 0: Prerequisites (Week 0)

**Objective:** Set up development environment and validate dependencies

**Tasks:**
- [ ] Install Node.js 18+ and TypeScript
- [ ] Clone MCP SDK from Anthropic/ModelContext Protocol repo
- [ ] Verify PowerShell 7+ on Windows (required for cross-platform modules)
- [ ] Test ATOM trail logging from TypeScript (proof of concept)
- [ ] Document MCP server registration in `claude_desktop_config.json`

**Deliverables:**
- Development environment setup guide
- Hello World MCP server (1 tool: `echo`)
- ATOM trail test from Node.js

**ATOM Trail:**
```yaml
type: setup
intent: validate_mcp_development_environment
timestamp: 2025-11-16T20:00:00Z
context: "Preparing for anti-cheat MCP server development"
```

---

### Phase 1: MVP - Query and Status (Weeks 1-2)

**Objective:** Provide read-only anti-cheat information to AI agents

#### Tools to Implement

**1. `check_anticheat_compatibility`**
```typescript
// Input: game_name (string)
// Output: { game, anticheat_system, linux_status, windows_status, source }
// Queries: AreWeAntiCheatYet API
```

**2. `query_protondb`**
```typescript
// Input: steam_appid (number) or game_name (string)
// Output: { rating, anticheat_notes, proton_version, reports[] }
// Queries: ProtonDB API/scraper
```

**3. `get_service_status`**
```typescript
// Input: service_name (string, default: "EasyAntiCheat_EOS")
// Output: { running: bool, startup_type: string, path: string }
// Platform: Windows (Get-Service), Linux (systemctl status)
```

**4. `get_lsa_status`**
```typescript
// Input: none
// Output: { credential_guard: bool, vbs_running: bool, lsa_protected: bool }
// Platform: Windows only (Get-CimInstance Win32_DeviceGuard)
```

#### Acceptance Criteria

- [ ] Successfully query AreWeAntiCheatYet for Battlefield 2042, Apex Legends, Elden Ring
- [ ] Detect EasyAntiCheat service status on Windows
- [ ] Return LSA/Credential Guard status accurately
- [ ] All queries logged to ATOM trail with intent metadata
- [ ] Error handling for missing APIs/services

#### Testing

```bash
# Test via Claude Code
User: "Does Battlefield 2042 work on Linux?"
Agent: Uses check_anticheat_compatibility → "No, EasyAntiCheat blocks Linux"

User: "Is EasyAntiCheat running?"
Agent: Uses get_service_status → "Stopped, startup type: Disabled"

User: "Do I have LSA protection enabled?"
Agent: Uses get_lsa_status → "Credential Guard: Enabled, VBS: Running"
```

**Deliverables:**
- 4 working MCP tools (read-only)
- Integration with AreWeAntiCheatYet API
- ProtonDB query capability
- ATOM trail logging for all queries

**Risk:** ProtonDB may not have public API → Mitigation: Web scraping or manual database

---

### Phase 2: Service Management (Weeks 3-4)

**Objective:** Enable AI agents to automate anti-cheat service control

#### Tools to Implement

**5. `toggle_anticheat_service`**
```typescript
// Input: { action: "enable" | "disable" | "start" | "stop", service_name: string }
// Output: { success: bool, new_state: string, rollback_command: string }
// Requires: Administrator/sudo permissions
// ATOM: Logs intent, action, rollback instructions
```

**6. `create_gaming_session`**
```typescript
// Input: { game_name: string, disable_lsa: bool }
// Output: { session_id: string, actions_taken: [], rollback_plan: string }
// Actions:
//   1. Stop LSA protection (if requested + warning)
//   2. Enable anti-cheat service
//   3. Log ATOM trail with security posture change
//   4. Return rollback plan
```

**7. `end_gaming_session`**
```typescript
// Input: { session_id: string }
// Output: { actions_taken: [], security_restored: bool }
// Actions:
//   1. Stop anti-cheat service
//   2. Re-enable LSA protection
//   3. Verify security posture restored
//   4. Close ATOM trail session
```

#### Safety Features

**Pre-Execution Checks:**
- [ ] User confirmation required for LSA changes (security impact warning)
- [ ] Validate rollback plan before execution
- [ ] Check for running games before stopping anti-cheat
- [ ] Verify administrator/sudo permissions

**ATOM Trail Requirements:**
- [ ] Log security posture BEFORE and AFTER changes
- [ ] Include rollback commands in metadata
- [ ] Tag high-risk operations (LSA disable) with `risk: high`
- [ ] Cryptographic hash of state changes (KENL1 ATOM standards)

#### Acceptance Criteria

- [ ] Successfully start/stop EasyAntiCheat service
- [ ] Gaming session workflow (disable LSA → game → restore LSA) works end-to-end
- [ ] Rollback plan executes successfully if gaming session fails
- [ ] User receives clear warnings about security impact
- [ ] All operations reversible via ATOM trail rollback commands

#### Testing

```powershell
# Test gaming session workflow
User: "Set up my system for Battlefield 2042"
Agent:
  1. Uses get_lsa_status → "LSA enabled"
  2. Warns: "This will temporarily reduce security"
  3. Uses create_gaming_session → Disables LSA, enables EAC
  4. Logs ATOM trail with rollback plan
  5. Returns: "Ready to launch. Run end_gaming_session when done."

User: "Done gaming"
Agent:
  1. Uses end_gaming_session
  2. Stops EasyAntiCheat, re-enables LSA
  3. Verifies security posture restored
```

**Deliverables:**
- 3 service management tools
- Gaming session state machine
- Safety checks and warnings
- Rollback automation

**Risk:** PowerShell execution policy blocks scripts → Mitigation: Documentation on Set-ExecutionPolicy, signed scripts

---

### Phase 3: Play Card Generation (Weeks 5-6)

**Objective:** Automate Play Card creation with anti-cheat documentation

#### Tools to Implement

**8. `generate_playcard`**
```typescript
// Input: { game_name: string, steam_appid?: number, auto_detect?: bool }
// Output: { yaml_content: string, file_path: string, validation_result: object }
// Actions:
//   1. Query compatibility databases
//   2. Detect running processes (if auto_detect)
//   3. Check service dependencies
//   4. Query hardware (GPU, CPU via PowerShell)
//   5. Generate YAML matching KENL2 Play Card schema
//   6. Validate against schema
//   7. Save to ~/kenl/modules/KENL2-gaming/play-cards/
```

**9. `validate_playcard`**
```typescript
// Input: { file_path: string }
// Output: { valid: bool, errors: [], warnings: [], safety_score: number }
// Checks:
//   - YAML syntax
//   - Required fields (game.name, game.platform, anticheat.system)
//   - AI safety scoring (Qwen local model - detect malicious launch options)
//   - Hardware profile completeness
```

#### Play Card Schema (Anti-Cheat Fields)

```yaml
anticheat:
  system: "EasyAntiCheat_EOS"          # Anti-cheat name
  version: "1.0.0"                     # Detected version
  kernel_driver: true                  # Kernel-level driver?
  blocks_lsa: true                     # Conflicts with LSA?
  linux_support: "blocked"             # supported | partial | blocked
  windows_support: "required"          # required | optional | none
  service_name: "EasyAntiCheat_EOS"    # Windows service name
  workarounds:
    - action: "disable_lsa"
      risk: "high"
      reversible: true
      command: "Set-ItemProperty -Path HKLM:\\SYSTEM\\... -Name LsaCfgFlags -Value 0"
```

#### Acceptance Criteria

- [ ] Generate valid YAML for Battlefield 2042 with full anti-cheat documentation
- [ ] Auto-detect running anti-cheat services and include in Play Card
- [ ] Validate Play Cards against KENL2 schema
- [ ] AI safety scoring detects malicious launch options (test with known bad examples)
- [ ] Save to correct location with proper naming (`battlefield-2042.yaml`)

#### Testing

```bash
User: "Document Battlefield 2042's anti-cheat"
Agent:
  1. Uses check_anticheat_compatibility → EasyAntiCheat_EOS
  2. Uses get_service_status → Detect version, path
  3. Uses get_lsa_status → Document LSA conflict
  4. Uses generate_playcard → Create YAML
  5. Uses validate_playcard → Safety score: 95/100 (safe)
  6. Saves to ~/kenl/modules/KENL2-gaming/play-cards/battlefield-2042.yaml
```

**Deliverables:**
- 2 Play Card tools
- YAML schema validation
- AI safety scoring integration
- Example Play Cards for top 10 Steam games

**Risk:** AI safety scoring requires local Qwen model → Mitigation: Fallback to regex validation if Ollama unavailable

---

### Phase 4: Monitoring Integration (Weeks 7-8)

**Objective:** Integrate with KENL4 monitoring for security posture tracking

#### Tools to Implement

**10. `export_prometheus_metrics`**
```typescript
// Output: Prometheus exposition format
// Metrics:
//   - anticheat_service_active{service="EasyAntiCheat_EOS"} 1
//   - lsa_protection_enabled 0
//   - gaming_session_active 1
//   - security_posture_score 65  # 0-100, lower = weaker security
```

**11. `get_security_posture`**
```typescript
// Output: { score: number, factors: [], recommendations: [] }
// Factors:
//   - LSA enabled: +30 points
//   - Credential Guard running: +20 points
//   - Anti-cheat kernel driver active: -15 points
//   - Firewall enabled: +10 points
//   - Automatic updates enabled: +10 points
```

#### KENL4 Integration

- [ ] Prometheus scrape endpoint (HTTP server in MCP)
- [ ] Grafana dashboard template (security posture over time)
- [ ] Alert rules (LSA disabled for >4 hours)
- [ ] ATOM database export (SQLite → Cloudflare D1)

#### Acceptance Criteria

- [ ] Prometheus metrics endpoint responds correctly
- [ ] Security posture score accurately reflects system state
- [ ] Grafana dashboard shows anti-cheat vs LSA status over time
- [ ] Alerts trigger when security posture degrades

**Deliverables:**
- Prometheus metrics exporter
- Grafana dashboard JSON
- Security posture algorithm
- ATOM database schema for anti-cheat events

**Risk:** Prometheus integration increases MCP server complexity → Mitigation: Optional feature flag

---

### Phase 5: Advanced Features (Weeks 9-12)

**Objective:** Polish, optimization, and community features

#### Features

**Scheduled Tasks:**
- Auto-restore LSA protection after 4 hours of inactivity
- Windows Task Scheduler integration (PowerShell ScheduledTask cmdlets)
- Reminder notifications before gaming session ends

**Multi-Game Sessions:**
- Track multiple games in single session
- Aggregate anti-cheat requirements (if all use EasyAntiCheat, start once)
- Optimize service start/stop to minimize reboots

**Community Integration (KENL6):**
- Upload Play Cards to community repository (encrypted via KENL8)
- Query shared Play Cards before generating new ones
- Attribution and verification (GPG signatures)

**Cross-Platform Parity:**
- Linux systemd service management (anti-cheat on Wine/Proton)
- Detect Wine prefix anti-cheat installations
- Unified interface for Windows/Linux service control

#### Acceptance Criteria

- [ ] Scheduled LSA restoration works after gaming session timeout
- [ ] Multi-game session reduces service restarts by 50%+
- [ ] Community Play Card sharing functional (upload + download)
- [ ] Linux parity for service management (where applicable)

**Deliverables:**
- Scheduled task automation
- Multi-game session manager
- Community sharing integration
- Cross-platform service abstraction

---

## Technical Specifications

### PowerShell Commands Reference

**Service Management:**
```powershell
# Get service status
Get-Service -Name "EasyAntiCheat_EOS" | Select-Object Status, StartType, DisplayName

# Start/stop service
Start-Service -Name "EasyAntiCheat_EOS"
Stop-Service -Name "EasyAntiCheat_EOS"

# Change startup type
Set-Service -Name "EasyAntiCheat_EOS" -StartupType Disabled
Set-Service -Name "EasyAntiCheat_EOS" -StartupType Automatic
```

**LSA Protection Detection:**
```powershell
# Credential Guard status
Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard | Select-Object SecurityServicesRunning, VirtualizationBasedSecurityStatus

# LSA protection registry key
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LsaCfgFlags"

# Disable LSA protection (requires reboot)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LsaCfgFlags" -Value 0
```

**ATOM Trail Logging:**
```powershell
# Using KENL.psm1 module
Import-Module ~/kenl/modules/KENL0-system/powershell/KENL.psm1
Write-AtomTrail -Type "security" -Intent "disable_lsa_for_gaming" -Context "Battlefield 2042 session"
```

### API Endpoints

**AreWeAntiCheatYet:**
```
GET https://api.areweanticheasyyet.com/v1/games
Response: [{ name, anticheat, status, notes, updated }]
```

**ProtonDB (unofficial):**
```
GET https://www.protondb.com/api/v1/reports/summaries/<appid>.json
Response: { tier, confidence, score, total, trendingTier }
```

### MCP Tool Schemas

Example schema for `toggle_anticheat_service`:

```json
{
  "name": "toggle_anticheat_service",
  "description": "Start, stop, enable, or disable anti-cheat services on Windows/Linux",
  "inputSchema": {
    "type": "object",
    "properties": {
      "action": {
        "type": "string",
        "enum": ["start", "stop", "enable", "disable"],
        "description": "Service action to perform"
      },
      "service_name": {
        "type": "string",
        "default": "EasyAntiCheat_EOS",
        "description": "Name of the anti-cheat service"
      },
      "confirm": {
        "type": "boolean",
        "default": false,
        "description": "User confirmation for high-risk actions"
      }
    },
    "required": ["action"]
  }
}
```

---

## Dependencies and Prerequisites

### Software Requirements

**Windows:**
- PowerShell 7.4+ (cross-platform modules)
- Administrator privileges (for service management)
- .NET Framework 4.8+ (for PowerShell cmdlets)

**Linux:**
- systemd (service management)
- Wine/Proton (for anti-cheat in Windows games)
- sudo privileges

**Development:**
- Node.js 18+ LTS
- TypeScript 5.0+
- MCP SDK (@modelcontextprotocol/sdk)

### KENL Module Dependencies

- **KENL0-system**: PowerShell modules (KENL.psm1)
- **KENL1-framework**: ATOM trail schemas, cryptographic hashing
- **KENL2-gaming**: Play Card schema, validation
- **KENL4-monitoring**: Prometheus integration (future)
- **KENL8-security**: GPG signing for Play Cards

---

## Testing Strategy

### Unit Tests

- [ ] PowerShell command execution (mocked services)
- [ ] API client responses (mocked HTTP)
- [ ] YAML generation (schema validation)
- [ ] ATOM trail formatting

### Integration Tests

- [ ] End-to-end gaming session workflow
- [ ] Service start/stop with real Windows services (test VM)
- [ ] LSA status detection on Windows 10/11
- [ ] Play Card generation for 5 popular games

### Security Tests

- [ ] Input validation (prevent command injection)
- [ ] Rollback plan execution (verify reversibility)
- [ ] AI safety scoring (detect malicious launch options)
- [ ] ATOM trail integrity (cryptographic hash verification)

### User Acceptance Testing

- [ ] Claude Code agent successfully sets up gaming session
- [ ] Non-technical user follows AI guidance to toggle anti-cheat
- [ ] Play Cards accurately reflect game requirements
- [ ] Security warnings clear and actionable

---

## Success Metrics

### Quantitative

- **Automation Rate**: 80%+ of gaming sessions use automated setup/teardown
- **Error Recovery**: 90%+ of failed operations have working rollback plans
- **Play Card Coverage**: 100+ games documented with anti-cheat info
- **Security Posture**: Average security score ≥70/100 across user base

### Qualitative

- **User Feedback**: "I no longer manually edit registry to play games"
- **AI Agent Effectiveness**: Claude Code proactively warns about anti-cheat conflicts
- **Community Adoption**: 50+ user-contributed Play Cards
- **Documentation Quality**: Users understand LSA/anti-cheat trade-off

---

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| PowerShell execution policy blocks scripts | High | Medium | Document Set-ExecutionPolicy, provide signed scripts |
| Anti-cheat detects service automation as cheating | Critical | Low | Only manage Windows services, never game memory |
| LSA re-enable fails after gaming session | High | Low | Automatic rollback, system restore point creation |
| ProtonDB API unavailable | Medium | Medium | Cache data, fallback to web scraping |
| User accidentally disables LSA permanently | Medium | Medium | ATOM trail with scheduled restoration, warnings |
| Anti-cheat updates break detection | Medium | High | Community-driven Play Card updates, version tracking |

---

## Timeline Summary

| Phase | Duration | Deliverables | Dependencies |
|-------|----------|--------------|--------------|
| Phase 0: Prerequisites | 1 week | Dev environment, Hello World MCP | None |
| Phase 1: MVP | 2 weeks | 4 query tools, ATOM logging | Phase 0 |
| Phase 2: Service Mgmt | 2 weeks | Service control, gaming sessions | Phase 1 |
| Phase 3: Play Cards | 2 weeks | YAML generation, AI safety scoring | Phase 1 |
| Phase 4: Monitoring | 2 weeks | Prometheus metrics, security posture | Phase 2 |
| Phase 5: Advanced | 4 weeks | Scheduled tasks, community sharing | Phase 3 |
| **Total** | **13 weeks** | **Production-ready MCP server** | - |

---

## Future Enhancements

### Post-v1.0 Features

- **Mobile Integration**: Remote session control via phone app
- **Multi-PC Management**: Centralized anti-cheat config for gaming rig + laptop
- **Game Launcher Integration**: Hooks into Steam/Epic launcher APIs
- **Predictive Warnings**: "You're about to buy a game that requires LSA disabling"
- **Hardware-Specific Profiles**: Different anti-cheat configs for AMD vs NVIDIA
- **Compliance Reporting**: Export security posture logs for corporate policies

### Research Areas

- **Kernel-Level Monitoring**: eBPF on Linux to track anti-cheat behavior
- **Sandboxing**: Run anti-cheat in isolated VM/container (Hyper-V)
- **Alternative Anti-Cheat**: Contribute to open-source anti-cheat that respects LSA
- **Microsoft Collaboration**: Advocate for anti-cheat compatibility mode in Windows

---

## Contributing

This roadmap is a living document. Contributions welcome:

1. **Feedback**: Open GitHub issue with `roadmap` label
2. **Feature Requests**: Add to Phase 5 or Future Enhancements
3. **Implementation**: Submit PR referencing phase/task
4. **Testing**: Validate on your hardware, submit Play Cards

**Contact:** See KENL CONTRIBUTING.md for guidelines.

---

## Appendix A: Reference Architecture

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Claude Code (MCP Client)                │
└─────────────────────┬───────────────────────────────────────┘
                      │ MCP Protocol (stdio)
┌─────────────────────▼───────────────────────────────────────┐
│              KENL Anti-Cheat MCP Server                     │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Tools: compatibility, service, security, playcard   │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Providers: AreWeAntiCheatYet, ProtonDB, Registry    │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  ATOM Trail Logger (cryptographic hashing)           │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────┬──────────────────┬──────────────────┬────────────┘
          │                  │                  │
┌─────────▼─────┐  ┌─────────▼─────┐  ┌─────────▼──────────┐
│  PowerShell   │  │  External APIs │  │  Play Card Files   │
│  (Windows)    │  │  (HTTP)        │  │  (YAML)            │
└───────────────┘  └────────────────┘  └────────────────────┘
```

### Data Flow: Gaming Session

```
1. User: "Set up for Battlefield 2042"
2. Claude Code → MCP: check_anticheat_compatibility("Battlefield 2042")
3. MCP → AreWeAntiCheatYet API → Response: EasyAntiCheat_EOS required
4. MCP → Claude Code: "Requires EasyAntiCheat, conflicts with LSA"
5. Claude Code → MCP: get_lsa_status()
6. MCP → PowerShell: Get-CimInstance Win32_DeviceGuard
7. PowerShell → MCP: Credential Guard enabled
8. MCP → Claude Code: "LSA is enabled, need to disable"
9. Claude Code → User: "Warning: This will reduce security. Proceed?"
10. User: "Yes"
11. Claude Code → MCP: create_gaming_session({ game: "BF2042", disable_lsa: true })
12. MCP → ATOM Logger: Log intent, security state BEFORE
13. MCP → PowerShell: Set-ItemProperty (disable LSA)
14. MCP → PowerShell: Start-Service EasyAntiCheat_EOS
15. MCP → ATOM Logger: Log actions, rollback plan
16. MCP → Claude Code: Session created (session_id: abc123)
17. Claude Code → User: "Ready to launch. LSA disabled, EAC running."
```

---

## Appendix B: ATOM Trail Examples

### Gaming Session Start

```yaml
type: security
intent: create_gaming_session
timestamp: 2025-11-16T20:30:00Z
context: "Battlefield 2042 multiplayer session"
metadata:
  game: "Battlefield 2042"
  anticheat: "EasyAntiCheat_EOS"
  security_changes:
    lsa_before: enabled
    lsa_after: disabled
    anticheat_before: stopped
    anticheat_after: running
  risk_level: high
  user_confirmed: true
rollback:
  - "Stop-Service -Name EasyAntiCheat_EOS"
  - "Set-ItemProperty -Path HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Lsa -Name LsaCfgFlags -Value 1"
  - "Restart-Computer -Confirm"
hash: "sha256:a1b2c3d4e5f6..."
signature: "Ed25519:..." # Optional, KENL8 security
```

### Gaming Session End

```yaml
type: security
intent: end_gaming_session
timestamp: 2025-11-16T23:15:00Z
context: "Restore security posture after gaming"
metadata:
  session_id: "abc123"
  duration_minutes: 165
  security_changes:
    lsa_before: disabled
    lsa_after: enabled
    anticheat_before: running
    anticheat_after: stopped
  security_restored: true
verification:
  - "Get-Service EasyAntiCheat_EOS: Stopped"
  - "Get-CimInstance Win32_DeviceGuard: Credential Guard running"
hash: "sha256:f6e5d4c3b2a1..."
parent_hash: "sha256:a1b2c3d4e5f6..." # Links to session start
```

---

## Appendix C: Play Card Example (Battlefield 2042)

```yaml
# Generated by KENL Anti-Cheat MCP Server v1.0.0
# Timestamp: 2025-11-16T20:00:00Z
# ATOM Tag: playcard_generation

game:
  name: "Battlefield 2042"
  platform: "Steam"
  app_id: 1517290
  developer: "DICE"
  publisher: "Electronic Arts"

anticheat:
  system: "EasyAntiCheat_EOS"
  version: "3.0.0"  # Auto-detected
  kernel_driver: true
  service_name: "EasyAntiCheat_EOS"
  driver_path: "C:\\Program Files (x86)\\EasyAntiCheat_EOS\\EasyAntiCheat_EOS.sys"

  compatibility:
    linux_status: "blocked"
    linux_notes: "EAC does not support Linux for BF2042 (EA decision)"
    windows_status: "required"
    lsa_conflict: true

  workarounds:
    - name: "Disable LSA Protection"
      platform: "Windows"
      risk: "high"
      reversible: true
      requires_reboot: true
      commands:
        - "Set-ItemProperty -Path HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Lsa -Name LsaCfgFlags -Value 0"
        - "Restart-Computer"
      rollback:
        - "Set-ItemProperty -Path HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Lsa -Name LsaCfgFlags -Value 1"
        - "Restart-Computer"

hardware:
  gpu: "NVIDIA GeForce RTX 3070"
  cpu: "AMD Ryzen 7 5800X"
  ram_gb: 32

proton:
  supported: false
  tested_versions: []
  notes: "Anti-cheat blocks Wine/Proton"

sources:
  - "AreWeAntiCheatYet.com (2025-11-16)"
  - "ProtonDB (appid: 1517290)"
  - "Auto-detected via KENL MCP"

safety_score: 95  # AI-validated (Qwen 2.5)
validated: true
schema_version: "1.0.0"
```

---

**End of Roadmap**

**Next Steps:**
1. Review and approve roadmap
2. Create GitHub project board with phases
3. Begin Phase 0 (prerequisites)
4. Schedule weekly check-ins for progress tracking

**ATOM Trail Tag for This Document:**
```yaml
type: planning
intent: document_anticheat_mcp_roadmap
timestamp: 2025-11-16T20:00:00Z
context: "Comprehensive implementation plan for anti-cheat MCP server"
```
