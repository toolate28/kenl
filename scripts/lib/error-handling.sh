#!/usr/bin/env bash
#───────────────────────────────────────────────────────────────────────────────
# KENL Error Handling Library
# Centralized error handling, dependency checking, and recovery functions
#───────────────────────────────────────────────────────────────────────────────
#
# Purpose: Provide reusable error handling and dependency checking for KENL scripts
# Prerequisites: Bash 4+
# Usage: source "$(dirname "$0")/lib/error-handling.sh"
# Integration: Used by all KENL scripts for consistent error handling
# Related: See CONTRIBUTING.md for error handling standards
#
# Version: 1.0.0
# ATOM: ATOM-TOOL-20251205-001
#

# Prevent multiple sourcing
if [ -n "${KENL_ERROR_HANDLING_LOADED:-}" ]; then
    return 0
fi
KENL_ERROR_HANDLING_LOADED=1

#───────────────────────────────────────────────────────────────────────────────
# Color Codes
#───────────────────────────────────────────────────────────────────────────────

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'  # Exported for use by scripts that source this library
readonly MAGENTA='\033[0;35m'
readonly NC='\033[0m' # No Color

#───────────────────────────────────────────────────────────────────────────────
# Logging Functions
#───────────────────────────────────────────────────────────────────────────────

# Log informational message
# Usage: log_info "message"
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*" >&2
}

# Log success message
# Usage: log_success "message"
log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*" >&2
}

# Log warning message
# Usage: log_warn "message"
log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*" >&2
}

# Log error message
# Usage: log_error "message"
log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# Log debug message (only if DEBUG is set)
# Usage: log_debug "message"
log_debug() {
    if [ "${DEBUG:-0}" = "1" ]; then
        echo -e "${MAGENTA}[DEBUG]${NC} $*" >&2
    fi
}

#───────────────────────────────────────────────────────────────────────────────
# Dependency Management
#───────────────────────────────────────────────────────────────────────────────

# Check if a command exists
# Usage: has_command "command_name"
# Returns: 0 if command exists, 1 otherwise
has_command() {
    command -v "$1" &>/dev/null
}

# Get installation instruction for a package
# Usage: get_install_instruction "package_name" ["command_name"]
# Returns: Installation instruction string
get_install_instruction() {
    local package="$1"
    local command="${2:-$1}"
    local distro=""

    # Detect distribution
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        distro="${ID:-unknown}"
    fi

    case "$distro" in
        fedora|rhel|centos)
            echo "sudo dnf install $package"
            ;;
        ubuntu|debian)
            echo "sudo apt-get install $package"
            ;;
        arch|manjaro)
            echo "sudo pacman -S $package"
            ;;
        opensuse*)
            echo "sudo zypper install $package"
            ;;
        *)
            echo "Install '$command' using your package manager"
            ;;
    esac
}

# Check for required command and provide installation instruction if missing
# Usage: require_command "command_name" ["package_name"] ["description"]
# Returns: 0 if command exists, exits with error otherwise
require_command() {
    local command="$1"
    local package="${2:-$1}"
    local description="${3:-$command}"

    if ! has_command "$command"; then
        log_error "Required command not found: $command"
        log_error "Description: $description"
        log_error "Installation: $(get_install_instruction "$package" "$command")"
        return 1
    fi

    log_debug "Found command: $command"
    return 0
}

# Check for optional command and warn if missing
# Usage: check_optional_command "command_name" ["package_name"] ["description"]
# Returns: 0 if command exists, 1 otherwise (does not exit)
check_optional_command() {
    local command="$1"
    local package="${2:-$1}"
    local description="${3:-$command}"

    if ! has_command "$command"; then
        log_warn "Optional command not found: $command"
        log_warn "Description: $description"
        log_warn "Installation: $(get_install_instruction "$package" "$command")"
        return 1
    fi

    log_debug "Found optional command: $command"
    return 0
}

