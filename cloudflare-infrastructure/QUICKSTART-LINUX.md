# Linux Quick Start

**KENL Cloudflare Infrastructure for Linux (Any Distro)**

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

### Ubuntu/Debian

```bash
# 1. Install Node.js
sudo apt update && sudo apt install -y nodejs npm

# 2. Install Wrangler CLI
npm install -g wrangler

# 3. Authenticate with Cloudflare
wrangler login

# 4. Verify
wrangler whoami
```

### Fedora/RHEL/Bazzite

```bash
# 1. Install Node.js
sudo dnf install -y nodejs npm

# 2. Install Wrangler CLI
npm install -g wrangler

# 3. Authenticate with Cloudflare
wrangler login

# 4. Verify
wrangler whoami
```

### Arch Linux

```bash
# 1. Install Node.js
sudo pacman -S nodejs npm

# 2. Install Wrangler CLI
npm install -g wrangler

# 3. Authenticate with Cloudflare
wrangler login

# 4. Verify
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
