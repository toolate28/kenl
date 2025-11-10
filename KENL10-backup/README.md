# KENL10: Intelligent Backup & Sync

**Icon:** 💾 | **Color:** Brown/Gold | **Status:** Beta

ATOM-aware backups that understand intent, not just files.

## Quick Start

```bash
# Create snapshot
cd ~/kenl/KENL10-backup
./atom-snapshot.sh create before-update "Before system update"

# List snapshots
./atom-snapshot.sh list

# Restore
./atom-snapshot.sh restore before-update

# Switch to backup context
cd ~/kenl/KENL5-facades
./switch-kenl.sh backup
```

## Features

- 📸 ATOM-aware snapshots (full context)
- 🎮 Play Card versioning
- ☁️ Cloud sync (S3, B2, Nextcloud)
- 🔄 Deduplication
- 🔐 Encrypted backups (via KENL8)
- 🚨 Disaster recovery from ATOM trail

## What Gets Backed Up

- ATOM trail (complete audit history)
- Play Cards (gaming configs)
- KENL configurations
- System state (rpm-ostree status)
- User configs (.bashrc, .kenl_profile)

**Restore from snapshot = restore complete context!**
