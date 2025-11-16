#!/usr/bin/env bash
#───────────────────────────────────────────────────────────────────────────────
# Play Card Validation Tool
# Validates play card YAML format and required fields
#───────────────────────────────────────────────────────────────────────────────

set -euo pipefail

VERSION="1.0.0"

show_help() {
    cat << EOF
Play Card Validation Tool v${VERSION}

Usage: $(basename "$0") PLAYCARD_FILE

Validates play card YAML format and required fields.

Example:
    $(basename "$0") bg3-001.yaml

Checks:
    ✓ Valid YAML syntax
    ✓ Required fields present (id, game, proton_version, etc.)
    ✓ Field value formats
    ✓ ATOM tag reference validity
EOF
}

check_yaml_syntax() {
    local file="$1"

    if command -v python3 &>/dev/null; then
        if python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
            return 0
        else
            return 1
        fi
    else
        # Fallback: basic check
        if grep -q "^[a-z_]*:" "$file" 2>/dev/null; then
            return 0
        else
            return 1
        fi
    fi
}

check_required_field() {
    local file="$1"
    local field="$2"

    if grep -q "^${field}:" "$file"; then
        return 0
    else
        return 1
    fi
}

extract_field() {
    local file="$1"
    local field="$2"

    grep "^${field}:" "$file" | sed "s/^${field}: *//" | sed 's/"//g' | sed "s/'//g"
}

validate_atom_tag() {
    local tag="$1"

    if echo "$tag" | grep -q "^ATOM-[A-Z]*-[0-9]\{8\}-[0-9]\{3\}$"; then
        return 0
    else
        return 1
    fi
}

main() {
    local playcard_file=""

    # Parse arguments
    if [ $# -eq 0 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        show_help
        exit 0
    fi

    playcard_file="$1"

    if [ ! -f "$playcard_file" ]; then
        echo "✗ File not found: $playcard_file"
        exit 1
    fi

    echo "════════════════════════════════════════════════════════════"
    echo "  Play Card Validation"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    echo "Validating: $playcard_file"
    echo ""

    local errors=0
    local warnings=0

    # Check 1: YAML syntax
    echo -n "[1/8] Checking YAML syntax... "
    if check_yaml_syntax "$playcard_file"; then
        echo "✓"
    else
        echo "✗ Invalid YAML syntax"
        ((errors++))
    fi

    # Check 2: Required fields
    local required_fields=("id" "game" "proton_version" "compatibility")

    for field in "${required_fields[@]}"; do
        echo -n "[2/8] Checking field '$field'... "
        if check_required_field "$playcard_file" "$field"; then
            echo "✓"
        else
            echo "✗ Missing required field"
            ((errors++))
        fi
    done

    # Check 3: ID format
    echo -n "[3/8] Checking ID format... "
    local card_id
    card_id=$(extract_field "$playcard_file" "id" || echo "")
    if [ -n "$card_id" ] && echo "$card_id" | grep -q "^[A-Z0-9-]*$"; then
        echo "✓ ($card_id)"
    else
        echo "⚠ Non-standard ID format"
        ((warnings++))
    fi

    # Check 4: Compatibility rating
    echo -n "[4/8] Checking compatibility rating... "
    local compat
    compat=$(extract_field "$playcard_file" "compatibility" || echo "")
    if [ "$compat" = "platinum" ] || [ "$compat" = "gold" ] || \
       [ "$compat" = "silver" ] || [ "$compat" = "bronze" ] || \
       [ "$compat" = "borked" ]; then
        echo "✓ ($compat)"
    else
        echo "⚠ Unknown rating: $compat"
        ((warnings++))
    fi

    # Check 5: Proton version
    echo -n "[5/8] Checking Proton version... "
    local proton
    proton=$(extract_field "$playcard_file" "proton_version" || echo "")
    if [ -n "$proton" ]; then
        echo "✓ ($proton)"
    else
        echo "✗ Missing Proton version"
        ((errors++))
    fi

    # Check 6: ATOM tag reference
    echo -n "[6/8] Checking ATOM tag... "
    if check_required_field "$playcard_file" "atom_tag"; then
        local atom_tag
        atom_tag=$(extract_field "$playcard_file" "atom_tag" || echo "")
        if validate_atom_tag "$atom_tag"; then
            echo "✓ ($atom_tag)"
        else
            echo "⚠ Invalid ATOM tag format: $atom_tag"
            ((warnings++))
        fi
    else
        echo "⚠ No ATOM tag reference (recommended)"
        ((warnings++))
    fi

    # Check 7: Performance section
    echo -n "[7/8] Checking performance section... "
    if check_required_field "$playcard_file" "performance"; then
        echo "✓"
    else
        echo "⚠ No performance data (optional)"
        ((warnings++))
    fi

    # Check 8: Validation status
    echo -n "[8/8] Overall validation... "
    if [ $errors -eq 0 ]; then
        echo "✓"
    else
        echo "✗"
    fi

    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "  Validation Summary"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    echo "Errors:   $errors"
    echo "Warnings: $warnings"
    echo ""

    if [ $errors -eq 0 ]; then
        echo "✓ Play card is valid!"
        if [ $warnings -gt 0 ]; then
            echo "  (Consider addressing warnings)"
        fi
        exit 0
    else
        echo "✗ Play card has errors - please fix before sharing"
        exit 1
    fi
}

main "$@"
