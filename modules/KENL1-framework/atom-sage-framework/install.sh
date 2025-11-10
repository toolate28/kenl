#!/usr/bin/env bash
set -euo pipefail

#───────────────────────────────────────────────────────────────────────────────
# ATOM+SAGE Framework Installer
# Pure POSIX shell implementation - zero external dependencies
#───────────────────────────────────────────────────────────────────────────────

VERSION="1.0.0"
INSTALL_DIR="${HOME}/.local/bin"
CONFIG_DIR="${HOME}/.config/atom-sage"
TRAIL_DIR="${HOME}/.config/atom-sage/trails"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

#───────────────────────────────────────────────────────────────────────────────
# Helper Functions
#───────────────────────────────────────────────────────────────────────────────

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_shell() {
    if [ -z "${BASH_VERSION:-}" ] && [ -z "${ZSH_VERSION:-}" ]; then
        log_warn "Detected non-bash/zsh shell. ATOM+SAGE requires bash or zsh."
        log_info "Proceeding with bash compatibility mode..."
    fi
}

create_directories() {
    log_info "Creating directory structure..."

    mkdir -p "${INSTALL_DIR}"
    mkdir -p "${CONFIG_DIR}"
    mkdir -p "${TRAIL_DIR}"

    log_success "Directories created"
}

install_atom_command() {
    log_info "Installing 'atom' command..."

    cat > "${INSTALL_DIR}/atom" << 'ATOM_EOF'
#!/usr/bin/env bash
#───────────────────────────────────────────────────────────────────────────────
# ATOM Trail Generator
# Creates atomic audit trail tags with intent preservation
#───────────────────────────────────────────────────────────────────────────────

set -euo pipefail

TRAIL_FILE="${HOME}/.config/atom-sage/trails/atom_trail.log"
COUNTER_FILE="${HOME}/.config/atom-sage/trails/.counter"
VERSION="1.0.0"

# Initialize counter if not exists
if [ ! -f "${COUNTER_FILE}" ]; then
    echo "000" > "${COUNTER_FILE}"
fi

# Read and increment counter
COUNTER=$(cat "${COUNTER_FILE}")
NEXT_COUNTER=$(printf "%03d" $((10#${COUNTER} + 1)))
echo "${NEXT_COUNTER}" > "${COUNTER_FILE}"

# Get operation type and intent
OPERATION_TYPE="${1:-STATUS}"
shift || true
INTENT="${*:-No intent specified}"

# Generate ATOM tag
DATE=$(date +%Y%m%d)
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
ATOM_TAG="ATOM-${OPERATION_TYPE}-${DATE}-${NEXT_COUNTER}"

# Capture context
WORK_DIR="$(pwd)"
USER="$(whoami)"
HOST="$(hostname)"

# Write to trail
echo "[${TIMESTAMP}] ${ATOM_TAG} | ${INTENT}" >> "${TRAIL_FILE}"
echo "  Context: ${USER}@${HOST}:${WORK_DIR}" >> "${TRAIL_FILE}"

# Output ATOM tag
echo "${ATOM_TAG}"
echo "Intent logged: ${INTENT}"
ATOM_EOF

    chmod +x "${INSTALL_DIR}/atom"
    log_success "'atom' command installed"
}

install_atom_analytics() {
    log_info "Installing 'atom-analytics' command..."

    cat > "${INSTALL_DIR}/atom-analytics" << 'ANALYTICS_EOF'
#!/usr/bin/env bash
#───────────────────────────────────────────────────────────────────────────────
# ATOM Analytics Tool
# Analyze ATOM trails for recovery and insights
#───────────────────────────────────────────────────────────────────────────────

set -euo pipefail

TRAIL_FILE="${HOME}/.config/atom-sage/trails/atom_trail.log"

show_help() {
    cat << 'HELP'
ATOM Analytics Tool

Usage:
    atom-analytics [COMMAND]

Commands:
    --summary, -s       Show summary of recent operations
    --last, -l [N]      Show last N operations (default: 10)
    --type TYPE         Filter by operation type
    --today             Show today's operations
    --pending           Show operations marked as TODO or pending
    --recovery          Recovery analysis (show incomplete workflows)
    --help, -h          Show this help

Examples:
    atom-analytics --summary
    atom-analytics --last 20
    atom-analytics --type MCP
    atom-analytics --recovery
HELP
}

summary() {
    if [ ! -f "${TRAIL_FILE}" ]; then
        echo "No ATOM trail found. Start creating operations with: atom STATUS \"Your intent\""
        return
    fi

    echo "════════════════════════════════════════════════════════════"
    echo "  ATOM Trail Summary"
    echo "════════════════════════════════════════════════════════════"
    echo ""

    local total=$(grep -c "ATOM-" "${TRAIL_FILE}" || echo "0")
    local today=$(grep "$(date +%Y-%m-%d)" "${TRAIL_FILE}" | grep -c "ATOM-" || echo "0")

    echo "Total operations: ${total}"
    echo "Today's operations: ${today}"
    echo ""

    echo "Operations by type:"
    grep "ATOM-" "${TRAIL_FILE}" | sed 's/.*ATOM-\([A-Z]*\)-.*/\1/' | sort | uniq -c | sort -rn
    echo ""
}

last_n() {
    local n="${1:-10}"

    if [ ! -f "${TRAIL_FILE}" ]; then
        echo "No ATOM trail found."
        return
    fi

    echo "Last ${n} operations:"
    echo "────────────────────────────────────────────────────────────"
    grep "ATOM-" "${TRAIL_FILE}" | tail -n "${n}"
}

filter_type() {
    local type="$1"

    if [ ! -f "${TRAIL_FILE}" ]; then
        echo "No ATOM trail found."
        return
    fi

    echo "Operations of type: ${type}"
    echo "────────────────────────────────────────────────────────────"
    grep "ATOM-${type}-" "${TRAIL_FILE}" || echo "No operations found for type: ${type}"
}

today_ops() {
    if [ ! -f "${TRAIL_FILE}" ]; then
        echo "No ATOM trail found."
        return
    fi

    echo "Today's operations ($(date +%Y-%m-%d)):"
    echo "────────────────────────────────────────────────────────────"
    grep "$(date +%Y-%m-%d)" "${TRAIL_FILE}" | grep "ATOM-" || echo "No operations today"
}

pending_ops() {
    if [ ! -f "${TRAIL_FILE}" ]; then
        echo "No ATOM trail found."
        return
    fi

    echo "Pending operations:"
    echo "────────────────────────────────────────────────────────────"
    grep -i "ATOM-TASK-\|TODO\|pending\|in progress" "${TRAIL_FILE}" || echo "No pending operations"
}

recovery_analysis() {
    if [ ! -f "${TRAIL_FILE}" ]; then
        echo "No ATOM trail for recovery analysis."
        return
    fi

    echo "════════════════════════════════════════════════════════════"
    echo "  Recovery Analysis"
    echo "════════════════════════════════════════════════════════════"
    echo ""

    echo "Recent context (last 20 operations):"
    echo "────────────────────────────────────────────────────────────"
    grep "ATOM-" "${TRAIL_FILE}" | tail -n 20
    echo ""

    echo "Pending tasks:"
    echo "────────────────────────────────────────────────────────────"
    grep -i "ATOM-TASK-\|TODO" "${TRAIL_FILE}" | tail -n 10 || echo "No explicit pending tasks"
    echo ""

    echo "Last status:"
    echo "────────────────────────────────────────────────────────────"
    grep "ATOM-STATUS-" "${TRAIL_FILE}" | tail -n 1 || echo "No status updates"
}

# Parse arguments
case "${1:-}" in
    --summary|-s)
        summary
        ;;
    --last|-l)
        last_n "${2:-10}"
        ;;
    --type)
        if [ -z "${2:-}" ]; then
            echo "Error: --type requires an argument"
            exit 1
        fi
        filter_type "$2"
        ;;
    --today)
        today_ops
        ;;
    --pending)
        pending_ops
        ;;
    --recovery)
        recovery_analysis
        ;;
    --help|-h|"")
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        echo "Run 'atom-analytics --help' for usage information"
        exit 1
        ;;
