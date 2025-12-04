#!/usr/bin/env bash
#
# setup-context-sync.sh
# Install and configure context-sync MCP server for KENL
#
# Purpose: Automates context-sync installation, project initialization, and MCP configuration
# Prerequisites: Node.js 18+, npm 9+, write access to ~/.config/
# Usage: ./setup-context-sync.sh [--skip-npm] [--project-name NAME]
# Output: 
#   - context-sync installed globally via npm
#   - bazza-dx project initialized in context-sync
#   - MCP configuration created at ~/.config/claude/mcp-servers/context-sync.json
# Next steps:
#   - Restart Claude Code to load MCP server
#   - Run ./test-installation.sh to verify setup
#   - See ../docs/USAGE-GUIDE.md for common workflows
# Integration:
#   - Uses KENL1 ATOM framework for operation tracking
#   - Creates ATOM log entry for installation
#   - Integrates with Claude Code MCP system (KENL3)
# Rollback: npm uninstall -g @context-sync/server && rm ~/.config/claude/mcp-servers/context-sync.json
#
# ATOM: ATOM-CFG-20251204-002
# Dog Kennel: 🏠 Building the memory kennel for AI agents 🐕

set -euo pipefail

# Color definitions (KENL Visual Elements Standard)
KENL_GREEN="\033[0;32m"
KENL_BLUE="\033[0;34m"
KENL_YELLOW="\033[1;33m"
KENL_RED="\033[0;31m"
KENL_CYAN="\033[0;36m"
KENL_MAGENTA="\033[0;35m"
KENL_BOLD="\033[1m"
KENL_RESET="\033[0m"

# Detect script and repository paths dynamically
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTEXT_SYNC_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
KENL3_DIR="$(cd "$CONTEXT_SYNC_DIR/.." && pwd)"
KENL_ROOT="$(cd "$KENL3_DIR/../.." && pwd)"

# Validate paths
if [[ ! -d "$KENL_ROOT/modules" ]]; then
    echo -e "${KENL_RED}❌ Error: KENL repository structure not found${KENL_RESET}"
    echo -e "${KENL_YELLOW}💡 Hint: Run this script from kenl/modules/KENL3-dev/context-sync/scripts/${KENL_RESET}"
    exit 1
fi

# Default configuration
SKIP_NPM_INSTALL=false
PROJECT_NAME="bazza-dx"

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-npm)
            SKIP_NPM_INSTALL=true
            shift
            ;;
        --project-name)
            PROJECT_NAME="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [--skip-npm] [--project-name NAME]"
            echo ""
            echo "Options:"
            echo "  --skip-npm        Skip npm installation (if already installed)"
            echo "  --project-name    Set project name (default: bazza-dx)"
            echo "  -h, --help        Show this help message"
            exit 0
            ;;
        *)
            echo -e "${KENL_RED}Unknown option: $1${KENL_RESET}"
            echo "Run with -h for help"
            exit 1
            ;;
    esac
done

# Display banner with dog kennel branding
echo -e "${KENL_CYAN}"
cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║       🏠 CONTEXT-SYNC MEMORY KENNEL SETUP 🐕💾             ║
║                                                              ║
║       Building a safe home for AI memories...               ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
echo -e "${KENL_RESET}"

echo ""
echo -e "${KENL_BOLD}KENL Context-Sync Installer${KENL_RESET}"
echo -e "${KENL_BLUE}Project: $PROJECT_NAME${KENL_RESET}"
echo ""

# Step 1: Check prerequisites
echo -e "${KENL_BOLD}[1/5] Checking prerequisites...${KENL_RESET}"

# Check Node.js
if ! command -v node &> /dev/null; then
    echo -e "${KENL_RED}❌ Node.js not found${KENL_RESET}"
    echo -e "${KENL_YELLOW}💡 Install Node.js 18+ via: nvm install 20 (or distrobox/system package manager)${KENL_RESET}"
    exit 1
fi

