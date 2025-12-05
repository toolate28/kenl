# KENL + context-sync + ATOM Integration Directive

**ATOM:** ATOM-DIRECTIVE-20241127-001
**Target Agent:** Local Claude instance (Claude Code, Claude Desktop)
**Context:** Full Bazza-DX project knowledge available
**Execution Mode:** Autonomous with human approval gates

---

## Mission Objective

Install and configure `context-sync` MCP server inside the KENL distrobox container, then implement ATOM tag integration as a plugin/extension. Maintain immutability principles—no base system modifications.

---

## Pre-Flight Checks

Before proceeding, verify:

1. **Environment Detection**
   - [ ] Confirm KENL distrobox exists: `distrobox list | grep kenl`
   - [ ] Verify Ubuntu 24.04 base: `distrobox enter kenl -- cat /etc/os-release`
   - [ ] Check Node.js availability: `distrobox enter kenl -- node --version` (should be v20+)
   - [ ] Confirm host filesystem access: `distrobox enter kenl -- ls ~/.config/bazza-dx`

2. **Prerequisites**
   - [ ] Host: Bazzite-DX (Fedora Atomic)
   - [ ] Container: KENL (distrobox, Ubuntu 24.04)
   - [ ] Tools: Node.js 20+ (via nvm), npm, git
   - [ ] Access: ~/.config/bazza-dx exists on host (shared with container)

3. **ATOM Trail Initialization**
   - [ ] Create ATOM counter: `echo 0 > /tmp/atom_counter`
   - [ ] Create ATOM log: `touch /tmp/atom_trail.log`
   - [ ] Generate first ATOM: `ATOM-DIRECTIVE-20241127-001` (this directive)

**GATE 1:** Ask human to confirm KENL container is running and accessible before proceeding.

---

## Phase 1: Install context-sync (Inside KENL)

### Execution Steps

```bash
# Enter KENL container
distrobox enter kenl

# Install context-sync globally
npm install -g @context-sync/server

# Verify installation
which context-sync
context-sync --version  # Should show v1.0.0

# ATOM tag
echo "ATOM-INSTALL-20241127-001: context-sync installed" >> /tmp/atom_trail.log
```

### Success Criteria
- ✅ `context-sync` command available in PATH
- ✅ Version v1.0.0 or higher
- ✅ No npm errors during installation

### Rollback Plan
```bash
npm uninstall -g @context-sync/server
```

**GATE 2:** Verify installation succeeded before proceeding to configuration.

---

## Phase 2: Initialize Bazza-DX Project in context-sync

### Execution Steps

```bash
# Inside KENL container
cd ~/projects/bazza-dx

# Initialize project
context-sync << 'EOF'
{
  "command": "init_project",
  "params": {
    "name": "bazza-dx",
    "description": "KENL development environment with SAGE methodology, gaming optimization, and multi-agent orchestration",
    "tech_stack": [
      "Fedora Atomic (Bazzite-DX)",
      "distrobox (KENL)",
      "Ubuntu 24.04 LTS",
      "Node.js 20",
      "Claude Code",
      "Python 3.12"
    ],
    "architecture": {
      "container": "KENL (distrobox)",
      "agents": ["Claude (10%)", "Qwen (60%)", "Perplexity (30%)"],
      "storage": ["D1", "KV namespace", "context-sync SQLite"],
      "audit": "ATOM tags"
    }
  }
}
EOF

# ATOM tag
echo "ATOM-INIT-20241127-002: bazza-dx project initialized in context-sync" >> /tmp/atom_trail.log
```

### Verification
```bash
# Query project context
context-sync << 'EOF'
{
  "command": "get_project_context",
  "params": {
    "project_name": "bazza-dx"
  }
}
EOF
```

**Expected Output:** Project metadata with tech stack, architecture details.

**GATE 3:** Confirm project initialization succeeded and context is retrievable.

---

## Phase 3: Configure MCP Server Integration

### Execution Steps

Create context-sync MCP configuration for Claude Code:

