#!/usr/bin/env bash
# share-playcard.sh
# Share Play Cards via Matrix/Discord with encryption
# Integrates KENL2 (gaming), KENL8 (security), KENL6 (social)

set -euo pipefail

KENL6_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAYCARD_DIR="$HOME/kenl/KENL2-gaming/play-cards"
KENL8_GPG="$HOME/kenl/KENL8-security/gpg-keyring"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

# Check dependencies
check_deps() {
    local missing=()

    [ ! -d "$PLAYCARD_DIR" ] && missing+=("KENL2-gaming")
    [ ! -d "$KENL8_GPG" ] && missing+=("KENL8-security")

    if [ ${#missing[@]} -gt 0 ]; then
        echo "Missing dependencies: ${missing[*]}"
        echo "Install required KENLs first"
        exit 1
    fi
}

# List available Play Cards
list_playcards() {
    echo -e "${BOLD}Available Play Cards:${RESET}"
    echo ""

    local cards=($(ls "$PLAYCARD_DIR"/*.yaml 2>/dev/null || true))

    if [ ${#cards[@]} -eq 0 ]; then
        echo "No Play Cards found in $PLAYCARD_DIR"
        return 1
    fi

    local i=1
    for card in "${cards[@]}"; do
        local name=$(basename "$card" .yaml)
        local game=$(grep "^game:" "$card" 2>/dev/null | cut -d'"' -f2 || echo "Unknown")
        echo "  $i) $name - $game"
        ((i++))
    done
    echo ""
}

# Share via Matrix
share_matrix() {
    local playcard="$1"
    local room="${2:-}"

    echo -e "${CYAN}Sharing via Matrix...${RESET}"

    # Check if matrix-commander is installed
    if ! command -v matrix-commander &> /dev/null; then
        echo "matrix-commander not found"
        echo ""
        echo "Install: pipx install matrix-commander"
        echo "Or: flatpak install flathub io.github.jfreegman.Toxic"
        return 1
    fi

    # Encrypt Play Card first (via KENL8)
    local encrypted="$playcard.gpg"
    "$KENL8_GPG/encrypt-file.sh" "$playcard" "$encrypted"

    # Send to Matrix room
    if [ -n "$room" ]; then
        matrix-commander --room "$room" --file "$encrypted" --message "New Play Card shared!"
        echo -e "${GREEN}✅ Shared to Matrix room: $room${RESET}"
    else
        echo "Enter Matrix room ID (e.g., !abc123:matrix.org):"
        read -r room
        matrix-commander --room "$room" --file "$encrypted" --message "New Play Card shared!"
        echo -e "${GREEN}✅ Shared to Matrix room: $room${RESET}"
    fi

    # Clean up encrypted file
    rm -f "$encrypted"
}

# Share via Discord webhook
share_discord() {
    local playcard="$1"
    local webhook="${2:-}"

    echo -e "${CYAN}Sharing via Discord...${RESET}"

    # Encrypt Play Card first
    local encrypted="$playcard.gpg"
    "$KENL8_GPG/encrypt-file.sh" "$playcard" "$encrypted"

    if [ -z "$webhook" ]; then
        echo "Enter Discord webhook URL:"
        read -r webhook
    fi

    # Upload via webhook
    curl -X POST "$webhook" \
        -F "content=New Play Card shared!" \
        -F "file=@$encrypted"

    echo -e "${GREEN}✅ Shared to Discord${RESET}"

    # Clean up
    rm -f "$encrypted"
}

# Generate shareable link (via KENL10 backup cloud sync)
share_link() {
    local playcard="$1"

    echo -e "${CYAN}Generating shareable link...${RESET}"

    # Encrypt first
    local encrypted="$playcard.gpg"
    "$KENL8_GPG/encrypt-file.sh" "$playcard" "$encrypted"

    # Upload to configured cloud backend (from KENL10)
    local link=$("$HOME/kenl/KENL10-backup/cloud-backends/upload.sh" "$encrypted")

    echo -e "${GREEN}✅ Play Card uploaded${RESET}"
    echo ""
    echo -e "${BOLD}Shareable link:${RESET}"
    echo "$link"
    echo ""
    echo "Recipients need your GPG public key to decrypt"

    # Clean up
    rm -f "$encrypted"
}

# Create community profile from Play Cards
create_profile() {
    echo -e "${CYAN}Creating community profile...${RESET}"

    local profile="$KENL6_ROOT/community-profiles/$(whoami).json"

    # Gather stats from Play Cards
    local total_cards=$(ls "$PLAYCARD_DIR"/*.yaml 2>/dev/null | wc -l)
    local games=($(find "$PLAYCARD_DIR" -name "*.yaml" -exec grep "^game:" {} \; | cut -d'"' -f2 | sort -u))

    cat > "$profile" <<EOF
{
  "username": "$(whoami)",
  "play_cards": $total_cards,
  "games": [
$(printf '    "%s",\n' "${games[@]}" | sed '$ s/,$//')
  ],
  "preferences": {
    "platform": "Bazzite",
    "proton_version": "GE-Proton",
    "share_method": "matrix"
  },
  "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

    echo -e "${GREEN}✅ Profile created: $profile${RESET}"
    cat "$profile"
}

# Main menu
main() {
    check_deps

    echo "════════════════════════════════════════════════════════════"
    echo "  KENL6: Play Card Sharing"
    echo "════════════════════════════════════════════════════════════"
    echo ""

    list_playcards

    echo "Select Play Card to share:"
    read -r selection

    local cards=($(ls "$PLAYCARD_DIR"/*.yaml 2>/dev/null))
    local playcard="${cards[$((selection-1))]}"

    if [ ! -f "$playcard" ]; then
        echo "Invalid selection"
        exit 1
    fi

    echo ""
    echo "Share via:"
    echo "  1) Matrix (encrypted)"
    echo "  2) Discord webhook (encrypted)"
    echo "  3) Generate shareable link"
    echo "  4) Create community profile"
    echo ""
    read -p "Select method [1-4]: " method

    case "$method" in
        1)
            share_matrix "$playcard"
            ;;
        2)
            share_discord "$playcard"
            ;;
        3)
            share_link "$playcard"
            ;;
        4)
            create_profile
            ;;
        *)
            echo "Invalid method"
            exit 1
            ;;
    esac

    # Log to ATOM trail
    if command -v atom &> /dev/null; then
        atom SOCIAL "Shared Play Card: $(basename "$playcard") via method $method"
    fi
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
