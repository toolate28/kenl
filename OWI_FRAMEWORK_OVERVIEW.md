---
project: Bazza-DX SAGE Framework
status: current
version: 2025-11-05
classification: OWI-STANDARD
atom: ATOM-DOC-20251105-028
owi-version: 1.0.0
---

# OWI Framework Overview
**Optimized-With-Intent: The Complete Framework**

## Vision

**OWI** (Optimized-With-Intent) is a comprehensive methodology for transparent, traceable, and intentional system development using AI assistance. It consists of three specialized forks, each targeting a specific domain while maintaining core principles.

---

## The Three Forks

```
                    ┌─────────────────────────┐
                    │   OWI Framework Core    │
                    │  (Metadata + ATOM +     │
                    │   Documentation)        │
                    └───────────┬─────────────┘
                                │
                ┌───────────────┼───────────────┐
                │               │               │
                ▼               ▼               ▼
        ┌───────────────┐ ┌────────────┐ ┌────────────────┐
        │   Gaming-     │ │Configuring-│ │   Building-    │
        │ With-Intent   │ │With-Intent │ │  With-Intent   │
        │   (GWI)       │ │   (CWI)    │ │     (BWI)      │
        └───────────────┘ └────────────┘ └────────────────┘
              │                  │                │
              │                  │                │
      Windows 10 EOL /     System Config    modules/KENL Scaffold
      Gaming-on-Linux      & Optimization   Distribution
```

---

## Fork 1: Gaming-With-Intent (GWI)

### Purpose
Transparent, evidence-based gaming configurations for Linux with Windows 10 EOL migration focus.

### Target Audience
- Windows 10 users facing EOL (Oct 2025)
- Gamers seeking Linux alternatives
- Privacy-conscious gamers
- Technical enthusiasts

### Core Components

#### 1. **Game Profiles (GWI-PROFILE)**
Per-game configuration with full traceability:

```yaml
---
project: Gaming-With-Intent
game: Counter-Strike 2
status: verified
version: 2025-11-05
classification: GWI-PROFILE
atom: ATOM-GWI-20251105-001
owi-version: 1.0.0
tested-on:
  - Bazzite-DX 43
  - AMD Ryzen 5 5600H
  - Radeon Vega Mobile
proton-version: GE-Proton9-15
performance:
  fps-avg: 180
  fps-min: 120
  latency-avg: 25ms
---

# Counter-Strike 2 Configuration

## Launch Options
```bash
PROTON_NO_ESYNC=0 PROTON_NO_FSYNC=0 RADV_PERFTEST=aco mangohud %command%
```

## Network Optimization
- Interface: enp1s0 (primary)
- QoS: Class 0 (real-time)
- Ports: 27015-27050 TCP/UDP

## Evidence
- Benchmark: [link to results]
- ATOM Trail: ATOM-GWI-20251105-001
- MangoHud logs: [attached]
```

#### 2. **Migration Guides (GWI-GUIDE)**
Step-by-step migration from Windows to Linux:

```markdown
---
classification: GWI-GUIDE
game-category: Competitive FPS
difficulty: Medium
time-estimate: 2-3 hours
---

# Windows 10 to Bazzite-DX: Competitive Gaming Guide

## Pre-Migration Checklist
- [ ] Document Windows settings
- [ ] Backup game saves
- [ ] Note peripheral configurations
- [ ] Test Linux live USB

## Expected Performance
- CS2: 90-95% of Windows performance
- Valorant: ❌ Not supported (Vanguard)
- Apex Legends: ✅ EAC Linux support
```

#### 3. **Hardware Compatibility (GWI-HARDWARE)**
Evidence-based hardware testing results:

```yaml
classification: GWI-HARDWARE
hardware: AMD Ryzen 5 5600H + Radeon Vega
status: verified
test-date: 2025-11-05
games-tested: 15
avg-performance: 92% of Windows
```

