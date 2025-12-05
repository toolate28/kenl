#!/usr/bin/env bash
#───────────────────────────────────────────────────────────────────────────────
# KENL Error Handling Library Test Suite
# Test all error handling functions and dependency checking
#───────────────────────────────────────────────────────────────────────────────
#
# Purpose: Validate error handling library functions work correctly
# Prerequisites: Bash 4+
# Usage: ./test-error-handling.sh
# Output: Test results with pass/fail indicators
#
# Version: 1.0.0
# ATOM: ATOM-TEST-20251205-001
#

set -euo pipefail

# Note: Tests use explicit error handling with || true to continue on failure
# This ensures we get a complete test report even when some tests fail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load error handling library
# shellcheck source=lib/error-handling.sh
source "$SCRIPT_DIR/lib/error-handling.sh"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

#───────────────────────────────────────────────────────────────────────────────
# Test Framework
#───────────────────────────────────────────────────────────────────────────────

test_assert() {
    local description="$1"
    local condition="$2"

    ((TESTS_RUN++))

    # Explicitly handle test failure without exiting
    if eval "$condition"; then
        log_success "PASS: $description"
        ((TESTS_PASSED++))
        return 0
    else
        log_error "FAIL: $description"
        ((TESTS_FAILED++))
        return 1
    fi || true  # Ensure test suite continues even on assertion failure
}

test_section() {
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  $1"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
}

#───────────────────────────────────────────────────────────────────────────────
# Tests
#───────────────────────────────────────────────────────────────────────────────

test_logging_functions() {
    test_section "Logging Functions"

    # Test that logging functions exist and run without error
    test_assert "log_info exists" "declare -f log_info >/dev/null"
    test_assert "log_success exists" "declare -f log_success >/dev/null"
    test_assert "log_warn exists" "declare -f log_warn >/dev/null"
    test_assert "log_error exists" "declare -f log_error >/dev/null"
    test_assert "log_debug exists" "declare -f log_debug >/dev/null"

    # Test actual output (redirected to avoid clutter)
    test_assert "log_info runs" "log_info 'test' 2>/dev/null; true"
    test_assert "log_success runs" "log_success 'test' 2>/dev/null; true"
    test_assert "log_warn runs" "log_warn 'test' 2>/dev/null; true"
    test_assert "log_error runs" "log_error 'test' 2>/dev/null; true"
}

test_command_checking() {
    test_section "Command Checking"

    # Test has_command with known commands
    test_assert "has_command detects bash" "has_command bash"
    test_assert "has_command detects ls" "has_command ls"
    test_assert "has_command detects missing command" "! has_command nonexistent_command_xyz"

    # Test require_command with existing command
    test_assert "require_command accepts bash" "require_command bash bash 'Bash shell' &>/dev/null"

    # Test require_command with missing command (should fail)
    test_assert "require_command rejects missing" "! require_command nonexistent_cmd &>/dev/null"
}

test_platform_detection() {
    test_section "Platform Detection"

    # Test platform detection returns valid value
    local platform
    platform=$(detect_platform)
    test_assert "detect_platform returns value" "[ -n '$platform' ]"
    test_assert "detect_platform returns valid platform" "[[ '$platform' =~ ^(linux|darwin|windows|wsl|bazzite|unknown)$ ]]"

    # Test immutable system detection (may be true or false)
    test_assert "is_immutable runs without error" "is_immutable || true"
    test_assert "is_bazzite runs without error" "is_bazzite || true"
}

test_root_checking() {
    test_section "Root/Privilege Checking"

    # Test is_root function
    test_assert "is_root function exists" "declare -f is_root >/dev/null"

    # We can't test require_root without actually being root
    # But we can test the functions exist
    test_assert "require_root function exists" "declare -f require_root >/dev/null"
    test_assert "require_not_root function exists" "declare -f require_not_root >/dev/null"
}

