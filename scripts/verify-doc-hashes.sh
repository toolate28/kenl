#!/usr/bin/env bash
# KENL Document Hash Verification Script
# ATOM: ATOM-SCRIPT-20251126-001
# Purpose: Verify integrity of versioned documents

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HASH_FILE="$REPO_ROOT/.doc-hashes"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Consistent pattern for hash field
HASH_PATTERN='^hash:'

echo "🔐 KENL Document Hash Verification"
echo "==================================="
echo ""

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

# Parse arguments
MODE="${1:-verify}"

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
        echo "Mode: Update Hashes"
        echo ""

        updated=0

        # Find all markdown files with frontmatter
        while IFS= read -r -d '' file; do
            if head -1 "$file" | grep -q "^---$"; then
                # Check if file has version field (only hash versioned files)
                if grep -q "^version:" "$file"; then
                    current_hash=$(compute_hash "$file")
                    stored_hash=$(extract_hash "$file")

                    if [[ "$stored_hash" != "$current_hash" ]]; then
                        update_hash "$file" "$current_hash"
                        echo -e "${GREEN}✅${NC} Updated: $file ($current_hash)"
                        updated=$((updated + 1))
                    fi
                fi
            fi
        done < <(find "$REPO_ROOT" -name "*.md" -type f -print0 2>/dev/null)

        echo ""
        echo "Updated: $updated files"
        ;;

    generate)
        echo "Mode: Generate Hash for File"
        echo ""

        if [[ -z "${2:-}" ]]; then
            echo "Usage: $0 generate <file>"
            exit 1
        fi

        file="$2"
        if [[ ! -f "$file" ]]; then
            echo "File not found: $file"
            exit 1
        fi

        hash=$(compute_hash "$file")
        echo "Hash for $file: $hash"
        echo ""
        echo "Add to frontmatter:"
        echo "hash: $hash"
        ;;

    *)
        echo "Usage: $0 [verify|update|generate <file>]"
        echo ""
        echo "Commands:"
        echo "  verify   - Check all document hashes (default)"
        echo "  update   - Update hashes for versioned files"
        echo "  generate - Generate hash for a specific file"
        exit 1
        ;;
esac
