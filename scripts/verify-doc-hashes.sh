#!/usr/bin/env bash
#───────────────────────────────────────────────────────────────────────────────
# KENL Document Hash Verification Script
# Verify integrity of versioned documents
#───────────────────────────────────────────────────────────────────────────────
#
# Purpose: Verify and update cryptographic hashes for KENL documentation
# Prerequisites: sha256sum (or shasum on macOS), sed, grep
# Usage: ./verify-doc-hashes.sh [verify|update|generate <file>] [--dry-run]
# Options:
#   verify          Check all document hashes (default)
#   update          Update hashes for versioned files
#   generate FILE   Generate hash for a specific file
#   --dry-run       Show what would be done without making changes
#   --help          Show this help message
# Output: Verification results or updated hash values
# Next steps:
#   - After update, commit changes with ATOM tag
#   - Review any hash mismatches for unauthorized changes
# Integration:
#   - Uses KENL error handling library
#   - Works with OWI metadata frontmatter
# Related: See OWI_METADATA_STANDARD.md for hash format
#
# Version: 2.0.0
# ATOM: ATOM-TOOL-20251205-003
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# Future enhancement: Track hash history in $REPO_ROOT/.doc-hashes
# Currently hashes are stored in YAML frontmatter only

# Load error handling library
if [ -f "$SCRIPT_DIR/lib/error-handling.sh" ]; then
    # shellcheck source=lib/error-handling.sh
    source "$SCRIPT_DIR/lib/error-handling.sh"
else
    # Fallback definitions
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color
    
    log_error() { echo "[ERROR] $*" >&2; }
    log_warn() { echo "[WARN] $*" >&2; }
    log_info() { echo "[INFO] $*"; }
    log_success() { echo "[SUCCESS] $*"; }
    log_debug() { if [ "${DEBUG:-0}" = "1" ]; then echo "[DEBUG] $*" >&2; fi; }
    die() { log_error "$1"; exit 1; }
fi

# Consistent pattern for hash field
HASH_PATTERN='^hash:'

# Options
DRY_RUN=false

# Function to extract hash from frontmatter
extract_hash() {
    local file="$1"
    grep -E "$HASH_PATTERN" "$file" 2>/dev/null | sed 's/^hash:[[:space:]]*//' | head -1
}

# Function to compute current hash (excludes hash line)
compute_hash() {
    local file="$1"
    grep -v "$HASH_PATTERN" "$file" | sha256sum | cut -c1-8
}

# Function to update hash in file
update_hash() {
    local file="$1"
    local new_hash="$2"

    # Detect platform for portable sed -i usage
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if grep -q "$HASH_PATTERN" "$file"; then
            # Update existing hash (macOS)
            sed -i '' "s/${HASH_PATTERN}.*/hash: $new_hash/" "$file"
        else
            # Add hash after status line in frontmatter (macOS)
            sed -i '' "/^status:/a hash: $new_hash" "$file"
        fi
    else
        if grep -q "$HASH_PATTERN" "$file"; then
            # Update existing hash (Linux/other)
            sed -i "s/${HASH_PATTERN}.*/hash: $new_hash/" "$file"
        else
            # Add hash after status line in frontmatter (Linux/other)
            sed -i "/^status:/a hash: $new_hash" "$file"
        fi
    fi
}

#───────────────────────────────────────────────────────────────────────────────
# Functions
#───────────────────────────────────────────────────────────────────────────────

show_help() {
    cat << 'EOF'
KENL Document Hash Verification Script

Usage: ./verify-doc-hashes.sh [COMMAND] [OPTIONS]

Verifies cryptographic hashes in document frontmatter to detect unauthorized changes.

Commands:
  verify          Check all document hashes (default)
  update          Update hashes for versioned files
  generate FILE   Generate hash for a specific file

Options:
  --dry-run       Show what would be done without making changes
  --help          Show this help message

Examples:
  ./verify-doc-hashes.sh                    # Verify all hashes
  ./verify-doc-hashes.sh update             # Update all hashes
  ./verify-doc-hashes.sh generate README.md # Generate hash for file
  ./verify-doc-hashes.sh update --dry-run   # Preview updates

Hash Format:
  Hashes are stored in YAML frontmatter:
    ---
    hash: abc12345
    ---

For more information, see OWI_METADATA_STANDARD.md
EOF
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    local missing=0
    
    # Check for sha256sum or shasum
    if has_command sha256sum; then
        log_debug "Found sha256sum"
    elif has_command shasum; then
        log_debug "Found shasum (macOS)"
    else
        log_error "Neither sha256sum nor shasum found"
        log_error "Install coreutils package or use macOS built-in shasum"
        missing=1
    fi
    
    # Check for sed
    if ! require_command sed "sed" "Stream editor for text manipulation"; then
        missing=1
    fi
    
    # Check for grep
    if ! require_command grep "grep" "Pattern matching tool"; then
        missing=1
    fi
    
    if [ $missing -eq 0 ]; then
        log_success "All prerequisites found"
        return 0
    else
        suggest_recovery "missing_dependency"
        return 1
    fi
}

