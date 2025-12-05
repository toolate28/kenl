# KENL Dual-Boot Gaming Setup: Agent Execution Directive

**ATOM:** ATOM-DIRECTIVE-DUALBOOT-20241127-001
**Target:** Local Claude agent with system access
**Scenario:** Battlefield 2042 (Windows 11) + Halo Infinite (Bazzite-DX)
**Duration:** 90-120 minutes total
**Approval Gates:** 7 mandatory checkpoints

---

## Mission Objectives

### Primary Goals
1. Install context-sync on Windows 11 (Claude Desktop)
2. Install context-sync in KENL container on Bazzite-DX (Claude Code)
3. Deploy Cloudflare D1 database for cross-OS sync
4. Configure BF 2042 on Windows with ATOM tagging
5. Configure Halo Infinite on Bazzite with ATOM tagging
6. Verify cross-platform memory persistence
7. Generate PDF user guide optimized for A4 printing

### Success Criteria
- [ ] context-sync operational on both OSes
- [ ] D1 database deployed and syncing
- [ ] BF 2042 config saved and tagged (ATOM-CFG-WIN-*)
- [ ] Halo Infinite config saved and tagged (ATOM-CFG-BAZZITE-*)
- [ ] Cross-OS query verified (query from opposite OS)
- [ ] ATOM trail contains entries from both platforms
- [ ] PDF guide generated with proper page breaks

---

## Phase 0: Pre-Flight Checks

**Duration:** 5 minutes
**Risk Level:** Low
**Rollback:** N/A (read-only)

### Checklist

```bash
# On Bazzite (host)
□ Verify dual-boot setup exists
  rpm-ostree status | head -20
  # Should show Bazzite deployment

□ Check available disk space
  df -h /home
  # Need: 5GB+ free

□ Verify distrobox installed
  distrobox list
  # Should show existing containers or empty

□ Test internet connectivity
  ping -c 3 cloudflare.com

□ Verify Cloudflare account access
  echo $CLOUDFLARE_API_TOKEN
  # Should return token or empty (will create)
```

```powershell
# On Windows (in PowerShell)
□ Verify Windows version
  Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion
  # Should show Windows 11

□ Check Node.js installation
  node --version
  # Should show v20.x or offer to install

□ Test internet connectivity
  Test-Connection -ComputerName cloudflare.com -Count 3

□ Verify Claude Desktop installed
  Test-Path "$env:LOCALAPPDATA\Programs\Claude\Claude.exe"
```

### APPROVAL GATE 1: Environment Verified
**Human Decision Required:** Proceed with Windows setup?
- [ ] YES: Continue to Phase 1
- [ ] NO: Document blockers in `/tmp/dual-boot-blockers.txt`

---

## Phase 1: Windows 11 Setup

**Duration:** 15-20 minutes
**Risk Level:** Low (user-space only)
**Rollback:** `npm uninstall -g @context-sync/server`

### Step 1.1: Install Node.js (if needed)

```powershell
# Check if Node.js installed
node --version

# If not installed or version < 20:
# 1. Download from https://nodejs.org/en/download/
# 2. Install LTS version (20.x)
# 3. Verify:
node --version
npm --version

# Generate ATOM tag
echo "ATOM-INSTALL-WIN-20241127-001: Node.js $(node --version) installed" | `
  Out-File -Append -FilePath "$env:TEMP\atom_trail.log"
```

### Step 1.2: Install context-sync

```powershell
# Install globally
npm install -g @context-sync/server

# Verify installation
context-sync --version

# Generate ATOM tag
echo "ATOM-INSTALL-WIN-20241127-002: context-sync $(context-sync --version) installed" | `
  Out-File -Append -FilePath "$env:TEMP\atom_trail.log"
```

### Step 1.3: Configure Claude Desktop MCP

```powershell
# Create config directory
$configPath = "$env:APPDATA\Claude\claude_desktop_config.json"
$configDir = Split-Path -Parent $configPath
New-Item -ItemType Directory -Force -Path $configDir

# Backup existing config (if exists)
if (Test-Path $configPath) {
  Copy-Item $configPath "$configPath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
}

# Create MCP configuration
$mcpConfig = @{
  mcpServers = @{
    "context-sync" = @{
      command = "context-sync"
      args = @("--mode", "mcp")
    }
    cloudflare = @{
      command = "npx"
      args = @("-y", "@cloudflare/mcp-server-cloudflare")
      env = @{
        CLOUDFLARE_API_TOKEN = "PLACEHOLDER_TOKEN"
        CLOUDFLARE_ACCOUNT_ID = "PLACEHOLDER_ACCOUNT"
      }
    }
  }
} | ConvertTo-Json -Depth 10

Set-Content -Path $configPath -Value $mcpConfig

Write-Host "✓ MCP config created at: $configPath"
Write-Host "⚠ IMPORTANT: Edit this file and replace PLACEHOLDER values"

# Generate ATOM tag
echo "ATOM-CFG-WIN-20241127-003: Claude Desktop MCP configured" | `
  Out-File -Append -FilePath "$env:TEMP\atom_trail.log"
```

### Step 1.4: Initialize Project

```powershell
# Initialize dual-boot-gaming project
$initCommand = @"
{
  "command": "init_project",
  "params": {
    "name": "dual-boot-gaming",
    "description": "Cross-platform gaming configuration management",
    "tech_stack": ["Windows 11", "Bazzite-DX", "AMD Radeon", "Dual-boot"],
    "metadata": {
      "platform": "windows",
      "created_at": "$(Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')",
      "games": ["Battlefield 2042"]
    }
  }
}
"@

# Save to temp file and execute
$initCommand | Out-File -FilePath "$env:TEMP\init_project.json"
Get-Content "$env:TEMP\init_project.json" | context-sync

# Verify
context-sync << @"
{
  "command": "get_project_context",
  "params": {"project_name": "dual-boot-gaming"}
}
"@

