---
title: KENL6 Library - Game Library, Media Server & Resources
version: 2.0.0
atom: ATOM-DOC-20251205-004
status: production
classification: MODULE-README
---

# KENL6: Library & Content Management

**Icon:** 📚 | **Color:** Cyan | **Status:** Production

Unified content and resource management for games, media, and community resources. Optimizes storage, automates media acquisition, and provides curated resources for the Bazzite/Linux gaming community.

---

## 📦 What's Included

### 🎮 Game Library (`game-library/`)
- **Shared Steam libraries** across dual-boot (Linux + Windows)
- **Save game synchronization** between operating systems
- **Launcher integration** (Steam, EA App, Epic, GOG, Heroic)
- **Storage optimization** (deduplicate, compress, archive)
- **Migration tools** (Windows → Linux, HDD → SSD)
- **Cloud save backup** (encrypted via KENL5-security)

### 🎬 Media Server (`media-server/`)
- **VPN-wrapped torrenting** (Tailscale/WireGuard/commercial)
- **Automated downloads** (Radarr, Sonarr, Lidarr, Prowlarr)
- **Media streaming** (Jellyfin/Plex with Overseerr)
- **Reverse proxy** (Nginx Proxy Manager, Caddy, Traefik)
- **Privacy tools** (DNSCrypt, Privoxy, ProxyChains)
- **Monitoring** (Tautulli, Grafana, stats)

### 📚 Resources (`resources/`)
- **One-click setup scripts** (browsers, VPN, torrent clients)
- **Bazzite/Linux gaming resources** (guides, links, tools)
- **RSS feeds** (gaming news, Bazzite updates)
- **Community links** (Discord, forums, documentation)
- **Download mirrors** (ISOs, tools, configurations)

---

## 🚀 Quick Start

### Game Library Management

```bash
# Set up shared game library (dual-boot)
cd ~/kenl/modules/KENL6-library/game-library
./setup-shared-library.sh

# Sync save games between Linux and Windows
./sync-saves.sh

# Migrate game from Windows to Linux
./migrate-game.sh "Elden Ring"
```

### Media Server Setup

```bash
# Deploy full media server stack (Podman/Docker)
cd ~/kenl/modules/KENL6-library/media-server/docker-compose
docker-compose up -d

# Or use individual services
cd ~/kenl/modules/KENL6-library/media-server
./deploy-jellyfin.sh
./deploy-radarr.sh
./deploy-qbittorrent-vpn.sh
```

### Resource Scripts

```bash
# Install Floorp browser (one-click)
cd ~/kenl/modules/KENL6-library/resources/downloads
./floorp-browser.sh

# Setup RSS feeds for gaming news
cd ~/kenl/modules/KENL6-library/resources/rss-feeds
./setup-rss.sh

# Install Proton VPN
cd ~/kenl/modules/KENL6-library/resources/downloads
./proton-setup.sh
```

---

## 🎯 Use Cases

### Dual-Boot Storage Optimization

**Problem:** Games installed twice waste storage
- Linux: Elden Ring 60GB
- Windows: Elden Ring 60GB
- **Total waste:** 120GB

**Solution:** Shared NTFS partition
- Shared: Elden Ring 60GB
- **Saved:** 60GB per game

**Implementation:**
```bash
cd ~/kenl/modules/KENL6-library/game-library
./setup-shared-library.sh
# Creates: /mnt/games-universal (NTFS, both OSes)
```

### Automated Media Pipeline

**Traditional:** 10-30 minutes per episode/movie  
**KENL6:** 30 seconds to request, fully automated

**Flow:**
1. Request in Overseerr web UI
2. Prowlarr searches indexers
3. Radarr/Sonarr finds best release
4. qBittorrent downloads via VPN
5. Auto-rename and organize
6. Jellyfin/Plex auto-scans library
7. **Done!** Watch anywhere

### Quick Tool Installation

```bash
# Instead of manual downloads and configuration
cd ~/kenl/modules/KENL6-library/resources/downloads

./floorp-browser.sh      # Firefox fork
./discord-clients.sh     # Vesktop, ArmCord
./torrent-clients.sh     # qBittorrent, Deluge
./bootable-usb.sh        # Ventoy, Etcher
```

---

## 📋 Module Dependencies

**Game Library depends on:**
- KENL2-gaming (Play Cards integration)
- KENL5-system-tools/security (encrypted cloud backups)
- External: Steam, Proton, Wine

**Media Server depends on:**
- Podman or Docker (containerization)
- VPN provider (commercial or self-hosted)
- Storage (network or local)

**Resources depends on:**
- Internet connection (downloads)
- Package managers (flatpak, apt, dnf)

---

## 🔒 User-Space & Container Design

**All services run in containers (Podman/Docker):**
- ✅ No system modifications required
- ✅ Respects Bazzite immutable design
- ✅ Easy rollback (stop/remove containers)
- ✅ Isolated from host system

