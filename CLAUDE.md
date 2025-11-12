---
project: Bazza-DX SAGE Framework
status: current
version: 2025-11-12
classification: OWI-DOC
atom: ATOM-DOC-20251112-010
owi-version: 1.0.0
last-updated: 2025-11-12
---

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## First Steps (New Claude Instance)

**Before starting any task:**
1. Read `claude-landing/CURRENT-STATE.md` for current environment snapshot
2. Read `claude-landing/RECENT-WORK.md` for latest session work
3. Run `git log --oneline -10` to see recent commits
4. Check `claude-landing/QUICK-REFERENCE.md` for common paths and commands

**The `claude-landing/` directory contains immediate orientation documents** - always start there when beginning a new session or task.

## Repository Purpose

**kenl** is a scaffold/template repository providing developer infrastructure and governance frameworks for the Bazza-DX ecosystem. It implements the **ATOM** (atomic audit trail) and **SAGE** (System-Aware Guided Evolution) methodologies for traceable, evidence-based system development on immutable Linux distributions (Bazzite-DX/Fedora Atomic).

### The KENL Builder Mentality

**"Putting the amazing work of Universal Blue / Bazzite teams into everyone's hands."**

KENL doesn't provide better tools - it provides **better access** to the excellent work already done by the Bazzite/Universal Blue community. Through documentation, AI assistance, and shareable configurations, every operation:
- Captures **intent** (why, not just what) via ATOM trails
- Provides **rollback instructions** (breaking-change proof)
- Operates in **user-space only** (cannot taint the immutable OS)
- Integrates **elegantly** (minimal CPU/GPU overhead, no system daemons)

See `README.md` for complete explanation of the Four Pillars (KENL, ATOM, OWI, SAGE) and Technical Guarantees.

## Core Architecture

### Repository Structure

The repository is organized into three main sections:

```
kenl/
├── claude-landing/    # START HERE - Immediate orientation docs
├── modules/           # All KENL modules (0-12)
│   ├── KENL0-system/
│   │   └── powershell/  # Windows PowerShell modules
│   ├── KENL1-framework/
│   ├── KENL2-gaming/
│   ├── KENL3-dev/
│   ├── KENL4-monitoring/
│   ├── KENL5-facades/
│   ├── KENL6-social/
│   ├── KENL7-learning/
│   ├── KENL8-security/
│   ├── KENL9-library/
│   ├── KENL10-backup/
│   ├── KENL11-media/
│   └── KENL12-resources/
├── governance/        # Governance artifacts
│   ├── mcp-governance/
│   └── 02-Decisions/
├── scripts/           # Utility scripts
└── ... (docs, CI, etc.)
```

**Key Paths:**
- **Orientation:** `claude-landing/` - START HERE for current state
- All KENL modules: `modules/KENL*`
- PowerShell modules: `modules/KENL0-system/powershell/`
- Governance artifacts: `governance/`
- Scripts: `scripts/`

### Governance Framework

This repository uses a dual governance system:

1. **ARCREF** (Architecture Reference artifacts) - `governance/mcp-governance/ARCREF_TEMPLATE.yaml`
   - Structural format for infrastructure/architecture decisions
   - Required for MCP, cloud, platform, or repo-level changes
   - Includes rollback plans, tests, and traceability

2. **ADR** (Architectural Decision Records) - `governance/02-Decisions/ADR_TEMPLATE.md`
   - Narrative format for decision documentation
   - Links to associated ARCREF IDs
   - Follows status lifecycle: proposed → accepted → deprecated/superseded

**Critical Pattern:** Infrastructure and architectural changes MUST have both an ARCREF artifact AND an ADR document. These provide bidirectional traceability and rollback safety.

### ATOM Tag System

ATOM tags provide cryptographic-grade audit trails for all changes:

**Format:** `ATOM-{TYPE}-{YYYYMMDD}-{COUNTER}`

**Types:**
- `ATOM-MCP-*` - MCP tool invocations
- `ATOM-SAGE-*` - Methodology executions
- `ATOM-CFG-*` - Configuration changes
- `ATOM-DEPLOY-*` - Production deployments
- `ATOM-TASK-*` - Task tracking
- `ATOM-RESEARCH-*` - Research queries
- `ATOM-STATUS-*` - Status reports

ATOM tags should be referenced in commit messages, ARCREF documents, and ADRs for complete traceability.

### Branch Naming Convention

Follow these patterns strictly (enforced by CI):

```
feat/<short-description>     # New features
fix/<short-description>      # Bug fixes
chore/<short-description>    # Infrastructure/tooling
docs/<short-description>     # Documentation only
ci/<short-description>       # CI/CD changes
refactor/<short-description> # Code refactoring
test/<short-description>     # Test additions/changes
```

### Commit Message Format

Use Conventional Commits strictly:

```
<type>: <subject>

[Optional body with details]

ATOM-<TYPE>-<YYYYMMDD>-<NNN>
```

Types: `feat`, `fix`, `chore`, `docs`, `ci`, `refactor`, `test`

## Development Workflow

### Initial Setup

```bash
# Bootstrap development environment
./scripts/bootstrap.sh

# This installs pre-commit hooks and runs initial checks
```

### Pre-commit Validation

All commits must pass pre-commit checks:

```bash
# Run all pre-commit hooks locally
pre-commit run --all-files

# Run specific hook
pre-commit run detect-secrets --all-files
pre-commit run shellcheck --all-files
```

