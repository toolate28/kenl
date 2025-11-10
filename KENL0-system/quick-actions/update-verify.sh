#!/usr/bin/env bash
# update-verify.sh
# Quick action: Update system + verify integrity
# Chained operations with ATOM trail

set -euo pipefail

KENL0_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$KENL0_ROOT/system-atom.sh"

echo "════════════════════════════════════════════════════════════"
echo "  KENL0 Quick Action: Update + Verify"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "This will:"
echo "  1. Check for available updates"
echo "  2. Update system packages"
echo "  3. Verify system integrity"
echo "  4. Report changes"
echo ""

# Step 1: Check for updates
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1/4: Checking for updates"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if ! rpm-ostree upgrade --check; then
    echo ""
    echo "✅ System is up to date!"
    exit 0
fi

# Step 2: Update
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2/4: Updating system"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

execute_system_op \
    "update" \
    "System update - CTFWI: Create rollback point and verify signatures" \
    "rpm-ostree upgrade"

# Step 3: Verify integrity
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3/4: Verifying system integrity"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

rpm-ostree status --verbose

# Step 4: Report changes
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 4/4: Reporting changes"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

rpm-ostree db diff

echo ""
echo "════════════════════════════════════════════════════════════"
echo "✅ Update + Verify complete!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Next steps:"
echo "  1. Reboot to activate updates: systemctl reboot"
echo "  2. If issues occur, rollback: rpm-ostree rollback && systemctl reboot"
echo "  3. View ATOM trail: ls ~/.config/atom-sage/trail/ATOM-SYSTEM-*"
echo ""
