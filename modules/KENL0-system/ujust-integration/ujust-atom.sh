#!/usr/bin/env bash
# ujust-atom.sh
# ATOM-wrapped ujust commands for Bazzite
# Integrates with Bazzite's just-based system management

set -euo pipefail

KENL0_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$KENL0_ROOT/system-atom.sh"

# Check if ujust is available (Bazzite-specific)
if ! command -v ujust &> /dev/null; then
    echo "Error: ujust not found. This tool is for Bazzite systems."
    echo ""
    echo "If you're on Bazzite and ujust is missing, install it:"
    echo "  rpm-ostree install just"
    exit 1
fi

# Function: Show available ujust recipes with ATOM integration
show_ujust_menu() {
    echo "════════════════════════════════════════════════════════════"
    echo "  KENL0: ujust Integration (ATOM-tracked)"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    echo "Common Bazzite operations (all logged to ATOM trail):"
    echo ""
    echo "  1) update               - Update system"
    echo "  2) rebase-stable        - Rebase to stable"
    echo "  3) rebase-testing       - Rebase to testing"
    echo "  4) install-brew         - Install Homebrew"
    echo "  5) install-docker       - Setup Docker/Podman"
    echo "  6) setup-gaming         - Configure gaming optimizations"
    echo "  7) setup-nvidia         - NVIDIA driver setup"
    echo "  8) distrobox-assemble   - Setup distrobox containers"
    echo "  9) choose               - Show all ujust recipes"
    echo " 10) custom              - Run custom ujust command"
    echo ""
}

# Function: Execute ujust with ATOM trail
execute_ujust_atom() {
    local recipe="$1"
    local intent="${2:-Execute ujust $recipe}"

    # Build command
    local command="ujust $recipe"

    # Map recipe to operation type
    local operation="ujust-$recipe"

    # Execute through system-atom
    execute_system_op "$operation" "$intent - CTFWI: Validate recipe exists and log to ATOM trail" "$command"
}

# Interactive menu
if [ "${1:-}" = "--choose" ] || [ "${1:-}" = "--pick" ] || [ $# -eq 0 ]; then
    show_ujust_menu

    read -p "Select operation [1-10]: " choice

    case "$choice" in
        1)
            execute_ujust_atom "update" "System update via ujust"
            ;;
        2)
            execute_ujust_atom "rebase-stable" "Rebase to Bazzite stable"
            ;;
        3)
            execute_ujust_atom "rebase-testing" "Rebase to Bazzite testing"
            ;;
        4)
            execute_ujust_atom "install-brew" "Install Homebrew package manager"
            ;;
        5)
            execute_ujust_atom "setup-docker" "Setup Docker/Podman containers"
            ;;
        6)
            execute_ujust_atom "setup-gaming" "Configure gaming optimizations (Proton, GameScope)"
            ;;
        7)
            execute_ujust_atom "setup-nvidia" "Install and configure NVIDIA drivers"
            ;;
        8)
            execute_ujust_atom "distrobox-assemble" "Setup preconfigured distrobox containers"
            ;;
        9)
            echo ""
            echo "All available ujust recipes:"
            echo ""
            ujust --choose
            ;;
        10)
            echo ""
            read -p "Enter ujust recipe name: " recipe
            read -p "Enter intent description: " intent
            execute_ujust_atom "$recipe" "$intent"
            ;;
        *)
            echo "Invalid choice"
            exit 1
            ;;
    esac
else
    # Direct execution mode
    local recipe="$1"
    local intent="${2:-Execute ujust $recipe}"
    execute_ujust_atom "$recipe" "$intent"
fi
