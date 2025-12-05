#!/bin/bash
# Create Cloudflare KV namespace
# ATOM: ATOM-SCRIPT-20251116-004
# Usage: ./create-kv-namespace.sh <namespace-name> [--preview]

set -euo pipefail

NAMESPACE="${1:-}"
PREVIEW="${2:-}"

if [[ -z "$NAMESPACE" ]]; then
    echo "❌ Usage: $0 <namespace-name> [--preview]"
    echo "   Example: $0 sessions"
    echo "   Example: $0 sessions --preview  (create preview namespace)"
    exit 1
fi

echo "🗂️  Creating KV namespace: $NAMESPACE"

# Create production namespace
if wrangler kv:namespace create "$NAMESPACE"; then
    echo "✅ Production namespace created: $NAMESPACE"
else
    echo "❌ Failed to create production namespace"
    exit 1
fi

# Create preview namespace if requested
if [[ "$PREVIEW" == "--preview" ]]; then
    echo ""
    echo "🔍 Creating preview namespace..."
    if wrangler kv:namespace create "$NAMESPACE" --preview; then
        echo "✅ Preview namespace created: ${NAMESPACE}_preview"
    else
        echo "❌ Failed to create preview namespace"
        exit 1
    fi
fi

echo ""
echo "📋 Next steps:"
echo "   1. Copy the namespace ID(s) from output above"
echo "   2. Add to wrangler.toml:"
echo "      kv_namespaces = ["
echo "        { binding = \"$(echo $NAMESPACE | tr '[:lower:]' '[:upper:]')\", id = \"<paste-id-here>\" }"
echo "      ]"

echo "✅ KV namespace creation complete"
