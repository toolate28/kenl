-- Users Table for KENL Web Interface
-- ATOM: ATOM-SCHEMA-20251116-003

CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    -- Identity
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    display_name TEXT,

    -- Authentication
    password_hash TEXT,                    -- bcrypt hash (for local auth)
    oauth_provider TEXT,                   -- github, google, discord
    oauth_id TEXT,                         -- External OAuth ID

    -- Authorization
    role TEXT NOT NULL DEFAULT 'user',     -- admin, contributor, user
    api_token TEXT UNIQUE,                 -- For API access
    api_token_expires DATETIME,

    -- Profile
    avatar_url TEXT,
    bio TEXT,
    website TEXT,

    -- Preferences
    theme TEXT DEFAULT 'dark',             -- dark, light, auto
    timezone TEXT DEFAULT 'UTC',
    language TEXT DEFAULT 'en',

    -- Metadata
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_login DATETIME,

    -- Status
    active BOOLEAN DEFAULT 1,
    email_verified BOOLEAN DEFAULT 0,
    banned BOOLEAN DEFAULT 0,
    ban_reason TEXT
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_user_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_user_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_user_api_token ON users(api_token);
CREATE INDEX IF NOT EXISTS idx_user_oauth ON users(oauth_provider, oauth_id);
CREATE INDEX IF NOT EXISTS idx_user_active ON users(active);

-- View: Active users
CREATE VIEW IF NOT EXISTS v_active_users AS
SELECT
    id,
    username,
    email,
    display_name,
    role,
    created_at,
    last_login
FROM users
WHERE active = 1 AND banned = 0
ORDER BY created_at DESC;
