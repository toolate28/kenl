---
title: ATOM Trail Database & Archiving Architecture
date: 2025-11-14
atom: ATOM-DOC-20251114-006
classification: OWI-DOC
status: design
platform: Bazzite, Fedora Atomic, Linux
---

# ATOM Trail Database & Archiving Architecture

**Comprehensive design for ATOM trail storage, validation, querying, and security with prevention mechanisms for unauthorized changes.**

---

## Security-First Design Principle

**Critical Insight:** ATOM trails are NOT just logs - they're a security and validation layer.

### The Problem

**Current approach** (audit-only):
```yaml
# Play Card with malicious launch parameter
game: "Halo MCC"
launch_options: "rm -rf ~ && %command%"  # Malicious!
```

**User applies Play Card:**
```bash
apply-playcard halo-mcc.yaml
# ❌ Command executes immediately
# ✅ ATOM trail logs it AFTER damage is done
```

**Result:** Data loss. ATOM trail has evidence, but damage already occurred.

### The Solution

**Prevention-first approach:**

```bash
apply-playcard halo-mcc.yaml
# 1. VALIDATE Play Card against schema and safety rules
# 2. PREVIEW changes and ATOM trail entry
# 3. USER APPROVAL required before execution
# 4. EXECUTE with sandboxing
# 5. LOG to ATOM trail with success/failure
```

**ATOM becomes a three-layer system:**

1. **Prevention Layer** - Schema validation, safety checks, user approval
2. **Execution Layer** - Sandboxed operations with rollback capability
3. **Audit Layer** - Cryptographically signed logs for forensics

---

## Architecture Overview

### Three-Tier Storage Model

```
┌─────────────────────────────────────────────┐
│         Tier 1: Local SQLite                │
│  (Fast queries, analytics, ~1GB limit)      │
│     ~/.kenl/db/atom-trails.db               │
└────────────────┬────────────────────────────┘
                 │
                 │ Auto-archive after 30 days
                 ▼
┌─────────────────────────────────────────────┐
│    Tier 2: Cloudflare D1 (Sync Backup)     │
│  (Off-site redundancy, query from web)      │
│      toolated.online D1 database            │
└────────────────┬────────────────────────────┘
                 │
                 │ Long-term storage
                 ▼
┌─────────────────────────────────────────────┐
│    Tier 3: Cloudflare R2 (Archive)         │
│  (Immutable JSONL logs, unlimited size)     │
│     s3://kenl-atom-archives/2025/11/        │
└─────────────────────────────────────────────┘
```

---

## Schema Design

### ATOM Trail Entry (SQLite)

```sql
CREATE TABLE atom_trails (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    -- ATOM Tag
    tag TEXT UNIQUE NOT NULL,              -- ATOM-CFG-20251114-001
    type TEXT NOT NULL,                    -- CFG, MCP, SAGE, DEPLOY, etc.
    date TEXT NOT NULL,                    -- 2025-11-14
    sequence INTEGER NOT NULL,             -- 001

    -- Metadata
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    user TEXT NOT NULL,                    -- matthew
    hostname TEXT NOT NULL,                -- bazzite-deck
    git_commit TEXT,                       -- Current repo SHA (if in repo)

    -- Content
    description TEXT NOT NULL,             -- Human-readable intent
    command TEXT,                          -- Command executed (if any)
    file_path TEXT,                        -- File modified (if any)
    changes TEXT,                          -- Diff or JSON of changes

    -- Validation & Security
    validation_status TEXT NOT NULL,       -- pending, approved, rejected, executed
    safety_score REAL,                     -- 0.0-1.0 (AI-computed risk score)
    safety_flags TEXT,                     -- JSON array of warnings
    approved_by TEXT,                      -- User who approved (if required)
    approved_at DATETIME,

    -- Execution
    exit_code INTEGER,                     -- 0 = success, non-zero = failure
    stdout TEXT,                           -- Command output
    stderr TEXT,                           -- Error output
    duration_ms INTEGER,                   -- Execution time

    -- Rollback
    rollback_command TEXT,                 -- How to undo this operation
    rollback_successful BOOLEAN,           -- NULL if never rolled back
    rolled_back_at DATETIME,

    -- Cryptographic Integrity
    signature TEXT,                        -- Ed25519 signature of entry
    previous_hash TEXT,                    -- SHA-256 of previous entry (blockchain-style)
    hash TEXT NOT NULL                     -- SHA-256 of this entry
);

-- Indexes for performance
CREATE INDEX idx_tag ON atom_trails(tag);
CREATE INDEX idx_type ON atom_trails(type);
CREATE INDEX idx_timestamp ON atom_trails(timestamp);
CREATE INDEX idx_validation_status ON atom_trails(validation_status);
CREATE INDEX idx_user ON atom_trails(user);
```

