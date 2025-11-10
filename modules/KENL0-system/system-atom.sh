#!/usr/bin/env bash
# system-atom.sh
# ATOM trail wrapper for privileged system operations
# Logs all systemwide changes with CTFWI validation

set -euo pipefail

KENL0_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ATOM_TRAIL="$HOME/.config/atom-sage/trail"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BOLD='\033[1m'
RESET='\033[0m'

# Ensure ATOM trail exists
mkdir -p "$ATOM_TRAIL"

# Function: Log system operation to ATOM trail
log_system_atom() {
    local operation="$1"
    local intent="$2"
    local status="${3:-pending}"

    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local date_tag=$(date +"%Y%m%d")
    local counter=$(find "$ATOM_TRAIL" -name "ATOM-SYSTEM-${date_tag}-*" 2>/dev/null | wc -l)
    counter=$((counter + 1))
    local atom_tag=$(printf "ATOM-SYSTEM-%s-%03d" "$date_tag" "$counter")

    cat >> "$ATOM_TRAIL/${atom_tag}.log" <<EOF
ATOM Tag: $atom_tag
Timestamp: $timestamp
Operation: $operation
Intent: $intent
Status: $status
User: $(whoami)
Hostname: $(hostname)
OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)
EOF

    echo "$atom_tag"
}

# Function: Check if running on rpm-ostree system
is_rpm_ostree() {
    command -v rpm-ostree &> /dev/null
}

# Function: Check if running on Bazzite
is_bazzite() {
    [ -f /etc/os-release ] && grep -q "Bazzite" /etc/os-release
}

# Function: Create rollback point before dangerous operations
create_rollback_point() {
    local operation="$1"

    echo -e "${YELLOW}📍 Creating rollback point before: $operation${RESET}"

    if is_rpm_ostree; then
        # rpm-ostree automatically keeps previous deployments
        local current_deployment=$(rpm-ostree status --json | jq -r '.deployments[0].id' 2>/dev/null || echo "unknown")
        echo -e "${GREEN}✅ Current deployment: $current_deployment${RESET}"
        echo "$current_deployment" > /tmp/kenl0-rollback-point
        echo -e "${GREEN}✅ Rollback available via: rpm-ostree rollback${RESET}"
    else
        echo -e "${YELLOW}⚠️  Not an rpm-ostree system, no automatic rollback${RESET}"
    fi
}

# Function: CTFWI validation for system operations
ctfwi_validate() {
    local operation="$1"
    local checklist="${2:-}"

    echo -e "${BOLD}🔍 CTFWI: Checked The Flags, What Intent?${RESET}"
    echo ""

    # Parse checklist from intent
    if [ -n "$checklist" ]; then
        echo -e "${YELLOW}Pre-flight checks:${RESET}"
        while IFS= read -r check; do
            echo "  • $check"
        done <<< "$checklist"
        echo ""
    fi

    # Operation-specific validations
    case "$operation" in
        rebase)
            echo -e "${YELLOW}Validating rebase operation...${RESET}"
            if is_rpm_ostree; then
                echo "  ✅ rpm-ostree available"
                echo "  ✅ Rollback point will be created"
            fi
            ;;
        update)
            echo -e "${YELLOW}Validating update operation...${RESET}"
            if is_rpm_ostree; then
                echo "  ✅ rpm-ostree available"
                # Check if updates available
                if rpm-ostree upgrade --check 2>/dev/null | grep -q "AvailableUpdate"; then
                    echo "  ✅ Updates available"
                else
                    echo "  ℹ️  No updates available"
                fi
            fi
            ;;
        rollback)
            echo -e "${YELLOW}Validating rollback operation...${RESET}"
            if is_rpm_ostree; then
                local deployments=$(rpm-ostree status --json | jq '.deployments | length' 2>/dev/null || echo "0")
                if [ "$deployments" -gt 1 ]; then
                    echo "  ✅ Rollback target available ($deployments deployments)"
                else
                    echo "  ❌ No rollback target (only 1 deployment)"
                    return 1
                fi
            fi
            ;;
    esac

    echo ""
}

# Function: Execute system operation with ATOM trail
execute_system_op() {
    local operation="$1"
    local intent="$2"
    local command="$3"

    # Log start
    local atom_tag=$(log_system_atom "$operation" "$intent" "started")
    echo -e "${GREEN}🏷️  $atom_tag${RESET}"
    echo ""

    # CTFWI validation
    if ! ctfwi_validate "$operation"; then
        log_system_atom "$operation" "$intent" "validation-failed"
        echo -e "${RED}❌ CTFWI validation failed${RESET}"
        exit 1
    fi

    # Create rollback point for dangerous operations
    case "$operation" in
        rebase|update|install)
            create_rollback_point "$operation"
            echo ""
            ;;
    esac

    # Confirm before proceeding
    echo -e "${YELLOW}About to execute:${RESET} $command"
    echo ""
    read -p "Proceed? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_system_atom "$operation" "$intent" "cancelled"
        echo -e "${YELLOW}Operation cancelled${RESET}"
        exit 0
    fi

    # Execute
    echo -e "${BOLD}Executing system operation...${RESET}"
    echo ""

    if eval "$command"; then
        log_system_atom "$operation" "$intent" "success"
        echo ""
        echo -e "${GREEN}✅ Operation completed successfully${RESET}"
        echo -e "${GREEN}🏷️  $atom_tag${RESET}"
        return 0
    else
        local exit_code=$?
        log_system_atom "$operation" "$intent" "failed (exit: $exit_code)"
        echo ""
        echo -e "${RED}❌ Operation failed (exit code: $exit_code)${RESET}"
        echo -e "${YELLOW}💡 Rollback available via: rpm-ostree rollback${RESET}"
        return $exit_code
    fi
}

# Main entry point
main() {
    if [ $# -lt 3 ]; then
        cat <<EOF
Usage: system-atom.sh <operation> <intent> <command>

Examples:
  system-atom.sh rebase "Rebase to Bazzite 40" "rpm-ostree rebase ..."
  system-atom.sh update "Update system packages" "rpm-ostree upgrade"
  system-atom.sh install "Install htop" "rpm-ostree install htop"

All operations are logged to ATOM trail: ~/.config/atom-sage/trail/
EOF
        exit 1
    fi

    local operation="$1"
    local intent="$2"
    local command="$3"

    execute_system_op "$operation" "$intent" "$command"
}

# If sourced, export functions; if executed, run main
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
