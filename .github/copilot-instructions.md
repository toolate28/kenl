# GitHub Copilot Instructions for KENL Repository

## Repository Purpose

**KENL** is a scaffold/template repository providing developer infrastructure and governance frameworks for the Bazza-DX ecosystem. It implements the **ATOM** (atomic audit trail) and **SAGE** (System-Aware Guided Evolution) methodologies for traceable, evidence-based system development on immutable Linux distributions (Bazzite-DX/Fedora Atomic).

**Core Philosophy:**
> "AI tools should enhance humans, not replace them. Documentation captures intent so humans remain authoritative, even when AI assists."

**The KENL Builder Mentality:** We provide better access to excellent work already done by the Bazzite/Universal Blue community through documentation, AI assistance, and shareable configurations.

## Key Architecture Concepts

### Four Pillars System

1. **KENL** - Distrobox tooling for Gaming + Development (isolated dev containers, no system deps)
2. **ATOM** - Intent logging (the *why*, not just *what*) via audit trails
3. **OWI** - Operating-With-Intent (AI + MCP integration, shareable Play Cards)
4. **SAGE** - Just-in-time documentation (claude-landing/ orientation docs)

### Technical Guarantees

Every KENL operation must ensure:
- **Elegant Integration:** Distrobox isolation • JSON-RPC MCP • Pure POSIX shell
- **Minimal Overhead:** ~0.1ms ATOM logging • Static YAML Play Cards • Copy-on-write filesystem
- **Breaking-Change Proof:** Immutable rpm-ostree base • User-space only (`~/.local`) • Atomic GRUB rollback
- **Rollback Instructions:** Every operation includes rollback instructions

## Repository Structure

```
kenl/
├── .github/              # GitHub configuration, workflows, templates
├── claude-landing/       # START HERE - AI agent orientation documents
├── modules/              # 14 KENL modules (KENL0-13)
│   ├── KENL0-system/     # System operations, PowerShell modules
│   ├── KENL1-framework/  # ATOM + SAGE core
│   ├── KENL2-gaming/     # Play Cards, Proton configs
│   ├── KENL3-dev/        # Distrobox, Claude Code, Ollama/Qwen, MCP
│   ├── KENL4-monitoring/ # Prometheus, Grafana, ATOM DB
│   └── ...               # KENL5-13 (see README.md for full list)
├── governance/           # Governance artifacts
│   ├── mcp-governance/   # ARCREF templates and artifacts
│   └── 02-Decisions/     # ADR (Architectural Decision Records)
├── scripts/              # Utility scripts (bash, PowerShell)
├── docs/                 # Additional documentation
└── case-studies/         # Real-world scenarios (RWS-*.md)
```

**Key Entry Points:**
- `CLAUDE.md` - Primary instructions for Claude Code agent
- `README.md` - Project overview and quick start
- `CONTRIBUTING.md` - Contribution guidelines
- `claude-landing/CURRENT-STATE.md` - Current environment snapshot
- `claude-landing/QUICK-REFERENCE.md` - Common paths and commands

## Setup and Development

### Initial Setup

```bash
# Clone and bootstrap
git clone https://github.com/toolate28/kenl.git
cd kenl
./scripts/bootstrap.sh  # Installs pre-commit hooks, runs initial checks
```

### Pre-commit Validation

**REQUIRED:** All commits must pass pre-commit checks before pushing.

```bash
# Run all pre-commit hooks
pre-commit run --all-files

# Run specific hooks
pre-commit run detect-secrets --all-files
pre-commit run shellcheck --all-files
```

**Pre-commit hooks enforce:**
- Trailing whitespace removal
- End-of-file fixers
- YAML/JSON validation
- Large file detection (max 500KB)
- Secret detection (detect-secrets)
- Shellcheck for bash scripts (--severity=style)
- Terraform formatting (if .tf files present)

### Build Commands

```bash
# Generate kenl-scaffold.zip for distribution
./make_kenl_scaffold_zip.sh

# This creates a clean scaffold structure without project-specific files
```

### Testing

```bash
# Run Python tests (if pytest.ini or tests/ directory exists)
pytest -q

# Test PowerShell modules (on Windows)
Import-Module ./modules/KENL0-system/powershell/KENL.psm1
Import-Module ./modules/KENL0-system/powershell/KENL.Network.psm1
Test-KenlNetwork  # Network diagnostics
Get-KenlPlatform  # Platform information
```

