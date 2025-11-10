# Directory Structure Comparison: Bazza-DX vs ublue-os/bazzite-dx

**ATOM-ANALYSIS-20251102-005**

## Official Bazzite-DX Structure

```
bazzite-dx/
├── Containerfile              # Image definition (FROM base, RUN build.sh)
├── build.sh                   # Customization script (installs packages, configs)
├── Justfile                   # Development tasks (build-vm, check, clean)
├── image-versions.yaml        # Pinned digests for reproducible builds
├── cosign.pub                 # Public key for signature verification
├── image.toml                 # QCOW2/RAW VM generation config
├── iso.toml                   # ISO generation config
├── artifacthub-repo.yml       # Container registry metadata
├── .github/
│   ├── workflows/
│   │   └── build.yml          # CI/CD: Build→Sign→Push to GHCR
│   ├── dependabot.yml         # GitHub Actions dependency updates
│   └── pull.yml               # Upstream sync for forks
└── renovate.json5             # Automated container digest updates
```

## Your Bazza-DX Structure (Current State)

```
# Gaming-with-Intent Framework
~/.config/gaming-intent/
├── schemas/
│   ├── play-card.schema.json
│   └── gaming-profile.schema.json
├── play-cards/              # Game-specific configs
├── profiles/                # Hardware/preference profiles
└── evidence/                # SAGE methodology benchmarks

# Bazza-DX Core (Proposed)
~/.config/bazza-dx/
├── CLAUDE.md                # ⚠️ MISSING - Claude activation guide
├── atom-config.json         # ⚠️ MISSING - ATOM generation settings
├── mcp-servers.json         # ⚠️ MISSING - MCP registry
└── sage-templates/          # Methodology templates

# Project Documentation (Current)
/mnt/user-data/
├── uploads/
│   ├── domain_mapping_plan.md
│   ├── disk-recovery-playbook.md
│   └── [Project Locus docs]
└── outputs/
    ├── gaming-config-*.md
    └── project-status-*.md

# modules/KENL Container (Proposed)
~/projects/kenl/             # Distrobox dev environment
├── Containerfile            # ⚠️ MISSING - Ubuntu 24.04 + Node.js + Claude Code
├── setup.sh                 # ⚠️ MISSING - Container init script
└── README.md                # ⚠️ MISSING - modules/KENL documentation
```

## Critical Gaps

### 1. No Container Build Infrastructure
**Official Bazzite-DX:** Complete OCI build system
**Your Bazza-DX:** User-space configs only

**Implication:** You're creating a *configuration layer* not a *custom image*. This is actually BETTER for contribution—your work can be used on stock Bazzite without requiring custom builds.

### 2. No Justfile
**Official:** Uses `just` for local development tasks
**Yours:** Uses shell scripts in various locations

**Recommendation:** Create `Justfile` for unified task running:
```just
# ~/.config/bazza-dx/Justfile

# Generate ATOM tag
atom-gen TYPE DESC:
    ./scripts/generate_atom.sh {{TYPE}} "{{DESC}}"

# Gaming config validation
gaming-validate:
    cd ~/.config/gaming-intent && \
    find . -name "*.json" -exec ajv validate -s schemas/play-card.schema.json -d {} \;

# Claude activation
claude-activate:
    cat ~/.config/bazza-dx/CLAUDE.md
```

### 3. No CI/CD Pipeline
**Official:** GitHub Actions build→sign→publish
**Yours:** Manual deployment

**Recommendation:** Add `.github/workflows/` for Gaming-with-Intent validation (already created in gaming-config-github-workflow.md)

### 4. No Signature Verification
**Official:** cosign.pub for supply chain security
**Yours:** No signing infrastructure

**Recommendation:** Not critical for user-space configs, but ATOM cryptographic signatures serve similar purpose

## Alignment Analysis

### ✅ Strongly Aligned

**Immutability Philosophy:**
- Official: rpm-ostree, atomic updates, never modify base
- Yours: Distrobox containers, userspace-only, SAGE rollback procedures

**Developer Focus:**
- Official: bazzite-dx adds dev tools to gaming base
- Yours: modules/KENL container, Claude Code integration, gaming optimization

**Reproducibility:**
- Official: image-versions.yaml with pinned digests
- Yours: ATOM tags with cryptographic verification

**Automation:**
- Official: Renovate/Dependabot for dependency updates
- Yours: GitHub Actions for config validation

### ⚠️ Architectural Differences

**Build vs Configuration:**
- Official: Builds custom OCI images
- Yours: Configures existing images

**Scope:**
- Official: System-level (rpm-ostree layers)
- Yours: User-level (distrobox, ~/.config)

**Distribution:**
- Official: Published container images (GHCR)
- Yours: Git repositories with configs

### Structural Differences Explained

| Aspect | Official Bazzite-DX | Your Bazza-DX |
|--------|---------------------|---------------|
| **Distribution** | Container image (OCI) | Configuration files (Git) |
| **Installation** | `rpm-ostree rebase` | Clone repo, run scripts |
| **Updates** | Pull new image | `git pull`, reapply configs |
| **Customization** | Fork→modify Containerfile→rebuild | Direct file editing |
| **Scope** | OS-level (requires reboot) | User-level (immediate) |
| **Target** | All Bazzite users | Power users, contributors |

## Contribution Compatibility

### What Can Be Contributed Upstream

