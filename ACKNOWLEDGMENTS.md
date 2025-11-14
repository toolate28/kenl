# Acknowledgments

**KENL** stands on the shoulders of giants. This project would not exist without the exceptional work of these communities, projects, and contributors.

---

## Core Infrastructure

### Universal Blue / Bazzite

**The foundation of KENL's immutable gaming platform.**

- **Project**: [Bazzite](https://bazzite.gg/) and [Universal Blue](https://universal-blue.org/)
- **License**: Apache 2.0 (Universal Blue), MIT (Bazzite components)
- **Contribution**: Atomic desktop images, gaming optimizations, hardware enablement, ujust recipes
- **Why it matters**: Bazzite provides production-ready, immutable Fedora images optimized for gaming. Their work on ProtonGE integration, MangoHud configs, and Steam Deck optimization saved thousands of hours of configuration work. Universal Blue's image-based workflow makes KENL's rollback-safe approach possible.
- **Maintainers**: Kyle Gospodnetich (@KyleGospo), Jorge Castro (@castrojo), and the Universal Blue community
- **Attribution**: KENL2 gaming configs build directly on Bazzite's hardware profiles and kernel tuning

### Fedora Project

**The stable, open-source foundation.**

- **Project**: [Fedora Linux](https://fedoraproject.org/)
- **License**: Multiple open-source licenses (GPL, MIT, Apache)
- **Contribution**: rpm-ostree, Fedora Atomic Desktop (Silverblue/Kinoite), SELinux policies
- **Why it matters**: Fedora's commitment to immutable infrastructure and atomic updates enables KENL's breaking-change-proof design. Their upstream-first approach ensures KENL benefits from cutting-edge kernel and Mesa drivers for gaming performance.
- **Attribution**: KENL0 system operations rely entirely on Fedora's rpm-ostree and ostree infrastructure

---

## Gaming Enablement

### Valve Software

**Making Windows gaming viable on Linux.**

- **Project**: [Proton](https://github.com/ValveSoftware/Proton), Steam Client, Steam Deck
- **License**: Custom (Proton includes Wine, DXVK, vkd3d-proton under various licenses)
- **Contribution**: Proton compatibility layer, Steam Play, SteamOS, Steam Deck hardware
- **Why it matters**: Proton achieved ~90% Windows game compatibility on Linux (per ProtonDB 2025 data). Without Valve's investment in DXVK, vkd3d-proton, and Proton itself, gaming on Linux would still be niche. KENL's gaming modules are only possible because of this work.
- **Statistics**: 89.7% of Windows titles launch on Linux (Boiling Steam, 2025), 15,855+ games rated playable on ProtonDB, 21,694+ Deck Verified games
- **Attribution**: KENL2 Play Cards document Proton version recommendations per game

### GloriousEggroll (Thomas Crider)

**Community Proton builds with cutting-edge patches.**

- **Project**: [Proton-GE](https://github.com/GloriousEggroll/proton-ge-custom)
- **License**: Mixed (Wine, DXVK, custom patches)
- **Contribution**: GE-Proton builds with fixes for games not yet patched in official Proton
- **Why it matters**: GE-Proton often resolves compatibility issues days or weeks before official Proton releases. Many KENL Play Cards recommend specific GE-Proton versions for game fixes.
- **Attribution**: KENL2 gaming configs reference GE-Proton versions for specific game compatibility

### ProtonDB

**Crowdsourced compatibility data.**

- **Project**: [ProtonDB](https://www.protondb.com/)
- **License**: N/A (community database)
- **Contribution**: Peer-reviewed compatibility reports, launch parameter recommendations, configuration tweaks
- **Why it matters**: ProtonDB's community-verified data prevents hours of trial-and-error testing. KENL Play Cards reference ProtonDB ratings and user-submitted fixes.
- **Attribution**: KENL2 Play Cards link to ProtonDB entries for each game

---

## Development Tools

### Anthropic

**AI assistance for development and documentation.**

- **Project**: [Claude](https://www.anthropic.com/claude), Model Context Protocol (MCP)
- **License**: Proprietary (Claude API), Open-source (MCP SDK - MIT)
- **Contribution**: Claude Code agent, Claude 3.5 Sonnet model, MCP protocol for tool use
- **Why it matters**: Claude assisted with KENL's PowerShell module development, documentation generation, and ATOM trail design. MCP enables Claude to interact with Cloudflare Workers, local filesystems, and custom KENL tooling.
- **Attribution**: CLAUDE.md instructs Claude instances on KENL's conventions. `claude-landing/` provides orientation for cold-start Claude sessions.

### Alibaba Cloud (Qwen Team)

**Local, open-source AI models.**

- **Project**: [Qwen](https://github.com/QwenLM/Qwen) (Qwen 2.5, Qwen 3)
- **License**: Apache 2.0
- **Contribution**: Open-weights language models optimized for local deployment
- **Why it matters**: Qwen enables KENL's 60% local AI strategy (Claude 10%, Perplexity 30%, Qwen 60%). Running Qwen locally via Ollama provides offline AI assistance without API costs or privacy concerns.
- **Attribution**: KENL's token strategy documented in `CLAUDE.md` and `claude-landing/CURRENT-STATE.md`

### Ollama

**Local AI model deployment made simple.**

- **Project**: [Ollama](https://ollama.com/)
- **License**: MIT
- **Contribution**: CLI for running LLMs locally, model registry, GPU acceleration
- **Why it matters**: Ollama makes local Qwen deployment trivial (`ollama run qwen3:8b`). KENL's local AI workflows rely on Ollama for offline code assistance and documentation generation.
- **Attribution**: Planned for KENL3 development environments

---

## Monitoring & Observability

### MangoHud

**In-game performance overlay.**

- **Project**: [MangoHud](https://github.com/flightlessmango/MangoHud)
- **License**: MIT
- **Contribution**: Vulkan/OpenGL overlay for FPS, GPU/CPU metrics, frametime graphs
- **Why it matters**: MangoHud provides real-time performance data for KENL Play Card validation. KENL gaming configs include MangoHud presets for AMD hardware optimization.
- **Attribution**: KENL2 gaming configs include MangoHud YAML presets

### Prometheus & Grafana

**Metrics and dashboards.**

- **Project**: [Prometheus](https://prometheus.io/), [Grafana](https://grafana.com/)
- **License**: Apache 2.0
- **Contribution**: Time-series metrics, alerting, visualization
- **Why it matters**: Planned for KENL4 monitoring - ATOM trail metrics, system performance baselines, gaming session analytics
- **Attribution**: Planned integration in KENL4

---

## Cloud Infrastructure

### Cloudflare

**Edge computing and data storage.**

- **Project**: [Cloudflare Workers](https://workers.cloudflare.com/), KV, D1, R2
- **License**: Proprietary (service), Open-source (Wrangler CLI)
- **Contribution**: Serverless edge functions, key-value store, SQL database, object storage
- **Why it matters**: KENL's planned MCP integration with Cloudflare enables Play Card sharing, ATOM trail backups, and community configs hosted at toolated.online
- **Attribution**: Planned for KENL6 social features (Play Card sharing)

---

## Community & Documentation

### GamingOnLinux

**News, reviews, and community.**

- **Project**: [GamingOnLinux](https://www.gamingonlinux.com/)
- **Contribution**: Linux gaming news, compatibility tracking, community forums
- **Why it matters**: GamingOnLinux provides real-world validation of gaming trends and hardware compatibility. KENL's gaming configs reference GamingOnLinux articles for hardware-specific optimizations.

### r/linux_gaming, r/Bazzite, r/SteamDeck

**Community support and troubleshooting.**

- **Platforms**: Reddit communities
- **Contribution**: Peer support, configuration sharing, bug workarounds
- **Why it matters**: Community-sourced fixes often appear on Reddit before official documentation. KENL Play Cards incorporate solutions from these communities.

---

## Tooling & Utilities

### Distrobox

**Container-based development environments.**

- **Project**: [Distrobox](https://github.com/89luca89/distrobox)
- **License**: GPL-3.0
- **Contribution**: Podman/Docker container integration with host system
- **Why it matters**: Distrobox enables KENL3 development environments without polluting the immutable OS. Python venvs, Node.js versions, and build tools live in containers, preserving rollback safety.
- **Attribution**: KENL3 development configs use Distrobox for Ubuntu 24.04 + Claude Code setup

### Pre-commit Framework

**Git hook management.**

- **Project**: [pre-commit](https://pre-commit.com/)
- **License**: MIT
- **Contribution**: Automated code quality checks, secret detection, linting
- **Why it matters**: KENL's pre-commit hooks prevent secrets from being committed, enforce Shellcheck compliance, and validate YAML/JSON configs before push.
- **Attribution**: `.pre-commit-config.yaml` uses detect-secrets, Shellcheck, trailing-whitespace hooks

---

## Hardware Partners (Indirect)

### AMD

**Open-source GPU drivers.**

- **Contribution**: AMDGPU kernel driver, Mesa RADV Vulkan driver, ROCm compute stack
- **Why it matters**: AMD's open-source Linux drivers enable day-one gaming support on Fedora/Bazzite. KENL2 hardware configs target AMD Ryzen 5 5600H + Vega graphics specifically because AMD's driver quality on Linux is exceptional.
- **Attribution**: KENL2 hardware profiles (AMD Ryzen 5 5600H + Vega optimization)

### Intel

**Open-source contributions.**

- **Contribution**: Intel Arc GPU drivers, kernel networking optimizations, power management
- **Why it matters**: Intel's upstream-first approach benefits all Linux users. KENL's network optimization scripts leverage Intel's TCP stack improvements.

---

## Standards & Protocols

### POSIX Shell

**Cross-platform scripting foundation.**

- **Why it matters**: KENL's ATOM and SAGE frameworks use pure POSIX shell (`#!/bin/sh`) to ensure compatibility across bash, dash, and zsh. This eliminates bashisms and ensures scripts work on any Unix-like system.

### JSON-RPC / Model Context Protocol (MCP)

- **Project**: [Model Context Protocol](https://github.com/anthropics/model-context-protocol)
- **License**: MIT
- **Contribution**: Standardized protocol for AI <-> tool communication
- **Why it matters**: MCP enables Claude to interact with Cloudflare, Prometheus, and custom KENL tools without brittle API integrations.

---

## Inspiration & Prior Art

### NixOS

**Declarative, reproducible system configuration.**

- **Project**: [NixOS](https://nixos.org/)
- **License**: MIT
- **Contribution**: Declarative config management, atomic rollbacks, reproducible builds
- **Why it matters**: NixOS pioneered atomic system configuration. KENL's ATOM trail and SAGE manifest draw inspiration from Nix's approach to capturing *intent* in configuration files.

### Ansible

**Infrastructure as code.**

- **Project**: [Ansible](https://www.ansible.com/)
- **License**: GPL-3.0
- **Contribution**: Idempotent playbooks, declarative configuration
- **Why it matters**: Ansible's idempotent design influenced KENL's approach to ujust recipes and system configuration scripts.

---

## Individual Contributors

### Matthew Ruhnau (@toolate28)

**Creator and maintainer of KENL.**

- **Contributions**: ATOM/SAGE/OWI framework design, PowerShell modules, Play Card format, documentation
- **Hardware**: AMD Ryzen 5 5600H + Vega system (reference platform for KENL2 gaming configs)

### Claude Code (AI Assistant)

**Documentation, code generation, and refactoring.**

- **Contributions**: PowerShell module scaffolding, ATOM tag design, governance templates (ARCREF/ADR), `claude-landing/` orientation docs
- **Attribution**: AI-generated code is marked with `# AI-assisted` comments where applicable

---

## Data Sources & Statistics

### Steam Hardware & Software Survey

- **Source**: [Steam Survey](https://store.steampowered.com/hwsurvey)
- **Data used**: Windows 10 vs. Windows 11 adoption rates (35.2% vs. 59.9% as of 2025)

### Boiling Steam (ProtonDB Analysis)

- **Source**: [Boiling Steam](https://boilingsteam.com/)
- **Data used**: 89.7% Windows game compatibility on Linux (2025)

### ControlUp (Enterprise Windows 10 EOL Study)

- **Source**: ControlUp endpoint telemetry
- **Data used**: 50% of enterprise devices still on Windows 10 (mid-2025)

### Microsoft

- **Source**: Official Windows 10 support lifecycle
- **Data used**: Windows 10 end of support date (October 14, 2025), Extended Security Updates program

---

## License Compliance

KENL is released under the **MIT License**. All third-party components listed above retain their original licenses. Where KENL incorporates code or configuration from other projects, those files include SPDX headers indicating the source and license.

**Example:**
```bash
#!/bin/bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2025 Matthew Ruhnau
# Based on: Bazzite gaming optimizations (Apache 2.0)
```

---

## Contributing Acknowledgments

If you contribute to KENL, your name/handle will be added here. See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

**Current contributors:**
- Matthew Ruhnau (@toolate28) - Creator, maintainer
- Claude Code (Anthropic) - AI-assisted development and documentation

---

## How to Acknowledge KENL

If KENL helped you, consider:

1. **Starring the repo**: [github.com/toolate28/kenl](https://github.com/toolate28/kenl)
2. **Sharing Play Cards**: Submit your configs to help others
3. **Contributing documentation**: Improve guides, fix typos, add examples
4. **Reporting issues**: Help identify bugs and compatibility issues
5. **Citing KENL** in your projects:

```markdown
This project uses KENL for intent-driven gaming and development.
See: https://github.com/toolate28/kenl
```

---

## Contact

- **Issues/Questions**: [GitHub Issues](https://github.com/toolate28/kenl/issues)
- **Discussions**: [GitHub Discussions](https://github.com/toolate28/kenl/discussions)
- **Security**: See [SECURITY.md](./SECURITY.md)

---

**Thank you** to everyone who makes Linux gaming and open-source development possible. KENL is a love letter to this community.

**ATOM**: ATOM-DOC-20251114-001
**Last Updated**: 2025-11-14
