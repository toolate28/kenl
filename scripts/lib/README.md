# KENL Script Library

Reusable library functions for KENL scripts providing consistent error handling, dependency checking, and recovery capabilities.

## Contents

### error-handling.sh

Centralized error handling and dependency management library for all KENL scripts.

**Version:** 1.0.0
**ATOM:** ATOM-TOOL-20251205-001

## Usage

Include the library at the start of your script:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/error-handling.sh
source "$SCRIPT_DIR/lib/error-handling.sh"
```

## Features

### Logging Functions

Consistent, colored output for all message types:

```bash
log_info "Informational message"
log_success "Operation completed successfully"
log_warn "Warning: potential issue detected"
log_error "Error: operation failed"
log_debug "Debug info (only shown with DEBUG=1)"
```

### Dependency Management

Check for required and optional commands with automatic installation hints:

```bash
# Check if command exists
if has_command "git"; then
    echo "Git is available"
fi

# Require a command (exits with error if missing)
require_command "git" "git" "Version control system"

# Check optional command (warns but doesn't exit)
check_optional_command "jq" "jq" "JSON processor"

# Check multiple commands at once
require_commands "git" "bash" "make"

# Validate files and directories exist
require_file "$CONFIG_FILE"
require_directory "$DATA_DIR"
```

Installation instructions are automatically generated based on the detected Linux distribution:

- Fedora/RHEL/CentOS: `sudo dnf install PACKAGE`
- Ubuntu/Debian: `sudo apt-get install PACKAGE`
- Arch/Manjaro: `sudo pacman -S PACKAGE`
- openSUSE: `sudo zypper install PACKAGE`

### Error Handling

Graceful error handling with recovery suggestions:

```bash
# Exit with error message and recovery suggestion
die "Configuration file not found" "Run: ./setup.sh to create configuration"

# Run command or die with error
run_or_die "git clone repo" "Failed to clone repository" "Check network connection"

# Try command without exiting on failure
if try_command "optional_tool --version" "Check optional tool"; then
    echo "Optional tool available"
fi

# Execute command with dry-run support
execute_step "rm -rf /tmp/cache" "Clear cache" "$DRY_RUN"
```

### Platform Detection

Detect platform and adjust behavior accordingly:

```bash
platform=$(detect_platform)
# Returns: linux, darwin, windows, wsl, bazzite, or unknown

# Check for specific platforms
if is_bazzite; then
    log_info "Running on Bazzite"
fi

if is_immutable; then
    warn_if_immutable "system package installation"
fi
```

### Root/Privilege Checking

Enforce privilege requirements:

```bash
# Require root privileges
require_root

# Require NOT running as root (for user-space operations)
require_not_root

# Check if running as root
if is_root; then
    log_warn "Running as root - proceed with caution"
fi
```

### Backup and Rollback

Create backups before modifications and provide rollback instructions:

```bash
# Backup file before modification
backup=$(backup_file "$CONFIG_FILE")
# Returns path to backup file

# Restore from backup
restore_file "$backup" "$CONFIG_FILE"

# Generate rollback instructions for users
generate_rollback_instructions \
    "database schema update" \
    "psql -U user -d db -f rollback.sql"
```

### Validation Helpers

Validate common data formats:

```bash
# Validate ATOM tag format
if validate_atom_tag "ATOM-CFG-20251205-001"; then
    echo "Valid ATOM tag"
fi

# Get user confirmation
if confirm_action "Delete all data?"; then
    rm -rf "$DATA_DIR"
fi
```

### Recovery Suggestions

Provide context-aware recovery suggestions:

```bash
suggest_recovery "missing_dependency" "/path/to/file"
suggest_recovery "permission_denied" "/protected/file"
suggest_recovery "network_error"
suggest_recovery "immutable_system"
```

## Example Script

Complete example using the error handling library:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/error-handling.sh"

# Options
DRY_RUN=false

show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
  --dry-run    Preview changes without executing
  --help       Show this help
EOF
}

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run) DRY_RUN=true; shift ;;
            --help) show_help; exit 0 ;;
            *) die "Unknown option: $1" "Run with --help for usage" ;;
        esac
    done

    log_info "Starting script..."

    # Check prerequisites
    require_commands "git" "make" || die "Missing required commands"
    check_optional_command "jq" "jq" "JSON processor"

    # Warn if on immutable system
    warn_if_immutable "file modification"

    # Create backup
    backup=$(backup_file "$CONFIG_FILE")

    # Execute with dry-run support
    execute_step "make build" "Build project" "$DRY_RUN"

    # Show rollback instructions
    generate_rollback_instructions \
        "configuration update" \
        "cp $backup $CONFIG_FILE"

    log_success "Script completed successfully"
}

main "$@"
```

## Testing

Run the test suite to validate the library:

```bash
./scripts/test-error-handling.sh
```

All 39 tests should pass.

## Standards Compliance

The error handling library follows KENL standards:

- **User-space only**: No system modifications required
- **ATOM tagging**: All operations can be tagged for audit trail
- **Rollback instructions**: Every operation includes rollback capability
- **Cross-platform**: Works on Linux, macOS, Windows (Git Bash/WSL)
- **Immutable-aware**: Detects and warns about immutable systems

## Integration with Existing Scripts

To update existing scripts to use the error handling library:

1. Source the library at the top of your script
2. Replace `echo` with `log_info`, `log_error`, etc.
3. Replace manual command checks with `require_command` or `has_command`
4. Add `--dry-run` flag support using `execute_step`
5. Add rollback instructions using `generate_rollback_instructions`

## Related Documentation

- [CONTRIBUTING.md](../../CONTRIBUTING.md) - Contribution guidelines
- [SCRIPT-ENVIRONMENT-TAGGING-STANDARD.md](../../SCRIPT-ENVIRONMENT-TAGGING-STANDARD.md) - Scripting standards
- [OWI_METADATA_STANDARD.md](../../OWI_METADATA_STANDARD.md) - Metadata format

## Version History

- **v1.0.0** (2025-12-05): Initial release with comprehensive error handling

**ATOM:** ATOM-DOC-20251205-004
