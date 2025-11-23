#!/usr/bin/env bash
# OWI Documentation Report Generator
# ATOM-TOOL-20251105-026

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Parse arguments
STATUS_FILTER="${1:-all}"
FORMAT="${2:-markdown}"

# Extract metadata from file
get_metadata() {
    local file="$1"
    local field="$2"

    if grep -q "^---" "$file"; then
        grep "^$field:" "$file" | head -1 | sed "s/^$field: //" || echo "unknown"
    else
        echo "none"
    fi
}

# Generate markdown report
generate_markdown() {
    echo "# OWI Documentation Index"
    echo ""
    echo "**Generated:** $(date -Iseconds)"
    echo "**Project:** Bazza-DX SAGE Framework"
    echo "**Filter:** $STATUS_FILTER"
    echo ""

    echo "## Current Documentation"
    echo ""
    echo "| File | Classification | Version | ATOM | Status |"
    echo "|------|----------------|---------|------|--------|"

    for file in $(find ~/ "$PROJECT_ROOT" -maxdepth 3 -name "*.md" -type f 2>/dev/null); do
        if [ -f "$file" ] && grep -q "^---" "$file"; then
            local status=$(get_metadata "$file" "status")
            local classification=$(get_metadata "$file" "classification")
            local version=$(get_metadata "$file" "version")
            local atom=$(get_metadata "$file" "atom")
            local relative_path="${file#$HOME/}"

            if [ "$STATUS_FILTER" = "all" ] || [ "$STATUS_FILTER" = "$status" ]; then
                echo "| $relative_path | $classification | $version | $atom | $status |"
            fi
        fi
    done | sort

    echo ""
    echo "---"
    echo ""
    echo "**Legend:**"
    echo "- **OWI-DOC**: General documentation"
    echo "- **OWI-ASSESSMENT**: Analysis documents"
    echo "- **OWI-CHECKLIST**: Procedural checklists"
    echo "- **OWI-HANDOFF**: Session handoffs"
    echo "- **OWI-STANDARD**: Standards documents"
    echo "- **OWI-CONFIG**: Configuration guides"
    echo ""
    echo "**Status Values:**"
    echo "- **current**: Active, up-to-date"
    echo "- **draft**: Work in progress"
    echo "- **archived**: Historical reference"
    echo "- **superseded**: Replaced by newer version"
}

# Generate JSON report
generate_json() {
    echo "{"
    echo "  \"generated\": \"$(date -Iseconds)\","
    echo "  \"project\": \"Bazza-DX SAGE Framework\","
    echo "  \"filter\": \"$STATUS_FILTER\","
    echo "  \"documents\": ["

    local first=true
    for file in $(find ~/ "$PROJECT_ROOT" -maxdepth 3 -name "*.md" -type f 2>/dev/null); do
        if [ -f "$file" ] && grep -q "^---" "$file"; then
            local status=$(get_metadata "$file" "status")
            local classification=$(get_metadata "$file" "classification")
            local version=$(get_metadata "$file" "version")
            local atom=$(get_metadata "$file" "atom")
            local relative_path="${file#$HOME/}"

            if [ "$STATUS_FILTER" = "all" ] || [ "$STATUS_FILTER" = "$status" ]; then
                if [ "$first" = false ]; then
                    echo ","
                fi
                first=false

                cat <<EOF
    {
      "path": "$relative_path",
      "classification": "$classification",
      "version": "$version",
      "atom": "$atom",
      "status": "$status"
    }
EOF
            fi
        fi
    done

    echo ""
    echo "  ]"
    echo "}"
}

# Main
main() {
    case "$FORMAT" in
        json)
            generate_json
            ;;
        markdown|*)
            generate_markdown
            ;;
    esac
}

main "$@"