## Coding Conventions and Standards

### Branch Naming (STRICTLY ENFORCED)

```
feat/<short-description>     # New features
fix/<short-description>      # Bug fixes
chore/<short-description>    # Infrastructure/tooling
docs/<short-description>     # Documentation only
ci/<short-description>       # CI/CD changes
refactor/<short-description> # Code refactoring
test/<short-description>     # Test additions/changes
```

**Examples:**
- `feat/add-ollama-integration`
- `fix/network-latency-spike`
- `docs/update-mcp-guide`

### Commit Message Format (Conventional Commits)

```
<type>: <subject>

[Optional body with details]

ATOM-<TYPE>-<YYYYMMDD>-<NNN>
```

**Types:** `feat`, `fix`, `chore`, `docs`, `ci`, `refactor`, `test`

**Example:**
```
feat: add Qwen local AI integration

Implements local AI processing using Ollama/Qwen for offline operation.
Includes configuration templates and MCP server integration.

ATOM-CFG-20251112-042
```

### ATOM Tag System

**CRITICAL:** All significant changes must be tagged with ATOM identifiers for audit trail.

**Format:** `ATOM-{TYPE}-{YYYYMMDD}-{NNN}`

**Types:**
- `ATOM-MCP-*` - MCP tool invocations
- `ATOM-SAGE-*` - Methodology executions
- `ATOM-CFG-*` - Configuration changes
- `ATOM-DEPLOY-*` - Production deployments
- `ATOM-TASK-*` - Task tracking
- `ATOM-RESEARCH-*` - Research queries
- `ATOM-STATUS-*` - Status reports
- `ATOM-DOC-*` - Documentation updates

**Usage:** Reference ATOM tags in:
- Commit messages
- ARCREF documents
- ADRs
- Documentation frontmatter

### Markdown Standards

#### Mermaid Diagrams

**Syntax Rules:**
- Always close mermaid code blocks with ` ``` ` on its own line
- Use simple node IDs (e.g., `KENL0`) not complex paths (e.g., `modules/KENL0`)
- Keep markdown content outside diagram code fences
- Place style declarations INSIDE the mermaid code fence

**Node Shapes (Semantic Meaning):**
- Stadium `( )` - User actions, start/end points
- Diamond `{ }` - Decisions, conditional branches
- Subroutine `[[ ]]` - Processes, transformations
- Cylinder `[( )]` - Data storage, persistence
- Rectangle `[ ]` - Standard operations

**Color Coding:**
- Red tones (`#ff6b6b`) - User intent, problems, error states
- Yellow (`#ffd43b`) - Decisions, research results, warnings
- Blue (`#4dabf7`) - Configuration processes, setup steps
- Purple (`#845ef7`) - Data storage, Play Cards, documentation
- Green (`#51cf66`) - Success states, completed actions

#### Markdown Tables

**⚠️ CRITICAL:** Table formatting is the #1 persistent issue across AI agents. Follow these rules EXACTLY.

**Primary Rule:** **Longest string sets the column width. Period.**

**Pattern #1 (Order-Agnostic Tables):**
1. Put the row with the longest entry FIRST
2. All subsequent rows pad to match row 1
3. Never scan all rows - row 1 is your template

**Pattern #2 (Sequential/Chronological Tables):**
1. Pre-determine max widths per column
2. Stick to those widths for ALL rows
3. Use ellipsis if content exceeds width

