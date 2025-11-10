#!/usr/bin/env bash
#
# research-game.sh - Research game compatibility on ProtonDB and community sources
#
# Usage: ./research-game.sh "Game Name"
#

set -euo pipefail

GAME_NAME="${1:-}"

if [ -z "$GAME_NAME" ]; then
    echo "Usage: $0 \"Game Name\""
    echo ""
    echo "Example: $0 \"Elden Ring\""
    exit 1
fi

echo "🔍 Researching: $GAME_NAME"
echo ""

# Sanitize game name for URLs
GAME_SLUG=$(echo "$GAME_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')

echo "📚 ProtonDB:"
echo "   https://www.protondb.com/search?q=${GAME_NAME// /+}"
echo ""

echo "🎮 Steam Deck Verified:"
echo "   https://www.steamdeck.com/en/verified"
echo ""

echo "🐧 Bazzite Gaming Wiki:"
echo "   https://universal-blue.discourse.group/docs?topic=37"
echo ""

echo "💬 Reddit r/linux_gaming:"
echo "   https://www.reddit.com/r/linux_gaming/search/?q=${GAME_NAME// /+}"
echo ""

echo "🔧 Proton GE Releases:"
echo "   https://github.com/GloriousEggroll/proton-ge-custom/releases"
echo ""

echo "📊 Are We Anti-Cheat Yet:"
echo "   https://areweanticheatyet.com/?q=${GAME_NAME// /+}"
echo ""

# If atom command available, log research
if command -v atom &> /dev/null; then
    atom RESEARCH "Researched game: $GAME_NAME" "ProtonDB + community sources"
fi

echo "✅ Research complete!"
echo ""
echo "Next steps:"
echo "  1. Check ProtonDB for compatibility rating"
echo "  2. Find best Proton version from reports"
echo "  3. Note any required launch options"
echo "  4. Create Play Card: ./create-playcard.sh \"$GAME_NAME\""
