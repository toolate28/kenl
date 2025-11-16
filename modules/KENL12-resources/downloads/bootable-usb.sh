#!/usr/bin/env bash
#
# bootable-usb.sh - Install bootable USB creation tools
#
# Supports: Ventoy, Balena Etcher, Rufus (via Wine)
#

set -euo pipefail

echo "💾 Bootable USB Tools Setup"
echo ""
echo "Choose tool:"
echo "  1) Ventoy (Multi-boot USB with drag-and-drop ISOs)"
echo "  2) Balena Etcher (Simple single-ISO flashing)"
echo "  3) Rufus via Wine (Windows tool on Linux)"
echo "  4) All"
echo ""
read -rp "Choose [1-4]: " choice

install_ventoy() {
    echo ""
    echo "📥 Installing Ventoy..."

    VENTOY_VERSION="1.0.99"
    DOWNLOAD_URL="https://github.com/ventoy/Ventoy/releases/download/v${VENTOY_VERSION}/ventoy-${VENTOY_VERSION}-linux.tar.gz"
    INSTALL_DIR="${HOME}/.local/share/ventoy"

    mkdir -p "$INSTALL_DIR"
    cd /tmp

    echo "Downloading Ventoy ${VENTOY_VERSION}..."
    wget -q --show-progress "$DOWNLOAD_URL" -O ventoy.tar.gz

    echo "Extracting..."
    tar xzf ventoy.tar.gz

    echo "Installing to $INSTALL_DIR..."
    cp -r ventoy-${VENTOY_VERSION}/* "$INSTALL_DIR/"

    # Make scripts executable
    chmod +x "$INSTALL_DIR"/*.sh

    # Create launcher
    mkdir -p ~/.local/bin
    cat > ~/.local/bin/ventoy <<EOF
#!/bin/bash
cd $INSTALL_DIR
./VentoyGUI.x86_64
EOF
    chmod +x ~/.local/bin/ventoy

    rm -rf ventoy-${VENTOY_VERSION} ventoy.tar.gz

    echo "✅ Ventoy installed to: $INSTALL_DIR"
    echo ""
    echo "📖 Ventoy Usage:"
    echo "  1. Run: ventoy"
    echo "  2. Select USB drive"
    echo "  3. Click 'Install'"
    echo "  4. Copy ISO files directly to USB (drag-and-drop!)"
    echo "  5. Boot from USB, select ISO from menu"
    echo ""
    echo "💡 Ventoy supports 900+ ISOs including:"
    echo "  - Linux distros (Bazzite, Fedora, Ubuntu, Arch, etc.)"
    echo "  - Windows install ISOs"
    echo "  - Recovery tools (GParted, Clonezilla)"
}

install_balena_etcher() {
    echo ""
    echo "📥 Installing Balena Etcher..."

    if command -v flatpak &> /dev/null; then
        flatpak install -y flathub io.balena.Etcher
        echo "✅ Balena Etcher installed via Flatpak"
        echo ""
        echo "To launch: flatpak run io.balena.Etcher"
    else
        echo "⚠️  Flatpak not available."
        echo "Download AppImage from: https://etcher.balena.io/#download-etcher"
    fi

    echo ""
    echo "📖 Balena Etcher Usage:"
    echo "  1. Launch Balena Etcher"
    echo "  2. Select ISO image"
    echo "  3. Select USB drive"
    echo "  4. Flash!"
    echo ""
    echo "⚠️  Note: Etcher writes ONE ISO per USB (not multi-boot like Ventoy)"
}

install_rufus_wine() {
    echo ""
    echo "📥 Installing Rufus via Wine..."

    # Check if Wine available
    if ! command -v wine &> /dev/null; then
        echo "Wine not found. Installing..."
        if command -v flatpak &> /dev/null; then
            flatpak install -y flathub org.winehq.Wine
        else
            rpm-ostree install wine
            echo "⚠️  Wine layered (reboot required)"
            return
        fi
    fi

    RUFUS_VERSION="4.3"
    RUFUS_URL="https://github.com/pbatard/rufus/releases/download/v${RUFUS_VERSION}/rufus-${RUFUS_VERSION}.exe"
    RUFUS_DIR="${HOME}/.local/share/rufus"

    mkdir -p "$RUFUS_DIR"
    cd "$RUFUS_DIR"

    echo "Downloading Rufus ${RUFUS_VERSION}..."
    wget -q --show-progress "$RUFUS_URL" -O rufus.exe

    # Create launcher
    cat > ~/.local/bin/rufus <<EOF
#!/bin/bash
cd $RUFUS_DIR
wine rufus.exe
EOF
    chmod +x ~/.local/bin/rufus

    echo "✅ Rufus installed (runs via Wine)"
    echo ""
    echo "📖 Rufus Usage:"
    echo "  Run: rufus"
    echo "  (May be slower than native tools)"
    echo ""
    echo "💡 Consider using Ventoy instead (native Linux, multi-boot)"
}

case $choice in
    1)
        install_ventoy
        ;;
    2)
        install_balena_etcher
        ;;
    3)
        install_rufus_wine
        ;;
    4)
        install_ventoy
        install_balena_etcher
        # Skip Rufus in "all" - most users don't need it
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "💾 Bootable USB Setup Complete!"
echo ""
echo "📚 Recommended ISOs to keep on Ventoy USB:"
echo "  - Bazzite (gaming/dev)"
echo "  - Fedora Workstation (general purpose)"
echo "  - GParted Live (partition management)"
echo "  - Clonezilla (backup/restore)"
echo "  - Windows 11 (dual-boot)"
echo ""
echo "Download links: ~/kenl/modules/KENL12-resources/README.md"

# Log with ATOM if available
if command -v atom &> /dev/null; then
    atom CONFIG "Installed bootable USB tool(s)" "$choice"
fi
