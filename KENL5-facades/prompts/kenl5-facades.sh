#!/usr/bin/env bash
# KENL5 Facades Context Prompt
# Yellow/Gold theme for customization/theming

# Colors (ANSI)
YELLOW='\[\033[0;33m\]'
BOLD_YELLOW='\[\033[1;33m\]'
CYAN='\[\033[0;36m\]'
WHITE='\[\033[1;37m\]'
RESET='\[\033[0m\]'

# KENL5 Icon: 🎨 (palette for theming)
export PS1="${BOLD_YELLOW}🎨  KENL5${RESET} ${YELLOW}\u${RESET}@${CYAN}\h${RESET}:${WHITE}\w${RESET}\$ "

# Additional indicators
export KENL_CONTEXT="KENL5-facades"
export KENL_COLOR="yellow"
export KENL_ICON="🎨"

# Terminal title
echo -ne "\033]0;KENL5: Facades & Theming\007"

# Welcome message
if [ -n "$PS1" ]; then
    echo -e "${BOLD_YELLOW}════════════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD_YELLOW}🎨  KENL5: Facades & Theming Context${RESET}"
    echo -e "${YELLOW}   Shell prompts, themes, profiles - Visual identity${RESET}"
    echo -e "${BOLD_YELLOW}════════════════════════════════════════════════════════════${RESET}"
fi
