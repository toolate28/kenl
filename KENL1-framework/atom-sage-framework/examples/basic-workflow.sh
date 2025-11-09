#!/usr/bin/env bash
#───────────────────────────────────────────────────────────────────────────────
# Basic ATOM Workflow Example
# Demonstrates simple ATOM tag usage for everyday operations
#───────────────────────────────────────────────────────────────────────────────

set -euo pipefail

echo "════════════════════════════════════════════════════════════"
echo "  ATOM Basic Workflow Example"
echo "════════════════════════════════════════════════════════════"
echo ""

# Example 1: Start a new project
echo "[1] Starting a new project..."
atom STATUS "Starting new web application project"
echo ""

# Example 2: Configuration changes
echo "[2] Making configuration changes..."
atom CFG "Configure database connection to PostgreSQL"
atom CFG "Set up environment variables for development"
echo ""

# Example 3: Development operations
echo "[3] Development operations..."
atom DEV "Implement user authentication module"
atom TEST "Write unit tests for auth module"
atom DEPLOY "Deploy v1.0.0 to staging environment"
echo ""

# Example 4: Documentation
echo "[4] Documentation operations..."
atom DOC "Create API documentation for auth endpoints"
atom DOC "Update README with deployment instructions"
echo ""

# Example 5: Mark pending tasks
echo "[5] Mark pending tasks..."
atom TASK "TODO: Implement password reset functionality"
atom TASK "TODO: Add rate limiting to API endpoints"
echo ""

# View summary
echo "════════════════════════════════════════════════════════════"
echo "  Workflow Complete - View Summary"
echo "════════════════════════════════════════════════════════════"
echo ""

atom-analytics --summary

echo ""
echo "View recent operations:"
echo "  $ atom-analytics --last 10"
echo ""
echo "View pending tasks:"
echo "  $ atom-analytics --pending"
echo ""
echo "Recovery after crash:"
echo "  $ atom-analytics --recovery"
