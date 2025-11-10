#!/usr/bin/env bash
#───────────────────────────────────────────────────────────────────────────────
# ATOM Recovery Demonstration
# Simulates a crash and demonstrates recovery capabilities
#───────────────────────────────────────────────────────────────────────────────

set -euo pipefail

DEMO_TRAIL="${HOME}/.config/atom-sage/trails/demo_trail.log"
BACKUP_TRAIL="${HOME}/.config/atom-sage/trails/atom_trail.log.backup"

echo "════════════════════════════════════════════════════════════"
echo "  ATOM Recovery Demonstration"
echo "════════════════════════════════════════════════════════════"
echo ""

# Backup existing trail
if [ -f "${HOME}/.config/atom-sage/trails/atom_trail.log" ]; then
    echo "Backing up existing ATOM trail..."
    cp "${HOME}/.config/atom-sage/trails/atom_trail.log" "${BACKUP_TRAIL}"
fi

echo "[Phase 1] Simulating normal operations..."
echo ""

# Simulate complex multi-context work
atom CFG "Configure MCP servers for development"
atom MCP "Cloudflare MCP: Workers API connected"
atom MCP "Perplexity MCP: Research queries enabled"
atom GWI "Gaming profile: Baldur's Gate 3 configured"
atom DOC "ARCREF template instantiated"
atom CFG "Filesystem: ~/.config/gaming-intent/ created"
atom TASK "TODO: Complete Ollama MCP setup"
atom GWI "Play Card: BG3-PROTON-GE-001 validated"
atom STATUS "In Progress: 4 parallel workflows"

sleep 1

echo ""
echo "[Phase 2] === SIMULATED CRASH ===="
echo "System crashed! All contexts lost!"
echo ""
sleep 2

echo "[Phase 3] Recovery process starting..."
echo ""
echo "User provides minimal input:"
echo "  \"Continue from crash\""
echo ""
sleep 1

echo "Recovery analysis:"
echo "─────────────────────────────────────────────────────────────"
atom-analytics --recovery

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  Recovery Complete!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Key observations:"
echo "  • User provided minimal input (no technical details)"
echo "  • ATOM trail contained all necessary context"
echo "  • Pending task (Ollama MCP) identified automatically"
echo "  • All 4 workflows understood from tag types"
echo ""
echo "Next actions identified:"
echo "  1. Complete Ollama MCP setup (explicit TASK)"
echo "  2. Expand gaming profiles (from GWI pattern)"
echo "  3. Finish ARCREF documentation (from DOC tag)"
echo "  4. Validate system configuration (from STATUS)"
echo ""

# Restore original trail
if [ -f "${BACKUP_TRAIL}" ]; then
    echo "Restoring original ATOM trail..."
    mv "${BACKUP_TRAIL}" "${HOME}/.config/atom-sage/trails/atom_trail.log"
    echo "Demo complete. Original trail restored."
else
    echo "Demo complete."
fi
