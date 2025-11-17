# GitHub Copilot Instructions: KENL3 Development

Module for development environments, distrobox, MCP servers, and local AI.

## Context

You are assisting with setting up isolated development environments on immutable Linux (Bazzite/Fedora Atomic) using distrobox, and integrating AI assistants (Claude Code, Ollama/Qwen) via MCP.

## Primary Tasks

1. **Create dev containers** - Distrobox/devcontainer configurations
2. **Configure MCP servers** - Model Context Protocol integration
3. **Set up local AI** - Ollama with Qwen models
4. **Generate dev workflows** - Scripts and automation
5. **Troubleshoot environments** - Container and AI issues

## Distrobox Environment Pattern

```bash
# Create Ubuntu 24.04 dev environment
distrobox create \
  --name project-dev \
  --image docker.io/library/ubuntu:24.04 \
  --home ~/distrobox/project-dev \
  --init \
  --additional-flags "--volume=/mnt:/mnt:rslave"

# Enter environment
distrobox enter project-dev

# Inside container - install KENL framework
cd ~/kenl/modules/KENL1-framework/atom-sage-framework
./install.sh

# Export app to host
distrobox-export --app code
```

## MCP Server Configuration Pattern

### KENL MCP Server (Custom)
```json
{
  "mcpServers": {
    "kenl": {
      "command": "node",
      "args": ["~/kenl/modules/KENL3-dev/mcp-servers/kenl-mcp-server/dist/index.js"],
      "env": {
        "KENL_HOME": "${HOME}/kenl",
        "ATOM_TRAIL_PATH": "${HOME}/.config/bazza-dx/atom_trail.log"
      }
    }
  }
}
```

### Cloudflare MCP
```json
{
  "mcpServers": {
    "cloudflare": {
      "command": "npx",
      "args": ["-y", "@cloudflare/mcp-server-cloudflare"],
      "env": {
        "CLOUDFLARE_API_TOKEN": "${CLOUDFLARE_API_TOKEN}",
        "CLOUDFLARE_ACCOUNT_ID": "${CLOUDFLARE_ACCOUNT_ID}"
      }
    }
  }
}
```

### GitHub MCP
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

### Filesystem MCP
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home/user/projects"],
      "env": {}
    }
  }
}
```

## Ollama Local AI Setup

```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Download Qwen models
ollama pull qwen2.5:7b        # 7B - Fast, 4GB RAM
ollama pull qwen2.5:14b       # 14B - Better, 8GB RAM
ollama pull qwen2.5-coder:7b  # 7B - Code-specialized

# Move to external storage (optional)
mv ~/.ollama/models /mnt/claude-ai/models/ollama
ln -s /mnt/claude-ai/models/ollama ~/.ollama/models

# Test
ollama run qwen2.5-coder:7b "Write a Python hello world"
```

## Devcontainer Configuration

```json
{
  "name": "KENL Development",
  "image": "ghcr.io/ublue-os/bazzite-arch:latest",
  "features": {
    "ghcr.io/devcontainers/features/common-utils:2": {},
    "ghcr.io/devcontainers/features/git:1": {},
    "ghcr.io/devcontainers/features/node:1": {
      "version": "20"
    }
  },
  "postCreateCommand": "bash .devcontainer/post-create.sh",
  "customizations": {
    "vscode": {
      "extensions": [
        "anthropics.claude-code",
        "github.copilot",
        "ms-python.python",
        "ms-vscode.cpptools"
      ],
      "settings": {
        "github.copilot.enable": {
          "*": true
        }
      }
    }
  },
  "mounts": [
    "source=${localWorkspaceFolder}/modules,target=/workspace/modules,type=bind",
    "source=/mnt,target=/mnt,type=bind,consistency=cached"
  ]
}
```

### Post-Create Script

```bash
#!/bin/bash
# .devcontainer/post-create.sh
# ATOM-DEV-20251116-001: Devcontainer initialization

# Install KENL framework
cd ~/kenl/modules/KENL1-framework/atom-sage-framework
./install.sh

# Configure ATOM trail
mkdir -p ~/.config/bazza-dx
touch ~/.config/bazza-dx/atom_trail.log

