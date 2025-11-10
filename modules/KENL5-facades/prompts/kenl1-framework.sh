#!/usr/bin/env bash
# KENL1 Framework Context Prompt
# Purple theme for core methodology

# Colors (ANSI)
PURPLE='\[\033[0;35m\]'
BOLD_PURPLE='\[\033[1;35m\]'
CYAN='\[\033[0;36m\]'
WHITE='\[\033[1;37m\]'
RESET='\[\033[0m\]'

# KENL1 Icon: ⚛️ (atom symbol for ATOM+SAGE)
export PS1="${BOLD_PURPLE}⚛️  KENL1${RESET} ${PURPLE}\u${RESET}@${CYAN}\h${RESET}:${WHITE}\w${RESET}\$ "

# Additional indicators
export KENL_CONTEXT="KENL1-framework"
export KENL_COLOR="purple"
export KENL_ICON="⚛️"

# Terminal title
echo -ne "\033]0;KENL1: ATOM+SAGE+OWI Framework\007"

# Welcome message
if [ -n "$PS1" ]; then
    echo -e "${BOLD_PURPLE}════════════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD_PURPLE}⚛️  KENL1: ATOM+SAGE+OWI Framework Context${RESET}"
    echo -e "${PURPLE}   Core methodology for intent-driven operations${RESET}"
    echo -e "${BOLD_PURPLE}════════════════════════════════════════════════════════════${RESET}"
fi
