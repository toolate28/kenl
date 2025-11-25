#!/usr/bin/env bash
#
# kenl-saif.sh - SAIF (System-Aware Intent Flagging) library for guided user journeys
#
# Provides SAIF flag generation, CTFWI handover, and next-step guidance
# Linux equivalent of KENL.SAIF.psm1
#
# Version: 1.0.0
# ATOM: ATOM-SAIF-20251125-001
#
# Usage:
#   source /path/to/kenl-saif.sh
#   saif_flag=$(new_saif_flag "CONFIG" "MTU" "MTU set to 1492" "Success")
#   write_saif_result "$saif_flag" "Success" "MTU set to 1492" "Test with: ping 8.8.8.8"
#

set -euo pipefail

# ═══════════════════════════════════════════════════════════
# Configuration
# ═══════════════════════════════════════════════════════════

readonly SAIF_VERSION="1.0.0"
readonly SAIF_LOG_PATH="${HOME}/.kenl/saif-trail.log"
readonly SAIF_COUNTER_PATH="${HOME}/.kenl/.saif-counter"
readonly SAIF_DIR="${HOME}/.kenl"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly GRAY='\033[0;90m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# ═══════════════════════════════════════════════════════════
# Core SAIF Functions
# ═══════════════════════════════════════════════════════════

#
# Initialize SAIF system
# Creates directories and counter file if needed
#
init_saif() {
    if [[ ! -d "$SAIF_DIR" ]]; then
        mkdir -p "$SAIF_DIR"
        echo -e "${GREEN}✅ Created SAIF directory: $SAIF_DIR${NC}"
    fi

    if [[ ! -f "$SAIF_COUNTER_PATH" ]]; then
        echo "1" > "$SAIF_COUNTER_PATH"
        echo -e "${GREEN}✅ Initialized SAIF counter${NC}"
    fi

    if [[ ! -f "$SAIF_LOG_PATH" ]]; then
        touch "$SAIF_LOG_PATH"
        echo -e "${GREEN}✅ Created SAIF log: $SAIF_LOG_PATH${NC}"
    fi
}

#
# Generate a new SAIF flag
#
# Arguments:
#   $1 - Action type (VALIDATE, PARTITION, CONFIG, etc.)
#   $2 - Subject (e.g., "MTU", "PREINSTALL", "NETWORK")
#   $3 - Description of what was done
#   $4 - Status (Success, Failure, Warning, Info) - default: Success
#
# Returns:
#   Prints the SAIF flag to stdout
#
# Example:
#   flag=$(new_saif_flag "CONFIG" "MTU" "MTU set to 1492" "Success")
#
new_saif_flag() {
    local action="${1:-CONFIG}"
    local subject="${2:-UNKNOWN}"
    local description="${3:-No description}"
    local status="${4:-Success}"

    # Ensure SAIF is initialized
    init_saif 2>/dev/null

    # Get counter
    local counter
    counter=$(cat "$SAIF_COUNTER_PATH" 2>/dev/null || echo "1")

    # Generate flag
    local timestamp
    timestamp=$(date +%Y%m%d)
    local saif_flag
    saif_flag=$(printf "SAIF-%s-%s-%03d" "$action" "$timestamp" "$counter")

    # Increment counter
    echo $((counter + 1)) > "$SAIF_COUNTER_PATH"

    # Log to SAIF trail (JSON format)
    local log_entry
    log_entry=$(printf '{"timestamp":"%s","flag":"%s","action":"%s","subject":"%s","description":"%s","status":"%s","platform":"Linux"}' \
        "$(date -Iseconds)" "$saif_flag" "$action" "$subject" "$description" "$status")

    echo "$log_entry" >> "$SAIF_LOG_PATH"

    # Output the flag
    echo "$saif_flag"
}

