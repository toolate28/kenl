-- ATOM Trails Table (Cloudflare D1)
-- Syncs with local ~/.kenl/db/atom-trails.db
-- ATOM: ATOM-SCHEMA-20251116-001

CREATE TABLE IF NOT EXISTS atom_trails (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    -- ATOM Tag Components
    tag TEXT UNIQUE NOT NULL,              -- ATOM-CFG-20251114-001
    type TEXT NOT NULL,                    -- CFG, MCP, SAGE, DEPLOY, PLAYCARD
    date TEXT NOT NULL,                    -- 2025-11-14
    sequence INTEGER NOT NULL,             -- 001

    -- Metadata
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    user TEXT NOT NULL,                    -- matthew
    hostname TEXT NOT NULL,                -- bazzite-deck
    git_commit TEXT,                       -- Current repo SHA

    -- Content
    description TEXT NOT NULL,             -- Human-readable intent
    command TEXT,                          -- Command executed
    file_path TEXT,                        -- File modified
    changes TEXT,                          -- Diff or JSON of changes

    -- Validation & Security
    validation_status TEXT NOT NULL,       -- pending, approved, rejected, executed
    safety_score REAL,                     -- 0.0-1.0 (AI-computed)
    safety_flags TEXT,                     -- JSON array of warnings
    approved_by TEXT,                      -- User who approved
    approved_at DATETIME,

    -- Execution
    exit_code INTEGER,                     -- 0 = success
    stdout TEXT,                           -- Command output
    stderr TEXT,                           -- Error output
    duration_ms INTEGER,                   -- Execution time

    -- Rollback
    rollback_command TEXT,                 -- How to undo
    rollback_successful BOOLEAN,           -- NULL if never rolled back
    rolled_back_at DATETIME,

    -- Cryptographic Integrity
    signature TEXT,                        -- Ed25519 signature
    previous_hash TEXT,                    -- SHA-256 of previous entry (blockchain-style)
    hash TEXT NOT NULL                     -- SHA-256 of this entry
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_atom_tag ON atom_trails(tag);
CREATE INDEX IF NOT EXISTS idx_atom_type ON atom_trails(type);
CREATE INDEX IF NOT EXISTS idx_atom_timestamp ON atom_trails(timestamp);
CREATE INDEX IF NOT EXISTS idx_atom_validation_status ON atom_trails(validation_status);
CREATE INDEX IF NOT EXISTS idx_atom_user ON atom_trails(user);
CREATE INDEX IF NOT EXISTS idx_atom_date ON atom_trails(date);

-- View: Recent entries (last 100)
CREATE VIEW IF NOT EXISTS v_recent_atom_trails AS
SELECT
    tag,
    type,
    timestamp,
    description,
    validation_status,
    exit_code
FROM atom_trails
ORDER BY timestamp DESC
LIMIT 100;

-- View: Failed operations (for debugging)
CREATE VIEW IF NOT EXISTS v_failed_operations AS
SELECT
    tag,
    timestamp,
    description,
    command,
    exit_code,
    stderr
FROM atom_trails
WHERE exit_code IS NOT NULL AND exit_code != 0
ORDER BY timestamp DESC;
