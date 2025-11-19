#!/bin/bash
# Validate wrangler.toml configuration
# ATOM: ATOM-SCRIPT-20251116-007
# Usage: ./validate-config.sh <wrangler.toml>

set -euo pipefail

CONFIG="${1:-wrangler.toml}"

if [[ ! -f "$CONFIG" ]]; then
    echo "❌ Configuration file not found: $CONFIG"
    exit 1
fi

echo "🔍 Validating configuration: $CONFIG"

ERRORS=0

# Check required fields
echo "📋 Checking required fields..."

if ! grep -q "^name = " "$CONFIG"; then
    echo "❌ Missing required field: name"
    ((ERRORS++))
fi

if ! grep -q "^compatibility_date = " "$CONFIG"; then
    echo "❌ Missing required field: compatibility_date"
    ((ERRORS++))
fi

# Check for common issues
echo "🔍 Checking for common issues..."

# Check for outdated compatibility date
COMPAT_DATE=$(grep "^compatibility_date = " "$CONFIG" | cut -d'"' -f2)
CURRENT_YEAR=$(date +%Y)
if [[ ! "$COMPAT_DATE" =~ ^$CURRENT_YEAR ]]; then
    echo "⚠️  Warning: compatibility_date may be outdated: $COMPAT_DATE"
fi

# Validate D1 database bindings
if grep -q "d1_databases" "$CONFIG"; then
    echo "✅ D1 databases configured"
    # Check if database_id is a placeholder
    if grep -q "database_id = \"<" "$CONFIG"; then
        echo "❌ D1 database_id contains placeholder value"
        ((ERRORS++))
    fi
fi

# Validate KV namespace bindings
if grep -q "kv_namespaces" "$CONFIG"; then
    echo "✅ KV namespaces configured"
    # Check if id is a placeholder
    if grep -q "id = \"<" "$CONFIG"; then
        echo "❌ KV namespace id contains placeholder value"
        ((ERRORS++))
    fi
fi

# Validate R2 bucket bindings
if grep -q "r2_buckets" "$CONFIG"; then
    echo "✅ R2 buckets configured"
fi

# Check for secrets
if grep -q "vars = " "$CONFIG"; then
    echo "⚠️  Warning: Using vars for configuration. Ensure secrets use wrangler secret put"
fi

# Summary
echo ""
if [[ $ERRORS -eq 0 ]]; then
    echo "✅ Configuration validation passed"
    exit 0
else
    echo "❌ Configuration validation failed with $ERRORS error(s)"
    exit 1
fi
