#!/usr/bin/env bash
#───────────────────────────────────────────────────────────────────────────────
# KENL Example Script Template
# Demonstrates all error handling library features and best practices
#───────────────────────────────────────────────────────────────────────────────
#
# Purpose: Template for creating new KENL scripts with comprehensive error handling
# Prerequisites: Bash 4+, KENL error handling library
# Usage: ./example-script-template.sh [OPTIONS] ARGUMENTS
# Options:
#   --dry-run       Show what would be done without making changes
#   --debug         Enable debug output
#   --help          Show this help message
# Output: Varies based on script purpose
# Next steps:
#   - Copy this template for new scripts
#   - Modify the main() function for your use case
#   - Update documentation sections
# Integration:
#   - Uses KENL error handling library
#   - Follows ATOM tagging standards
#   - Provides rollback instructions
# Related: See scripts/lib/README.md for library documentation
#
# Version: 1.0.0
# ATOM: ATOM-TEMPLATE-20251205-001
#

set -euo pipefail

# Get script directory and load error handling library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/error-handling.sh
source "$SCRIPT_DIR/lib/error-handling.sh"

#───────────────────────────────────────────────────────────────────────────────
# Script Configuration
#───────────────────────────────────────────────────────────────────────────────

SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_NAME
readonly VERSION="1.0.0"
readonly ATOM_TAG="ATOM-TEMPLATE-20251205-001"

# Options
DRY_RUN=false
DEBUG=0
VERBOSE=false

# Script-specific variables
CONFIG_FILE="${HOME}/.config/example/config.yaml"
DATA_DIR="${HOME}/.local/share/example"

#───────────────────────────────────────────────────────────────────────────────
# Help and Usage
#───────────────────────────────────────────────────────────────────────────────

show_help() {
    cat << EOF
KENL Example Script Template v${VERSION}

Usage: $SCRIPT_NAME [OPTIONS] ARGUMENTS

Demonstrates comprehensive error handling and best practices for KENL scripts.

Options:
  --dry-run       Show what would be done without making changes
  --debug         Enable debug output (set DEBUG=1)
  --verbose       Enable verbose output
  --help          Show this help message

Arguments:
  (Add your script-specific arguments here)

Examples:
  $SCRIPT_NAME --dry-run          # Preview changes
  $SCRIPT_NAME --debug            # Debug mode
  $SCRIPT_NAME --verbose          # Verbose output

Environment Variables:
  DEBUG=1         Enable debug logging

For more information, see:
  - scripts/lib/README.md - Error handling library documentation
  - CONTRIBUTING.md - Contribution guidelines

ATOM Tag: $ATOM_TAG
EOF
}

#───────────────────────────────────────────────────────────────────────────────
# Prerequisite Checks
#───────────────────────────────────────────────────────────────────────────────

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    local errors=0
    
    # Check required commands
    if ! require_commands "bash" "grep" "sed"; then
        ((errors++))
    fi
    
    # Check optional commands (warns but doesn't fail)
    check_optional_command "jq" "jq" "JSON processor for enhanced features" || true
    check_optional_command "yq" "yq" "YAML processor for config parsing" || true
    
    # Check platform compatibility
    local platform
    platform=$(detect_platform)
    log_info "Detected platform: $platform"
    
    # Warn if on immutable system
    warn_if_immutable "file system modifications"
    
    # Verify we're not running as root (for user-space operations)
    if [ "${REQUIRE_ROOT:-false}" = "true" ]; then
        require_root
    else
        if is_root; then
            log_warn "Running as root - this script is designed for user-space"
        fi
    fi
    
    if [ $errors -gt 0 ]; then
        die "Prerequisites check failed" \
            "Install missing dependencies and try again"
    fi
    
    log_success "All prerequisites satisfied"
}

#───────────────────────────────────────────────────────────────────────────────
# Configuration Management
#───────────────────────────────────────────────────────────────────────────────

load_configuration() {
    log_info "Loading configuration..."
    
    # Create default configuration if it doesn't exist
    if [ ! -f "$CONFIG_FILE" ]; then
        log_warn "Configuration file not found: $CONFIG_FILE"
        log_info "Creating default configuration..."
        
        if [ "$DRY_RUN" = "true" ]; then
            log_info "[DRY RUN] Would create: $CONFIG_FILE"
        else
            mkdir -p "$(dirname "$CONFIG_FILE")"
            cat > "$CONFIG_FILE" << 'EOF'
---
# Example KENL Script Configuration
version: 1.0.0
settings:
  verbose: false
  timeout: 30
EOF
            log_success "Created default configuration"
        fi
    else
        log_success "Configuration loaded from: $CONFIG_FILE"
    fi
}

