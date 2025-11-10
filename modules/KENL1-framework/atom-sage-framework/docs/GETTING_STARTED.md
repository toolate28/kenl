---
project: ATOM+SAGE Framework
status: active
version: 1.0.0
classification: OWI-DOC
atom: ATOM-DOC-20251107-010
owi-version: 1.0.0
---

# Getting Started with ATOM+SAGE

**Your first 15 minutes with intent-driven operations**

## Quick Overview

ATOM+SAGE is a framework for capturing the **why** behind every operation, enabling:
- 7-minute crash recovery
- 100% intent preservation
- Self-validating operations
- Zero-dependency core

This guide will get you up and running in 15 minutes.

---

## Installation (5 minutes)

### Step 1: Clone the repository

```bash
git clone https://github.com/toolate28/atom-sage-framework
cd atom-sage-framework
```

### Step 2: Run the installer

```bash
./install.sh
```

The installer will:
- Create `~/.config/atom-sage/` directory structure
- Install `atom` command to `~/.local/bin/`
- Install `atom-analytics` command
- Configure your shell PATH

### Step 3: Verify installation

```bash
# Reload your shell
source ~/.bashrc  # or ~/.zshrc

# Test the commands
atom STATUS "Testing ATOM+SAGE installation"
atom-analytics --summary
```

**Expected output**:
```
ATOM-STATUS-20251107-001
Intent logged: Testing ATOM+SAGE installation

════════════════════════════════════════════════════════════
  ATOM Trail Summary
════════════════════════════════════════════════════════════

Total operations: 1
Today's operations: 1
...
```

---

## Basic Usage (10 minutes)

### Creating Your First ATOM Tags

ATOM tags capture operations with intent:

```bash
# Start a project
atom STATUS "Starting new web application project"

# Configuration changes
atom CFG "Configure PostgreSQL database connection"
atom CFG "Set up environment variables for dev"

# Development work
atom DEV "Implement user authentication module"
atom TEST "Write unit tests for auth module"

# Documentation
atom DOC "Create API documentation"

# Mark pending work
atom TASK "TODO: Implement password reset"
```

### Understanding ATOM Tag Format

Every ATOM tag follows this pattern:

```
ATOM-{TYPE}-{YYYYMMDD}-{COUNTER}
```

Examples:
- `ATOM-STATUS-20251107-001` - Status update
- `ATOM-CFG-20251107-002` - Configuration change
- `ATOM-DEV-20251107-003` - Development work
- `ATOM-TASK-20251107-004` - Pending task

### Common Operation Types

| Type | Purpose | Example |
|------|---------|---------|
| `STATUS` | Project status updates | "Starting new feature" |
| `CFG` | Configuration changes | "Configure database" |
| `DEV` | Development work | "Implement auth module" |
| `TEST` | Testing operations | "Write unit tests" |
| `DOC` | Documentation | "Update README" |
| `TASK` | Pending work | "TODO: Fix bug #123" |
| `DEPLOY` | Deployments | "Deploy v1.0.0 to prod" |
| `RESEARCH` | Research queries | "Investigate caching options" |

### Viewing Your ATOM Trail

```bash
# Show summary
atom-analytics --summary

# Show recent operations
atom-analytics --last 10

# Filter by type
atom-analytics --type CFG

# Show today's operations
atom-analytics --today

# Show pending tasks
atom-analytics --pending
```

---

## Real-World Example: Starting a New Project

Let's walk through a complete workflow:

```bash
# Day 1: Project setup
atom STATUS "Starting new API project: customer-portal"
atom CFG "Initialize Git repository"
atom CFG "Set up Python virtualenv"
atom CFG "Install dependencies: Flask, SQLAlchemy, pytest"
atom DEV "Create project structure: src/, tests/, docs/"
atom DOC "Create README with project overview"
atom TASK "TODO: Set up CI/CD pipeline"

# Day 2: Database setup
atom CFG "Configure PostgreSQL database"
atom DEV "Create database models: User, Customer, Order"
atom DEV "Implement database migrations with Alembic"
atom TEST "Write tests for database models"

# Day 3: API implementation
atom DEV "Implement authentication endpoints"
atom DEV "Implement customer CRUD endpoints"
atom TEST "Write integration tests for API"
atom TASK "TODO: Add rate limiting"

# View progress
atom-analytics --summary
```

