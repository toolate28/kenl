---
project: KENL Cloudflare Deployment
atom: ATOM-SAIF-20251116-004
classification: SAIF-WORKFLOW
status: production-ready
version: 1.0.0
---

# SAIF Workflow: Deploy with Existing Cloudflare Account

**System-Aware Intent Framework for rapid deployment when you already have Cloudflare credentials**

## Purpose

Guided deployment from existing Cloudflare account to production in ~50 minutes with complete validation and ATOM logging.

## Philosophy

> "Capture every ID, validate every step, log every action" - Zero guesswork deployment.

## Prerequisites Check

Run this before starting:

```bash
# Check if you're in the right directory
pwd | grep cloudflare-infrastructure || echo "❌ Run: cd cloudflare-infrastructure"

# Check if wrangler is installed
command -v wrangler >/dev/null || echo "❌ Install: npm install -g wrangler"

# Check Node.js version
node --version | grep -E "v(18|19|20|21)" || echo "⚠️  Node.js 18+ recommended"
```

**Prerequisites Met?** Continue to Step 1.

---

## Step 1: Authenticate & Validate

### Intent
Establish authenticated connection to Cloudflare account and capture Account ID.

### Actions

```bash
# 1.1 Login to Cloudflare
wrangler login

# Browser will open for OAuth
# ✅ Click "Allow" when prompted

# 1.2 Verify authentication
wrangler whoami

# Expected output:
# ┌──────────────────────────────────────┐
# │ Account Name  │ Your Account         │
# │ Account ID    │ abc123def456...      │
# └──────────────────────────────────────┘
```

### Capture Output

**IMPORTANT**: Save your Account ID for later:

```bash
# Create capture file
echo "CLOUDFLARE_ACCOUNT_ID=$(wrangler whoami | grep 'Account ID' | awk '{print $3}')" > .env.deployment
cat .env.deployment
```

### Validation

```bash
# Verify .env.deployment was created
test -f .env.deployment && echo "✅ Account ID captured" || echo "❌ Run capture command again"
```

### Troubleshooting

| Issue | Solution |
|-------|----------|
| "Not logged in" | Run `wrangler login` again |
| Browser doesn't open | Use `wrangler login --browser=false` for manual URL |
| Permission denied | Check Cloudflare dashboard → API Tokens |

### ATOM Log

```bash
# Log authentication
echo "ATOM-CF-AUTH-$(date +%Y%m%d)-001: Authenticated with Cloudflare account" >> ~/.kenl/atom-trail.log
```

**Step 1 Complete?** ✅ Account ID saved in `.env.deployment`

---

## Step 2: Create D1 Database

### Intent
Create primary D1 database for ATOM trails with automatic ID capture.

### Actions

```bash
# 2.1 Create database
./scripts/create-d1-database.sh kenl-atom-trails

# Output will show:
# ✅ Database created: kenl-atom-trails
#    database_id = "abc123..."
```

### Capture Output

**CRITICAL**: Capture the database ID shown in output:

```bash
# The script will prompt you to save the ID
# When you see: "Enter database ID from output above:"
# Copy the database_id value and paste it

# Or capture automatically:
wrangler d1 list | grep kenl-atom-trails | awk '{print $2}' > .database-id.txt
echo "D1_DATABASE_ID=$(cat .database-id.txt)" >> .env.deployment
```

### Validation

```bash
# Verify database exists
wrangler d1 list | grep kenl-atom-trails && echo "✅ Database created" || echo "❌ Database not found"

# Verify ID captured
grep "D1_DATABASE_ID" .env.deployment && echo "✅ ID captured" || echo "❌ Run capture command"
```

### Rollback

```bash
# If you need to start over
wrangler d1 delete kenl-atom-trails --skip-confirmation
```

### ATOM Log

```bash
echo "ATOM-CF-D1-$(date +%Y%m%d)-001: Created D1 database kenl-atom-trails" >> ~/.kenl/atom-trail.log
```

**Step 2 Complete?** ✅ Database ID saved in `.env.deployment`

---

## Step 3: Apply Database Schemas

### Intent
Apply all 4 table schemas to D1 database with verification.

### Actions

```bash
# 3.1 Apply ATOM trails schema
./scripts/apply-schema.sh kenl-atom-trails schemas/atom_trails.sql

# 3.2 Apply Play Card rules schema
./scripts/apply-schema.sh kenl-atom-trails schemas/playcard_rules.sql

# 3.3 Apply users schema
./scripts/apply-schema.sh kenl-atom-trails schemas/users.sql

# 3.4 Apply sessions schema
./scripts/apply-schema.sh kenl-atom-trails schemas/sessions.sql
```

