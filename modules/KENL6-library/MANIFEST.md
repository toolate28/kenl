---
title: KENL6 Library - File Manifest
version: 2.0.0
atom: ATOM-DOC-20251205-005
classification: MANIFEST
---

# KENL6 Library Manifest

**Module:** KENL6-library  
**Total Files:** 13  
**Last Updated:** 2025-12-05

---

## Directory Structure

```
KENL6-library/
├── README.md                      # Main module documentation
├── MANIFEST.md                    # This file
├── game-library/                  # Game library management
│   ├── MANIFEST.md
│   └── README.md
├── media-server/                  # Automated media server
│   ├── MANIFEST.md
│   ├── README.md
│   └── docker-compose/
└── resources/                     # Community resources & tools
    ├── MANIFEST.md
    ├── README.md
    ├── downloads/
    └── rss-feeds/
```

---

## Component Breakdown

### Game Library (2 files)
- **README.md** - Game library documentation
- **MANIFEST.md** - File inventory

### Media Server (3 files + docker-compose)
- **README.md** - Media server documentation
- **MANIFEST.md** - File inventory
- **docker-compose/** - Full stack deployment configs

### Resources (8 files)
- **README.md** - Resources documentation
- **MANIFEST.md** - File inventory
- **downloads/** - One-click install scripts
- **rss-feeds/** - Gaming news RSS feeds

---

## Migration History

**Consolidated from:**
- `modules/KENL9-library/` (2 files)
- `modules/KENL11-media/` (3 files)
- `modules/KENL12-resources/` (8 files)

**Rationale:** All content/resource management (games, media, community resources) belongs together as they share common patterns for storage optimization and content delivery.

---

## Dependencies

**Internal:**
- KENL2-gaming (Play Card integration)
- KENL5-system-tools/security (encrypted backups)
- KENL5-system-tools/backup (snapshot support)

**External:**
- Steam, Proton, Wine (gaming)
- Podman/Docker (media server containers)
- VPN provider (media privacy)
- Flatpak (application installation)

---

## File Purpose Summary

| File/Directory | Purpose | User-Facing |
|----------------|---------|-------------|
| `README.md` | Main module documentation | Yes |
| `MANIFEST.md` | File inventory (this file) | No |
| `game-library/` | Dual-boot game storage optimization | Yes |
| `media-server/` | Automated media acquisition & streaming | Yes |
| `resources/` | Quick install scripts & community links | Yes |

---

## Validation

**Check file count:**
```bash
find . -type f | wc -l  # Should be 13
```

**Verify structure:**
```bash
ls -la game-library/ media-server/ resources/
```

---

**ATOM:** ATOM-DOC-20251205-005  
**Version:** 2.0.0  
**Last Updated:** 2025-12-05
