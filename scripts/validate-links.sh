#!/bin/bash
# KENL Link Validator
# Catches broken internal links before they hit production
# Usage: ./scripts/validate-links.sh [--fix]

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0
FIX_MODE=false

[[ "${1:-}" == "--fix" ]] && FIX_MODE=true

echo "🔍 KENL Link Validator"
echo "====================="
echo

# Function to check if a file/directory exists
check_link() {
    local file="$1"
    local link="$2"
    local line="$3"

    # Check if it's a full URL (skip external links)
    if [[ "$link" =~ ^https?:// ]]; then
        return 0
    fi

    # Skip template placeholders like {URL}, {{var}}, etc.
    if [[ "$link" =~ ^\{.*\}$ ]]; then
        return 0
    fi

    # Skip anchor links (internal page references)
    if [[ "$link" =~ ^# ]]; then
        return 0
    fi

    # Convert markdown link to filesystem path
    local target="$link"

    # Strip anchor (# fragment) if present - we only check if file exists
    target="${target%%#*}"

    # If relative link, resolve from file's directory
    if [[ "$target" != /* ]]; then
        local file_dir=$(dirname "$file")
        target="$file_dir/$target"
    fi

    # Remove trailing /
    target="${target%/}"

    # Try to resolve the path (handle ../ and ./)
    if command -v realpath &>/dev/null; then
        target=$(realpath -m "$target" 2>/dev/null || echo "$target")
    fi

    # Check if target exists
    if [[ ! -e "$target" ]]; then
        echo -e "${RED}❌ BROKEN LINK${NC} in $file:$line"
        echo "   Link: $link"
        echo "   Expected: $target"
        ((ERRORS++))

        # Suggest fixes for common patterns
        if [[ "$link" =~ KENL[0-9]+ ]]; then
            local module=$(echo "$link" | grep -oP 'KENL[0-9]+')
            if [[ -d "modules/${module}-"* ]]; then
                local actual=$(ls -d modules/${module}-* 2>/dev/null | head -1)
                echo -e "   ${YELLOW}💡 Did you mean: ./$actual/${NC}"
            fi
        fi
        echo
        return 1
    fi
    return 0
}

# Function to validate footnote references
check_footnotes() {
    local file="$1"

    # Extract footnote references [^1], [^2], etc.
    local refs=$(grep -oP '\[\^[0-9]+\]' "$file" 2>/dev/null | sort -u)

    # Extract footnote definitions
    local defs=$(grep -oP '^\[\^[0-9]+\]:' "$file" 2>/dev/null | sed 's/:$//' | sort -u)

    # Check if all references have definitions
    while IFS= read -r ref; do
        if ! echo "$defs" | grep -q "^$ref$"; then
            echo -e "${RED}❌ MISSING FOOTNOTE${NC} in $file"
            echo "   Reference: $ref has no definition"
            ((ERRORS++))
        fi
    done <<< "$refs"

    # Check if all definitions are used
    while IFS= read -r def; do
        if ! echo "$refs" | grep -q "^$def$"; then
            echo -e "${YELLOW}⚠️  UNUSED FOOTNOTE${NC} in $file"
            echo "   Definition: $def is never referenced"
            ((WARNINGS++))
        fi
    done <<< "$defs"
}

# Function to check for old path patterns
check_old_patterns() {
    local file="$1"

    # Pattern 1: Direct KENL links (should be modules/KENL)
    if grep -qP '\]\(\.\/KENL[0-9]' "$file" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  OLD PATH PATTERN${NC} in $file"
        echo "   Found: ](./KENL*"
        echo "   Should be: ](./modules/KENL*"
        ((WARNINGS++))
    fi

    # Pattern 2: Windows-style backslashes
    if grep -qP '\]\([^)]*\\' "$file" 2>/dev/null; then
        echo -e "${RED}❌ WINDOWS PATH${NC} in $file"
        echo "   Found: Backslashes in markdown link"
        echo "   Should use: Forward slashes"
        ((ERRORS++))
    fi
}

# Main validation loop
echo "📝 Checking markdown files for broken links..."
echo

# Find all markdown files (excluding .git, node_modules)
while IFS= read -r file; do
    # Extract markdown links: [text](./path/to/file)
    while IFS= read -r line_info; do
        line_num=$(echo "$line_info" | cut -d: -f1)
        line_content=$(echo "$line_info" | cut -d: -f2-)

        # Extract all links from this line
        while IFS= read -r link; do
            [[ -z "$link" ]] && continue
            check_link "$file" "$link" "$line_num"
        done < <(echo "$line_content" | grep -oP '\]\(\K[^)]+' || true)
    done < <(grep -n '](.*' "$file" | cat)

    # Check footnotes
    check_footnotes "$file"

    # Check for old patterns
    check_old_patterns "$file"

done < <(find . -name "*.md" -type f \
    ! -path "./.git/*" \
    ! -path "./node_modules/*" \
    ! -path "./vendor/*")

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [[ $ERRORS -eq 0 ]] && [[ $WARNINGS -eq 0 ]]; then
    echo -e "${GREEN}✅ All links valid!${NC}"
    exit 0
elif [[ $ERRORS -eq 0 ]]; then
    echo -e "${YELLOW}⚠️  $WARNINGS warnings (non-critical)${NC}"
    exit 0
else
    echo -e "${RED}❌ $ERRORS errors, $WARNINGS warnings${NC}"
    echo
    echo "Fix broken links and run again:"
    echo "  ./scripts/validate-links.sh"
    exit 1
fi
