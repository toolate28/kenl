-- Play Card Validation Rules Table
-- Security patterns to prevent malicious Play Cards
-- ATOM: ATOM-SCHEMA-20251116-002

CREATE TABLE IF NOT EXISTS playcard_validation_rules (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    -- Rule metadata
    rule_name TEXT UNIQUE NOT NULL,
    severity TEXT NOT NULL,                -- critical, high, medium, low
    enabled BOOLEAN DEFAULT 1,
    category TEXT NOT NULL,                -- command_injection, file_system, network, privilege

    -- Pattern matching
    field_path TEXT NOT NULL,              -- JSON path (e.g., "launch_options")
    pattern TEXT,                          -- Regex for dangerous patterns
    forbidden_values TEXT,                 -- JSON array of banned values

    -- Actions
    action TEXT NOT NULL,                  -- reject, warn, require_approval
    message TEXT NOT NULL,                 -- User-facing explanation
    remediation TEXT,                      -- How to fix the issue

    -- Metadata
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_rule_severity ON playcard_validation_rules(severity);
CREATE INDEX IF NOT EXISTS idx_rule_enabled ON playcard_validation_rules(enabled);
CREATE INDEX IF NOT EXISTS idx_rule_category ON playcard_validation_rules(category);

-- Pre-populate with essential security rules
INSERT OR IGNORE INTO playcard_validation_rules
(rule_name, severity, category, field_path, pattern, action, message, remediation)
VALUES
('no_rm_rf_commands', 'critical', 'file_system', 'launch_options', 'rm\s+-r[fF]', 'reject',
 'Launch options contain dangerous "rm -rf" command',
 'Remove the rm -rf command from launch_options'),

('no_shell_redirect', 'high', 'command_injection', 'launch_options', '[>;|&]', 'require_approval',
 'Launch options contain shell redirection or piping',
 'Review the command to ensure it is safe'),

('no_sudo', 'critical', 'privilege', 'launch_options', 'sudo', 'reject',
 'Launch options request elevated privileges',
 'Remove sudo from launch_options - games should not require root'),

('no_curl_pipe_sh', 'critical', 'command_injection', 'launch_options', 'curl.*\|\s*sh', 'reject',
 'Launch options execute downloaded script',
 'Download and review scripts manually instead of piping to shell'),

('no_dd_command', 'critical', 'file_system', 'launch_options', '\bdd\s+', 'reject',
 'Launch options contain dangerous disk write command (dd)',
 'Remove dd command - it can overwrite disks'),

('no_mkfs', 'critical', 'file_system', 'launch_options', 'mkfs', 'reject',
 'Launch options attempt to format a filesystem',
 'Remove mkfs command'),

('no_chmod_777', 'medium', 'file_system', 'launch_options', 'chmod\s+777', 'warn',
 'Launch options set overly permissive file permissions',
 'Use more restrictive permissions (e.g., 755)'),

('proton_version_valid', 'medium', 'file_system', 'proton_version', '^(GE-Proton[0-9]+-[0-9]+|Proton-[0-9.]+|Experimental)$', 'warn',
 'Proton version format unrecognized',
 'Use format: GE-Proton9-20 or Proton-8.0 or Experimental'),

('no_init_override', 'high', 'privilege', 'launch_options', 'init=', 'reject',
 'Launch options attempt to override system init',
 'Remove init= parameter - potential system compromise'),

('no_ld_preload', 'medium', 'privilege', 'launch_options', 'LD_PRELOAD', 'require_approval',
 'Launch options override library loading (LD_PRELOAD)',
 'Ensure the library being preloaded is trusted');

-- View: Active critical rules
CREATE VIEW IF NOT EXISTS v_critical_rules AS
SELECT
    rule_name,
    field_path,
    pattern,
    message
FROM playcard_validation_rules
WHERE enabled = 1 AND severity = 'critical'
ORDER BY rule_name;