### GWI Project Structure
```
gaming-with-intent/
├── profiles/
│   ├── competitive-fps/
│   │   ├── cs2-gwi-profile.md
│   │   ├── apex-legends-gwi-profile.md
│   │   └── valorant-status.md (not supported)
│   ├── moba/
│   │   ├── lol-gwi-profile.md
│   │   └── dota2-gwi-profile.md
│   └── simulation/
├── migration-guides/
│   ├── windows-to-bazzite-gwi-guide.md
│   ├── dual-boot-gwi-guide.md
│   └── peripheral-setup-gwi-guide.md
├── hardware/
│   ├── amd-ryzen-gwi-hardware.md
│   ├── intel-core-gwi-hardware.md
│   └── gpu-compatibility-gwi-hardware.md
└── evidence/
    ├── benchmarks/
    ├── atom-trail/
    └── community-reports/
```

---

## Fork 2: Configuring-With-Intent (CWI)

### Purpose
Transparent, rollback-safe system configurations with comprehensive audit trails.

### Target Audience
- System administrators
- Power users
- DevOps engineers
- Immutable Linux users

### Core Components

#### 1. **Configuration Modules (CWI-MODULE)**
Reusable, tested configuration modules:

```yaml
---
project: Configuring-With-Intent
module: Multi-Path Network
status: production
version: 2025-11-05
classification: CWI-MODULE
atom: ATOM-CWI-20251105-001
owi-version: 1.0.0
tested-on:
  - Bazzite-DX 43
  - Fedora 43 Atomic
immutable-safe: true
rollback-tested: true
---

# Multi-Path Network Configuration Module

## Purpose
Configure 3+ network interfaces for load-balanced gaming downloads.

## Pre-requisites
- Multiple physical interfaces
- DHCP-enabled network
- Immutable Linux system

## Implementation
```bash
# Execute configuration
bash ~/.config/cwi/modules/network-multipath.sh

# Verify
bash ~/.config/cwi/modules/network-multipath.sh --verify

# Rollback
bash ~/.config/cwi/modules/network-multipath.sh --rollback
```

## Evidence
- ATOM: ATOM-CWI-20251105-001
- Tests: [passed 15/15]
- Rollback: [verified 3x]
```

#### 2. **System Playbooks (CWI-PLAYBOOK)**
Complete system setup procedures:

```yaml
---
classification: CWI-PLAYBOOK
system: Bazzite-DX Gaming Workstation
components: 12
estimated-time: 3-4 hours
rollback-points: 8
---

# Bazzite-DX Gaming Workstation Setup

## Modules Included
1. Multi-path networking (CWI-MODULE-001)
2. Centralized logging (CWI-MODULE-002)
3. GPU optimization (CWI-MODULE-003)
4. Firewall gaming ports (CWI-MODULE-004)
5. Proton/Wine setup (CWI-MODULE-005)

## Execution Order
[Detailed step-by-step with rollback points]

## ATOM Trail
- ATOM-CWI-20251105-001 through 020
```

#### 3. **Rollback Procedures (CWI-ROLLBACK)**
Tested rollback procedures for each module:

```markdown
---
classification: CWI-ROLLBACK
module: Multi-Path Network
rollback-time: < 5 minutes
data-loss-risk: None
---

# Rollback: Multi-Path Network Module

## Quick Rollback
```bash
bash ~/.config/cwi/modules/network-multipath.sh --rollback
systemctl reboot
```

## Manual Rollback
[Step-by-step instructions]

## Verification
[How to verify rollback success]
```

### CWI Project Structure
```
configuring-with-intent/
├── modules/
│   ├── network/
│   │   ├── multipath-cwi-module.md
│   │   ├── qos-cwi-module.md
│   │   └── firewall-cwi-module.md
│   ├── logging/
│   │   ├── logdy-cwi-module.md
│   │   └── journald-cwi-module.md
│   └── gaming/
│       ├── proton-cwi-module.md
│       └── gpu-cwi-module.md
├── playbooks/
│   ├── gaming-workstation-cwi-playbook.md
│   ├── server-cwi-playbook.md
│   └── developer-cwi-playbook.md
├── rollback/
│   ├── network-rollback-cwi.md
│   ├── logging-rollback-cwi.md
│   └── gpu-rollback-cwi.md
└── evidence/
    ├── test-results/
    ├── atom-trail/
    └── benchmarks/
```

