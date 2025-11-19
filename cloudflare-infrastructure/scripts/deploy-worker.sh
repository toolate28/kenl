#!/bin/bash
# Deploy individual Cloudflare Worker
# ATOM: ATOM-SCRIPT-20251116-006
# Usage: ./deploy-worker.sh <worker-name> [--production]

set -euo pipefail

WORKER="${1:-}"
ENV="${2:---dev}"

if [[ -z "$WORKER" ]]; then
    echo "❌ Usage: $0 <worker-name> [--production]"
    echo "   Example: $0 api-atom --dev"
    echo "   Example: $0 api-atom --production"
    exit 1
fi

WORKER_DIR="workers/$WORKER"

if [[ ! -d "$WORKER_DIR" ]]; then
    echo "❌ Worker not found: $WORKER_DIR"
    echo "   Available workers:"
    ls -1 workers/ 2>/dev/null || echo "   (none)"
    exit 1
fi

cd "$WORKER_DIR"

echo "🚀 Deploying worker: $WORKER"

# Validate wrangler.toml exists
if [[ ! -f "wrangler.toml" ]]; then
    echo "❌ wrangler.toml not found in $WORKER_DIR"
    exit 1
fi

# Run tests if they exist
if [[ -f "package.json" ]] && grep -q "\"test\"" package.json; then
    echo "🧪 Running tests..."
    npm test || {
        echo "❌ Tests failed. Aborting deployment."
        exit 1
    }
fi

# Deploy based on environment
if [[ "$ENV" == "--production" ]]; then
    echo "☁️  Deploying to PRODUCTION..."
    read -p "⚠️  Deploy to production? (yes/no): " CONFIRM
    if [[ "$CONFIRM" != "yes" ]]; then
        echo "❌ Deployment cancelled"
        exit 1
    fi
    wrangler deploy
else
    echo "🔧 Deploying to DEV..."
    wrangler deploy --env dev
fi

echo "✅ Worker deployed: $WORKER"
