---
title: Model Context Protocol (MCP) Integration Guide for KENL
date: 2025-11-14
atom: ATOM-DOC-20251114-005
classification: OWI-DOC
status: production
platform: Linux, macOS, Windows
---

# Model Context Protocol (MCP) Integration Guide for KENL

**Complete guide to integrating Claude with KENL tools, Cloudflare services, and custom MCP servers using the Model Context Protocol.**

---

## What is MCP?

**Model Context Protocol** is a standardized way for AI models (like Claude) to interact with external tools and data sources. Think of it as a plugin system for AI.

**Key benefits for KENL:**
- ✅ **Claude can read/write files** - Edit Play Cards, update ATOM trails, modify configs
- ✅ **Cloudflare integration** - Manage Workers, KV, D1, R2 directly from Claude
- ✅ **Custom tools** - Expose KENL functions (rpm-ostree, ujust recipes) to Claude
- ✅ **Standardized protocol** - JSON-RPC over stdio, works across platforms
- ✅ **Security** - Explicit tool permissions, sandboxed execution

**Architecture:**

```
┌──────────────┐
│ Claude Code  │
│  (Claude AI) │
└──────┬───────┘
       │
       │ JSON-RPC over stdio
       │
┌──────▼───────────────────────────────────────┐
│          MCP Servers (Node.js)               │
├──────────────┬────────────────┬──────────────┤
│  Filesystem  │   Cloudflare   │ KENL Custom  │
│   (read/     │   (Workers,    │  (ujust,     │
│    write)    │    KV, D1)     │   rpm-ostree)│
└──────────────┴────────────────┴──────────────┘
```

---

## Prerequisites

### 1. Node.js (v18+)

```bash
# Check version
node --version  # Should be v18 or higher

# If not installed (Bazzite/Fedora):
# Option A: Distrobox (recommended)
distrobox create --name nodejs-dev --image docker.io/library/node:20
distrobox enter nodejs-dev

# Option B: rpm-ostree layer (modifies immutable system)
sudo rpm-ostree install nodejs
sudo systemctl reboot
```

### 2. Claude Desktop or Claude Code

**Claude Desktop:**
- Download from https://claude.ai/download
- macOS, Windows, Linux (AppImage)

**Claude Code:**
- VS Code extension (currently in beta)
- Install from VS Code marketplace

### 3. Git

```bash
git --version  # Should be installed on Bazzite by default
```

---

## MCP Server Installation

### Built-in Servers (Official Anthropic)

#### 1. Filesystem Server

**Allows Claude to read/write files in specific directories.**

```bash
# Install globally
npm install -g @modelcontextprotocol/server-filesystem

# Test
npx @modelcontextprotocol/server-filesystem /home/user/kenl
```

**Configure in Claude Desktop** (`~/.config/Claude/claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "filesystem-kenl": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/home/user/kenl"
      ]
    }
  }
}
```

**What Claude can do:**
- ✅ Read Play Cards: `read_file("/home/user/kenl/modules/KENL2-gaming/play-cards/halo-mcc.yaml")`
- ✅ Update ATOM trails: `write_file("/home/user/.kenl/logs/atom-trail.log", "ATOM-...")`
- ✅ Edit configs: `edit_file("/home/user/.kenl/config.yaml", ...)`

**Security:**
- Claude can ONLY access `/home/user/kenl` directory
- No access to `~/.ssh`, `~/.gnupg`, or system files
- Always review file changes before approving

#### 2. GitHub Server

**Allows Claude to create issues, PRs, search code, etc.**

```bash
npm install -g @modelcontextprotocol/server-github

# Get GitHub token
# 1. Go to https://github.com/settings/tokens
# 2. Generate new token (classic) with: repo, read:org scopes
# 3. Save token securely
```

**Configure:**

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "ghp_YOUR_TOKEN_HERE"
      }
    }
  }
}
```

**⚠️ Security:** Store token in environment variable, not config file:

```bash
# Add to ~/.bashrc or ~/.zshrc
export GITHUB_TOKEN="ghp_YOUR_TOKEN_HERE"
```

**What Claude can do:**
- ✅ Create GitHub issues
- ✅ Search KENL codebase
- ✅ Create PRs for Play Cards
- ✅ Read issue comments

#### 3. Brave Search Server (Web Research)

**Enables Claude to search the web (alternative to Perplexity).**

```bash
npm install -g @modelcontextprotocol/server-brave-search

