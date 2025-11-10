# modules/KENL12: Resources & Community Links

**Icon:** 📚 | **Color:** Cyan | **Status:** Reference Library

Curated collection of CSS snippets, Bazzite/Bazzite-DX resources, distrobox guides, community links, and **one-click setup scripts** for essential applications.

---

## 🚀 Quick Setup Scripts

**One-command installations** for essential tools. All scripts include ATOM trail integration.

### Available Scripts

| Script | What It Installs | Command |
|--------|------------------|---------|
| 🦊 **Floorp Browser** | Privacy-focused Firefox fork | `./downloads/floorp-browser.sh` |
| 🔐 **Proton Services** | Proton VPN, Mail Bridge | `./downloads/proton-setup.sh` |
| 📥 **Torrent Clients** | qBittorrent, Transmission, Deluge | `./downloads/torrent-clients.sh` |
| 💾 **Bootable USB Tools** | Ventoy, Balena Etcher | `./downloads/bootable-usb.sh` |
| 💬 **Discord Clients** | Vesktop, ArmCord, Equicord | `./downloads/discord-clients.sh` |
| 📰 **RSS Feeds** | Bazzite & Linux gaming news | `./rss-feeds/setup-rss.sh` |

**Usage:**
```bash
cd ~/kenl/KENL12-resources
./downloads/floorp-browser.sh  # Interactive menu
./rss-feeds/setup-rss.sh       # Setup RSS feeds
```

