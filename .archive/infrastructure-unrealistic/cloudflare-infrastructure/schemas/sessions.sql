-- Sessions Table for User Sessions
-- ATOM: ATOM-SCHEMA-20251116-004

CREATE TABLE IF NOT EXISTS sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    -- Session identity
    session_token TEXT UNIQUE NOT NULL,    -- Random token (UUID v4)
    user_id INTEGER NOT NULL,              -- Foreign key to users table

    -- Session metadata
    ip_address TEXT,
    user_agent TEXT,
    device_type TEXT,                      -- desktop, mobile, tablet

    -- Lifecycle
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME NOT NULL,          -- TTL: 24 hours default
    last_activity DATETIME DEFAULT CURRENT_TIMESTAMP,

    -- Security
    revoked BOOLEAN DEFAULT 0,
    revoked_at DATETIME,
    revoke_reason TEXT,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_session_token ON sessions(session_token);
CREATE INDEX IF NOT EXISTS idx_session_user_id ON sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_session_expires ON sessions(expires_at);
CREATE INDEX IF NOT EXISTS idx_session_revoked ON sessions(revoked);

-- View: Active sessions
CREATE VIEW IF NOT EXISTS v_active_sessions AS
SELECT
    s.session_token,
    s.user_id,
    u.username,
    s.ip_address,
    s.created_at,
    s.expires_at,
    s.last_activity
FROM sessions s
JOIN users u ON s.user_id = u.id
WHERE s.revoked = 0 AND s.expires_at > CURRENT_TIMESTAMP
ORDER BY s.last_activity DESC;