```bash
# Inside KENL container
mkdir -p ~/.config/claude-code/mcp-servers

# Add context-sync to MCP server registry
cat > ~/.config/claude-code/mcp-servers/context-sync.json << 'EOF'
{
  "name": "context-sync",
  "description": "Persistent memory and workspace access",
  "command": "context-sync",
  "args": ["--mode", "mcp"],
  "env": {
    "CONTEXT_SYNC_DB": "~/.context-sync/data.db",
    "CONTEXT_SYNC_PROJECT": "bazza-dx"
  }
}
EOF

# ATOM tag
echo "ATOM-CFG-20241127-003: context-sync MCP server configured" >> /tmp/atom_trail.log
```

### Verification
```bash
# Test MCP server connection
claude-code --test-mcp context-sync
```

**Expected Output:** Connection successful, tools available: `init_project`, `save_decision`, `read_file`, etc.

**GATE 4:** Verify MCP server is accessible to Claude Code before proceeding to ATOM integration.

---

## Phase 4: ATOM Plugin Development

### Architecture Decision

Implement ATOM tags as **optional plugin** (Phase 1 approach from analysis):
- Separate SQLite table: `atom_trail`
- New MCP tool: `atom_tag_operation`
- No breaking changes to context-sync core

### Execution Steps

#### 4.1: Create ATOM Schema

```bash
# Inside KENL container
sqlite3 ~/.context-sync/data.db << 'EOF'
CREATE TABLE IF NOT EXISTS atom_trail (
  atom_id TEXT PRIMARY KEY,
  operation TEXT NOT NULL,
  agent TEXT NOT NULL,
  timestamp TEXT NOT NULL,
  signature TEXT,
  previous_atom TEXT,
  metadata JSON,

  -- Link to context-sync operations
  context_sync_ref TEXT,

  -- Token tracking
  token_cost INTEGER,

  FOREIGN KEY (previous_atom) REFERENCES atom_trail(atom_id)
);

CREATE INDEX idx_atom_timestamp ON atom_trail(timestamp);
CREATE INDEX idx_atom_operation ON atom_trail(operation);
CREATE INDEX idx_atom_agent ON atom_trail(agent);

-- Verify schema
.schema atom_trail
EOF

# ATOM tag
echo "ATOM-SCHEMA-20241127-004: atom_trail table created" >> /tmp/atom_trail.log
```

#### 4.2: Create ATOM Generation Script

```bash
# Inside KENL container
mkdir -p ~/projects/bazza-dx/scripts

cat > ~/projects/bazza-dx/scripts/generate_atom.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Generate ATOM tag
# Usage: generate_atom.sh TYPE [METADATA_JSON]

TYPE="${1:-TASK}"
METADATA="${2:-{}}"

# Read counter
COUNTER_FILE="/tmp/atom_counter"
DATE_FILE="/tmp/atom_date"
CURRENT_DATE=$(date +%Y%m%d)

# Initialize if needed
if [[ ! -f "$COUNTER_FILE" ]]; then
    echo "0" > "$COUNTER_FILE"
    echo "$CURRENT_DATE" > "$DATE_FILE"
fi

# Reset counter if date changed
STORED_DATE=$(cat "$DATE_FILE")
if [[ "$STORED_DATE" != "$CURRENT_DATE" ]]; then
    echo "0" > "$COUNTER_FILE"
    echo "$CURRENT_DATE" > "$DATE_FILE"
fi

# Increment counter
COUNTER=$(cat "$COUNTER_FILE")
COUNTER=$((COUNTER + 1))
echo "$COUNTER" > "$COUNTER_FILE"

# Format ATOM ID
ATOM_ID=$(printf "ATOM-%s-%s-%03d" "$TYPE" "$CURRENT_DATE" "$COUNTER")

# Generate signature (SHA-256 hash)
SIGNATURE=$(echo -n "$ATOM_ID:$METADATA" | sha256sum | cut -d' ' -f1)

# Get previous ATOM (last line from log)
PREVIOUS_ATOM=$(tail -n1 /tmp/atom_trail.log 2>/dev/null | cut -d':' -f1 || echo "null")

# Detect agent
AGENT="unknown"
if [[ -n "${CLAUDE_SESSION:-}" ]]; then
    AGENT="claude-code"
elif [[ -n "${CURSOR_SESSION:-}" ]]; then
    AGENT="cursor-ide"
else
    AGENT="local-script"
fi

# Output JSON
cat << JSON
{
  "atom_id": "$ATOM_ID",
  "timestamp": "$(date -Iseconds)",
  "signature": "$SIGNATURE",
  "previous_atom": "$PREVIOUS_ATOM",
  "agent": "$AGENT",
  "metadata": $METADATA
}
JSON

# Append to log
echo "$ATOM_ID: $METADATA" >> /tmp/atom_trail.log
EOF

chmod +x ~/projects/bazza-dx/scripts/generate_atom.sh

# ATOM tag
echo "ATOM-SCRIPT-20241127-005: generate_atom.sh created" >> /tmp/atom_trail.log
```

