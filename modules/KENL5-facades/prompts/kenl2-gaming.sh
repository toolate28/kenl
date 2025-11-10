#!/usr/bin/env bash
# KENL2 Gaming Context Prompt
# Red/Orange theme for gaming

# Colors (ANSI)
RED='\[\033[0;31m\]'
BOLD_RED='\[\033[1;31m\]'
ORANGE='\[\033[0;33m\]'
WHITE='\[\033[1;37m\]'
RESET='\[\033[0m\]'

# KENL2 Icon: 🎮 (game controller for gaming)
export PS1="${BOLD_RED}🎮  KENL2${RESET} ${RED}\u${RESET}@${ORANGE}\h${RESET}:${WHITE}\w${RESET}\$ "

# Additional indicators
export KENL_CONTEXT="KENL2-gaming"
export KENL_COLOR="red"
export KENL_ICON="🎮"

# Terminal title
echo -ne "\033]0;KENL2: Bazzite Gaming (GWI)\007"

# Welcome message
if [ -n "$PS1" ]; then
    echo -e "${BOLD_RED}════════════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD_RED}🎮  KENL2: Bazzite Gaming Context${RESET}"
    echo -e "${RED}   Gaming-With-Intent (GWI) - Play Cards & Optimization${RESET}"
    echo -e "${BOLD_RED}════════════════════════════════════════════════════════════${RESET}"
fi
