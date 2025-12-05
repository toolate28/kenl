---
title: KENL5 System Tools - File Manifest
version: 2.0.0
atom: ATOM-DOC-20251205-003
classification: MANIFEST
---

# KENL5 System Tools Manifest

**Module:** KENL5-system-tools  
**Total Files:** 63  
**Last Updated:** 2025-12-05

---

## Directory Structure

```
KENL5-system-tools/
├── README.md                   # Main module documentation
├── MANIFEST.md                 # This file
├── backup/                     # Backup & snapshot utilities
│   ├── MANIFEST.md
│   ├── README.md
│   └── atom-snapshot.sh
├── security/                   # Security & encryption tools
│   ├── MANIFEST.md
│   ├── README.md
│   └── gpg-keyring/
└── theming/                    # Visual customization & context switching
    ├── MANIFEST.md
    ├── README.md
    ├── banners/
    ├── cheatsheets/
    ├── prompts/
    ├── show-cheatsheet.sh
    └── switch-kenl.sh
```

---

## Component Breakdown

### Backup (3 files)
- **atom-snapshot.sh** - ATOM-aware backup script
- **README.md** - Backup documentation
- **MANIFEST.md** - File inventory

### Security (3 files + gpg-keyring)
- **README.md** - Security documentation
- **MANIFEST.md** - File inventory
- **gpg-keyring/** - GPG key management

### Theming (57 files)
- **switch-kenl.sh** - Context switcher
- **show-cheatsheet.sh** - Quick reference display
- **README.md** - Theming documentation
- **MANIFEST.md** - File inventory
- **banners/** - ASCII art banners for each module
- **cheatsheets/** - Quick reference cards
- **prompts/** - Shell prompt configurations

---

## Migration History

**Consolidated from:**
- `modules/KENL10-backup/` (3 files)
- `modules/KENL5-facades/` (57 files)
- `modules/KENL8-security/` (3 files)

**Rationale:** System-level utilities (backup, security, theming) belong together as they all operate in user-space and share common patterns.

---

## Dependencies

**Internal:**
- KENL1-framework (ATOM trail, OWI metadata)
- KENL2-gaming (Play Card backups)
- KENL3-dev (development environment themes)

**External:**
- GPG (user-space keyring)
- Bash/Zsh (shell customization)
- Optional: HashiCorp Vault, cloud storage providers

---

## File Purpose Summary

| File/Directory | Purpose | User-Facing |
|----------------|---------|-------------|
| `README.md` | Main module documentation | Yes |
| `MANIFEST.md` | File inventory (this file) | No |
| `backup/` | Snapshot and recovery utilities | Yes |
| `security/` | Encryption and key management | Yes |
| `theming/` | Visual customization | Yes |

---

## Validation

**Check file count:**
```bash
find . -type f | wc -l  # Should be 63
```

**Verify structure:**
```bash
ls -la backup/ security/ theming/
```

---

**ATOM:** ATOM-DOC-20251205-003  
**Version:** 2.0.0  
**Last Updated:** 2025-12-05