# Get API key from https://brave.com/search/api/
```

**Configure:**

```json
{
  "mcpServers": {
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "BSA_YOUR_KEY_HERE"
      }
    }
  }
}
```

**What Claude can do:**
- ✅ Search for ProtonDB reports
- ✅ Find Bazzite documentation
- ✅ Look up AMD GPU optimization guides
- ✅ Research game compatibility issues

### Third-Party Servers

#### 4. Cloudflare MCP Server (KENL-Specific)

**Manage Cloudflare Workers, KV, D1, R2 for Play Card sharing and ATOM trail backups.**

**Installation:**

```bash
# Clone Cloudflare MCP server (community project)
git clone https://github.com/cloudflare/mcp-server-cloudflare.git ~/.kenl/mcp-servers/cloudflare
cd ~/.kenl/mcp-servers/cloudflare
npm install

# Get Cloudflare API token
# 1. Go to https://dash.cloudflare.com/profile/api-tokens
# 2. Create token with: Workers Scripts (Edit), Workers KV (Edit), D1 (Edit)
```

**Configure:**

```json
{
  "mcpServers": {
    "cloudflare": {
      "command": "node",
      "args": ["/home/user/.kenl/mcp-servers/cloudflare/dist/index.js"],
      "env": {
        "CLOUDFLARE_API_TOKEN": "YOUR_TOKEN",
        "CLOUDFLARE_ACCOUNT_ID": "YOUR_ACCOUNT_ID"
      }
    }
  }
}
```

**What Claude can do:**
- ✅ Upload Play Cards to Cloudflare KV
- ✅ Deploy Workers for Play Card API
- ✅ Backup ATOM trails to Cloudflare R2
- ✅ Query D1 database for gaming stats

**Example workflow:**

```
User: "Upload my Halo MCC Play Card to Cloudflare KV"
Claude:
  1. Reads play-cards/halo-mcc.yaml (filesystem MCP)
  2. Uploads to KV namespace "kenl-play-cards" (Cloudflare MCP)
  3. Returns public URL: https://toolated.online/play-cards/halo-mcc
```

#### 5. Ollama Server (Local AI Delegation)

**Allow Claude to delegate simple tasks to local Qwen models.**

```bash
npm install -g @modelcontextprotocol/server-ollama
```

**Configure:**

```json
{
  "mcpServers": {
    "ollama": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-ollama"],
      "env": {
        "OLLAMA_HOST": "http://localhost:11434"
      }
    }
  }
}
```

**What Claude can do:**
- ✅ Offload code generation to Qwen (saves API costs)
- ✅ Generate documentation with local AI
- ✅ Quick refactoring via Qwen
- ✅ Escalate complex tasks back to Claude

**Token cost savings:**

```
Without Ollama MCP:
  10 code generation tasks × 500 tokens = 5,000 tokens (~$0.015)

With Ollama MCP:
  10 code generation tasks × 100 tokens (Claude routing) = 1,000 tokens (~$0.003)
  Qwen handles actual generation (free)

Savings: 80% reduction in API costs for simple tasks
```

---

## Custom KENL MCP Server

### Create a Custom Server for KENL Operations

**Goal:** Let Claude run `ujust` recipes, check `rpm-ostree` status, and execute KENL functions.

**Create `/home/user/.kenl/mcp-servers/kenl-server/index.js`:**

```javascript
#!/usr/bin/env node
// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2025 KENL Project

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { CallToolRequestSchema, ListToolsRequestSchema } from "@modelcontextprotocol/sdk/types.js";
import { exec } from "child_process";
import { promisify } from "util";

const execAsync = promisify(exec);

const server = new Server({
  name: "kenl-server",
  version: "1.0.0"
}, {
  capabilities: {
    tools: {}
  }
});

// Define KENL tools
server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    {
      name: "rpm-ostree-status",
      description: "Check current rpm-ostree deployment and rollback options",
      inputSchema: {
        type: "object",
        properties: {}
      }
    },
    {
      name: "ujust-list",
      description: "List available ujust recipes",
      inputSchema: {
        type: "object",
        properties: {}
      }
    },
    {
      name: "atom-trail-append",
      description: "Append ATOM tag to trail log",
      inputSchema: {
        type: "object",
        properties: {
          tag: { type: "string", description: "ATOM tag (e.g., ATOM-CFG-20251114-001)" },
          description: { type: "string", description: "Human-readable description" }
        },
        required: ["tag", "description"]
      }
    },
    {
      name: "test-kenlnetwork",
      description: "Run Test-KenlNetwork PowerShell function to check latency",
      inputSchema: {
        type: "object",
        properties: {}
      }
    }
  ]
}));

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case "rpm-ostree-status": {
        const { stdout } = await execAsync("rpm-ostree status");
        return { content: [{ type: "text", text: stdout }] };
      }

      case "ujust-list": {
        const { stdout } = await execAsync("just --list --justfile /usr/share/ublue-os/justfile");
        return { content: [{ type: "text", text: stdout }] };
      }

      case "atom-trail-append": {
        const { tag, description } = args;
        const logEntry = `${tag}: ${description}\n`;
        const logPath = `${process.env.HOME}/.kenl/logs/atom-trail.log`;

        await execAsync(`mkdir -p ${process.env.HOME}/.kenl/logs`);
        await execAsync(`echo "${logEntry}" >> ${logPath}`);

        return { content: [{ type: "text", text: `Appended to ATOM trail: ${tag}` }] };
      }

      case "test-kenlnetwork": {
        const { stdout } = await execAsync(
          'pwsh -Command "Import-Module ~/.kenl/modules/KENL0-system/powershell/KENL.Network.psm1; Test-KenlNetwork"'
        );
        return { content: [{ type: "text", text: stdout }] };
      }

      default:
        return { content: [{ type: "text", text: `Unknown tool: ${name}` }], isError: true };
    }
  } catch (error) {
    return { content: [{ type: "text", text: `Error: ${error.message}` }], isError: true };
  }
});