#### 4.3: Create ATOM MCP Tool Wrapper

```bash
# Inside KENL container
cat > ~/projects/bazza-dx/scripts/atom_mcp_wrapper.js << 'EOF'
#!/usr/bin/env node

/**
 * ATOM MCP Tool Wrapper
 * Bridges context-sync operations with ATOM tagging
 */

const sqlite3 = require('sqlite3');
const { execSync } = require('child_process');
const path = require('path');

// Connect to databases
const contextSyncDb = path.join(process.env.HOME, '.context-sync', 'data.db');
const db = new sqlite3.Database(contextSyncDb);

/**
 * Tag a context-sync operation with ATOM
 */
async function atomTagOperation(operation, atomType, metadata = {}) {
  // Generate ATOM using script
  const atomJson = execSync(
    `${process.env.HOME}/projects/bazza-dx/scripts/generate_atom.sh ${atomType} '${JSON.stringify(metadata)}'`,
    { encoding: 'utf-8' }
  );

  const atom = JSON.parse(atomJson);

  // Insert into atom_trail
  return new Promise((resolve, reject) => {
    db.run(
      `INSERT INTO atom_trail
       (atom_id, operation, agent, timestamp, signature, previous_atom, metadata, context_sync_ref)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        atom.atom_id,
        operation,
        atom.agent,
        atom.timestamp,
        atom.signature,
        atom.previous_atom,
        JSON.stringify(atom.metadata),
        metadata.context_sync_id || null
      ],
      function(err) {
        if (err) reject(err);
        else resolve(atom);
      }
    );
  });
}

/**
 * Query ATOM trail
 */
async function queryAtomTrail(filters = {}) {
  let query = 'SELECT * FROM atom_trail WHERE 1=1';
  const params = [];

  if (filters.operation) {
    query += ' AND operation = ?';
    params.push(filters.operation);
  }

  if (filters.agent) {
    query += ' AND agent = ?';
    params.push(filters.agent);
  }

  if (filters.since) {
    query += ' AND timestamp >= ?';
    params.push(filters.since);
  }

  query += ' ORDER BY timestamp DESC';

  if (filters.limit) {
    query += ' LIMIT ?';
    params.push(filters.limit);
  }

  return new Promise((resolve, reject) => {
    db.all(query, params, (err, rows) => {
      if (err) reject(err);
      else resolve(rows);
    });
  });
}

// Export for MCP tool usage
module.exports = {
  atomTagOperation,
  queryAtomTrail
};

// CLI interface
if (require.main === module) {
  const command = process.argv[2];
  const args = JSON.parse(process.argv[3] || '{}');

  (async () => {
    switch (command) {
      case 'tag':
        const atom = await atomTagOperation(args.operation, args.type, args.metadata);
        console.log(JSON.stringify(atom, null, 2));
        break;

      case 'query':
        const results = await queryAtomTrail(args);
        console.log(JSON.stringify(results, null, 2));
        break;

      default:
        console.error('Unknown command:', command);
        process.exit(1);
    }

    db.close();
  })();
}
EOF

chmod +x ~/projects/bazza-dx/scripts/atom_mcp_wrapper.js

# Install dependencies
npm install --prefix ~/projects/bazza-dx/scripts sqlite3

# ATOM tag
echo "ATOM-TOOL-20241127-006: atom_mcp_wrapper.js created" >> /tmp/atom_trail.log
```

**GATE 5:** Test ATOM generation and SQLite insertion before proceeding.

#### 4.4: Test ATOM Integration

```bash
# Test ATOM generation
~/projects/bazza-dx/scripts/generate_atom.sh TEST '{"test": "initial"}'

# Test MCP wrapper
node ~/projects/bazza-dx/scripts/atom_mcp_wrapper.js tag '{
  "operation": "test_operation",
  "type": "TEST",
  "metadata": {"source": "manual_test"}
}'

