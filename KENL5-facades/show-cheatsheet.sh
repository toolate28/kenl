#!/usr/bin/env bash
#
# show-cheatsheet.sh - Display KENL context cheatsheet
#
# Usage:
#   ./show-cheatsheet.sh 0          # Show KENL0 cheatsheet
#   ./show-cheatsheet.sh gaming     # Show KENL2 cheatsheet
#   ./show-cheatsheet.sh            # Show current context cheatsheet

set -euo pipefail

KENL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHEATSHEET_DIR="$KENL_DIR/cheatsheets"

# Determine which KENL context to show
if [[ $# -eq 0 ]]; then
    # No argument - use current context from environment
    KENL_NUM="${KENL_CONTEXT##*KENL}"
    KENL_NUM="${KENL_NUM%%-*}"
else
    # Argument provided
    case "${1,,}" in
        0|system|kenl0)
            KENL_NUM="0"
            ;;
        1|framework|kenl1)
            KENL_NUM="1"
            ;;
        2|gaming|kenl2)
            KENL_NUM="2"
            ;;
        3|dev|development|kenl3)
            KENL_NUM="3"
            ;;
        4|monitoring|kenl4)
            KENL_NUM="4"
            ;;
        5|facades|theming|kenl5)
            KENL_NUM="5"
            ;;
        6|social|kenl6)
            KENL_NUM="6"
            ;;
        8|security|kenl8)
            KENL_NUM="8"
            ;;
        10|backup|kenl10)
            KENL_NUM="10"
            ;;
        *)
            echo "Unknown KENL context: $1"
            echo "Usage: $0 [0|1|2|3|4|5|6|8|10]"
            exit 1
            ;;
    esac
fi

# Find cheatsheet file
CHEATSHEET_FILE="$CHEATSHEET_DIR/kenl${KENL_NUM}-cheatsheet.txt"

if [[ ! -f "$CHEATSHEET_FILE" ]]; then
    echo "⚠️  Cheatsheet not found for KENL${KENL_NUM}"
    echo "Expected: $CHEATSHEET_FILE"
    exit 1
fi

# Display cheatsheet
cat "$CHEATSHEET_FILE"

# Optional: Display at bottom of terminal
# (If terminal supports, could set as background image)
echo ""
echo "💡 TIP: Add 'show-cheatsheet' to your shell RC to display on startup"
echo "        Add to ~/.bashrc: alias cheat='~/kenl/KENL5-facades/show-cheatsheet.sh'"
