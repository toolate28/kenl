#!/usr/bin/env bash
#───────────────────────────────────────────────────────────────────────────────
# ATOM+SAGE Devcontainer Post-Create Script
# Runs after container is created to set up the development environment
#───────────────────────────────────────────────────────────────────────────────

set -e

echo "════════════════════════════════════════════════════════════"
echo "  ATOM+SAGE Devcontainer Setup"
echo "════════════════════════════════════════════════════════════"
echo ""

# Update package lists
echo "[1/6] Updating package lists..."
sudo apt-get update -qq

# Install dependencies
echo "[2/6] Installing dependencies..."
sudo apt-get install -y -qq \
    shellcheck \
    gnupg2 \
    curl \
    jq \
    python3-pip \
    python3-venv

# Install ATOM+SAGE framework
echo "[3/6] Installing ATOM+SAGE framework..."
cd /workspaces/atom-sage-framework
./install.sh

# Install Python analytics (optional)
echo "[4/6] Installing Python analytics..."
if [ -f analytics/setup.py ]; then
    pip3 install --user -e analytics/
fi

# Set up git configuration
echo "[5/6] Configuring git..."
git config --global --add safe.directory /workspaces/atom-sage-framework

# Create example configuration
echo "[6/6] Creating example configuration..."
mkdir -p ~/.config/atom-sage

cat > ~/.config/atom-sage/config.example <<'EOF'
[general]
trail_file = ~/.config/atom-sage/trails/atom_trail.log
counter_file = ~/.config/atom-sage/trails/.counter

[privacy]
pii_redaction = false
redact_patterns = email,phone,ssn

[playcard]
encryption = true
gpg_recipient = your@email.com

[logdy]
server_url = http://localhost:8081
api_token = change-me
namespace = play-cards
EOF

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  Setup Complete!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Try these commands:"
echo "  atom STATUS 'Working in devcontainer'"
echo "  atom-analytics --summary"
echo "  ./examples/basic-workflow.sh"
echo ""
echo "Configuration example: ~/.config/atom-sage/config.example"
echo ""
