---
project: Bazza-DX SAGE Framework
status: current
version: 2025-11-05
classification: OWI-STANDARD
atom: ATOM-DOC-20251105-024
owi-version: 1.0.0
---

# OWI Metadata Standard
**Optimized-With-Intent (OWI) Documentation System**

## Purpose

This standard defines metadata tagging for all documentation, images, and artifacts in the Bazza-DX SAGE project that have been created or optimized with AI tooling assistance.

**OWI** = **Optimized-With-Intent**
- Indicates content created/enhanced with AI assistance
- Ensures transparency about AI involvement
- Tracks version and currency of documentation
- Enables automated documentation management

---

## Metadata Header Format

All markdown files (`.md`) in the project must include this YAML frontmatter:

```yaml
---
project: Bazza-DX SAGE Framework
status: current|archived|draft|superseded
version: YYYY-MM-DD
classification: OWI-{TYPE}
atom: ATOM-DOC-YYYYMMDD-NNN
owi-version: SEMVER
supersedes: [previous-file.md] # optional
related: [related-file1.md, related-file2.md] # optional
---
```

---

## Classification Types

### OWI-DOC
**Usage:** General documentation files
**Examples:** Guides, tutorials, explanations
**Files:** README.md, CONTRIBUTING.md, guides, tutorials

### OWI-STANDARD
**Usage:** Standards and specifications documents
**Examples:** This file, coding standards, conventions
**Files:** Standards, protocols, specifications

### OWI-CONFIG
**Usage:** Configuration documentation
**Examples:** Setup guides, config references
**Files:** Configuration guides, setup instructions

### OWI-ASSESSMENT
**Usage:** Analysis and assessment documents
**Examples:** System analysis, comparisons
**Files:** REBASE_POST_MORTEM.md, PROTON_WINE_ASSESSMENT.md

### OWI-CHECKLIST
**Usage:** Procedural checklists and runbooks
**Examples:** Pre-flight checks, deployment steps
**Files:** NEXT_BOOT_CHECKLIST.md, deployment checklists

### OWI-HANDOFF
**Usage:** Session handoff and status documents
**Examples:** Session summaries, status reports
**Files:** SESSION_HANDOFF_*.md, status reports

### OWI-REFERENCE
**Usage:** Quick reference cards and cheat sheets
**Examples:** Command references, keyboard shortcuts
**Files:** Command references, API docs

### OWI-VISUAL
**Usage:** Generated images, diagrams, charts
**Examples:** Architecture diagrams, charts
**Files:** PNG, SVG, JPEG with AI generation

---

## Status Values

| Status | Meaning | Usage |
|--------|---------|-------|
| `current` | Active, up-to-date documentation | Primary documentation files |
| `draft` | Work in progress | Incomplete documents |
| `archived` | Historical, superseded | Old versions kept for reference |
| `superseded` | Replaced by newer version | Deprecated but linked |
| `deprecated` | No longer recommended | Will be removed |

---

## Version Format

**Format:** `YYYY-MM-DD`
**Example:** `2025-11-05`

**Rationale:** ISO 8601 date format, sortable, clear chronology

---

## OWI Version (Semantic)

**Format:** `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes (incompatible format changes)
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes, clarifications

**Current OWI Standard:** `1.0.0`

---

## Examples

### Example 1: General Documentation
```yaml
---
project: Bazza-DX SAGE Framework
status: current
version: 2025-11-05
classification: OWI-DOC
atom: ATOM-DOC-20251105-025
owi-version: 1.0.0
---

# Gaming Setup Guide
```

### Example 2: Configuration Guide
```yaml
---
project: Bazza-DX SAGE Framework
status: current
version: 2025-11-05
classification: OWI-CONFIG
atom: ATOM-CFG-20251105-026
owi-version: 1.0.0
related: [network-multipath-steam.sh]
---

# Network Configuration Guide
```

### Example 3: Archived Document
```yaml
---
project: Bazza-DX SAGE Framework
status: archived
version: 2025-11-01
classification: OWI-ASSESSMENT
atom: ATOM-DOC-20251101-012
owi-version: 1.0.0
supersedes: null
superseded-by: PROTON_WINE_ASSESSMENT.md
---