### Play Card Validation Rules

```sql
CREATE TABLE playcard_validation_rules (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    -- Rule metadata
    rule_name TEXT UNIQUE NOT NULL,
    severity TEXT NOT NULL,                -- critical, high, medium, low
    enabled BOOLEAN DEFAULT 1,

    -- Pattern matching
    field_path TEXT NOT NULL,              -- JSON path (e.g., "launch_options")
    pattern TEXT,                          -- Regex for dangerous patterns
    forbidden_values TEXT,                 -- JSON array of banned values

    -- Actions
    action TEXT NOT NULL,                  -- reject, warn, require_approval
    message TEXT NOT NULL,                 -- User-facing explanation

    -- Metadata
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Example rules
INSERT INTO playcard_validation_rules (rule_name, severity, field_path, pattern, action, message) VALUES
('no_rm_commands', 'critical', 'launch_options', 'rm\s+-rf', 'reject', 'Launch options contain dangerous "rm -rf" command'),
('no_shell_redirect', 'high', 'launch_options', '[>;|&]', 'require_approval', 'Launch options contain shell redirection or piping'),
('no_sudo', 'critical', 'launch_options', 'sudo', 'reject', 'Launch options request elevated privileges'),
('no_curl_pipe_sh', 'critical', 'launch_options', 'curl.*\|\s*sh', 'reject', 'Launch options execute downloaded script'),
('proton_version_valid', 'medium', 'proton_version', '^(GE-Proton[0-9]+-[0-9]+|Proton-[0-9.]+)$', 'warn', 'Proton version format unrecognized');
```

---

## Prevention Layer: Validation Workflow

### Step 1: Schema Validation

```python
#!/usr/bin/env python3
# ~/.kenl/bin/validate-playcard.py

import yaml
import re
import sqlite3
from typing import Dict, List, Tuple

def validate_playcard(playcard_path: str) -> Tuple[bool, List[str]]:
    """
    Validate Play Card against safety rules.

    Returns:
        (is_safe: bool, warnings: List[str])
    """
    with open(playcard_path) as f:
        playcard = yaml.safe_load(f)

    db = sqlite3.connect(os.path.expanduser("~/.kenl/db/atom-trails.db"))
    cursor = db.cursor()

    warnings = []
    is_safe = True

    # Fetch enabled rules
    cursor.execute("SELECT * FROM playcard_validation_rules WHERE enabled = 1")
    rules = cursor.fetchall()

    for rule in rules:
        rule_name, severity, field_path, pattern, action, message = rule[1:7]

        # Get field value from Play Card (e.g., "launch_options")
        field_value = playcard.get(field_path, "")

        # Check pattern
        if pattern and re.search(pattern, field_value, re.IGNORECASE):
            warnings.append(f"[{severity.upper()}] {message}")

            if action == "reject":
                is_safe = False
            elif action == "require_approval":
                # Flag for user confirmation
                pass

    db.close()
    return is_safe, warnings

# Usage
is_safe, warnings = validate_playcard("halo-mcc.yaml")
if not is_safe:
    print("❌ REJECTED: Play Card failed validation")
    for w in warnings:
        print(f"  {w}")
    exit(1)
elif warnings:
    print("⚠️  WARNINGS detected:")
    for w in warnings:
        print(f"  {w}")
    print("\nProceed? (yes/no)")
    # ... user input handling
```

### Step 2: Safety Score (AI-Powered)

**Use local Qwen model to compute risk score:**

```bash
#!/bin/bash
# ~/.kenl/bin/compute-safety-score.sh

PLAYCARD_PATH="$1"

# Extract launch_options
LAUNCH_OPTIONS=$(yq eval '.launch_options' "$PLAYCARD_PATH")

# Ask Qwen to analyze
PROMPT="Analyze this Steam launch parameter for security risks (scale 0.0-1.0, where 1.0 is completely safe):

Launch parameter: $LAUNCH_OPTIONS

Consider:
- Shell injection risks
- File system operations
- Network operations
- Privilege escalation
- Known malicious patterns

Respond with ONLY a number between 0.0 and 1.0."

SAFETY_SCORE=$(ollama run qwen2.5-coder:7b "$PROMPT" | grep -oP '^\d+\.\d+')

echo "$SAFETY_SCORE"
```

**Store score in ATOM trail:**

