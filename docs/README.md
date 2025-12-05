---
title: KENL Documentation Directory
atom: ATOM-DOC-20251205-006
classification: INDEX
status: production
created: 2025-12-05
version: 1.0.0
---

# KENL Documentation Directory

**Purpose:** General documentation organized by category for easy navigation and maintenance.

---

## 📁 Directory Structure

```
docs/
├── README.md           # This file
├── standards/          # Framework standards and conventions
├── guides/             # Installation and integration guides
├── analysis/           # Pattern analysis and optimization
└── technical/          # Technical design documents
```

---

## 📋 Standards (`standards/`)

Framework standards, conventions, and specifications:

| Document | Purpose |
|----------|---------|
| [OWI_FRAMEWORK_OVERVIEW.md](./standards/OWI_FRAMEWORK_OVERVIEW.md) | OWI methodology explanation |
| [OWI_METADATA_STANDARD.md](./standards/OWI_METADATA_STANDARD.md) | OWI metadata format specification |
| [VISUAL-ELEMENTS-STANDARD.md](./standards/VISUAL-ELEMENTS-STANDARD.md) | Emoji, color, Mermaid conventions |
| [NAMING-CONVENTIONS.md](./standards/NAMING-CONVENTIONS.md) | Branch, commit, tag naming rules |
| [SCRIPT-ENVIRONMENT-TAGGING-STANDARD.md](./standards/SCRIPT-ENVIRONMENT-TAGGING-STANDARD.md) | Script header format |

---

## 📖 Guides (`guides/`)

Installation and integration walkthroughs:

| Document | Purpose |
|----------|---------|
| [AI-INTEGRATION-GUIDE.md](./guides/AI-INTEGRATION-GUIDE.md) | Per-module AI usage guide |
| [BAZZITE-DX-IWI-INSTALLATION-SAIF.md](./guides/BAZZITE-DX-IWI-INSTALLATION-SAIF.md) | Complete Bazzite installation |
| [COMPLETE-DEVELOPMENT-SETUP.md](./guides/COMPLETE-DEVELOPMENT-SETUP.md) | Development environment setup |
| [GITHUB-COPILOT-AGENT-BRIEFING.md](./guides/GITHUB-COPILOT-AGENT-BRIEFING.md) | Copilot agent instructions |

---

## 📐 Analysis (`analysis/`)

Pattern analysis and optimization documentation:

| Document | Purpose |
|----------|---------|
| [SAIF-PATTERN-ANALYSIS.md](./analysis/SAIF-PATTERN-ANALYSIS.md) | SAIF command-flag pattern analysis |
| [PROMPT-ANALYSIS-AND-OPTIMIZATION.md](./analysis/PROMPT-ANALYSIS-AND-OPTIMIZATION.md) | AI prompt optimization |
| [ALIGNED-SIGHT.md](./analysis/ALIGNED-SIGHT.md) | Alignment documentation |

---

## 🛠️ Technical (`technical/`)

Technical design documents and proposals:

| Document | Purpose |
|----------|---------|
| [PR-DAY-ZERO-DESIGN.md](./technical/PR-DAY-ZERO-DESIGN.md) | PR workflow design |
| [WORKSPACE.md](./technical/WORKSPACE.md) | Workspace configuration |
| [SAIF-WORKFLOW-PROGRESS-REPORT.md](./technical/SAIF-WORKFLOW-PROGRESS-REPORT.md) | SAIF workflow progress |
| [atom-context-sync-proposal.md](./technical/atom-context-sync-proposal.md) | Context sync proposal |
| [kenl-atom-visual-presentation.md](./technical/kenl-atom-visual-presentation.md) | ATOM visual presentation |
| [kenl-context-sync-atom-directive.md](./technical/kenl-context-sync-atom-directive.md) | Context sync directive |

---

## 🔍 Additional Documentation

### Module-Specific Documentation

Each KENL module has its own documentation:
- See [../modules/](../modules/) directory
- Each module has a `README.md` with module-specific guides

### AI Agent Documentation

AI agent orientation and system integration:
- See [../claude-landing/](../claude-landing/) directory
- Start with [AI-AGENT-SYSTEM.md](../claude-landing/AI-AGENT-SYSTEM.md)

### Case Studies

Real-world scenarios and examples:
- See [../case-studies/](../case-studies/) directory
- Examples: Dual-boot setup, game configuration, Windows migration

### Governance

ARCREF templates and ADR decisions:
- See [../governance/](../governance/) directory
- ARCREF: [../governance/mcp-governance/](../governance/mcp-governance/)
- ADR: [../governance/02-Decisions/](../governance/02-Decisions/)

---

## 🗂️ Finding Documentation

### By Topic

- **Getting Started:** See [../GETTING-STARTED.md](../GETTING-STARTED.md)
- **Navigation Hub:** See [../claude-landing/DOCUMENTATION-PATHWAYS.md](../claude-landing/DOCUMENTATION-PATHWAYS.md)
- **Document Index:** See [../DOCUMENT-INDEX.md](../DOCUMENT-INDEX.md)
- **Contributing:** See [../CONTRIBUTING.md](../CONTRIBUTING.md)
- **Security:** See [../SECURITY.md](../SECURITY.md)

### By Audience

| Audience | Start Here |
|----------|------------|
| **New Users** | [../GETTING-STARTED.md](../GETTING-STARTED.md) |
| **Gamers** | [../modules/KENL2-gaming/](../modules/KENL2-gaming/) |
| **Developers** | [../modules/KENL3-dev/](../modules/KENL3-dev/) |
| **AI Agents** | [../claude-landing/AI-AGENT-SYSTEM.md](../claude-landing/AI-AGENT-SYSTEM.md) |
| **Contributors** | [../CONTRIBUTING.md](../CONTRIBUTING.md) |

---

## 📝 Notes

- Documentation follows ATOM tagging for traceability
- Each document includes frontmatter with metadata
- Version numbers track significant changes
- All paths are relative to repository root

---

**ATOM:** ATOM-DOC-20251205-006
**Version:** 1.0.0
**Last Updated:** 2025-12-05