# Old Gaming Assessment (ARCHIVED)
```

### Example 4: Visual Asset
```yaml
# Filename: architecture-diagram.png.meta.yaml
---
project: Bazza-DX SAGE Framework
status: current
version: 2025-11-05
classification: OWI-VISUAL
atom: ATOM-VISUAL-20251105-001
owi-version: 1.0.0
generator: Claude Code + Mermaid
source: architecture-diagram.mmd
format: PNG
resolution: 1920x1080
---
```

---

## Implementation

### 1. Add Metadata to Existing Files

All existing `.md` files in the project should be updated with headers:

```bash
# Script to add metadata (run once)
./scripts/add-owi-metadata.sh
```

### 2. Pre-commit Hook

Add pre-commit hook to verify metadata presence:

```yaml
# .pre-commit-config.yaml
- repo: local
  hooks:
    - id: check-owi-metadata
      name: Check OWI metadata headers
      entry: ./scripts/check-owi-metadata.sh
      language: script
      files: \.md$
```

### 3. Automated Reporting

Generate documentation index:

```bash
# List all current docs
./scripts/owi-report.sh --status=current

# List all archived docs
./scripts/owi-report.sh --status=archived
```

---

## Metadata Scripts

### add-owi-metadata.sh

```bash
#!/usr/bin/env bash
# Add OWI metadata to markdown files

for file in $(find . -name "*.md" -type f); do
    if ! grep -q "^---" "$file"; then
        # File has no frontmatter, add it
        temp=$(mktemp)
        cat > "$temp" <<EOF
---
project: Bazza-DX SAGE Framework
status: current
version: $(date +%Y-%m-%d)
classification: OWI-DOC
atom: ATOM-DOC-$(date +%Y%m%d)-XXX
owi-version: 1.0.0
---

EOF
        cat "$file" >> "$temp"
        mv "$temp" "$file"
        echo "Added metadata to: $file"
    fi
done
```

### check-owi-metadata.sh

```bash
#!/usr/bin/env bash
# Pre-commit hook to verify OWI metadata

errors=0

for file in "$@"; do
    if [[ "$file" == *.md ]]; then
        if ! grep -q "^---" "$file"; then
            echo "ERROR: $file missing OWI metadata header"
            errors=$((errors + 1))
        elif ! grep -q "classification: OWI-" "$file"; then
            echo "ERROR: $file missing OWI classification"
            errors=$((errors + 1))
        elif ! grep -q "atom: ATOM-" "$file"; then
            echo "ERROR: $file missing ATOM tag"
            errors=$((errors + 1))
        fi
    fi
done

if [ $errors -gt 0 ]; then
    echo ""
    echo "Found $errors files with missing/invalid OWI metadata"
    echo "Add metadata headers using: ./scripts/add-owi-metadata.sh"
    exit 1
fi
```

### owi-report.sh

```bash
#!/usr/bin/env bash
# Generate OWI documentation report

status_filter="${1:---status=current}"

echo "# OWI Documentation Report"
echo "Generated: $(date -Iseconds)"
echo ""

for file in $(find . -name "*.md" -type f); do
    if grep -q "^---" "$file"; then
        status=$(grep "^status:" "$file" | head -1 | awk '{print $2}')
        classification=$(grep "^classification:" "$file" | head -1 | awk '{print $2}')
        version=$(grep "^version:" "$file" | head -1 | awk '{print $2}')
        atom=$(grep "^atom:" "$file" | head -1 | awk '{print $2}')

        if [[ "$status_filter" == *"$status"* ]]; then
            echo "## $file"
            echo "- **Status**: $status"
            echo "- **Classification**: $classification"
            echo "- **Version**: $version"
            echo "- **ATOM**: $atom"
            echo ""
        fi
    fi