#
# Write SAIF execution result with next-step guidance
#
# Arguments:
#   $1 - SAIF flag
#   $2 - Status (Success, Failure, Warning, Info)
#   $3 - Description
#   $4 - Next step 1
#   $5 - Next step 2 (optional)
#   $6 - Next step 3 (optional)
#   $7 - Log path (optional)
#   $8 - Rollback command (optional)
#
# Example:
#   write_saif_result "$flag" "Success" "MTU set to 1492" \
#       "Verify with: ping 8.8.8.8" \
#       "Check logs at: ~/.kenl/logs/network.log" \
#       "Rollback: sudo ip link set dev eth0 mtu 1500"
#
write_saif_result() {
    local saif_flag="${1:-UNKNOWN}"
    local status="${2:-Success}"
    local description="${3:-Operation completed}"
    local next_step_1="${4:-}"
    local next_step_2="${5:-}"
    local next_step_3="${6:-}"
    local log_path="${7:-}"
    local rollback_cmd="${8:-}"

    # Status icon and color
    local status_icon status_color
    case "$status" in
        Success)
            status_icon="✅"
            status_color="$GREEN"
            ;;
        Failure)
            status_icon="❌"
            status_color="$RED"
            ;;
        Warning)
            status_icon="⚠️"
            status_color="$YELLOW"
            ;;
        Info)
            status_icon="ℹ️"
            status_color="$CYAN"
            ;;
        *)
            status_icon="•"
            status_color="$WHITE"
            ;;
    esac

    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  SAIF Execution Result                                     ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Status and description
    echo -e "  ${status_icon} ${status_color}${description}${NC}"
    echo ""

    # SAIF Flag
    echo -e "  ${GRAY}SAIF Flag:${NC} ${YELLOW}${saif_flag}${NC}"
    echo ""

    # Next steps
    echo -e "  ${CYAN}📋 Next Steps:${NC}"
    [[ -n "$next_step_1" ]] && echo -e "     ${WHITE}→ $next_step_1${NC}"
    [[ -n "$next_step_2" ]] && echo -e "     ${WHITE}→ $next_step_2${NC}"
    [[ -n "$next_step_3" ]] && echo -e "     ${WHITE}→ $next_step_3${NC}"
    echo ""

    # Optional details
    if [[ -n "$log_path" ]]; then
        echo -e "  ${GRAY}📁 Log:${NC} $log_path"
    fi
    if [[ -n "$rollback_cmd" ]]; then
        echo -e "  ${GRAY}↩️  Rollback:${NC} $rollback_cmd"
    fi

    echo -e "${GRAY}─────────────────────────────────────────────────────────────${NC}"
}

