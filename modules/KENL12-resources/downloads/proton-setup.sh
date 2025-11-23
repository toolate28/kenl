#!/usr/bin/env bash
#
# proton-setup.sh - Setup Proton VPN and Mail Bridge
#
# Installs Proton services for privacy-focused VPN and encrypted email
#

set -euo pipefail

echo "🔐 Proton Services Setup"
echo ""
echo "What would you like to install?"
echo "  1) Proton VPN"
echo "  2) Proton Mail Bridge"
echo "  3) Both"
echo ""
read -rp "Choose [1-3]: " choice

install_proton_vpn() {
    echo ""
    echo "📥 Installing Proton VPN..."

    # Check if Flatpak available
    if command -v flatpak &> /dev/null; then
        echo "Using Flatpak (recommended for Bazzite)..."
        flatpak install -y flathub com.protonvpn.www

        echo "✅ Proton VPN installed via Flatpak"
        echo ""
        echo "To launch: flatpak run com.protonvpn.www"
        echo "Or search 'Proton VPN' in application menu"
    else
        echo "⚠️  Flatpak not available. Installing via rpm-ostree..."

        # Add Proton VPN repository
        sudo wget -q https://repo.protonvpn.com/fedora-$(rpm -E %fedora)-stable/protonvpn-stable-release/protonvpn-stable-release-1.0.1-2.noarch.rpm

        # Layer package
        rpm-ostree install ./protonvpn-stable-release-1.0.1-2.noarch.rpm protonvpn

        echo "✅ Proton VPN layered on system"
        echo "⚠️  Reboot required: systemctl reboot"
    fi

    echo ""
    echo "📖 Proton VPN Setup Guide:"
    echo "  1. Launch Proton VPN"
    echo "  2. Log in with Proton account"
    echo "  3. Connect to VPN server"
    echo "  4. (Optional) Enable Kill Switch in Settings"
    echo "  5. (Optional) Enable NetShield ad-blocker"
    echo ""
    echo "For KENL11 (torrenting), see: ~/kenl/modules/KENL11-media/vpn/"
}

install_proton_mail_bridge() {
    echo ""
    echo "📥 Installing Proton Mail Bridge..."

    if command -v flatpak &> /dev/null; then
        echo "Using Flatpak (recommended for Bazzite)..."
        flatpak install -y flathub ch.protonmail.protonmail-bridge

        echo "✅ Proton Mail Bridge installed via Flatpak"
        echo ""
        echo "To launch: flatpak run ch.protonmail.protonmail-bridge"
    else
        echo "⚠️  Flatpak not available."
        echo "Download from: https://proton.me/mail/bridge#download"
        echo "Manual installation required on non-Flatpak systems"
        exit 1
    fi

    echo ""
    echo "📖 Proton Mail Bridge Setup Guide:"
    echo "  1. Launch Proton Mail Bridge"
    echo "  2. Log in with Proton account"
    echo "  3. Configure email client (Thunderbird recommended):"
    echo "     - IMAP: 127.0.0.1:1143"
    echo "     - SMTP: 127.0.0.1:1025"
    echo "     - Use generated password from Bridge"
    echo ""
    echo "For KENL8 integration, see: ~/kenl/modules/KENL8-security/README.md"
}

case $choice in
    1)
        install_proton_vpn
        ;;
    2)
        install_proton_mail_bridge
        ;;
    3)
        install_proton_vpn
        install_proton_mail_bridge
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "🔐 Proton Setup Complete!"
echo ""
echo "💡 Proton Tips:"
echo "  - Free tier: 1 VPN connection, 3 countries"
echo "  - Plus tier: 10 VPN connections, all countries, NetShield"
echo "  - Mail Bridge requires paid Proton plan"
echo "  - Use with KENL11 for VPN-wrapped torrenting"
echo ""
echo "Privacy resources:"
echo "  - ProtonVPN guide: https://protonvpn.com/support/"
echo "  - Mail Bridge guide: https://proton.me/support/protonmail-bridge-clients"

# Log with ATOM if available
if command -v atom &> /dev/null; then
    atom CONFIG "Installed Proton services" "VPN and/or Mail Bridge"
fi