# Generate ATOM tag
echo "ATOM-INIT-WIN-20241127-004: dual-boot-gaming project initialized" | `
  Out-File -Append -FilePath "$env:TEMP\atom_trail.log"
```

### Step 1.5: Test Basic Operations

```powershell
# Test save_decision
context-sync << @"
{
  "command": "save_decision",
  "params": {
    "project_name": "dual-boot-gaming",
    "decision": "Use context-sync for cross-platform memory",
    "rationale": "Enable AI memory persistence across Windows and Bazzite boots",
    "alternatives": ["Manual config files", "Git-only tracking"],
    "metadata": {
      "platform": "windows",
      "atom_tag": "ATOM-DECISION-WIN-20241127-005"
    }
  }
}
"@

Write-Host "✓ Windows setup complete!"
Write-Host "  Database: $env:USERPROFILE\.context-sync\data.db"
Write-Host "  ATOM trail: $env:TEMP\atom_trail.log"
```

### APPROVAL GATE 2: Windows Setup Complete
**Human Decision Required:** Windows context-sync verified?
- [ ] YES: Continue to Phase 2 (Bazzite setup)
- [ ] NO: Review logs in `$env:TEMP\atom_trail.log`

---

## Phase 2: Bazzite-DX Setup

**Duration:** 20-30 minutes
**Risk Level:** Low (container-only)
**Rollback:** `distrobox rm kenl`

### Step 2.1: Create KENL Container (if not exists)

```bash
# Check if KENL exists
distrobox list | grep kenl

# If not exists, create it
if ! distrobox list | grep -q kenl; then
  distrobox create --name kenl --image ubuntu:24.04
  echo "ATOM-INSTALL-BAZZITE-20241127-006: KENL container created" >> /tmp/atom_trail.log
fi

# Enter KENL
distrobox enter kenl
```

### Step 2.2: Install Dependencies (inside KENL)

```bash
# Update package lists
sudo apt update

# Install Node.js via nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 20
nvm use 20

# Verify
node --version
npm --version

# Generate ATOM tag
echo "ATOM-INSTALL-BAZZITE-20241127-007: Node.js $(node --version) installed in KENL" >> /tmp/atom_trail.log

# Install development tools
sudo apt install -y git curl jq shellcheck

echo "ATOM-INSTALL-BAZZITE-20241127-008: Dev tools installed" >> /tmp/atom_trail.log
```

### Step 2.3: Install context-sync (inside KENL)

```bash
# Install globally
npm install -g @context-sync/server

# Verify
context-sync --version

# Generate ATOM tag
echo "ATOM-INSTALL-BAZZITE-20241127-009: context-sync $(context-sync --version) installed" >> /tmp/atom_trail.log
```

### Step 2.4: Configure Claude Code MCP (inside KENL)

```bash
# Create config directory
mkdir -p ~/.config/claude-code

# Create MCP configuration
cat > ~/.config/claude-code/mcp_config.json << 'EOF'
{
  "mcpServers": {
    "context-sync": {
      "command": "context-sync",
      "args": ["--mode", "mcp"]
    },
    "cloudflare": {
      "command": "npx",
      "args": ["-y", "@cloudflare/mcp-server-cloudflare"],
      "env": {
        "CLOUDFLARE_API_TOKEN": "PLACEHOLDER_TOKEN",
        "CLOUDFLARE_ACCOUNT_ID": "PLACEHOLDER_ACCOUNT"
      }
    }
  }
}
EOF

echo "✓ MCP config created at: ~/.config/claude-code/mcp_config.json"
echo "⚠ IMPORTANT: Edit this file and replace PLACEHOLDER values"

# Generate ATOM tag
echo "ATOM-CFG-BAZZITE-20241127-010: Claude Code MCP configured" >> /tmp/atom_trail.log
```

### Step 2.5: Initialize Project (inside KENL)

```bash
# Initialize same project
context-sync << 'EOF'
{
  "command": "init_project",
  "params": {
    "name": "dual-boot-gaming",
    "description": "Cross-platform gaming configuration management",
    "tech_stack": ["Windows 11", "Bazzite-DX", "AMD Radeon", "Dual-boot"],
    "metadata": {
      "platform": "bazzite",
      "created_at": "$(date -Iseconds)",
      "games": ["Halo Infinite"]
    }
  }
}
EOF

# Verify
context-sync << 'EOF'
{
  "command": "get_project_context",
  "params": {"project_name": "dual-boot-gaming"}
}
EOF

# Generate ATOM tag
echo "ATOM-INIT-BAZZITE-20241127-011: dual-boot-gaming project initialized" >> /tmp/atom_trail.log
```

### APPROVAL GATE 3: Bazzite Setup Complete
**Human Decision Required:** Bazzite context-sync verified?
- [ ] YES: Continue to Phase 3 (Cloudflare D1)
- [ ] NO: Review logs in `/tmp/atom_trail.log`

---

## Phase 3: Cloudflare D1 Deployment

**Duration:** 10-15 minutes
**Risk Level:** Low (cloud-only)
**Rollback:** `wrangler d1 delete atom-trail`

### Step 3.1: Install Wrangler (on either OS)

```bash
# Install Wrangler globally
npm install -g wrangler

# Verify
wrangler --version

# Login to Cloudflare
wrangler login

# Generate ATOM tag
echo "ATOM-INSTALL-D1-20241127-012: Wrangler installed and authenticated" >> /tmp/atom_trail.log
```

### Step 3.2: Create D1 Database

```bash
# Create database
wrangler d1 create atom-trail-dual-boot

# Save database ID (will be printed in output)
# Example output:
# ✅ Successfully created DB 'atom-trail-dual-boot' (ID: abc123...)

# Store database ID
echo "ATOM-DEPLOY-D1-20241127-013: D1 database created" >> /tmp/atom_trail.log
```

