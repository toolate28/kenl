#!/bin/bash
# Backup local ATOM database to R2
# ATOM: ATOM-SCRIPT-20251116-008
# Usage: ./backup-to-r2.sh [bucket-name]

set -euo pipefail

BUCKET="${1:-kenl-atom-archives}"
LOCAL_DB="$HOME/.kenl/db/atom-trails.db"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_NAME="atom-trails-backup-$TIMESTAMP.db"

if [[ ! -f "$LOCAL_DB" ]]; then
    echo "❌ Local ATOM database not found: $LOCAL_DB"
    exit 1
fi

echo "💾 Backing up ATOM database to R2..."

# Create temporary backup with compression
TMP_DIR=$(mktemp -d)
TMP_BACKUP="$TMP_DIR/$BACKUP_NAME"

echo "📦 Creating backup..."
cp "$LOCAL_DB" "$TMP_BACKUP"

# Compress
echo "🗜️  Compressing..."
gzip "$TMP_BACKUP"
COMPRESSED="$TMP_BACKUP.gz"

# Upload to R2 with date-based prefix
R2_PATH="backups/$(date +%Y/%m)/$BACKUP_NAME.gz"

echo "☁️  Uploading to R2: $R2_PATH"
if wrangler r2 object put "$BUCKET/$R2_PATH" --file="$COMPRESSED"; then
    echo "✅ Backup uploaded successfully"

    # Show file size
    SIZE=$(du -h "$COMPRESSED" | cut -f1)
    echo "📊 Backup size: $SIZE"

    # Cleanup
    rm -rf "$TMP_DIR"

    echo "📋 Restore command:"
    echo "   wrangler r2 object get $BUCKET/$R2_PATH --file=atom-trails-restore.db.gz"
    echo "   gunzip atom-trails-restore.db.gz"
else
    echo "❌ Failed to upload backup"
    rm -rf "$TMP_DIR"
    exit 1
fi

echo "✅ Backup complete"
