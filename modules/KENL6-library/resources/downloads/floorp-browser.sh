#!/usr/bin/env bash
#
# floorp-browser.sh - Download and setup Floorp browser
#
# Floorp is a Firefox-based browser with enhanced privacy and customization
#

set -euo pipefail

FLOORP_VERSION="11.17.6"
DOWNLOAD_URL="https://github.com/Floorp-Projects/Floorp/releases/download/v${FLOORP_VERSION}"
INSTALL_DIR="${HOME}/.local/share/floorp"
PORTABLE_DIR="${HOME}/Apps/Floorp"

echo "🦊 Floorp Browser Setup"
echo ""
echo "Options:"
echo "  1) Install to ~/.local/share/floorp (system integration)"
echo "  2) Portable install to ~/Apps/Floorp"
echo "  3) Both"
echo ""
read -rp "Choose [1-3]: " choice

install_floorp() {
    local target_dir="$1"
    local integrate="$2"

    echo ""
    echo "📥 Downloading Floorp ${FLOORP_VERSION}..."

    # Detect architecture
    ARCH=$(uname -m)
    if [ "$ARCH" = "x86_64" ]; then
        TARBALL="floorp-${FLOORP_VERSION}.linux-x86_64.tar.bz2"
    else
        echo "❌ Unsupported architecture: $ARCH"
        exit 1
    fi

    DOWNLOAD_PATH="${DOWNLOAD_URL}/${TARBALL}"

    mkdir -p "$(dirname "$target_dir")"
    cd /tmp

    wget -q --show-progress "$DOWNLOAD_PATH" -O "$TARBALL"

    echo "📦 Extracting..."
    tar xjf "$TARBALL"

    echo "📁 Installing to $target_dir..."
    rm -rf "$target_dir"
    mv floorp "$target_dir"

    chmod +x "$target_dir/floorp"
    chmod +x "$target_dir/floorp-bin"

    rm "$TARBALL"

    if [ "$integrate" = "yes" ]; then
        echo "🔗 Creating desktop integration..."

        mkdir -p ~/.local/share/applications
        cat > ~/.local/share/applications/floorp.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Floorp
Comment=Floorp Web Browser
Exec=$target_dir/floorp %u
Icon=$target_dir/browser/chrome/icons/default/default128.png
Terminal=false
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;
StartupNotify=true
EOF

        # Add to PATH
        mkdir -p ~/.local/bin
        ln -sf "$target_dir/floorp" ~/.local/bin/floorp

        echo "✅ Desktop entry created: ~/.local/share/applications/floorp.desktop"
        echo "✅ Symlink created: ~/.local/bin/floorp"
    fi

    echo "✅ Floorp installed to: $target_dir"
}

case $choice in
    1)
        install_floorp "$INSTALL_DIR" "yes"
        ;;
    2)
        install_floorp "$PORTABLE_DIR" "no"
        echo ""
        echo "💡 To run: $PORTABLE_DIR/floorp"
        ;;
    3)
        install_floorp "$INSTALL_DIR" "yes"
        install_floorp "$PORTABLE_DIR" "no"
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "🦊 Floorp Setup Complete!"
echo ""
echo "First run tips:"
echo "  - Set DuckDuckGo or Startpage as default search"
echo "  - Enable 'HTTPS-Only Mode' in Settings → Privacy"
echo "  - Install uBlock Origin extension"
echo ""
echo "Floorp features:"
echo "  - Tree-style tabs"
echo "  - Vertical tabs"
echo "  - Enhanced privacy controls"
echo "  - Custom CSS support"

# Log with ATOM if available
if command -v atom &> /dev/null; then
    atom CONFIG "Installed Floorp browser v${FLOORP_VERSION}" "$target_dir"
fi
