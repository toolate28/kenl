---
title: KENL Documentation - Start Here
date: 2025-11-18
atom: ATOM-DOC-20251118-010
classification: NAVIGATION-HUB
status: active
---

# KENL Documentation Hub
## Your Gateway to Gaming + Development on Bazzite-DX

Welcome! This is your entry point to KENL documentation. Choose your path based on what you want to accomplish.

---

## 🎯 Quick Navigation

### I Want To...

#### 🎮 **Game on Linux**
→ Start here: [Bazzite-DX Installation Guide](../BAZZITE-DX-IWI-INSTALLATION-SAIF.md)
- Complete installation walkthrough with SAIF compliance
- Hardware optimization for AMD Ryzen + Radeon
- Dual-boot setup with Windows 11
- **Time:** 2-4 hours | **Difficulty:** Intermediate

Related:
- [Gaming Case Studies](../case-studies/README.md) - Real-world scenarios
- [Play Cards Overview](../modules/KENL2-gaming/README.md) - Game configurations

#### 🛠️ **Develop & Contribute**
→ Start here: [Contributing Guide](../CONTRIBUTING.md)
- How to contribute to KENL
- Coding standards and conventions
- AI agent usage (Claude, Copilot)
- **Time:** 30 minutes | **Difficulty:** Beginner

Related:
- [Standards & Conventions](standards/) - Naming, visual elements, scripting
- [Governance](../governance/README.md) - ADRs and ARCREF artifacts
- [AI Integration Guide](../AI-INTEGRATION-GUIDE.md) - Using AI tools effectively

#### 🧠 **Understand the Framework**
→ Start here: [OWI Framework Overview](frameworks/OWI_FRAMEWORK_OVERVIEW.md)
- Operating-With-Intent philosophy
- ATOM audit trail system
- SAGE methodology
- **Time:** 45 minutes | **Difficulty:** Intermediate

Related:
- [SAIF Pattern Analysis](frameworks/SAIF-PATTERN-ANALYSIS.md) - Command-flag patterns
- [Visual Elements Standard](standards/VISUAL-ELEMENTS-STANDARD.md) - Colors, emojis, diagrams

#### 🔧 **Configure My System**
→ Start here: [Configuration Guides](guides/configuration/)
- Network optimization
- Hardware tuning
- Distrobox setup
- **Time:** Varies | **Difficulty:** Intermediate-Advanced

Related:
- [Workspace Setup](reference/WORKSPACE.md) - Development environment
- [Module Documentation](../modules/README.md) - KENL0-13 modules

---

## 📚 Documentation Structure

### By Type

```
docs/
├── 00-START-HERE.md         ← You are here
├── guides/                  ← How-to guides and walkthroughs
│   ├── installation/        ← Installation guides
│   ├── configuration/       ← Configuration guides
│   └── workflows/           ← Workflow documentation
├── standards/               ← Standards and conventions
│   ├── VISUAL-ELEMENTS-STANDARD.md
│   ├── NAMING-CONVENTIONS.md
│   ├── OWI_METADATA_STANDARD.md
│   └── SCRIPT-ENVIRONMENT-TAGGING-STANDARD.md
├── frameworks/              ← Framework documentation
│   ├── OWI_FRAMEWORK_OVERVIEW.md
│   ├── SAIF-PATTERN-ANALYSIS.md
│   └── ATOM-overview.md (coming soon)
└── reference/               ← Reference materials
    ├── WORKSPACE.md
    └── TERMINOLOGY.md (see claude-landing/)
```

### By Audience

**For Users:**
- [Installation Guide](../BAZZITE-DX-IWI-INSTALLATION-SAIF.md) - Get started with Bazzite-DX
- [Case Studies](../case-studies/README.md) - Learn from real-world scenarios
- [Security Policy](../SECURITY.md) - How we handle security

**For Contributors:**
- [Contributing Guide](../CONTRIBUTING.md) - How to contribute
- [Code of Conduct](../CODE_OF_CONDUCT.md) - Community standards
- [Standards](standards/) - Coding and documentation standards

**For AI Agents:**
- [Claude Instructions](../CLAUDE.md) - Claude Desktop/Code
- [Copilot Instructions](../.github/copilot-instructions.md) - GitHub Copilot
- [Agent Landing](../claude-landing/README.md) - Orientation for AI

---

## 🔍 Common Questions

### What is KENL?
KENL is a scaffold/template repository providing developer infrastructure and governance frameworks for the Bazza-DX ecosystem. It implements ATOM (audit trail) and SAGE (guided evolution) methodologies for traceable system development.

**Core Philosophy:** *"AI tools should enhance humans, not replace them. Documentation captures intent so humans remain authoritative."*

### What is SAIF?
SAIF (System-Aware Intelligent Flags) is a pattern for command execution where each operation generates a trackable flag indicating completion state. Example:
```bash
Command: kenl-network-optimize
Result: SAIF-NETWORK-OPTIMIZE-20251118-001
```

