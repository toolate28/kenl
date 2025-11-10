#!/usr/bin/env bash
# KENL4 Monitoring Context Prompt
# Green theme for monitoring/observability

# Colors (ANSI)
GREEN='\[\033[0;32m\]'
BOLD_GREEN='\[\033[1;32m\]'
CYAN='\[\033[0;36m\]'
WHITE='\[\033[1;37m\]'
RESET='\[\033[0m\]'

# KENL4 Icon: 📊 (chart for monitoring)
export PS1="${BOLD_GREEN}📊  KENL4${RESET} ${GREEN}\u${RESET}@${CYAN}\h${RESET}:${WHITE}\w${RESET}\$ "

# Additional indicators
export KENL_CONTEXT="KENL4-monitoring"
export KENL_COLOR="green"
export KENL_ICON="📊"

# Terminal title
echo -ne "\033]0;KENL4: Monitoring & Observability\007"

# Welcome message
if [ -n "$PS1" ]; then
    echo -e "${BOLD_GREEN}════════════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD_GREEN}📊  KENL4: Monitoring & Observability Context${RESET}"
    echo -e "${GREEN}   Logdy, Grafana, Prometheus - ATOM Trail Analytics${RESET}"
    echo -e "${BOLD_GREEN}════════════════════════════════════════════════════════════${RESET}"
fi
