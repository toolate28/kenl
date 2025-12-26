# ClaudeNPC Server Suite: AI-Powered Minecraft NPCs

**Document Type:** Orientation & Task Routing
**Last Updated:** 2025-12-27 07:45
**Status:** Active - Phase 1 Pending Authorization
**Current Phase:** Delivery complete (v1.0.0), Phase 1 implementation ready

---

## Current State: What You Need to Know First

**Last verified:** 2025-12-27 07:45
**System status:** Framework delivered, implementation not started

### What's Working
- Complete framework delivered (65+ files, 220+ pages documentation)
- PowerShell modules tested and functional (Display, Logger, Safety, Config)
- Setup.ps1 automated installer ready (5-phase installation)
- Git repository clean, all v1.0.0 changes committed
- Documentation comprehensive and branded
- SAIF counter at 3

### What's Not Working / Unknown
- **Minecraft server NOT YET INSTALLED** (Setup.ps1 available but not run)
- **Java installation unknown** (may need to install)
- **Citizens plugin not installed** (part of Setup.ps1)
- **ClaudeNPC plugin NOT BUILT** (Phase 1 deliverable)
- **Claude API key not configured** (user needs to provide)
- **Minecraft client installation unknown** (user needs Java Edition)

### Critical Alerts
- **DO NOT START PHASE 1 WITHOUT USER AUTHORIZATION**
- User must review NEXT_STAGE_READY.md before proceeding
- Claude API key required (user must provide from Anthropic account)
- Estimated 2-3 days for Phase 1 (single working NPC proof of concept)
- Java 21+ required (Setup.ps1 can install if missing)

---

## What We're Actually Building

**Surface level:** Minecraft plugin that adds AI-powered NPCs using Claude API

**Actual purpose:** Proof of concept for "GitLab City" vision - a multi-tenant SaaS platform that visualizes Git repositories as explorable Minecraft buildings with AI NPCs that explain code.

