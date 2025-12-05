---
title: KENL5 System Tools - Backup, Security & Theming
version: 2.0.0
atom: ATOM-DOC-20251205-002
status: production
classification: MODULE-README
---

# KENL5: System Tools

**Icon:** 🛠️ | **Color:** Gold | **Status:** Production

Unified system utilities for backup, security, and visual customization. All tools are **user-space only** and respect immutable OS constraints (Bazzite/Fedora Atomic).

---

## 📦 What's Included

### 🛡️ Backup (`backup/`)
- **ATOM-aware snapshots** with full context preservation
- **Play Card versioning** for gaming configurations
- **Cloud sync** (S3, B2, Nextcloud, Cloudflare R2)
- **Disaster recovery** from ATOM trail
- **Deduplication** and compression

### 🔐 Security (`security/`)
- **GPG key management** and encryption
- **File encryption/decryption** for sensitive data
- **Digital signatures** for verification
- **Vault integration** (HashiCorp Vault support)
- **Secret rotation** automation
- **TOTP 2FA** management

### 🎨 Theming (`theming/`)
- **Context-aware shell prompts** with unique icons/colors
- **Terminal themes** optimized per KENL module
- **Easy context switching** between modules
- **Profile configurations** with environment variables
- **Visual identity** for each module

---

## 🚀 Quick Start

### Backup Operations

```bash
# Create snapshot before system changes
cd ~/kenl/modules/KENL5-system-tools/backup
./atom-snapshot.sh create pre-update "Before system update"

# List all snapshots
./atom-snapshot.sh list

# Restore from snapshot
./atom-snapshot.sh restore pre-update
```

### Security Operations

```bash
# Encrypt sensitive file
cd ~/kenl/modules/KENL5-system-tools/security/gpg-keyring
./encrypt-file.sh encrypt my-passwords.txt

# Export public key for sharing
./encrypt-file.sh export-key

# Verify file signature
./encrypt-file.sh verify signed-file.txt.sig
```

### Theming & Context Switching

```bash
# Switch to gaming context
cd ~/kenl/modules/KENL5-system-tools/theming
./switch-kenl.sh gaming

# Switch to development context
./switch-kenl.sh dev

# Show available contexts
./switch-kenl.sh list
```

---

## 📋 Module Dependencies

**Backup depends on:**
- KENL1-framework (ATOM trail access)
- KENL5-security (encrypted backups)

**Security depends on:**
- GPG (user-space keyring)
- Optional: HashiCorp Vault (external)

**Theming depends on:**
- Bash/Zsh (shell customization)
- Terminal emulator (colors, fonts)

---

## 🎯 Use Cases

### Daily Backup Workflow
1. Morning: Verify yesterday's backup status
2. Before changes: Create snapshot with context
3. After testing: Commit changes or restore
4. Evening: Cloud sync to remote storage

### Security Best Practices
1. **Sensitive configs:** Encrypt before committing
2. **Play Cards:** Sign before sharing publicly
3. **API keys:** Store in encrypted vault
4. **Backups:** Always encrypted before cloud upload

### Context Awareness
Each KENL module gets its own visual identity:
- 🎮 KENL2 Gaming (Red) - Clear visual cue
- 💻 KENL3 Development (Blue) - No confusion
- 📊 KENL4 Monitoring (Green) - Instant recognition

---

## 📊 What Gets Backed Up

```
~/.kenl/
├── db/atom-trails.db         # Full audit history
├── play-cards/               # Gaming configurations
├── profiles/                 # Shell profiles
└── configs/                  # Module configurations

~/.config/
└── bazza-dx/                 # System configurations

~/.local/share/
└── kenl/                     # Application data
```

**Excluded from backups:**
- Build artifacts (`node_modules/`, `target/`)
- Cache directories (`~/.cache/`)
- Temporary files (`/tmp/`)
- System files (not in user-space)

---

## 🔒 User-Space Only Guarantee

**All operations in KENL5 are user-space only:**

✅ **Safe Locations:**
- `~/.local/` - User applications and data
- `~/.config/` - User configurations
- `~/.kenl/` - KENL-specific data
- `~/.gnupg/` - GPG keyring (user-space)

❌ **NEVER Modified:**
- `/etc/` - System configuration
- `/usr/` - System binaries
- `/opt/` - Optional software
- rpm-ostree base layer