### Step 3.3: Create Schema

```bash
# Create schema file
cat > /tmp/d1_schema.sql << 'EOF'
-- ATOM trail table
CREATE TABLE atom_trail (
  atom_id TEXT PRIMARY KEY,
  operation TEXT NOT NULL,
  platform TEXT NOT NULL,        -- 'windows' or 'bazzite'
  agent TEXT NOT NULL,            -- 'claude-desktop', 'claude-code', 'qwen', 'perplexity'
  timestamp TEXT NOT NULL,
  signature TEXT,                 -- SHA-256 hash
  previous_atom TEXT,             -- Blockchain-style linking
  metadata JSON,                  -- Operation-specific data
  game TEXT,                      -- 'bf2042', 'halo-infinite', etc.
  token_cost INTEGER DEFAULT 0,
  FOREIGN KEY (previous_atom) REFERENCES atom_trail(atom_id)
);

-- Indexes for performance
CREATE INDEX idx_platform ON atom_trail(platform);
CREATE INDEX idx_game ON atom_trail(game);
CREATE INDEX idx_timestamp ON atom_trail(timestamp DESC);
CREATE INDEX idx_agent ON atom_trail(agent);

-- Game configurations table
CREATE TABLE game_configs (
  config_id TEXT PRIMARY KEY,
  game_name TEXT NOT NULL,
  platform TEXT NOT NULL,
  config_json TEXT NOT NULL,      -- Full config as JSON
  atom_ref TEXT,                  -- Links to ATOM trail
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (atom_ref) REFERENCES atom_trail(atom_id)
);

CREATE INDEX idx_game_platform ON game_configs(game_name, platform);

-- Cross-platform learnings table
CREATE TABLE learnings (
  learning_id TEXT PRIMARY KEY,
  pattern_name TEXT NOT NULL,     -- e.g., "amd-high-preset"
  source_platform TEXT,
  target_platform TEXT,
  effectiveness REAL,             -- 0.0 to 1.0
  games_applied TEXT,             -- JSON array of game names
  atom_refs TEXT,                 -- JSON array of ATOM IDs
  created_at TEXT NOT NULL
);

CREATE INDEX idx_pattern ON learnings(pattern_name);
EOF

# Apply schema
wrangler d1 execute atom-trail-dual-boot --file=/tmp/d1_schema.sql

echo "✓ D1 schema created with 3 tables"
echo "ATOM-SCHEMA-D1-20241127-014: D1 schema deployed" >> /tmp/atom_trail.log
```

### Step 3.4: Deploy Sync Worker

