#!/usr/bin/env bash
# Add OWI Metadata to Documentation Files
# ATOM-TOOL-20251105-025

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Classification mapping based on file path/name
get_classification() {
    local file="$1"
    local basename=$(basename "$file")

    case "$basename" in
        *ASSESSMENT*.md) echo "OWI-ASSESSMENT" ;;
        *CHECKLIST*.md) echo "OWI-CHECKLIST" ;;
        *HANDOFF*.md) echo "OWI-HANDOFF" ;;
        *STANDARD*.md) echo "OWI-STANDARD" ;;
        *CONFIG*.md) echo "OWI-CONFIG" ;;
        *REFERENCE*.md) echo "OWI-REFERENCE" ;;
        README.md|CONTRIBUTING.md|CHANGELOG.md|CLAUDE.md) echo "OWI-DOC" ;;
        *) echo "OWI-DOC" ;;
    esac
}

# Get next available ATOM counter
get_atom_counter() {
    if [ -f ~/.config/bazza-dx/atom_counter ]; then
        cat ~/.config/bazza-dx/atom_counter
    else
        echo "1"
    fi
}

# Process a single file
process_file() {
    local file="$1"
    local relative_path="${file#$PROJECT_ROOT/}"

    # Skip if already has metadata
    if head -1 "$file" | grep -q "^---"; then
        echo "  ✓ $relative_path (already has metadata)"
        return 0
    fi

    # Determine classification
    local classification=$(get_classification "$file")
    local counter=$(get_atom_counter)
    local date=$(date +%Y-%m-%d)
    local datenum=$(date +%Y%m%d)

    # Create temp file with metadata
    local temp=$(mktemp)
    cat > "$temp" <<EOF
---
project: Bazza-DX SAGE Framework
status: current
version: $date
classification: $classification
atom: ATOM-DOC-$datenum-$(printf "%03d" $counter)
owi-version: 1.0.0
---

EOF

    # Append original content
    cat "$file" >> "$temp"

    # Replace original
    mv "$temp" "$file"

    echo "  ✓ $relative_path [$classification]"
}

# Main execution
main() {
    echo "=== OWI Metadata Addition Tool ==="
    echo "Project: Bazza-DX SAGE Framework"
    echo ""

    # Process home directory .md files
    echo "Processing home directory documentation..."
    for file in ~/*.md; do
        [ -f "$file" ] && process_file "$file"
    done

    echo ""
    echo "Processing kenl/ project documentation..."

    # Process kenl root
    for file in "$PROJECT_ROOT"/*.md; do
        [ -f "$file" ] && process_file "$file"
    done

    # Process kenl/.kenl/
    if [ -d "$PROJECT_ROOT/.kenl" ]; then
        for file in "$PROJECT_ROOT/.kenl"/*.md; do
            [ -f "$file" ] && process_file "$file"
        done
    fi

    # Process 02-Decisions/
    if [ -d "$PROJECT_ROOT/02-Decisions" ]; then
        for file in "$PROJECT_ROOT/02-Decisions"/*.md; do
            [ -f "$file" ] && process_file "$file"
        done
    fi

    # Process mcp-governance/
    if [ -d "$PROJECT_ROOT/mcp-governance" ]; then
        for file in "$PROJECT_ROOT/mcp-governance"/*.md; do
            [ -f "$file" ] && process_file "$file"
        done
    fi

    echo ""
    echo "=== OWI Metadata Addition Complete ==="
    echo ""
    echo "Run './scripts/owi-report.sh' to generate documentation index"
}

# Run
main "$@"