done
```

---

## Visual Asset Metadata

For images and diagrams generated with AI:

### Naming Convention
```
{description}-{YYYYMMDD}-owi.{ext}
```

Examples:
- `architecture-diagram-20251105-owi.png`
- `network-topology-20251105-owi.svg`
- `performance-chart-20251105-owi.jpg`

### Sidecar Metadata File

Create `.meta.yaml` alongside each image:

```yaml
# architecture-diagram-20251105-owi.png.meta.yaml
---
project: Bazza-DX SAGE Framework
status: current
version: 2025-11-05
classification: OWI-VISUAL
atom: ATOM-VISUAL-20251105-001
owi-version: 1.0.0
generator: Claude Code + Mermaid
prompt: "Create architecture diagram showing SAGE framework components"
source: architecture-diagram.mmd
format: PNG
resolution: 1920x1080
color-scheme: dark
export-date: 2025-11-05T10:30:00Z
---
```

---

## Documentation Index

Maintain `DOCUMENTATION_INDEX.md` with:

```markdown
# Documentation Index

## Current Documentation

| File | Type | Version | ATOM | Purpose |
|------|------|---------|------|---------|
| README.md | OWI-DOC | 2025-11-05 | ATOM-DOC-... | Project overview |
| CONTRIBUTING.md | OWI-DOC | 2025-11-05 | ATOM-DOC-... | Contribution guide |
| ... | ... | ... | ... | ... |

## Archived Documentation

| File | Type | Version | ATOM | Superseded By |
|------|------|---------|------|---------------|
| ... | ... | ... | ... | ... |
```

Auto-generate with:
```bash
./scripts/owi-report.sh --format=table > DOCUMENTATION_INDEX.md
```

---

## Benefits

### 1. Transparency ✅
- Clear indication of AI-assisted content
- Attribution and methodology visible

### 2. Version Control ✅
- Easy to identify current vs outdated docs
- Clear supersession chain

### 3. Automated Management ✅
- Pre-commit hooks enforce standards
- Scripts generate reports automatically

### 4. Audit Trail ✅
- ATOM tags link docs to system changes
- Complete traceability

### 5. Discovery ✅
- Easy to find current documentation
- Clear classification by purpose

---

## Compliance

### Required Files

All files in these locations MUST have OWI metadata:

```
~/kenl/*.md                    # Root documentation
~/kenl/.kenl/*.md              # Hidden project docs
~/kenl/02-Decisions/*.md       # ADRs
~/kenl/mcp-governance/*.md     # ARCREF documents
~/*.md                         # Home directory guides
```

### Exceptions

These files MAY omit metadata:
- `node_modules/` directory
- `.git/` directory
- Third-party documentation
- Auto-generated files (e.g., changelogs)

---

## Migration Plan

### Phase 1: Add Metadata to Critical Files (NOW)
- [ ] README.md
- [ ] CONTRIBUTING.md
- [ ] CLAUDE.md
- [ ] All home directory .md files

### Phase 2: Add Metadata to Project Docs (Week 1)
- [ ] ~/kenl/.kenl/*.md
- [ ] 02-Decisions/*.md
- [ ] mcp-governance/*.md

### Phase 3: Implement Automation (Week 2)
- [ ] add-owi-metadata.sh script
- [ ] check-owi-metadata.sh pre-commit hook
- [ ] owi-report.sh reporting script

### Phase 4: Visual Assets (Week 3)
- [ ] Generate naming convention for images
- [ ] Create .meta.yaml for existing diagrams
- [ ] Set up automated diagram generation

---

## Future Enhancements

### v1.1.0 (Planned)
- Add `ai-model` field (e.g., "Claude Sonnet 3.5")
- Add `review-status` field (peer-reviewed, self-reviewed)
- Add `license` field for public docs

### v1.2.0 (Planned)
- Integration with Cloudflare D1 for documentation database
- Public documentation portal at docs.toolated.online
- Automated changelog generation from ATOM tags

### v2.0.0 (Future)
- Machine-readable documentation format
- API for documentation queries
- Automated documentation testing

---

## References

- ATOM Tag System: `~/.config/bazza-dx/env.sh`
- Project Governance: `~/kenl/CLAUDE.md`
- SAGE Methodology: `~/SYSTEM_INTELLIGENCE_REPORT.md`

---

**Status:** ADOPTED
**Effective Date:** 2025-11-05
**Review Date:** 2025-12-05

**OWI-STANDARD v1.0.0** - *Optimized-With-Intent*