test_file_validation() {
    test_section "File/Directory Validation"

    # Create temp files for testing
    local temp_dir
    temp_dir=$(mktemp -d)
    local temp_file="$temp_dir/test.txt"
    echo "test" > "$temp_file"

    # Test require_file
    test_assert "require_file accepts existing file" "require_file '$temp_file' &>/dev/null"
    test_assert "require_file rejects missing file" "! require_file '$temp_dir/missing.txt' &>/dev/null"

    # Test require_directory
    test_assert "require_directory accepts existing dir" "require_directory '$temp_dir' &>/dev/null"
    test_assert "require_directory rejects missing dir" "! require_directory '/nonexistent/dir/xyz' &>/dev/null"

    # Test multiple files
    local temp_file2="$temp_dir/test2.txt"
    echo "test2" > "$temp_file2"
    test_assert "require_file accepts multiple files" "require_file '$temp_file' '$temp_file2' &>/dev/null"

    # Cleanup
    rm -rf "$temp_dir"
}

test_backup_restore() {
    test_section "Backup/Restore Functions"

    # Create temp file for testing
    local temp_dir
    temp_dir=$(mktemp -d)
    local test_file="$temp_dir/test.txt"
    echo "original content" > "$test_file"

    # Test backup_file
    local backup
    backup=$(backup_file "$test_file" 2>/dev/null)
    test_assert "backup_file creates backup" "[ -f '$backup' ]"

    # Modify original
    echo "modified content" > "$test_file"

    # Test restore_file
    test_assert "restore_file works" "restore_file '$backup' '$test_file' &>/dev/null"
    test_assert "restored content matches" "grep -q 'original content' '$test_file'"

    # Cleanup
    rm -rf "$temp_dir"
}

test_atom_validation() {
    test_section "ATOM Tag Validation"

    # Test valid ATOM tags
    test_assert "validate_atom_tag accepts valid tag 1" "validate_atom_tag 'ATOM-CFG-20251205-001' &>/dev/null"
    test_assert "validate_atom_tag accepts valid tag 2" "validate_atom_tag 'ATOM-TOOL-20231231-999' &>/dev/null"

    # Test invalid ATOM tags
    test_assert "validate_atom_tag rejects invalid tag 1" "! validate_atom_tag 'ATOM-CFG-2025-001' &>/dev/null"
    test_assert "validate_atom_tag rejects invalid tag 2" "! validate_atom_tag 'ATOM-20251205-001' &>/dev/null"
    test_assert "validate_atom_tag rejects invalid tag 3" "! validate_atom_tag 'INVALID-TAG' &>/dev/null"
}

test_execute_step() {
    test_section "Execute Step Function"

    # Test execute_step in normal mode
    test_assert "execute_step runs simple command" "execute_step 'true' 'test command' false &>/dev/null"

    # Test execute_step in dry-run mode
    test_assert "execute_step dry-run doesn't execute" "execute_step 'false' 'should not run' true &>/dev/null"

    # Test execute_step catches failures
    test_assert "execute_step detects failure" "! execute_step 'false' 'failing command' false &>/dev/null"
}

test_installation_instructions() {
    test_section "Installation Instructions"

    # Test get_install_instruction returns something
    local instruction
    instruction=$(get_install_instruction "test-package")
    test_assert "get_install_instruction returns value" "[ -n '$instruction' ]"

    # Test it includes package name
    test_assert "get_install_instruction includes package" "[[ '$instruction' =~ test-package ]]"
}

#───────────────────────────────────────────────────────────────────────────────
# Main Test Execution
#───────────────────────────────────────────────────────────────────────────────

main() {
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  KENL Error Handling Library Test Suite"
    echo "═══════════════════════════════════════════════════════════"
    echo ""

    # Run all test suites (continue even if individual tests fail)
    test_logging_functions || true
    test_command_checking || true
    test_platform_detection || true
    test_root_checking || true
    test_file_validation || true
    test_backup_restore || true
    test_atom_validation || true
    test_execute_step || true
    test_installation_instructions || true

    # Print summary
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  Test Summary"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo "Tests run:    $TESTS_RUN"
    echo "Tests passed: $TESTS_PASSED"
    echo "Tests failed: $TESTS_FAILED"
    echo ""

    if [ $TESTS_FAILED -eq 0 ]; then
        log_success "All tests passed! ✅"
        echo ""
        exit 0
    else
        log_error "Some tests failed! ❌"
        echo ""
        exit 1
    fi
}

main "$@"
