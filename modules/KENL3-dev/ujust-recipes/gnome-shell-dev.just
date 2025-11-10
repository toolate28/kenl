# KENL3 ujust recipe: GNOME Shell Development Environment
# Usage: ujust gnome-shell-dev-setup

# Create GNOME Shell development environment using toolbox
gnome-shell-dev-setup:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "🔧 KENL3: Setting up GNOME Shell Development Environment"
    echo "========================================================="
    echo ""

    CONTAINER_NAME="gnome-dev"
    FEDORA_VERSION="40"

    # Check if toolbox exists
    if toolbox list | grep -q "$CONTAINER_NAME"; then
        echo "⚠️  Container '$CONTAINER_NAME' already exists"
        read -p "Delete and recreate? (y/N): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            toolbox rm -f "$CONTAINER_NAME"
        else
            echo "Exiting. Use: toolbox enter $CONTAINER_NAME"
            exit 0
        fi
    fi

    # Create toolbox (better host integration than distrobox for compositor work)
    echo "📦 Creating toolbox container..."
    toolbox create "$CONTAINER_NAME" --image "registry.fedoraproject.org/fedora-toolbox:$FEDORA_VERSION"

    # Install GNOME development tools
    echo "📥 Installing GNOME Shell development packages..."
    toolbox run -c "$CONTAINER_NAME" sudo dnf install -y \
        mutter-devel \
        gnome-shell \
        gnome-shell-extension-tool \
        gjs \
        gjs-devel \
        gtk4-devel \
        libadwaita-devel \
        git \
        nodejs \
        npm

    # Create helper script inside container
    echo "📝 Creating helper scripts..."
    toolbox run -c "$CONTAINER_NAME" bash -c 'cat > ~/.local/bin/gnome-dev-shell <<EOF
#!/bin/bash
# KENL3 GNOME Shell Development Helper
set -euo pipefail

echo "🐚 Starting GNOME Shell in development mode..."
echo ""
echo "Tips:"
echo "  - Press Alt+F2, type 'r' to reload shell"
echo "  - Logs: journalctl -f /usr/bin/gnome-shell"
echo "  - Looking Glass: Alt+F2, type 'lg'"
echo ""

# Run gnome-shell with development kit
dbus-run-session -- gnome-shell --devkit
EOF'

    toolbox run -c "$CONTAINER_NAME" chmod +x ~/.local/bin/gnome-dev-shell

    # Create ATOM trail entry
    echo "ATOM-DEV-$(date +%Y%m%d)-$(date +%s | tail -c 4): Created GNOME Shell dev environment" >> ~/.kenl/atom-trail.log 2>/dev/null || true

    echo ""
    echo "✅ GNOME Shell development environment ready!"
    echo ""
    echo "📋 Next Steps:"
    echo "  1. Enter container:  toolbox enter $CONTAINER_NAME"
    echo "  2. Start dev shell:  gnome-dev-shell"
    echo "  3. Or manually:      dbus-run-session -- gnome-shell --devkit"
    echo ""
    echo "📁 Your home directory is shared with the container"
    echo "💡 Extension development: ~/.local/share/gnome-shell/extensions/"
    echo ""

# Enter existing GNOME dev environment
gnome-shell-dev-enter:
    toolbox enter gnome-dev

# Remove GNOME dev environment
gnome-shell-dev-remove:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "🗑️  Removing GNOME Shell development environment..."
    toolbox rm -f gnome-dev
    echo "✅ Removed"

# Show GNOME dev environment info
gnome-shell-dev-info:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "📊 GNOME Shell Development Environment Info"
    echo "============================================="
    echo ""

    if toolbox list | grep -q "gnome-dev"; then
        echo "Status: ✅ Installed"
        echo ""
        echo "Container Info:"
        toolbox list | grep gnome-dev || true
        echo ""
        echo "Installed Packages:"
        toolbox run -c gnome-dev rpm -qa | grep -E "mutter-devel|gnome-shell|gjs" || echo "  (run setup first)"
    else
        echo "Status: ❌ Not installed"
        echo ""
        echo "Run: ujust gnome-shell-dev-setup"
    fi
