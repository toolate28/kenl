#!/usr/bin/env bash
#
# activate.sh - Activate KENL2 gaming module
#
# Requires: KENL1 framework already installed
#

set -euo pipefail

echo "🎮 Activating KENL2: Gaming Module"
echo ""

# Check if KENL1 installed
if ! command -v atom &> /dev/null; then
    echo "❌ KENL1 framework not found!"
    echo "   Install it first:"
    echo "   cd ../KENL1-framework/atom-sage-framework && ./install.sh"
    exit 1
fi

echo "✅ KENL1 framework detected"
echo ""

# Create required directories
echo "📁 Creating directories..."
mkdir -p play-cards
mkdir -p configs/{proton,mangohud,gamescope}
mkdir -p compat-tracking
mkdir -p windows-eol-migration

# Make scripts executable
echo "🔧 Setting script permissions..."
chmod +x ./*.sh 2>/dev/null || true
chmod +x play-cards/*.sh 2>/dev/null || true

# Check for required tools
echo "🔍 Checking dependencies..."

MISSING=()

if ! command -v steam &> /dev/null; then
    echo "⚠️  Steam not found (should be pre-installed on Bazzite)"
    MISSING+=("steam")
fi

if ! command -v mangohud &> /dev/null; then
    echo "⚠️  MangoHud not found (should be pre-installed on Bazzite)"
    MISSING+=("mangohud")
fi

if ! command -v gamescope &> /dev/null; then
    echo "⚠️  GameScope not found (should be pre-installed on Bazzite)"
    MISSING+=("gamescope")
fi

if ! command -v yq &> /dev/null; then
    echo "⚠️  yq not found - needed for Play Card parsing"
    echo "   Install: flatpak install -y flathub com.github.mikefarah.yq"
    MISSING+=("yq")
fi

if [ ${#MISSING[@]} -eq 0 ]; then
    echo "✅ All dependencies satisfied"
else
    echo ""
    echo "⚠️  Missing dependencies: ${MISSING[*]}"
    echo "   KENL2 will have limited functionality"
fi

echo ""
echo "✅ KENL2 activated!"
echo ""
echo "Next steps:"
echo "  1. Research a game: ./research-game.sh \"Game Name\""
echo "  2. Create Play Card: ./create-playcard.sh \"Game Name\""
echo "  3. Apply configuration: ./apply-playcard.sh play-cards/game-name.yaml"
echo "  4. Track performance: cd ../KENL4-monitoring/play-card-tracking && ./track-session.sh"
echo ""
echo "Switch context: cd ../KENL5-facades && ./switch-kenl.sh gaming"

# Log with ATOM
atom CONFIG "Activated KENL2 gaming module" "Dependencies: ${#MISSING[@]} missing"
