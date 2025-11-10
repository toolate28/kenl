#!/usr/bin/env bash
# KENL3 Development Context Prompt
# Blue/Cyan theme for development

# Colors (ANSI)
BLUE='\[\033[0;34m\]'
BOLD_BLUE='\[\033[1;34m\]'
CYAN='\[\033[0;36m\]'
WHITE='\[\033[1;37m\]'
RESET='\[\033[0m\]'

# KENL3 Icon: 💻 (laptop for development)
export PS1="${BOLD_BLUE}💻  KENL3${RESET} ${BLUE}\u${RESET}@${CYAN}\h${RESET}:${WHITE}\w${RESET}\$ "

# Additional indicators
export KENL_CONTEXT="KENL3-dev"
export KENL_COLOR="blue"
export KENL_ICON="💻"

# Terminal title
echo -ne "\033]0;KENL3: Bazzite-DX Development\007"

# Welcome message
if [ -n "$PS1" ]; then
    echo -e "${BOLD_BLUE}════════════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD_BLUE}💻  KENL3: Bazzite-DX Development Context${RESET}"
    echo -e "${BLUE}   Distrobox development with Claude Code integration${RESET}"
    echo -e "${BOLD_BLUE}════════════════════════════════════════════════════════════${RESET}"
fi
