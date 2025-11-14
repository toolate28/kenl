# modules/KENL

**Intent-Driven Gaming & Development on Bazzite Linux**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Status: Production](https://img.shields.io/badge/Status-Production-brightgreen.svg)]()
[![Platform: Bazzite](https://img.shields.io/badge/Platform-Bazzite-blueviolet.svg)]()

> KENL transforms your Bazzite system into a self-documenting gaming and development platform with automatic crash recovery, shareable configurations, and complete audit trails.

Philosophy


Core Belief:

    "AI tools should enhance humans, not replace them. Documentation captures intent so humans remain authoritative, even when AI assists."
    
KENL/SAIF exists because:

    Knowledge is expensive to acquire Years of expertise shouldn't walk out the door when someone quits.

    Intent matters more than actions "What" without "why" breaks when assumptions change.

    Transparency builds trust Customers/users deserve to know what AI generated and what humans reviewed.

    Reproducibility scales expertise Proven solutions should be shareable, not rediscovered every time.

    Confidentiality is real Not everything should be public. Multi-tier system protects customer privacy.

    Rollback is essential Changes should be reversible. Safety net enables experimentation.


---

## The Problem KENL Solves

**HALO wouldn't launch.** EA App auth errors, anti-cheat failures, 174ms network latency. After hours of troubleshooting: *it works*. But how? What fixed it? Can you reproduce it?

**KENL captures the *why* behind every fix**, not just the *what*. If it breaks again, recovery takes minutes instead of hours - because you already documented the solution.

**Real example:** `ATOM-GAMING-001: HALO won't launch → ATOM-RESEARCH-002: ProtonDB suggests GE-Proton 9-20 → ATOM-CFG-003: Applied fix → ATOM-PLAYCARD-006: Created shareable config`

**Result:** Next time HALO breaks, recovery takes <10 minutes instead of hours. Share the Play Card - others skip your pain entirely.

---

## The KENL Builder Mentality

We stand on shoulders, not on toes. KENL doesn't provide better tools - it provides **better access** to the excellent work already done by the Respective Dev/Contributor communities.

### Four Pillars

| Pillar    | Purpose                                      | Example                                                            |
|-----------|----------------------------------------------|--------------------------------------------------------------------|
| **KENL**  | Distrobox tooling for Gaming + Development   | Isolated dev containers, no system deps                            |
| **ATOM**  | Intent logging (the *why*, not just *what*)  | [`claude-landing/RECENT-WORK.md`](./claude-landing/RECENT-WORK.md) |
| **OWI**   | Operating-With-Intent (AI + MCP integration) | Play Cards: shareable game configs                                 |
| **SAGE**  | Just-in-time documentation                   | [`claude-landing/`](./claude-landing/) orientation docs            |

    **Elegant Integration:** Distrobox isolation • JSON-RPC MCP • Pure POSIX shell
    **Minimal Overhead:** ~0.1ms ATOM logging • Static YAML Play Cards • Copy-on-write filesystem
    **Breaking-Change Proof:** Immutable rpm-ostree base • User-space only (`~/.local`) • Atomic GRUB rollback

    *Every KENL operation includes rollback instructions.*

---

## Quick Start

```bash
# Clone and bootstrap
git clone https://github.com/toolate28/kenl.git ~/.kenl && cd ~/.kenl && ./scripts/bootstrap.sh

# Pick your entry point
cd modules/KENL2-gaming    # 🎮 Gaming configs & Play Cards
cd modules/KENL3-dev       # 💻 Development environments
cd modules/KENL0-system    # ⚙️ System operations
cd claude-landing/         # 📍 AI agent orientation (START HERE for Claude Code)
```

---

## Modules

**13 specialized layers** (KENL0-12) that work together:

| Module | Purpose | Module | Purpose |
|--------|---------|--------|---------|
| **KENL0** System | rpm-ostree, firmware | **KENL7** Learning | Guides, cheatsheets |
| **KENL1** Framework | ATOM + SAGE core | **KENL8** Security | GPG, SSH, encryption |
| **KENL2** Gaming | Play Cards, Proton | **KENL9** Library | Game management |
| **KENL3** Development | Distrobox, Claude Code | **KENL10** Backup | Snapshots, recovery |
| **KENL4** Monitoring | Prometheus, Grafana | **KENL11** Media | Streaming, Docker |
| **KENL5** Facades | Visual themes, context | **KENL12** Resources | Downloads, community |
| **KENL6** Social | Sharing, community | | |

**Each module has its own README** - navigate to `modules/KENLX-<name>/` and start there.

---

## What You Get

**🔍 Complete Audit Trails:** ATOM tags track every change with *why*, not just *what*. When crashes happen, you know exactly what broke and how to fix it (85% faster recovery - [validation study](./modules/KENL1-framework/docs/VALIDATION_COMPLETE.md))

**📋 Shareable Play Cards:** Document game configs as YAML ([example  config](./modules/KENL2-gaming/play-cards/battlefield-6-amd-ryzen5-5600h-vega.yaml)). Share with friends - they skip your troubleshooting pain entirely.

**🎨 Visual Context Switching:** Shell themes prevent mistakes (`🎮 KENL2` for gaming, `💻 KENL3` for dev, `⚙️ KENL0` for system ops)

**🪟 Windows 10 EOL Support:** [Migration guides](./windows-support/) for 240M+ PCs affected by Oct 2025 EOL

---

## Documentation

| Audience | Start Here | Description |
|----------|------------|-------------|
| **New Users** | [claude-landing/](./claude-landing/) | Current state, recent work, quick reference |
| **AI Agents** | [claude-landing/CURRENT-STATE.md](./claude-landing/CURRENT-STATE.md) | Environment snapshot + CTF flag validation |
| **Gamers** | [KENL2 Gaming](./modules/KENL2-gaming/) | Play Cards, Proton optimization |
| **Developers** | [KENL3 Dev](./modules/KENL3-dev/) | Distrobox, Claude Code integration |
| **Windows Users** | [windows-support/](./windows-support/) | EOL migration, Surface Pro 4 help |
| **Contributors** | [CONTRIBUTING.md](./CONTRIBUTING.md) | Code style, ARCREF + ADR requirements |

**Real-World Scenarios:** [case-studies/](./case-studies/) - Complete storyboards (BIOS updates, dual-boot,  troubleshooting)

---

## Contributing & Support

**Contributions welcome!** See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines (Conventional Commits, pre-commit hooks, ARCREF + ADR for architectural changes)

**Need help?** [GitHub Issues](https://github.com/toolate28/kenl/issues) • [Discussions](https://github.com/toolate28/kenl/discussions) • [Security](./SECURITY.md) (private reporting)

**License:** MIT - Fork it, modify it, share it. See [LICENSE](./LICENSE)

---

**KENL** = **K**nowledge **E**nhanced **N**avigation **L**ayer

Every operation builds knowledge → Every knowledge entry enables recovery → Every recovery strengthens the system.

**Status**: Production | **Version**: 1.0.0 | **Platform**: Bazzite (Fedora Atomic) | **Made with intent** by Bazza-DX 🎮💻🔐