### Expected Output (for each)

```
✅ Schema applied to production

🔍 Verifying tables...
name
----
atom_trails
playcard_rules
users
sessions
```

### Validation

```bash
# Verify all 4 tables exist
wrangler d1 execute kenl-atom-trails \
  --command="SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;"

# Expected: 4 tables listed
# ✅ atom_trails
# ✅ playcard_validation_rules
# ✅ sessions
# ✅ users
```

### Rollback

```bash
# Drop all tables if needed
wrangler d1 execute kenl-atom-trails --command="
  DROP TABLE IF EXISTS atom_trails;
  DROP TABLE IF EXISTS playcard_validation_rules;
  DROP TABLE IF EXISTS users;
  DROP TABLE IF EXISTS sessions;
"

# Re-apply if needed (go back to 3.1)
```

### ATOM Log

```bash
echo "ATOM-CF-SCHEMA-$(date +%Y%m%d)-001: Applied 4 database schemas" >> ~/.kenl/atom-trail.log
```

**Step 3 Complete?** ✅ All 4 tables verified

---

## Step 4: Create KV Namespaces

### Intent
Create 3 KV namespaces for sessions, caching, and rate limiting with ID capture.

### Actions

```bash
# 4.1 Create sessions namespace
./scripts/create-kv-namespace.sh sessions --preview

# 4.2 Create cache namespace
./scripts/create-kv-namespace.sh cache --preview

# 4.3 Create rate-limits namespace
./scripts/create-kv-namespace.sh rate-limits --preview
```

### Capture Output

**For EACH namespace**, you'll see output like:

```
✅ Production namespace created: sessions
   id = "abc123..."

✅ Preview namespace created: sessions_preview
   id = "def456..."
```

**Capture all 3 production IDs**:

```bash
# Manual capture (recommended for accuracy)
cat > .kv-ids.txt <<EOF
SESSIONS_KV_ID=<paste-sessions-production-id>
CACHE_KV_ID=<paste-cache-production-id>
RATELIMIT_KV_ID=<paste-ratelimit-production-id>
EOF

# Append to deployment env
cat .kv-ids.txt >> .env.deployment
```

### Validation

```bash
# Verify all 3 namespaces exist
wrangler kv:namespace list | grep -E "(sessions|cache|rate-limits)" | wc -l

# Expected: 6 (3 production + 3 preview)
# ✅ Shows "6" = All created
# ❌ Shows less than 6 = Re-run failed creation
```

### Rollback

```bash
# Delete namespaces if needed
wrangler kv:namespace delete --binding sessions
wrangler kv:namespace delete --binding cache
wrangler kv:namespace delete --binding rate-limits
```

### ATOM Log

```bash
echo "ATOM-CF-KV-$(date +%Y%m%d)-001: Created 3 KV namespaces" >> ~/.kenl/atom-trail.log
```

**Step 4 Complete?** ✅ All 3 KV IDs saved in `.env.deployment`

---

## Step 5: Update Worker Configurations

### Intent
Replace placeholder values in wrangler.toml files with actual resource IDs.

### Actions

```bash
# 5.1 Load captured IDs
source .env.deployment

# 5.2 Update api-atom worker config
sed -i "s/<your-database-id>/$D1_DATABASE_ID/g" workers/api-atom/wrangler.toml
sed -i "s/<your-kv-id>/$SESSIONS_KV_ID/g" workers/api-atom/wrangler.toml

# 5.3 Update logging worker config
sed -i "s/<your-database-id>/$D1_DATABASE_ID/g" workers/logging/wrangler.toml

# 5.4 Verify no placeholders remain
grep -r "<your-" workers/*/wrangler.toml && echo "❌ Placeholders still exist" || echo "✅ All placeholders replaced"
```

### Validation

```bash
# Validate both worker configs
./scripts/validate-config.sh workers/api-atom/wrangler.toml
./scripts/validate-config.sh workers/logging/wrangler.toml

# Expected for both:
# ✅ Configuration validation passed
```

### Manual Verification

```bash
# Show updated configs to verify
echo "=== api-atom config ==="
grep -A5 "d1_databases" workers/api-atom/wrangler.toml

echo "=== logging config ==="
grep -A5 "d1_databases" workers/logging/wrangler.toml

# Verify database_id is NOT "<your-database-id>"
```

### Rollback

```bash
# Restore original configs from git
git checkout workers/api-atom/wrangler.toml
git checkout workers/logging/wrangler.toml

# Re-run Step 5 if needed
```