```sql
UPDATE atom_trails
SET safety_score = 0.85,
    safety_flags = '["shell_redirection", "network_operation"]'
WHERE tag = 'ATOM-PLAYCARD-20251114-001';
```

### Step 3: User Approval (Interactive)

```bash
#!/bin/bash
# ~/.kenl/bin/apply-playcard.sh

PLAYCARD="$1"

# 1. Validate
echo "🔍 Validating Play Card..."
if ! validate-playcard "$PLAYCARD"; then
    echo "❌ Validation failed. Aborting."
    exit 1
fi

# 2. Compute safety score
SAFETY_SCORE=$(compute-safety-score "$PLAYCARD")
echo "🛡️  Safety Score: $SAFETY_SCORE / 1.0"

if (( $(echo "$SAFETY_SCORE < 0.7" | bc -l) )); then
    echo "⚠️  Low safety score detected!"
fi

# 3. Preview changes
echo ""
echo "📋 Preview of changes:"
yq eval '.' "$PLAYCARD"

echo ""
echo "🏷️  ATOM Trail Entry:"
echo "ATOM-PLAYCARD-$(date +%Y%m%d)-001: Applied Play Card: $(basename $PLAYCARD)"

# 4. User approval
echo ""
read -p "Apply this Play Card? (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
    echo "❌ Aborted by user"
    log-atom-trail "ATOM-PLAYCARD-$(date +%Y%m%d)-001" "rejected" "User rejected Play Card application"
    exit 1
fi

# 5. Execute (sandboxed)
echo "⚙️  Applying Play Card..."
apply-playcard-internal "$PLAYCARD"
EXIT_CODE=$?

# 6. Log to ATOM trail
log-atom-trail "ATOM-PLAYCARD-$(date +%Y%m%d)-001" "executed" "Applied Play Card: $(basename $PLAYCARD)" "$EXIT_CODE"

if [[ $EXIT_CODE -eq 0 ]]; then
    echo "✅ Play Card applied successfully"
else
    echo "❌ Play Card application failed (exit code: $EXIT_CODE)"
    echo "💡 Rollback available: undo-playcard ATOM-PLAYCARD-$(date +%Y%m%d)-001"
fi
```

---

## Execution Layer: Sandboxed Operations

### Flatpak Sandbox for Game Launch

**Problem:** `rm -rf ~` in launch options would delete user's home directory.

**Solution:** Run games in Flatpak sandbox with restricted filesystem access.

```bash
#!/bin/bash
# ~/.kenl/bin/apply-playcard-sandboxed.sh

GAME_NAME=$(yq eval '.game' "$PLAYCARD")
LAUNCH_OPTIONS=$(yq eval '.launch_options' "$PLAYCARD")

# Escape %command% placeholder
LAUNCH_CMD="${LAUNCH_OPTIONS//%command%/flatpak run com.valvesoftware.Steam}"

# Run in Flatpak sandbox (Steam Flatpak already sandboxed)
flatpak run com.valvesoftware.Steam -applaunch $GAME_ID $LAUNCH_CMD
```

**Flatpak permissions:**
```bash
# Steam Flatpak has NO access to:
# - /home (except ~/Documents, ~/Downloads via portals)
# - /etc, /usr, /var (read-only)
# - Network (except Steam servers)

# Even if launch_options contains "rm -rf ~", it only affects Flatpak's isolated home
```

### Distrobox Isolation for Scripts

```bash
#!/bin/bash
# Run untrusted scripts in throwaway Distrobox

distrobox create --name playcard-sandbox --image alpine:latest
distrobox enter playcard-sandbox -- sh -c "$UNTRUSTED_SCRIPT"
distrobox rm -f playcard-sandbox  # Destroy after execution
```

---

## Audit Layer: Cryptographic Integrity

### Blockchain-Style Hashing

**Each ATOM entry includes:**

1. **Hash of current entry** (SHA-256 of `tag + timestamp + description + command`)
2. **Hash of previous entry** (creates chain)

**Tamper detection:**

