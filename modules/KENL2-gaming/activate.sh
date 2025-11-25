#!/usr/bin/env bash
#
# activate.sh - Activate KENL2 gaming module
#
# Requires: KENL1 framework already installed
#
# Version: 2.0.0
# ATOM: ATOM-GAMING-20251125-003

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
fi

# shellcheck source=/dev/null
if [[ -f "$KENL0_FUNCTIONS/kenl-saif.sh" ]]; then
    source "$KENL0_FUNCTIONS/kenl-saif.sh"
fi

kenl_info "🎮 Activating KENL2: Gaming Module"
echo ""

# Check if KENL1 installed
if ! command -v atom &> /dev/null; then
    kenl_warn "KENL1 framework not found (optional)"
    echo "   Install it for ATOM trail logging:"
    echo "   cd ../KENL1-framework/atom-sage-framework && ./install.sh"
fi

echo ""

# Create required directories
kenl_info "📁 Creating directories..."
mkdir -p play-cards
mkdir -p configs/{proton,mangohud,gamescope}
mkdir -p compat-tracking
mkdir -p windows-eol-migration

# Make scripts executable
kenl_info "🔧 Setting script permissions..."
chmod +x ./*.sh 2>/dev/null || true
chmod +x play-cards/*.sh 2>/dev/null || true

# Check for required tools
kenl_info "🔍 Checking dependencies..."

MISSING=()

if ! command -v steam &> /dev/null && ! flatpak list 2>/dev/null | grep -q Steam; then
    kenl_warn "Steam not found (should be pre-installed on Bazzite)"
    MISSING+=("steam")
fi

if ! command -v mangohud &> /dev/null; then
    kenl_warn "MangoHud not found (should be pre-installed on Bazzite)"
    MISSING+=("mangohud")
fi

if ! command -v gamescope &> /dev/null; then
    kenl_warn "GameScope not found (should be pre-installed on Bazzite)"
    MISSING+=("gamescope")
fi

if ! command -v yq &> /dev/null; then
    kenl_warn "yq not found - needed for Play Card parsing"
    echo "   Install: flatpak install -y flathub com.github.mikefarah.yq"
    MISSING+=("yq")
fi

if [[ ${#MISSING[@]} -eq 0 ]]; then
    kenl_success "All dependencies satisfied"
else
    echo ""
    kenl_warn "Missing dependencies: ${MISSING[*]}"
    echo "   KENL2 will have limited functionality"
fi

echo ""

# Generate SAIF result if available
if command -v new_saif_flag &> /dev/null; then
    status="Success"
    [[ ${#MISSING[@]} -gt 0 ]] && status="Warning"

    flag=$(new_saif_flag "GAMING" "ACTIVATE-KENL2" "KENL2 gaming module activated" "$status")
    write_saif_result "$flag" "$status" "KENL2 gaming module activated" \
        "Research a game: ./research-game.sh \"Game Name\"" \
        "Create Play Card: ./create-playcard.sh \"Game Name\"" \
        "Apply configuration: ./apply-playcard.sh play-cards/<game>.yaml" \
        "" \
        ""
else
    kenl_success "KENL2 activated!"
    echo ""
    echo "📋 Next Steps:"
    echo "   1. Research a game: ./research-game.sh \"Game Name\""
    echo "   2. Create Play Card: ./create-playcard.sh \"Game Name\""
    echo "   3. Apply configuration: ./apply-playcard.sh play-cards/game-name.yaml"
    echo "   4. Track performance: cd ../KENL4-monitoring/play-card-tracking && ./track-session.sh"
    echo ""
    echo "Switch context: cd ../KENL5-facades && ./switch-kenl.sh gaming"
fi

# Log with ATOM
if command -v atom &> /dev/null; then
    atom CONFIG "Activated KENL2 gaming module" "Dependencies: ${#MISSING[@]} missing"
fi