// Start server
const transport = new StdioServerTransport();
await server.connect(transport);
```

**Install dependencies:**

```bash
cd ~/.kenl/mcp-servers/kenl-server
npm init -y
npm install @modelcontextprotocol/sdk
chmod +x index.js
```

**Configure in Claude Desktop:**

```json
{
  "mcpServers": {
    "kenl": {
      "command": "node",
      "args": ["/home/user/.kenl/mcp-servers/kenl-server/index.js"]
    }
  }
}
```

**What Claude can now do:**

```
User: "Check my rpm-ostree status and tell me if I can rollback"
Claude: [Uses rpm-ostree-status tool] "You're on Fedora 39.20241110, can rollback to 39.20241103"

User: "List available ujust recipes"
Claude: [Uses ujust-list tool] "Available recipes: bios-update, distrobox-assemble, ..."

User: "Log that I installed MangoHud"
Claude: [Uses atom-trail-append] "Logged: ATOM-CFG-20251114-001: Installed MangoHud"

User: "Test my network latency"
Claude: [Uses test-kenlnetwork tool] "Average latency: 6.2ms (EXCELLENT)"
```

**ATOM Trail:**
```bash
echo "ATOM-MCP-$(date +%Y%m%d)-001: Created custom KENL MCP server with ujust, rpm-ostree, and ATOM trail integration" >> ~/.kenl/logs/atom-trail.log
```

---

## Configuration Best Practices

### 1. Use Environment Variables for Secrets

**❌ Bad (secrets in config file):**
```json
{
  "mcpServers": {
    "github": {
      "env": {
        "GITHUB_TOKEN": "ghp_mysecrettoken123"
      }
    }
  }
}
```

**✅ Good (secrets in environment):**
```bash
# Add to ~/.bashrc
export GITHUB_TOKEN="ghp_mysecrettoken123"
export CLOUDFLARE_API_TOKEN="abc123"
```

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"]
      // Token read from $GITHUB_TOKEN automatically
    }
  }
}
```

### 2. Limit Filesystem Access

**❌ Bad (overly broad access):**
```json
{
  "mcpServers": {
    "filesystem": {
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home/user"]
    }
  }
}
```

**✅ Good (scoped to KENL directory):**
```json
{
  "mcpServers": {
    "filesystem-kenl": {
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home/user/kenl"]
    },
    "filesystem-playcards": {
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home/user/.kenl/playcards"]
    }
  }
}
```

### 3. Test MCP Servers Independently

```bash
# Test server manually (before adding to Claude)
npx @modelcontextprotocol/server-filesystem /home/user/kenl

# Should print:
# MCP Server running on stdio
# (Ctrl+C to exit)
```

### 4. Reload Claude Desktop After Config Changes

```bash
# Kill Claude Desktop
pkill -f "Claude"

# Restart
claude &

# Check logs for MCP errors
tail -f ~/.config/Claude/logs/mcp*.log
```

---

## Troubleshooting

### Issue: MCP server not showing in Claude

**Check:**
1. Config file syntax: `cat ~/.config/Claude/claude_desktop_config.json | jq` (should not error)
2. Server path exists: `ls -la /home/user/.kenl/mcp-servers/kenl-server/index.js`
3. Node.js installed: `node --version`
4. Claude Desktop restarted after config change

**Debug:**
```bash
# Test server directly
node /home/user/.kenl/mcp-servers/kenl-server/index.js

# Check Claude logs
tail -f ~/.config/Claude/logs/*.log | grep -i mcp
```

### Issue: Permission denied errors

**Cause:** MCP server trying to access restricted files.

**Fix:**
```bash
# Ensure KENL directory is readable
chmod -R u+rw /home/user/kenl

# For system commands, grant sudo access
sudo visudo
# Add: your-username ALL=(ALL) NOPASSWD: /usr/bin/rpm-ostree
```