#───────────────────────────────────────────────────────────────────────────────
# Main Operations
#───────────────────────────────────────────────────────────────────────────────

setup_environment() {
    log_info "Setting up environment..."
    
    # Create necessary directories
    local dirs=("$DATA_DIR" "${DATA_DIR}/cache" "${DATA_DIR}/logs")
    
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            execute_step "mkdir -p '$dir'" "Create directory: $dir" "$DRY_RUN"
        else
            log_debug "Directory exists: $dir"
        fi
    done
    
    log_success "Environment setup complete"
}

perform_operation() {
    log_info "Performing main operation..."
    
    # Example: Backup existing file before modification
    if [ -f "$CONFIG_FILE" ]; then
        local backup
        backup=$(backup_file "$CONFIG_FILE")
        log_info "Backup created: $backup"
    fi
    
    # Example: Execute with dry-run support
    execute_step "echo 'Processing data...'" \
                 "Process data files" \
                 "$DRY_RUN"
    
    # Example: Try optional operation without failing
    if try_command "optional_tool --process" "Run optional tool"; then
        log_success "Optional tool completed successfully"
    else
        log_warn "Optional tool failed or not available (continuing)"
    fi
    
    # Example: Validate ATOM tag format
    if validate_atom_tag "$ATOM_TAG"; then
        log_debug "ATOM tag is valid"
    fi
    
    log_success "Operation completed"
}

cleanup() {
    log_info "Cleaning up..."
    
    # Add cleanup operations here
    execute_step "echo 'Cleaning temporary files...'" \
                 "Clean temporary files" \
                 "$DRY_RUN"
    
    log_success "Cleanup complete"
}

#───────────────────────────────────────────────────────────────────────────────
# Error Recovery
#───────────────────────────────────────────────────────────────────────────────

handle_error() {
    local exit_code=$?
    
    log_error "Script failed with exit code: $exit_code"
    
    # Provide context-specific recovery suggestions
    if [ $exit_code -eq 1 ]; then
        suggest_recovery "missing_dependency"
    elif [ $exit_code -eq 2 ]; then
        suggest_recovery "permission_denied" "$DATA_DIR"
    else
        suggest_recovery "unknown"
    fi
    
    exit $exit_code
}

#───────────────────────────────────────────────────────────────────────────────
# Argument Parsing
#───────────────────────────────────────────────────────────────────────────────

parse_arguments() {
    # Check for help first
    if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
        show_help
        exit 0
    fi
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                log_debug "Dry-run mode enabled"
                shift
                ;;
            --debug)
                DEBUG=1
                export DEBUG
                log_debug "Debug mode enabled"
                shift
                ;;
            --verbose|-v)
                VERBOSE=true  # Used for verbose output logging
                log_debug "Verbose mode enabled"
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            -*)
                log_error "Unknown option: $1"
                echo ""
                show_help
                exit 1
                ;;
            *)
                # Positional arguments
                log_debug "Positional argument: $1"
                shift
                ;;
        esac
    done
}

#───────────────────────────────────────────────────────────────────────────────
# Main Execution
#───────────────────────────────────────────────────────────────────────────────

main() {
    # Set error trap
    trap handle_error ERR
    
    # Display banner
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  KENL Example Script Template v${VERSION}"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    
    # Parse command-line arguments
    parse_arguments "$@"
    
    # Show mode indicators
    if [ "$DRY_RUN" = "true" ]; then
        log_info "Running in DRY RUN mode - no changes will be made"
        echo ""
    fi
    
    if [ "${DEBUG:-0}" = "1" ]; then
        log_debug "Debug logging enabled"
    fi
    
    # Execute main workflow
    check_prerequisites
    echo ""
    
    load_configuration
    echo ""
    
    setup_environment
    echo ""
    
    perform_operation
    echo ""
    
    cleanup
    echo ""
    
    # Generate rollback instructions
    if [ "$DRY_RUN" = "false" ]; then
        generate_rollback_instructions \
            "example script execution" \
            "# Add specific rollback commands here
            # Example: rm -rf $DATA_DIR
            # Example: restore_file backup_path original_path"
    fi
    
    # Final summary
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    log_success "Script completed successfully!"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    
    if [ "$DRY_RUN" = "true" ]; then
        log_info "This was a dry run - no changes were made"
        log_info "Run without --dry-run to apply changes"
    fi
}

# Run main function
main "$@"
