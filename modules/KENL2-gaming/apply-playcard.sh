#!/usr/bin/env bash
#
# apply-playcard.sh - Apply a Play Card configuration to Steam game
#
# Usage: ./apply-playcard.sh <playcard.yaml>
#
# Version: 2.0.0
# ATOM: ATOM-GAMING-20251125-001

set -euo pipefail

# Source core libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KENL0_FUNCTIONS="${SCRIPT_DIR}/../KENL0-system/functions"

# shellcheck source=/dev/null
if [[ -f "$KENL0_FUNCTIONS/kenl-core.sh" ]]; then
    source "$KENL0_FUNCTIONS/kenl-core.sh"
else
    # Fallback: source basic functions from kenl-fallback.sh
    if [[ -f "$KENL0_FUNCTIONS/kenl-fallback.sh" ]]; then
        source "$KENL0_FUNCTIONS/kenl-fallback.sh"
    else
        echo "[✗] Fallback functions not found: $KENL0_FUNCTIONS/kenl-fallback.sh" >&2
        exit 1
    fi
fi

# shellcheck source=/dev/null
if [[ -f "$KENL0_FUNCTIONS/kenl-saif.sh" ]]; then
    source "$KENL0_FUNCTIONS/kenl-saif.sh"
fi

PLAYCARD="${1:-}"

if [[ -z "$PLAYCARD" ]] || [[ ! -f "$PLAYCARD" ]]; then
    kenl_error "Usage: $0 <playcard.yaml>"
    echo ""
    echo "Example: $0 play-cards/halo-infinite.yaml"
    exit 1
fi

kenl_header "Apply Play Card"
kenl_info "Processing: $PLAYCARD"
echo ""

# Check if yq is available for YAML parsing
if ! command -v yq &> /dev/null; then
    kenl_error "yq not found. Installing..."
    echo "   Run: flatpak install -y flathub com.github.mikefarah.yq"
    exit 1
fi

# Parse Play Card
GAME_NAME=$(yq eval '.game' "$PLAYCARD")
STEAM_APP_ID=$(yq eval '.configuration.steam_app_id' "$PLAYCARD")
PROTON_VERSION=$(yq eval '.configuration.proton' "$PLAYCARD")
LAUNCH_OPTIONS=$(yq eval '.configuration.launch_options' "$PLAYCARD")

echo "Game: $GAME_NAME"
echo "Steam App ID: $STEAM_APP_ID"
echo "Proton: $PROTON_VERSION"
echo "Launch Options: $LAUNCH_OPTIONS"
echo ""

if [[ "$STEAM_APP_ID" == "unknown" ]] || [[ "$STEAM_APP_ID" == "null" ]]; then
    kenl_warn "Steam App ID not set in Play Card"
    echo "   Find it at: https://steamdb.info/"
    read -rp "Enter Steam App ID: " STEAM_APP_ID
fi

# Proton setup
kenl_info "Setting Proton version..."
if [[ "$PROTON_VERSION" == *"GE"* ]]; then
    PROTON_PATH="$HOME/.local/share/Steam/compatibilitytools.d/$PROTON_VERSION"
    if [[ ! -d "$PROTON_PATH" ]]; then
        kenl_error "$PROTON_VERSION not found"
        echo "   Download from: https://github.com/GloriousEggroll/proton-ge-custom/releases"
        echo "   Extract to: $HOME/.local/share/Steam/compatibilitytools.d/"
        exit 1
    fi
    kenl_success "Found: $PROTON_PATH"
else
    kenl_success "Using Steam's built-in Proton: $PROTON_VERSION"
fi

# Set launch options
if [[ -n "$LAUNCH_OPTIONS" ]] && [[ "$LAUNCH_OPTIONS" != "null" ]]; then
    echo ""
    kenl_info "Launch Options to set in Steam:"
    echo "   Right-click game → Properties → Launch Options"
    echo ""
    echo "   $LAUNCH_OPTIONS"
    echo ""
fi

# MangoHud setup
MANGOHUD_ENABLED=$(yq eval '.configuration.mangohud' "$PLAYCARD")
if [[ "$MANGOHUD_ENABLED" == "true" ]]; then
    kenl_info "MangoHud enabled"
    MANGOHUD_CONFIG=$(yq eval '.configuration.mangohud_config' "$PLAYCARD")

    mkdir -p "$HOME/.config/MangoHud"
    echo "$MANGOHUD_CONFIG" > "$HOME/.config/MangoHud/MangoHud.conf"
    kenl_success "MangoHud config updated: ~/.config/MangoHud/MangoHud.conf"
fi

echo ""

# Generate SAIF result if available
if command -v new_saif_flag &> /dev/null; then
    flag=$(new_saif_flag "GAMING" "APPLY-PLAYCARD" "Applied Play Card for $GAME_NAME" "Success")
    write_saif_result "$flag" "Success" "Play Card applied for $GAME_NAME" \
        "Open Steam and find '$GAME_NAME' (App ID: $STEAM_APP_ID)" \
        "Set Proton version: $PROTON_VERSION" \
        "Launch game and test performance" \
        "$PLAYCARD"
else
    kenl_success "Play Card applied!"
    echo ""
    echo "📋 Next Steps:"
    echo "   1. Open Steam"
    echo "   2. Find '$GAME_NAME' (App ID: $STEAM_APP_ID)"
    echo "   3. Right-click → Properties → Compatibility"
    echo "   4. Force use: $PROTON_VERSION"
    if [[ -n "$LAUNCH_OPTIONS" ]] && [[ "$LAUNCH_OPTIONS" != "null" ]]; then
        echo "   5. Set launch options: $LAUNCH_OPTIONS"
    fi
    echo ""
    echo "   Then launch the game and test!"
fi

# Log with ATOM if available
if command -v atom &> /dev/null; then
    atom CONFIG "Applied Play Card for $GAME_NAME" "Proton: $PROTON_VERSION"
fi