**⚠️ Security:** Only grant passwordless sudo to specific commands, not ALL.

### Issue: Cloudflare MCP "Invalid API token"

**Check:**
1. Token has correct permissions: Workers (Edit), KV (Edit)
2. Account ID matches: `wrangler whoami`
3. Environment variable exported: `echo $CLOUDFLARE_API_TOKEN`

### Issue: High latency with MCP tools

**Cause:** Claude calling MCP tool for every file operation.

**Optimization:**
- Use `read_multiple_files` instead of multiple `read_file` calls
- Cache frequently-accessed data in MCP server
- Batch operations where possible

---

## Example Workflows

### 1. Create and Share a Play Card

```
User: "I just got Halo MCC working on ProtonGE 9-20. Create a Play Card and upload it."

Claude workflow:
  1. Uses filesystem MCP: Read template from play-cards/template.yaml
  2. Generates Play Card YAML with user's settings
  3. Uses filesystem MCP: Write to play-cards/halo-mcc.yaml
  4. Uses GitHub MCP: Create PR to kenl repository
  5. Uses Cloudflare MCP: Upload to KV namespace "kenl-play-cards"
  6. Uses KENL MCP: Log ATOM trail entry
  7. Returns: "Play Card created, PR #42 opened, live at https://toolated.online/play-cards/halo-mcc"
```

### 2. System Health Check

```
User: "Check my system health and network performance"

Claude workflow:
  1. Uses KENL MCP: rpm-ostree-status (check for updates)
  2. Uses KENL MCP: test-kenlnetwork (latency test)
  3. Uses filesystem MCP: Read /var/log/messages (recent errors)
  4. Uses KENL MCP: atom-trail-append (log health check)
  5. Returns: Formatted report with recommendations
```

### 3. Automated Documentation

```
User: "Document my recent gaming session with BF6"

Claude workflow:
  1. Uses filesystem MCP: Read ~/.kenl/logs/gaming-session-*.log
  2. Uses Ollama MCP: Generate summary with Qwen (cheap)
  3. Uses filesystem MCP: Create play-cards/bf6-session-*.yaml
  4. Uses KENL MCP: atom-trail-append (log session)
  5. Returns: "Session documented, Play Card created"
```

---

## Security Considerations

### 1. Principle of Least Privilege

**Only grant MCP servers the minimum permissions needed:**

```json
// ❌ Bad: Full filesystem access
{"filesystem": {"args": ["/"]}}

// ✅ Good: Scoped to KENL
{"filesystem-kenl": {"args": ["/home/user/kenl"]}}
```

### 2. Audit ATOM Trails

**MCP tool calls should generate ATOM entries:**

```bash
tail -f ~/.kenl/logs/atom-trail.log

# Should show:
# ATOM-MCP-20251114-001: Claude uploaded halo-mcc.yaml to Cloudflare KV
# ATOM-MCP-20251114-002: Claude created GitHub PR #42 for Play Card
```

### 3. Review Before Execution

**For destructive operations, Claude should ask first:**

```
Claude: "I'll run 'rpm-ostree rebase fedora:40' to upgrade. Proceed? (yes/no)"
User: "yes"
Claude: [Executes, logs ATOM trail]
```

### 4. Sandboxing

**Run MCP servers in Distrobox for isolation:**

```bash
# Create MCP container
distrobox create --name mcp-servers --image node:20

# Enter and install servers
distrobox enter mcp-servers
npm install -g @modelcontextprotocol/server-*

# Configure Claude to use container
{
  "mcpServers": {
    "filesystem": {
      "command": "distrobox-enter",
      "args": ["mcp-servers", "--", "npx", "@modelcontextprotocol/server-filesystem", "/home/user/kenl"]
    }
  }
}
```

---

## Resources

### Official Documentation
- **MCP Spec**: https://modelcontextprotocol.io/
- **MCP SDK**: https://github.com/anthropics/mcp
- **Example Servers**: https://github.com/modelcontextprotocol/servers

### Community
- **r/ClaudeAI**: https://www.reddit.com/r/ClaudeAI/
- **MCP Discord**: https://discord.gg/anthropic

---

## ATOM Trail

```
ATOM-DOC-20251114-005: Created comprehensive MCP integration guide for KENL
Intent: Enable Claude integration with Cloudflare, GitHub, and custom KENL tooling
Validation: Tested with Claude Desktop + filesystem/GitHub/Ollama MCP servers
Rollback: Remove ~/.config/Claude/claude_desktop_config.json
Next: Implement Cloudflare MCP for Play Card sharing at toolated.online
```

---

**Last Updated**: 2025-11-14
**Tested With**: Claude Desktop 1.2.0, MCP SDK 0.5.0
**Platform**: Bazzite KDE (Fedora Atomic 39), macOS, Windows 11
