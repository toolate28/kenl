# Complete Development Environment Setup
## KENL-13 i-W-i SAIF Workflow - Development Tools

**ATOM:** ATOM-DEV-20251205-001
**SAIF:** SAIF-DEV-COMPLETE-20251205-001

---

## Development Tools to Install

### 1. Zed Editor (Flatpak)

**Install:**
```bash
flatpak install flathub dev.zed.Zed
```

**Configure for KENL:**
- GitHub Copilot extension
- Rust language server
- Markdown preview
- YAML syntax highlighting

**Launch:**
```bash
flatpak run dev.zed.Zed
```

---

### 2. VS Code (Flatpak)

**Install:**
```bash
flatpak install flathub com.visualstudio.code
```

**Extensions to install:**
- GitHub Copilot
- Rust Analyzer
- YAML
- Markdown All in One
- GitLens
- Docker
- Remote - Containers (for distrobox integration)

**Launch:**
```bash
flatpak run com.visualstudio.code
```

---

### 3. GitHub Copilot CLI

**Install:**
```bash
# Via npm
npm install -g @githubnext/github-copilot-cli

# Configure with GitHub token
gh auth login
```

**Usage:**
```bash
# Ask Copilot for shell commands
?? how to find large files

# Explain a command
git?? git rebase -i HEAD~5

# Git operations
git?? commit with message
```

---

### 4. Ollama (Dedicated Distrobox)

**Create Ollama distrobox:**
```bash
distrobox create --name ollama --image fedora:latest
distrobox enter ollama

# Inside ollama distrobox:
curl -fsSL https://ollama.com/install.sh | sh
ollama serve &
ollama pull qwen2.5-coder:7b
```

**Access from main distrobox:**
```bash
# Ollama will be available at localhost:11434
export OLLAMA_ENDPOINT="http://localhost:11434"
```

---

## Flatpak Packages for Development

### Essential

```bash
# Git GUI
flatpak install flathub io.github.shiftey.Desktop

# Database tools
flatpak install flathub org.postgresql.pgAdmin

# API testing
flatpak install flathub com.getpostman.Postman

# Terminal multiplexer
flatpak install flathub org.wezfurlong.wezterm
```

### Optional

```bash
# Docker Desktop
flatpak install flathub io.podman_desktop.PodmanDesktop

# Obsidian (notes)
flatpak install flathub md.obsidian.Obsidian

# Discord (comms)
flatpak install flathub com.discordapp.Discord
```

---

## Distrobox Strategy

### Current Setup

1. **debian** (main) - General development, Claude Code
2. **ollama** (dedicated) - AI models, minimal overhead
3. **arch** (optional) - AUR packages, gaming tools
4. **ubuntu** (optional) - Ubuntu-specific testing

### Create Ollama Distrobox

```bash
distrobox create --name ollama \
  --image fedora:latest \
  --init \
  --additional-packages "curl git"

distrobox enter ollama
```

**Inside ollama distrobox:**
```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Start Ollama service
ollama serve > /tmp/ollama.log 2>&1 &

# Pull model
ollama pull qwen2.5-coder:7b

# Test
ollama run qwen2.5-coder:7b "Write a hello world in Rust"
```

---

## Interoperability Configuration

### VS Code + Distrobox

**Install VS Code Remote extension in container:**
```bash
# From main distrobox
distrobox-export --app code

# VS Code can now open projects in any distrobox
code --folder-uri vscode-remote://distrobox+ollama/home/user/project
```

### Zed + Git Integration

**Configure Zed settings:**
```json
{
  "git": {
    "git_binary_path": "/usr/bin/git"
  },
  "copilot": {
    "enabled": true
  }
}
```

### GitHub Copilot Everywhere

**Authenticate once, use everywhere:**
```bash
# In main distrobox
gh auth login

# Token is stored in ~/.config/gh/
# All distroboxes share home directory
```

---

## Development Workflow

### Scenario 1: Quick Script

```bash
# Use Zed for fast editing
flatpak run dev.zed.Zed script.sh

# Or VS Code for full IDE features
flatpak run com.visualstudio.code .
```

### Scenario 2: AI-Assisted Coding

```bash
# Start Ollama in dedicated distrobox
distrobox enter ollama
ollama serve &
exit

# Use from main environment
curl http://localhost:11434/api/generate -d '{
  "model": "qwen2.5-coder:7b",
  "prompt": "Write a Rust function to parse YAML"
}'
```

### Scenario 3: Git + Copilot

```bash
# Use GitHub Copilot CLI
?? create a git commit message for these changes

# Or use VS Code with Copilot extension
code .
```

---

## ATOM Trail Integration

```bash
# Log development activities
echo "ATOM-DEV-20251205-001: Installed Zed editor" >> ~/.kenl/.atom-trail.log
echo "ATOM-DEV-20251205-002: Configured GitHub Copilot" >> ~/.kenl/.atom-trail.log
echo "ATOM-DEV-20251205-003: Created ollama distrobox" >> ~/.kenl/.atom-trail.log
```

---

## Next Steps

1. Install Zed and VS Code
2. Configure GitHub Copilot in both
3. Create ollama distrobox
4. Test AI-assisted coding workflow
5. Document results in play card

---

**Status:** READY TO INSTALL
**SAIF:** SAIF-DEV-COMPLETE-20251205-001
