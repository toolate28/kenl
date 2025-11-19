---
project: KENL Cloudflare Deployment Guide
atom: ATOM-DOC-20251116-008
classification: OWI-DOC
status: production-ready
---

# Cloudflare Deployment Guide

**Complete deployment checklist for KENL Cloudflare infrastructure**

## Pre-Deployment

### 1. Verify Prerequisites

```bash
# Check tools installed
command -v wrangler || npm install -g wrangler
command -v jq || sudo dnf install jq
command -v sqlite3 || sudo dnf install sqlite

# Verify Cloudflare authentication
wrangler whoami
```

### 2. Configure Secrets

```bash
# Set Cloudflare API token
export CLOUDFLARE_API_TOKEN="your-token-here"

# For GitHub Actions, add to repository secrets:
# - CLOUDFLARE_API_TOKEN
# - CLOUDFLARE_ACCOUNT_ID
```

## Deployment Workflow

### Phase 1: Create Infrastructure (30 minutes)

```bash
cd cloudflare-infrastructure

# Step 1: Create D1 database
./scripts/create-d1-database.sh kenl-atom-trails
# Save database ID

# Step 2: Apply schemas
./scripts/apply-schema.sh kenl-atom-trails schemas/atom_trails.sql
./scripts/apply-schema.sh kenl-atom-trails schemas/playcard_rules.sql
./scripts/apply-schema.sh kenl-atom-trails schemas/users.sql
./scripts/apply-schema.sh kenl-atom-trails schemas/sessions.sql

# Step 3: Create KV namespaces
./scripts/create-kv-namespace.sh sessions --preview
./scripts/create-kv-namespace.sh cache --preview
./scripts/create-kv-namespace.sh rate-limits --preview
# Save namespace IDs

# Step 4: Create R2 buckets
./scripts/create-r2-bucket.sh kenl-atom-archives
./scripts/create-r2-bucket.sh kenl-playcard-repo --public
./scripts/create-r2-bucket.sh kenl-backups
```

### Phase 2: Configure Workers (15 minutes)

```bash
# Update wrangler.toml files with actual IDs
# Replace placeholders in:
# - workers/api-atom/wrangler.toml
# - workers/logging/wrangler.toml

# Validate configurations
./scripts/validate-config.sh workers/api-atom/wrangler.toml
./scripts/validate-config.sh workers/logging/wrangler.toml
```

### Phase 3: Deploy to Dev (10 minutes)

```bash
# Deploy workers to dev environment
./scripts/deploy-worker.sh api-atom --dev
./scripts/deploy-worker.sh logging --dev

# Test dev endpoints
curl https://api-dev.toolated.online/api/atom/recent
curl -X POST https://api-dev.toolated.online/api/log \
  -H "Content-Type: application/json" \
  -d '{"tag":"ATOM-TEST-001","type":"TEST","description":"Test log entry"}'
```

### Phase 4: Sync Data (5 minutes)

```bash
# Sync local ATOM database to D1
./scripts/sync-atom-to-d1.sh --recent-only

# Create initial R2 backup
./scripts/backup-to-r2.sh kenl-atom-archives
```

### Phase 5: Deploy to Production (15 minutes)

```bash
# Deploy workers to production
./scripts/deploy-worker.sh api-atom --production
./scripts/deploy-worker.sh logging --production

# Verify production endpoints
curl https://api.toolated.online/api/atom/stats
```

### Phase 6: Configure DNS (10 minutes)

**Manual steps via Cloudflare dashboard**:

1. Go to https://dash.cloudflare.com
2. Select zone: `toolated.online`
3. DNS → Add records:
   - `CNAME kenl → <pages-url>`
   - `CNAME api → <worker-url>`
4. Enable proxy (orange cloud)

### Phase 7: Validation (10 minutes)

```bash
# Run comprehensive validation
./scripts/validate-deployment.sh
```

## Post-Deployment

### 1. Monitor Deployment

```bash
# Watch worker logs
wrangler tail kenl-api-atom

# Check D1 database stats
wrangler d1 execute kenl-atom-trails --command="SELECT COUNT(*) FROM atom_trails;"
```

### 2. Set Up Scheduled Backups

```bash
# Add cron job for daily R2 backups
crontab -e

# Add line:
# 0 2 * * * /home/user/kenl/cloudflare-infrastructure/scripts/backup-to-r2.sh kenl-atom-archives
```

### 3. Configure GitHub Actions

```bash
# Copy workflow template
mkdir -p .github/workflows
cp cloudflare-infrastructure/workflows/github-ci-template.yml \
   .github/workflows/cloudflare-deploy.yml

# Commit and push
git add .github/workflows/cloudflare-deploy.yml
git commit -m "ci: Add Cloudflare deployment workflow"
git push
```

## Verification Checklist

- [ ] D1 database created and schemas applied
- [ ] KV namespaces created (sessions, cache, rate-limits)
- [ ] R2 buckets created (archives, playcard-repo, backups)
- [ ] Workers deployed to dev and production
- [ ] DNS records configured and propagated
- [ ] API endpoints responding (200 OK)
- [ ] ATOM logging functional
- [ ] GitHub Actions workflow configured
- [ ] Initial data synced to D1
- [ ] R2 backup successful

## Troubleshooting

### Worker Deployment Fails

```bash
# Check wrangler.toml syntax
./scripts/validate-config.sh workers/api-atom/wrangler.toml

# Check for placeholder values
grep "<your-" workers/api-atom/wrangler.toml

# View detailed error
cd workers/api-atom
wrangler deploy --env production --verbose
```

### D1 Schema Application Fails

```bash
# Check schema syntax
sqlite3 :memory: < schemas/atom_trails.sql

# Apply schema with error output
wrangler d1 execute kenl-atom-trails \
  --file schemas/atom_trails.sql \
  --json
```

### DNS Not Resolving

```bash
# Check DNS propagation
dig +short kenl.toolated.online
dig +short api.toolated.online

# Wait for TTL (usually 300s)
# Clear local DNS cache
sudo systemd-resolve --flush-caches
```

## Rollback Procedures

### Rollback Worker Deployment

```bash
# List recent deployments
wrangler deployments list kenl-api-atom

# Rollback to previous version
wrangler rollback kenl-api-atom

# Verify rollback
curl https://api.toolated.online/api/atom/stats
```

### Rollback D1 Schema

```bash
# Restore from R2 backup
wrangler r2 object get kenl-backups/atom-trails-backup-latest.db.gz \
  --file restore.db.gz

gunzip restore.db.gz

# Import to D1 (requires manual SQL export/import)
```

### Rollback DNS

1. Go to Cloudflare dashboard
2. DNS → Revert CNAME records to previous values
3. Wait for propagation (~5 minutes)

## ATOM Trail

```
ATOM-DOC-DEPLOY-20251116-008: Created comprehensive deployment guide
Intent: Step-by-step deployment process with validation and rollback
Phases: Infrastructure creation → Configuration → Dev deployment → Production
Validation: Complete checklist and troubleshooting procedures
Next: Execute deployment following this guide
```

## License

MIT - Same as KENL repository