[See detailed download links below ↓](#direct-download-links)

---

## 📥 Direct Download Links

### Browsers

**Floorp Browser** (Firefox-based, privacy-focused):
- [Latest Release](https://github.com/Floorp-Projects/Floorp/releases/latest)
- [Linux x86_64 .tar.bz2](https://github.com/Floorp-Projects/Floorp/releases)
- Features: Tree tabs, vertical tabs, enhanced privacy
- **Quick setup**: `./downloads/floorp-browser.sh`

**LibreWolf** (Firefox without telemetry):
- [LibreWolf Releases](https://librewolf.net/installation/)
- Flatpak: `flatpak install flathub io.gitlab.librewolf-community`

**Brave** (Chromium-based, built-in ad blocker):
- [Brave Download](https://brave.com/linux/)
- Flatpak: `flatpak install flathub com.brave.Browser`

### Privacy & VPN

**Proton Services**:
- [Proton VPN](https://protonvpn.com/download) - Free tier available
- [Proton Mail Bridge](https://proton.me/mail/bridge#download) - Requires paid plan
- Flatpak (VPN): `flatpak install flathub com.protonvpn.www`
- Flatpak (Mail): `flatpak install flathub ch.protonmail.protonmail-bridge`
- **Quick setup**: `./downloads/proton-setup.sh`

**Mullvad VPN** (Privacy-focused, no logs):
- [Mullvad Download](https://mullvad.net/en/download/)
- Best for: Privacy advocates, torrenting

### Torrent Clients

**qBittorrent** (Recommended):
- [qBittorrent Download](https://www.qbittorrent.org/download.php)
- Flatpak: `flatpak install flathub org.qbittorrent.qBittorrent`
- Features: Web UI, RSS, search plugins

**Transmission** (Lightweight):
- Flatpak: `flatpak install flathub com.transmissionbt.Transmission`
- Best for: Simple torrenting, low RAM

**Deluge** (Plugin ecosystem):
- Flatpak: `flatpak install flathub org.deluge_torrent.deluge`
- Best for: Advanced users, automation

**Quick setup**: `./downloads/torrent-clients.sh`

### Bootable USB Creation

**Ventoy** (Multi-boot USB, drag-and-drop ISOs):
- [Ventoy Releases](https://github.com/ventoy/Ventoy/releases/latest)
- [Linux .tar.gz](https://github.com/ventoy/Ventoy/releases)
- **Recommended**: Best for keeping multiple ISOs on one USB
- **Quick setup**: `./downloads/bootable-usb.sh`

**Balena Etcher** (Simple ISO flashing):
- [Etcher Download](https://etcher.balena.io/#download-etcher)
- Flatpak: `flatpak install flathub io.balena.Etcher`
- Best for: Single ISO writes

**Rufus** (via Wine, Windows tool):
- [Rufus Download](https://rufus.ie/downloads/)
- Note: Ventoy recommended over Rufus on Linux

### Discord Clients

**Vesktop** (Vencord + screen share audio) ⭐ **Recommended**:
- [Vesktop Releases](https://github.com/Vencord/Vesktop/releases)
- Flatpak: `flatpak install flathub dev.vencord.Vesktop`
- Why: Screen share with audio works on Linux!

**ArmCord** (Lightweight, privacy-focused):
- [ArmCord Releases](https://github.com/ArmCord/ArmCord/releases/latest)
- [Linux .rpm](https://github.com/ArmCord/ArmCord/releases)

**Equicord** (Equicord mod):
- [Equicord Releases](https://github.com/Equicord/Equicord/releases)
- [Linux AppImage](https://github.com/Equicord/Equicord/releases)

**Quick setup**: `./downloads/discord-clients.sh`

### Proxies & Network Tools

**Nginx Proxy Manager** (Reverse proxy with Web UI):
- [NPM Docker](https://nginxproxymanager.com/setup/)
- See: `~/kenl/KENL11-media/proxies/` for docker-compose

**Caddy** (Automatic HTTPS reverse proxy):
- [Caddy Download](https://caddyserver.com/download)
- Best for: Simple HTTPS setups

**Privoxy** (HTTP proxy, ad filtering):
- Install: `rpm-ostree install privoxy`
- Best for: Local ad blocking

**Squid** (Caching proxy):
- Install: `rpm-ostree install squid`
- Best for: Network caching

---

## 📰 RSS Feeds & News

**Setup Script**: `./rss-feeds/setup-rss.sh`

Automatically configures RSS reader with curated feeds:

### Included Feed Categories

**🎮 Bazzite & Universal Blue:**
- Bazzite News (Discourse)
- Universal Blue Announcements
- Bazzite GitHub Releases

**🐧 Linux Gaming:**
- GamingOnLinux
- Boiling Steam
- ProtonDB Recent Reports

**🍷 Proton & Compatibility:**
- Proton GE Releases (GloriousEggroll)
- Valve Proton Releases

**📦 Fedora & Atomic:**
- Fedora Magazine
- Fedora Project News

**🔧 Hardware & Drivers:**
- Phoronix (Linux hardware news)
- Mesa Releases (graphics drivers)

**💬 Reddit Communities:**
- r/Bazzite
- r/linux_gaming
- r/SteamDeck
- r/Fedora

**Supported RSS Readers:**
- Newsboat (terminal-based)
- Akregator (KDE)
- Liferea (GTK)
- Any reader (OPML export)

---

## Quick Links

### 🎨 CSS Snippets & Theming

**KDE Plasma Themes:**
- [Catppuccin KDE](https://github.com/catppuccin/kde) - Soothing pastel theme
- [Nordic KDE](https://github.com/EliverLara/Nordic) - Nord-based theme
- [Gruvbox KDE](https://github.com/sachahjkl/gruvbox-kde) - Retro groove colors

**Terminal Color Schemes:**
- [Gogh](https://github.com/Gogh-Co/Gogh) - 300+ terminal color schemes
- [base16](https://github.com/chriskempson/base16) - Architecture for color schemes
- [Nord](https://www.nordtheme.com/) - Arctic, north-bluish color palette

**GTK Themes:**
- [Catppuccin GTK](https://github.com/catppuccin/gtk) - GTK2/3/4 theme
- [Dracula GTK](https://github.com/dracula/gtk) - Dark theme
- [Gruvbox GTK](https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme) - Warm retro

**Firefox/Browser CSS:**
- [Firefox CSS](https://github.com/MrOtherGuy/firefox-csshacks) - 1000+ userChrome.css tweaks
- [Cascade](https://github.com/andreasgrafen/cascade) - Minimal Firefox theme
- [Catppuccin Firefox](https://github.com/catppuccin/firefox) - Catppuccin theme

→ See [`css-snippets/`](./css-snippets/)

---

## 🎮 Bazzite Resources

### Official Bazzite

**GitHub:**
- [ublue-os/bazzite](https://github.com/ublue-os/bazzite) - Main repository
- [Bazzite Releases](https://github.com/ublue-os/bazzite/releases) - Download ISOs
- [Bazzite Issues](https://github.com/ublue-os/bazzite/issues) - Bug reports

**Documentation:**
- [Bazzite Docs](https://universal-blue.discourse.group/docs?category=11) - Official documentation
- [Getting Started](https://universal-blue.discourse.group/docs?topic=35) - First steps
- [Gaming Guide](https://universal-blue.discourse.group/docs?topic=37) - Gaming optimization
- [FAQ](https://universal-blue.discourse.group/docs?topic=33) - Common questions

**Community:**
- [Universal Blue Forum](https://universal-blue.discourse.group/) - Discussions
- [Discord](https://discord.gg/f8MUghG5PB) - Real-time support
- [Reddit r/Bazzite](https://www.reddit.com/r/Bazzite/) - Community discussions

**Social:**
- [Twitter/X @teamublue](https://twitter.com/teamublue) - Updates
- [Mastodon @bazzite](https://fosstodon.org/@bazzite) - Announcements

### Bazzite-DX

**What is Bazzite-DX?**
- Developer-focused variant of Bazzite
- Includes distrobox, toolbox, development tools
- Same gaming optimizations as standard Bazzite
- Perfect for gaming + development workflows

**Resources:**
- [Bazzite-DX Image](https://github.com/ublue-os/bazzite#bazzite-dx) - Description
- Development containers pre-configured
- modules/KENL integrates perfectly with Bazzite-DX

### Related Projects

**Universal Blue Ecosystem:**
- [Bluefin](https://github.com/ublue-os/bluefin) - Developer-focused desktop
- [Aurora](https://github.com/ublue-os/aurora) - KDE Plasma variant
- [uBlue Main](https://github.com/ublue-os/main) - Base images

**Gaming Tools (Pre-installed on Bazzite):**
- [Steam](https://store.steampowered.com/) - Game platform
- [Proton](https://github.com/ValveSoftware/Proton) - Windows compatibility
- [Proton GE](https://github.com/GloriousEggroll/proton-ge-custom) - Community Proton
- [Lutris](https://lutris.net/) - Game launcher
- [GameMode](https://github.com/FeralInteractive/gamemode) - Performance optimization
- [MangoHud](https://github.com/flightlessmango/MangoHud) - Performance overlay

→ See [`bazzite-resources/`](./bazzite-resources/)

---

## 📦 Distrobox Resources

### Official Documentation

- [Distrobox GitHub](https://github.com/89luca89/distrobox) - Main repository
- [Distrobox Docs](https://distrobox.it/) - Official documentation
- [Compatibility List](https://github.com/89luca89/distrobox/blob/main/docs/compatibility.md) - Supported distros

### Guides & Tutorials

**Official Guides:**
- [Getting Started](https://github.com/89luca89/distrobox/blob/main/docs/getting-started.md)
- [Useful Tips](https://github.com/89luca89/distrobox/blob/main/docs/useful_tips.md)
- [Exporting Apps](https://github.com/89luca89/distrobox/blob/main/docs/usage/distrobox-export.md)
- [GUI Applications](https://github.com/89luca89/distrobox/blob/main/docs/useful_tips.md#using-distrobox-for-graphical-applications)

**Community Guides:**
- [Fedora Magazine: Distrobox](https://fedoramagazine.org/distrobox-a-box-full-of-distros/) - Introduction
- [Linux Unplugged: Distrobox](https://www.jupiterbroadcasting.com/show/linux-unplugged/477/) - Podcast episode
- [DistroTube: Distrobox](https://www.youtube.com/watch?v=_pMm7p2OOh8) - Video tutorial

### Podman/Docker Resources

**Podman (Used by Distrobox):**
- [Podman GitHub](https://github.com/containers/podman) - Main repository
- [Podman Docs](https://docs.podman.io/) - Official documentation
- [Podman Desktop](https://podman-desktop.io/) - GUI for Podman

**Container Images:**
- [Docker Hub](https://hub.docker.com/) - Container registry
- [Quay.io](https://quay.io/) - Red Hat container registry
- [GitHub Container Registry](https://ghcr.io/) - GitHub packages

### Pre-built Distrobox Configs

- [Toolbx Images](https://github.com/containers/toolbox#readme) - Fedora Toolbx
- [Bazzite Distrobox Templates](https://github.com/ublue-os/bazzite/tree/main/usr/share/ublue-os/distrobox) - Bazzite configs
- [Awesome Distrobox](https://github.com/89luca89/distrobox#articles-and-tutorials) - Community examples

→ See [`distrobox-resources/`](./distrobox-resources/)

---

## 🌐 Linux Gaming Community

### Proton & Compatibility

**ProtonDB:**
- [ProtonDB](https://www.protondb.com/) - Game compatibility database
- [Steam Deck Verified](https://www.steamdeck.com/en/verified) - Official ratings
- [Are We Anti-Cheat Yet](https://areweanticheatyet.com/) - Anti-cheat status

**Proton Resources:**
- [Proton GitHub](https://github.com/ValveSoftware/Proton) - Official Proton
- [Proton GE Releases](https://github.com/GloriousEggroll/proton-ge-custom/releases) - Latest GE builds
- [Proton Tips](https://github.com/ValveSoftware/Proton/wiki/Proton-FAQ) - Official FAQ

### Reddit Communities

- [r/linux_gaming](https://www.reddit.com/r/linux_gaming/) - 245K+ members
- [r/SteamDeck](https://www.reddit.com/r/SteamDeck/) - 500K+ members
- [r/Bazzite](https://www.reddit.com/r/Bazzite/) - Growing community
- [r/Fedora](https://www.reddit.com/r/Fedora/) - Fedora discussions

### Discord Servers

- [Universal Blue Discord](https://discord.gg/f8MUghG5PB) - Bazzite official
- [GamingOnLinux Discord](https://discord.gg/gamingonlinux) - Linux gaming general
- [ProtonDB Discord](https://discord.gg/uuwK9EV) - Proton help

### YouTube Channels

- [GamingOnLinux](https://www.youtube.com/@gamingonlinux) - News & reviews
- [The Linux Experiment](https://www.youtube.com/@TheLinuxEXP) - Linux desktop
- [Linux For Everyone](https://www.youtube.com/@LinuxForEveryone) - Beginner-friendly
- [Distrotube](https://www.youtube.com/@DistroTube) - Advanced Linux

### News Sites

- [GamingOnLinux](https://www.gamingonlinux.com/) - Linux gaming news
- [Phoronix](https://www.phoronix.com/) - Linux hardware & software
- [Boiling Steam](https://boilingsteam.com/) - Steam Deck & Linux gaming

→ See [`community-links/`](./community-links/)

---

## 📊 Performance & Benchmarking

**Tools:**
- [MangoHud](https://github.com/flightlessmango/MangoHud) - FPS overlay
- [GOverlay](https://github.com/benjamimgois/goverlay) - MangoHud GUI
- [CoreCtrl](https://gitlab.com/corectrl/corectrl) - GPU overclocking

**Benchmarks:**
- [OpenBenchmarking](https://openbenchmarking.org/) - Phoronix Test Suite
- [Flightless Mango Benchmarks](https://flightlessmango.com/) - Game benchmarks

---

## 🔧 Development Tools

### Terminal & Shell

**Shells:**
- [Fish Shell](https://fishshell.com/) - User-friendly shell
- [Zsh](https://www.zsh.org/) - Powerful shell
- [Oh My Zsh](https://ohmyz.sh/) - Zsh framework
- [Starship](https://starship.rs/) - Cross-shell prompt

**Terminal Emulators:**
- [Alacritty](https://github.com/alacritty/alacritty) - GPU-accelerated
- [Kitty](https://sw.kovidgoyal.net/kitty/) - Feature-rich
- [WezTerm](https://wezfurlong.org/wezterm/) - GPU-based
- [Konsole](https://konsole.kde.org/) - KDE default

### Code Editors

- [VS Code](https://code.visualstudio.com/) - Popular IDE
- [VSCodium](https://vscodium.com/) - FOSS VS Code
- [Neovim](https://neovim.io/) - Modernized Vim
- [Helix](https://helix-editor.com/) - Post-modern text editor

### AI Coding Assistants

- [Claude Code](https://claude.ai/code) - Anthropic AI coding
- [GitHub Copilot](https://github.com/features/copilot) - AI pair programmer
- [Codeium](https://codeium.com/) - Free AI code completion
- [Ollama](https://ollama.com/) - Local LLMs (Qwen, CodeLlama)

---

## 🎨 Customization

### Dotfiles Repos

- [awesome-dotfiles](https://github.com/webpro/awesome-dotfiles) - Curated list
- [dotfiles.github.io](https://dotfiles.github.io/) - Guide & examples
- [r/unixporn](https://www.reddit.com/r/unixporn/) - Desktop customization

### Icon Themes

- [Papirus](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme) - Modern icons
- [Breeze](https://github.com/KDE/breeze-icons) - KDE official
- [Tela](https://github.com/vinceliuice/Tela-icon-theme) - Flat colorful

### Fonts

- [Nerd Fonts](https://www.nerdfonts.com/) - Patched developer fonts
- [Cascadia Code](https://github.com/microsoft/cascadia-code) - Microsoft monospace
- [JetBrains Mono](https://www.jetbrains.com/lp/mono/) - Developer font
- [Fira Code](https://github.com/tonsky/FiraCode) - Monospace with ligatures

---

## 📦 Fedora Atomic Resources

### rpm-ostree

- [rpm-ostree Docs](https://coreos.github.io/rpm-ostree/) - Official documentation
- [Fedora Silverblue](https://docs.fedoraproject.org/en-US/fedora-silverblue/) - Guide
- [OSTree](https://ostreedev.github.io/ostree/) - Core technology

### Universal Blue

- [Universal Blue](https://universal-blue.org/) - Main site
- [Bluefin Project](https://projectbluefin.io/) - Developer desktop
- [Image Builder](https://blue-build.org/) - Custom image tool

---

## 🤝 Contributing

Found a useful resource? Add it!

1. Fork the repository
2. Add to appropriate section in this README
3. Or add files to subdirectories:
   - `css-snippets/` - CSS files, themes
   - `bazzite-resources/` - Bazzite-specific docs
   - `distrobox-resources/` - Distrobox configs
   - `community-links/` - Additional links
4. Submit PR

---

## Navigation

- **← [Root README](../README.md)**: Overview of all modules/KENL modules
- **→ [KENL5: Facades](../modules/KENL5-facades/README.md)**: Visual theming
- **→ [KENL7: Learning](../modules/KENL7-learning/README.md)**: Tutorials

---

**Status**: Reference Library | **Icon**: 📚 | **Type**: Community Resource Collection
