#!/usr/bin/env bash
#
# kenl-banner-context.sh - Display KENL banner with current context
#
# Usage: kenl-banner-context.sh [KENL_NUMBER]
#

set -euo pipefail

KENL_NUM="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# KENL metadata
declare -A KENL_NAMES=(
    [0]="ATOM Trail"
    [1]="Sanctuary"
    [2]="Gaming"
    [3]="Development"
    [4]="Monitoring"
    [5]="Facades"
    [6]="Isolation"
    [7]="Learning"
    [8]="Crypto"
    [9]="Networking"
    [10]="Infrastructure"
    [11]="Media"
    [12]="Resources"
)

declare -A KENL_ICONS=(
    [0]="📝"
    [1]="🏠"
    [2]="🎮"
    [3]="💻"
    [4]="📊"
    [5]="🎨"
    [6]="🔒"
    [7]="📚"
    [8]="🔐"
    [9]="🌐"
    [10]="🏗️"
    [11]="📺"
    [12]="📦"
)

declare -A KENL_COLORS=(
    [0]="\033[38;5;208m"  # Orange
    [1]="\033[38;5;39m"   # Blue
    [2]="\033[38;5;201m"  # Magenta
    [3]="\033[38;5;46m"   # Green
    [4]="\033[38;5;226m"  # Yellow
    [5]="\033[38;5;141m"  # Purple
    [6]="\033[38;5;196m"  # Red
    [7]="\033[38;5;51m"   # Cyan
    [8]="\033[38;5;220m"  # Gold
    [9]="\033[38;5;33m"   # Deep Blue
    [10]="\033[38;5;214m" # Orange-Yellow
    [11]="\033[38;5;165m" # Pink
    [12]="\033[38;5;87m"  # Cyan
)

RESET="\033[0m"
BOLD="\033[1m"

# Detect current KENL context if not provided
if [ -z "$KENL_NUM" ]; then
    if [ -f "$HOME/.kenl/current-context" ]; then
        KENL_NUM=$(cat "$HOME/.kenl/current-context")
    else
        KENL_NUM="0"
    fi
fi

# Get metadata
NAME="${KENL_NAMES[$KENL_NUM]}"
ICON="${KENL_ICONS[$KENL_NUM]}"
COLOR="${KENL_COLORS[$KENL_NUM]}"

# Display context-aware banner
cat << EOF
${COLOR}${BOLD}
┌────────────────────────────────────────────────────────────────┐
│                                                                │
│   ██╗  ██╗███████╗███╗   ██╗██╗      ${ICON}  KENL${KENL_NUM}: ${NAME}${COLOR}${BOLD}
│   ██║ ██╔╝██╔════╝████╗  ██║██║                                │
│   █████╔╝ █████╗  ██╔██╗ ██║██║      Knowledge-Engine-N-Layer │
│   ██╔═██╗ ██╔══╝  ██║╚██╗██║██║                                │
│   ██║  ██╗███████╗██║ ╚████║███████╗ Bazzite-DX Gaming Infra  │
│   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝╚══════╝                          │
│                                                                │
│   🏠═══╗  🏠═══╗  🏠═══╗  🏠═══╗  🏠═══╗  🏠═══╗  🏠═══╗      │
│   ║ 🐕║  ║ 🐕║  ║ 🐕║  ║ 🐕║  ║ 🐕║  ║ 🐕║  ║ 🐕║      │
│   ╚═══╝  ╚═══╝  ╚═══╝  ╚═══╝  ╚═══╝  ╚═══╝  ╚═══╝      │
│                                                                │
│   Modular │ Traceable │ Rollback-Safe │ ATOM-Powered          │
│                                                                │
└────────────────────────────────────────────────────────────────┘
${RESET}
EOF

# Show quick context info
echo -e "${COLOR}Current Context:${RESET} KENL${KENL_NUM} - ${NAME} ${ICON}"
echo -e "${COLOR}Available Commands:${RESET} kenl help, kenl switch <0-12>, kenl status"
echo ""
