#!/usr/bin/env bash
#
# setup-rss.sh - Setup RSS feeds for Bazzite and Linux gaming news
#
# Configures RSS reader with curated feeds
#

set -euo pipefail

echo "📰 RSS Feeds Setup"
echo ""
echo "Choose RSS reader:"
echo "  1) Newsboat (Terminal-based, lightweight)"
echo "  2) Akregator (KDE RSS reader)"
echo "  3) Liferea (GTK RSS reader)"
echo "  4) Just generate OPML file (import manually)"
echo ""
read -rp "Choose [1-4]: " choice

# Generate OPML file with curated feeds
generate_opml() {
    local opml_file="$1"

    cat > "$opml_file" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head>
    <title>KENL Curated Feeds</title>
    <dateCreated>2025-11-10</dateCreated>
  </head>
  <body>
    <outline text="Bazzite &amp; Universal Blue" title="Bazzite &amp; Universal Blue">
      <outline type="rss" text="Bazzite News" title="Bazzite News"
        xmlUrl="https://universal-blue.discourse.group/c/bazzite/11.rss"
        htmlUrl="https://universal-blue.discourse.group/c/bazzite/11"/>
      <outline type="rss" text="Universal Blue Announcements" title="Universal Blue Announcements"
        xmlUrl="https://universal-blue.discourse.group/c/announcements/6.rss"
        htmlUrl="https://universal-blue.discourse.group/c/announcements/6"/>
      <outline type="rss" text="Bazzite GitHub Releases" title="Bazzite GitHub Releases"
        xmlUrl="https://github.com/ublue-os/bazzite/releases.atom"
        htmlUrl="https://github.com/ublue-os/bazzite/releases"/>
    </outline>

    <outline text="Linux Gaming" title="Linux Gaming">
      <outline type="rss" text="GamingOnLinux" title="GamingOnLinux"
        xmlUrl="https://www.gamingonlinux.com/article_rss.php"
        htmlUrl="https://www.gamingonlinux.com/"/>
      <outline type="rss" text="Boiling Steam" title="Boiling Steam"
        xmlUrl="https://boilingsteam.com/feed/"
        htmlUrl="https://boilingsteam.com/"/>
      <outline type="rss" text="ProtonDB Recent" title="ProtonDB Recent"
        xmlUrl="https://www.protondb.com/rss/recent"
        htmlUrl="https://www.protondb.com/"/>
    </outline>

    <outline text="Proton &amp; Compatibility" title="Proton &amp; Compatibility">
      <outline type="rss" text="Proton GE Releases" title="Proton GE Releases"
        xmlUrl="https://github.com/GloriousEggroll/proton-ge-custom/releases.atom"
        htmlUrl="https://github.com/GloriousEggroll/proton-ge-custom/releases"/>
      <outline type="rss" text="Valve Proton Releases" title="Valve Proton Releases"
        xmlUrl="https://github.com/ValveSoftware/Proton/releases.atom"
        htmlUrl="https://github.com/ValveSoftware/Proton/releases"/>
    </outline>

    <outline text="Fedora &amp; Atomic" title="Fedora &amp; Atomic">
      <outline type="rss" text="Fedora Magazine" title="Fedora Magazine"
        xmlUrl="https://fedoramagazine.org/feed/"
        htmlUrl="https://fedoramagazine.org/"/>
      <outline type="rss" text="Fedora Project News" title="Fedora Project News"
        xmlUrl="https://fedoraproject.org/rss.xml"
        htmlUrl="https://fedoraproject.org/"/>
    </outline>

    <outline text="Hardware &amp; Drivers" title="Hardware &amp; Drivers">
      <outline type="rss" text="Phoronix" title="Phoronix"
        xmlUrl="https://www.phoronix.com/rss.php"
        htmlUrl="https://www.phoronix.com/"/>
      <outline type="rss" text="Mesa Releases" title="Mesa Releases"
        xmlUrl="https://www.mesa3d.org/relnotes/rss.xml"
        htmlUrl="https://www.mesa3d.org/"/>
    </outline>

    <outline text="Reddit" title="Reddit">
      <outline type="rss" text="r/Bazzite" title="r/Bazzite"
        xmlUrl="https://www.reddit.com/r/Bazzite/.rss"
        htmlUrl="https://www.reddit.com/r/Bazzite/"/>
      <outline type="rss" text="r/linux_gaming" title="r/linux_gaming"
        xmlUrl="https://www.reddit.com/r/linux_gaming/.rss"
        htmlUrl="https://www.reddit.com/r/linux_gaming/"/>
      <outline type="rss" text="r/SteamDeck" title="r/SteamDeck"
        xmlUrl="https://www.reddit.com/r/SteamDeck/.rss"
        htmlUrl="https://www.reddit.com/r/SteamDeck/"/>
      <outline type="rss" text="r/Fedora" title="r/Fedora"
        xmlUrl="https://www.reddit.com/r/Fedora/.rss"
        htmlUrl="https://www.reddit.com/r/Fedora/"/>
    </outline>
  </body>
</opml>
EOF

    echo "✅ OPML file generated: $opml_file"
}