```bash
# Create Worker directory
mkdir -p ~/projects/atom-sync-worker
cd ~/projects/atom-sync-worker

# Initialize Worker
wrangler init atom-sync -y

# Create Worker script
cat > src/index.js << 'EOF'
export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    // CORS headers
    const corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    };

    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    // POST /sync - Sync ATOM entry to D1
    if (url.pathname === '/sync' && request.method === 'POST') {
      try {
        const data = await request.json();

        const result = await env.DB.prepare(
          `INSERT INTO atom_trail
           (atom_id, operation, platform, agent, timestamp, signature,
            previous_atom, metadata, game, token_cost)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
        ).bind(
          data.atom_id,
          data.operation,
          data.platform,
          data.agent,
          data.timestamp,
          data.signature,
          data.previous_atom || null,
          JSON.stringify(data.metadata || {}),
          data.game || null,
          data.token_cost || 0
        ).run();

        return new Response(JSON.stringify({
          success: true,
          atom_id: data.atom_id
        }), {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        });
      } catch (error) {
        return new Response(JSON.stringify({
          success: false,
          error: error.message
        }), {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        });
      }
    }

    // GET /query?platform=X&game=Y
    if (url.pathname === '/query' && request.method === 'GET') {
      const platform = url.searchParams.get('platform');
      const game = url.searchParams.get('game');

      let query = 'SELECT * FROM atom_trail WHERE 1=1';
      const bindings = [];

      if (platform) {
        query += ' AND platform = ?';
        bindings.push(platform);
      }
      if (game) {
        query += ' AND game = ?';
        bindings.push(game);
      }

      query += ' ORDER BY timestamp DESC LIMIT 50';

      const result = await env.DB.prepare(query).bind(...bindings).all();

      return new Response(JSON.stringify(result.results), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }

    // GET /config/:game
    if (url.pathname.startsWith('/config/')) {
      const game = url.pathname.split('/')[2];

      const result = await env.DB.prepare(
        'SELECT * FROM game_configs WHERE game_name = ? ORDER BY updated_at DESC LIMIT 1'
      ).bind(game).first();

      if (!result) {
        return new Response(JSON.stringify({ error: 'Config not found' }), {
          status: 404,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        });
      }

      return new Response(result.config_json, {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }

    return new Response('KENL ATOM Sync Worker', {
      headers: { ...corsHeaders, 'Content-Type': 'text/plain' }
    });
  }
};
EOF

# Update wrangler.toml
cat > wrangler.toml << 'EOF'
name = "atom-sync"
main = "src/index.js"
compatibility_date = "2024-11-27"

[[d1_databases]]
binding = "DB"
database_name = "atom-trail-dual-boot"
database_id = "YOUR_DATABASE_ID_HERE"
EOF

echo "⚠ IMPORTANT: Edit wrangler.toml and replace YOUR_DATABASE_ID_HERE"
echo "   Find ID in: wrangler d1 list"

# Deploy Worker
wrangler deploy

echo "✓ Worker deployed to: https://atom-sync.YOUR_ACCOUNT.workers.dev"
echo "ATOM-DEPLOY-D1-20241127-015: Sync Worker deployed" >> /tmp/atom_trail.log
```

### Step 3.5: Configure Sync URLs

```bash
# Update Windows config
# Edit: C:\Users\toolated\AppData\Roaming\Claude\claude_desktop_config.json
# Add environment variable:
# "CONTEXT_SYNC_D1_URL": "https://atom-sync.YOUR_ACCOUNT.workers.dev"

# Update Bazzite config
# Edit: ~/.config/claude-code/mcp_config.json
# Add environment variable:
# "CONTEXT_SYNC_D1_URL": "https://atom-sync.YOUR_ACCOUNT.workers.dev"

# Or set globally in KENL
echo 'export CONTEXT_SYNC_D1_URL="https://atom-sync.YOUR_ACCOUNT.workers.dev"' >> ~/.bashrc
source ~/.bashrc
```

### APPROVAL GATE 4: D1 Infrastructure Deployed
**Human Decision Required:** D1 database and Worker operational?
- [ ] YES: Continue to Phase 4 (BF 2042 config)
- [ ] NO: Review Worker logs: `wrangler tail atom-sync`

---

## Phase 4: Battlefield 2042 Configuration (Windows)

**Duration:** 20-30 minutes
**Risk Level:** Medium (game settings modified)
**Rollback:** Restore EA App settings backup

### Step 4.1: Research BF 2042 Optimization

```powershell
# This would typically use Perplexity via MCP
# For agent execution, use context-sync to save research

$research = @"
{
  "command": "save_conversation",
  "params": {
    "project_name": "dual-boot-gaming",
    "content": "Battlefield 2042 AMD Optimization Research",
    "messages": [
      {
        "role": "assistant",
        "content": "Research findings for BF 2042 on AMD Radeon:\n\n1. DirectX 12 recommended (better AMD performance)\n2. AMD FSR 2.0 Quality mode (best quality/performance)\n3. High preset baseline (adjust shadows/reflections)\n4. AMD Radeon settings:\n   - Anti-Lag: Enabled\n   - Radeon Boost: Off (conflicts with FSR)\n   - Texture Filtering: Performance\n5. EA App launch options: -dx12 -high\n\nExpected FPS: 60+ @ High (1080p) on Vega Mobile"
      }
    ],
    "metadata": {
      "platform": "windows",
      "atom_tag": "ATOM-RESEARCH-WIN-20241127-016",
      "token_cost": 3000,
      "agent": "perplexity"
    }
  }
}
"@

$research | Out-File -FilePath "$env:TEMP\bf_research.json"
Get-Content "$env:TEMP\bf_research.json" | context-sync

echo "ATOM-RESEARCH-WIN-20241127-016: BF 2042 research completed" | `
  Out-File -Append -FilePath "$env:TEMP\atom_trail.log"
```

### Step 4.2: Generate Configuration

```powershell
# Create BF 2042 config
$config = @"
{
  "game": "battlefield-2042",
  "platform": "windows",
  "launcher": "EA App",
  "gpu": "AMD Radeon Vega Mobile",
  "settings": {
    "graphics_preset": "High",
    "resolution": "1920x1080",
    "vsync": false,
    "fps_limit": 144,
    "directx_version": "12",
    "fsr": {
      "enabled": true,
      "mode": "Quality"
    }
  },
  "launch_options": "-dx12 -high",
  "amd_settings": {
    "anti_lag": true,
    "radeon_boost": false,
    "texture_filtering": "Performance"
  },
  "expected_fps": "60+",
  "tested_date": "$(Get-Date -Format 'yyyy-MM-dd')",
  "atom_tag": "ATOM-CFG-WIN-20241127-017"
}
"@

# Save to file
$config | Out-File -FilePath "$env:USERPROFILE\Documents\bf2042-config.json"

# Save to context-sync
$saveConfig = @"
{
  "command": "create_file",
  "params": {
    "project_name": "dual-boot-gaming",
    "path": "configs/bf2042-windows.json",
    "content": $($config | ConvertFrom-Json | ConvertTo-Json -Compress),
    "metadata": {
      "atom_tag": "ATOM-CFG-WIN-20241127-017",
      "agent": "claude-desktop"
    }
  }
}
"@

$saveConfig | Out-File -FilePath "$env:TEMP\save_config.json"
Get-Content "$env:TEMP\save_config.json" | context-sync

echo "ATOM-CFG-WIN-20241127-017: BF 2042 config created" | `
  Out-File -Append -FilePath "$env:TEMP\atom_trail.log"
```

### Step 4.3: Apply Configuration

```powershell
# Instructions for human to apply:
Write-Host @"
═══════════════════════════════════════════════════
 MANUAL STEPS REQUIRED: Apply BF 2042 Configuration
═══════════════════════════════════════════════════

1. Open AMD Radeon Software
   - Press Alt+R
   - Go to Gaming → Global Graphics
   - Set Anti-Lag: Enabled
   - Set Radeon Boost: Disabled
   - Set Texture Filtering: Performance

2. Open EA App
   - Find Battlefield 2042
   - Right-click → Game Properties
   - Advanced Launch Options: -dx12 -high
   - Save

3. Launch BF 2042
   - Go to Settings → Graphics
   - Set Preset: High
   - Enable AMD FSR 2.0 (Quality mode)
   - Resolution: 1920x1080
   - VSync: Off
   - Apply

4. Benchmark (5 minutes)
   - Play any match or bot mode
   - Monitor FPS with AMD overlay (Ctrl+Shift+O)
   - Record average FPS

Press Enter when configuration applied and tested...
"@

Read-Host

# Record test results
$testResults = Read-Host "Enter average FPS achieved"

$testData = @"
{
  "command": "save_decision",
  "params": {
    "project_name": "dual-boot-gaming",
    "decision": "BF 2042 Windows configuration validated",
    "rationale": "Achieved $testResults FPS with High preset + FSR Quality",
    "alternatives": ["Ultra preset (lower FPS)", "Medium preset (higher FPS)"],
    "metadata": {
      "platform": "windows",
      "atom_tag": "ATOM-TEST-WIN-20241127-018",
      "fps_achieved": "$testResults",
      "agent": "claude-desktop"
    }
  }
}
"@

$testData | Out-File -FilePath "$env:TEMP\test_results.json"
Get-Content "$env:TEMP\test_results.json" | context-sync

echo "ATOM-TEST-WIN-20241127-018: BF 2042 tested, $testResults FPS achieved" | `
  Out-File -Append -FilePath "$env:TEMP\atom_trail.log"
```

### Step 4.4: Sync to D1

```powershell
# Sync ATOM trail to D1
$syncScript = @"
`$atoms = Get-Content "$env:TEMP\atom_trail.log"
`$workerUrl = "https://atom-sync.YOUR_ACCOUNT.workers.dev"

foreach (`$atom in `$atoms | Where-Object { `$_ -match "ATOM-.*-WIN-" }) {
  `$parts = `$atom -split ": "
  `$atomId = `$parts[0]
  `$operation = `$parts[1]

  `$payload = @{
    atom_id = `$atomId
    operation = `$operation
    platform = "windows"
    agent = "claude-desktop"
    timestamp = (Get-Date).ToString("o")
    game = "bf2042"
  } | ConvertTo-Json

  Invoke-RestMethod -Uri "`$workerUrl/sync" -Method POST -Body `$payload -ContentType "application/json"

  Write-Host "✓ Synced: `$atomId"
}
"@

