#!/usr/bin/env bash
# Add OWI Metadata to Documentation Files
# Version: 2.0.0
# ATOM-TOOL-20251105-025

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Options
DRY_RUN=false
SKIP_CONFIRM=false

# Counters
FILES_TO_UPDATE=()
FILES_SKIPPED=0
FILES_UPDATED=0

# Colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

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

# Check if file needs metadata
check_file() {
    local file="$1"
    local relative_path="${file#$PROJECT_ROOT/}"

    # Skip if already has metadata
    if head -1 "$file" | grep -q "^---"; then
        ((FILES_SKIPPED++))
        return 1
    fi

    FILES_TO_UPDATE+=("$file")
    return 0
}

# Process a single file (add metadata)
process_file() {
    local file="$1"
    local relative_path="${file#$PROJECT_ROOT/}"

    # Determine classification
    local classification=$(get_classification "$file")
    local counter=$(get_atom_counter)
    local date=$(date +%Y-%m-%d)
    local datenum=$(date +%Y%m%d)

    if [[ "$DRY_RUN" == true ]]; then
        echo -e "  ${CYAN}[DRY RUN]${NC} $relative_path [$classification]"
        return 0
    fi

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

    ((FILES_UPDATED++))
    echo -e "  ${GREEN}✓${NC} $relative_path [$classification]"
}

# Scan for files needing metadata
scan_files() {
    local directories=(
        "$HOME"
        "$PROJECT_ROOT"
        "$PROJECT_ROOT/.kenl"
        "$PROJECT_ROOT/governance/02-Decisions"
        "$PROJECT_ROOT/governance/mcp-governance"
    )

    for dir in "${directories[@]}"; do
        if [ -d "$dir" ]; then
            for file in "$dir"/*.md; do
                [ -f "$file" ] && check_file "$file"
            done
        fi
    done
}

# Show summary of files to be updated
show_summary() {
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  SCAN RESULTS"
    echo "═══════════════════════════════════════════════════════════"
    echo "Files with metadata:    $FILES_SKIPPED"
    echo "Files needing metadata: ${#FILES_TO_UPDATE[@]}"
    echo "═══════════════════════════════════════════════════════════"

    if [[ ${#FILES_TO_UPDATE[@]} -gt 0 ]]; then
        echo ""
        echo "Files to be updated:"
        for file in "${FILES_TO_UPDATE[@]}"; do
            local relative_path="${file#$PROJECT_ROOT/}"
            local classification=$(get_classification "$file")
            echo "  - $relative_path [$classification]"
        done
    fi
}

# Confirmation prompt
confirm_operation() {
    if [[ "$SKIP_CONFIRM" == true ]]; then
        return 0
    fi

    echo ""
    read -p "Continue with adding metadata? (y/n): " response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Operation cancelled"
        exit 0
    fi
}

# Main execution
main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -y|--yes)
                SKIP_CONFIRM=true
                shift
                ;;
            -h|--help)
                cat <<EOF
Usage: $0 [OPTIONS]

Add OWI metadata to markdown files without frontmatter.

Options:
  -n, --dry-run    Show what would be done without making changes
  -y, --yes        Skip confirmation prompt
  -h, --help       Show this help message

Examples:
  $0               # Interactive mode
  $0 --dry-run     # Preview changes
  $0 --yes         # Skip confirmation
EOF
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                echo "Use -h for help"
                exit 1
                ;;
        esac
    done

    echo "═══════════════════════════════════════════════════════════"
    echo "  OWI Metadata Addition Tool v2.0"
    echo "═══════════════════════════════════════════════════════════"
    echo "Project: Bazza-DX SAGE Framework"

    if [[ "$DRY_RUN" == true ]]; then
        echo "Mode: DRY RUN (no changes will be made)"
    fi

    echo ""
    echo "Scanning for markdown files..."

    # Scan phase
    scan_files
    show_summary

    # Exit if no files to update
    if [[ ${#FILES_TO_UPDATE[@]} -eq 0 ]]; then
        echo ""
        echo -e "${GREEN}✓ All files already have metadata${NC}"
        exit 0
    fi

    # Confirmation
    if [[ "$DRY_RUN" == false ]]; then
        confirm_operation
    fi

    # Processing phase
    echo ""
    echo "Processing files..."
    for file in "${FILES_TO_UPDATE[@]}"; do
        process_file "$file"
    done

    # Final summary
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    if [[ "$DRY_RUN" == true ]]; then
        echo "  DRY RUN COMPLETE"
        echo "  Would update ${#FILES_TO_UPDATE[@]} files"
    else
        echo "  COMPLETE"
        echo "  Updated $FILES_UPDATED files"
    fi
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo "Next step: Run './scripts/owi-report.sh' to generate documentation index"
}

# Run
main "$@"
