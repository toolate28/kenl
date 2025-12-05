---
project: KENL Cloudflare Domain Routing
atom: ATOM-DOC-20251116-007
classification: OWI-DOC
status: production-ready
---

# Domain Routing Architecture

**Complete domain structure for *.toolated.online KENL services**

## Public Domain Strategy

KENL uses **2 primary public domains** on `*.toolated.online`:

### 1. `kenl.toolated.online` - Main Web Interface
**Purpose**: User-facing web applications and documentation

**Technology**: Cloudflare Pages

**Content**:
- Landing page with KENL overview
- Documentation browser
- Play Card repository (browse community configs)
- ATOM trail public viewer (opt-in shared trails)

**DNS Configuration**:
```
Type: CNAME
Name: kenl
Target: kenl-web.pages.dev
Proxy: Enabled (orange cloud)
```

**Cloudflare Pages Deployment**:
```bash
cd cloudflare-infrastructure/pages/kenl-web
wrangler pages deploy dist --project-name kenl-web
```

### 2. `api.toolated.online` - Backend API
**Purpose**: REST API for ATOM trails, Play Cards, authentication

**Technology**: Cloudflare Workers

**Endpoints**:
- `/api/atom/*` - ATOM trail queries
- `/api/playcard/*` - Play Card validation and serving
- `/api/auth/*` - User authentication
- `/api/log` - ATOM trail logging endpoint

**DNS Configuration**:
```
Type: CNAME
Name: api
Target: <worker-domain>  # Auto-assigned by Cloudflare
Proxy: Enabled (orange cloud)
```

## Subdomain Structure (KENL Modules)

Each KENL module gets a dedicated subdomain:

| Subdomain | Module | Purpose | Technology |
|-----------|--------|---------|------------|
| `gaming.toolated.online` | KENL2 | Play Card browser, gaming guides | Pages |
| `dev.toolated.online` | KENL3 | Developer dashboards, Ollama/Qwen UI | Pages |
| `atom.toolated.online` | KENL4 | ATOM trail analytics (Grafana-style) | Pages |
| `monitoring.toolated.online` | KENL4 | Prometheus/Grafana metrics | Pages |
| `social.toolated.online` | KENL6 | Community profiles, sharing | Pages |

## API Routing Structure

```
api.toolated.online
├── /api/atom/
│   ├── GET /recent               # Last 100 ATOM trails
│   ├── GET /search?q=<keyword>   # Search trails
│   ├── GET /tag/<atom-tag>       # Get specific trail
│   ├── GET /stats                # Trail statistics
│   └── GET /user/<username>      # User's trails
│
├── /api/playcard/
│   ├── GET /browse               # List available Play Cards
│   ├── GET /game/<game-id>       # Get Play Card for game
│   ├── POST /validate            # Validate Play Card YAML
│   ├── POST /submit              # Submit new Play Card
│   └── GET /popular              # Most used Play Cards
│
├── /api/auth/
│   ├── POST /login               # Login (email/password)
│   ├── POST /oauth/<provider>    # OAuth login (GitHub, Discord)
│   ├── POST /logout              # Logout
│   ├── GET /me                   # Current user profile
│   └── POST /token               # Generate API token
│
└── /api/log
    └── POST /                    # Log ATOM trail entry
```

## DNS Records (Complete Setup)

```bash
# Primary domains
kenl.toolated.online      CNAME  kenl-web.pages.dev       (proxied)
api.toolated.online       CNAME  <auto-worker-domain>     (proxied)

# KENL module subdomains
gaming.toolated.online    CNAME  kenl-gaming.pages.dev    (proxied)
dev.toolated.online       CNAME  kenl-dev.pages.dev       (proxied)
atom.toolated.online      CNAME  kenl-atom.pages.dev      (proxied)
monitoring.toolated.online CNAME kenl-monitoring.pages.dev (proxied)
social.toolated.online    CNAME  kenl-social.pages.dev    (proxied)

# Development environments
api-dev.toolated.online   CNAME  <dev-worker-domain>      (proxied)
staging.toolated.online   CNAME  kenl-staging.pages.dev   (proxied)
```

## Worker Routing Configuration

### wrangler.toml Example

