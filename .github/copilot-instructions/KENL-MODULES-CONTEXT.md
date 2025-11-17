# GitHub Copilot Module-Specific Context

This directory contains module-specific instructions for GitHub Copilot to provide better, context-aware suggestions when working with different parts of the KENL framework.

## ATOM Tag Pattern (All Modules)

```bash
# ATOM-{TYPE}-{YYYYMMDD}-{NNN}: Brief description
# Intent: Why this change is being made
# Evidence: Supporting data or benchmarks (if applicable)
<actual code>
```

**Common Types:** CFG, GAMING, DEPLOY, RESEARCH, TEST, FIX, FEATURE, DOC

## Module-Specific Patterns

### KENL2 (Gaming) - Play Card Structure

```yaml
---
title: "Game Name - Hardware Config"
game: game-slug
hardware:
  cpu: "CPU Model"
  gpu: "GPU Model"
  ram: "RAM Amount"
performance:
  avg_fps: 60
  min_fps: 45
  max_fps: 75
proton: "GE-Proton9-20"
launch_options: "PROTON_USE_WINED3D=1 %command%"
atom_tag: ATOM-PLAYCARD-20251116-001
---
```

### KENL1 (Framework) - ATOM Logging

```bash
# Log an ATOM event
atom LOG "CFG" "Updated system configuration for gaming performance"

# With intent documentation
# ATOM-CFG-20251116-001: Set CPU governor to performance mode
# Intent: Maximize FPS by preventing CPU throttling during gaming
# Evidence: +12 FPS improvement in BF6 (106 → 118 FPS)
sudo cpupower frequency-set -g performance
```

### KENL3 (Dev) - MCP Server Configuration

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

### KENL8 (Security) - GPG Operations

```bash
# ATOM-SEC-20251116-001: Encrypt sensitive Play Card for sharing
# Intent: Share gaming config without exposing API keys
gpg --encrypt --recipient user@example.com play-card.yaml

# Always verify encryption before sharing
gpg --list-packets play-card.yaml.gpg
```

## Best Practices

1. **User-space only**: Never modify /usr, /etc, /var
2. **ATOM tags mandatory**: All significant changes must be tagged
3. **Document intent**: Explain WHY, not just WHAT
4. **Rollback procedures**: Include undo instructions
5. **Test before commit**: Validate changes work as expected

## GitHub Copilot Usage

When working with KENL code:
- Copilot will suggest ATOM tags automatically
- Context from module READMEs informs suggestions
- Security-sensitive operations get extra scrutiny
- Generated code follows KENL conventions
