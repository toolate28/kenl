#!/bin/bash
# Sync local ATOM SQLite database to Cloudflare D1
# ATOM: ATOM-SCRIPT-20251116-003
# Usage: ./sync-atom-to-d1.sh [--recent-only]

set -euo pipefail

DB_NAME="kenl-atom-trails"
LOCAL_DB="$HOME/.kenl/db/atom-trails.db"
RECENT_ONLY="${1:-}"

if [[ ! -f "$LOCAL_DB" ]]; then
    echo "❌ Local ATOM database not found: $LOCAL_DB"
    exit 1
fi

echo "🔄 Syncing ATOM trails to D1..."

# Export recent entries (last 100) or all
if [[ "$RECENT_ONLY" == "--recent-only" ]]; then
    echo "📋 Exporting recent entries (last 100)..."
    QUERY="SELECT * FROM atom_trails ORDER BY timestamp DESC LIMIT 100;"
else
    echo "📋 Exporting all entries..."
    QUERY="SELECT * FROM atom_trails;"
fi

# Export to JSON
TMP_FILE=$(mktemp)
sqlite3 "$LOCAL_DB" <<EOF | jq -c > "$TMP_FILE"
.mode json
$QUERY
EOF

# Count entries
ENTRY_COUNT=$(wc -l < "$TMP_FILE")
echo "📊 Found $ENTRY_COUNT entries to sync"

if [[ $ENTRY_COUNT -eq 0 ]]; then
    echo "⚠️  No entries to sync"
    rm "$TMP_FILE"
    exit 0
fi

# Create SQL INSERT statements (batch by 100 for efficiency)
SQL_FILE=$(mktemp)
echo "BEGIN TRANSACTION;" > "$SQL_FILE"

jq -r 'to_entries[] | .value |
    "INSERT OR REPLACE INTO atom_trails (
        tag, type, date, sequence, timestamp, user, hostname, git_commit,
        description, command, file_path, changes,
        validation_status, safety_score, safety_flags, approved_by, approved_at,
        exit_code, stdout, stderr, duration_ms,
        rollback_command, rollback_successful, rolled_back_at,
        signature, previous_hash, hash
    ) VALUES (
        '\''\(.tag)'\'', '\''\(.type)'\'', '\''\(.date)'\'', \(.sequence),
        '\''\(.timestamp)'\'', '\''\(.user)'\'', '\''\(.hostname)'\'', '\''\(.git_commit // "")'\'',
        '\''\(.description)'\'', '\''\(.command // "")'\'', '\''\(.file_path // "")'\'', '\''\(.changes // "")'\'',
        '\''\(.validation_status)'\'', \(.safety_score // "NULL"), '\''\(.safety_flags // "")'\'',
        '\''\(.approved_by // "")'\'', '\''\(.approved_at // "")'\'',
        \(.exit_code // "NULL"), '\''\(.stdout // "")'\'', '\''\(.stderr // "")'\'', \(.duration_ms // "NULL"),
        '\''\(.rollback_command // "")'\'', \(.rollback_successful // "NULL"), '\''\(.rolled_back_at // "")'\'',
        '\''\(.signature // "")'\'', '\''\(.previous_hash // "")'\'', '\''\(.hash)'\''
    );"' "$TMP_FILE" >> "$SQL_FILE"

echo "COMMIT;" >> "$SQL_FILE"

# Upload to D1
echo "☁️  Uploading to D1..."
if wrangler d1 execute "$DB_NAME" --file="$SQL_FILE"; then
    echo "✅ Synced $ENTRY_COUNT ATOM trail entries to D1"
else
    echo "❌ Failed to sync to D1"
    rm "$TMP_FILE" "$SQL_FILE"
    exit 1
fi

# Cleanup
rm "$TMP_FILE" "$SQL_FILE"

echo "✅ Sync complete"
