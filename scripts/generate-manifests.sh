#!/usr/bin/env bash
#
# generate-manifests.sh
# Generates basic MANIFEST.md files for all KENL modules
#
# Version: 1.0.0
# ATOM: ATOM-CFG-20251112-004

set -euo pipefail

MODULES_DIR="/home/user/kenl/modules"
DATE=$(date +%Y-%m-%d)
DATENUM=$(date +%Y%m%d)

# Module definitions: ID, Name, Category, Status, Description
declare -A MODULES=(
    ["KENL1-framework"]="Framework|Framework Core|Production Ready|Core ATOM/SAGE/OWI framework implementation"
    ["KENL2-gaming"]="Gaming|Gaming Optimization|Production Ready|Gaming configurations, Play Cards, performance optimization"
    ["KENL3-dev"]="Development|Development Tools|Production Ready|Distrobox environments, ujust recipes, Claude Code setup"
    ["KENL4-monitoring"]="Monitoring|System Monitoring|Development|Prometheus, Grafana, ATOM analytics"
    ["KENL5-facades"]="Facades|Visual Themes|Development|Context switching, banners, visual themes"
    ["KENL6-social"]="Social|Community Sharing|Development|Play Card sharing, community features"
    ["KENL7-learning"]="Learning|Documentation|Production Ready|Cheatsheets, guides, learning resources"
    ["KENL8-security"]="Security|Security Tools|Development|GPG, SSH, security hardening"
    ["KENL9-library"]="Library|Game Library|Development|Game library management, Steam integration"
    ["KENL10-backup"]="Backup|Backup & Recovery|Development|Backups, snapshots, recovery procedures"
    ["KENL11-media"]="Media|Media Streaming|Development|Media streaming, Docker compose"
    ["KENL12-resources"]="Resources|Community Resources|Development|Community downloads, RSS feeds"
)

generate_manifest() {
    local module_dir="$1"
    local module_num="${module_dir##*KENL}"
    module_num="${module_num%%-*}"
    local module_key=$(basename "$module_dir")

    if [[ -z "${MODULES[$module_key]}" ]]; then
        echo "Warning: No metadata for $module_key"
        return 1
    fi

    IFS='|' read -r name category status description <<< "${MODULES[$module_key]}"

    local manifest_file="$module_dir/MANIFEST.md"
    local counter=$(printf "%03d" $((10 + module_num)))

    cat > "$manifest_file" <<EOF
---
project: Bazza-DX SAGE Framework
classification: OWI-DOC
atom: ATOM-DOC-${DATENUM}-${counter}
status: active
version: 1.0.0
---

# ${module_key} Module Manifest

**Module:** ${module_key}
**Version:** 1.0.0
**Status:** ${status}
**Last Updated:** ${DATE}

---

## Purpose

${description}

---

## Module Information

| Property | Value |
|----------|-------|
| **Module ID** | KENL${module_num} |
| **Module Name** | ${name} |
| **Category** | ${category} |
| **Privilege Level** | User-space |
| **Platform** | Linux (Bazzite/Fedora Atomic) |
| **Dependencies** | KENL0 (System), KENL1 (Framework) |

---

## Directory Structure

\`\`\`
${module_key}/
├── README.md                     # Module documentation
├── MANIFEST.md                   # This file
└── [module-specific files]
\`\`\`

---

## Files Inventory

See \`README.md\` for detailed file inventory.

---

## Dependencies

### System Dependencies

See module README for specific system package requirements.

### KENL Module Dependencies

- **KENL0:** System operations and ATOM logging
- **KENL1:** Framework core (ATOM/SAGE/OWI)

---

## Installation

### Quick Install

\`\`\`bash
# Most KENL modules operate from repo without installation
cd ~/kenl/modules/${module_key}

# Follow module-specific README for setup instructions
cat README.md
\`\`\`

### Verification

\`\`\`bash
# Verify module files exist
ls -la ~/kenl/modules/${module_key}
\`\`\`

---

## Configuration

See module \`README.md\` for configuration details.

---

## Usage

See module \`README.md\` for usage examples and commands.

---

## Integration Points

### Integration with Other Modules

- **KENL0:** Uses system-atom.sh for logging
- **KENL1:** Integrates with ATOM/SAGE framework

### System Integration

See module \`README.md\` for system integration details.

---

## ATOM Traceability

### ATOM Tags

| Tag | Purpose |
|-----|---------|
| \`ATOM-DOC-${DATENUM}-${counter}\` | Module manifest |

### Logging

- **Log Location:** \`~/.atom-logs/\`
- **Log Format:** Standard KENL ATOM trail format

---

## Testing & Validation

### Validation Checklist

- [ ] Module README exists and is up-to-date
- [ ] Module files are accessible
- [ ] Dependencies are satisfied
- [ ] ATOM logging works

---

## Rollback & Recovery

### Uninstallation

\`\`\`bash
# Most modules have no system-level installation
# Simply don't use the module files
\`\`\`

---

## Maintenance

### Update Procedure

\`\`\`bash
# Update with kenl repo
cd ~/kenl
git pull origin main
\`\`\`

### Health Checks

\`\`\`bash
# Verify module files exist
ls -la ~/kenl/modules/${module_key}
\`\`\`

---

## Known Issues

See module \`README.md\` for current issues and limitations.

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | ${DATE} | Initial manifest creation |

---

## References

### Internal Documentation

- \`README.md\` - Module documentation

### External Resources

See module \`README.md\` for external references.

---

## Metadata

- **Created:** ${DATE}
- **Last Updated:** ${DATE}
- **Maintainer:** toolate28/kenl
- **ATOM Tag:** ATOM-DOC-${DATENUM}-${counter}
- **Classification:** OWI-DOC
- **Status:** Active

---
EOF

    echo "✓ Created manifest for $module_key"
}

main() {
    echo "═══════════════════════════════════════════════════════════"
    echo "  KENL Module Manifest Generator"
    echo "═══════════════════════════════════════════════════════════"
    echo ""

    local count=0
    for module_dir in "$MODULES_DIR"/KENL*; do
        if [[ -d "$module_dir" ]]; then
            local module_name=$(basename "$module_dir")

            # Skip KENL0 (already has comprehensive manifest)
            if [[ "$module_name" == "KENL0-system" ]]; then
                echo "⊙ Skipping $module_name (already has manifest)"
                continue
            fi

            if generate_manifest "$module_dir"; then
                ((count++))
            fi
        fi
    done

    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  Created $count manifests"
    echo "═══════════════════════════════════════════════════════════"
}

main "$@"