NODE_VERSION=$(node --version)
echo -e "${KENL_GREEN}✓ Node.js ${NODE_VERSION}${KENL_RESET}"

# Check npm
if ! command -v npm &> /dev/null; then
    echo -e "${KENL_RED}❌ npm not found${KENL_RESET}"
    echo -e "${KENL_YELLOW}💡 npm should come with Node.js. Reinstall Node.js.${KENL_RESET}"
    exit 1
fi

NPM_VERSION=$(npm --version)
echo -e "${KENL_GREEN}✓ npm ${NPM_VERSION}${KENL_RESET}"

# Check SQLite (optional but recommended)
if command -v sqlite3 &> /dev/null; then
    SQLITE_VERSION=$(sqlite3 --version | cut -d' ' -f1)
    echo -e "${KENL_GREEN}✓ SQLite ${SQLITE_VERSION}${KENL_RESET}"
else
    echo -e "${KENL_YELLOW}⚠ SQLite CLI not found (optional for manual DB queries)${KENL_RESET}"
fi

echo ""

# Step 2: Install context-sync via npm
if [[ "$SKIP_NPM_INSTALL" == false ]]; then
    echo -e "${KENL_BOLD}[2/5] Installing context-sync from npm...${KENL_RESET}"
    echo -e "${KENL_CYAN}🏗️  Building the kennel foundation...${KENL_RESET}"
    
    if npm install -g @context-sync/server; then
        echo -e "${KENL_GREEN}✅ context-sync installed successfully${KENL_RESET}"
    else
        echo -e "${KENL_RED}❌ npm installation failed${KENL_RESET}"
        echo -e "${KENL_YELLOW}💡 Try: npm install -g @context-sync/server --force${KENL_RESET}"
        exit 1
    fi
else
    echo -e "${KENL_BOLD}[2/5] Skipping npm installation (--skip-npm flag)${KENL_RESET}"
fi

# Verify installation
if ! command -v context-sync &> /dev/null; then
    echo -e "${KENL_RED}❌ context-sync command not found after installation${KENL_RESET}"
    echo -e "${KENL_YELLOW}💡 Check npm global bin directory: npm config get prefix${KENL_RESET}"
    exit 1
fi

CONTEXT_SYNC_VERSION=$(context-sync --version 2>&1 | head -n1 || echo "unknown")
echo -e "${KENL_GREEN}✓ context-sync ${CONTEXT_SYNC_VERSION}${KENL_RESET}"

echo ""

# Step 3: Initialize project in context-sync
echo -e "${KENL_BOLD}[3/5] Initializing project in context-sync...${KENL_RESET}"
echo -e "${KENL_CYAN}🐕 Creating memory kennel for: $PROJECT_NAME${KENL_RESET}"

# Create context-sync data directory if needed
mkdir -p ~/.context-sync

# Note: context-sync auto-creates project on first use via MCP
# We create a marker file to indicate KENL setup
cat > ~/.context-sync/kenl-setup.json << EOF
{
  "setup_date": "$(date -Iseconds)",
  "project_name": "$PROJECT_NAME",
  "kenl_root": "$KENL_ROOT",
  "setup_script": "$(basename "$0")",
  "atom_tag": "ATOM-CFG-20251204-002"
}
EOF

echo -e "${KENL_GREEN}✅ Project initialization complete${KENL_RESET}"
echo -e "${KENL_BLUE}   Database location: ~/.context-sync/data.db${KENL_RESET}"
echo -e "${KENL_BLUE}   Project will be created on first MCP use${KENL_RESET}"

echo ""

# Step 4: Create MCP server configuration
echo -e "${KENL_BOLD}[4/5] Configuring MCP server for Claude Code...${KENL_RESET}"

MCP_CONFIG_DIR="$HOME/.config/claude/mcp-servers"
MCP_CONFIG_FILE="$MCP_CONFIG_DIR/context-sync.json"

mkdir -p "$MCP_CONFIG_DIR"