```python
def verify_atom_trail_integrity(db_path: str) -> bool:
    """
    Verify ATOM trail has not been tampered with.

    Returns True if chain is valid, False if tampered.
    """
    db = sqlite3.connect(db_path)
    cursor = db.cursor()

    cursor.execute("SELECT id, hash, previous_hash FROM atom_trails ORDER BY id")
    entries = cursor.fetchall()

    for i, (entry_id, current_hash, previous_hash) in enumerate(entries):
        # Check previous hash matches
        if i > 0:
            expected_previous = entries[i-1][1]  # Hash of previous entry
            if previous_hash != expected_previous:
                print(f"❌ Tampered: Entry {entry_id} has wrong previous_hash")
                return False

        # Recompute hash
        cursor.execute("SELECT tag, timestamp, description, command FROM atom_trails WHERE id = ?", (entry_id,))
        tag, timestamp, description, command = cursor.fetchone()
        expected_hash = hashlib.sha256(f"{tag}{timestamp}{description}{command}".encode()).hexdigest()

        if current_hash != expected_hash:
            print(f"❌ Tampered: Entry {entry_id} has wrong hash")
            return False

    print("✅ ATOM trail integrity verified")
    return True
```

### Ed25519 Signatures (Optional)

**For high-security environments:**

```bash
# Generate signing key
ssh-keygen -t ed25519 -f ~/.kenl/keys/atom-signing-key

# Sign each ATOM entry
SIGNATURE=$(echo "$ATOM_ENTRY" | ssh-keygen -Y sign -n atom-trail -f ~/.kenl/keys/atom-signing-key)
```

**Store signature in `atom_trails.signature` column.**

**Verify:**

```bash
echo "$ATOM_ENTRY" | ssh-keygen -Y verify -n atom-trail -f ~/.kenl/keys/atom-signing-key.pub -s <(echo "$SIGNATURE")
```

---

## Querying and Analytics

### CLI Tool: `kenl-atom`

```bash
#!/bin/bash
# ~/.kenl/bin/kenl-atom - Query ATOM trails

case "$1" in
    list)
        # Show recent ATOM entries
        sqlite3 ~/.kenl/db/atom-trails.db "SELECT tag, timestamp, description FROM atom_trails ORDER BY timestamp DESC LIMIT 20"
        ;;

    search)
        # Search by keyword
        KEYWORD="$2"
        sqlite3 ~/.kenl/db/atom-trails.db "SELECT tag, description FROM atom_trails WHERE description LIKE '%$KEYWORD%'"
        ;;

    show)
        # Show detailed entry
        TAG="$2"
        sqlite3 ~/.kenl/db/atom-trails.db "SELECT * FROM atom_trails WHERE tag = '$TAG'" | jq
        ;;

    rollback)
        # Execute rollback command
        TAG="$2"
        ROLLBACK_CMD=$(sqlite3 ~/.kenl/db/atom-trails.db "SELECT rollback_command FROM atom_trails WHERE tag = '$TAG'")

        if [[ -z "$ROLLBACK_CMD" ]]; then
            echo "❌ No rollback available for $TAG"
            exit 1
        fi

        echo "🔄 Rollback command: $ROLLBACK_CMD"
        read -p "Execute rollback? (yes/no): " CONFIRM

        if [[ "$CONFIRM" == "yes" ]]; then
            eval "$ROLLBACK_CMD"
            sqlite3 ~/.kenl/db/atom-trails.db "UPDATE atom_trails SET rollback_successful = 1, rolled_back_at = datetime('now') WHERE tag = '$TAG'"
            echo "✅ Rollback executed"
        fi
        ;;

    verify)
        # Check integrity
        python3 ~/.kenl/bin/verify-atom-trail.py
        ;;

    export)
        # Export to JSONL for backup
        sqlite3 ~/.kenl/db/atom-trails.db ".mode json" "SELECT * FROM atom_trails" > atom-trails-backup-$(date +%Y%m%d).json
        ;;
esac
```

### Usage Examples

```bash
# List recent entries
kenl-atom list

# Search for MangoHud config changes
kenl-atom search "MangoHud"

# Show detailed entry
kenl-atom show ATOM-CFG-20251114-001

# Rollback a change
kenl-atom rollback ATOM-CFG-20251114-002

# Verify integrity
kenl-atom verify

# Export for backup
kenl-atom export
```

---

## Grafana Dashboard Integration

### Prometheus Exporter for ATOM Metrics