### ATOM Log

```bash
echo "ATOM-CF-CONFIG-$(date +%Y%m%d)-001: Updated worker configurations" >> ~/.kenl/atom-trail.log
```

**Step 5 Complete?** ✅ No placeholders in configs, validation passed

---

## Step 6: Deploy Workers to Production

### Intent
Deploy both workers to production with testing and verification.

### Actions

```bash
# 6.1 Deploy api-atom worker
./scripts/deploy-worker.sh api-atom --production

# Output shows:
# ✅ Worker deployed: api-atom
# URL: https://kenl-api-atom.<subdomain>.workers.dev

# 6.2 Deploy logging worker
./scripts/deploy-worker.sh logging --production

# Output shows:
# ✅ Worker deployed: logging
# URL: https://kenl-logging.<subdomain>.workers.dev
```

### Capture Output

```bash
# Save worker URLs
echo "API_ATOM_URL=$(wrangler deployments list kenl-api-atom | grep 'https://' | awk '{print $2}')" >> .env.deployment
echo "LOGGING_URL=$(wrangler deployments list kenl-logging | grep 'https://' | awk '{print $2}')" >> .env.deployment
```

### Validation

```bash
# Test api-atom worker
source .env.deployment
curl -s "$API_ATOM_URL/api/atom/stats" | jq .

# Expected: JSON response with stats
# {
#   "total": 0,
#   "by_type": [],
#   "recent_failures": 0
# }

# Test logging worker
curl -X POST "$LOGGING_URL/api/log" \
  -H "Content-Type: application/json" \
  -d '{
    "tag": "ATOM-TEST-001",
    "type": "TEST",
    "description": "Test deployment"
  }'

# Expected: "Logged" (200 OK)
```

### Rollback

```bash
# Rollback to previous version
wrangler rollback kenl-api-atom
wrangler rollback kenl-logging
```

### ATOM Log

```bash
echo "ATOM-CF-DEPLOY-$(date +%Y%m%d)-001: Deployed workers to production" >> ~/.kenl/atom-trail.log

# Also log via the logging worker
source .env.deployment
curl -X POST "$LOGGING_URL/api/log" \
  -H "Content-Type: application/json" \
  -d "{
    \"tag\": \"ATOM-CF-DEPLOY-$(date +%Y%m%d)-001\",
    \"type\": \"DEPLOY\",
    \"description\": \"Deployed KENL Cloudflare infrastructure to production\",
    \"user\": \"$(whoami)\",
    \"hostname\": \"$(hostname)\",
    \"exit_code\": 0
  }"
```

**Step 6 Complete?** ✅ Both workers responding to requests

---

## Step 7: Final Verification

### Intent
Comprehensive validation of entire deployment.

### Validation Checklist

```bash
# 7.1 Verify D1 database
wrangler d1 execute kenl-atom-trails --command="SELECT COUNT(*) FROM atom_trails;"
# ✅ Returns count (even if 0)

# 7.2 Verify KV namespaces
wrangler kv:namespace list | grep -c "sessions"
# ✅ Shows 2 (production + preview)

# 7.3 Verify workers responding
source .env.deployment
curl -s "$API_ATOM_URL/api/atom/recent" | jq 'length'
# ✅ Returns number (even if 0)

# 7.4 Test logging pipeline
ATOM_TAG="ATOM-VERIFY-$(date +%Y%m%d)-001"
curl -X POST "$LOGGING_URL/api/log" \
  -H "Content-Type: application/json" \
  -d "{\"tag\":\"$ATOM_TAG\",\"type\":\"VERIFY\",\"description\":\"Deployment verification test\"}"

# Wait 5 seconds for processing
sleep 5

# Query back from D1
wrangler d1 execute kenl-atom-trails \
  --command="SELECT tag, description FROM atom_trails WHERE tag='$ATOM_TAG';"
# ✅ Shows the entry we just logged
```

### Success Criteria

- [ ] D1 database query succeeds
- [ ] KV namespaces exist (6 total)
- [ ] api-atom worker responds
- [ ] logging worker accepts logs
- [ ] Logged entry appears in D1 database

**All criteria met?** 🎉 **DEPLOYMENT COMPLETE**

### ATOM Log

```bash
echo "ATOM-CF-VERIFY-$(date +%Y%m%d)-001: Deployment verification complete ✅" >> ~/.kenl/atom-trail.log
```

---

## Step 8: Next Steps (Optional)

### Now that you're deployed:

1. **Configure DNS** (if you have `toolated.online` domain)
   ```bash
   # See: docs/DOMAIN-ROUTING.md
   ```