# Check multiple required commands at once
# Usage: require_commands "cmd1" "cmd2" "cmd3"
# Returns: 0 if all commands exist, exits with list of missing commands otherwise
require_commands() {
    local missing_commands=()
    local cmd

    for cmd in "$@"; do
        if ! has_command "$cmd"; then
            missing_commands+=("$cmd")
        fi
    done

    if [ ${#missing_commands[@]} -gt 0 ]; then
        log_error "Missing required commands: ${missing_commands[*]}"
        log_error ""
        log_error "Installation instructions:"
        for cmd in "${missing_commands[@]}"; do
            log_error "  - $(get_install_instruction "$cmd")"
        done
        return 1
    fi

    return 0
}

# Validate that required directories exist
# Usage: require_directory "path1" "path2" ...
# Returns: 0 if all directories exist, exits with error otherwise
require_directory() {
    local missing_dirs=()
    local dir

    for dir in "$@"; do
        if [ ! -d "$dir" ]; then
            missing_dirs+=("$dir")
        fi
    done

    if [ ${#missing_dirs[@]} -gt 0 ]; then
        log_error "Missing required directories:"
        for dir in "${missing_dirs[@]}"; do
            log_error "  - $dir"
        done
        return 1
    fi

    return 0
}

# Validate that required files exist
# Usage: require_file "path1" "path2" ...
# Returns: 0 if all files exist, exits with error otherwise
require_file() {
    local missing_files=()
    local file

    for file in "$@"; do
        if [ ! -f "$file" ]; then
            missing_files+=("$file")
        fi
    done

    if [ ${#missing_files[@]} -gt 0 ]; then
        log_error "Missing required files:"
        for file in "${missing_files[@]}"; do
            log_error "  - $file"
        done
        return 1
    fi

    return 0
}

#───────────────────────────────────────────────────────────────────────────────
# Error Handling
#───────────────────────────────────────────────────────────────────────────────

# Exit with error message and optional recovery instructions
# Usage: die "error message" ["recovery instruction"]
die() {
    local message="$1"
    local recovery="${2:-}"

    log_error "$message"

    if [ -n "$recovery" ]; then
        echo ""
        log_info "Recovery suggestion:"
        echo "  $recovery" >&2
    fi

    exit 1
}

# Run a command with error handling
# Usage: run_or_die "command" "error message" ["recovery instruction"]
run_or_die() {
    local cmd="$1"
    local error_msg="$2"
    local recovery="${3:-}"

    if ! eval "$cmd"; then
        die "$error_msg" "$recovery"
    fi
}

# Run a command and return status without exiting
# Usage: try_command "command" "description"
# Returns: Command exit status
try_command() {
    local cmd="$1"
    local description="${2:-$cmd}"

    log_debug "Trying: $description"

    if eval "$cmd" &>/dev/null; then
        log_debug "Success: $description"
        return 0
    else
        log_warn "Failed: $description"
        return 1
    fi
}

# Execute command in dry-run mode or real mode
# Usage: execute_step "command" "description" [dry_run_flag]
# Returns: 0 on success, 1 on failure
execute_step() {
    local cmd="$1"
    local description="$2"
    local dry_run="${3:-false}"

    if [ "$dry_run" = "true" ]; then
        log_info "[DRY RUN] Would execute: $description"
        return 0
    fi

    log_info "Executing: $description"

    if eval "$cmd"; then
        log_success "$description"
        return 0
    else
        log_error "Failed: $description"
        return 1
    fi
}

#───────────────────────────────────────────────────────────────────────────────
# Platform Detection
#───────────────────────────────────────────────────────────────────────────────

# Detect the current platform
# Usage: platform=$(detect_platform)
# Returns: "linux", "darwin", "windows", "wsl", "bazzite", or "unknown"
detect_platform() {
    local os
    os=$(uname -s | tr '[:upper:]' '[:lower:]')

    case "$os" in
        linux*)
            # Check for WSL
            if grep -qi microsoft /proc/version 2>/dev/null; then
                echo "wsl"
            # Check for Bazzite
            elif grep -qi bazzite /etc/os-release 2>/dev/null; then
                echo "bazzite"
            else
                echo "linux"
            fi
            ;;
        darwin*)
            echo "darwin"
            ;;
        mingw*|msys*|cygwin*)
            echo "windows"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Check if running on Bazzite (immutable Fedora Atomic)
# Usage: if is_bazzite; then ... fi
is_bazzite() {
    grep -qi bazzite /etc/os-release 2>/dev/null
}

# Check if running on immutable system (rpm-ostree based)
# Usage: if is_immutable; then ... fi
is_immutable() {
    has_command rpm-ostree
}

# Warn if operation would modify immutable system
# Usage: warn_if_immutable "operation description"
warn_if_immutable() {
    local operation="$1"

    if is_immutable; then
        log_warn "Running on immutable system (rpm-ostree)"
        log_warn "Operation '$operation' should be user-space only"
        log_warn "Avoid modifying /etc, /usr, /opt directly"
        log_warn "Use ~/.local, ~/.config, ~/. instead"
    fi
}

#───────────────────────────────────────────────────────────────────────────────
# Root/Privilege Checking
#───────────────────────────────────────────────────────────────────────────────

# Check if running as root
# Usage: if is_root; then ... fi
is_root() {
    [ "${EUID:-$(id -u)}" -eq 0 ]
}

# Require root privileges
# Usage: require_root
require_root() {
    if ! is_root; then
        die "This script must be run as root (use sudo)" \
            "Run: sudo $0 $*"
    fi
}

# Require NOT running as root (for user-space operations)
# Usage: require_not_root
require_not_root() {
    if is_root; then
        die "This script should NOT be run as root" \
            "Run without sudo: $0 $*"
    fi
}

#───────────────────────────────────────────────────────────────────────────────
# Rollback Support
#───────────────────────────────────────────────────────────────────────────────

# Create a backup of a file before modifying it
# Usage: backup_file "filepath"
backup_file() {
    local file="$1"
    local backup
    backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"

    if [ -f "$file" ]; then
        if cp "$file" "$backup"; then
            log_info "Backed up: $file -> $backup"
            echo "$backup"
            return 0
        else
            log_error "Failed to backup: $file"
            return 1
        fi
    else
        log_debug "File does not exist, no backup needed: $file"
        return 0
    fi
}

# Restore a file from backup
# Usage: restore_file "backup_filepath" "original_filepath"
restore_file() {
    local backup="$1"
    local original="$2"

    if [ -f "$backup" ]; then
        if cp "$backup" "$original"; then
            log_info "Restored: $backup -> $original"
            return 0
        else
            log_error "Failed to restore: $backup"
            return 1
        fi
    else
        log_error "Backup file not found: $backup"
        return 1
    fi
}

# Generate rollback instructions
# Usage: generate_rollback_instructions "operation" "rollback_command"
generate_rollback_instructions() {
    local operation="$1"
    local rollback_cmd="$2"

    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  ROLLBACK INSTRUCTIONS"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo "Operation: $operation"
    echo ""
    echo "To rollback, run:"
    echo "  $rollback_cmd"
    echo ""
    echo "═══════════════════════════════════════════════════════════"
}

#───────────────────────────────────────────────────────────────────────────────
# Progress Tracking
#───────────────────────────────────────────────────────────────────────────────

# Show a progress spinner during long operations
# Usage: show_spinner "message" &
#        SPINNER_PID=$!
#        ... long operation ...
#        kill $SPINNER_PID 2>/dev/null
show_spinner() {
    local message="$1"
    local delay=0.1
    local spinstr='|/-\'

    printf "%s " "$message" >&2

    while true; do
        local temp=${spinstr#?}
        printf "[%c]" "$spinstr" >&2
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b" >&2
    done
}

#───────────────────────────────────────────────────────────────────────────────
# Validation Helpers
#───────────────────────────────────────────────────────────────────────────────

# Validate ATOM tag format
# Usage: if validate_atom_tag "ATOM-CFG-20251205-001"; then ... fi
validate_atom_tag() {
    local tag="$1"

    if echo "$tag" | grep -qE '^ATOM-[A-Z]+-[0-9]{8}-[0-9]{3}$'; then
        return 0
    else
        log_error "Invalid ATOM tag format: $tag"
        log_error "Expected format: ATOM-TYPE-YYYYMMDD-NNN"
        return 1
    fi
}

# Validate user confirmation
# Usage: if confirm_action "Delete file?"; then ... fi
confirm_action() {
    local prompt="${1:-Continue?}"
    local response

    read -r -p "$prompt (y/N): " response

    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

#───────────────────────────────────────────────────────────────────────────────
# Error Recovery Suggestions
#───────────────────────────────────────────────────────────────────────────────

# Provide context-aware recovery suggestions based on error type
# Usage: suggest_recovery "error_type" "context"
suggest_recovery() {
    local error_type="$1"
    local context="${2:-}"

    echo ""
    log_info "Recovery suggestions for: $error_type"
    echo ""

    case "$error_type" in
        missing_dependency)
            echo "  1. Install missing dependencies (see error messages above)"
            echo "  2. Verify package manager is working: dnf check-update"
            echo "  3. Check if running in distrobox: distrobox list"
            ;;
        permission_denied)
            echo "  1. Check file permissions: ls -la $context"
            echo "  2. Ensure you have write access to the directory"
            echo "  3. If on immutable system, use ~/.local or ~/.config"
            ;;
        network_error)
            echo "  1. Check internet connectivity: ping -c 3 8.8.8.8"
            echo "  2. Verify DNS resolution: nslookup google.com"
            echo "  3. Check firewall settings"
            ;;
        immutable_system)
            echo "  1. Use rpm-ostree for system packages: rpm-ostree install PACKAGE"
            echo "  2. Use user-space alternatives: ~/.local/bin, flatpak, distrobox"
            echo "  3. Review KENL documentation for user-space operations"
            ;;
        *)
            echo "  1. Review error messages above carefully"
            echo "  2. Check KENL documentation and case studies"
            echo "  3. Search GitHub issues: https://github.com/toolate28/kenl/issues"
            ;;
    esac
    echo ""
}

#───────────────────────────────────────────────────────────────────────────────
# Initialization Message
#───────────────────────────────────────────────────────────────────────────────

log_debug "KENL Error Handling Library v1.0.0 loaded"
