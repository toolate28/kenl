#!/usr/bin/env bash
# system-functions.sh
# Advanced system functions for Bazzite
# Chainable operations with error handling and SAIF integration
#
# Version: 2.0.0
# ATOM: ATOM-SYS-20251125-001
#
# Usage:
#   source system-functions.sh
#   full-update

# Source core libraries if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=kenl-core.sh
if [[ -f "$SCRIPT_DIR/kenl-core.sh" ]]; then
    source "$SCRIPT_DIR/kenl-core.sh"
else
    # Fallback basic functions if core not available
    kenl_info() { echo "[ℹ] $*"; }
    kenl_success() { echo "[✓] $*"; }
    kenl_warn() { echo "[⚠] $*" >&2; }
    kenl_error() { echo "[✗] $*" >&2; }
    kenl_header() { echo "=== $1 ==="; }
fi

# shellcheck source=kenl-saif.sh
if [[ -f "$SCRIPT_DIR/kenl-saif.sh" ]]; then
    source "$SCRIPT_DIR/kenl-saif.sh"
fi

# ═══════════════════════════════════════════════════════════
# System Update Functions
# ═══════════════════════════════════════════════════════════

# Full system update: rpm-ostree + flatpak + distrobox
full-update() {
    kenl_header "Full System Update"
    kenl_info "Starting full system update..."
    echo ""

    local errors=0

    # Update rpm-ostree
    kenl_info "1/3: Updating base system (rpm-ostree)..."
    if rpm-ostree upgrade; then
        kenl_success "Base system updated"
    else
        kenl_warn "Base system update failed or no updates available"
        ((errors++)) || true
    fi
    echo ""

    # Update flatpaks
    kenl_info "2/3: Updating Flatpak applications..."
    if flatpak update -y; then
        kenl_success "Flatpaks updated"
    else
        kenl_warn "Flatpak update failed or no updates available"
        ((errors++)) || true
    fi
    echo ""

    # Update distrobox containers
    kenl_info "3/3: Updating distrobox containers..."
    for container in $(distrobox list --no-color 2>/dev/null | awk 'NR>1 {print $3}'); do
        kenl_info "  Updating: $container"
        distrobox enter "$container" -- sh -c 'command -v apt && sudo apt update && sudo apt upgrade -y || command -v dnf && sudo dnf upgrade -y || command -v pacman && sudo pacman -Syu --noconfirm' 2>/dev/null || true
    done
    kenl_success "Distrobox containers updated"
    echo ""

    # Generate SAIF result if available
    if command -v new_saif_flag &> /dev/null; then
        local status="Success"
        [[ $errors -gt 0 ]] && status="Warning"

        local flag
        flag=$(new_saif_flag "CONFIG" "FULL-UPDATE" "Full system update completed" "$status")
        write_saif_result "$flag" "$status" "Full system update completed" \
            "Reboot to apply rpm-ostree changes: systemctl reboot" \
            "Check update status: rpm-ostree status" \
            "Rollback if issues: rpm-ostree rollback && systemctl reboot"
    else
        kenl_success "Full system update complete!"
        echo ""
        echo "📋 Next Steps:"
        echo "   → Reboot to apply rpm-ostree changes: systemctl reboot"
        echo "   → Check update status: rpm-ostree status"
        echo "   → Rollback if issues: rpm-ostree rollback && systemctl reboot"
        echo ""
    fi
}

# Quick update check (no changes)
check-updates() {
    kenl_header "Update Check"
    kenl_info "Checking for available updates..."
    echo ""

    kenl_info "1/3: rpm-ostree updates..."
    rpm-ostree upgrade --check || true
    echo ""

    kenl_info "2/3: Flatpak updates..."
    flatpak remote-ls --updates 2>/dev/null || true
    echo ""

    kenl_info "3/3: System info..."
    rpm-ostree status

    echo ""
    echo "📋 Next Steps:"
    echo "   → Apply updates: full-update"
    echo "   → Update specific: rpm-ostree upgrade or flatpak update"
}