---

## Fork 3: Building-With-Intent (BWI)

### Purpose
Transparent, AI-assisted software development with complete traceability.

### Target Audience
- Open-source developers
- Infrastructure engineers
- Solo developers using AI tools
- Teams adopting AI coding assistants

### Core Components

#### 1. **Code Modules (BWI-CODE)**
AI-generated or AI-assisted code with full attribution:

```python
"""
---
project: Building-With-Intent
module: ATOM Tag Generator
status: production
version: 2025-11-05
classification: BWI-CODE
atom: ATOM-BWI-20251105-001
owi-version: 1.0.0
ai-assistance: Claude Code (Sonnet 3.5)
human-review: Yes
test-coverage: 95%
---

ATOM Tag Generator for SAGE Framework

This module was created with AI assistance (Claude Code)
and reviewed/tested by human developer.

Evidence:
- ATOM: ATOM-BWI-20251105-001
- Tests: tests/test_atom_generator.py
- Review: Approved by toolate28 on 2025-11-05
"""

def generate_atom_tag(tag_type: str) -> str:
    """
    Generate ATOM tag with auto-incrementing counter.

    Args:
        tag_type: Type of ATOM (CFG, GAMING, NETWORK, etc.)

    Returns:
        Formatted ATOM tag: ATOM-{TYPE}-{YYYYMMDD}-{NNN}

    Evidence:
        - Unit tested: test_generate_atom_tag()
        - Integration tested: Full SAGE framework
        - AI-assisted development: Claude Code
    """
    # Implementation here
    pass
```

#### 2. **Architecture Decisions (BWI-ARCREF)**
AI-informed architectural decisions with evidence:

```yaml
---
project: Building-With-Intent
decision: modules/KENL Scaffold Architecture
status: accepted
version: 2025-11-05
classification: BWI-ARCREF
atom: ATOM-BWI-20251105-002
owi-version: 1.0.0
ai-consultation: Claude Code
human-decision: toolate28
alternatives-considered: 3
---

# ARCREF-BWI-001: modules/KENL Scaffold Architecture

## Decision
Use dual governance (ARCREF + ADR) for infrastructure decisions.

## AI Consultation
Claude Code suggested:
1. ARCREF for structural artifacts
2. ADR for narrative decisions
3. Bidirectional linking

## Human Decision
Accepted AI recommendation with modifications:
- Added ATOM tag requirement
- Added rollback procedures
- Added evidence schemas

## Evidence
- AI Discussion: [transcript link]
- ATOM: ATOM-BWI-20251105-002
- Alternatives: [documented in ADR-001]
```

#### 3. **Development Guides (BWI-GUIDE)**
Best practices for AI-assisted development:

```markdown
---
classification: BWI-GUIDE
topic: AI-Assisted Code Review
ai-models: Claude, Copilot, Cursor
experience-level: Intermediate
---

# AI-Assisted Code Review Guide

## Prompt Engineering
Best prompts for code review with AI assistants.

## Evidence Collection
How to document AI assistance properly.

## Attribution
When to credit AI vs claiming authorship.

## Quality Gates
Human review requirements for AI-generated code.
```

### BWI Project Structure
```
building-with-intent/
├── code-modules/
│   ├── python/
│   │   ├── atom-generator-bwi-code.py
│   │   ├── logdy-integration-bwi-code.py
│   │   └── network-monitor-bwi-code.py
│   ├── bash/
│   │   ├── owi-metadata-bwi-code.sh
│   │   └── system-collector-bwi-code.sh
│   └── yaml/
│       └── game-profiles-bwi-code.yaml
├── architecture/
│   ├── kenl-scaffold-bwi-arcref.md
│   ├── owi-framework-bwi-arcref.md
│   └── sage-methodology-bwi-arcref.md
├── guides/
│   ├── ai-code-review-bwi-guide.md
│   ├── prompt-engineering-bwi-guide.md
│   └── attribution-bwi-guide.md
└── evidence/
    ├── ai-transcripts/
    ├── code-reviews/
    └── test-results/
```

