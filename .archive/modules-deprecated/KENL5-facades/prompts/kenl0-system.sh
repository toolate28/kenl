#!/usr/bin/env bash
# KENL0 System Context Prompt
# White/Bright theme for system operations (elevated privileges)

# Colors (ANSI)
WHITE='\[\033[1;37m\]'
BRIGHT='\[\033[1;97m\]'
RED='\[\033[0;31m\]'
CYAN='\[\033[0;36m\]'
RESET='\[\033[0m\]'

# KENL0 Icon: ⚙️ (gear for system operations)
export PS1="${BRIGHT}⚙️  KENL0${RESET} ${RED}\u${RESET}@${CYAN}\h${RESET}:${WHITE}\w${RESET}\$ "

# Additional indicators
export KENL_CONTEXT="KENL0-system"
export KENL_COLOR="white"
export KENL_ICON="⚙️"

# Load Bazzite-specific aliases and functions
if [ -f ~/kenl/modules/KENL0-system/aliases/bazzite-aliases.sh ]; then
    source ~/kenl/modules/KENL0-system/aliases/bazzite-aliases.sh
fi

if [ -f ~/kenl/modules/KENL0-system/functions/system-functions.sh ]; then
    source ~/kenl/modules/KENL0-system/functions/system-functions.sh
fi

# Terminal title
echo -ne "\033]0;KENL0: System Operations (Elevated)\007"

# Welcome message
if [ -n "$PS1" ]; then
    echo -e "${BRIGHT}════════════════════════════════════════════════════════════${RESET}"
    echo -e "${BRIGHT}⚙️  KENL0: System Operations Context${RESET}"
    echo -e "${WHITE}   Privileged operations for Bazzite (rpm-ostree)${RESET}"
    echo -e "${RED}   ⚠️  Elevated privileges - ATOM trail active${RESET}"
    echo -e "${BRIGHT}════════════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "${WHITE}Quick actions:${RESET}"
    echo -e "  qa-update     → Update + verify system"
    echo -e "  qa-rebase     → Rebase + clean deployments"
    echo -e "  qa-ujust      → ujust operations menu"
    echo ""
fi
