#!/usr/bin/env bash
# rebase-clean.sh
# Quick action: Rebase system + clean up old deployments
# Chained operations with ATOM trail

set -euo pipefail

KENL0_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$KENL0_ROOT/system-atom.sh"

echo "════════════════════════════════════════════════════════════"
echo "  KENL0 Quick Action: Rebase + Clean"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "This will:"
echo "  1. Rebase to specified Bazzite version"
echo "  2. Clean up old deployments (keep 2)"
echo "  3. Verify system integrity"
echo ""

# Get target from argument or prompt
if [ -n "${1:-}" ]; then
    TARGET="$1"
else
    echo "Available Bazzite versions:"
    echo "  - stable (recommended)"
    echo "  - testing"
    echo "  - latest"
    echo ""
    read -p "Enter target version [stable]: " TARGET
    TARGET="${TARGET:-stable}"
fi

# Step 1: Rebase
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1/3: Rebasing to Bazzite $TARGET"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

execute_system_op \
    "rebase" \
    "Rebase to Bazzite $TARGET - CTFWI: Verify version exists and create rollback point" \
    "rpm-ostree rebase ostree-image-signed:docker://ghcr.io/ublue-os/bazzite:$TARGET"

# Step 2: Clean old deployments
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2/3: Cleaning old deployments"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

execute_system_op \
    "cleanup" \
    "Remove old deployments (keep 2) - CTFWI: Preserve current and previous" \
    "rpm-ostree cleanup --rollback --pending"

# Step 3: Verify
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3/3: Verifying system integrity"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

rpm-ostree status

echo ""
echo "════════════════════════════════════════════════════════════"
echo "✅ Rebase + Clean complete!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Next steps:"
echo "  1. Reboot to activate new deployment: systemctl reboot"
echo "  2. If issues occur, rollback: rpm-ostree rollback && systemctl reboot"
echo "  3. View ATOM trail: ls ~/.config/atom-sage/trail/ATOM-SYSTEM-*"
echo ""
