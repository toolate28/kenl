#!/bin/bash
# Apply SQL schema to D1 database
# ATOM: ATOM-SCRIPT-20251116-002
# Usage: ./apply-schema.sh <database-name> <schema-file>

set -euo pipefail

DB_NAME="${1:-}"
SCHEMA_FILE="${2:-}"

if [[ -z "$DB_NAME" ]] || [[ -z "$SCHEMA_FILE" ]]; then
    echo "❌ Usage: $0 <database-name> <schema-file>"
    echo "   Example: $0 kenl-atom-trails schemas/atom_trails.sql"
    exit 1
fi

if [[ ! -f "$SCHEMA_FILE" ]]; then
    echo "❌ Schema file not found: $SCHEMA_FILE"
    exit 1
fi

echo "📋 Applying schema to $DB_NAME: $(basename $SCHEMA_FILE)"

# Apply schema to production
if wrangler d1 execute "$DB_NAME" --file="$SCHEMA_FILE"; then
    echo "✅ Schema applied to production"
else
    echo "❌ Failed to apply schema"
    exit 1
fi

# Verify tables were created
echo ""
echo "🔍 Verifying tables..."
wrangler d1 execute "$DB_NAME" --command="SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;"

echo "✅ Schema application complete"