#
# Create CTFWI handover document
#
# Arguments:
#   $1 - Title
#   $2 - Phase (e.g., "Step 1 Complete")
#   $3 - Completed actions (comma-separated)
#   $4 - Next actions (comma-separated)
#   $5 - Critical notes (comma-separated, optional)
#   $6 - Output path (optional, defaults to /tmp)
#
# Example:
#   create_handover "Disk Preparation" "Step 1" \
#       "Disk wiped,GPT created" \
#       "Boot Bazzite Live,Run partition script" \
#       "Do not interrupt partitioning"
#
create_handover() {
    local title="${1:-Handover Document}"
    local phase="${2:-Current}"
    local completed_raw="${3:-}"
    local next_raw="${4:-}"
    local notes_raw="${5:-}"
    local output_path="${6:-}"

    # Generate SAIF flag
    local saif_flag
    saif_flag=$(new_saif_flag "HANDOVER" "${title// /-}" "Created handover: $title" "Success")

    # Default output path
    if [[ -z "$output_path" ]]; then
        local timestamp
        timestamp=$(date +%Y%m%d-%H%M%S)
        output_path="/tmp/HANDOVER-${title// /-}-${timestamp}.md"
    fi

    # Parse comma-separated lists
    IFS=',' read -ra completed <<< "$completed_raw"
    IFS=',' read -ra next_actions <<< "$next_raw"
    IFS=',' read -ra notes <<< "$notes_raw"

    # Build document
    cat > "$output_path" << EOF
---
title: $title
classification: CTFWI-HANDOVER
saif: $saif_flag
timestamp: $(date -Iseconds)
phase: $phase
status: handover
---

# $title
## CTFWI Handover Document

**Generated:** $(date '+%Y-%m-%d %H:%M:%S')
**SAIF Flag:** $saif_flag
**Phase:** $phase

---

## Completed Actions

$(for item in "${completed[@]}"; do echo "- ✅ $item"; done)

---

## Next Actions

$(for item in "${next_actions[@]}"; do echo "- ⏳ $item"; done)

---

## Critical Notes

$(if [[ ${#notes[@]} -gt 0 && -n "${notes[0]}" ]]; then
    for note in "${notes[@]}"; do echo "⚠️ $note"; echo ""; done
else
    echo "No critical notes for this handover."
fi)

---

## Status Checklist

$(for item in "${completed[@]}"; do echo "- [x] $item"; done)
$(for item in "${next_actions[@]}"; do echo "- [ ] $item"; done)

---

Generated by KENL SAIF Library v$SAIF_VERSION
EOF

    # Display result
    write_saif_result "$saif_flag" "Success" "Handover document created: $title" \
        "Review handover at: $output_path" \
        "Follow next steps in sequence" \
        "Log continuation with ATOM tag" \
        "$output_path"

    echo ""
    echo -e "  ${CYAN}📝 Handover saved to:${NC}"
    echo -e "     ${WHITE}$output_path${NC}"
    echo ""

    # Return path
    echo "$output_path"
}

#
# Show SAIF trail
#
# Arguments:
#   $1 - Number of entries to show (default: 20)
#   $2 - Action filter (optional)
#
show_saif_trail() {
    local count="${1:-20}"
    local action_filter="${2:-}"

    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  SAIF Trail (Last $count entries)                           ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    if [[ ! -f "$SAIF_LOG_PATH" ]]; then
        echo -e "${YELLOW}No SAIF trail found at: $SAIF_LOG_PATH${NC}"
        return
    fi

    # Parse and display entries
    if command -v jq &> /dev/null; then
        if [[ -n "$action_filter" ]]; then
            tail -n "$count" "$SAIF_LOG_PATH" | jq -r "select(.action == \"$action_filter\") | \"\(.timestamp | split(\"T\")[1] | split(\"+\")[0]) | \(.flag) | \(.status) | \(.description)\""
        else
            tail -n "$count" "$SAIF_LOG_PATH" | jq -r '"\(.timestamp | split("T")[1] | split("+")[0]) | \(.flag) | \(.status) | \(.description)"'
        fi
    else
        # Fallback without jq
        tail -n "$count" "$SAIF_LOG_PATH"
    fi

    echo ""
}

#
# Get SAIF trail entries as JSON array
#
# Arguments:
#   $1 - Number of entries (default: all)
#   $2 - Action filter (optional)
#
get_saif_trail() {
    local count="${1:-0}"
    local action_filter="${2:-}"

    if [[ ! -f "$SAIF_LOG_PATH" ]]; then
        echo "[]"
        return
    fi

    local entries
    if [[ $count -gt 0 ]]; then
        entries=$(tail -n "$count" "$SAIF_LOG_PATH")
    else
        entries=$(cat "$SAIF_LOG_PATH")
    fi

    if [[ -n "$action_filter" ]] && command -v jq &> /dev/null; then
        echo "$entries" | jq -s "[.[] | select(.action == \"$action_filter\")]"
    else
        echo "$entries" | jq -s '.'
    fi
}

# ═══════════════════════════════════════════════════════════
# Convenience Functions
# ═══════════════════════════════════════════════════════════

#
# Quick SAIF for common operations
#

saif_validate() {
    local subject="${1:-VALIDATION}"
    local description="${2:-Validation completed}"
    local status="${3:-Success}"
    local next_step="${4:-Proceed to next phase}"

    local flag
    flag=$(new_saif_flag "VALIDATE" "$subject" "$description" "$status")
    write_saif_result "$flag" "$status" "$description" "$next_step"
    echo "$flag"
}

saif_config() {
    local subject="${1:-CONFIG}"
    local description="${2:-Configuration applied}"
    local status="${3:-Success}"
    local verify_cmd="${4:-}"
    local rollback_cmd="${5:-}"

    local flag
    flag=$(new_saif_flag "CONFIG" "$subject" "$description" "$status")
    write_saif_result "$flag" "$status" "$description" \
        "Configuration complete" \
        "${verify_cmd:+Verify with: $verify_cmd}" \
        "" \
        "" \
        "$rollback_cmd"
    echo "$flag"
}

saif_network() {
    local subject="${1:-NETWORK}"
    local description="${2:-Network operation completed}"
    local status="${3:-Success}"

    local flag
    flag=$(new_saif_flag "NETWORK" "$subject" "$description" "$status")
    write_saif_result "$flag" "$status" "$description" \
        "Verify with: ping 8.8.8.8 or Test-KenlNetwork" \
        "Check logs at: ~/.kenl/logs/network.log" \
        "" \
        "${HOME}/.kenl/logs/network.log"
    echo "$flag"
}

# ═══════════════════════════════════════════════════════════
# Module Load Message
# ═══════════════════════════════════════════════════════════

if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Sourced
    echo -e "${CYAN}KENL SAIF library loaded (v$SAIF_VERSION)${NC}"
    echo -e "${GRAY}  Quick start: flag=\$(new_saif_flag 'CONFIG' 'MySubject' 'What I did')${NC}"
fi