**Pre-commit hooks enforce:**
- Trailing whitespace removal
- End-of-file fixers
- YAML/JSON validation
- Large file detection
- Secret detection (detect-secrets)
- Shellcheck for bash scripts (--severity=style)
- Terraform formatting (if .tf files present)

### Testing

```bash
# Run Python tests (if pytest.ini or tests/ directory exists)
pytest -q

# CI runs this automatically on push/PR to main
```

### Creating a PR

**Checklist (from CONTRIBUTING.md):**
- Branch name follows convention
- Commit messages use Conventional Commits
- Tests added/modified where appropriate
- Documentation updated (README, docs/)
- ARCREF + ADR created for architectural changes
- Pre-commit passes: `pre-commit run --all-files`

**For Architectural Changes:**
1. Create ARCREF artifact in `governance/mcp-governance/` using template
2. Create ADR in `governance/02-Decisions/` using template
3. Link ARCREF ID in ADR and PR description
4. Include rollback plan and test verification

### Building Scaffold Distribution

```bash
# Generate kenl-scaffold.zip for distribution
./make_kenl_scaffold_zip.sh

# This creates a clean scaffold structure without project-specific files
```

## CI/CD Pipeline

### Automated Checks (.github/workflows/ci.yml)

On push/PR to `main`:

1. **pre-commit job** - Runs all pre-commit hooks
2. **CodeQL job** - Security scanning (JavaScript, Python)
3. **tests job** - Runs pytest if tests exist

**Permissions required:**
- `contents: read`
- `packages: read`
- `security-events: write`

### Release Workflow (.github/workflows/release.yml)

Triggered on version tags (`v*.*.*`):

```bash
# Create a release
git tag v1.0.0
git push origin v1.0.0

# CI runs semantic-release automatically
```

Uses semantic-release with GITHUB_TOKEN for automated changelog generation.

## Bazza-DX Ecosystem Context

This repository is part of a larger ecosystem focused on gaming-with-intent on immutable Linux systems:

**Stack:**
- **Base:** Bazzite-DX (Fedora Atomic/rpm-ostree)
- **Gaming:** Proton/GE-Proton, GameScope, MangoHud
- **AI:** Claude (10%), Perplexity (30%), Qwen local (60%)
- **Dev:** modules/KENL distrobox (Ubuntu 24.04 + Claude Code)
- **Cloud:** Cloudflare Workers/D1/KV/R2 (toolated.online)

**Target Use Case:** Windows 10 EOL migration (Oct 2025) - providing evidence-based, rollback-safe gaming configurations for 240M+ affected PCs.

## KENL Module Navigation

When working with specific KENL modules, use these paths:

**System & Framework:**
- `modules/KENL0-system/` - System operations (rpm-ostree, ujust, firmware)
- `modules/KENL1-framework/` - ATOM+SAGE+OWI core framework

**Gaming & Social:**
- `modules/KENL2-gaming/` - Gaming configs, Play Cards, Proton optimization
- `modules/KENL6-social/` - Sharing Play Cards, community features
- `modules/KENL9-library/` - Game library management

**Development:**
- `modules/KENL3-dev/` - Distrobox environments, Claude Code setup
- `modules/KENL4-monitoring/` - Prometheus, Grafana, ATOM analytics
- `modules/KENL7-learning/` - Cheatsheets, guides, learning resources

**Theming & Security:**
- `modules/KENL5-facades/` - Visual themes, context switching, banners
- `modules/KENL8-security/` - GPG, SSH, security tools

**Infrastructure:**
- `modules/KENL10-backup/` - Backups, snapshots, recovery
- `modules/KENL11-media/` - Media streaming, Docker compose
- `modules/KENL12-resources/` - Community downloads, RSS feeds

**Each KENL has:**
- `README.md` - Module overview and usage
- Scripts specific to that layer's purpose
- Configuration files and templates

## Key Documentation Files

Beyond this scaffold, the repository contains project-specific documentation:

- `modules/KENL2-gaming/guides/bazza-dx-one-pager.md` - Executive summary
- `modules/KENL3-dev/claude-code-setup/claude-configuration-guide.md` - MCP setup
- `modules/KENL2-gaming/guides/gaming-config-*.md` - Gaming frameworks
- `AI-INTEGRATION-GUIDE.md` - AI integration patterns (root level)

When working on gaming configs or MCP integrations, consult these documents for context and established patterns.

## Immutable System Considerations

This scaffold targets **immutable** distributions (Fedora Atomic, Bazzite-DX):

- System changes require `rpm-ostree` layered packages
- User-space changes go in `~/.config` or `~/.local`
- All changes must be **rollback-safe** (include rollback instructions in ARCREF)
- ATOM tags track changes for audit trails
- Testing requires verification that changes survive reboot

When making system-level changes, always document the immutable-system-specific approach in the ARCREF rollback plan.

## Security Reporting

For security issues, follow SECURITY.md - report privately before public disclosure.

## MCP Integration Notes

This repository is designed to work with Model Context Protocol (MCP) servers:

**Configured servers (future):**
- Cloudflare MCP (Workers/KV/D1/R2 management)
- Perplexity MCP (research and documentation)
- Ollama MCP (local AI with Qwen models)

When MCP integrations are active, all tool invocations should generate ATOM-MCP-* tags for traceability.
