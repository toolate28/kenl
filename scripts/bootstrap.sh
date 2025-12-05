#!/usr/bin/env bash
#───────────────────────────────────────────────────────────────────────────────
# KENL Bootstrap Script
# Installs pre-commit hooks and runs initial setup checks
#───────────────────────────────────────────────────────────────────────────────
#
# Purpose: Initialize KENL development environment with pre-commit hooks
# Prerequisites: Python 3 or Homebrew
# Usage: ./bootstrap.sh [--dry-run]
# Options:
#   --dry-run       Show what would be done without making changes
#   --help          Show this help message
# Output: Configured pre-commit hooks and validation results
# Next steps:
#   - Make changes to code
#   - Commit with `git commit` (hooks will run automatically)
#   - Run tests with `pytest` (if available)
# Integration:
#   - Uses KENL error handling library
#   - Follows ATOM tagging standards
# Related: See CONTRIBUTING.md for development setup
#
# Version: 2.0.0
# ATOM: ATOM-TOOL-20251205-002
#

set -euo pipefail

# Get script directory and load error handling library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/lib/error-handling.sh" ]; then
    # shellcheck source=lib/error-handling.sh
    source "$SCRIPT_DIR/lib/error-handling.sh"
else
    # Fallback if library not found (backwards compatibility)
    log_warn() { echo "[WARN] $*" >&2; }
    log_info() { echo "[INFO] $*"; }
    log_success() { echo "[SUCCESS] $*"; }
    log_error() { echo "[ERROR] $*" >&2; }
fi

# Options
DRY_RUN=false

#───────────────────────────────────────────────────────────────────────────────
# Functions
#───────────────────────────────────────────────────────────────────────────────

show_help() {
    cat << 'EOF'
KENL Bootstrap Script

Usage: ./bootstrap.sh [OPTIONS]

Installs pre-commit hooks and runs initial setup checks for KENL development.

Options:
  --dry-run    Show what would be done without making changes
  --help       Show this help message

Examples:
  ./bootstrap.sh            # Normal installation
  ./bootstrap.sh --dry-run  # Preview changes

For more information, see CONTRIBUTING.md
EOF
}

check_python_installation() {
    log_info "Checking for Python installation..."

    if has_command python3; then
        local python_version
        python_version=$(python3 --version 2>&1 | cut -d' ' -f2)
        log_success "Found Python 3: $python_version"
        return 0
    elif has_command python; then
        local python_version
        python_version=$(python --version 2>&1 | cut -d' ' -f2)
        log_success "Found Python: $python_version"
        return 0
    else
        log_error "Python not found"
        log_error "Python 3 is required for pre-commit hooks"
        suggest_recovery "missing_dependency"
        return 1
    fi
}

check_pip_installation() {
    log_info "Checking for pip installation..."

    if has_command pip3; then
        log_success "Found pip3"
        return 0
    elif has_command pip; then
        log_success "Found pip"
        return 0
    else
        log_warn "pip not found"
        log_warn "pip is recommended for installing pre-commit"

        if has_command python3; then
            log_info "Try installing pip with: python3 -m ensurepip --user"
        fi

        return 1
    fi
}

install_precommit() {
    log_info "Installing pre-commit..."

    if [ "$DRY_RUN" = "true" ]; then
        log_info "[DRY RUN] Would install pre-commit via pip"
        return 0
    fi

    local pip_cmd=""
    if has_command pip3; then
        pip_cmd="pip3"
    elif has_command pip; then
        pip_cmd="pip"
    else
        log_error "No pip command available"
        return 1
    fi

    if $pip_cmd install --user pre-commit; then
        log_success "pre-commit installed successfully"
        return 0
    else
        log_warn "Failed to install pre-commit via pip"
        log_warn "You can try installing via Homebrew: brew install pre-commit"
        return 1
    fi
}