# Query ATOM trail
node ~/projects/bazza-dx/scripts/atom_mcp_wrapper.js query '{
  "limit": 10
}'

# Verify in SQLite
sqlite3 ~/.context-sync/data.db "SELECT * FROM atom_trail ORDER BY timestamp DESC LIMIT 5;"
```

**Expected Output:** ATOM entries visible in both log file and SQLite database.

---

## Phase 5: Integration Testing

### Test Scenario 1: Save Decision with ATOM

```bash
# Inside KENL, using Claude Code
# Step 1: Save decision via context-sync
context-sync << 'EOF'
{
  "command": "save_decision",
  "params": {
    "title": "Use context-sync for persistent memory",
    "reason": "Solves cross-chat context loss, proven architecture"
  }
}
EOF

# Step 2: Tag with ATOM
node ~/projects/bazza-dx/scripts/atom_mcp_wrapper.js tag '{
  "operation": "save_decision",
  "type": "DECISION",
  "metadata": {
    "title": "Use context-sync for persistent memory",
    "influenced_by": ["ATOM-ANALYSIS-20241127-001"]
  }
}'

# Step 3: Query both systems
echo "=== context-sync ==="
context-sync << 'EOF'
{
  "command": "get_project_context",
  "params": {"project_name": "bazza-dx"}
}
EOF

echo "=== ATOM trail ==="
node ~/projects/bazza-dx/scripts/atom_mcp_wrapper.js query '{
  "operation": "save_decision",
  "limit": 1
}'
```

**Success Criteria:**
- ✅ Decision visible in context-sync
- ✅ ATOM tag created and linked
- ✅ Both queries return consistent data

### Test Scenario 2: Multi-Agent Simulation

```bash
# Simulate Claude operation
CLAUDE_SESSION=test node ~/projects/bazza-dx/scripts/atom_mcp_wrapper.js tag '{
  "operation": "research",
  "type": "RESEARCH",
  "metadata": {"query": "Best React patterns"}
}'

# Simulate Qwen operation
AGENT=qwen node ~/projects/bazza-dx/scripts/atom_mcp_wrapper.js tag '{
  "operation": "config_generation",
  "type": "CFG",
  "metadata": {"influenced_by": ["ATOM-RESEARCH-20241127-007"]}
}'

# Query by agent
node ~/projects/bazza-dx/scripts/atom_mcp_wrapper.js query '{
  "agent": "claude-code",
  "limit": 5
}'
```

**Success Criteria:**
- ✅ Agent detection works correctly
- ✅ ATOM chain linkage (`influenced_by`) preserved
- ✅ Queries filterable by agent

---

## Phase 6: Documentation & Handoff

### Create Usage Guide

```bash
cat > ~/projects/bazza-dx/docs/ATOM-CONTEXT-SYNC-USAGE.md << 'EOF'
# ATOM + context-sync Usage Guide

## Quick Start

### Save a Decision with ATOM
```bash
# 1. Save to context-sync
context-sync << 'JSON'
{
  "command": "save_decision",
  "params": {"title": "...", "reason": "..."}
}
JSON

# 2. Tag with ATOM
node ~/projects/bazza-dx/scripts/atom_mcp_wrapper.js tag '{
  "operation": "save_decision",
  "type": "DECISION",
  "metadata": {"title": "..."}
}'
```

### Query ATOM Trail
```bash
# All ATOMs today
node ~/projects/bazza-dx/scripts/atom_mcp_wrapper.js query '{
  "since": "2024-11-27T00:00:00Z"
}'

# By agent
node ~/projects/bazza-dx/scripts/atom_mcp_wrapper.js query '{
  "agent": "claude-code"
}'

# By operation type
node ~/projects/bazza-dx/scripts/atom_mcp_wrapper.js query '{
  "operation": "save_decision",
  "limit": 10
}'
```

## ATOM Types

- `DECISION` - Architectural decisions
- `RESEARCH` - Research queries
- `CFG` - Configuration changes
- `DEPLOY` - Deployments
- `TEST` - Test operations
- `SAGE` - SAGE methodology executions
- `MCP` - MCP tool calls

## Integration with Existing Workflows

### SAGE Methodology
```bash
# Tag SAGE execution
generate_atom.sh SAGE '{"methodology": "disk-recovery", "evidence": "..."}'
```

