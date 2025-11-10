---
project: kenl - Developer Infrastructure & ATOM+SAGE Framework
status: production
version: 1.0.0
classification: OWI-DOC
atom: ATOM-DOC-20251107-014
owi-version: 1.0.0
---

# kenl

**Developer infrastructure scaffold + ATOM+SAGE intent-driven operations framework**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Status: Production](https://img.shields.io/badge/Status-Production-brightgreen.svg)]()
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)]()

## Overview

**kenl** provides two complementary systems for professional software development:

1. **Developer Infrastructure Scaffold**: Production-ready governance templates, CI/CD pipelines, and development tooling for any project
2. **ATOM+SAGE Framework**: Intent-driven operations with validated 7-minute crash recovery

Both are fully open source (MIT licensed) and designed for professional deployment.

---

## Quick Start

```bash
# Clone repository
git clone https://github.com/toolate28/kenl.git
cd kenl

# Bootstrap development environment
./scripts/bootstrap.sh

# OPTIONAL: Install ATOM+SAGE framework
cd atom-sage-framework
./install.sh
```

---

## What's Included

### 1. Developer Infrastructure Scaffold

Professional-grade templates and automation for:

- **Governance**: ARCREF (architectural reference artifacts) + ADR (decision records)
- **CI/CD**: GitHub Actions with pre-commit hooks, CodeQL security scanning
- **Templates**: Issue templates, PR templates, contribution guidelines
- **Security**: Dependabot, secret detection, security policy
- **Documentation**: Metadata standards, OWI framework documentation

**Use this to**: Bootstrap new projects with enterprise-grade governance and automation.

### 2. ATOM+SAGE Framework

Intent-driven operations with proven crash recovery:

- **7-minute recovery**: Validated real-world recovery from catastrophic failures
- **100% intent preservation**: Full context reconstruction from minimal input
- **Zero dependencies**: Pure POSIX shell core
- **Self-validating**: CTFWI methodology for AI assistant validation

**Use this to**: Make all operations traceable, all crashes recoverable.

**Location**: `./atom-sage-framework/` - [Read more →](./atom-sage-framework/README.md)

---

## Governance System

kenl implements a **dual-documentation governance pattern**:

### ARCREF (Architecture Reference Artifacts)
**File**: `mcp-governance/ARCREF_TEMPLATE.yaml`

Structured format for infrastructure/architecture decisions:
- Technical specifications with rollback plans
- Test verification and dependencies
- Migration steps and monitoring

**When to use**: MCP changes, cloud deployments, platform upgrades, repository-level infrastructure

### ADR (Architectural Decision Records)
**File**: `02-Decisions/ADR_TEMPLATE.md`

Narrative format for decision documentation:
- Context and problem statement
- Decision rationale and consequences
- Links to ARCREF artifacts

**When to use**: Major architectural decisions, technology choices, process changes

### First Production Instance

See **ARCREF::BWI::ATOM-SAGE::001** + **ADR-001** for the ATOM+SAGE framework launch - demonstrates the governance pattern in action.

---

## ATOM+SAGE Framework

### What It Does

Captures **why** operations happen (not just what), enabling:

- **85% faster recovery**: 7 minutes vs 30-60 minutes traditional
- **87% less input**: 147 characters vs ~1,200 characters required
- **Minimal user burden**: "Continue from crash" is sufficient input
- **Complete context**: Reconstructs all parallel workflows automatically

### Real-World Validation

**Scenario**: Complete system crash during Bazzite Linux configuration
- **Lost**: 4 concurrent Claude Code conversations
- **User input**: 147 characters (fits in half a tweet)
- **Recovery time**: 7 minutes
- **Result**: 100% context restored, all tasks completed

[Read full validation case study →](./atom-sage-framework/docs/VALIDATION_COMPLETE.md)

### How It Works

```bash
# Create traceable operations
atom STATUS "Starting database migration project"
atom CFG "Configure PostgreSQL connection pool"
atom DEV "Implement user authentication module"
atom TASK "TODO: Add rate limiting"

# After crash: Instant recovery
atom-analytics --recovery
# Shows: all 4 contexts, pending tasks, last status, next action
```