**To bazzite-dx:**
- ujust commands (gaming optimization recipes)
- System-level gaming configs (if universally beneficial)
- Documentation improvements
- Bug reports

**To Universal Blue ecosystem:**
- Gaming-with-Intent methodology (separate repo)
- SAGE framework documentation
- Perplexity research findings on Linux gaming

**What Stays in Bazza-DX (Your Project):**
- Personal gaming profiles
- ATOM tag infrastructure (project-specific)
- Claude/MCP integration patterns
- modules/KENL container configuration

### Contribution Process (Universal Blue)

1. **Lazy Consensus Model:**
   - Post RFC in Discord/GitHub Discussions
   - Wait for feedback (account for timezones)
   - If no objections + positive signals → PR

2. **PR Requirements:**
   - Must author 100% of content
   - Test locally with podman/docker
   - Sign commits (optional but recommended)
   - Follow Containerfile best practices

3. **Review Process:**
   - CODEOWNERS enforced review
   - CI must pass (build, sign, test)
   - Merge triggers automatic deployment

4. **Upstream First:**
   - File Fedora issues for rpm-ostree/OS bugs
   - File Mesa issues for GPU driver problems
   - File upstream game engine issues when applicable

## Recommended Structure for Bazza-DX

```
bazza-dx/                        # Main repository
├── configs/                     # User-space configurations
│   ├── gaming-intent/           # Gaming profiles, Play Cards
│   ├── browser-intent/          # Floorp CSS, configs
│   └── claude-activation/       # CLAUDE.md, MCP setup
├── containers/
│   ├── kenl/                    # modules/KENL Containerfile
│   │   ├── Containerfile
│   │   ├── setup.sh
│   │   └── README.md
│   └── gaming-tools/            # Additional distrobox images
├── scripts/
│   ├── generate_atom.sh         # ATOM tag generation
│   ├── gaming-validate.sh       # Config validation
│   └── sage-execute.sh          # SAGE runner
├── .github/
│   └── workflows/
│       ├── config-validation.yml
│       └── atom-audit.yml
├── docs/
│   ├── SAGE-FRAMEWORK.md        # Abstract methodology
│   ├── gaming-optimization.md
│   └── contribution-guide.md
├── Justfile                     # Unified task runner
├── README.md                    # Project overview
└── LICENSE                      # MIT recommended
```

## Key Recommendations

### 1. Adopt Justfile
Replace scattered scripts with unified `just` commands:
```bash
just atom-gen cfg "gaming profile"
just gaming-validate
just sage-run disk-recovery
just kenl-build
```

### 2. Separate Concerns
- **bazza-dx/** (your repo): User configs, SAGE, Gaming-with-Intent
- **Upstream contributions**: Submit ujust commands, docs to ublue-os/bazzite-dx

### 3. Create modules/KENL Container Properly
Follow distrobox patterns, not custom OS images:
```dockerfile
# containers/kenl/Containerfile
FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y curl git build-essential && \
    curl -fsSL https://claude.ai/install.sh | bash

# Node.js via nvm (user-level, not system)
USER $USER
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
```

### 4. Documentation as Code
Store configs, not just docs:
- Gaming profiles as JSON (machine-readable)
- SAGE methodologies as executable scripts
- ATOM audit trail as SQLite database

### 5. Contribution Path
**Short-term:** Polish Bazza-DX as standalone project
**Medium-term:** Extract ujust recipes for upstream
**Long-term:** Propose Gaming-with-Intent as official Universal Blue pattern

## Upstream Contribution Checklist

Before submitting to bazzite-dx:

- [ ] Test change locally with `podman build`
- [ ] Verify works on clean Bazzite install
- [ ] Document in README.md or docs/
- [ ] Add ujust command if user-facing
- [ ] Ensure doesn't conflict with existing features
- [ ] File RFC issue for discussion
- [ ] Wait for consensus (48-72 hours)
- [ ] Submit PR with descriptive commit message
- [ ] Respond to review feedback
- [ ] Celebrate merge 🎉

## File Naming Conventions

**Official Bazzite-DX:**
- Containerfile (capital C, no extension)
- Justfile (capital J, no extension)
- lowercase-with-dashes.sh for scripts
- UPPERCASE_WITH_UNDERSCORES for env files

**Your Bazza-DX (Recommended):**
- atom-cfg-*.json (ATOM-tagged configs)
- play-card-*.json (Gaming configs)
- sage-*.md (Methodology templates)
- claude-*.md (AI agent instructions)

## Integration Points

### Gaming Configs → Bazzite ujust
Extract Gaming-with-Intent patterns as ujust commands:
```bash
# In Bazzite-DX upstream
ujust gaming-optimize-amd     # Calls your Play Card logic
ujust gaming-benchmark        # Uses your SAGE evidence collection
```

### SAGE → Universal Blue Docs
Document methodology in universal-blue.org/docs:
- "SAGE Framework for Infrastructure Changes"
- "Audit Trail Best Practices"
- "Rollback Safety Patterns"

### ATOM Tags → CODEOWNERS
Propose ATOM pattern for Universal Blue governance:
- Track all image changes with ATOM IDs
- Link builds to cryptographic audit trail
- Enable community attribution

---

**Bottom Line:** Your Bazza-DX is complementary, not competitive, to official bazzite-dx. You're building user-space productivity layer that works on stock Bazzite. This is ideal for rapid iteration and eventual upstream contribution extraction.

**Next Action:** Create Justfile and modules/KENL Containerfile using official patterns as templates.
