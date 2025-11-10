#!/usr/bin/env bash
#
# compare-configs.sh - Compare two Play Card configurations
#
# Usage: ./compare-configs.sh <playcard1.yaml> <playcard2.yaml>
#

set -euo pipefail

PLAYCARD1="${1:-}"
PLAYCARD2="${2:-}"

if [ -z "$PLAYCARD1" ] || [ ! -f "$PLAYCARD1" ] || [ -z "$PLAYCARD2" ] || [ ! -f "$PLAYCARD2" ]; then
    echo "Usage: $0 <playcard1.yaml> <playcard2.yaml>"
    echo ""
    echo "Example: $0 play-cards/halo-ge918.yaml play-cards/halo-ge919.yaml"
    exit 1
fi

# Check if yq available
if ! command -v yq &> /dev/null; then
    echo "❌ yq not found. Installing..."
    echo "   Run: flatpak install -y flathub com.github.mikefarah.yq"
    exit 1
fi

echo "🔍 Comparing Play Cards"
echo ""

# Parse Play Cards
GAME1=$(yq eval '.game' "$PLAYCARD1")
GAME2=$(yq eval '.game' "$PLAYCARD2")
PROTON1=$(yq eval '.configuration.proton' "$PLAYCARD1")
PROTON2=$(yq eval '.configuration.proton' "$PLAYCARD2")
FPS1=$(yq eval '.performance.fps_avg' "$PLAYCARD1")
FPS2=$(yq eval '.performance.fps_avg' "$PLAYCARD2")
FPS1_LOW1=$(yq eval '.performance.fps_1_percent_low' "$PLAYCARD1")
FPS1_LOW2=$(yq eval '.performance.fps_1_percent_low' "$PLAYCARD2")
FRAMETIME1=$(yq eval '.performance.frame_time_avg_ms // 0' "$PLAYCARD1")
FRAMETIME2=$(yq eval '.performance.frame_time_avg_ms // 0' "$PLAYCARD2")
LAUNCH1=$(yq eval '.configuration.launch_options' "$PLAYCARD1")
LAUNCH2=$(yq eval '.configuration.launch_options' "$PLAYCARD2")

# Calculate differences
FPS_DIFF=$(echo "scale=1; (($FPS2 - $FPS1) / $FPS1) * 100" | bc 2>/dev/null || echo "0")
FPS1_LOW_DIFF=$(echo "scale=1; (($FPS1_LOW2 - $FPS1_LOW1) / $FPS1_LOW1) * 100" | bc 2>/dev/null || echo "0")

# Display comparison
echo "┌─────────────────────────────────────────────────────────────┐"
echo "│ Play Card Comparison: $GAME1"
echo "├─────────────────────────────────────────────────────────────┤"
echo "│ Metric                 │ Config 1        │ Config 2        │ Δ      │"
echo "├─────────────────────────────────────────────────────────────┤"
printf "│ %-22s │ %-15s │ %-15s │        │\n" "Proton" "$PROTON1" "$PROTON2"
printf "│ %-22s │ %-15s │ %-15s │ %+.1f%% │\n" "FPS avg" "$FPS1" "$FPS2" "$FPS_DIFF"
printf "│ %-22s │ %-15s │ %-15s │ %+.1f%% │\n" "FPS 1% low" "$FPS1_LOW1" "$FPS1_LOW2" "$FPS1_LOW_DIFF"

if [ "$FRAMETIME1" != "0" ] && [ "$FRAMETIME2" != "0" ]; then
    FRAMETIME_DIFF=$(echo "scale=1; (($FRAMETIME2 - $FRAMETIME1) / $FRAMETIME1) * 100" | bc 2>/dev/null || echo "0")
    printf "│ %-22s │ %-15s │ %-15s │ %+.1f%% │\n" "Frame time (ms)" "$FRAMETIME1" "$FRAMETIME2" "$FRAMETIME_DIFF"
fi

echo "└─────────────────────────────────────────────────────────────┘"
echo ""

# Launch options diff
if [ "$LAUNCH1" != "$LAUNCH2" ]; then
    echo "Launch Options Difference:"
    echo "  Config 1: $LAUNCH1"
    echo "  Config 2: $LAUNCH2"
    echo ""
fi

# Recommendation
if (( $(echo "$FPS_DIFF > 5" | bc -l 2>/dev/null || echo 0) )); then
    echo "✅ Recommendation: Config 2 shows significant improvement (+${FPS_DIFF}%)"
    WINNER="$PLAYCARD2"
elif (( $(echo "$FPS_DIFF < -5" | bc -l 2>/dev/null || echo 0) )); then
    echo "❌ Recommendation: Config 1 performs better (Config 2 is ${FPS_DIFF}% worse)"
    WINNER="$PLAYCARD1"
else
    echo "⚖️  Recommendation: Both configs perform similarly (difference: ${FPS_DIFF}%)"
    WINNER="either"
fi

echo ""
echo "Files compared:"
echo "  1. $PLAYCARD1"
echo "  2. $PLAYCARD2"

# Log with ATOM if available
if command -v atom &> /dev/null; then
    atom STATUS "Compared Play Cards for $GAME1" "Winner: $WINNER (FPS diff: ${FPS_DIFF}%)"
fi
