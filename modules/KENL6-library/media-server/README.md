# Media Server Resources

**Status:** External Reference Guide  
**Platform:** Bazzite (Fedora Atomic)

---

## Overview

Setting up a media server (Jellyfin, Plex, Radarr, Sonarr) is **beyond KENL's scope**. This is a reference guide pointing to quality external resources.

**Why not included:** Media server automation is a separate project with its own complexity, storage requirements, and community (r/selfhosted). KENL focuses on gaming + development.

---

## Quick Links

### Media Servers (Pick One)
- **Jellyfin** (Free, open-source) → https://jellyfin.org/
- **Plex** (Freemium, easier setup) → https://www.plex.tv/

### Setup Guides
- **r/selfhosted Wiki** → https://www.reddit.com/r/selfhosted/wiki/
- **Jellyfin Docs** → https://jellyfin.org/docs/
- **TRaSH Guides** (Radarr/Sonarr) → https://trash-guides.info/

### Container Images
- **Jellyfin Official** → https://jellyfin.org/docs/general/installation/container
- **LinuxServer.io** → https://fleet.linuxserver.io/

---

## Bazzite Considerations

**Use Podman/Docker** (immutable OS requirement):
```bash
# Example: Jellyfin via Podman
podman run -d \
  --name jellyfin \
  -p 8096:8096 \
  -v /home/user/media:/media:ro \
  -v /home/user/jellyfin-config:/config \
  docker.io/jellyfin/jellyfin:latest
```

**Storage:**
- ✅ Store media in `/mnt/` or `/home/` (persistent across updates)
- ❌ Don't use `/usr/` or `/opt/` (immutable base layer)

---

## Why External Resources?

1. **Scope:** Media servers are a full project, not a gaming feature
2. **Expertise:** r/selfhosted community has 10+ years of refined guides
3. **Maintenance:** Media server software changes rapidly
4. **Legal:** Torrenting automation involves legal/privacy considerations

**KENL's job:** Gaming optimization, not media center management.

---

## Related KENL Modules

- **KENL6-library/game-library/** - Game storage optimization (dual-boot)
- **KENL6-library/resources/** - Download tools and utilities
- **KENL5-system-tools/backup/** - Backup your media library

---

**Last Updated:** 2025-12-05
