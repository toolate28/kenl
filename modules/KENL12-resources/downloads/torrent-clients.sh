#!/usr/bin/env bash
#
# torrent-clients.sh - Install torrent clients
#
# Supports: qBittorrent, Transmission, Deluge
#

set -euo pipefail

echo "📥 Torrent Client Setup"
echo ""
echo "Choose torrent client:"
echo "  1) qBittorrent (Recommended - best features)"
echo "  2) Transmission (Lightweight)"
echo "  3) Deluge (Plugin ecosystem)"
echo "  4) All three"
echo ""
read -rp "Choose [1-4]: " choice

install_qbittorrent() {
    echo ""
    echo "📥 Installing qBittorrent..."

    if command -v flatpak &> /dev/null; then
        flatpak install -y flathub org.qbittorrent.qBittorrent
        echo "✅ qBittorrent installed via Flatpak"
    else
        rpm-ostree install qbittorrent
        echo "✅ qBittorrent layered on system (reboot required)"
    fi

    echo ""
    echo "📖 qBittorrent Tips:"
    echo "  - Enable Web UI: Tools → Options → Web UI"
    echo "  - Default port: 8080 (username: admin, password in terminal)"
    echo "  - For KENL11 automation, see docker-compose setup"
}

install_transmission() {
    echo ""
    echo "📥 Installing Transmission..."

    if command -v flatpak &> /dev/null; then
        flatpak install -y flathub com.transmissionbt.Transmission
        echo "✅ Transmission installed via Flatpak"
    else
        rpm-ostree install transmission-gtk
        echo "✅ Transmission layered on system (reboot required)"
    fi

    echo ""
    echo "📖 Transmission Tips:"
    echo "  - Very lightweight (~20MB RAM)"
    echo "  - Simple, no-frills interface"
    echo "  - Good for headless servers"
}

install_deluge() {
    echo ""
    echo "📥 Installing Deluge..."

    if command -v flatpak &> /dev/null; then
        flatpak install -y flathub org.deluge_torrent.deluge
        echo "✅ Deluge installed via Flatpak"
    else
        rpm-ostree install deluge
        echo "✅ Deluge layered on system (reboot required)"
    fi

    echo ""
    echo "📖 Deluge Tips:"
    echo "  - Rich plugin ecosystem"
    echo "  - Thin client/server architecture"
    echo "  - Good for remote management"
}

case $choice in
    1)
        install_qbittorrent
        ;;
    2)
        install_transmission
        ;;
    3)
        install_deluge
        ;;
    4)
        install_qbittorrent
        install_transmission
        install_deluge
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "📥 Torrent Client Setup Complete!"
echo ""
echo "⚠️  IMPORTANT: Privacy & Legal Usage"
echo "  ✅ DO: Use VPN when torrenting"
echo "  ✅ DO: Torrent open-source software, Creative Commons media"
echo "  ❌ DON'T: Pirate copyrighted content"
echo "  ❌ DON'T: Torrent without VPN on ISP connection"
echo ""
echo "💡 For automated torrenting with VPN:"
echo "  See: ~/kenl/modules/KENL11-media/README.md"
echo "  Includes: qBittorrent + Proton VPN + Radarr/Sonarr"
echo ""
echo "Privacy-focused torrent search:"
echo "  - Knaben.eu (meta-search)"
echo "  - 1337x.to"
echo "  - RARBG alternatives"

# Log with ATOM if available
if command -v atom &> /dev/null; then
    atom CONFIG "Installed torrent client(s)" "$choice"
fi