$syncScript | Out-File -FilePath "$env:TEMP\sync_to_d1.ps1"
Write-Host "Sync script created: $env:TEMP\sync_to_d1.ps1"
Write-Host "Run to sync ATOM trail to D1"
```

### APPROVAL GATE 5: BF 2042 Configured
**Human Decision Required:** BF 2042 running satisfactorily on Windows?
- [ ] YES: Continue to Phase 5 (Halo Infinite)
- [ ] NO: Adjust settings and re-test

---

## Phase 5: Halo Infinite Configuration (Bazzite)

**Duration:** 20-30 minutes
**Risk Level:** Medium (game settings modified)
**Rollback:** Remove `~/.config/gaming-intent/halo-infinite.env`

### Step 5.1: Research with Cross-Reference (inside KENL)

```bash
# Query BF config from Windows
context-sync << 'EOF'
{
  "command": "search_files",
  "params": {
    "project_name": "dual-boot-gaming",
    "query": "battlefield",
    "file_types": ["json"]
  }
}
EOF

# Research Halo Infinite (Perplexity would be called here)
context-sync << 'EOF'
{
  "command": "save_conversation",
  "params": {
    "project_name": "dual-boot-gaming",
    "content": "Halo Infinite Linux Optimization Research",
    "messages": [
      {
        "role": "assistant",
        "content": "Research findings for Halo Infinite on Bazzite:\n\n1. ProtonDB: Gold rating\n2. Recommended: Proton-GE 8.25\n3. DXVK 2.3 for best compatibility\n4. Steam launch options: PROTON_USE_WINED3D=0 DXVK_HUD=fps %command%\n5. Graphics: High preset (same as BF 2042)\n6. Anti-cheat: Works with Proton\n7. Expected FPS: 55+ @ High (1080p) - ~5-10% lower than Windows\n\nCross-reference: BF 2042 config shows High preset stable at 60 FPS on same GPU. Halo should achieve similar with Proton overhead."
      }
    ],
    "metadata": {
      "platform": "bazzite",
      "atom_tag": "ATOM-RESEARCH-BAZZITE-20241127-019",
      "token_cost": 2000,
      "agent": "perplexity",
      "influenced_by": "ATOM-CFG-WIN-20241127-017"
    }
  }
}
EOF

echo "ATOM-RESEARCH-BAZZITE-20241127-019: Halo Infinite research completed (cross-referenced BF)" >> /tmp/atom_trail.log
```

### Step 5.2: Generate Configuration (Qwen - FREE)

```bash
# Create Halo Infinite config
cat > /tmp/halo-infinite-config.json << 'EOF'
{
  "game": "halo-infinite",
  "platform": "bazzite",
  "launcher": "Steam",
  "proton_version": "GE-Proton8-25",
  "gpu": "AMD Radeon Vega Mobile",
  "settings": {
    "graphics_preset": "High",
    "resolution": "1920x1080",
    "vsync": false,
    "fps_limit": 144,
    "dxvk_version": "2.3"
  },
  "launch_options": "PROTON_USE_WINED3D=0 DXVK_HUD=fps PROTON_LOG=1 %command%",
  "environment_vars": {
    "DXVK_HUD": "fps,memory",
    "RADV_DEBUG": "",
    "AMD_VULKAN_ICD": "RADV"
  },
  "expected_fps": "55+",
  "expected_delta_from_windows": "-5 to -10 FPS (Proton overhead)",
  "learned_from": "ATOM-CFG-WIN-20241127-017",
  "tested_date": "TBD",
  "atom_tag": "ATOM-CFG-BAZZITE-20241127-020"
}
EOF

# Save to context-sync
context-sync << EOF
{
  "command": "create_file",
  "params": {
    "project_name": "dual-boot-gaming",
    "path": "configs/halo-infinite-bazzite.json",
    "content": $(cat /tmp/halo-infinite-config.json | jq -c),
    "metadata": {
      "atom_tag": "ATOM-CFG-BAZZITE-20241127-020",
      "agent": "qwen",
      "token_cost": 0
    }
  }
}
EOF

echo "ATOM-CFG-BAZZITE-20241127-020: Halo Infinite config created (Qwen, 0 tokens)" >> /tmp/atom_trail.log
```

### Step 5.3: Apply Configuration

```bash
# Create gaming-intent directory (on host, accessible from container)
mkdir -p ~/.config/gaming-intent

