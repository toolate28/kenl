# Windows Quick Start

**KENL Cloudflare Infrastructure for Windows 10/11**

## One-Command Clone

```powershell
# Full repository (recommended)
git clone https://github.com/toolate28/kenl.git
cd kenl\cloudflare-infrastructure

# OR: Sparse clone (Cloudflare only, ~5MB)
git clone --depth 1 --filter=blob:none --sparse https://github.com/toolate28/kenl.git
cd kenl
git sparse-checkout set cloudflare-infrastructure
cd cloudflare-infrastructure
```

## Setup (5 minutes)

```powershell
# 1. Install Node.js
winget install OpenJS.NodeJS

# 2. Install Wrangler CLI
npm install -g wrangler

# 3. Authenticate with Cloudflare
wrangler login

# 4. Verify
wrangler whoami
```

## Deploy (50 minutes)

```powershell
# Follow step-by-step guide
.\workflows\SAIF-CLOUDFLARE-SETUP.md
```

## Quick Commands

```powershell
# Create D1 database
.\scripts\create-d1-database.sh kenl-atom-trails

# Deploy worker
.\scripts\deploy-worker.sh api-atom --production

# Sync ATOM database
.\scripts\sync-atom-to-d1.sh
```

**Note**: Scripts are Bash but work in Git Bash (included with Git for Windows)

---

**Next**: See [README.md](README.md) for full documentation
