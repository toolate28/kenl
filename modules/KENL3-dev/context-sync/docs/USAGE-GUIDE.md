# Context-Sync Usage Guide

**Quick reference for common context-sync workflows in KENL**

> **Note:** This is Phase 1 implementation. ATOM bridge scripts (`atom-bridge/`) and advanced integrations are planned for Phase 2. Current guide focuses on core context-sync usage via MCP server.

---

## Quick Start Checklist

- [ ] Installed context-sync: `./scripts/setup-context-sync.sh`
- [ ] Restarted Claude Code to load MCP server
- [ ] Verified installation: `context-sync --version`
- [ ] Initialized first project

---

## Common Workflows

### 1. Save an Architectural Decision

**When to use:** After making important technical choices

```bash
# Using context-sync CLI
context-sync << 'EOF'
{
  "command": "save_decision",
  "params": {
    "title": "Use PostgreSQL over MySQL",
    "reason": "Better JSON support, KENL requires complex data structures"
  }
}
EOF

# Tag with ATOM for traceability (Phase 2 - coming soon)
# cd ~/kenl/modules/KENL3-dev/context-sync
# ./atom-bridge/sync-atom-trail.sh --decision "Use PostgreSQL"

# For now, manually log ATOM tag:
echo "ATOM-DECISION-$(date +%Y%m%d)-001: Use PostgreSQL over MySQL" >> ~/.kenl/atom-trail.log
```

**Result:** Decision stored in `~/.context-sync/data.db`, retrievable in future chats. ATOM tag logged for audit trail.

---

### 2. Query Project Context

**When to use:** Starting new chat, need to remember where you left off

```bash
# Get full project summary
context-sync << 'EOF'
{
  "command": "get_project_context",
  "params": {
    "project_name": "bazza-dx"
  }
}
EOF
```

**Output includes:**
- Tech stack decisions
- Architecture choices
- Recent file changes
- Conversation summaries

---

### 3. Search Across Conversations

**When to use:** "What did we decide about X?"

```bash
# Search for keyword
context-sync << 'EOF'
{
  "command": "search_content",
  "params": {
    "query": "database choice"
  }
}
EOF
```

---

### 4. Track File Changes

**When to use:** Want AI to remember what files you're working on

```bash
# context-sync auto-tracks via MCP when Claude Code uses filesystem
# Manual tracking:
context-sync << 'EOF'
{
  "command": "track_file",
  "params": {
    "file_path": "src/database.ts",
    "reason": "Main database connection logic"
  }
}
EOF
```

---

### 5. Git Integration

**When to use:** Get commit message suggestions based on changes

```bash
# Get git status through context-sync
context-sync << 'EOF'
{
  "command": "git_status",
  "params": {
    "workspace": "~/projects/bazza-dx"
  }
}
EOF

# Get suggested commit message
context-sync << 'EOF'
{
  "command": "suggest_commit_message",
  "params": {
    "workspace": "~/projects/bazza-dx"
  }
}
EOF
```

---

### 6. Cross-Agent Coordination (Phase 2 - Planned)

**When to use:** Using multiple AI tools (Claude + Cursor + Copilot)

> **Note:** ATOM bridge scripts coming in Phase 2. For now, context-sync works with any MCP-compatible AI agent via the same SQLite database.

```bash
# Current approach: All agents share same context-sync database
# Each agent accesses ~/.context-sync/data.db via MCP

# Phase 2 will add:
# ./atom-bridge/query-context-sync.sh --agent "claude-code" --limit 10
# ./atom-bridge/query-context-sync.sh --show-influenced-by
```

---

### 7. Export to Cloudflare D1 (Phase 2 - Planned)

**When to use:** Want cloud persistence, multi-device sync

> **Note:** Cloud backup integration coming in Phase 2.

```bash
# Phase 2 will add:
# export CLOUDFLARE_API_TOKEN="your-token"
# export CLOUDFLARE_ACCOUNT_ID="your-account-id"
# cd ~/kenl/modules/KENL3-dev/context-sync
# ./atom-bridge/export-to-d1.sh --all
```

---

### 8. Gaming Configuration Memory

**When to use:** Creating Play Cards, troubleshooting game launches