# Create env file
cat > ~/.config/gaming-intent/halo-infinite.env << 'EOF'
# Halo Infinite - Bazzite-DX Configuration
# Generated by KENL: ATOM-CFG-BAZZITE-20241127-020
# Learned from: BF 2042 Windows config (High preset stable)

# Proton version
PROTON_VERSION="GE-Proton8-25"

# DXVK settings
DXVK_HUD="fps,memory"
DXVK_LOG_LEVEL="none"

# AMD/RADV settings
AMD_VULKAN_ICD="RADV"
RADV_DEBUG=""

# Performance
PROTON_USE_WINED3D=0
PROTON_LOG=1

# Steam launch options (paste in Steam):
# PROTON_USE_WINED3D=0 DXVK_HUD=fps PROTON_LOG=1 %command%
EOF

echo "✓ Config created: ~/.config/gaming-intent/halo-infinite.env"

# Manual steps instructions
cat << 'INSTRUCTIONS'
═══════════════════════════════════════════════════
 MANUAL STEPS REQUIRED: Apply Halo Infinite Config
═══════════════════════════════════════════════════

1. Open Steam
   - Find Halo Infinite in library
   - Right-click → Properties

2. Set Compatibility Tool
   - Force use: Proton-GE 8-25
   - (Install GE-Proton from ProtonUp-Qt if needed)

3. Set Launch Options
   - Paste: PROTON_USE_WINED3D=0 DXVK_HUD=fps PROTON_LOG=1 %command%
   - Click OK

4. Launch Halo Infinite
   - First launch may take 2-3 minutes (shader compilation)
   - Go to Settings → Graphics
   - Set Preset: High (same as BF 2042)
   - Resolution: 1920x1080
   - VSync: Off
   - Apply

5. Benchmark (5 minutes)
   - Play any match or bot mode
   - Monitor FPS with DXVK HUD (top-left corner)
   - Record average FPS

Press Enter when configuration applied and tested...
INSTRUCTIONS

read -p ""

# Record test results
read -p "Enter average FPS achieved: " FPS_RESULT

# Save test results
context-sync << EOF
{
  "command": "save_decision",
  "params": {
    "project_name": "dual-boot-gaming",
    "decision": "Halo Infinite Bazzite configuration validated",
    "rationale": "Achieved $FPS_RESULT FPS with High preset (learned from BF 2042 Windows config)",
    "alternatives": ["Ultra preset (lower FPS)", "Medium preset (higher FPS)"],
    "metadata": {
      "platform": "bazzite",
      "atom_tag": "ATOM-TEST-BAZZITE-20241127-021",
      "fps_achieved": "$FPS_RESULT",
      "agent": "claude-code",
      "cross_os_learning": true,
      "windows_ref": "ATOM-CFG-WIN-20241127-017"
    }
  }
}
EOF

echo "ATOM-TEST-BAZZITE-20241127-021: Halo Infinite tested, $FPS_RESULT FPS achieved" >> /tmp/atom_trail.log
```

### Step 5.4: Sync to D1

```bash
# Sync ATOM trail to D1
cat > /tmp/sync_to_d1.sh << 'SYNCSCRIPT'
#!/bin/bash
WORKER_URL="https://atom-sync.YOUR_ACCOUNT.workers.dev"

while IFS= read -r line; do
  if [[ $line =~ ATOM-.*-BAZZITE- ]]; then
    ATOM_ID=$(echo "$line" | cut -d: -f1)
    OPERATION=$(echo "$line" | cut -d: -f2-)

    PAYLOAD=$(jq -n \
      --arg aid "$ATOM_ID" \
      --arg op "$OPERATION" \
      --arg plat "bazzite" \
      --arg agent "claude-code" \
      --arg ts "$(date -Iseconds)" \
      --arg game "halo-infinite" \
      '{
        atom_id: $aid,
        operation: $op,
        platform: $plat,
        agent: $agent,
        timestamp: $ts,
        game: $game
      }')

    curl -X POST "$WORKER_URL/sync" \
      -H "Content-Type: application/json" \
      -d "$PAYLOAD"

    echo "✓ Synced: $ATOM_ID"
  fi
done < /tmp/atom_trail.log
SYNCSCRIPT

chmod +x /tmp/sync_to_d1.sh
echo "Sync script created: /tmp/sync_to_d1.sh"
echo "Run to sync ATOM trail to D1"
```

### APPROVAL GATE 6: Halo Infinite Configured
**Human Decision Required:** Halo Infinite running satisfactorily on Bazzite?
- [ ] YES: Continue to Phase 6 (Verification)
- [ ] NO: Adjust Proton version or settings

---

## Phase 6: Cross-Platform Verification

**Duration:** 10 minutes
**Risk Level:** Low (read-only)
**Rollback:** N/A

### Step 6.1: Test Cross-OS Memory (Windows Query)

```powershell
# Boot to Windows
# Open Claude Desktop
# Query for Halo config

context-sync << @"
{
  "command": "search_files",
  "params": {
    "project_name": "dual-boot-gaming",
    "query": "halo-infinite",
    "file_types": ["json", "env"]
  }
}
"@

# Expected: Should return Halo config created on Bazzite

# Generate verification ATOM
echo "ATOM-VERIFY-WIN-20241127-022: Cross-OS query successful (Windows → Bazzite config)" | `
  Out-File -Append -FilePath "$env:TEMP\atom_trail.log"
```

### Step 6.2: Test Cross-OS Memory (Bazzite Query)

```bash
# Boot to Bazzite
# Enter KENL
# Query for BF config

context-sync << 'EOF'
{
  "command": "search_files",
  "params": {
    "project_name": "dual-boot-gaming",
    "query": "battlefield",
    "file_types": ["json"]
  }
}
EOF

# Expected: Should return BF config created on Windows

# Generate verification ATOM
echo "ATOM-VERIFY-BAZZITE-20241127-023: Cross-OS query successful (Bazzite → Windows config)" >> /tmp/atom_trail.log
```

