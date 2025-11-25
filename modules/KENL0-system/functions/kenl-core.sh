#!/usr/bin/env bash
#
# kenl-core.sh - Core KENL library with shared functions
#
# Provides common functionality used across all KENL modules:
# - Color output and formatting
# - Platform detection
# - ATOM trail logging
# - Error handling
# - Path management
# - User prompts and confirmations
#
# Version: 1.0.0
# ATOM: ATOM-CORE-20251125-001
#
# Usage:
#   source /path/to/kenl-core.sh
#   kenl_info "Starting operation..."
#   platform=$(kenl_get_platform)
#

set -euo pipefail

# ═══════════════════════════════════════════════════════════
# Configuration
# ═══════════════════════════════════════════════════════════

readonly KENL_CORE_VERSION="1.0.0"
readonly KENL_CONFIG_DIR="${KENL_CONFIG_DIR:-${HOME}/.kenl}"
readonly KENL_LOGS_DIR="${KENL_LOGS_DIR:-${HOME}/.kenl/logs}"
readonly ATOM_TRAIL_PATH="${ATOM_TRAIL_PATH:-${HOME}/.kenl/atom_trail.log}"
readonly ATOM_COUNTER_PATH="${ATOM_COUNTER_PATH:-${HOME}/.kenl/.atom-counter}"

# ═══════════════════════════════════════════════════════════
# Colors and Formatting
# ═══════════════════════════════════════════════════════════

# Check if we support colors
if [[ -t 1 ]] && [[ "${TERM:-dumb}" != "dumb" ]]; then
    readonly KENL_COLOR_ENABLED=true
else
    readonly KENL_COLOR_ENABLED=false
fi

# Color definitions
# shellcheck disable=SC2034  # Colors exported for use by sourcing scripts
if $KENL_COLOR_ENABLED; then
    readonly C_RED='\033[0;31m'
    readonly C_GREEN='\033[0;32m'
    readonly C_YELLOW='\033[1;33m'
    readonly C_BLUE='\033[0;34m'
    readonly C_MAGENTA='\033[0;35m'
    readonly C_CYAN='\033[0;36m'
    readonly C_WHITE='\033[1;37m'
    readonly C_GRAY='\033[0;90m'
    readonly C_BOLD='\033[1m'
    readonly C_NC='\033[0m' # No Color
else
    readonly C_RED=''
    readonly C_GREEN=''
    readonly C_YELLOW=''
    readonly C_BLUE=''
    readonly C_MAGENTA=''
    readonly C_CYAN=''
    readonly C_WHITE=''
    readonly C_GRAY=''
    readonly C_BOLD=''
    readonly C_NC=''
fi

# ═══════════════════════════════════════════════════════════
# Logging Functions
# ═══════════════════════════════════════════════════════════

#
# Log an info message
#
kenl_info() {
    echo -e "${C_CYAN}[ℹ]${C_NC} $*"
}

#
# Log a success message
#
kenl_success() {
    echo -e "${C_GREEN}[✓]${C_NC} $*"
}

#
# Log a warning message
#
kenl_warn() {
    echo -e "${C_YELLOW}[⚠]${C_NC} $*" >&2
}

#
# Log an error message
#
kenl_error() {
    echo -e "${C_RED}[✗]${C_NC} $*" >&2
}

#
# Log a debug message (only if KENL_DEBUG is set)
#
kenl_debug() {
    if [[ "${KENL_DEBUG:-}" == "1" || "${KENL_DEBUG:-}" == "true" ]]; then
        echo -e "${C_GRAY}[D]${C_NC} $*" >&2
    fi
}

#
# Print a header banner
#
kenl_header() {
    local title="$1"
    local width="${2:-60}"

    echo ""
    echo -e "${C_CYAN}╔$(printf '═%.0s' $(seq 1 "$width"))╗${C_NC}"
    printf "${C_CYAN}║${C_NC}  %-$((width - 2))s${C_CYAN}║${C_NC}\n" "$title"
    echo -e "${C_CYAN}╚$(printf '═%.0s' $(seq 1 "$width"))╝${C_NC}"
    echo ""
}

#
# Print a section divider
#
kenl_divider() {
    local width="${1:-60}"
    echo -e "${C_GRAY}$(printf '─%.0s' $(seq 1 "$width"))${C_NC}"
}

# ═══════════════════════════════════════════════════════════
# Platform Detection
# ═══════════════════════════════════════════════════════════

