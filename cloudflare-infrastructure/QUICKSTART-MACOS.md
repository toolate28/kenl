# macOS Quick Start

**KENL Cloudflare Infrastructure for macOS 12+**

## One-Command Clone

```bash
# Full repository (recommended)
git clone https://github.com/toolate28/kenl.git
cd kenl/cloudflare-infrastructure

# OR: Sparse clone (Cloudflare only, ~5MB)
git clone --depth 1 --filter=blob:none --sparse https://github.com/toolate28/kenl.git
cd kenl
git sparse-checkout set cloudflare-infrastructure
cd cloudflare-infrastructure
```

## Setup (5 minutes)

```bash
# 1. Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install Node.js
brew install node

# 3. Install Wrangler CLI
npm install -g wrangler

# 4. Authenticate with Cloudflare
wrangler login

# 5. Verify
wrangler whoami
```

## Deploy (50 minutes)

```bash
# Follow step-by-step guide
./workflows/SAIF-CLOUDFLARE-SETUP.md
```

## Quick Commands

```bash
# Create D1 database
./scripts/create-d1-database.sh kenl-atom-trails

# Deploy worker
./scripts/deploy-worker.sh api-atom --production

# Sync ATOM database
./scripts/sync-atom-to-d1.sh
```

---

**Next**: See [README.md](README.md) for full documentation