---

## Core OWI Principles (All Forks)

### 1. Transparency ✅
Every artifact clearly indicates:
- AI involvement (yes/no)
- AI model used (if applicable)
- Human review status
- Version and date

### 2. Traceability ✅
Every change tracked with:
- ATOM tags (immutable audit trail)
- Git commits (version control)
- Evidence (benchmarks, tests, logs)
- Rollback procedures (safety net)

### 3. Intentionality ✅
Every decision documented:
- Why this approach?
- What alternatives considered?
- What evidence supports it?
- What's the rollback plan?

### 4. Reproducibility ✅
Every configuration tested:
- Automated tests where possible
- Manual verification procedures
- Evidence collection
- Community validation

---

## Cross-Fork Integration

### Scenario: Gaming Workstation Setup

**GWI** provides:
- Game-specific configurations
- Performance benchmarks
- Hardware compatibility

**CWI** provides:
- System configuration modules
- Network optimization
- Logging infrastructure

**BWI** provides:
- Automation scripts
- Configuration generators
- Monitoring tools

**Combined Result:**
A complete, tested, documented gaming workstation setup with:
- Evidence-based game configurations (GWI)
- Rollback-safe system config (CWI)
- AI-generated automation (BWI)
- Full ATOM audit trail (All)

---

## OWI Metadata Across Forks

### Gaming-With-Intent (GWI)
```yaml
classification: GWI-PROFILE|GWI-GUIDE|GWI-HARDWARE
```

### Configuring-With-Intent (CWI)
```yaml
classification: CWI-MODULE|CWI-PLAYBOOK|CWI-ROLLBACK
```

### Building-With-Intent (BWI)
```yaml
classification: BWI-CODE|BWI-ARCREF|BWI-GUIDE
```

### Core OWI (All Forks)
```yaml
classification: OWI-DOC|OWI-STANDARD|OWI-ASSESSMENT|OWI-CHECKLIST|OWI-HANDOFF|OWI-REFERENCE|OWI-VISUAL
```

---

## Community Contributions

### How to Contribute to Each Fork

#### GWI Contributions
1. Test a game on Linux
2. Document configuration with GWI-PROFILE template
3. Include benchmarks and ATOM tag
4. Submit PR with evidence

#### CWI Contributions
1. Create reusable configuration module
2. Test on target system
3. Document rollback procedure
4. Submit PR with test results

#### BWI Contributions
1. Develop with AI assistance
2. Document AI involvement
3. Include tests and reviews
4. Submit PR with attribution

---

## Project Roadmap

### Phase 1: Foundation (Current)
- [x] OWI metadata standard
- [x] ATOM tag system
- [x] Documentation templates
- [ ] Automation scripts (GWI)
- [ ] Module library (CWI)
- [ ] Code templates (BWI)

### Phase 2: Content (Q1 2026)
- [ ] 50+ game profiles (GWI)
- [ ] 20+ config modules (CWI)
- [ ] 10+ code modules (BWI)
- [ ] Community portal launch

### Phase 3: Automation (Q2 2026)
- [ ] Auto-generating GWI profiles
- [ ] CWI module testing framework
- [ ] BWI code generation tools
- [ ] Cloudflare integration

### Phase 4: Community (Q3 2026)
- [ ] Public repository launch
- [ ] Community contributions
- [ ] Evidence database
- [ ] Certification program

---

## Success Metrics

### GWI Success
- Number of verified game profiles
- Windows 10 EOL migration count
- Community-reported success rate
- Hardware compatibility coverage

### CWI Success
- Number of production-ready modules
- Rollback success rate (target: 100%)
- Time savings vs manual config
- Systems deployed with CWI

### BWI Success
- Lines of AI-generated code
- Code review pass rate
- Test coverage percentage
- Attribution compliance rate

---

## Branding & Visual Identity

### Fork Logos