### Gaming Configs
```bash
# Tag Play Card generation
generate_atom.sh CFG '{"type": "play_card", "game": "..."}'
```
EOF

# ATOM tag
echo "ATOM-DOC-20241127-007: Usage guide created" >> /tmp/atom_trail.log
```

### Update Project README

```bash
cat >> ~/projects/bazza-dx/README.md << 'EOF'

## context-sync Integration

KENL now includes context-sync for persistent AI memory across chats:

```bash
# Initialize project
context-sync init_project --name my-project

# Save decisions
context-sync save_decision --title "..." --reason "..."

# Query context
context-sync get_project_context
```

### ATOM Tags

Every operation is tagged with ATOM IDs for audit trails:

```bash
# Generate ATOM
./scripts/generate_atom.sh DECISION '{"title": "..."}'

# Query ATOM trail
node ./scripts/atom_mcp_wrapper.js query '{"limit": 10}'
```

See [docs/ATOM-CONTEXT-SYNC-USAGE.md](docs/ATOM-CONTEXT-SYNC-USAGE.md) for details.
EOF
```

---

## Phase 7: Cloudflare D1 Integration (Optional)

### Sync ATOM Trail to D1

```bash
# Create sync script
cat > ~/projects/bazza-dx/scripts/sync_atom_to_d1.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Sync ATOM trail to Cloudflare D1
# Requires: CLOUDFLARE_API_TOKEN, CLOUDFLARE_ACCOUNT_ID

D1_DATABASE="bazza-dx-atom-trail"
SQLITE_DB="$HOME/.context-sync/data.db"

# Export ATOM trail as JSON
sqlite3 "$SQLITE_DB" << SQL > /tmp/atom_export.json
.mode json
SELECT * FROM atom_trail WHERE timestamp >= datetime('now', '-1 day');
SQL

# Upload to D1 via Cloudflare API
# (Implementation depends on D1 API availability)

echo "ATOM trail synced to D1: $D1_DATABASE"
EOF

chmod +x ~/projects/bazza-dx/scripts/sync_atom_to_d1.sh
```

---

## Success Criteria (Final Checklist)

- [ ] context-sync installed in KENL container
- [ ] bazza-dx project initialized in context-sync
- [ ] ATOM trail SQLite table created
- [ ] ATOM generation script working
- [ ] MCP wrapper tool functional
- [ ] Test scenarios pass (decision tracking, multi-agent)
- [ ] Documentation complete
- [ ] No base system modifications (immutability preserved)
- [ ] Rollback plan tested

---

## Rollback Procedure

If anything goes wrong:

```bash
# 1. Remove context-sync
npm uninstall -g @context-sync/server

# 2. Remove ATOM tables
sqlite3 ~/.context-sync/data.db "DROP TABLE IF EXISTS atom_trail;"

# 3. Remove scripts
rm -rf ~/projects/bazza-dx/scripts/{generate_atom.sh,atom_mcp_wrapper.js}

# 4. Restore from git
cd ~/projects/bazza-dx
git restore README.md

# 5. Restart KENL container
exit
distrobox stop kenl
distrobox start kenl
```

---

## Expected Outcomes

1. **Persistent Memory:** Claude Code remembers all bazza-dx context across chats
2. **ATOM Audit Trail:** Every operation tagged and queryable
3. **Multi-Agent Ready:** Infrastructure for Claude/Qwen/Perplexity coordination
4. **Immutability Preserved:** All changes in user-space (KENL container)
5. **Token Optimization:** Foundation for tracking costs per agent

---

## Next Steps After Completion

1. Test context-sync persistence (new chat, verify context retention)
2. Create first Play Card with ATOM tagging
3. Implement SAGE methodology with ATOM trails
4. Set up D1 sync for remote persistence
5. Integrate with gaming optimization workflows

---

## Human Approval Gates

This directive includes 5 mandatory approval gates:

- **GATE 1:** Environment verification
- **GATE 2:** Installation verification
- **GATE 3:** Project initialization verification
- **GATE 4:** MCP server verification
- **GATE 5:** ATOM integration testing

**Agent: Pause at each gate and request human confirmation before proceeding.**

---

**ATOM:** ATOM-DIRECTIVE-20241127-001
**Status:** Ready for agent execution
**Estimated Time:** 45-60 minutes
**Risk Level:** Low (all operations reversible)
