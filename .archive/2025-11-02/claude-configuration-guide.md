# Bazza-DX Claude Configuration Guide

**ATOM-CFG-20251102-006**

## Claude Desktop Configuration

**Location:** `~/.config/Claude/claude_desktop_config.json` (Linux)

```json
{
  "mcpServers": {
    "cloudflare": {
      "command": "npx",
      "args": ["-y", "@cloudflare/mcp-server-cloudflare"],
      "env": {
        "CLOUDFLARE_API_TOKEN": "YOUR_API_TOKEN_HERE",
        "CLOUDFLARE_ACCOUNT_ID": "3ddeb355f4954bb1ee4f9486b2908e7e"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/home/YOUR_USERNAME/.config/bazza-dx",
        "/home/YOUR_USERNAME/.config/gaming-intent",
        "/home/YOUR_USERNAME/projects"
      ]
    },
    "git": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-git",
        "--repository",
        "/home/YOUR_USERNAME/projects/bazza-dx"
      ]
    }
  },
  "globalShortcut": "CommandOrControl+Shift+Space"
}
```

**Setup:**
```bash
# Create config directory
mkdir -p ~/.config/Claude

# Copy config (replace YOUR_USERNAME with actual username)
cat > ~/.config/Claude/claude_desktop_config.json << 'EOF'
[paste JSON above]
EOF

# Replace placeholders
sed -i "s/YOUR_USERNAME/$USER/g" ~/.config/Claude/claude_desktop_config.json
sed -i "s/YOUR_API_TOKEN_HERE/$CLOUDFLARE_API_TOKEN/g" ~/.config/Claude/claude_desktop_config.json

# Restart Claude Desktop
killall claude-desktop 2>/dev/null
claude-desktop &
```

---

## Claude.ai Web Project Configuration

**Location:** Project Settings → Custom Instructions

### Project Name
```
Bazza-DX: Gaming & Development Ecosystem
```

### Custom Instructions

```markdown
# Project Context: Bazza-DX

## Overview
Australian-themed gaming/dev ecosystem built on Bazzite-DX (Fedora Atomic). Emphasizes immutability, SAGE methodology, and MCP-orchestrated infrastructure.

## Core Principles
- **Immutable base**: rpm-ostree, never modify system
- **User-space focus**: distrobox containers, ~/.config
- **ATOM traceability**: Every operation tagged
- **Token efficiency**: Qwen local (60%), Perplexity (30%), Claude (10%)
- **SAGE methodology**: Evidence-based, rollback-safe operations

## Terminology
- **ATOM tags**: `ATOM-{TYPE}-{YYYYMMDD}-{COUNTER}` (replaces REF-tags)
- **KENL**: Kubernetes ENvironment Layer (distrobox dev container)
- **Play Cards**: Gaming config JSON schemas
- **SAGE**: System-Aware Guided Evolution methodology

## Technical Stack
- **OS**: Bazzite-DX (Fedora 43, KDE Plasma 6.4.5)
- **Hardware**: Ryzen 5 5600H, AMD Radeon, 16GB RAM
- **Containers**: distrobox (KENL), podman
- **Domains**: toolated.online (Cloudflare)
- **AI**: Claude (complex), Qwen 7B (local simple), Perplexity (research)

## Directory Structure
```
~/.config/bazza-dx/          # Core configs
~/.config/gaming-intent/     # Gaming profiles, Play Cards
~/projects/bazza-dx/         # Main repo
~/projects/kenl/             # Dev container
```

## Response Style
- Concise, direct (Australian vernacular welcome)
- Code-first (artifacts, scripts, configs)
- ATOM-tagged operations
- Token-conscious (suggest Qwen for simple tasks)
- Actionable (no "I can help with that" fluff)

## Task Priorities
1. CLAUDE.md activation file (blocking KENL)
2. D1 ATOM database deployment
3. Justfile creation
4. Gaming config framework testing

## Available MCP Servers
- Cloudflare (Workers, KV, D1, R2)
- Filesystem (read local configs)
- Git (repo operations)

## Guard Rails
- Never suggest base system modifications
- Always validate ATOM tag format
- Confirm destructive operations
- Provide rollback procedures
- Token budget: Estimate complexity before suggesting Claude vs Qwen
```