### Specialized Applications

  **ATOM-SEC**: AI security testing with forensic audit trails
  **ATOM-GOV**: MCP governance with policy-as-code
  **ATOM-EOL**: Windows 10 EOL migration framework

[Explore all applications →](./atom-sage-framework/README.md)

---

## Repository Structure

```
kenl/
├── atom-sage-framework/          # Intent-driven operations framework
│   ├── README.md                 # Framework documentation
│   ├── install.sh                # Zero-dependency installer
│   ├── docs/                     # Guides and validation studies
│   ├── examples/                 # Runnable demonstrations
│   ├── analytics/                # Advanced analysis tools
│   └── forks/                    # Specialized applications
│       ├── ATOM-SEC/             # AI security & red-teaming
│       ├── ATOM-GOV/             # MCP governance
│       └── ATOM-EOL/             # Windows 10 EOL migration
├── mcp-governance/               # ARCREF artifacts
│   ├── ARCREF_TEMPLATE.yaml      # Template for new artifacts
│   └── ARCREF-ATOM-SAGE-001.yaml # Example: ATOM+SAGE launch
├── 02-Decisions/                 # ADR documents
│   ├── ADR_TEMPLATE.md           # Template for new decisions
│   └── ADR-001-ATOM-SAGE-LAUNCH.md # Example: ATOM+SAGE decision
├── scripts/                      # Automation and tooling
│   ├── bootstrap.sh              # Development environment setup
│   ├── add-owi-metadata.sh       # Documentation metadata
│   └── owi-report.sh             # Documentation index generation
├── .github/                      # GitHub automation
│   ├── workflows/                # CI/CD pipelines
│   └── ISSUE_TEMPLATE/           # Issue templates
├── CONTRIBUTING.md               # Contribution guidelines
├── SECURITY.md                   # Security policy
└── README.md                     # This file
```

---

## For Contributors

### Development Workflow

1. **Fork and clone** the repository
2. **Create a branch** following naming conventions:
   - `feat/description` - New features
   - `fix/description` - Bug fixes
   - `docs/description` - Documentation
   - `refactor/description` - Code refactoring

3. **Make changes** with proper commit messages:
   ```
   type: subject line

   Body with details

   ATOM-TYPE-YYYYMMDD-NNN
   ```
   Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`

4. **Run pre-commit checks**:
   ```bash
   pre-commit run --all-files
   ```

5. **Create pull request** with:
   - Clear description
   - ARCREF + ADR for architectural changes
   - Tests and documentation updates

See [CONTRIBUTING.md](./CONTRIBUTING.md) for detailed guidelines.

### Architectural Changes

For infrastructure, MCP, or architectural changes:

1. Create **ARCREF artifact** in `mcp-governance/`
2. Create **ADR document** in `02-Decisions/`
3. Link them bidirectionally
4. Include rollback plan and tests
5. Reference in PR description

Example: See `ARCREF-ATOM-SAGE-001.yaml` + `ADR-001-ATOM-SAGE-LAUNCH.md`

---

## For Users

### Using the Scaffold

To bootstrap a new project with kenl's governance infrastructure:

```bash
# Option 1: Fork this repository
# Option 2: Extract scaffold
./make_kenl_scaffold_zip.sh
# Creates kenl-scaffold.zip with clean template structure
```

### Using ATOM+SAGE

To add intent-driven operations to your workflow:

```bash
cd atom-sage-framework
./install.sh