install_precommit_hooks() {
    log_info "Installing pre-commit hooks..."

    if [ "$DRY_RUN" = "true" ]; then
        log_info "[DRY RUN] Would install pre-commit hooks in .git/hooks/"
        return 0
    fi

    if ! has_command pre-commit; then
        log_error "pre-commit command not found"
        log_error "Installation may have failed or ~/.local/bin not in PATH"
        log_info "Add to PATH: export PATH=\"\$HOME/.local/bin:\$PATH\""
        return 1
    fi

    if pre-commit install; then
        log_success "pre-commit hooks installed"
        return 0
    else
        log_error "Failed to install pre-commit hooks"
        return 1
    fi
}

run_precommit_checks() {
    log_info "Running pre-commit on all files..."

    if [ "$DRY_RUN" = "true" ]; then
        log_info "[DRY RUN] Would run: pre-commit run --all-files"
        return 0
    fi

    if ! has_command pre-commit; then
        log_warn "pre-commit not available, skipping validation"
        return 1
    fi

    echo ""
    echo "═══════════════════════════════════════════════════════════"

    if pre-commit run --all-files; then
        echo "═══════════════════════════════════════════════════════════"
        log_success "All pre-commit checks passed"
        return 0
    else
        echo "═══════════════════════════════════════════════════════════"
        log_warn "Some pre-commit checks failed"
        log_info "This is normal for first run - hooks may have fixed issues"
        log_info "Commit the changes and run again if needed"
        return 0  # Don't fail bootstrap on pre-commit warnings
    fi
}

check_test_infrastructure() {
    log_info "Checking for test infrastructure..."

    if has_command pytest; then
        log_success "pytest found - run tests with: pytest"
        return 0
    else
        log_info "pytest not found (optional)"
        log_info "Install with: pip install --user pytest"
        return 1
    fi
}

show_next_steps() {
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  Bootstrap Complete!"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo "Next steps:"
    echo ""
    echo "  1. Make changes to code or documentation"
    echo "  2. Stage changes: git add ."
    echo "  3. Commit: git commit -m 'your message'"
    echo "     → Pre-commit hooks will run automatically"
    echo ""
    echo "  4. Run tests (if available): pytest"
    echo ""
    echo "For more information:"
    echo "  - Read CONTRIBUTING.md for contribution guidelines"
    echo "  - Read GETTING-STARTED.md for general usage"
    echo "  - Check .pre-commit-config.yaml for hook configuration"
    echo ""
    echo "═══════════════════════════════════════════════════════════"
}

#───────────────────────────────────────────────────────────────────────────────
# Main Execution
#───────────────────────────────────────────────────────────────────────────────

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  KENL Bootstrap Script v2.0"
    echo "═══════════════════════════════════════════════════════════"
    echo ""

    if [ "$DRY_RUN" = "true" ]; then
        log_info "Running in DRY RUN mode - no changes will be made"
        echo ""
    fi

    # Check prerequisites
    local errors=0

    check_python_installation || ((errors++))
    check_pip_installation || ((errors++))

    if [ $errors -gt 0 ]; then
        echo ""
        log_error "Prerequisites check failed"
        log_error "Please install Python and pip before continuing"
        suggest_recovery "missing_dependency"
        exit 1
    fi

    echo ""

    # Install pre-commit if not present
    if has_command pre-commit; then
        log_success "pre-commit already installed"
    else
        install_precommit || {
            log_error "Failed to install pre-commit"
            log_info "Try manual installation:"
            log_info "  - Via pip: pip install --user pre-commit"
            log_info "  - Via Homebrew: brew install pre-commit"
            exit 1
        }
    fi

    # Install hooks
    install_precommit_hooks || {
        log_error "Failed to install pre-commit hooks"
        exit 1
    }

    # Run validation
    run_precommit_checks

    # Check for test infrastructure (optional)
    echo ""
    check_test_infrastructure

    # Show next steps
    show_next_steps

    # Generate rollback instructions
    if [ "$DRY_RUN" = "false" ]; then
        echo ""
        generate_rollback_instructions \
            "pre-commit installation" \
            "pre-commit uninstall && pip uninstall pre-commit"
    fi
}

main "$@"