#
# Get current platform type
# Returns: windows, wsl2, bazzite, fedora, ubuntu, linux, macos, unknown
#
kenl_get_platform() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    elif grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl2"
    elif [[ -f /etc/os-release ]]; then
        # Parse os-release for distribution
        local id
        id=$(grep "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"')
        case "$id" in
            bazzite)
                echo "bazzite"
                ;;
            fedora)
                echo "fedora"
                ;;
            ubuntu)
                echo "ubuntu"
                ;;
            arch|manjaro)
                echo "arch"
                ;;
            *)
                echo "linux"
                ;;
        esac
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

#
# Check if running on immutable OS (rpm-ostree based)
#
kenl_is_immutable() {
    command -v rpm-ostree &> /dev/null
}

#
# Check if systemd is available
#
kenl_has_systemd() {
    command -v systemctl &> /dev/null && [[ -d /run/systemd/system ]]
}

#
# Check if running as root
#
kenl_is_root() {
    [[ $EUID -eq 0 ]]
}

#
# Require root, exit if not root
#
kenl_require_root() {
    if ! kenl_is_root; then
        kenl_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# ═══════════════════════════════════════════════════════════
# Directory and Path Management
# ═══════════════════════════════════════════════════════════

#
# Initialize KENL directories
#
kenl_init_dirs() {
    mkdir -p "$KENL_CONFIG_DIR"
    mkdir -p "$KENL_LOGS_DIR"

    # Set permissions
    chmod 700 "$KENL_CONFIG_DIR"
}

#
# Get KENL module path
#
kenl_get_module_path() {
    local module="${1:-}"

    # Try to find KENL root
    local kenl_root="${KENL_ROOT:-}"

    if [[ -z "$kenl_root" ]]; then
        # Try common locations
        if [[ -d "$HOME/kenl" ]]; then
            kenl_root="$HOME/kenl"
        elif [[ -d "/opt/kenl" ]]; then
            kenl_root="/opt/kenl"
        fi
    fi

    if [[ -n "$module" ]] && [[ -n "$kenl_root" ]]; then
        echo "$kenl_root/modules/$module"
    elif [[ -n "$kenl_root" ]]; then
        echo "$kenl_root"
    else
        echo ""
    fi
}

# ═══════════════════════════════════════════════════════════
# ATOM Trail Logging
# ═══════════════════════════════════════════════════════════

#
# Generate ATOM tag
#
# Arguments:
#   $1 - Type (CFG, DEPLOY, TASK, etc.)
#   $2 - Description
#
# Returns:
#   Prints the ATOM tag to stdout
#
generate_atom_tag() {
    local type="${1:-TASK}"
    local description="${2:-No description}"

    # Initialize if needed
    kenl_init_dirs

    if [[ ! -f "$ATOM_COUNTER_PATH" ]]; then
        echo "1" > "$ATOM_COUNTER_PATH"
    fi

    # Get counter
    local counter
    counter=$(cat "$ATOM_COUNTER_PATH")

    # Generate tag
    local tag
    tag=$(printf "ATOM-%s-%s-%03d" "$type" "$(date +%Y%m%d)" "$counter")

    # Log to trail
    local timestamp
    timestamp=$(date -Iseconds)
    echo "$timestamp | $tag | $description" >> "$ATOM_TRAIL_PATH"

    # Increment counter
    echo $((counter + 1)) > "$ATOM_COUNTER_PATH"

    # Return tag
    echo "$tag"
}

#
# Shorthand for ATOM logging
#
atom() {
    local type="${1:-TASK}"
    local message="${2:-}"
    local details="${3:-}"

    local full_msg="$message"
    if [[ -n "$details" ]]; then
        full_msg="$message | $details"
    fi

    local tag
    tag=$(generate_atom_tag "$type" "$full_msg")
    kenl_debug "ATOM: $tag - $full_msg"
    echo "$tag"
}

#
# Show recent ATOM trail entries
#
show_atom_trail() {
    local count="${1:-20}"

    if [[ ! -f "$ATOM_TRAIL_PATH" ]]; then
        kenl_warn "ATOM trail not found at: $ATOM_TRAIL_PATH"
        return
    fi

    kenl_header "ATOM Trail (Last $count entries)"
    tail -n "$count" "$ATOM_TRAIL_PATH"
    echo ""
}

# ═══════════════════════════════════════════════════════════
# User Interaction
# ═══════════════════════════════════════════════════════════

#
# Prompt for confirmation
#
# Arguments:
#   $1 - Prompt message
#   $2 - Default (y/n, default: n)
#
# Returns:
#   0 if yes, 1 if no
#
kenl_confirm() {
    local prompt="${1:-Continue?}"
    local default="${2:-n}"

    local yn_hint
    if [[ "$default" == "y" ]]; then
        yn_hint="[Y/n]"
    else
        yn_hint="[y/N]"
    fi

    read -rp "$prompt $yn_hint: " response

    case "${response:-$default}" in
        [Yy]|[Yy][Ee][Ss])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

#
# Prompt for exact phrase confirmation (for destructive operations)
#
# Arguments:
#   $1 - Required phrase
#   $2 - Prompt message (optional)
#
# Returns:
#   0 if phrase matches, 1 otherwise
#
kenl_confirm_phrase() {
    local required_phrase="$1"
    # shellcheck disable=SC2016  # We want literal quotes in the prompt
    local prompt="${2:-Type '${required_phrase}' to confirm}"

    read -rp "$prompt: " response

    if [[ "$response" == "$required_phrase" ]]; then
        return 0
    else
        kenl_error "Confirmation phrase did not match"
        return 1
    fi
}

#
# Prompt for input with validation
#
# Arguments:
#   $1 - Prompt message
#   $2 - Validation regex (optional)
#   $3 - Default value (optional)
#
# Returns:
#   Prints the user input to stdout
#
kenl_prompt() {
    local prompt="$1"
    local validation="${2:-}"
    local default="${3:-}"

    local hint=""
    if [[ -n "$default" ]]; then
        hint=" [$default]"
    fi

    while true; do
        read -rp "$prompt$hint: " response

        # Use default if empty
        response="${response:-$default}"

        # Validate if pattern provided
        if [[ -n "$validation" ]]; then
            if [[ "$response" =~ $validation ]]; then
                echo "$response"
                return 0
            else
                kenl_error "Invalid input. Please try again."
            fi
        else
            echo "$response"
            return 0
        fi
    done
}

# ═══════════════════════════════════════════════════════════
# Error Handling
# ═══════════════════════════════════════════════════════════

#
# Exit with error message and optional cleanup
#
kenl_die() {
    local message="$1"
    local exit_code="${2:-1}"

    kenl_error "$message"

    # Run cleanup function if defined
    if declare -f kenl_cleanup &> /dev/null; then
        kenl_cleanup
    fi

    exit "$exit_code"
}

#
# Set up trap for cleanup on exit
#
kenl_setup_trap() {
    trap 'kenl_cleanup' EXIT INT TERM
}

# Default cleanup function (can be overridden)
kenl_cleanup() {
    kenl_debug "Cleanup called"
    # Override this in your script
}

# ═══════════════════════════════════════════════════════════
# Command Helpers
# ═══════════════════════════════════════════════════════════

#
# Check if command exists
#
kenl_has_command() {
    command -v "$1" &> /dev/null
}

#
# Require command, exit if not found
#
kenl_require_command() {
    local cmd="$1"
    local install_hint="${2:-}"

    if ! kenl_has_command "$cmd"; then
        kenl_error "Required command not found: $cmd"
        if [[ -n "$install_hint" ]]; then
            kenl_info "Install with: $install_hint"
        fi
        exit 1
    fi
}

#
# Run command with logging
#
kenl_run() {
    kenl_debug "Running: $*"
    "$@"
}

#
# Run command and capture output
#
kenl_run_capture() {
    kenl_debug "Running (capture): $*"
    "$@" 2>&1
}

# ═══════════════════════════════════════════════════════════
# Version and Info
# ═══════════════════════════════════════════════════════════

#
# Show KENL core library info
#
kenl_version() {
    echo "KENL Core Library v$KENL_CORE_VERSION"
    echo "Platform: $(kenl_get_platform)"
    echo "Config: $KENL_CONFIG_DIR"
    echo "Logs: $KENL_LOGS_DIR"
    echo "ATOM Trail: $ATOM_TRAIL_PATH"
}

# ═══════════════════════════════════════════════════════════
# Module Load
# ═══════════════════════════════════════════════════════════

# Initialize directories on load
kenl_init_dirs

# Print load message if sourced interactively
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    kenl_debug "KENL core library loaded (v$KENL_CORE_VERSION)"
fi