# ═══════════════════════════════════════════════════════════
# Rebase Functions
# ═══════════════════════════════════════════════════════════

# Safe rebase with backup
safe-rebase() {
    local target="${1:-stable}"

    kenl_header "Safe Rebase"
    kenl_info "Rebasing to: $target"
    echo ""

    kenl_info "Current deployment:"
    rpm-ostree status | head -n 10
    echo ""

    if ! kenl_confirm "Proceed with rebase to $target?"; then
        kenl_warn "Cancelled"
        return 1
    fi

    # Perform rebase
    if rpm-ostree rebase "ostree-image-signed:docker://ghcr.io/ublue-os/bazzite:$target"; then
        # Generate SAIF result if available
        if command -v new_saif_flag &> /dev/null; then
            local flag
            flag=$(new_saif_flag "DEPLOY" "REBASE-$target" "Rebased to $target" "Success")
            write_saif_result "$flag" "Success" "Rebase to $target completed" \
                "Reboot to activate: systemctl reboot" \
                "Rollback if issues: rpm-ostree rollback && systemctl reboot" \
                "Check status: rpm-ostree status"
        else
            kenl_success "Rebase successful!"
            echo ""
            kenl_info "New deployment:"
            rpm-ostree status | head -n 10
            echo ""
            echo "📋 Next Steps:"
            echo "   → Reboot to activate: systemctl reboot"
            echo "   → Rollback if issues: rpm-ostree rollback && systemctl reboot"
        fi
    else
        kenl_error "Rebase failed"
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════
# Cleanup Functions
# ═══════════════════════════════════════════════════════════

# Deep clean: rpm-ostree + flatpak + caches
deep-clean() {
    kenl_header "Deep System Cleanup"
    kenl_info "Starting deep cleanup..."
    echo ""

    # rpm-ostree cleanup
    kenl_info "1/5: Cleaning rpm-ostree deployments..."
    rpm-ostree cleanup --rollback --pending || true
    kenl_success "rpm-ostree cleaned"
    echo ""

    # Flatpak unused runtimes
    kenl_info "2/5: Removing unused Flatpak runtimes..."
    flatpak uninstall --unused -y 2>/dev/null || true
    kenl_success "Flatpak runtimes cleaned"
    echo ""

    # User cache
    kenl_info "3/5: Cleaning user cache..."
    rm -rf ~/.cache/thumbnails/* 2>/dev/null || true
    rm -rf ~/.cache/mesa_shader_cache/* 2>/dev/null || true
    kenl_success "User cache cleaned"
    echo ""

    # Distrobox containers
    kenl_info "4/5: Cleaning distrobox containers..."
    for container in $(distrobox list --no-color 2>/dev/null | awk 'NR>1 {print $3}'); do
        kenl_info "  Cleaning: $container"
        distrobox enter "$container" -- sh -c 'command -v apt && sudo apt autoremove -y && sudo apt autoclean || command -v dnf && sudo dnf autoremove -y || command -v pacman && sudo pacman -Sc --noconfirm' 2>/dev/null || true
    done
    kenl_success "Distrobox containers cleaned"
    echo ""

    # Journal logs (keep last 7 days)
    kenl_info "5/5: Cleaning old journal logs..."
    sudo journalctl --vacuum-time=7d 2>/dev/null || true
    kenl_success "Journal logs cleaned"
    echo ""

    # Report space freed
    if command -v new_saif_flag &> /dev/null; then
        local flag
        flag=$(new_saif_flag "CONFIG" "DEEP-CLEAN" "Deep system cleanup completed" "Success")
        write_saif_result "$flag" "Success" "Deep system cleanup completed" \
            "Verify disk space: df -h /" \
            "Check rpm-ostree status: rpm-ostree status" \
            "Run health check: health-check"
    else
        kenl_success "Deep clean complete!"
        echo ""
        echo "📋 Disk Space:"
        df -h / | tail -1
        echo ""
        echo "📋 Next Steps:"
        echo "   → Verify disk space: df -h /"
        echo "   → Run health check: health-check"
    fi
}

# ═══════════════════════════════════════════════════════════
# Rollback Functions
# ═══════════════════════════════════════════════════════════

# Emergency rollback and reboot
emergency-rollback() {
    kenl_header "Emergency Rollback"
    kenl_warn "Emergency rollback initiated"
    echo ""

    kenl_info "Previous deployment:"
    rpm-ostree status | grep -A 5 "● (rollback)" || true
    echo ""

    if kenl_confirm "Rollback and reboot NOW?"; then
        if command -v new_saif_flag &> /dev/null; then
            local flag
            flag=$(new_saif_flag "RESTORE" "EMERGENCY-ROLLBACK" "Emergency rollback initiated" "Warning")
            write_saif_result "$flag" "Warning" "Emergency rollback initiated" \
                "System will reboot immediately" \
                "Previous deployment will be activated" \
                "No further action needed"
        fi
        rpm-ostree rollback && systemctl reboot
    else
        kenl_warn "Cancelled"
    fi
}

# ═══════════════════════════════════════════════════════════
# Gaming Functions
# ═══════════════════════════════════════════════════════════

# Update gaming stack
update-gaming() {
    kenl_header "Gaming Stack Update"
    kenl_info "Updating gaming stack..."
    echo ""

    local errors=0

    # Update Proton-GE
    kenl_info "1/3: Updating Proton-GE..."
    if command -v ujust &> /dev/null; then
        if ! ujust install-proton-ge; then
            ((errors++))
        fi
    else
        kenl_warn "ujust not found, skipping Proton-GE update"
    fi
    echo ""

    # Update Steam
    kenl_info "2/3: Updating Steam..."
    if ! flatpak update -y com.valvesoftware.Steam 2>/dev/null; then
        ((errors++))
    fi
    echo ""

    # Update gaming-related flatpaks
    kenl_info "3/3: Updating gaming applications..."
    flatpak update -y \
        org.freedesktop.Platform.VulkanLayer.MangoHud \
        org.freedesktop.Platform.VulkanLayer.gamescope \
        net.davidotek.pupgui2 2>/dev/null || true
    echo ""

    if command -v new_saif_flag &> /dev/null; then
        local status="Success"
        [[ $errors -gt 0 ]] && status="Warning"

        local flag
        flag=$(new_saif_flag "GAMING" "UPDATE-GAMING" "Gaming stack update completed" "$status")
        write_saif_result "$flag" "$status" "Gaming stack updated" \
            "Launch Steam: flatpak run com.valvesoftware.Steam" \
            "Check Proton version: check-proton <app_id>" \
            "Create Play Card: cd modules/KENL2-gaming && ./create-playcard.sh"
    else
        kenl_success "Gaming stack updated!"
        echo ""
        echo "📋 Next Steps:"
        echo "   → Launch Steam: flatpak run com.valvesoftware.Steam"
        echo "   → Check Proton: check-proton <steam_app_id>"
    fi
}

# Check Proton compatibility
check-proton() {
    local game_id="$1"

    if [[ -z "$game_id" ]]; then
        kenl_error "Usage: check-proton <steam_app_id>"
        echo "Example: check-proton 1086940  # Baldur's Gate 3"
        return 1
    fi

    kenl_info "Checking ProtonDB for app ID: $game_id"
    echo "URL: https://www.protondb.com/app/$game_id"
    echo ""

    # Try to open in browser if available
    if command -v xdg-open &> /dev/null; then
        xdg-open "https://www.protondb.com/app/$game_id" 2>/dev/null &
    fi

    echo "📋 Next Steps:"
    echo "   → Review ProtonDB ratings"
    echo "   → Create Play Card: cd modules/KENL2-gaming && ./create-playcard.sh \"Game Name\""
}

# ═══════════════════════════════════════════════════════════
# Diagnostics Functions
# ═══════════════════════════════════════════════════════════

# System health check
health-check() {
    kenl_header "System Health Check"
    echo ""

    # rpm-ostree status
    kenl_info "📦 rpm-ostree deployments:"
    rpm-ostree status
    echo ""

    # Disk space
    kenl_info "💾 Disk space:"
    df -h / /home /var 2>/dev/null | grep -v tmpfs || df -h /
    echo ""

    # Memory
    kenl_info "🧠 Memory usage:"
    free -h 2>/dev/null || true
    echo ""

    # Failed services
    kenl_info "⚠️  Failed systemd services:"
    systemctl list-units --state=failed --no-pager 2>/dev/null || true
    echo ""

    # Journal errors (last boot)
    kenl_info "📋 Recent errors (last boot):"
    journalctl -b -p err --no-pager 2>/dev/null | tail -20 || true
    echo ""

    if command -v new_saif_flag &> /dev/null; then
        local flag
        flag=$(new_saif_flag "TEST" "HEALTH-CHECK" "System health check completed" "Success")
        write_saif_result "$flag" "Success" "System health check completed" \
            "Review any failed services above" \
            "Generate full report: system-report" \
            "Deep clean if needed: deep-clean"
    else
        kenl_divider
        kenl_success "Health check complete"
        echo ""
        echo "📋 Next Steps:"
        echo "   → Generate full report: system-report"
        echo "   → Deep clean if needed: deep-clean"
    fi
}

# Generate system report
system-report() {
    local report_file
    report_file="/tmp/system-report-$(date +%Y%m%d-%H%M%S).txt"

    kenl_info "Generating system report: $report_file"
    echo ""

    {
        echo "System Report - $(date)"
        echo "════════════════════════════════════════════════════════════"
        echo ""

        echo "OS Information:"
        cat /etc/os-release 2>/dev/null || echo "N/A"
        echo ""

        echo "Kernel:"
        uname -a
        echo ""

        echo "rpm-ostree Status:"
        rpm-ostree status 2>/dev/null || echo "N/A"
        echo ""

        echo "Flatpak Applications:"
        flatpak list 2>/dev/null || echo "N/A"
        echo ""

        echo "Distrobox Containers:"
        distrobox list 2>/dev/null || echo "N/A"
        echo ""

        echo "Disk Usage:"
        df -h 2>/dev/null || echo "N/A"
        echo ""

        echo "Memory:"
        free -h 2>/dev/null || echo "N/A"
        echo ""

        echo "Failed Services:"
        systemctl list-units --state=failed 2>/dev/null || echo "N/A"
        echo ""

        echo "Recent Errors:"
        journalctl -b -p err --no-pager 2>/dev/null | tail -50 || echo "N/A"
        echo ""

    } > "$report_file"

    if command -v new_saif_flag &> /dev/null; then
        local flag
        flag=$(new_saif_flag "TEST" "SYSTEM-REPORT" "System report generated" "Success")
        write_saif_result "$flag" "Success" "System report generated" \
            "View report: cat $report_file" \
            "Open in editor: \$EDITOR $report_file" \
            "Share with support if needed"
    else
        kenl_success "Report generated: $report_file"
        echo ""
        echo "📋 Next Steps:"
        echo "   → View: cat $report_file"
        echo "   → Edit: \$EDITOR $report_file"
    fi
}

# ═══════════════════════════════════════════════════════════
# Module load message
# ═══════════════════════════════════════════════════════════

if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    kenl_success "Bazzite system functions loaded (KENL0)"
    echo "   Available: full-update, check-updates, safe-rebase, deep-clean,"
    echo "              emergency-rollback, update-gaming, check-proton,"
    echo "              health-check, system-report"
fi