**What you get**:
- Complete audit trail of all work
- Pending tasks automatically tracked
- Context for recovery if you need to stop

---

## Crash Recovery Example

**Scenario**: Your system crashes mid-work. How do you recover?

### Traditional Approach (30-60 minutes)
```
"Uh, I was working on... something with the database?
And maybe the API? I think I finished the models...
Let me check git... hmm, incomplete commits...
What was I doing again?"
```

### ATOM+SAGE Approach (7 minutes)
```bash
# Step 1: Check recovery analysis
atom-analytics --recovery

# Output shows:
#   Recent context: Last 20 operations
#   Pending tasks: Explicit TODOs
#   Last status: "Implementing customer CRUD"
#   Active workflows: DEV (5 ops), TEST (2 ops), CFG (3 ops)

# Step 2: Resume work
atom STATUS "Recovered from crash - continuing customer CRUD"

# You're back to work with full context!
```

**Key insight**: You provided ZERO technical details. The trail captured everything.

---

## CTFWI: Self-Validating Operations

CTFWI = "Checked The Flags, What Intent?"

Use CTFWI flags to test whether AI assistants understand your requirements:

```bash
# Without CTFWI
atom DEPLOY "Deploy to production"
# AI might deploy without checks

# With CTFWI
atom DEPLOY "Deploy to production - CTFWI: Confirm tests pass"
# AI is forced to validate tests first

# Another example
atom CFG "Configure MCP servers - CTFWI: List all 3 servers"
# AI must explicitly show all 3 servers

# Rollback safety
atom TASK "Migrate database - CTFWI: Test on staging first"
# AI must test on staging before production
```

**CTFWI validates understanding, not just execution.**

---

## Multi-Context Workflows

Working on multiple things at once? ATOM tags handle it:

```bash
# Context 1: Feature development
atom DEV "Feature: User notifications module"
atom DEV "Implement email notifications"
atom DEV "Implement push notifications"

# Context 2: Bug fixes
atom DEV "Bugfix: Login timeout issue"
atom TEST "Add regression test for timeout"

# Context 3: Documentation
atom DOC "Update API documentation for v2"

# Context 4: Infrastructure
atom CFG "Set up Redis for caching"

# View specific context
atom-analytics --type DEV  # See all development work
atom-analytics --type CFG  # See all configuration

# Recovery understands all contexts
atom-analytics --recovery
```

---

## Advanced: Python Analytics

For advanced analysis, use the Python tool:

```bash
# Install (requires Python 3.7+)
pip install --user -e ./analytics/

# Use advanced features
atom_analytics.py summary
atom_analytics.py recent -n 20
atom_analytics.py timeline --hours 24
atom_analytics.py recovery
atom_analytics.py export audit-trail.json
```

---

## Integration with AI Assistants

ATOM+SAGE works great with Claude Code, GitHub Copilot, etc:

### Claude Code Integration

```bash
# In a conversation:
"I was working on the customer portal API. Can you continue from where I left off?"

# Claude Code reads ATOM trail automatically
atom-analytics --recovery | pbcopy  # Copy to clipboard
# Paste into conversation
```

### GitHub Copilot Chat

```bash
# Generate recovery context
atom-analytics --recovery > recovery-context.txt

# Paste into Copilot Chat
# Copilot understands the full context
```

---

## Next Steps

### Try the Examples

```bash
# Run example workflows
./examples/basic-workflow.sh
./examples/recovery-demo.sh
./examples/ctfwi-validation.sh
./examples/multi-context.sh
```

### Read Advanced Documentation

