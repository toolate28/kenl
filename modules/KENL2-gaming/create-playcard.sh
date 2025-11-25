#!/usr/bin/env bash
#
# create-playcard.sh - Create a new Play Card for a game
#
# Usage: ./create-playcard.sh "Game Name"
#
# Version: 2.0.0
# ATOM: ATOM-GAMING-20251125-002

set -euo pipefail

# Source core libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KENL0_FUNCTIONS="${SCRIPT_DIR}/../KENL0-system/functions"

# shellcheck source=/dev/null
if [[ -f "$KENL0_FUNCTIONS/kenl-core.sh" ]]; then
    source "$KENL0_FUNCTIONS/kenl-core.sh"
else
    kenl_info() { echo "[ℹ] $*"; }
    kenl_success() { echo "[✓] $*"; }
    kenl_warn() { echo "[⚠] $*" >&2; }
    kenl_error() { echo "[✗] $*" >&2; }
    kenl_header() { echo "=== $1 ==="; }
fi

# shellcheck source=/dev/null
if [[ -f "$KENL0_FUNCTIONS/kenl-saif.sh" ]]; then
    source "$KENL0_FUNCTIONS/kenl-saif.sh"
fi

GAME_NAME="${1:-}"

if [[ -z "$GAME_NAME" ]]; then
    kenl_error "Usage: $0 \"Game Name\""
    echo ""
    echo "Example: $0 \"Halo Infinite\""
    exit 1
fi

# Sanitize game name for filename
GAME_SLUG=$(echo "$GAME_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
PLAYCARD_FILE="play-cards/${GAME_SLUG}.yaml"

if [[ -f "$PLAYCARD_FILE" ]]; then
    kenl_error "Play Card already exists: $PLAYCARD_FILE"
    echo "   Use a different name or edit the existing card"
    exit 1
fi

kenl_header "Create Play Card"
kenl_info "Creating Play Card: $GAME_NAME"
echo ""

# Gather information
read -rp "Proton version (e.g., GE-Proton 9-18): " PROTON_VERSION
read -rp "Steam App ID (optional): " STEAM_APP_ID
read -rp "Launch options (optional): " LAUNCH_OPTIONS
read -rp "GPU model: " GPU_MODEL
read -rp "CPU model: " CPU_MODEL
read -rp "Average FPS (if tested): " FPS_AVG
read -rp "1% low FPS (if tested): " FPS_1_LOW

# Create Play Card
cat > "$PLAYCARD_FILE" <<EOF
---
# Play Card: $GAME_NAME
# Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
# Status: draft

game: "$GAME_NAME"
verified: $(date -u +"%Y-%m-%d")
status: testing  # draft, testing, verified, deprecated

hardware:
  gpu: "${GPU_MODEL:-Unknown}"
  cpu: "${CPU_MODEL:-Unknown}"
  ram: "16GB"  # Update this

configuration:
  proton: "${PROTON_VERSION:-GE-Proton latest}"
  steam_app_id: "${STEAM_APP_ID:-unknown}"
  launch_options: "${LAUNCH_OPTIONS:-}"

  # MangoHud settings
  mangohud: true
  mangohud_config: |
    fps_limit=0
    vsync=0
    gpu_stats
    cpu_stats
    fps
    frametime

performance:
  fps_avg: ${FPS_AVG:-0}
  fps_1_percent_low: ${FPS_1_LOW:-0}
  fps_0_1_percent_low: 0
  resolution: "1920x1080"
  graphics_preset: "High"

compatibility:
  rating: untested  # platinum, gold, silver, bronze, borked, untested
  anti_cheat: unknown
  multiplayer: unknown
  issues: []
  workarounds: []

notes: |
  Initial Play Card created - needs testing!

tags:
  - draft
  - needs-verification

references:
  - protondb: "https://www.protondb.com/search?q=${GAME_NAME// /+}"
EOF

# Generate SAIF result if available
if command -v new_saif_flag &> /dev/null; then
    flag=$(new_saif_flag "GAMING" "CREATE-PLAYCARD" "Created Play Card for $GAME_NAME" "Success")
    write_saif_result "$flag" "Success" "Play Card created: $PLAYCARD_FILE" \
        "Edit the file: \$EDITOR $PLAYCARD_FILE" \
        "Test and update performance metrics" \
        "Apply: ./apply-playcard.sh $PLAYCARD_FILE" \
        "$PLAYCARD_FILE"
else
    kenl_success "Play Card created: $PLAYCARD_FILE"
    echo ""
    echo "📋 Next Steps:"
    echo "   1. Edit $PLAYCARD_FILE with accurate information"
    echo "   2. Test the game and update performance metrics"
    echo "   3. Apply: ./apply-playcard.sh $PLAYCARD_FILE"
    echo "   4. Validate: ./play-cards/validate-playcard.sh $PLAYCARD_FILE"
    echo "   5. Share: ./share-playcard.sh $PLAYCARD_FILE"
fi

# Log with ATOM if available
if command -v atom &> /dev/null; then
    atom CONFIG "Created Play Card for $GAME_NAME" "$PLAYCARD_FILE"
fi