### What is ATOM?
ATOM (Atomic Audit Trail) is a methodology for logging intent, not just actions. Every significant operation gets an ATOM tag:
```
ATOM-{TYPE}-{YYYYMMDD}-{NNN}
```
Types: DOC, CFG, DEPLOY, RESEARCH, STATUS, REFACTOR

### What platforms does KENL support?
- **Primary:** Bazzite-DX (Fedora Atomic 43 + Universal Blue)
- **Testing:** Windows 11 (for Win10 EOL migration)
- **Target:** Windows 10 users migrating to Linux gaming

---

## 🚀 Quick Start Paths

### Path 1: Gaming (Windows → Linux Migration)
```
1. Read: Installation Guide
   └→ BAZZITE-DX-IWI-INSTALLATION-SAIF.md
2. Review: Case Study RWS-06 (Complete Dual-Boot Gaming Setup)
   └→ case-studies/RWS-06-COMPLETE-DUAL-BOOT-GAMING-SETUP.md
3. Configure: Gaming Optimization
   └→ modules/KENL2-gaming/
4. Play: Use Play Cards for game configs
   └→ modules/KENL2-gaming/play-cards/
```

### Path 2: Development (Contributing)
```
1. Read: Contributing Guide
   └→ CONTRIBUTING.md
2. Review: Standards
   └→ docs/standards/NAMING-CONVENTIONS.md
3. Setup: AI Tools
   └→ CLAUDE.md OR .github/copilot-instructions.md
4. Create: Your first PR
   └→ governance/02-Decisions/ADR_TEMPLATE.md
```

### Path 3: Understanding (Framework Deep-Dive)
```
1. Read: OWI Framework Overview
   └→ docs/frameworks/OWI_FRAMEWORK_OVERVIEW.md
2. Study: SAIF Pattern Analysis
   └→ docs/frameworks/SAIF-PATTERN-ANALYSIS.md
3. Review: Real-World Scenarios
   └→ case-studies/
4. Explore: Modules
   └→ modules/README.md
```

---

## 📖 External Resources

### Community
- [Bazzite GitHub](https://github.com/ublue-os/bazzite) - Upstream project
- [Universal Blue](https://universal-blue.org/) - Immutable Linux ecosystem
- [ProtonDB](https://www.protondb.com/) - Game compatibility database

### Tools
- [Claude Desktop](https://claude.ai/download) - AI assistant
- [GitHub Copilot](https://github.com/features/copilot) - AI coding assistant
- [Obsidian](https://obsidian.md/) - Knowledge management (optional)

### Documentation
- [Fedora Silverblue Docs](https://docs.fedoraproject.org/en-US/fedora-silverblue/) - Immutable OS concepts
- [rpm-ostree Docs](https://coreos.github.io/rpm-ostree/) - Package layering
- [Distrobox Docs](https://distrobox.it/) - Container isolation

---

## 🆘 Getting Help

### I'm stuck with...

**Installation issues:**
- Check: [Case Studies](../case-studies/) for similar scenarios
- Review: [Hardware Documentation](../claude-landing/HARDWARE.md)
- Ask: Open an issue on GitHub

**Contributing questions:**
- Read: [Contributing Guide](../CONTRIBUTING.md)
- Check: [Agent Instructions](../.github/copilot-instructions.md)
- Ask: Open a discussion on GitHub

**Framework confusion:**
- Review: [Terminology](../claude-landing/TERMINOLOGY.md)
- Study: [OWI Framework](frameworks/OWI_FRAMEWORK_OVERVIEW.md)
- Ask: Open a discussion on GitHub

**Security concerns:**
- Review: [Security Policy](../SECURITY.md)
- Report: Follow responsible disclosure process
- Don't: Publicly disclose vulnerabilities

---

## 📊 Documentation Health

**Last Updated:** 2025-11-18
**ATOM Tag:** ATOM-DOC-20251118-010
**Status:** Active (v1.0)

**Coverage:**
- Root-level docs: 28 files
- Subdirectories: 39 files
- Total: 67 documentation files

**Registry:**
- Location: `.kenl/document-registry.json`
- Coverage: Updating to 100%

---

## 🔄 Navigation Tips

### Obsidian-Wall Pattern
This documentation uses the "Obsidian-wall" pattern:
1. **Entry point** - Start here (this document)
2. **Contextual links** - Next steps embedded in content
3. **Footnote depth** - Additional context scroll-accessible
4. **Decision points** - Clear action-oriented choices
5. **SAIF flags** - Trackable completion markers

### Reading Strategy
- **Skim first** - Get the overview
- **Follow links** - Dive into what matters to you
- **Ignore footnotes** - Unless you need details
- **Use ATOM tags** - Track your progress
- **Ask questions** - Open issues/discussions

---

## ✅ Success Metrics

You'll know you're on the right track when:
- [ ] You can find any document in <3 clicks
- [ ] You understand ATOM, SAIF, and OWI concepts
- [ ] You've completed at least one guided path
- [ ] You know where to ask for help
- [ ] You can contribute back to KENL

---

**Next:** Choose your path above and start your journey!

**ATOM-DOC-20251118-010**
