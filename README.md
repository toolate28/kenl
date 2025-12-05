# KENL

**Intent-Driven Gaming & Development with SAIF Process**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Status: Production](https://img.shields.io/badge/Status-Production-brightgreen.svg)](https://github.com/toolate28/kenl)
[![Platform: Bazzite](https://img.shields.io/badge/Platform-Bazzite-blueviolet.svg)](https://bazzite.gg/)
[![ATOM: ATOM-DOC-20251126-005](https://img.shields.io/badge/ATOM-DOC--20251126--005-yellow.svg)](./ATOM-REGISTER.md)

---

## 🧭 Choose Your Pathway

**Navigate directly to what you need - no scrolling required:**

| I want to... | Start Here | Time |
|--------------|------------|------|
| 🎮 **Play games on Linux** | [Gaming Pathway](./claude-landing/DOCUMENTATION-PATHWAYS.md#-gaming-pathway) | 15 min |
| 💻 **Develop with AI assistance** | [Development Pathway](./claude-landing/DOCUMENTATION-PATHWAYS.md#-development-pathway) | 20 min |
| 🔧 **Fix system issues** | [Recovery Pathway](./claude-landing/DOCUMENTATION-PATHWAYS.md#-recovery-pathway) | Varies |
| 🚀 **Migrate from Windows** | [Migration Pathway](./claude-landing/DOCUMENTATION-PATHWAYS.md#-migration-pathway) | 1-2 hrs |
| 📖 **Learn the framework** | [Learning Pathway](./claude-landing/DOCUMENTATION-PATHWAYS.md#-learning-pathway) | Self-paced |
| 🤖 **AI Agent on repo** | [Agent Pathway](./claude-landing/DOCUMENTATION-PATHWAYS.md#-agent-pathway) | N/A |

**Full guided setup:** [📚 GETTING-STARTED.md](./GETTING-STARTED.md)

---

## 🚀 Quick Start (30 seconds)

```bash
# 1. Clone KENL
git clone https://github.com/toolate28/kenl.git ~/.kenl && cd ~/.kenl

# 2. Choose your pathway above (terminal or Obsidian - your choice)
# 3. Follow the guided checklist for your goal
```

**PowerShell profile for dynamic banners (optional):**
```powershell
. ~/.kenl/scripts/Install-KenlProfile.ps1
```

---

## What is KENL?

KENL transforms your system into a **self-documenting, intent-driven platform** with:

- 🎮 **Shareable game configurations** (Play Cards)
- 💻 **AI-assisted development** (Claude Code, Ollama/Qwen, MCP)
- 🔧 **Automated system recovery** (BattleMedic)
- 📋 **Complete audit trails** (ATOM tags)
- ↩️ **Rollback safety** (every operation is reversible)

---

## Philosophy

**Core Belief:**

> "AI tools should enhance humans, not replace them. Documentation captures intent so humans remain authoritative, even when AI assists."

**KENL/SAIF exists because:**

- **Knowledge is expensive to acquire** - Years of expertise shouldn't walk out the door when someone quits
- **Intent matters more than actions** - "What" without "why" breaks when assumptions change
- **Transparency builds trust** - Customers/users deserve to know what AI generated and what humans reviewed
- **Reproducibility scales expertise** - Proven solutions should be shareable, not rediscovered every time
- **Confidentiality is real** - Not everything should be public. Multi-tier system protects customer privacy
- **Rollback is essential** - Changes should be reversible. Safety net enables experimentation

---

## The Problem KENL Solves

**HALO wouldn't launch.** EA App auth errors, anti-cheat failures, 174ms network latency. After hours of troubleshooting: *it works*. But how? What fixed it? Can you reproduce it?

**KENL captures the *why* behind every fix**, not just the *what*. If it breaks again, recovery takes minutes instead of hours - because you already documented the solution.

**Real example:** `ATOM-GAMING-001: HALO won't launch → ATOM-RESEARCH-002: ProtonDB suggests GE-Proton 9-20 → ATOM-CFG-003: Applied fix → ATOM-PLAYCARD-006: Created shareable config`

**Result:** Next time HALO breaks, recovery takes <10 minutes instead of hours. Share the Play Card - others skip your pain entirely.

---

## The KENL Builder Mentality

We stand on shoulders, not on toes. KENL doesn't provide better tools - it provides **better access** to the excellent work already done by the Respective Dev/Contributor communities[^1].

### Four Pillars

| Pillar    | Purpose                                      | Example                                                            |
|-----------|----------------------------------------------|--------------------------------------------------------------------|
| **KENL**  | Distrobox tooling for Gaming + Development   | Isolated dev containers, no system deps                            |
| **ATOM**  | Intent logging (the *why*, not just *what*)  | [`claude-landing/RECENT-WORK.md`](./claude-landing/RECENT-WORK.md) |
| **OWI**   | Operating-With-Intent (AI + MCP integration) | Play Cards: shareable game configs                                 |
| **SAGE**  | Just-in-time documentation                   | [`claude-landing/`](./claude-landing/) orientation docs            |

**Technical Guarantees:**
- **Elegant Integration:** Distrobox isolation • JSON-RPC MCP • Pure POSIX shell
- **Minimal Overhead:** ~0.1ms ATOM logging • Static YAML Play Cards • Copy-on-write filesystem
- **Breaking-Change Proof:** Immutable rpm-ostree base • User-space only (`~/.local`) • Atomic GRUB rollback

*Every KENL operation includes rollback instructions.*

#### Architecture Overview

```mermaid
graph TD
    User[👤 User] --> Start[📚 GETTING-STARTED.md]
    Start --> Pathway{Select Pathway}

    Pathway --> |Gaming| KENL2[🎮 KENL2-gaming]
    Pathway --> |Development| KENL3[💻 KENL3-dev]
    Pathway --> |Recovery| BM[🔧 BattleMedic]
    Pathway --> |Migration| KENL0[⚙️ KENL0-system]

    KENL2 --> ATOM[🏷️ ATOM Trails]
    KENL3 --> ATOM
    BM --> ATOM
    KENL0 --> ATOM

    ATOM --> DB[(SQLite + Cloudflare D1)]

    style Start fill:#5865F2,color:#fff
    style ATOM fill:#57F287,color:#000
    style KENL2 fill:#ED4245,color:#fff
    style KENL3 fill:#00AFF4,color:#fff
    style BM fill:#FEE75C,color:#000
    style KENL0 fill:#845EF7,color:#fff
```

---

## Pathways

**Detailed pathway documentation:** [📁 DOCUMENTATION-PATHWAYS.md](./claude-landing/DOCUMENTATION-PATHWAYS.md)

| Pathway | Description | Quick Start |
|---------|-------------|-------------|
| 🎮 [Gaming](./claude-landing/DOCUMENTATION-PATHWAYS.md#-gaming-pathway) | Play Cards, Proton optimization | `./modules/KENL2-gaming/research-game.sh "Game"` |
| 💻 [Development](./claude-landing/DOCUMENTATION-PATHWAYS.md#-development-pathway) | AI-assisted dev with Ollama/Claude | `distrobox create -n kenl-dev` |
| 🔧 [Recovery](./claude-landing/DOCUMENTATION-PATHWAYS.md#-recovery-pathway) | BattleMedic diagnostics | `Import-Module BattleMedic` |
| 🚀 [Migration](./claude-landing/DOCUMENTATION-PATHWAYS.md#-migration-pathway) | Windows → Linux dual-boot | See partition scripts |
| 📖 [Learning](./claude-landing/DOCUMENTATION-PATHWAYS.md#-learning-pathway) | Cheatsheets, case studies | Browse KENL7-learning |
| 🤖 [Agent](./claude-landing/DOCUMENTATION-PATHWAYS.md#-agent-pathway) | AI Agent system integration | Read AI-AGENT-SYSTEM.md |

---

## Modules

**14 specialized layers** (KENL0-13) that work together:

| Module | Purpose | Module | Purpose |
|--------|---------|--------|---------|
| [**KENL0** System](./modules/KENL0-system/) | rpm-ostree, firmware, PowerShell modules | [**KENL7** Learning](./modules/KENL7-learning/) | Guides, cheatsheets |
| [**KENL1** Framework](./modules/KENL1-framework/) | ATOM + SAGE core | [**KENL8** Security](./modules/KENL8-security/) | GPG, SSH, encryption |
| [**KENL2** Gaming](./modules/KENL2-gaming/) | Play Cards, Proton | [**KENL9** Library](./modules/KENL9-library/) | Game management |
| [**KENL3** Development](./modules/KENL3-dev/) | Distrobox, Claude Code, [Ollama/Qwen](./modules/KENL3-dev/guides/OLLAMA-QWEN-LOCAL-AI-SETUP.md), [MCP](./modules/KENL3-dev/guides/MCP-INTEGRATION-GUIDE.md) | [**KENL10** Backup](./modules/KENL10-backup/) | Snapshots, recovery |
| [**KENL4** Monitoring](./modules/KENL4-monitoring/) | Prometheus, Grafana, [ATOM DB](./modules/KENL4-monitoring/docs/ATOM-DATABASE-ARCHITECTURE.md) | [**KENL11** Media](./modules/KENL11-media/) | Streaming, Docker |
| [**KENL5** Facades](./modules/KENL5-facades/) | Visual themes, context | [**KENL12** Resources](./modules/KENL12-resources/) | Downloads, community |
| [**KENL6** Social](./modules/KENL6-social/) | Sharing, community | [**KENL13** IWI](./modules/KENL13-iwi/) | Intent-With-Insight |

**Each module has its own README** - navigate to `modules/KENLX-<name>/` and start there.

#### Module Stack

```mermaid
graph TB
    subgraph Gaming["🎮 Gaming Stack"]
        KENL2[KENL2 Gaming]
        KENL6[KENL6 Social]
        KENL9[KENL9 Library]
    end

    subgraph Development["💻 Development Stack"]
        KENL3[KENL3 Development]
        KENL7[KENL7 Learning]
        KENL8[KENL8 Security]
    end

    subgraph Operations["⚙️ Operations Stack"]
        KENL4[KENL4 Monitoring]
        KENL10[KENL10 Backup]
        KENL11[KENL11 Media]
    end

    subgraph Resources["📦 Resources Stack"]
        KENL5[KENL5 Facades]
        KENL12[KENL12 Resources]
        KENL13[KENL13 IWI]
    end

    subgraph Core["🔧 Core Framework"]
        KENL0[KENL0 System]
        KENL1[KENL1 Framework]
    end

    Gaming --> Core
    Development --> Core
    Operations --> Core
    Resources --> Core

    Core --> Immutable[Bazzite Immutable OS]

    style Core fill:#5865F2,color:#fff
    style Gaming fill:#ED4245,color:#fff
    style Development fill:#00AFF4,color:#fff
    style Operations fill:#57F287,color:#000
    style Resources fill:#FEE75C,color:#000
```

---

## What You Get

**🔍 Complete Audit Trails:** ATOM tags track every change with *why*, not just *what*. When crashes happen, you know exactly what broke and how to fix it (85% faster recovery[^2])

**📋 Shareable Play Cards:** Document game configs as YAML ([example config](./modules/KENL2-gaming/play-cards/games/battlefield-2042.yaml)). Share with friends - they skip your troubleshooting pain entirely.

**🎮 Linux Gaming Ready:** 89.7% of Windows games now run on Linux via Proton[^3], with 15,855+ games rated playable on ProtonDB and 21,694+ Deck Verified games.

**🤖 Local AI Integration:** Run Qwen models locally for zero-cost code assistance ([Ollama/Qwen setup guide](./modules/KENL3-dev/guides/OLLAMA-QWEN-LOCAL-AI-SETUP.md)). Integrate Claude with KENL tools via MCP ([MCP integration guide](./modules/KENL3-dev/guides/MCP-INTEGRATION-GUIDE.md)).

**🛡️ Security-First:** [ATOM database architecture](./modules/KENL4-monitoring/docs/ATOM-DATABASE-ARCHITECTURE.md) prevents malicious Play Cards with schema validation, AI safety scoring, and user approval gates.

**🎨 Visual Context Switching:** Shell themes prevent mistakes (`🎮 KENL2` for gaming, `💻 KENL3` for dev, `⚙️ KENL0` for system ops)

**🪟 Windows 10 EOL Support:** [Migration guides](./modules/KENL0-system/windows-support/) for 240M+ PCs affected by Oct 14, 2025 end of support[^4]

---

## Documentation

**🧭 Full Navigation Hub:** [DOCUMENTATION-PATHWAYS.md](./claude-landing/DOCUMENTATION-PATHWAYS.md)
**📋 Document Index:** [DOCUMENT-INDEX.md](./DOCUMENT-INDEX.md) - 1-line review of all root documents
**👤 User Landing:** [user/](./user/) - Your personal workspace for project-specific files and symlinks

### Quick Links by Audience

| Audience | Start Here | Next Step |
|----------|------------|-----------|
| **Everyone** | [GETTING-STARTED.md](./GETTING-STARTED.md) | [Choose Pathway](./claude-landing/DOCUMENTATION-PATHWAYS.md) |
| **AI Agents** | [AI-AGENT-SYSTEM.md](./claude-landing/AI-AGENT-SYSTEM.md) | [CURRENT-STATE.md](./claude-landing/CURRENT-STATE.md) |
| **Gamers** | [Gaming Pathway](./claude-landing/DOCUMENTATION-PATHWAYS.md#-gaming-pathway) | [KENL2 README](./modules/KENL2-gaming/README.md) |
| **Developers** | [Dev Pathway](./claude-landing/DOCUMENTATION-PATHWAYS.md#-development-pathway) | [KENL3 README](./modules/KENL3-dev/README.md) |
| **Windows Users** | [Migration Pathway](./claude-landing/DOCUMENTATION-PATHWAYS.md#-migration-pathway) | [Partition Scripts](./scripts/windows-partition-scripts/) |
| **Contributors** | [CONTRIBUTING.md](./CONTRIBUTING.md) | [Governance](./governance/) |

### Documentation Structure

| Category | Location | Purpose |
|----------|----------|---------|
| **User Workspace** | [user/](./user/) | Personal project files and symlinks |
| **AI Agent Landing** | [claude-landing/](./claude-landing/) | AI agent orientation documents |
| **Documentation** | [docs/](./docs/) | Standards, guides, analysis, technical docs |
| **Modules** | [modules/](./modules/) | 14 KENL modules (KENL0-13) |
| **Dotfiles** | [dotfiles/](./dotfiles/) | SAIF workflows and system configurations |
| **Case Studies** | [case-studies/](./case-studies/) | Real-world scenarios |
| **Governance** | [governance/](./governance/) | ARCREF + ADR decisions |
| **Scripts** | [scripts/](./scripts/) | Utility scripts and automation |

---

## Key Features

### PowerShell Profile Integration

Install the KENL profile for dynamic banners and current playcard display:

```powershell
# Install profile integration
. ~/.kenl/scripts/Install-KenlProfile.ps1

# After installation, these commands are available:
Show-KenlBanner          # Display current context, module, playcard
Get-CurrentPlaycard      # Show current active playcard
Set-CurrentPlaycard      # Set active playcard
Show-Playcards           # List all available playcards
kenl-switch <n>          # Switch to module (0-13, battlemedic)
kenl-status              # Comprehensive status
```

**Dynamic banner shows:**
- Current platform (Windows, WSL2, Linux, Bazzite)
- Active module context
- Current playcard (game being configured)
- Recent ATOM and SAIF entries

### PowerShell Modules (Windows/Linux)

Cross-platform PowerShell modules for KENL operations:

```powershell
# Install KENL PowerShell modules
.\modules\KENL0-system\powershell\Install-KENL.ps1

# Test network latency
Import-Module KENL.Network
Test-KenlNetwork

# Platform detection
Import-Module KENL
Get-KenlPlatform
```

**PSGallery-ready** with module manifests (.psd1) for publication. See [PowerShell README](./modules/KENL0-system/powershell/README.md).

### ATOM Trail Database

Security-first audit trail system with:
- **Prevention Layer:** Schema validation, AI safety scoring, user approval
- **Execution Layer:** Sandboxed operations (Flatpak/Distrobox)
- **Audit Layer:** Cryptographic integrity (blockchain-style hashing)

```mermaid
sequenceDiagram
    participant User
    participant KENL
    participant Validator
    participant Qwen
    participant Sandbox
    participant DB

    User->>KENL: Apply Play Card
    KENL->>Validator: Validate schema
    Validator->>Validator: Check patterns (rm -rf, sudo, etc)

    alt Validation Failed
        Validator-->>User: ❌ Rejected: Dangerous pattern detected
    else Validation Passed
        Validator->>Qwen: Compute safety score
        Qwen-->>Validator: Score: 0.85 (GOOD)
        Validator->>User: ⚠️ Preview changes + safety score
        User->>KENL: Approve
        KENL->>Sandbox: Execute in Flatpak/Distrobox
        Sandbox-->>KENL: ✅ Success (exit code 0)
        KENL->>DB: Log ATOM trail with hash
        DB-->>User: ✅ ATOM-PLAYCARD-20251114-001
    end
```

See [ATOM Database Architecture](./modules/KENL4-monitoring/docs/ATOM-DATABASE-ARCHITECTURE.md) for complete design.

### Local AI (Ollama + Qwen)

Run AI models locally for 60% of KENL's token strategy (Claude 10%, Perplexity 30%, Qwen 60%):

- Zero API costs
- 100% privacy (code never leaves your machine)
- Offline capability
- Integration with VS Code (Continue.dev) and Claude Desktop (MCP)

See [Ollama/Qwen Setup Guide](./modules/KENL3-dev/guides/OLLAMA-QWEN-LOCAL-AI-SETUP.md).

### Model Context Protocol (MCP)

Enable Claude to interact with KENL tools directly:

- Custom KENL MCP server (rpm-ostree, ujust, ATOM trails)
- Cloudflare integration (Workers, KV, D1, R2)
- GitHub operations (issues, PRs, code search)
- Ollama delegation (offload simple tasks to local AI)

See [MCP Integration Guide](./modules/KENL3-dev/guides/MCP-INTEGRATION-GUIDE.md).

---

## Contributing & Support

**Contributions welcome!** See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines (Conventional Commits, pre-commit hooks, ARCREF + ADR for architectural changes)

**Need help?** [GitHub Issues](https://github.com/toolate28/kenl/issues) • [Discussions](https://github.com/toolate28/kenl/discussions) • [Security](./SECURITY.md) (private reporting)

**License:** MIT - Fork it, modify it, share it. See [LICENSE](./LICENSE)

**Acknowledgments:** This project stands on the shoulders of giants. See [ACKNOWLEDGMENTS.md](./ACKNOWLEDGMENTS.md) for complete attribution of third-party projects and contributors.

---

## References & Citations

[^1]: See [ACKNOWLEDGMENTS.md](./ACKNOWLEDGMENTS.md) for comprehensive attribution of Bazzite, Universal Blue, Valve Proton, and all third-party projects that make KENL possible.

[^2]: Based on internal testing comparing recovery time with vs. without ATOM trail documentation. Formal validation study planned for future release.

[^3]: [Boiling Steam ProtonDB Analysis (2025)](https://boilingsteam.com/) - Community-verified compatibility data showing 89.7% of Windows titles launch on Linux, with 15,855+ games rated playable by at least two ProtonDB reports.

[^4]: [Microsoft Windows 10 Support Lifecycle](https://support.microsoft.com/en-us/windows/making-the-transition-to-a-new-era-of-computing-235e9399-a563-40f8-be4f-fbe109be74c8) - Windows 10 reaches end of support on October 14, 2025. Enterprise studies show ~240M devices still running Windows 10 as of mid-2025 (ControlUp endpoint telemetry).

---

**KENL** = **K**nowledge **E**nhanced **N**avigation **L**ayer

Every operation builds knowledge → Every knowledge entry enables recovery → Every recovery strengthens the system.

**Status**: Production | **Version**: 1.0.0 | **Platform**: Bazzite (Fedora Atomic) | **Made with intent** by Bazza-DX 🎮💻🔐