---

## Claude Code (KENL Container) Configuration

**Location:** `~/projects/kenl/.claude/config.json`

```json
{
  "project": "Bazza-DX KENL Development",
  "context": {
    "directories": [
      "~/.config/bazza-dx",
      "~/.config/gaming-intent",
      "~/projects/bazza-dx"
    ],
    "files": [
      "~/.config/bazza-dx/CLAUDE.md",
      "~/projects/bazza-dx/Justfile"
    ]
  },
  "preferences": {
    "token_budget": "conservative",
    "local_first": true,
    "atom_tagging": true
  },
  "tools": {
    "qwen_threshold": "repetitive_generation",
    "perplexity_threshold": "research_required",
    "claude_threshold": "complex_reasoning"
  }
}
```

**Setup:**
```bash
# Create KENL project directory
mkdir -p ~/projects/kenl/.claude

# Create config
cat > ~/projects/kenl/.claude/config.json << 'EOF'
[paste JSON above]
EOF
```

---

## Environment Variables

**Location:** `~/.config/bazza-dx/env.sh`

```bash
# Bazza-DX Environment Configuration
# Source: source ~/.config/bazza-dx/env.sh

# Cloudflare
export CLOUDFLARE_API_TOKEN="your_api_token"
export CLOUDFLARE_ACCOUNT_ID="3ddeb355f4954bb1ee4f9486b2908e7e"

# ATOM Configuration
export ATOM_COUNTER_FILE="/tmp/atom_counter"
export ATOM_AUDIT_LOG="/tmp/atom_trail.log"
export ATOM_D1_ENDPOINT="https://atom-registry.toolated.workers.dev"

# MCP Servers
export MCP_FILESYSTEM_ROOTS="$HOME/.config/bazza-dx:$HOME/.config/gaming-intent:$HOME/projects"

# Token Optimization
export QWEN_MODEL="qwen2.5:7b"
export QWEN_ENDPOINT="http://localhost:11434"

# Project Paths
export BAZZADX_ROOT="$HOME/projects/bazza-dx"
export GAMING_CONFIG="$HOME/.config/gaming-intent"
export KENL_ROOT="$HOME/projects/kenl"
```

**Setup:**
```bash
# Create env file
mkdir -p ~/.config/bazza-dx
cat > ~/.config/bazza-dx/env.sh << 'EOF'
[paste bash above]
EOF

# Add to shell profile
echo "source ~/.config/bazza-dx/env.sh" >> ~/.zshrc
source ~/.zshrc
```

---

## Verification

```bash
# Test Claude Desktop MCP
ls ~/.config/Claude/claude_desktop_config.json

# Test environment
source ~/.config/bazza-dx/env.sh
echo $CLOUDFLARE_ACCOUNT_ID

# Test Qwen availability
curl http://localhost:11434/api/version

# Generate test ATOM
mkdir -p /tmp
echo "0" > /tmp/atom_counter
date +%Y%m%d > /tmp/atom_date
echo "ATOM-TEST-$(cat /tmp/atom_date)-001"
```

---

## Quick Reference

| Tool | When to Use | Config Location |
|------|-------------|-----------------|
| Claude Desktop | Local development, file operations | `~/.config/Claude/` |
| Claude.ai | Web research, long sessions | Project settings |
| Claude Code | KENL container coding | `~/projects/kenl/.claude/` |
| Qwen | Config generation, validation | Ollama service |
| Perplexity | Documentation research | MCP server |

---

**Installation Order:**
1. Environment variables (`env.sh`)
2. Claude Desktop config (MCP servers)
3. Claude.ai project (Custom Instructions)
4. Claude Code (KENL container setup)
5. Verify all tools accessible

**Total Setup Time:** ~15 minutes
