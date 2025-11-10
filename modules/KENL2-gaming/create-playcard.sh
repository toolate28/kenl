#!/usr/bin/env bash
#
# create-playcard.sh - Create a new Play Card for a game
#
# Usage: ./create-playcard.sh "Game Name"
#

set -euo pipefail

GAME_NAME="${1:-}"

if [ -z "$GAME_NAME" ]; then
    echo "Usage: $0 \"Game Name\""
    echo ""
    echo "Example: $0 \"Halo Infinite\""
    exit 1
fi

# Sanitize game name for filename
GAME_SLUG=$(echo "$GAME_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
PLAYCARD_FILE="play-cards/${GAME_SLUG}.yaml"

if [ -f "$PLAYCARD_FILE" ]; then
    echo "❌ Play Card already exists: $PLAYCARD_FILE"
    echo "   Use a different name or edit the existing card"
    exit 1
fi

echo "📝 Creating Play Card: $GAME_NAME"
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

echo "✅ Play Card created: $PLAYCARD_FILE"
echo ""
echo "Next steps:"
echo "  1. Edit $PLAYCARD_FILE with accurate information"
echo "  2. Test the game and update performance metrics"
echo "  3. Apply the Play Card: ./apply-playcard.sh $PLAYCARD_FILE"
echo "  4. Validate: ./play-cards/validate-playcard.sh $PLAYCARD_FILE"
echo "  5. Share: ./share-playcard.sh $PLAYCARD_FILE"

# Log with ATOM if available
if command -v atom &> /dev/null; then
    atom CONFIG "Created Play Card for $GAME_NAME" "$PLAYCARD_FILE"
fi
