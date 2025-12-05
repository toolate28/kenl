#!/usr/bin/env bash
# KENL8 Security Context Prompt
# Magenta theme for security/privacy

# Colors (ANSI)
MAGENTA='\[\033[0;35m\]'
BOLD_MAGENTA='\[\033[1;35m\]'
CYAN='\[\033[0;36m\]'
WHITE='\[\033[1;37m\]'
RESET='\[\033[0m\]'

# KENL8 Icon: 🔐 (lock for security)
export PS1="${BOLD_MAGENTA}🔐  KENL8${RESET} ${MAGENTA}\u${RESET}@${CYAN}\h${RESET}:${WHITE}\w${RESET}\$ "

# Additional indicators
export KENL_CONTEXT="KENL8-security"
export KENL_COLOR="magenta"
export KENL_ICON="🔐"

# Terminal title
echo -ne "\033]0;KENL8: Security & Privacy\007"

# Welcome message
if [ -n "$PS1" ]; then
    echo -e "${BOLD_MAGENTA}════════════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD_MAGENTA}🔐  KENL8: Security & Privacy Context${RESET}"
    echo -e "${MAGENTA}   GPG encryption, vault, secret rotation, TOTP${RESET}"
    echo -e "${BOLD_MAGENTA}════════════════════════════════════════════════════════════${RESET}"
fi