- [Architecture Deep Dive](./ARCHITECTURE.md)
- [Validation Case Study](./VALIDATION_COMPLETE.md)
- [Launch Presentation](./LAUNCH_PRESENTATION.md)

### Explore Fork-Specific Solutions

- [ATOM-SEC](../forks/ATOM-SEC/README.md) - AI Security & Red-Teaming
- [ATOM-GOV](../forks/ATOM-GOV/README.md) - MCP Governance
- [ATOM-EOL](../forks/ATOM-EOL/README.md) - Windows 10 EOL Migration

---

## Common Patterns

### Pattern 1: Daily Standup
```bash
atom STATUS "Daily standup: $(date +%Y-%m-%d)"
atom STATUS "Yesterday: Completed authentication module"
atom STATUS "Today: Working on customer CRUD endpoints"
atom STATUS "Blockers: Need design review for API pagination"
```

### Pattern 2: Sprint Planning
```bash
atom STATUS "Sprint 5 planning"
atom TASK "TODO: Implement notification system"
atom TASK "TODO: Add user preferences page"
atom TASK "TODO: Performance optimization for search"
atom TASK "TODO: Update deployment documentation"
```

### Pattern 3: Code Review
```bash
atom REVIEW "Code review: PR #123 - Authentication module"
atom REVIEW "Feedback: Add error handling for expired tokens"
atom REVIEW "Feedback: Extract validation logic to separate function"
atom TASK "TODO: Address PR #123 feedback"
```

### Pattern 4: Incident Response
```bash
atom INCIDENT "P1: API outage detected"
atom INCIDENT "Root cause: Database connection pool exhausted"
atom INCIDENT "Mitigation: Increased pool size from 10 to 50"
atom INCIDENT "Resolution: Service restored at $(date)"
atom TASK "TODO: Add monitoring for connection pool usage"
```

---

## Tips & Best Practices

### Write Intent, Not Technical Details

**Bad**:
```bash
atom CFG "Changed config.py line 47"
```

**Good**:
```bash
atom CFG "Enable caching to improve API response time"
```

### Use CTFWI for Critical Operations

```bash
# Always validate critical operations
atom DEPLOY "Production deployment - CTFWI: Verify all tests pass"
atom CFG "Database migration - CTFWI: Test on staging first"
```

### Mark Pending Work Explicitly

```bash
# Don't rely on memory
atom TASK "TODO: Implement rate limiting (priority: high)"
atom TASK "TODO: Add API documentation examples"
```

### Regular Status Checkpoints

```bash
# Create recovery points
atom STATUS "End of day: 3/5 endpoints complete, 2 pending"
```

### Use Type Tags Consistently

```bash
# Consistent type usage helps with filtering
atom DEV "..."    # Development work
atom TEST "..."   # Testing
atom DOC "..."    # Documentation
atom CFG "..."    # Configuration
```

---

## Troubleshooting

### Command not found: atom

**Fix**:
```bash
source ~/.bashrc  # or ~/.zshrc
# OR manually add to PATH
export PATH="$HOME/.local/bin:$PATH"
```

### No ATOM trail found

**Cause**: Haven't created any operations yet

**Fix**:
```bash
atom STATUS "First operation"
atom-analytics --summary
```

### Permission denied

**Fix**:
```bash
chmod +x ~/.local/bin/atom
chmod +x ~/.local/bin/atom-analytics
```

---

## Getting Help

- **Documentation**: Read the [full documentation](./README.md)
- **Examples**: Run the example scripts in `./examples/`
- **Issues**: Report bugs at GitHub Issues
- **Email**: support@atom-sage.dev

---

**You're ready to use ATOM+SAGE!**

Start creating intent-driven operations and experience the power of capturing **why**, not just **what**.

```bash
atom STATUS "Completed ATOM+SAGE getting started guide"
```

---

**Document ID**: ATOM-DOC-20251107-010
**Version**: 1.0.0
**Last Updated**: 2025-11-06
**Status**: Production Ready
