#!/usr/bin/env bash
#
# discord-clients.sh - Install alternative Discord clients
#
# Supports: Vesktop, ArmCord, Equicord
#

set -euo pipefail

echo "💬 Discord Client Setup"
echo ""
echo "Choose Discord client:"
echo "  1) Vesktop (Vencord + screen share audio)"
echo "  2) ArmCord (Lightweight, privacy-focused)"
echo "  3) Equicord (Equicord mod)"
echo "  4) Official Discord (Flatpak)"
echo "  5) All alternative clients (1-3)"
echo ""
read -rp "Choose [1-5]: " choice

install_vesktop() {
    echo ""
    echo "📥 Installing Vesktop..."

    if command -v flatpak &> /dev/null; then
        flatpak install -y flathub dev.vencord.Vesktop
        echo "✅ Vesktop installed via Flatpak"
    else
        echo "⚠️  Flatpak required for Vesktop"
        echo "Download from: https://github.com/Vencord/Vesktop/releases"
        return
    fi

    echo ""
    echo "📖 Vesktop Features:"
    echo "  ✅ Vencord mod built-in (custom themes, plugins)"
    echo "  ✅ Screen share with audio (Linux fix!)"
    echo "  ✅ Better performance than official client"
    echo "  ✅ Open source"
    echo ""
    echo "💡 First run: Install Vencord from Settings"
}

install_armcord() {
    echo ""
    echo "📥 Installing ArmCord..."

    ARMCORD_VERSION="3.2.7"
    ARMCORD_URL="https://github.com/ArmCord/ArmCord/releases/download/v${ARMCORD_VERSION}/ArmCord_${ARMCORD_VERSION}_amd64.rpm"

    cd /tmp
    echo "Downloading ArmCord ${ARMCORD_VERSION}..."
    wget -q --show-progress "$ARMCORD_URL" -O armcord.rpm

    # On Bazzite, use rpm-ostree
    if command -v rpm-ostree &> /dev/null; then
        rpm-ostree install ./armcord.rpm
        echo "✅ ArmCord layered on system (reboot required)"
    else
        sudo dnf install -y ./armcord.rpm
        echo "✅ ArmCord installed"
    fi

    rm armcord.rpm

    echo ""
    echo "📖 ArmCord Features:"
    echo "  ✅ Lightweight (less RAM than official)"
    echo "  ✅ Privacy-focused (blocks trackers)"
    echo "  ✅ Custom CSS themes"
    echo "  ✅ Mobile app support"
}

install_equicord() {
    echo ""
    echo "📥 Installing Equicord..."

    if command -v flatpak &> /dev/null; then
        # Note: Equicord may not have official Flatpak yet
        echo "⚠️  Equicord Flatpak not available"
        echo "Installing from GitHub releases..."
    fi

    EQUICORD_VERSION="1.9.3"
    EQUICORD_URL="https://github.com/Equicord/Equicord/releases/download/v${EQUICORD_VERSION}/equicord-${EQUICORD_VERSION}.AppImage"
    EQUICORD_DIR="${HOME}/.local/share/equicord"

    mkdir -p "$EQUICORD_DIR"
    cd "$EQUICORD_DIR"

    echo "Downloading Equicord ${EQUICORD_VERSION}..."
    wget -q --show-progress "$EQUICORD_URL" -O equicord.AppImage
    chmod +x equicord.AppImage

    # Create launcher
    mkdir -p ~/.local/bin
    cat > ~/.local/bin/equicord <<EOF
#!/bin/bash
$EQUICORD_DIR/equicord.AppImage
EOF
    chmod +x ~/.local/bin/equicord

    echo "✅ Equicord installed to: $EQUICORD_DIR"
    echo ""
    echo "📖 Equicord Features:"
    echo "  ✅ Equicord mod (custom plugins)"
    echo "  ✅ Enhanced privacy"
    echo "  ✅ Message logger"
    echo "  ✅ Custom themes"
}

install_official_discord() {
    echo ""
    echo "📥 Installing Official Discord..."

    if command -v flatpak &> /dev/null; then
        flatpak install -y flathub com.discordapp.Discord
        echo "✅ Official Discord installed via Flatpak"
    else
        rpm-ostree install discord
        echo "✅ Discord layered on system (reboot required)"
    fi

    echo ""
    echo "📖 Official Discord:"
    echo "  ⚠️  No screen share audio on Linux"
    echo "  ⚠️  Higher resource usage"
    echo "  ✅ Official support"
    echo "  ✅ Most stable"
}

case $choice in
    1)
        install_vesktop
        ;;
    2)
        install_armcord
        ;;
    3)
        install_equicord
        ;;
    4)
        install_official_discord
        ;;
    5)
        install_vesktop
        install_armcord
        install_equicord
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "💬 Discord Client Setup Complete!"
echo ""
echo "📊 Comparison:"
echo "  Vesktop:   Best features + screen share audio ⭐"
echo "  ArmCord:   Lightweight + privacy"
echo "  Equicord:  Equicord mod + plugins"
echo "  Official:  Most stable, but no audio share on Linux"
echo ""
echo "💡 Recommendation: Start with Vesktop"
echo ""
echo "🔗 Communities:"
echo "  - Bazzite Discord: discord.gg/f8MUghG5PB"
echo "  - Universal Blue: discord.gg/WEu6BdFEtp"
echo "  - Linux Gaming: discord.gg/linuxgaming"

# Log with ATOM if available
if command -v atom &> /dev/null; then
    atom CONFIG "Installed Discord client(s)" "$choice"
fi
