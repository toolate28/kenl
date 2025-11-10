#!/usr/bin/env bash
#
# track-compatibility.sh - Track game compatibility status and update Play Card
#
# Usage: ./track-compatibility.sh "Game Name"
#

set -euo pipefail

GAME_NAME="${1:-}"

if [ -z "$GAME_NAME" ]; then
    echo "Usage: $0 \"Game Name\""
    echo ""
    echo "Example: $0 \"Cyberpunk 2077\""
    exit 1
fi

# Find Play Card
GAME_SLUG=$(echo "$GAME_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
PLAYCARD_FILE="play-cards/${GAME_SLUG}.yaml"

if [ ! -f "$PLAYCARD_FILE" ]; then
    echo "❌ Play Card not found: $PLAYCARD_FILE"
    echo "   Create one first: ./create-playcard.sh \"$GAME_NAME\""
    exit 1
fi

echo "🎮 Tracking compatibility for: $GAME_NAME"
echo ""

# Gather compatibility information
echo "Compatibility Rating:"
echo "  1) Platinum (perfect, no issues)"
echo "  2) Gold (works well with minor issues)"
echo "  3) Silver (works with workarounds)"
echo "  4) Bronze (barely playable)"
echo "  5) Borked (doesn't work)"
read -rp "Select rating (1-5): " RATING_NUM

case $RATING_NUM in
    1) RATING="platinum" ;;
    2) RATING="gold" ;;
    3) RATING="silver" ;;
    4) RATING="bronze" ;;
    5) RATING="borked" ;;
    *) RATING="untested" ;;
esac

read -rp "Anti-cheat status (none/supported/unsupported/unknown): " ANTI_CHEAT
read -rp "Multiplayer works? (yes/no/unknown): " MULTIPLAYER
read -rp "Any issues? (comma-separated, or 'none'): " ISSUES
read -rp "Any workarounds? (comma-separated, or 'none'): " WORKAROUNDS

# Check if yq available
if ! command -v yq &> /dev/null; then
    echo "❌ yq not found. Installing..."
    echo "   Run: flatpak install -y flathub com.github.mikefarah.yq"
    exit 1
fi

# Update Play Card
echo ""
echo "📝 Updating Play Card..."

yq eval -i ".compatibility.rating = \"$RATING\"" "$PLAYCARD_FILE"
yq eval -i ".compatibility.anti_cheat = \"$ANTI_CHEAT\"" "$PLAYCARD_FILE"
yq eval -i ".compatibility.multiplayer = \"$MULTIPLAYER\"" "$PLAYCARD_FILE"

# Update issues
if [ "$ISSUES" != "none" ]; then
    # Convert comma-separated to YAML array
    IFS=',' read -ra ISSUE_ARRAY <<< "$ISSUES"
    yq eval -i ".compatibility.issues = []" "$PLAYCARD_FILE"
    for issue in "${ISSUE_ARRAY[@]}"; do
        yq eval -i ".compatibility.issues += [\"${issue// /}\"]" "$PLAYCARD_FILE"
    done
fi

# Update workarounds
if [ "$WORKAROUNDS" != "none" ]; then
    IFS=',' read -ra WORKAROUND_ARRAY <<< "$WORKAROUNDS"
    yq eval -i ".compatibility.workarounds = []" "$PLAYCARD_FILE"
    for workaround in "${WORKAROUND_ARRAY[@]}"; do
        yq eval -i ".compatibility.workarounds += [\"${workaround// /}\"]" "$PLAYCARD_FILE"
    done
fi

# Update status
yq eval -i ".status = \"verified\"" "$PLAYCARD_FILE"
yq eval -i ".verified = \"$(date -u +\"%Y-%m-%d\")\"" "$PLAYCARD_FILE"

echo "✅ Play Card updated: $PLAYCARD_FILE"
echo ""
echo "Summary:"
echo "  Rating: $RATING"
echo "  Anti-cheat: $ANTI_CHEAT"
echo "  Multiplayer: $MULTIPLAYER"
echo ""

# Log with ATOM if available
if command -v atom &> /dev/null; then
    atom STATUS "Tracked compatibility for $GAME_NAME: $RATING" "$PLAYCARD_FILE"
fi

echo "Next steps:"
echo "  1. Validate: ./play-cards/validate-playcard.sh $PLAYCARD_FILE"
echo "  2. Share with community: ./share-playcard.sh $PLAYCARD_FILE"