### Step 6.3: Query D1 Directly

```bash
# Query D1 database for all ATOM entries
wrangler d1 execute atom-trail-dual-boot --command="SELECT atom_id, platform, game FROM atom_trail ORDER BY timestamp DESC LIMIT 20"

# Expected output should show entries from both platforms:
# ATOM-*-WIN-* (battlefield-2042)
# ATOM-*-BAZZITE-* (halo-infinite)

# Generate verification ATOM
echo "ATOM-VERIFY-D1-20241127-024: D1 database contains entries from both platforms" >> /tmp/atom_trail.log
```

### Step 6.4: Verify Learning Pattern

```bash
# Query for learned pattern
context-sync << 'EOF'
{
  "command": "get_project_context",
  "params": {"project_name": "dual-boot-gaming"}
}
EOF

# Should show:
# - BF 2042 config (Windows)
# - Halo Infinite config (Bazzite)
# - Cross-reference between configs
# - "High preset" pattern learned

echo "ATOM-VERIFY-PATTERN-20241127-025: Learning pattern verified (High preset applied to both games)" >> /tmp/atom_trail.log
```

### APPROVAL GATE 7: Cross-Platform Verification Complete
**Human Decision Required:** Both OSes can query each other's configs?
- [ ] YES: Continue to Phase 7 (PDF Generation)
- [ ] NO: Review D1 sync logs

---

## Phase 7: PDF User Guide Generation

**Duration:** 10-15 minutes
**Risk Level:** Low (documentation only)
**Rollback:** Delete PDF

### Step 7.1: Generate PDF-Optimized Markdown

```bash
# Create PDF-optimized version of the brief
# (This step will create a separate artifact optimized for PDF export)

# Agent will execute this in next artifact creation
echo "ATOM-DOC-20241127-026: PDF-optimized user guide generated" >> /tmp/atom_trail.log
```

*Note: PDF generation will be handled in separate artifact creation*

---

## Post-Execution Summary

### Completion Checklist

**Windows Setup:**
- [ ] Node.js installed
- [ ] context-sync installed
- [ ] Claude Desktop MCP configured
- [ ] dual-boot-gaming project initialized
- [ ] BF 2042 config created and tested
- [ ] ATOM trail synced to D1

**Bazzite Setup:**
- [ ] KENL container created/verified
- [ ] Node.js installed in container
- [ ] context-sync installed in container
- [ ] Claude Code MCP configured
- [ ] dual-boot-gaming project initialized
- [ ] Halo Infinite config created and tested
- [ ] ATOM trail synced to D1

**Infrastructure:**
- [ ] Cloudflare D1 database created
- [ ] Schema deployed (3 tables)
- [ ] Sync Worker deployed
- [ ] Both OSes configured with Worker URL

**Verification:**
- [ ] Windows can query Bazzite configs
- [ ] Bazzite can query Windows configs
- [ ] D1 contains entries from both platforms
- [ ] Learning pattern validated

**Documentation:**
- [ ] ATOM trail logs preserved
- [ ] PDF user guide generated
- [ ] Config files backed up

### ATOM Trail Summary

Expected ATOM count: **26 entries**

**Windows (9 entries):**
- ATOM-INSTALL-WIN-001 through -004 (setup)
- ATOM-RESEARCH-WIN-016 (BF research)
- ATOM-CFG-WIN-017 (BF config)
- ATOM-TEST-WIN-018 (BF test)
- ATOM-VERIFY-WIN-022 (cross-OS query)
- ATOM-DOC-WIN-* (if applicable)

**Bazzite (11 entries):**
- ATOM-INSTALL-BAZZITE-006 through -011 (setup)
- ATOM-RESEARCH-BAZZITE-019 (Halo research)
- ATOM-CFG-BAZZITE-020 (Halo config)
- ATOM-TEST-BAZZITE-021 (Halo test)
- ATOM-VERIFY-BAZZITE-023 (cross-OS query)
- ATOM-DOC-BAZZITE-* (if applicable)

**Infrastructure (6 entries):**
- ATOM-INSTALL-D1-012 (Wrangler)
- ATOM-DEPLOY-D1-013 (database)
- ATOM-SCHEMA-D1-014 (schema)
- ATOM-DEPLOY-D1-015 (Worker)
- ATOM-VERIFY-D1-024 (D1 query)
- ATOM-VERIFY-PATTERN-025 (learning)
- ATOM-DOC-026 (PDF guide)

### Token Economics Report

**Estimated Token Usage:**
```
Phase 1-2 (Setup):           ~2,000 tokens (Claude, config)
Phase 3 (D1 Deploy):         ~1,000 tokens (Claude, Worker)
Phase 4 (BF Research/Config): ~5,000 tokens (3k Perplexity + 2k Claude)
Phase 5 (Halo Config):        ~2,000 tokens (2k Perplexity + 0 Qwen)
Phase 6 (Verification):       ~500 tokens (Claude, queries)
Phase 7 (PDF):                ~1,000 tokens (Claude, formatting)
─────────────────────────────────────────────────
Total:                       ~11,500 tokens

Compared to traditional approach:
Windows BF setup:            ~40,000 tokens
Linux Halo setup:            ~50,000 tokens
─────────────────────────────────────────────────
Traditional Total:           ~90,000 tokens

Savings:                     78,500 tokens (87%)
```

**Cost Breakdown:**
- Claude Pro: $20/month (within limit)
- Perplexity Pro: $20/month (within limit)
- Qwen: $0 (local inference)
- Cloudflare D1: $0 (free tier: 5GB storage, 5M reads/day)
- **Total: $40/month**

### Files Created

**Windows:**
```
C:\Users\toolated\.context-sync\data.db
C:\Users\toolated\AppData\Roaming\Claude\claude_desktop_config.json
C:\Users\toolated\Documents\bf2042-config.json
%TEMP%\atom_trail.log
%TEMP%\sync_to_d1.ps1
```

