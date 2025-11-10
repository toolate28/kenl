#!/usr/bin/env bash
# KENL6 Social Context Prompt
# Orange theme for community/social gaming

# Colors (ANSI)
ORANGE='\[\033[0;33m\]'
BOLD_ORANGE='\[\033[1;33m\]'
CYAN='\[\033[0;36m\]'
WHITE='\[\033[1;37m\]'
RESET='\[\033[0m\]'

# KENL6 Icon: 🌐 (globe for social/community)
export PS1="${BOLD_ORANGE}🌐  KENL6${RESET} ${ORANGE}\u${RESET}@${CYAN}\h${RESET}:${WHITE}\w${RESET}\$ "

# Additional indicators
export KENL_CONTEXT="KENL6-social"
export KENL_COLOR="orange"
export KENL_ICON="🌐"

# Terminal title
echo -ne "\033]0;KENL6: Social Gaming & Community\007"

# Welcome message
if [ -n "$PS1" ]; then
    echo -e "${BOLD_ORANGE}════════════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD_ORANGE}🌐  KENL6: Social Gaming & Community Context${RESET}"
    echo -e "${ORANGE}   Play Card sharing, Matrix/Discord, LFG matchmaking${RESET}"
    echo -e "${BOLD_ORANGE}════════════════════════════════════════════════════════════${RESET}"
fi