**Example (Pattern #1):**
```markdown
| Module | Purpose                                |
|--------|----------------------------------------|
| KENL2  | Gaming with Play Cards and Proton      |
| KENL1  | Framework                              |
| KENL0  | System                                 |
```

**Why:** "Gaming with Play Cards and Proton" is longest → Sets width for column 2

**Detailed Guide:** See `claude-landing/MARKDOWN-TABLE-FORMATTING.md` for:
- Anti-patterns to avoid
- Self-validation checklist
- Real examples from this repo
- Pre-commit validation rules

### Shell Script Standards

**For bash scripts (.sh):**
- Use `#!/usr/bin/env bash` shebang
- Must pass shellcheck with `--severity=style`
- Include ATOM tag in header comments
- Add OWI metadata frontmatter for tracking

**For PowerShell scripts (.ps1):**
- Follow PowerShell verb-noun naming convention
- Include comment-based help headers
- Use `#Requires -Version 5.1` or higher
- Add ATOM tag in script header

## Governance Requirements

### Dual Governance System

**CRITICAL:** Infrastructure and architectural changes MUST have both an ARCREF artifact AND an ADR document.

#### 1. ARCREF (Architecture Reference artifacts)

**Location:** `governance/mcp-governance/ARCREF-*.yaml`

**Required for:**
- MCP tool integrations
- Cloud/platform changes
- Repository-level infrastructure
- Build system modifications

**Template:** `governance/mcp-governance/ARCREF_TEMPLATE.yaml`

**Must include:**
- Unique ARCREF ID
- Rollback plan
- Test verification steps
- Traceability to ATOM tags

#### 2. ADR (Architectural Decision Records)

**Location:** `governance/02-Decisions/ADR-*.md`

**Required for:**
- All architectural decisions
- Technology choices
- Pattern implementations

**Template:** `governance/02-Decisions/ADR_TEMPLATE.md`

**Status Lifecycle:**
```
proposed → accepted → deprecated/superseded
```

**Must include:**
- Link to associated ARCREF ID
- Context and problem statement
- Decision rationale
- Consequences (positive and negative)

### Creating a Pull Request

**PR Checklist (from CONTRIBUTING.md):**
- [ ] Branch name follows convention
- [ ] Commit messages use Conventional Commits
- [ ] Tests added/modified where appropriate
- [ ] Documentation updated (README, docs/)
- [ ] ARCREF + ADR created for architectural changes
- [ ] Pre-commit passes: `pre-commit run --all-files`
- [ ] ATOM tags referenced in commit messages

**For Architectural Changes:**
1. Create ARCREF artifact in `governance/mcp-governance/` using template
2. Create ADR in `governance/02-Decisions/` using template
3. Link ARCREF ID in ADR and PR description
4. Include rollback plan and test verification

## CI/CD Pipeline

### Automated Checks

**On push/PR to `main` (`.github/workflows/ci.yml`):**
1. **pre-commit job** - Runs all pre-commit hooks
2. **CodeQL job** - Security scanning (JavaScript, Python)
3. **tests job** - Runs pytest if tests exist

**Permissions required:**
- `contents: read`
- `packages: read`
- `security-events: write`

### Release Workflow

**Triggered on version tags (`v*.*.*`) (`.github/workflows/release.yml`):**
```bash
# Create a release
git tag v1.0.0
git push origin v1.0.0
# CI runs semantic-release automatically
```

## Important Cautions

### Do Not Modify Directly

**Critical Files:**
- `.github/workflows/*.yml` - CI/CD pipelines (requires ARCREF + ADR)
- `governance/02-Decisions/ADR-*.md` - Only update status, don't delete
- `.pre-commit-config.yaml` - Pre-commit configuration (requires testing)
- `CLAUDE.md` - Primary AI agent instructions (discuss changes first)

**Protected Patterns:**
- ATOM tag format: `ATOM-{TYPE}-{YYYYMMDD}-{NNN}` - Must follow exactly
- Branch naming: Must match enforced patterns
- Commit message format: Must follow Conventional Commits

### User-Space Only Operations

**REQUIREMENT:** All operations must be user-space only (`~/.local`, `~/.config`, `~/.*`)

**Never:**
- Modify system-level files (`/etc`, `/usr`, `/opt`)
- Suggest `sudo` commands that affect immutable base
- Taint the rpm-ostree base layer
- Require system daemons or services

**Why:** KENL targets immutable Linux distributions (Bazzite-DX/Fedora Atomic) where system modifications require layering and break the atomic update model.

### Security Considerations

- **Secrets:** Never commit secrets, API keys, or credentials
- **Secret Detection:** Pre-commit hook will catch secrets before commit
- **Security Issues:** Report via `SECURITY.md` (private disclosure)
- **Third-Party Integrations:** Require approval and security review

### Performance Requirements

**Overhead Targets:**
- ATOM logging: ~0.1ms per operation
- Play Card loading: Static YAML (no runtime parsing)
- MCP operations: JSON-RPC minimal latency
- No CPU/GPU overhead from monitoring daemons

## Special Instructions for Common Tasks

### Adding a New KENL Module

1. Create directory: `modules/KENLX-<name>/`
2. Add `README.md` with module overview
3. Follow existing module structure pattern
4. Update main `README.md` module list
5. Add entry to `.sage-manifest.yaml`
6. Create ATOM tag: `ATOM-SAGE-YYYYMMDD-NNN`

### Updating Documentation

1. Check `claude-landing/CURRENT-STATE.md` first for current environment
2. Use ATOM tag: `ATOM-DOC-YYYYMMDD-NNN`
3. Follow markdown standards (Mermaid, tables)
4. Update date in frontmatter
5. Run `pre-commit run --all-files` to validate

### Adding External Dependencies

1. Check if it can be user-space installed
2. Document rollback procedure
3. Add to appropriate module README
4. Create ATOM tag: `ATOM-CFG-YYYYMMDD-NNN`
5. Test in isolated environment first

### Working with PowerShell Modules

**Location:** `modules/KENL0-system/powershell/`

1. Follow PowerShell verb-noun naming
2. Include comment-based help
3. Export functions explicitly
4. Test on Windows 11 and PowerShell 7+
5. Add ATOM tag in script header

### Integrating MCP Tools

**Guide:** `modules/KENL3-dev/guides/MCP-INTEGRATION-GUIDE.md`

1. Must create ARCREF artifact
2. Must create ADR document
3. Include rollback plan
4. Test JSON-RPC communication
5. Document in MCP governance directory

## Target Environment

**Platform:** Bazzite-DX (Fedora Atomic 43 + Universal Blue)
- **Desktop:** KDE Plasma 6.3+
- **Gaming:** Proton/GE-Proton, GameScope, MangoHud
- **AI Stack:** Claude (10%), Perplexity (30%), Qwen local (60%)
- **Dev:** Distrobox (Ubuntu 24.04 + Claude Code)
- **Cloud:** Cloudflare Workers/D1/KV/R2

**Pre-Deployment Testing:** Windows 11 (current phase)

**Target Use Case:** Windows 10 EOL migration (Oct 2025) - providing evidence-based, rollback-safe gaming configurations.

## Quick Reference Commands

### Git Operations
```bash
git status
git log --oneline -10
git branch -a
```

### PowerShell (Windows Testing)
```powershell
Import-Module ./modules/KENL0-system/powershell/KENL.psm1
Import-Module ./modules/KENL0-system/powershell/KENL.Network.psm1
Test-KenlNetwork     # Network diagnostics
Get-KenlPlatform     # Platform info
```

### Validation
```bash
pre-commit run --all-files           # Run all checks
pre-commit run shellcheck --all-files # Shell scripts only
pre-commit run detect-secrets --all-files # Secret detection
```

### Documentation
```bash
cat claude-landing/CURRENT-STATE.md  # Current environment
cat claude-landing/RECENT-WORK.md   # Recent session work
cat claude-landing/QUICK-REFERENCE.md # Common commands
```

## Getting Help

1. **For Claude Code:** Start with `claude-landing/` directory
2. **For general usage:** Read `README.md` and module-specific READMEs
3. **For contributing:** See `CONTRIBUTING.md`
4. **For governance:** Check `governance/` templates
5. **For security:** Follow `SECURITY.md` procedures

## Task Assignment Guidelines for Copilot Coding Agent

### Appropriate Tasks

**Good Tasks for Copilot:**
- Bug fixes with clear reproduction steps
- Adding unit tests for existing code
- Documentation updates and improvements
- Refactoring with well-defined scope
- Adding new features with clear specifications
- Shell script creation following ATOM/SAGE patterns
- PowerShell module development
- Configuration file updates (YAML, JSON)

**Tasks Requiring Human Review:**
- Security-critical changes (authentication, encryption)
- Changes affecting CI/CD pipelines (require ARCREF + ADR)
- Major architectural decisions
- Changes to governance templates (ARCREF_TEMPLATE.yaml, ADR_TEMPLATE.md)
- Modifications to `.github/copilot-instructions.md`

**Issue Formatting for Best Results:**

```markdown
## Problem
Clear description of what needs to be fixed or added

## Acceptance Criteria
- [ ] Specific, testable requirement 1
- [ ] Specific, testable requirement 2
- [ ] Tests added/updated
- [ ] Documentation updated

## Context
- Affected files: `path/to/file.sh`
- Related ATOM tag: ATOM-TYPE-YYYYMMDD-NNN
- Testing approach: Manual verification / pytest / shellcheck
```

### Review Process for Copilot PRs

1. **Automated Checks:** Verify CI passes (pre-commit, CodeQL, tests)
2. **Code Review:** Review for correctness, style, and security
3. **ATOM Compliance:** Ensure ATOM tags are present and correct
4. **Governance:** Verify ARCREF + ADR for architectural changes
5. **Testing:** Manually test changes if automated coverage insufficient
6. **Documentation:** Verify docs are updated appropriately

### Custom Agents (Optional)

Create specialized agent profiles in `.github/agents/` for recurring tasks:

**Example: `.github/agents/documentation-expert.md`**
```markdown
# Documentation Expert Agent

Focus on maintaining high-quality documentation following KENL standards.

## Responsibilities
- Update markdown documentation with proper formatting
- Ensure Mermaid diagrams follow visual standards
- Validate table formatting (longest-string-first rule)
- Add ATOM-DOC tags to all documentation changes
- Update frontmatter dates and metadata

## Standards
- Follow VISUAL-ELEMENTS-STANDARD.md for colors and emojis
- Use claude-landing/ for AI-agent-specific docs
- Maintain consistency across all module READMEs
```

**Example: `.github/agents/shell-script-expert.md`**
```markdown
# Shell Script Development Agent

Specialized in creating POSIX-compliant shell scripts for KENL.

## Responsibilities
- Write bash scripts following KENL shell standards
- Ensure shellcheck compliance (--severity=style)
- Add ATOM tags and OWI metadata
- Include error handling and rollback instructions
- Generate appropriate SAIF flags

## Standards
- Use `#!/usr/bin/env bash` shebang
- Include `set -euo pipefail`
- Follow color scheme from VISUAL-ELEMENTS-STANDARD.md
- Test on both Bazzite-DX and Windows 11 (if applicable)
```

## Automation Commands for Copilot

These commands enable Copilot to autonomously validate changes:

### Validation Commands

```bash
# Run all pre-commit hooks (if pre-commit installed)
pip install --user pre-commit
pre-commit install
pre-commit run --all-files

# Validate shell scripts
find . -name "*.sh" -type f -exec shellcheck --severity=style {} \;

# Check YAML files
find . -name "*.yaml" -o -name "*.yml" | xargs -I {} sh -c 'python3 -m yaml validate {}'

# Validate JSON files
find . -name "*.json" -type f -exec python3 -m json.tool {} \; > /dev/null
```

### Testing Commands

```bash
# Run Python tests (if available)
pytest -q

# Test PowerShell modules (Windows/Linux)
pwsh -Command "Import-Module ./modules/KENL0-system/powershell/KENL.psm1; Get-KenlPlatform"
pwsh -Command "Import-Module ./modules/KENL0-system/powershell/KENL.Network.psm1; Test-KenlNetwork"

# Validate Play Cards (if ATOM framework installed)
./atom-sage-framework/tools/validate-playcard.sh <path-to-playcard.yaml>
```

### Build Commands

```bash
# Generate distribution scaffold
./make_kenl_scaffold_zip.sh

# Bootstrap development environment
./scripts/bootstrap.sh

# Generate documentation artifacts
./atom-sage-framework/generate-pdf.sh
```

## Summary

When working on KENL:
1. **Always** read `claude-landing/CURRENT-STATE.md` first
2. **Always** use ATOM tags for traceability
3. **Always** create ARCREF + ADR for infrastructure changes
4. **Always** include rollback instructions
5. **Always** stay in user-space (no system modifications)
6. **Always** run pre-commit checks before pushing
7. **Always** follow Conventional Commits format
8. **Always** document the *why*, not just the *what*

**For Copilot Coding Agent Specifically:**
- Review task assignments carefully for scope and clarity
- Run validation commands before submitting PRs
- Follow existing patterns and conventions strictly
- Request human review for security or architectural changes
- Document all assumptions and decisions in commit messages