**This is NOT:**
- A complete production-ready plugin (Phase 1 is proof of concept only)
- A full GitLab City implementation (that's Phase 2+)
- Ready to deploy (needs testing, verification, iteration)
- A simple chat bot (it's a spatial code exploration platform)

**This is ACTUALLY:**
- **Phase 1**: Build ONE working NPC with Claude API integration
- **Phase 2**: Expand to GitVerse world with multiple NPCs and features
- **Future**: Multi-tenant SaaS platform (GitLab City vision)

### Success Looks Like (Phase 1 Only)

**Technical Criteria:**
- ✅ Minecraft server runs stable on localhost:25565
- ✅ Single NPC responds to player messages via Claude API
- ✅ Conversations flow naturally (3+ message exchanges)
- ✅ NPC remembers context within conversation
- ✅ Memory persists across player disconnect/reconnect
- ✅ Multiple players can talk to NPC simultaneously (separate conversations)
- ✅ No crashes during 1 hour of continuous testing
- ✅ Response time < 5 seconds average
- ✅ Code is clean, commented, and understandable

**Verification Required:**
```bash
# Server stability test
Run server for 1 hour, monitor console for errors

# Conversation test
Have 5-10 message exchange, verify context maintained

# Memory test
Disconnect, reconnect after 5 minutes, verify NPC remembers

# Multi-player test
Two clients simultaneously, verify no context bleeding

# Performance test
Measure response times across 20+ messages
```

---

## System Environment

### Verified Present
- Windows 11 (confirmed via environment)
- Git (repository operational)
- PowerShell 5.1+ (modules tested)
- Project files complete (setup/, scripts/, modules/, docs/)
- Framework documentation (220+ pages verified)

### Installed But Unconfigured
- Unknown - needs verification:
  - Java JDK 21+ (required for Minecraft server)
  - Minecraft Java Edition client (user needs to play/test)
  - Port 25565 availability (default Minecraft port)

### Missing or Requires User Provision
- Claude API key (user must provide from https://console.anthropic.com/)
- Minecraft server installation (Setup.ps1 will handle)
- PaperMC server JAR (Setup.ps1 will download)
- Citizens plugin (Setup.ps1 will install)
- ClaudeNPC plugin (Phase 1 deliverable - we build this)

### Directory Structure
```
C:\Users\iamto\.kenl\claude-landing\claudenpc-server-suite\
├── REMOTE: setup/                           # Automated installer
│   ├── Setup.ps1                            # Main installation wizard
│   ├── modules/                             # PowerShell modules
│   │   ├── Display.psm1                     # UI and formatting
│   │   ├── Logger.psm1                      # Logging system
│   │   ├── Safety.psm1                      # Safety checks
│   │   └── Config.psm1                      # Configuration management
│   └── config/                              # Configuration templates
├── REMOTE: scripts/                         # Server utilities
│   ├── Start-Server.ps1                     # Server startup
│   ├── Stop-Server.ps1                      # Graceful shutdown
│   ├── Backup-World.ps1                     # World backup
│   └── Monitor-Performance.ps1              # Performance monitoring
├── REMOTE: docs/                            # Documentation
│   ├── README_BRANDED.md                    # Project overview
│   ├── QUICKSTART_BRANDED.md                # Quick setup guide
│   ├── IMPLEMENTATION_PROMPTS.md            # Advanced features guide
│   ├── CLAUDE_INSTANCE_GUIDE.md             # New instance onboarding
│   └── [15+ other documentation files]
├── REMOTE: *.md                             # Project documentation
│   ├── NEXT_STAGE_READY.md                  # ⭐ Phase 1 implementation guide
│   ├── IMPLEMENTATION_ORDER.md              # Phase breakdown
│   ├── PROJECT_STATE.md                     # Project status
│   └── bump-md-*.md                         # This methodology
└── LOCAL: C:\MinecraftServer\               # Target installation directory
    ├── [Created by Setup.ps1]
    ├── server.jar                           # PaperMC server (downloaded)
    ├── plugins/                             # Plugin directory
    │   ├── Citizens.jar                     # NPC framework
    │   └── ClaudeNPC.jar                    # Our plugin (Phase 1 builds this)
    ├── start.bat                            # Server startup script
    └── worlds/                              # Minecraft worlds
```

### Dependencies

**Phase 0 (Verification):**
```powershell
# Check Java installation
java -version
# Required: Java 21+ (Setup.ps1 can install if missing)

# Check port availability
Test-NetConnection -ComputerName localhost -Port 25565
# Should fail if port is free (good)

# Verify PowerShell version
$PSVersionTable.PSVersion
# Required: 5.1+
```

**Phase 1 (Installation - Setup.ps1 handles these):**
- PaperMC server 1.21.3+ (downloaded automatically)
- Citizens plugin (downloaded automatically)
- Vault plugin (optional, for permissions)
- LuckPerms plugin (optional, for permissions)

**Phase 1 (Development - we need to install):**
- IntelliJ IDEA Community Edition (or VS Code with Java extensions)
- Maven or Gradle (for building ClaudeNPC plugin)
- Git (already present)

**Phase 1 (User provides):**
- Claude API key from https://console.anthropic.com/
- Minecraft Java Edition client (to test)

---

## Your Mission

**Single focused task:** Phase 1 - Build ClaudeNPC Core Plugin (proof of concept)

**DO NOT START without:**
1. ✅ User has reviewed NEXT_STAGE_READY.md
2. ✅ User explicitly authorizes "Let's start Phase 1"
3. ✅ User provides Claude API key
4. ✅ User confirms Java is installed (or authorizes Setup.ps1 to install)

**Once authorized, Phase 1 deliverables:**

**Step 1: Environment Setup (30-45 minutes)**
```powershell
# Run automated installer
cd setup
.\Setup.ps1

# Expected outcomes:
- Java installed (if missing)
- PaperMC server downloaded
- Citizens plugin installed
- Server configured and tested
- Server starts successfully on localhost:25565
```

**Step 2: ClaudeNPC Plugin Development (1-2 days)**
```
Minimum viable features:
1. NPC Detection - Hook into Citizens, detect player right-clicks
2. Claude API Client - Send message to Claude, get response
3. Basic Conversation - Display Claude's response to player
4. Simple Memory - Remember player name + last 5 messages
5. Configuration - API key and model settings in config.yml

Project structure:
ClaudeNPC/
├── src/main/java/com/claudenpc/
│   ├── ClaudeNPC.java              # Main plugin class
│   ├── NPCListener.java            # Handle NPC interactions
│   ├── ClaudeAPIClient.java        # API communication
│   ├── ConversationManager.java    # Manage conversations
│   ├── MemoryStore.java            # Store NPC memories
│   └── ConfigManager.java          # Handle config.yml
├── src/main/resources/
│   ├── plugin.yml                  # Plugin metadata
│   └── config.yml                  # Configuration file
└── pom.xml                         # Maven build file
```

**Step 3: Testing (CRITICAL - verify everything)**
```
Test 1: Basic Interaction
→ Create NPC, right-click, type message
→ Verify NPC responds via Claude
→ Check console for errors

Test 2: Conversation Flow
→ 5-10 message exchange
→ Verify context maintained
→ Responses make sense

Test 3: Memory Persistence
→ Talk to NPC, disconnect for 5 minutes
→ Reconnect and talk again
→ Verify NPC remembers previous conversation

Test 4: Multiple Players
→ Two players talk to same NPC
→ Verify separate conversations
→ No context bleeding between players

Test 5: Stability
→ Run server for 1 hour with periodic testing
→ Monitor memory usage, response times
→ No crashes or degradation
```

### Verification Criteria

Before claiming Phase 1 completion:
- [ ] Setup.ps1 completed successfully
- [ ] Minecraft server running stable on localhost:25565
- [ ] ClaudeNPC plugin built and loaded without errors
- [ ] Single NPC responds to messages via Claude API
- [ ] All 5 test scenarios pass
- [ ] Response time < 5 seconds average (measure across 20+ messages)
- [ ] No crashes during 1 hour stability test
- [ ] Code is clean, commented, and documented
- [ ] Git commits are clean with proper messages
- [ ] Passes Tomorrow's Test: "Could another dev understand and extend this?"

### Interaction Guidance

**User will provide:**
- Authorization to start Phase 1
- Claude API key (from Anthropic console)
- Clarifications on NPC behavior when ambiguous
- Go/no-go decisions on scope changes

**You should provide:**
- Step-by-step progress updates
- Clear verification at each step
- Honest assessment of what works vs what doesn't
- Questions when requirements unclear
- No completion claims without verification evidence

---

## What You Have (Use These, Don't Explain Them)

**Active Frameworks:**
- **bump.md**: High-mass context routing (you're reading this now)
- **SAIF**: Staged approach, currently at counter 3, Phase 1 next
- **ATOM**: Tracking tags for traceability
- **Tomorrow's Test**: Will claims stand up to review?

**Guiding Principles:**
- **Proof of concept before features**: One working NPC beats ten broken NPCs
- **Verification before advancement**: Test passes before claiming complete
- **Simplicity over cleverness**: Code should be boring and obvious
- **Documentation is deliverable**: Not an afterthought
- **Phase discipline**: Complete Phase 1 before Phase 2

**Verification Patterns:**
```bash
# Before claiming server works:
netstat -an | grep 25565        # Port actually listening?
java -jar server.jar --version  # Server JAR functional?
ls plugins/                     # Plugins actually installed?

# Before claiming plugin works:
javac [files]                   # Code actually compiles?
java -jar ClaudeNPC.jar         # JAR builds successfully?
grep ERROR logs/latest.log      # No errors in server log?

# Before claiming NPC works:
# (Actual in-game test required, no shortcuts)

# Tomorrow's Test:
"If user shows this to another Minecraft plugin developer tomorrow,
will they understand the code and be able to extend it?"
```

---

## Work Sessions

### 2025-12-27 07:45 - Phase 1 Preparation & bump.md Creation

**Context:** Creating project-specific bump.md for ClaudeNPC to enable clear Phase 1 orientation when user authorizes implementation.

**Actions Taken:**
- Created this bump.md file with complete Phase 1 context
- Documented current state honestly (framework delivered, implementation not started)
- Laid out Phase 1 mission clearly (proof of concept, not full product)
- Defined verification criteria explicitly
- Clarified what's working vs unknown vs missing

**Critical Alerts Set:**
- DO NOT START without user authorization
- User must review NEXT_STAGE_READY.md first
- Claude API key required before proceeding
- Java installation must be verified

**Outcomes:**
- ✅ Project-specific bump.md created
- ✅ Phase 1 scope clearly defined
- ✅ Verification criteria explicit
- ✅ Authorization gates documented
- ⏳ Awaiting user authorization to proceed

**Verification:**
- [x] bump.md structure follows template
- [x] Current state assessment is honest
- [x] Phase 1 mission is clear and focused
- [x] Success criteria are measurable
- [ ] User has reviewed and authorized (pending)

**Next Steps:**
1. Await user authorization for Phase 1
2. Once authorized: Run Setup.ps1 (Step 1)
3. Develop ClaudeNPC plugin (Step 2)
4. Execute full test suite (Step 3)
5. Verify all success criteria met
6. Update SAIF counter when Phase 1 complete

**Tomorrow's Test Status:**
Documentation is clear and actionable. A fresh Claude instance could read this and understand exactly what Phase 1 entails, what the current state is, and what authorization is required before proceeding.

---

### 2025-12-12 03:05 - ClaudeNPC Server Suite v1.0.0 Delivery

**Context:** Completed comprehensive delivery package - framework, documentation, automation scripts.

**Actions Taken:**
- Created 65+ file framework structure
- Developed PowerShell modules (Display, Logger, Safety, Config)
- Built 5-phase automated installer (Setup.ps1)
- Generated 220+ pages of documentation
- Created implementation guides and prompts
- Packaged ClaudeNPC-Server-Suite-v1.0.0-BRANDED.zip
- Updated SAIF counter 2 → 3

**Git Commits:**
```
7c1a916 - feat: complete ClaudeNPC Server Suite v1.0.0 delivery package
b557a02 - chore: update Claude and Obsidian workspace settings
```

**Deliverables:**
```
✅ Setup wizard (Setup.ps1 with 5 phases)
✅ PowerShell modules (Display, Logger, Safety, Config)
✅ Server utility scripts (Start, Stop, Backup, Monitor)
✅ Documentation suite (220+ pages)
✅ Implementation guides (IMPLEMENTATION_ORDER.md, NEXT_STAGE_READY.md)
✅ Advanced feature prompts (5 major features documented)
✅ Branded professional documentation
✅ Complete package (ZIP file)
```

**Outcomes:**
- ✅ Framework delivery complete
- ✅ All files committed to git
- ✅ Remote repository synchronized
- ✅ Documentation comprehensive
- ✅ NEXT_STAGE_READY.md created for Phase 1 guidance
- ✅ SAIF counter properly incremented

**Verification:**
- [x] 65+ files verified in repository
- [x] Git state clean after commits
- [x] Remote synchronized (pushed)
- [x] Documentation reviewed for quality
- [x] SAIF counter at 3

**Phase Transition:**
Framework delivery (v1.0.0) → Phase 1 implementation (pending authorization)

---

## For Other Instances: How to Use This Document

**When you wake up:**
1. Read this bump.md FIRST (primary orientation)
2. Verify Current State section matches reality
3. Check "Your Mission" - understand current phase
4. Review latest Work Session - immediate context
5. **CRITICAL**: Check for authorization gates (DO NOT START without approval)

**Before starting Phase 1:**
```
⚠️ AUTHORIZATION REQUIRED ⚠️

User MUST:
1. Review NEXT_STAGE_READY.md
2. Explicitly say "Let's start Phase 1" or equivalent
3. Provide Claude API key
4. Confirm Java installation or authorize Setup.ps1 to install

DO NOT proceed without these confirmations.
```

**When appending work:**
- Add new session at TOP of Work Sessions
- Use timestamp: YYYY-MM-DD HH:MM
- Mark status: ✅ done, ⏳ in progress, ⚠️ issues, ❌ blocked
- Include verification evidence (test output, screenshots, console logs)
- Apply Tomorrow's Test before completion claims

**When uncertain:**
- Apply Tomorrow's Test: "Will this stand up to external review?"
- Check momentum: Too many iterations without verification? Re-verify foundation.
- Ask user for clarification (especially for scope/business logic)
- Mark unknowns explicitly (better than fabricating)
- Use Peripheral Vision Protocol (flag anomalies even outside current task)

**When you hit these patterns, STOP:**
- Starting Phase 1 without authorization
- Adding features beyond minimum viable (proof of concept first!)
- Claiming completion without running full test suite
- Assuming Java/Minecraft installed without verification
- Skipping verification steps ("it should work")
- Moving to Phase 2 before Phase 1 verified complete

**Integration with systemwide bump.md:**
- This is PROJECT-SPECIFIC bump.md for ClaudeNPC
- Systemwide bump.md: `../bump.md` (claude-landing root)
- Both work together: systemwide for orientation, project for specifics
- ATOM/SAIF/CTF frameworks apply across both

**Key documentation:**
```
ESSENTIAL FOR PHASE 1:
- This file (bump.md) - Primary orientation
- NEXT_STAGE_READY.md - Phase 1 detailed guide
- IMPLEMENTATION_ORDER.md - Phase breakdown

REFERENCE DURING DEVELOPMENT:
- IMPLEMENTATION_PROMPTS.md - Advanced features (Phase 2+)
- CLAUDE_INSTANCE_GUIDE.md - New instance onboarding
- README_BRANDED.md - Project overview
- QUICKSTART_BRANDED.md - Quick setup reference

SYSTEMWIDE CONTEXT:
- ../bump.md - KENL system orientation
- ../AI-AGENT-SYSTEM.md - Framework details
- ../CURRENT-STATE.md - Environment snapshot
```

**Verification commands:**
```powershell
# Pre-Phase 1 verification
java -version                           # Java installed?
Test-NetConnection -Port 25565          # Port available?
Test-Path setup/Setup.ps1               # Setup script present?

# During Phase 1
Get-Process java                        # Server running?
Test-NetConnection -Port 25565          # Server listening?
Get-Content logs/latest.log -Tail 50    # Recent log entries?
ls plugins/                             # Plugins loaded?

# Phase 1 completion verification
# (In-game testing required - no command shortcuts)
# Must verify all 5 test scenarios pass
```

---

**Status:** Phase 1 preparation complete, awaiting user authorization
**Next Verification:** User review of NEXT_STAGE_READY.md and explicit Phase 1 authorization
**Authorization Gate:** DO NOT PROCEED without user approval, API key, and Java verification
**Tomorrow's Test:** Fresh instance can orient and understand Phase 1 requirements clearly ✅