# Start using
atom STATUS "Your first traceable operation"
atom-analytics --summary
```

[Complete getting started guide →](./atom-sage-framework/docs/GETTING_STARTED.md)

---

## Documentation

### Core Documentation
- **[CLAUDE.md](./CLAUDE.md)**: Guidance for Claude Code instances
- **[OWI Framework](./OWI_FRAMEWORK_OVERVIEW.md)**: Complete methodology specification
- **[OWI Metadata Standard](./OWI_METADATA_STANDARD.md)**: Documentation system

### ATOM+SAGE Documentation
- **[Framework README](./atom-sage-framework/README.md)**: Overview and quick start
- **[Validation Study](./atom-sage-framework/docs/VALIDATION_COMPLETE.md)**: 7-minute recovery forensics
- **[Getting Started](./atom-sage-framework/docs/GETTING_STARTED.md)**: 15-minute tutorial

### Governance Examples
- **[ARCREF-ATOM-SAGE-001](./mcp-governance/ARCREF-ATOM-SAGE-001.yaml)**: Technical specification
- **[ADR-001](./02-Decisions/ADR-001-ATOM-SAGE-LAUNCH.md)**: Decision narrative

---

## CI/CD & Automation

### GitHub Actions Workflows

**`.github/workflows/ci.yml`**: Continuous integration
- Pre-commit hooks (trailing whitespace, YAML validation, secrets detection)
- CodeQL security analysis (JavaScript, Python)
- Automated testing (pytest when tests exist)

**`.github/workflows/release.yml`**: Release automation
- Semantic versioning
- Automated changelog generation
- Triggered on version tags (`v*.*.*`)

### Pre-commit Hooks

Enforced on every commit:
- Trailing whitespace removal
- End-of-file fixers
- YAML/JSON validation
- Large file detection
- Secret detection (detect-secrets)
- Shellcheck for bash scripts

**Run manually**:
```bash
pre-commit run --all-files
```

---

## Community & Support

- **Issues**: [GitHub Issues](https://github.com/toolate28/kenl/issues) for bugs and feature requests
- **Discussions**: [GitHub Discussions](https://github.com/toolate28/kenl/discussions) for questions
- **Pull Requests**: Contributions welcome! See [CONTRIBUTING.md](./CONTRIBUTING.md)
- **Security**: Report vulnerabilities per [SECURITY.md](./SECURITY.md)

---

## Ecosystem Context

kenl is part of the **Bazza-DX** ecosystem focused on gaming-with-intent on immutable Linux systems:

- **Base**: Bazzite-DX (Fedora Atomic/rpm-ostree)
- **Gaming**: Proton/GE-Proton, GameScope, MangoHud
- **Dev**: KENL distrobox (Ubuntu 24.04 + Claude Code)
- **Cloud**: Cloudflare Workers/D1/KV/R2
- **Methodology**: OWI Framework (Gaming-With-Intent, Configuring-With-Intent, Building-With-Intent)

**Target use case**: Windows 10 EOL migration (Oct 2025) providing evidence-based, rollback-safe gaming configurations.

---

## License

MIT License - see [LICENSE](./LICENSE) for details.

Both the scaffold and ATOM+SAGE framework are fully open source.

---

## Acknowledgments

- **OWI Framework**: Methodology for transparent, traceable system development
- **SAGE Framework**: System-Aware Guided Evolution principles
- **Community**: Contributors and early adopters

---

## Quick Links

| Resource | Link |
|----------|------|
| **ATOM+SAGE Framework** | [./atom-sage-framework/](./atom-sage-framework/) |
| **Getting Started** | [./atom-sage-framework/docs/GETTING_STARTED.md](./atom-sage-framework/docs/GETTING_STARTED.md) |
| **Validation Study** | [./atom-sage-framework/docs/VALIDATION_COMPLETE.md](./atom-sage-framework/docs/VALIDATION_COMPLETE.md) |
| **Contributing** | [CONTRIBUTING.md](./CONTRIBUTING.md) |
| **Governance Templates** | ARCREF: [mcp-governance/](./mcp-governance/) / ADR: [02-Decisions/](./02-Decisions/) |
| **Security Policy** | [SECURITY.md](./SECURITY.md) |
| **Issue Tracking** | [GitHub Issues](https://github.com/toolate28/kenl/issues) |

---

**Version**: 1.0.0
**Status**: Production Ready
**Last Updated**: 2025-11-06
**ATOM**: ATOM-DOC-20251107-014