**Game library operates in user-space:**
- ✅ Mount points in `/mnt/` (user-accessible)
- ✅ Configs in `~/.config/` and `~/.local/`
- ❌ No system-level modifications

**Resources are user-installed:**
- ✅ Flatpak (user-space applications)
- ✅ AppImage (portable, no install)
- ✅ Distrobox (isolated containers)

---

## 📖 Documentation

### Game Library
- [setup-shared-library.sh](./game-library/setup-shared-library.sh) - Dual-boot setup
- [sync-saves.sh](./game-library/sync-saves.sh) - Save game sync
- [README.md](./game-library/README.md) - Full documentation

### Media Server
- [docker-compose/](./media-server/docker-compose/) - Full stack deployment
- [deploy-jellyfin.sh](./media-server/deploy-jellyfin.sh) - Jellyfin setup
- [README.md](./media-server/README.md) - Architecture and guides

### Resources
- [downloads/](./resources/downloads/) - One-click install scripts
- [rss-feeds/](./resources/rss-feeds/) - Gaming news feeds
- [README.md](./resources/README.md) - Resource catalog

---

## 🔄 Migration from Old Modules

**This module consolidates:**
- `KENL9-library/` → `KENL6-library/game-library/`
- `KENL11-media/` → `KENL6-library/media-server/`
- `KENL12-resources/` → `KENL6-library/resources/`

**Old module directories remain for backward compatibility but will be removed in v3.0.0.**

**Update your scripts:**
```bash
# Old paths
~/kenl/modules/KENL9-library/setup-shared-library.sh
~/kenl/modules/KENL11-media/docker-compose/
~/kenl/modules/KENL12-resources/downloads/

# New paths
~/kenl/modules/KENL6-library/game-library/setup-shared-library.sh
~/kenl/modules/KENL6-library/media-server/docker-compose/
~/kenl/modules/KENL6-library/resources/downloads/
```

---

## 🏷️ ATOM Integration

All KENL6 operations log to the ATOM trail:

```bash
# Game library operations
ATOM-LIBRARY-20251205-001: Shared library mounted at /mnt/games-universal
ATOM-LIBRARY-20251205-002: Save game synced for 'Elden Ring'

# Media server operations
ATOM-MEDIA-20251205-003: Jellyfin container started
ATOM-MEDIA-20251205-004: VPN connection established

# Resource installations
ATOM-INSTALL-20251205-005: Floorp browser installed via Flatpak
```

**Query ATOM trail:**
```bash
sqlite3 ~/.kenl/db/atom-trails.db "SELECT * FROM trail WHERE type='LIBRARY' OR type='MEDIA' ORDER BY created_at DESC LIMIT 10"
```

---

## 🔧 Configuration

### Game Library
Edit `~/.kenl/configs/game-library.conf`:
```bash
SHARED_LIBRARY_PATH="/mnt/games-universal"
AUTO_SYNC_SAVES=true
SYNC_INTERVAL="daily"
CLOUD_BACKUP_ENABLED=true
```

### Media Server
Edit `~/.kenl/configs/media-server.conf`:
```bash
JELLYFIN_PORT=8096
RADARR_PORT=7878
SONARR_PORT=8989
VPN_PROVIDER="mullvad"
DOWNLOAD_PATH="/mnt/media/downloads"
LIBRARY_PATH="/mnt/media/library"
```

### Resources
Edit `~/.kenl/configs/resources.conf`:
```bash
RSS_FEED_READER="newsboat"
AUTO_UPDATE_FEEDS=true
PREFERRED_BROWSER="floorp"
```

---

## 🚨 Rollback Instructions

**If KENL6 changes cause issues:**

```bash
# Stop all media server containers
cd ~/kenl/modules/KENL6-library/media-server/docker-compose
docker-compose down

# Unmount shared game library
sudo umount /mnt/games-universal

# Restore default configs
rm ~/.kenl/configs/game-library.conf
rm ~/.kenl/configs/media-server.conf
rm ~/.kenl/configs/resources.conf
```

**Remove installed applications:**
```bash
# Uninstall Flatpak apps
flatpak uninstall io.gitlab.librewolf-community
flatpak uninstall com.discordapp.Discord

# Remove containers
docker system prune -a
```

---

## 📊 Module Status

| Component | Status | Files | Last Update |
|-----------|--------|-------|-------------|
| Game Library | ✅ Production | 2 | 2025-12-05 |
| Media Server | ✅ Production | 3 | 2025-12-05 |
| Resources | ✅ Production | 8 | 2025-12-05 |

**Version:** 2.0.0 (Consolidated from KENL9, KENL11, KENL12)  
**ATOM:** ATOM-DOC-20251205-004  
**Last Updated:** 2025-12-05
