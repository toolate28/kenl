#!/usr/bin/env bash
#───────────────────────────────────────────────────────────────────────────────
# Multi-Context ATOM Operations Example
# Demonstrates handling multiple parallel workflows with ATOM tags
#───────────────────────────────────────────────────────────────────────────────

set -euo pipefail

echo "════════════════════════════════════════════════════════════"
echo "  Multi-Context Operations Example"
echo "════════════════════════════════════════════════════════════"
echo ""

# Context 1: MCP Server Setup
echo "[Context 1] MCP Server Configuration"
echo "─────────────────────────────────────────────────────────────"
atom MCP "Initialize MCP server configuration"
atom MCP "Cloudflare MCP: Configure Workers API"
atom MCP "Cloudflare MCP: Configure KV storage"
atom MCP "Perplexity MCP: Configure research API"
atom TASK "TODO: Complete Ollama MCP configuration"
echo ""

# Context 2: Gaming Profiles (Windows 10 EOL)
echo "[Context 2] Gaming Profile Setup"
echo "─────────────────────────────────────────────────────────────"
atom GWI "Create gaming profile structure"
atom GWI "Profile: Baldur's Gate 3 - Proton-GE 8.25"
atom GWI "Profile: Cyberpunk 2077 - Proton Experimental"
atom GWI "Profile: Elden Ring - Proton 8.0"
atom TASK "TODO: Test all gaming profiles post-reboot"
echo ""

# Context 3: Documentation
echo "[Context 3] Documentation Updates"
echo "─────────────────────────────────────────────────────────────"
atom DOC "Create ARCREF for MCP governance"
atom DOC "Create ADR for gaming profile methodology"
atom DOC "Update README with installation instructions"
atom TASK "TODO: Generate API documentation"
echo ""

# Context 4: Infrastructure Configuration
echo "[Context 4] Infrastructure Setup"
echo "─────────────────────────────────────────────────────────────"
atom CFG "Configure ~/.config/atom-sage directory structure"
atom CFG "Set up ATOM trail logging"
atom CFG "Configure pre-commit hooks"
atom CFG "Set up CI/CD pipeline"
echo ""

# Status checkpoint
echo "════════════════════════════════════════════════════════════"
atom STATUS "Multi-context setup: 4 parallel workflows in progress"
echo "════════════════════════════════════════════════════════════"
echo ""

# Analyze workflow state
echo "Analyzing workflow state..."
echo ""

echo "MCP Server Progress:"
atom-analytics --type MCP | tail -5
echo ""

echo "Gaming Profile Progress:"
atom-analytics --type GWI | tail -5
echo ""

echo "Documentation Progress:"
atom-analytics --type DOC | tail -5
echo ""

echo "Configuration Progress:"
atom-analytics --type CFG | tail -5
echo ""

echo "Pending Tasks Across All Contexts:"
atom-analytics --pending
echo ""

echo "════════════════════════════════════════════════════════════"
echo "  Multi-Context Analysis Complete"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Key observations:"
echo "  • 4 distinct contexts tracked with type tags"
echo "  • Each context has its own workflow progression"
echo "  • Pending tasks tracked across all contexts"
echo "  • Status checkpoints provide recovery points"
echo ""
echo "Recovery after crash:"
echo "  $ atom-analytics --recovery"
echo "  (Will reconstruct all 4 contexts automatically)"
echo ""
echo "View specific workflow:"
echo "  $ atom-analytics --type MCP    # MCP server workflow"
echo "  $ atom-analytics --type GWI    # Gaming profiles"
echo "  $ atom-analytics --type DOC    # Documentation"
echo "  $ atom-analytics --type CFG    # Configuration"
