#!/usr/bin/env bash
# atom-snapshot.sh
# ATOM-aware backup system - captures full context
# Understands intent, not just files

set -euo pipefail

KENL10_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_ROOT="$HOME/.local/share/kenl-backups"
ATOM_TRAIL="$HOME/.config/atom-sage/trail"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

# Ensure backup directory exists
mkdir -p "$BACKUP_ROOT"/{snapshots,atom-context,recovery-points}

# Create ATOM-aware snapshot
create_snapshot() {
    local name="${1:-auto-$(date +%Y%m%d-%H%M%S)}"
    local intent="${2:-Manual snapshot}"

    echo -e "${BOLD}Creating ATOM-aware snapshot: $name${RESET}"
    echo ""

    local snapshot_dir="$BACKUP_ROOT/snapshots/$name"
    mkdir -p "$snapshot_dir"

    # 1. Capture ATOM trail context
    echo -e "${CYAN}[1/6] Capturing ATOM trail context...${RESET}"
    if [ -d "$ATOM_TRAIL" ]; then
        cp -r "$ATOM_TRAIL" "$snapshot_dir/atom-trail"
        local atom_count=$(find "$snapshot_dir/atom-trail" -name "ATOM-*" | wc -l)
        echo "  ✅ Captured $atom_count ATOM entries"
    fi

    # 2. Capture all KENL configurations
    echo -e "${CYAN}[2/6] Capturing KENL configurations...${RESET}"
    for kenl in KENL{0..10}*; do
        if [ -d "$HOME/kenl/$kenl" ]; then
            mkdir -p "$snapshot_dir/kenl-configs/$kenl"

            # Capture config files (not entire repos)
            find "$HOME/kenl/$kenl" -name "*.yaml" -o -name "*.json" -o -name "*.conf" 2>/dev/null | \
                xargs -I {} cp {} "$snapshot_dir/kenl-configs/$kenl/" 2>/dev/null || true

            echo "  ✅ $kenl"
        fi
    done

    # 3. Capture Play Cards (KENL2)
    echo -e "${CYAN}[3/6] Capturing Play Cards...${RESET}"
    if [ -d "$HOME/kenl/modules/KENL2-gaming/play-cards" ]; then
        cp -r "$HOME/kenl/modules/KENL2-gaming/play-cards" "$snapshot_dir/play-cards"
        local card_count=$(find "$snapshot_dir/play-cards" -name "*.yaml" | wc -l)
        echo "  ✅ Captured $card_count Play Cards"
    fi

    # 4. Capture system state (KENL0)
    echo -e "${CYAN}[4/6] Capturing system state...${RESET}"
    {
        echo "# System State Snapshot"
        echo "Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo ""
        echo "## rpm-ostree"
        rpm-ostree status 2>/dev/null || echo "N/A"
        echo ""
        echo "## Flatpak"
        flatpak list 2>/dev/null || echo "N/A"
        echo ""
        echo "## Distrobox"
        distrobox list 2>/dev/null || echo "N/A"
    } > "$snapshot_dir/system-state.txt"
    echo "  ✅ System state captured"

    # 5. Capture user configurations
    echo -e "${CYAN}[5/6] Capturing user configurations...${RESET}"
    mkdir -p "$snapshot_dir/user-configs"
    for config in .bashrc .bash_profile .kenl_profile .gitconfig; do
        [ -f "$HOME/$config" ] && cp "$HOME/$config" "$snapshot_dir/user-configs/" || true
    done
    # KENL facades config
    [ -d "$HOME/.config/kenl-facades" ] && cp -r "$HOME/.config/kenl-facades" "$snapshot_dir/user-configs/" || true
    echo "  ✅ User configs captured"

    # 6. Create snapshot manifest
    echo -e "${CYAN}[6/6] Creating manifest...${RESET}"
    cat > "$snapshot_dir/MANIFEST.json" <<EOF
{
  "name": "$name",
  "intent": "$intent",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "created_by": "$(whoami)@$(hostname)",
  "kenl_version": "2.0.0",
  "contents": {
    "atom_trail_entries": $(find "$snapshot_dir/atom-trail" -name "ATOM-*" 2>/dev/null | wc -l),
    "play_cards": $(find "$snapshot_dir/play-cards" -name "*.yaml" 2>/dev/null | wc -l),
    "kenl_configs": $(find "$snapshot_dir/kenl-configs" -type f 2>/dev/null | wc -l)
  },
  "size_bytes": $(du -sb "$snapshot_dir" | cut -f1)
}
EOF
    echo "  ✅ Manifest created"

    echo ""
    echo -e "${GREEN}✅ Snapshot created: $name${RESET}"
    echo -e "${GREEN}   Location: $snapshot_dir${RESET}"
    echo -e "${GREEN}   Size: $(du -sh "$snapshot_dir" | cut -f1)${RESET}"

    # Log to ATOM trail
    if command -v atom &> /dev/null; then
        atom BACKUP "Created snapshot: $name - $intent"
    fi
}