# Set up MCP servers
mkdir -p ~/.config/claude
cp ~/kenl/modules/KENL3-dev/mcp-configs/*.json ~/.config/claude/

# Install local AI (optional)
if command -v ollama &> /dev/null; then
    ollama pull qwen2.5-coder:7b
fi

echo "✅ KENL devcontainer initialized"
```

## ATOM Tags for Development

```bash
# ATOM-DEV-20251116-001: Created Python dev environment
# Intent: Isolate project dependencies from host system
# Evidence: Container running, pip install works, no conflicts

# ATOM-MCP-20251116-002: Configured Cloudflare MCP
# Intent: Enable Claude to deploy Workers directly
# Evidence: Test deployment successful to kenl-test.workers.dev

# ATOM-AI-20251116-003: Installed Qwen 2.5 Coder 7B
# Intent: Local AI for code completion, zero API costs
# Evidence: Model loaded, 1.2s avg response time
```

## Common Development Workflows

### Workflow 1: New Project Setup

```bash
# 1. Create distrobox environment
distrobox create --name myproject-dev --image ubuntu:24.04

# 2. Enter and set up
distrobox enter myproject-dev
cd ~/projects/myproject

# 3. Initialize with ATOM tracking
# ATOM-DEV-20251116-001: Initialize myproject
# Intent: Start new project with KENL framework
git init
atom LOG "DEV" "Created myproject dev environment"

# 4. Install dependencies
npm init -y  # or poetry init, cargo init, etc.
```

### Workflow 2: Claude Code with MCP

```bash
# 1. Configure MCP servers
cat > ~/.config/claude/mcp-servers.json << 'EOF'
{
  "mcpServers": {
    "kenl": { /* ... */ },
    "github": { /* ... */ },
    "filesystem": { /* ... */ }
  }
}
EOF

# 2. Start Claude Code
claude code .

# 3. Claude can now:
# - Access KENL operations via kenl MCP
# - Query GitHub repos via github MCP
# - Read/write project files via filesystem MCP
```

### Workflow 3: Ollama Local AI

```bash
# Quick code generation
ollama run qwen2.5-coder:7b "Generate Python function to parse YAML"

# Interactive session
ollama run qwen2.5-coder:7b
>>> Explain this error: [paste error]

# API usage (for IDE integration)
curl http://localhost:11434/api/generate -d '{
  "model": "qwen2.5-coder:7b",
  "prompt": "Write a Rust hello world",
  "stream": false
}'
```

## Troubleshooting Patterns

### Container Issues

**Problem:** Container can't access /mnt
```bash
# Solution: Add volume mount
distrobox create --additional-flags "--volume=/mnt:/mnt:rslave"
```

**Problem:** Exported app doesn't work
```bash
# Solution: Re-export with proper paths
distrobox-export --app code --extra-flags "--new-window"
```

### MCP Issues

**Problem:** MCP server not found
```bash
# Solution: Verify Node.js and install manually
node --version  # Should be 18+
npm install -g @cloudflare/mcp-server-cloudflare
```

**Problem:** Environment variables not loaded
```bash
# Solution: Set in shell profile
echo 'export GITHUB_TOKEN="ghp_..."' >> ~/.bashrc
source ~/.bashrc
```

### Ollama Issues

**Problem:** Model loading is slow
```bash
# Solution: Check GPU passthrough
# For NVIDIA:
distrobox create --nvidia

# For AMD:
distrobox create --additional-flags "--device=/dev/dri"
```

**Problem:** Out of memory
```bash
# Solution: Use smaller model
ollama pull qwen2.5:7b  # Instead of 14b or 32b
```

## VS Code Settings for KENL

```json
{
  "github.copilot.enable": {
    "*": true,
    "yaml": true,
    "markdown": true,
    "shellscript": true
  },
  "github.copilot.chat.codeGeneration.useInstructionFiles": true,
  "files.associations": {
    "*.just": "shellscript",
    ".gitmessage": "gitcommit",
    "*.playcard.yaml": "yaml"
  },
  "editor.rulers": [80, 120],
  "editor.formatOnSave": true,
  "[yaml]": {
    "editor.defaultFormatter": "redhat.vscode-yaml"
  },
  "[markdown]": {
    "editor.defaultFormatter": "yzhang.markdown-all-in-one"
  }
}
```

## Best Practices

1. **Isolate environments** - One container per project
2. **Track with ATOM** - Log environment creation and changes
3. **Use MCP efficiently** - Delegate to appropriate server
4. **Keep containers light** - Only install needed packages
5. **Export apps wisely** - Only GUI apps that need host integration
6. **Test AI locally first** - Use Ollama before cloud APIs

## Related Modules

- **KENL0**: System prerequisites (distrobox install)
- **KENL1**: ATOM framework integration
- **KENL4**: Monitoring dev environments
- **KENL11**: Docker compose for media servers