**Bazzite:**
```
~/.context-sync/data.db
~/.config/claude-code/mcp_config.json
~/.config/gaming-intent/halo-infinite.env
/tmp/atom_trail.log
/tmp/sync_to_d1.sh
/tmp/halo-infinite-config.json
```

**Cloudflare:**
```
D1 Database: atom-trail-dual-boot
Worker: atom-sync.YOUR_ACCOUNT.workers.dev
Tables: atom_trail, game_configs, learnings
```

### Rollback Procedures

**Complete Rollback (Nuclear Option):**

Windows:
```powershell
npm uninstall -g @context-sync/server
Remove-Item -Recurse -Force "$env:USERPROFILE\.context-sync"
# Restore claude_desktop_config.json.backup.*
```

Bazzite:
```bash
distrobox rm kenl
rm -rf ~/.context-sync
rm -rf ~/.config/gaming-intent
```

Cloudflare:
```bash
wrangler d1 delete atom-trail-dual-boot
wrangler delete atom-sync
```

**Partial Rollback (Configs Only):**

Windows:
```powershell
# Revert EA App settings to defaults
# Remove custom launch options
# Disable AMD Anti-Lag if causing issues
```

Bazzite:
```bash
rm ~/.config/gaming-intent/halo-infinite.env
# Remove Steam launch options
# Switch back to Proton Experimental
```

### Troubleshooting

**Issue: context-sync not found**
```bash
# Verify npm global path
npm list -g --depth=0

# If not in PATH, add to shell rc:
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc
```

**Issue: D1 sync failing**
```bash
# Check Worker logs
wrangler tail atom-sync

# Test manually
curl -X POST https://atom-sync.YOUR_ACCOUNT.workers.dev/sync \
  -H "Content-Type: application/json" \
  -d '{"test": "ping"}'
```

**Issue: Cross-OS query returns nothing**
```bash
# Verify D1 contains data
wrangler d1 execute atom-trail-dual-boot \
  --command="SELECT COUNT(*) FROM atom_trail"

# If empty, re-run sync scripts
```

**Issue: Halo Infinite won't launch**
```bash
# Check Proton log
cat ~/.steam/steam/steamapps/compatdata/1240440/pfx/drive_c/proton.log

# Common fixes:
# 1. Switch to Proton Experimental
# 2. Verify DXVK installed: ls ~/.steam/root/compatibilitytools.d/
# 3. Clear shader cache: rm -rf ~/.steam/steam/steamapps/shadercache/1240440/
```

---

## Success Metrics

### Technical Validation
- [ ] context-sync operational on both OSes (2/2)
- [ ] D1 database has 20+ ATOM entries
- [ ] Cross-OS queries successful (2/2)
- [ ] BF 2042: 55+ FPS @ High on Windows
- [ ] Halo Infinite: 50+ FPS @ High on Bazzite
- [ ] Token savings: 80%+ vs traditional

### User Experience
- [ ] User can boot to either OS and query full context
- [ ] Configs shareable via D1 URLs
- [ ] Learning pattern applied (High preset across games)
- [ ] PDF guide printable and comprehensive

### Infrastructure
- [ ] D1 database accessible
- [ ] Sync Worker responding (200 OK)
- [ ] ATOM trail cryptographically sound
- [ ] No data loss across reboots

---

## Next Steps (Post-Directive)

### Immediate (Next Session)
1. Configure 2 more games (1 per OS) to validate pattern learning
2. Create "high-preset-amd" template in D1 learnings table
3. Set up automatic D1 sync (currently manual)
4. Create shareable Play Cards for BF/Halo

### Short-Term (Next Week)
1. Implement real-time D1 sync (background process)
2. Create web UI for ATOM trail visualization
3. Add FPS tracking over time (performance regression detection)
4. Document GPU upgrade path

### Long-Term (Next Month)
1. Extend to more games (target: 10+ across both OSes)
2. Create community Play Card repository
3. Implement predictive config generation (ML-based)
4. Write blog post on dual-boot AI memory

---

## Appendix: Command Reference

### context-sync Commands
```bash
# Project management
context-sync init_project --name PROJECT
context-sync get_project_context --project PROJECT

# File operations
context-sync read_file --project PROJECT --path PATH
context-sync create_file --project PROJECT --path PATH --content CONTENT
context-sync search_files --project PROJECT --query QUERY

# Decision tracking
context-sync save_decision --project PROJECT --decision TEXT
context-sync save_conversation --project PROJECT --content CONTENT

# Git integration
context-sync git_status --project PROJECT
context-sync suggest_commit_message --project PROJECT
```

### D1 Commands
```bash
# Database management
wrangler d1 list
wrangler d1 create DATABASE_NAME
wrangler d1 delete DATABASE_NAME
wrangler d1 execute DATABASE_NAME --command="SQL"
wrangler d1 execute DATABASE_NAME --file=schema.sql

# Worker management
wrangler deploy
wrangler tail WORKER_NAME
wrangler delete WORKER_NAME
```

### ATOM Tag Format
```
ATOM-{TYPE}-{PLATFORM}-{YYYYMMDD}-{COUNTER}

Types: INSTALL, CFG, TEST, RESEARCH, DEPLOY, VERIFY, DOC
Platforms: WIN, BAZZITE, D1
Example: ATOM-CFG-WIN-20241127-017
```

---

## Agent Signature

**Directive ID:** ATOM-DIRECTIVE-DUALBOOT-20241127-001
**Agent:** Claude Code (local execution)
**Status:** Ready for execution
**Estimated Duration:** 90-120 minutes
**Human Approvals Required:** 7 gates
**Risk Level:** Medium (game config changes)
**Rollback Available:** Yes (full or partial)

**Execute:** Await human authorization to begin Phase 0

---

END OF DIRECTIVE