# List snapshots
list_snapshots() {
    echo -e "${BOLD}Available snapshots:${RESET}"
    echo ""

    local snapshots=($(ls -1t "$BACKUP_ROOT/snapshots" 2>/dev/null || true))

    if [ ${#snapshots[@]} -eq 0 ]; then
        echo "No snapshots found"
        return 1
    fi

    for snapshot in "${snapshots[@]}"; do
        if [ -f "$BACKUP_ROOT/snapshots/$snapshot/MANIFEST.json" ]; then
            local intent=$(jq -r '.intent' "$BACKUP_ROOT/snapshots/$snapshot/MANIFEST.json" 2>/dev/null || echo "N/A")
            local timestamp=$(jq -r '.timestamp' "$BACKUP_ROOT/snapshots/$snapshot/MANIFEST.json" 2>/dev/null || echo "N/A")
            local size=$(du -sh "$BACKUP_ROOT/snapshots/$snapshot" | cut -f1)

            echo -e "${CYAN}$snapshot${RESET}"
            echo "  Intent: $intent"
            echo "  Time: $timestamp"
            echo "  Size: $size"
            echo ""
        fi
    done
}

# Restore from snapshot
restore_snapshot() {
    local name="$1"
    local snapshot_dir="$BACKUP_ROOT/snapshots/$name"

    if [ ! -d "$snapshot_dir" ]; then
        echo -e "${RED}Error: Snapshot not found: $name${RESET}"
        list_snapshots
        exit 1
    fi

    echo -e "${BOLD}Restoring from snapshot: $name${RESET}"
    echo ""

    # Read manifest
    local intent=$(jq -r '.intent' "$snapshot_dir/MANIFEST.json")
    echo "Intent: $intent"
    echo ""

    echo -e "${YELLOW}⚠️  This will restore:${RESET}"
    echo "  • ATOM trail context"
    echo "  • Play Cards"
    echo "  • KENL configurations"
    echo "  • User configs (.bashrc, .kenl_profile, etc)"
    echo ""
    read -p "Continue? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        exit 0
    fi

    # Restore ATOM trail
    echo -e "${CYAN}[1/4] Restoring ATOM trail...${RESET}"
    if [ -d "$snapshot_dir/atom-trail" ]; then
        mkdir -p "$ATOM_TRAIL"
        cp -r "$snapshot_dir/atom-trail/"* "$ATOM_TRAIL/" 2>/dev/null || true
        echo "  ✅ ATOM trail restored"
    fi

    # Restore Play Cards
    echo -e "${CYAN}[2/4] Restoring Play Cards...${RESET}"
    if [ -d "$snapshot_dir/play-cards" ]; then
        mkdir -p "$HOME/kenl/modules/KENL2-gaming/play-cards"
        cp -r "$snapshot_dir/play-cards/"* "$HOME/kenl/modules/KENL2-gaming/play-cards/" 2>/dev/null || true
        echo "  ✅ Play Cards restored"
    fi

    # Restore KENL configs
    echo -e "${CYAN}[3/4] Restoring KENL configurations...${RESET}"
    if [ -d "$snapshot_dir/kenl-configs" ]; then
        for kenl_dir in "$snapshot_dir/kenl-configs/"*/; do
            kenl=$(basename "$kenl_dir")
            [ -d "$HOME/kenl/$kenl" ] && cp -r "$kenl_dir"* "$HOME/kenl/$kenl/" 2>/dev/null || true
        done
        echo "  ✅ KENL configs restored"
    fi

    # Restore user configs
    echo -e "${CYAN}[4/4] Restoring user configurations...${RESET}"
    if [ -d "$snapshot_dir/user-configs" ]; then
        cp "$snapshot_dir/user-configs/".* "$HOME/" 2>/dev/null || true
        [ -d "$snapshot_dir/user-configs/kenl-facades" ] && \
            cp -r "$snapshot_dir/user-configs/kenl-facades" "$HOME/.config/" 2>/dev/null || true
        echo "  ✅ User configs restored"
    fi

    echo ""
    echo -e "${GREEN}✅ Restore complete from: $name${RESET}"
    echo ""
    echo "You may need to:"
    echo "  • Restart shell: exec bash"
    echo "  • Re-source profile: source ~/.bashrc"

    # Log to ATOM trail
    if command -v atom &> /dev/null; then
        atom RECOVERY "Restored from snapshot: $name"
    fi
}

# Delete snapshot
delete_snapshot() {
    local name="$1"

    if [ ! -d "$BACKUP_ROOT/snapshots/$name" ]; then
        echo -e "${RED}Error: Snapshot not found: $name${RESET}"
        exit 1
    fi

    echo -e "${YELLOW}⚠️  Delete snapshot: $name?${RESET}"
    read -p "Continue? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$BACKUP_ROOT/snapshots/$name"
        echo -e "${GREEN}✅ Deleted: $name${RESET}"
    fi
}

# Main
case "${1:-}" in
    create|c)
        create_snapshot "${2:-}" "${3:-Manual snapshot}"
        ;;
    list|ls|l)
        list_snapshots
        ;;
    restore|r)
        restore_snapshot "${2:-}"
        ;;
    delete|rm)
        delete_snapshot "${2:-}"
        ;;
    *)
        cat <<EOF
Usage: $0 <command> [args]

Commands:
  create [name] [intent]  - Create ATOM-aware snapshot
  list                    - List available snapshots
  restore <name>          - Restore from snapshot
  delete <name>           - Delete snapshot

Examples:
  $0 create before-update "Before system update"
  $0 list
  $0 restore before-update

Snapshots are stored in: $BACKUP_ROOT/snapshots/
EOF
        ;;
esac