```bash
# Save gaming decision
context-sync << 'EOF'
{
  "command": "save_decision",
  "params": {
    "title": "HALO Infinite requires GE-Proton 9-20",
    "reason": "EA App auth + BattlEye anti-cheat compatibility"
  }
}
EOF

# Later: "How did I fix HALO?"
context-sync << 'EOF'
{
  "command": "search_content",
  "params": {
    "query": "HALO Infinite"
  }
}
EOF
```

---

## Usage Patterns

### Pattern 1: New Project Setup

```bash
# 1. Initialize project
context-sync init_project --name "my-new-game"

# 2. Document initial decisions
context-sync save_decision \
  --title "Unity vs Unreal" \
  --reason "Unity for rapid prototyping"

# 3. Set workspace
context-sync set_workspace --path "~/projects/my-new-game"

# 4. Start development (Claude Code auto-tracks from here)
claude code ~/projects/my-new-game
```

### Pattern 2: Resume After Break

```bash
# What was I working on?
context-sync get_project_context --project "bazza-dx"

# What files did I change?
context-sync git_status --workspace "~/projects/bazza-dx"

# What decisions did I make?
context-sync search_content --query "decision" --limit 5
```

### Pattern 3: Handoff to Another Developer

```bash
# Export context for sharing
context-sync export_project --project "bazza-dx" --output "project-context.json"

# Other developer imports
context-sync import_project --input "project-context.json"
```

---

## Integration with KENL Modules

### With KENL1 (ATOM Framework)

Every context-sync operation can be tagged:

```bash
# Save decision with ATOM tag
context-sync save_decision --title "..." --reason "..."
./atom-bridge/sync-atom-trail.sh --last-decision

# Result: ATOM-DECISION-YYYYMMDD-NNN in both systems
```

### With KENL2 (Gaming)

Track Play Card creation decisions:

```bash
# Document why this configuration works
context-sync save_decision \
  --title "BF6 needs DXVK 2.3" \
  --reason "Shader compilation hang on 2.4"

# Reference in Play Card YAML
atom_decision: ATOM-DECISION-20241204-005
```

### With KENL4 (Monitoring)

Dashboards can query context-sync:

```bash
# Export metrics
./atom-bridge/query-context-sync.sh --json | \
  jq '.[] | {date, operation, agent}' > /tmp/context-metrics.json

# Feed to Grafana via D1
./atom-bridge/export-to-d1.sh --metrics-only
```

---

## Tips & Tricks

### Tip 1: Use context-sync in Scripts

```bash
#!/usr/bin/env bash
# Automated decision logging

DECISION="Use Rust for performance-critical code"
REASON="10x faster than Python for game logic"

context-sync << EOF
{
  "command": "save_decision",
  "params": {
    "title": "$DECISION",
    "reason": "$REASON"
  }
}
EOF
```

### Tip 2: Query Before Asking AI

Before asking Claude "How do I X?", query context-sync first:

```bash
# You might have already solved this!
context-sync search_content --query "authentication"
```

### Tip 3: Cross-Project Learning

```bash
# Find patterns across all projects
context-sync << 'EOF'
{
  "command": "search_content",
  "params": {
    "query": "database migration",
    "all_projects": true
  }
}
EOF
```

---

## Troubleshooting

> **Note:** `TROUBLESHOOTING.md` is planned for Phase 2 and does not yet exist. Basic troubleshooting tips are provided below.

**Common Issues & Solutions**

- **context-sync not found:**  
  Ensure you ran `./scripts/setup-context-sync.sh` and your `$PATH` includes `~/.local/bin`.

- **MCP server not responding:**  
  Restart Claude Code and verify MCP server is running (`ps aux | grep mcp-server`).

- **Project not initializing:**  
  Check for typos in your initialization command and ensure your working directory is writable.
---

**Next Steps:**
- **ATOM Integration (Phase 2):** The ATOM audit trail integration guide (`ATOM-INTEGRATION.md`) is planned for Phase 2. For now, refer to the [../README.md](../README.md) for a summary of ATOM methodology and audit trail concepts. All context-sync operations are logged with ATOM tags for traceability; see comments in your ADRs and commit messages for examples.
- Explore [../README.md](../README.md) for architecture overview
- Join KENL community for tips and Play Card sharing
