---
project: KENL Cloudflare Infrastructure
atom: ATOM-INFRA-20251116-001
classification: OWI-STANDARD
status: production-ready
---

# KENL Cloudflare Infrastructure

**Modular, composable Cloudflare services for KENL with SAIF workflow automation**

## Architecture Principles

### Modularity First
- **One script = One responsibility** (< 200 lines ideal)
- **Composable utilities** that chain together
- **No megalithic scripts** - break into focused modules
- **Testable independently** - each script has clear I/O

### Domain Structure

**Public Domains** (`*.toolated.online`):
- `kenl.toolated.online` - Main web interface (Cloudflare Pages)
- `api.toolated.online` - Backend API (Cloudflare Workers)

**Subdomains** (per KENL module):
- `gaming.toolated.online` - KENL2 Play Card browser
- `dev.toolated.online` - KENL3 development dashboards
- `atom.toolated.online` - KENL4 ATOM trail analytics

## Directory Structure

```
cloudflare-infrastructure/
├── schemas/              # D1 database schemas (one file per table)
│   ├── atom_trails.sql
│   ├── playcard_rules.sql
│   ├── users.sql
│   └── sessions.sql
├── workers/              # Cloudflare Workers (small, focused)
│   ├── api-atom/         # ATOM trail query API
│   ├── api-playcard/     # Play Card validation API
│   ├── auth/             # Authentication worker
│   └── logging/          # Centralized logging worker
├── pages/                # Cloudflare Pages sites
│   ├── kenl-web/         # Main website
│   └── atom-dashboard/   # ATOM analytics dashboard
├── scripts/              # Small utility scripts
│   ├── validate-config.sh      # Validate wrangler.toml
│   ├── sync-d1.sh              # SQLite -> D1 sync
│   ├── deploy-worker.sh        # Deploy single worker
│   ├── create-kv-namespace.sh  # Create KV namespace
│   └── backup-to-r2.sh         # Backup to R2
├── workflows/            # SAIF workflow orchestrators
│   ├── SAIF-CLOUDFLARE-SETUP.md
│   ├── SAIF-GITHUB-INTEGRATION.md
│   └── SAIF-BAZZITE-GAMING.md
└── docs/
    ├── ARCHITECTURE.md
    ├── DEPLOYMENT.md
    └── DOMAIN-ROUTING.md
```

## Quick Start

### 1. Initialize Cloudflare Services
```bash
cd cloudflare-infrastructure/workflows
./saif-cloudflare-setup.sh --init
```

### 2. Deploy Individual Services
```bash
# Deploy ATOM API worker
./scripts/deploy-worker.sh api-atom

# Sync ATOM database to D1
./scripts/sync-d1.sh atom_trails

# Create KV namespace for sessions
./scripts/create-kv-namespace.sh sessions
```

### 3. Run SAIF Workflow
```bash
# Full Cloudflare setup with validation
./workflows/saif-cloudflare-setup.sh --validate
```

## Services Overview

### Cloudflare D1 (SQLite-Compatible Database)
- **atom_trails** - Syncs with local `~/.kenl/db/atom-trails.db`
- **playcard_rules** - Validation rules for Play Cards
- **users** - User accounts for web interface
- **sessions** - Active user sessions

### Cloudflare Workers (API Endpoints)
- **api-atom** - Query ATOM trails, get analytics
- **api-playcard** - Validate and serve Play Cards
- **auth** - User authentication (OAuth + API tokens)
- **logging** - Centralized logging with Analytics Engine

### Cloudflare KV (Key-Value Storage)
- **sessions** - User session tokens (TTL: 24h)
- **cache** - Cached Play Cards and validation results
- **rate-limits** - API rate limiting counters

### Cloudflare R2 (Object Storage)
- **kenl-atom-archives** - ATOM trail archives (30+ days)
- **playcard-repo** - Community Play Card repository
- **backups** - Automated database backups

### Cloudflare Pages (Static Sites)
- **kenl.toolated.online** - Main KENL website
- **atom.toolated.online** - ATOM analytics dashboard (Grafana-style)

## SAIF Workflows

### 1. Cloudflare Setup (`SAIF-CLOUDFLARE-SETUP.md`)
Intelligently sets up all Cloudflare services with validation:
- Creates D1 databases and applies schemas
- Deploys Workers with dependency checking
- Configures KV namespaces and bindings
- Sets up R2 buckets with lifecycle rules
- Configures DNS and WAF rules
- Validates everything before going live

### 2. GitHub Integration (`SAIF-GITHUB-INTEGRATION.md`)
Automates CI/CD with ATOM logging:
- GitHub Actions for automated deployment
- ATOM trail logging for all deployments
- Rollback on failed deployment
- Secrets management with Cloudflare vault

### 3. Bazzite Gaming Configuration (`SAIF-BAZZITE-GAMING.md`)
Hardware-specific gaming optimizations:
- Detects hardware profile (AMD/NVIDIA/Intel)
- Applies optimal Play Cards
- Configures MangoHud, Gamescope
- Logs all changes with ATOM trail

## Deployment Flow

```mermaid
graph LR
    A[Local Changes] --> B[Validate Config]
    B --> C[Run Tests]
    C --> D[Deploy to Staging]
    D --> E[Integration Tests]
    E --> F{Pass?}
    F -->|Yes| G[Deploy to Production]
    F -->|No| H[Rollback]
    G --> I[Log ATOM Trail]
    H --> I
```

## Integration with Existing ATOM System

**This infrastructure extends the existing ATOM database** (see `modules/KENL4-monitoring/docs/ATOM-DATABASE-ARCHITECTURE.md`):

- Local SQLite (`~/.kenl/db/atom-trails.db`) remains source of truth
- Cloudflare D1 is a **sync target** for web queries
- R2 archives long-term ATOM trails (30+ days)
- Workers Analytics provides real-time metrics

## Security

- **D1 databases**: Row-level security with user context
- **Workers**: Rate limiting (100 req/min per IP)
- **KV namespaces**: Scoped access tokens
- **R2 buckets**: Private by default, signed URLs for access
- **Pages**: Static content, no server-side execution

## Development

### Prerequisites
```bash
# Install Wrangler CLI
npm install -g wrangler

# Login to Cloudflare
wrangler login

# Verify access
wrangler whoami
```

### Local Testing
```bash
# Test worker locally
cd workers/api-atom
wrangler dev

# Test D1 database locally
wrangler d1 execute kenl-atom-trails --local --file=../../schemas/atom_trails.sql
```

## ATOM Trail

```
ATOM-INFRA-20251116-001: Created modular Cloudflare infrastructure foundation
Intent: Enable KENL web services with *.toolated.online domains
Architecture: Small, composable scripts following KENL modularity principles
Validation: Follows existing ATOM database design, extends with D1/Workers/R2
Next: Implement individual schemas, workers, and SAIF workflows
```

## License

MIT - Same as KENL repository

## Links

- [Main KENL README](../README.md)
- [ATOM Database Architecture](../modules/KENL4-monitoring/docs/ATOM-DATABASE-ARCHITECTURE.md)
- [Cloudflare Integration Case Study](../case-studies/CLOUDFLARE_INTEGRATION.md)
- [SAIF Framework](../dotfiles/SAIF-FRAMEWORK.md)
