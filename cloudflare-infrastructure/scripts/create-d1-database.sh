#!/bin/bash
# Create Cloudflare D1 database
# ATOM: ATOM-SCRIPT-20251116-001
# Usage: ./create-d1-database.sh <database-name>

set -euo pipefail

DB_NAME="${1:-}"

if [[ -z "$DB_NAME" ]]; then
    echo "❌ Usage: $0 <database-name>"
    echo "   Example: $0 kenl-atom-trails"
    exit 1
fi

echo "🗄️  Creating D1 database: $DB_NAME"

# Check if wrangler is installed
if ! command -v wrangler &> /dev/null; then
    echo "❌ wrangler CLI not found. Install with: npm install -g wrangler"
    exit 1
fi

# Create database
if wrangler d1 create "$DB_NAME"; then
    echo "✅ Database created: $DB_NAME"
    echo ""
    echo "📋 Next steps:"
    echo "   1. Copy the database_id from output above"
    echo "   2. Add to wrangler.toml:"
    echo "      [[d1_databases]]"
    echo "      binding = \"DB\""
    echo "      database_name = \"$DB_NAME\""
    echo "      database_id = \"<paste-id-here>\""
    echo ""
    echo "   3. Apply schema:"
    echo "      ./scripts/apply-schema.sh $DB_NAME schemas/atom_trails.sql"
else
    echo "❌ Failed to create database"
    exit 1
fi