**Why:** Bazzite-DX is an immutable OS. System modifications require layering and break the atomic update model. KENL respects this design.

---

## 🔄 Migration from Old Modules

**This module consolidates:**
- `KENL10-backup/` → `KENL5-system-tools/backup/`
- `KENL5-facades/` → `KENL5-system-tools/theming/`
- `KENL8-security/` → `KENL5-system-tools/security/`

**Old module directories remain for backward compatibility but will be removed in v3.0.0.**

**Update your scripts:**
```bash
# Old path
~/kenl/modules/KENL10-backup/atom-snapshot.sh

# New path
~/kenl/modules/KENL5-system-tools/backup/atom-snapshot.sh
```

---

## 📖 Documentation

### Backup
- [atom-snapshot.sh](./backup/atom-snapshot.sh) - Main backup script
- [MANIFEST.md](./backup/MANIFEST.md) - File inventory

### Security
- [encrypt-file.sh](./security/gpg-keyring/encrypt-file.sh) - Encryption utilities
- [MANIFEST.md](./security/MANIFEST.md) - Security tools inventory

### Theming
- [switch-kenl.sh](./theming/switch-kenl.sh) - Context switcher
- [MANIFEST.md](./theming/MANIFEST.md) - Theme inventory
- [banners/](./theming/banners/) - ASCII art banners
- [prompts/](./theming/prompts/) - Shell prompt configurations

---

## 🏷️ ATOM Integration

All KENL5 operations log to the ATOM trail:

```bash
# Backup creates ATOM entry
ATOM-BACKUP-20251205-001: Snapshot 'pre-update' created

# Encryption logs key usage
ATOM-SECURITY-20251205-002: File 'passwords.txt' encrypted

# Context switching logs environment change
ATOM-CONFIG-20251205-003: Switched to gaming context
```

**Query ATOM trail:**
```bash
sqlite3 ~/.kenl/db/atom-trails.db "SELECT * FROM trail WHERE type='BACKUP' ORDER BY created_at DESC LIMIT 10"
```

---

## 🔧 Configuration

### Backup Configuration
Edit `~/.kenl/configs/backup.conf`:
```bash
BACKUP_LOCATION="$HOME/.kenl/backups"
CLOUD_SYNC_ENABLED=true
CLOUD_PROVIDER="cloudflare-r2"
ENCRYPTION_ENABLED=true
RETENTION_DAYS=90
```

### Security Configuration
Edit `~/.kenl/configs/security.conf`:
```bash
GPG_KEY_ID="your-key-id"
VAULT_ENABLED=false
VAULT_ADDRESS="http://localhost:8200"
TOTP_ENABLED=true
```

### Theming Configuration
Edit `~/.kenl/configs/theming.conf`:
```bash
DEFAULT_CONTEXT="system"
SHOW_CONTEXT_BANNER=true
PROMPT_STYLE="powerline"
COLOR_SCHEME="auto"  # auto, light, dark
```

---

## 🚨 Rollback Instructions

**If KENL5 changes break your system:**

```bash
# 1. Restore from last backup
cd ~/kenl/modules/KENL5-system-tools/backup
./atom-snapshot.sh list  # Find last good snapshot
./atom-snapshot.sh restore <snapshot-name>

# 2. OR reset to default theme
cd ~/kenl/modules/KENL5-system-tools/theming
./switch-kenl.sh reset

# 3. OR revert security changes
cd ~/kenl/modules/KENL5-system-tools/security
./encrypt-file.sh decrypt <file>  # Decrypt if needed
```

**Complete removal:**
```bash
# Remove KENL5 configurations (preserves backups)
rm -rf ~/.kenl/configs/backup.conf
rm -rf ~/.kenl/configs/security.conf
rm -rf ~/.kenl/configs/theming.conf

# Backups remain in ~/.kenl/backups/ for manual recovery
```

---

## 📊 Module Status

| Component | Status | Files | Last Update |
|-----------|--------|-------|-------------|
| Backup | ✅ Production | 3 | 2025-12-05 |
| Security | ✅ Production | 3 | 2025-12-05 |
| Theming | ✅ Production | 57 | 2025-12-05 |

**Version:** 2.0.0 (Consolidated from KENL5, KENL8, KENL10)  
**ATOM:** ATOM-DOC-20251205-002  
**Last Updated:** 2025-12-05
