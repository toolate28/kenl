#!/usr/bin/env bash
# KENL10 Backup Context Prompt
# Brown/Gold theme for backup/preservation

# Colors (ANSI)
BROWN='\[\033[0;33m\]'
BOLD_BROWN='\[\033[1;33m\]'
CYAN='\[\033[0;36m\]'
WHITE='\[\033[1;37m\]'
RESET='\[\033[0m\]'

# KENL10 Icon: 💾 (floppy disk for backup)
export PS1="${BOLD_BROWN}💾  KENL10${RESET} ${BROWN}\u${RESET}@${CYAN}\h${RESET}:${WHITE}\w${RESET}\$ "

# Additional indicators
export KENL_CONTEXT="KENL10-backup"
export KENL_COLOR="brown"
export KENL_ICON="💾"

# Terminal title
echo -ne "\033]0;KENL10: Intelligent Backup & Sync\007"

# Welcome message
if [ -n "$PS1" ]; then
    echo -e "${BOLD_BROWN}════════════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD_BROWN}💾  KENL10: Intelligent Backup & Sync Context${RESET}"
    echo -e "${BROWN}   ATOM-aware snapshots, cloud sync, disaster recovery${RESET}"
    echo -e "${BOLD_BROWN}════════════════════════════════════════════════════════════${RESET}"
fi