```toml
# Production routes
[env.production]
routes = [
  { pattern = "api.toolated.online/api/atom/*", zone_name = "toolated.online" },
  { pattern = "api.toolated.online/api/playcard/*", zone_name = "toolated.online" },
  { pattern = "api.toolated.online/api/log", zone_name = "toolated.online" }
]

# Development routes
[env.dev]
routes = [
  { pattern = "api-dev.toolated.online/*", zone_name = "toolated.online" }
]
```

## Security Configuration

### WAF Rules

```yaml
# Block common attacks
rules:
  - name: "Block SQL injection attempts"
    expression: '(http.request.uri.query contains "UNION SELECT") or (http.request.uri.query contains "DROP TABLE")'
    action: block

  - name: "Rate limit API calls"
    expression: 'http.request.uri.path starts_with "/api/"'
    action: challenge
    rate_limit:
      requests_per_minute: 100
      per_ip: true

  - name: "Block non-HTTPS"
    expression: 'not ssl'
    action: redirect
    redirect:
      url: 'https://${http.request.host}${http.request.uri}'
      status_code: 301
```

### CORS Configuration (Workers)

```typescript
// Permissive CORS for public APIs
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',  // Or specific domain: 'https://kenl.toolated.online'
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Access-Control-Max-Age': '86400',
};
```

## CDN and Caching

### Cache Configuration

```typescript
// Cache ATOM trail queries (5 minutes)
const cacheConfig = {
  '/api/atom/recent': { ttl: 300 },
  '/api/atom/stats': { ttl: 300 },
  '/api/playcard/browse': { ttl: 600 },
  '/api/playcard/popular': { ttl: 3600 },
};
```

### Cache-Control Headers

```typescript
// Set Cache-Control based on endpoint
const response = new Response(data, {
  headers: {
    'Content-Type': 'application/json',
    'Cache-Control': 'public, max-age=300',  // 5 minutes
  },
});
```

## Analytics and Monitoring

### Cloudflare Analytics

```bash
# View traffic analytics
wrangler pages deployment tail kenl-web --project-name kenl-web

# View worker analytics
wrangler tail kenl-api-atom
```

### Custom Metrics (Workers Analytics)

```typescript
// Track API usage
env.ANALYTICS.writeDataPoint({
  blobs: ['api-atom', 'GET', '/api/atom/recent'],
  doubles: [Date.now(), responseTime],
  indexes: ['api-atom'],
});
```

## Deployment Checklist

- [ ] Configure DNS records in Cloudflare dashboard
- [ ] Deploy Workers to production
- [ ] Deploy Pages sites
- [ ] Configure WAF rules
- [ ] Set up rate limiting
- [ ] Enable Cloudflare Analytics
- [ ] Test all API endpoints
- [ ] Verify SSL certificates
- [ ] Monitor for 24 hours

## Rollback Plan

```bash
# Revert DNS changes
# 1. Go to Cloudflare dashboard → DNS
# 2. Update CNAME records to previous values
# 3. Wait for propagation (TTL: 300s)

# Rollback Workers
wrangler rollback kenl-api-atom

# Rollback Pages
wrangler pages deployment list --project-name kenl-web
wrangler pages deployment promote <previous-deployment-id>
```

## Cost Estimation

### Cloudflare Free Tier Limits

- **Workers**: 100,000 requests/day
- **Pages**: Unlimited requests
- **D1**: 5 GB storage, 5M row reads/day
- **KV**: 100,000 reads/day, 1,000 writes/day
- **R2**: 10 GB storage, 1M Class A operations/month

### Expected Usage (KENL)

- **API requests**: ~10,000/day (well within limits)
- **D1 reads**: ~50,000/day (within limits)
- **KV reads**: ~5,000/day (within limits)
- **R2 storage**: ~1 GB (ATOM archives)

**Estimated monthly cost**: $0 (Free tier sufficient for initial deployment)

## ATOM Trail

```
ATOM-DOC-ROUTING-20251116-007: Documented domain routing architecture for *.toolated.online
Intent: Complete DNS, routing, and security configuration for KENL Cloudflare services
Structure: 2 primary domains (kenl, api) + 5 module subdomains
Validation: WAF rules, rate limiting, CORS configuration included
Next: Deploy DNS records and configure Cloudflare dashboard
```

## License

MIT - Same as KENL repository