esac
ANALYTICS_EOF

    chmod +x "${INSTALL_DIR}/atom-analytics"
    log_success "'atom-analytics' command installed"
}

add_to_path() {
    log_info "Checking PATH configuration..."

    if [[ ":$PATH:" == *":${INSTALL_DIR}:"* ]]; then
        log_success "PATH already configured"
        return
    fi

    local shell_rc=""
    if [ -n "${BASH_VERSION:-}" ]; then
        shell_rc="${HOME}/.bashrc"
    elif [ -n "${ZSH_VERSION:-}" ]; then
        shell_rc="${HOME}/.zshrc"
    else
        log_warn "Unknown shell. Please manually add ${INSTALL_DIR} to PATH"
        return
    fi

    if [ -f "${shell_rc}" ]; then
        echo "" >> "${shell_rc}"
        echo "# ATOM+SAGE Framework" >> "${shell_rc}"
        echo "export PATH=\"\${HOME}/.local/bin:\${PATH}\"" >> "${shell_rc}"
        log_success "Added to ${shell_rc}"
        log_info "Run 'source ${shell_rc}' or restart your shell"
    else
        log_warn "Could not find ${shell_rc}. Please manually add ${INSTALL_DIR} to PATH"
    fi
}

show_install_summary() {
    echo ""
    echo "════════════════════════════════════════════════════════════"
    log_success "ATOM+SAGE Framework v${VERSION} installed successfully!"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    echo "Installation locations:"
    echo "  Commands: ${INSTALL_DIR}"
    echo "  Config:   ${CONFIG_DIR}"
    echo "  Trails:   ${TRAIL_DIR}"
    echo ""
    echo "Available commands:"
    echo "  atom               - Create ATOM tags"
    echo "  atom-analytics     - Analyze ATOM trails"
    echo ""
    echo "Quick start:"
    echo "  $ atom STATUS \"Starting my first ATOM-tracked project\""
    echo "  $ atom CFG \"Configure database connection\""
    echo "  $ atom-analytics --summary"
    echo ""
    echo "For recovery after crash:"
    echo "  $ atom-analytics --recovery"
    echo ""
    echo "Documentation: ./docs/"
    echo "Examples: ./examples/"
    echo ""
    log_info "If commands are not found, run: source ~/.bashrc (or ~/.zshrc)"
}

#───────────────────────────────────────────────────────────────────────────────
# Main Installation
#───────────────────────────────────────────────────────────────────────────────

main() {
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "  ATOM+SAGE Framework Installer v${VERSION}"
    echo "  Intent-driven operations for traceable systems"
    echo "════════════════════════════════════════════════════════════"
    echo ""

    check_shell
    create_directories
    install_atom_command
    install_atom_analytics
    add_to_path
    show_install_summary

    # Create initial ATOM tag
    if command -v "${INSTALL_DIR}/atom" &> /dev/null; then
        "${INSTALL_DIR}/atom" STATUS "ATOM+SAGE Framework v${VERSION} installed" > /dev/null 2>&1 || true
    fi
}

main "$@"