# Copy template and customize
if [[ -f "$CONTEXT_SYNC_DIR/mcp-configs/context-sync.json" ]]; then
    cp "$CONTEXT_SYNC_DIR/mcp-configs/context-sync.json" "$MCP_CONFIG_FILE"
    echo -e "${KENL_GREEN}✅ MCP configuration created${KENL_RESET}"
    echo -e "${KENL_BLUE}   Location: $MCP_CONFIG_FILE${KENL_RESET}"
else
    # Create from scratch if template missing
    cat > "$MCP_CONFIG_FILE" << EOF
{
  "mcpServers": {
    "context-sync": {
      "command": "npx",
      "args": ["-y", "@context-sync/server"],
      "env": {
        "CONTEXT_SYNC_PROJECT": "$PROJECT_NAME",
        "CONTEXT_SYNC_DB": "\${HOME}/.context-sync/data.db"
      }
    }
  }
}
EOF
    echo -e "${KENL_GREEN}✅ MCP configuration generated${KENL_RESET}"
    echo -e "${KENL_BLUE}   Location: $MCP_CONFIG_FILE${KENL_RESET}"
fi

echo ""

# Step 5: Create ATOM trail entry
echo -e "${KENL_BOLD}[5/5] Recording installation in ATOM trail...${KENL_RESET}"

ATOM_LOG="$HOME/.kenl/atom-trail.log"
mkdir -p "$(dirname "$ATOM_LOG")"

ATOM_ENTRY="ATOM-CFG-20251204-002: Installed context-sync memory kennel for $PROJECT_NAME"
echo "$ATOM_ENTRY" >> "$ATOM_LOG"
echo -e "${KENL_CYAN}🏷️  $ATOM_ENTRY${KENL_RESET}"

echo ""

# Installation complete
echo -e "${KENL_GREEN}╔══════════════════════════════════════════════════════════════╗${KENL_RESET}"
echo -e "${KENL_GREEN}║                                                              ║${KENL_RESET}"
echo -e "${KENL_GREEN}║   ✅ MEMORY KENNEL BUILT SUCCESSFULLY! 🏠🐕                 ║${KENL_RESET}"
echo -e "${KENL_GREEN}║                                                              ║${KENL_RESET}"
echo -e "${KENL_GREEN}╚══════════════════════════════════════════════════════════════╝${KENL_RESET}"
echo ""
echo -e "${KENL_BOLD}Installation Summary:${KENL_RESET}"
echo -e "${KENL_GREEN}✓${KENL_RESET} context-sync installed: $(command -v context-sync)"
echo -e "${KENL_GREEN}✓${KENL_RESET} Project initialized: $PROJECT_NAME"
echo -e "${KENL_GREEN}✓${KENL_RESET} MCP server configured: $MCP_CONFIG_FILE"
echo -e "${KENL_GREEN}✓${KENL_RESET} ATOM trail updated: $ATOM_LOG"
echo ""
echo -e "${KENL_BOLD}Next Steps:${KENL_RESET}"
echo -e "${KENL_BLUE}1.${KENL_RESET} Restart Claude Code to load MCP server:"
echo -e "   ${KENL_CYAN}pkill -f claude && claude code .${KENL_RESET}"
echo ""
echo -e "${KENL_BLUE}2.${KENL_RESET} Verify installation:"
echo -e "   ${KENL_CYAN}./test-installation.sh${KENL_RESET}"
echo ""
echo -e "${KENL_BLUE}3.${KENL_RESET} Read usage guide:"
echo -e "   ${KENL_CYAN}cat ../docs/USAGE-GUIDE.md${KENL_RESET}"
echo ""
echo -e "${KENL_BLUE}4.${KENL_RESET} Start using context-sync in Claude Code:"
echo -e "   ${KENL_CYAN}claude code ~/projects/$PROJECT_NAME${KENL_RESET}"
echo ""
echo -e "${KENL_YELLOW}🐕 Your AI now has a permanent home for memories!${KENL_RESET}"
echo ""