```python
#!/usr/bin/env python3
# ~/.kenl/bin/atom-prometheus-exporter.py

from prometheus_client import start_http_server, Gauge, Counter
import sqlite3
import time

# Metrics
atom_entries_total = Counter('kenl_atom_entries_total', 'Total ATOM trail entries', ['type'])
atom_validation_failures = Counter('kenl_atom_validation_failures_total', 'Failed validations')
atom_rollbacks_total = Counter('kenl_atom_rollbacks_total', 'Total rollbacks executed')
atom_safety_score = Gauge('kenl_atom_safety_score', 'Latest Play Card safety score')

def collect_metrics():
    db = sqlite3.connect(os.path.expanduser("~/.kenl/db/atom-trails.db"))
    cursor = db.cursor()

    # Count entries by type
    cursor.execute("SELECT type, COUNT(*) FROM atom_trails GROUP BY type")
    for atom_type, count in cursor.fetchall():
        atom_entries_total.labels(type=atom_type).inc(count)

    # Count validation failures
    cursor.execute("SELECT COUNT(*) FROM atom_trails WHERE validation_status = 'rejected'")
    atom_validation_failures.inc(cursor.fetchone()[0])

    # Latest safety score
    cursor.execute("SELECT safety_score FROM atom_trails WHERE safety_score IS NOT NULL ORDER BY timestamp DESC LIMIT 1")
    result = cursor.fetchone()
    if result:
        atom_safety_score.set(result[0])

    db.close()

if __name__ == '__main__':
    start_http_server(9101)  # Expose on :9101/metrics
    while True:
        collect_metrics()
        time.sleep(60)  # Update every minute
```

**Grafana dashboard panels:**

1. **ATOM Entries Over Time** - Line graph by type
2. **Validation Failure Rate** - Percentage gauge
3. **Safety Score Distribution** - Histogram
4. **Top 10 Most Rolled Back Operations** - Table

---

## Backup and Archiving

### Auto-Archive to Cloudflare R2

```bash
#!/bin/bash
# ~/.kenl/bin/archive-atom-trails.sh
# Run weekly via cron

# Export ATOM trails older than 30 days
sqlite3 ~/.kenl/db/atom-trails.db <<EOF | gzip > /tmp/atom-archive-$(date +%Y%m).jsonl.gz
.mode json
SELECT * FROM atom_trails WHERE timestamp < datetime('now', '-30 days');
EOF

# Upload to Cloudflare R2
wrangler r2 object put kenl-atom-archives/$(date +%Y/%m)/atom-trails-$(date +%Y%m%d).jsonl.gz \
    --file /tmp/atom-archive-$(date +%Y%m).jsonl.gz

# Delete archived entries from local DB
sqlite3 ~/.kenl/db/atom-trails.db "DELETE FROM atom_trails WHERE timestamp < datetime('now', '-30 days')"

# Vacuum to reclaim space
sqlite3 ~/.kenl/db/atom-trails.db "VACUUM"

echo "✅ Archived and cleaned ATOM trails"
```

### Restore from Archive

```bash
#!/bin/bash
# ~/.kenl/bin/restore-atom-trails.sh

ARCHIVE_URL="$1"  # s3://kenl-atom-archives/2025/11/atom-trails-20251101.jsonl.gz

# Download from R2
wrangler r2 object get "$ARCHIVE_URL" --file /tmp/atom-restore.jsonl.gz

# Decompress and import
gunzip /tmp/atom-restore.jsonl.gz
sqlite3 ~/.kenl/db/atom-trails.db ".mode json" ".import /tmp/atom-restore.jsonl atom_trails"

echo "✅ Restored ATOM trails from archive"
```

---

## Security Summary

### Prevention Mechanisms

| Layer | Mechanism | Example |
|-------|-----------|---------|
| **Schema Validation** | Regex pattern matching | Reject `rm -rf` in launch options |
| **AI Safety Scoring** | Qwen-powered risk analysis | Flag suspicious shell redirects |
| **User Approval** | Interactive confirmation | Preview changes before execution |
| **Sandboxing** | Flatpak/Distrobox isolation | Limit filesystem access |
| **Cryptographic Integrity** | SHA-256 chaining + signatures | Detect tampered logs |
| **Rollback Safety** | Automatic rollback commands | Undo changes within seconds |

### Attack Scenarios Mitigated

1. **Malicious Play Card:** Rejected during validation (pattern matching)
2. **Tampered ATOM Trail:** Detected by hash chain verification
3. **Unauthorized Config Change:** Logged with user approval requirement
4. **Data Exfiltration:** Sandboxed execution limits network access
5. **Privilege Escalation:** Sudo commands flagged and rejected

---

## ATOM Trail

```
ATOM-DOC-20251114-006: Designed ATOM trail database architecture with security validation
Intent: Transform ATOM trails from audit-only logs to prevention+audit+rollback system
Validation: Schema supports validation rules, safety scoring, and rollback commands
Rollback: N/A (design document only)
Next: Implement SQLite database schema and validation CLI tools
```

---

**Last Updated**: 2025-11-14
**Status**: Design (Implementation pending)
**Dependencies**: SQLite, Cloudflare Wrangler, Ollama (for safety scoring)
