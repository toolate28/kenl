#!/bin/bash
#
# SAIF Recovery Vault Builder
# Executes DIRECTIVE-BUILD-RECOVERY-VAULT.md
#

set -e  # Exit on error

echo "╔════════════════════════════════════════╗"
echo "║  SAIF Recovery Vault Builder v1.0     ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "This will create a guided Obsidian vault for Surface Pro 4 recovery."
echo ""
read -p "Proceed? (yes/no): " confirm

if [[ "$confirm" != "yes" ]]; then
    echo "Cancelled."
    exit 0
fi

# Execute directive (pass to Claude Code CLI)
if command -v claude &> /dev/null; then
    echo ""
    echo "Passing directive to Claude Code CLI..."
    claude --file claude-landing/DIRECTIVE-BUILD-RECOVERY-VAULT.md --execute
else
    echo ""
    echo "⚠️  Claude Code CLI not found."
    echo "Install: https://docs.anthropic.com/claude/docs/claude-code"
    echo ""
    echo "Or execute manually:"
    echo "  cat claude-landing/DIRECTIVE-BUILD-RECOVERY-VAULT.md"
    exit 1
fi