2. **Set up GitHub Actions CI/CD**
   ```bash
   # Add secrets to GitHub repository:
   source .env.deployment
   echo "CLOUDFLARE_ACCOUNT_ID: $CLOUDFLARE_ACCOUNT_ID"
   echo "Generate API token: https://dash.cloudflare.com/profile/api-tokens"

   # See: workflows/SAIF-GITHUB-INTEGRATION.md
   ```

3. **Sync your local ATOM database to D1**
   ```bash
   # If you have existing ATOM trails
   ./scripts/sync-atom-to-d1.sh --recent-only
   ```

4. **Create R2 buckets for archiving**
   ```bash
   ./scripts/create-r2-bucket.sh kenl-atom-archives
   ./scripts/create-r2-bucket.sh kenl-playcard-repo
   ./scripts/create-r2-bucket.sh kenl-backups
   ```

---

## Troubleshooting Guide

### Issue: "Permission denied" during deployment

```bash
# Check API token permissions
wrangler whoami

# Ensure token has:
# - Workers Scripts: Edit
# - D1: Edit
# - Workers KV Storage: Edit

# Re-authenticate
wrangler logout
wrangler login
```

### Issue: Worker deployment fails

```bash
# Check wrangler.toml syntax
./scripts/validate-config.sh workers/api-atom/wrangler.toml

# Check for placeholders
grep "<your-" workers/*/wrangler.toml

# If found, go back to Step 5
```

### Issue: Database query fails

```bash
# List all databases
wrangler d1 list

# If kenl-atom-trails not found, go back to Step 2
# If found but queries fail, check schemas (Step 3)
```

### Issue: Lost resource IDs

```bash
# Retrieve from Cloudflare
wrangler d1 list | grep kenl-atom-trails
wrangler kv:namespace list | grep sessions

# Recreate .env.deployment with actual values
```

---

## Deployment Summary

### What You Built

```
Cloudflare Resources Created:
├── D1 Database: kenl-atom-trails (4 tables)
├── KV: sessions (production + preview)
├── KV: cache (production + preview)
├── KV: rate-limits (production + preview)
├── Worker: kenl-api-atom (4 endpoints)
└── Worker: kenl-logging (1 endpoint)

Total Deployment Time: TBD (not yet verified)
Infrastructure Cost: $0/month (Free tier)
```

### URLs Available

```bash
# View your deployment URLs
source .env.deployment
echo "ATOM API: $API_ATOM_URL/api/atom/recent"
echo "Logging: $LOGGING_URL/api/log"
```

### Files Created

```
cloudflare-infrastructure/
├── .env.deployment      ← Your captured IDs (DO NOT COMMIT)
├── .database-id.txt     ← D1 database ID
└── .kv-ids.txt          ← KV namespace IDs
```

**Add to .gitignore**:

```bash
echo ".env.deployment" >> .gitignore
echo ".database-id.txt" >> .gitignore
echo ".kv-ids.txt" >> .gitignore
```

---

## ATOM Trail Summary

```
ATOM-CF-AUTH-20251116-001: Authenticated with Cloudflare account
ATOM-CF-D1-20251116-001: Created D1 database kenl-atom-trails
ATOM-CF-SCHEMA-20251116-001: Applied 4 database schemas
ATOM-CF-KV-20251116-001: Created 3 KV namespaces
ATOM-CF-CONFIG-20251116-001: Updated worker configurations
ATOM-CF-DEPLOY-20251116-001: Deployed workers to production
ATOM-CF-VERIFY-20251116-001: Deployment verification complete ✅
```

---

## Complete Rollback Procedure

If you need to completely remove the deployment:

```bash
# Delete workers
wrangler delete kenl-api-atom --force
wrangler delete kenl-logging --force

# Delete KV namespaces
wrangler kv:namespace delete --binding sessions
wrangler kv:namespace delete --binding cache
wrangler kv:namespace delete --binding rate-limits

# Delete D1 database
wrangler d1 delete kenl-atom-trails --skip-confirmation

# Clean up local files
rm .env.deployment .database-id.txt .kv-ids.txt

# Restore original configs
git checkout workers/*/wrangler.toml

echo "✅ Complete rollback finished - all Cloudflare resources deleted"
```

---

## License

MIT - Same as KENL repository

## Links

- [Architecture Overview](../docs/ARCHITECTURE.md)
- [Full Setup Guide](SAIF-CLOUDFLARE-SETUP.md) (if starting from scratch)
- [GitHub Integration](SAIF-GITHUB-INTEGRATION.md)
- [Main KENL README](../../README.md)