install_newsboat() {
    echo ""
    echo "📥 Installing Newsboat..."

    if command -v flatpak &> /dev/null; then
        flatpak install -y flathub io.gitlab.news_flash.NewsFlash
        echo "⚠️  Newsboat not available on Flatpak, installed NewsFlash instead"
        echo "   (Modern GUI RSS reader)"
    else
        rpm-ostree install newsboat
        echo "✅ Newsboat layered on system (reboot required)"
    fi

    # Generate config
    mkdir -p ~/.newsboat
    generate_opml ~/.newsboat/urls-kenl.opml

    # Create newsboat config
    cat > ~/.newsboat/config <<'EOF'
# KENL Newsboat Configuration
auto-reload yes
reload-time 30
reload-threads 4
browser "xdg-open %u"
player "mpv %u"

# Vim keybindings
bind-key j down
bind-key k up
bind-key J next-feed
bind-key K prev-feed
bind-key g home
bind-key G end

# Color scheme (Catppuccin-inspired)
color background default default
color listnormal cyan default
color listfocus black yellow bold
color listnormal_unread blue default
color listfocus_unread yellow default bold
color info black blue bold
color article default default

# Import KENL feeds
include ~/.newsboat/urls-kenl.opml
EOF

    echo ""
    echo "📖 Newsboat Usage:"
    echo "  Run: newsboat"
    echo "  Keys: j/k (nav), Space (open), r (reload), q (quit)"
    echo "  Config: ~/.newsboat/config"
}

install_akregator() {
    echo ""
    echo "📥 Installing Akregator..."

    if command -v flatpak &> /dev/null; then
        flatpak install -y flathub org.kde.akregator
    else
        rpm-ostree install akregator
        echo "⚠️  Reboot required"
    fi

    local opml_file="$HOME/kenl-feeds.opml"
    generate_opml "$opml_file"

    echo ""
    echo "📖 Akregator Setup:"
    echo "  1. Launch Akregator"
    echo "  2. File → Import Feeds"
    echo "  3. Select: $opml_file"
    echo "  4. Enjoy!"
}

install_liferea() {
    echo ""
    echo "📥 Installing Liferea..."

    if command -v flatpak &> /dev/null; then
        flatpak install -y flathub net.sourceforge.liferea
    else
        rpm-ostree install liferea
        echo "⚠️  Reboot required"
    fi

    local opml_file="$HOME/kenl-feeds.opml"
    generate_opml "$opml_file"

    echo ""
    echo "📖 Liferea Setup:"
    echo "  1. Launch Liferea"
    echo "  2. File → Import Feed List"
    echo "  3. Select: $opml_file"
}

case $choice in
    1)
        install_newsboat
        ;;
    2)
        install_akregator
        ;;
    3)
        install_liferea
        ;;
    4)
        local opml_file="$HOME/kenl-feeds.opml"
        generate_opml "$opml_file"
        echo ""
        echo "📖 Import into your RSS reader:"
        echo "  File: $opml_file"
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "📰 RSS Setup Complete!"
echo ""
echo "📚 Included Feed Categories:"
echo "  🎮 Bazzite & Universal Blue (news, releases)"
echo "  🐧 Linux Gaming (GamingOnLinux, Boiling Steam, ProtonDB)"
echo "  🍷 Proton (GE releases, Valve Proton)"
echo "  📦 Fedora & Atomic (Fedora Magazine, project news)"
echo "  🔧 Hardware (Phoronix, Mesa)"
echo "  💬 Reddit (r/Bazzite, r/linux_gaming, r/SteamDeck, r/Fedora)"
echo ""
echo "💡 Stay updated on:"
echo "  - New Bazzite releases"
echo "  - Proton GE updates"
echo "  - Linux game releases and compatibility"
echo "  - Hardware driver improvements"

# Log with ATOM if available
if command -v atom &> /dev/null; then
    atom CONFIG "Setup RSS feeds" "Bazzite + Linux gaming news"
fi
