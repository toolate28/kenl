#!/bin/bash
# Create Cloudflare R2 bucket
# ATOM: ATOM-SCRIPT-20251116-005
# Usage: ./create-r2-bucket.sh <bucket-name> [--public]

set -euo pipefail

BUCKET="${1:-}"
PUBLIC="${2:-}"

if [[ -z "$BUCKET" ]]; then
    echo "❌ Usage: $0 <bucket-name> [--public]"
    echo "   Example: $0 kenl-atom-archives"
    echo "   Example: $0 playcard-repo --public"
    exit 1
fi

echo "🪣 Creating R2 bucket: $BUCKET"

# Create bucket
if wrangler r2 bucket create "$BUCKET"; then
    echo "✅ Bucket created: $BUCKET"
else
    echo "❌ Failed to create bucket"
    exit 1
fi

# Configure public access if requested
if [[ "$PUBLIC" == "--public" ]]; then
    echo ""
    echo "🌐 Configuring public access..."
    echo "⚠️  Note: Public R2 buckets require custom domain setup"
    echo "   Visit: https://dash.cloudflare.com → R2 → $BUCKET → Settings"
fi

echo ""
echo "📋 Next steps:"
echo "   1. Add to wrangler.toml:"
echo "      [[r2_buckets]]"
echo "      binding = \"$(echo $BUCKET | tr '[:lower:]' '[:upper:]' | tr '-' '_')\""
echo "      bucket_name = \"$BUCKET\""
echo ""
echo "   2. Configure lifecycle rules (optional):"
echo "      - Delete objects after N days"
echo "      - Transition to Glacier storage"

echo "✅ R2 bucket creation complete"