#### GWI (Gaming-With-Intent)
```
┌─────────────────┐
│    🎮 GWI       │
│  Gaming With    │
│    Intent       │
│  Evidence-Based │
│  Performance    │
└─────────────────┘
```

#### CWI (Configuring-With-Intent)
```
┌─────────────────┐
│    ⚙️ CWI       │
│ Configuring     │
│  With Intent    │
│  Rollback-Safe  │
│  Transparency   │
└─────────────────┘
```

#### BWI (Building-With-Intent)
```
┌─────────────────┐
│    🏗️ BWI       │
│  Building With  │
│    Intent       │
│  AI-Assisted    │
│  Traceable Code │
└─────────────────┘
```

---

## Missing Pieces? Let's Review

### Current Coverage ✅

1. **Metadata System** ✅
   - Standard defined
   - Automation scripts created
   - 7 documents tagged

2. **Three Forks Defined** ✅
   - GWI: Gaming focus
   - CWI: Configuration focus
   - BWI: Building/development focus

3. **Core Principles** ✅
   - Transparency
   - Traceability
   - Intentionality
   - Reproducibility

4. **Project Structure** ✅
   - Directory layouts defined
   - Classification types documented
   - Cross-fork integration explained

### Potential Gaps 🤔

#### 1. **Community Platform**
- [ ] Where do users share GWI profiles?
- [ ] How to crowdsource CWI modules?
- [ ] BWI code contribution process?

**Recommendation:** Cloudflare-hosted portal with D1 database.

#### 2. **Certification/Verification**
- [ ] Who verifies GWI game profiles?
- [ ] Who tests CWI module rollbacks?
- [ ] Who reviews BWI code attribution?

**Recommendation:** Tiered verification system (self-reported, community-verified, core-team-certified).

#### 3. **Licensing & Legal**
- [ ] What license for GWI profiles? (CC-BY?)
- [ ] What license for CWI modules? (MIT?)
- [ ] What license for BWI code? (depends on AI model)

**Recommendation:**
- GWI: CC-BY-SA 4.0 (share-alike)
- CWI: MIT (permissive)
- BWI: Per-module (respect AI provider terms)

#### 4. **Monetization/Sustainability**
- [ ] How to fund development?
- [ ] Accept donations/sponsorships?
- [ ] Paid certification/support tier?

**Recommendation:** Start with donations, add premium support tier later.

#### 5. **Multi-Language Support**
- [ ] GWI profiles in multiple languages?
- [ ] CWI module docs translated?
- [ ] BWI guides internationalized?

**Recommendation:** English first, community translations later.

#### 6. **Integration with Existing Ecosystems**
- [ ] ProtonDB integration for GWI?
- [ ] Ansible/Puppet compatibility for CWI?
- [ ] GitHub Copilot patterns for BWI?

**Recommendation:** Document integration paths in framework v1.1.

#### 7. **Quality Assurance**
- [ ] Automated testing for GWI profiles?
- [ ] CI/CD for CWI module verification?
- [ ] Linting/scanning for BWI code?

**Recommendation:** Add QA workflows in Phase 2.

---

## Next Immediate Steps

### 1. Run OWI Bulk Metadata Addition
```bash
cd ~/kenl
./scripts/add-owi-metadata.sh
```

### 2. Create Fork-Specific Repositories
```bash
mkdir -p ~/gaming-with-intent
mkdir -p ~/configuring-with-intent
mkdir -p ~/building-with-intent
```

### 3. Generate First Fork Content
- GWI: Create CS2 game profile
- CWI: Document network multipath module
- BWI: Attribute OWI scripts with BWI-CODE

### 4. Set Up Community Platform (Future)
- Cloudflare Workers + D1
- Public portal at toolated.online
- API for querying profiles/modules

---

**Status:** FRAMEWORK DEFINED
**Version:** 1.0.0
**Adoption Date:** 2025-11-05
**Next Review:** 2025-12-05

**ATOM:** ATOM-DOC-20251105-028
**OWI v1.0.0** - *Optimized-With-Intent Framework*

🦘 **Three forks, one vision: Transparent AI-assisted development!**