# Parse arguments - check for help first
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    show_help
    exit 0
fi

MODE="${1:-verify}"
shift || true

# Parse options
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            # Assume it's a file argument for generate command
            if [ "$MODE" = "generate" ] && [ -z "${FILE_ARG:-}" ]; then
                FILE_ARG="$1"
                shift
            else
                log_error "Unknown option: $1"
                show_help
                exit 1
            fi
            ;;
    esac
done

# Show banner
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  KENL Document Hash Verification"
echo "═══════════════════════════════════════════════════════════"
echo ""

if [ "$DRY_RUN" = "true" ]; then
    log_info "Running in DRY RUN mode - no changes will be made"
    echo ""
fi

# Check prerequisites
check_prerequisites || die "Prerequisites check failed"

echo ""

case "$MODE" in
    verify)
        echo "Mode: Verification"
        echo ""

        errors=0
        checked=0

        # Find all markdown files with frontmatter
        while IFS= read -r -d '' file; do
            if head -1 "$file" | grep -q "^---$"; then
                stored_hash=$(extract_hash "$file")

                if [[ -n "$stored_hash" ]]; then
                    current_hash=$(compute_hash "$file")
                    checked=$((checked + 1))

                    if [[ "$stored_hash" == "$current_hash" ]]; then
                        echo -e "${GREEN}✅${NC} $file"
                    else
                        echo -e "${RED}❌${NC} $file"
                        echo "   Stored:  $stored_hash"
                        echo "   Current: $current_hash"
                        errors=$((errors + 1))
                    fi
                fi
            fi
        done < <(find "$REPO_ROOT" -name "*.md" -type f -print0 2>/dev/null)

        echo ""
        echo "Checked: $checked files"
        echo "Errors:  $errors"

        if [[ $errors -gt 0 ]]; then
            echo -e "${YELLOW}⚠️  Some hashes don't match. Run with 'update' to fix.${NC}"
            exit 1
        else
            echo -e "${GREEN}✅ All hashes verified.${NC}"
        fi
        ;;

    update)
        log_info "Mode: Update Hashes"
        echo ""

        updated=0
        skipped=0

        # Find all markdown files with frontmatter
        while IFS= read -r -d '' file; do
            if head -1 "$file" | grep -q "^---$"; then
                # Check if file has version field (only hash versioned files)
                if grep -q "^version:" "$file"; then
                    current_hash=$(compute_hash "$file")
                    stored_hash=$(extract_hash "$file")

                    if [[ "$stored_hash" != "$current_hash" ]]; then
                        if [ "$DRY_RUN" = "true" ]; then
                            log_info "[DRY RUN] Would update: $file"
                            log_info "  Old: $stored_hash"
                            log_info "  New: $current_hash"
                        else
                            if update_hash "$file" "$current_hash"; then
                                echo -e "${GREEN}✅${NC} Updated: $file ($current_hash)"
                            else
                                log_error "Failed to update: $file"
                            fi
                        fi
                        updated=$((updated + 1))
                    else
                        skipped=$((skipped + 1))
                        log_debug "Skipped (unchanged): $file"
                    fi
                fi
            fi
        done < <(find "$REPO_ROOT" -name "*.md" -type f -print0 2>/dev/null)

        echo ""
        echo "═══════════════════════════════════════════════════════════"
        if [ "$DRY_RUN" = "true" ]; then
            log_info "DRY RUN Summary:"
            log_info "Would update: $updated files"
        else
            log_success "Update Summary:"
            echo "Updated: $updated files"
        fi
        echo "Skipped: $skipped files (unchanged)"
        echo "═══════════════════════════════════════════════════════════"
        ;;

    generate)
        log_info "Mode: Generate Hash for File"
        echo ""

        if [[ -z "${FILE_ARG:-}" ]]; then
            log_error "File argument required"
            log_info "Usage: $0 generate <file>"
            exit 1
        fi

        file="$FILE_ARG"
        
        if ! require_file "$file"; then
            die "File not found: $file"
        fi

        hash=$(compute_hash "$file")
        
        echo "═══════════════════════════════════════════════════════════"
        log_success "Hash generated for: $file"
        echo "═══════════════════════════════════════════════════════════"
        echo ""
        echo "Hash: $hash"
        echo ""
        echo "Add to frontmatter:"
        echo "  ---"
        echo "  hash: $hash"
        echo "  ---"
        echo ""
        echo "═══════════════════════════════════════════════════════════"
        ;;

    *)
        log_error "Unknown command: $MODE"
        show_help
        exit 1
        ;;
esac

# Show rollback instructions for update operations
if [ "$MODE" = "update" ] && [ "$DRY_RUN" = "false" ] && [ "$updated" -gt 0 ]; then
    echo ""
    generate_rollback_instructions \
        "document hash update" \
        "git restore <modified-files> (or git reset --hard HEAD if committed)"
fi
