#!/usr/bin/env bash
# system-functions.sh
# Advanced system functions for Bazzite
# Chainable operations with error handling

# ═══════════════════════════════════════════════════════════
# System Update Functions
# ═══════════════════════════════════════════════════════════

# Full system update: rpm-ostree + flatpak + distrobox
full-update() {
    echo "🔄 Full system update starting..."
    echo ""

    # Update rpm-ostree
    echo "1/3: Updating base system (rpm-ostree)..."
    if rpm-ostree upgrade; then
        echo "✅ Base system updated"
    else
        echo "⚠️  Base system update failed or no updates available"
    fi
    echo ""

    # Update flatpaks
    echo "2/3: Updating Flatpak applications..."
    if flatpak update -y; then
        echo "✅ Flatpaks updated"
    else
        echo "⚠️  Flatpak update failed or no updates available"
    fi
    echo ""

    # Update distrobox containers
    echo "3/3: Updating distrobox containers..."
    for container in $(distrobox list --no-color | awk 'NR>1 {print $3}'); do
        echo "  Updating: $container"
        distrobox enter "$container" -- sh -c 'command -v apt && sudo apt update && sudo apt upgrade -y || command -v dnf && sudo dnf upgrade -y || command -v pacman && sudo pacman -Syu --noconfirm' 2>/dev/null
    done
    echo "✅ Distrobox containers updated"
    echo ""

    echo "✅ Full system update complete!"
    echo ""
    echo "Next: Reboot to apply rpm-ostree changes: systemctl reboot"
}

# Quick update check (no changes)
check-updates() {
    echo "🔍 Checking for available updates..."
    echo ""

    echo "1/3: rpm-ostree updates..."
    rpm-ostree upgrade --check
    echo ""

    echo "2/3: Flatpak updates..."
    flatpak remote-ls --updates
    echo ""

    echo "3/3: System info..."
    rpm-ostree status
}

# ═══════════════════════════════════════════════════════════
# Rebase Functions
# ═══════════════════════════════════════════════════════════

# Safe rebase with backup
safe-rebase() {
    local target="${1:-stable}"

    echo "🔄 Safe rebase to: $target"
    echo ""
    echo "Current deployment:"
    rpm-ostree status | head -n 10
    echo ""

    read -p "Proceed with rebase to $target? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        return 1
    fi

    # Perform rebase
    if rpm-ostree rebase "ostree-image-signed:docker://ghcr.io/ublue-os/bazzite:$target"; then
        echo ""
        echo "✅ Rebase successful!"
        echo ""
        echo "New deployment:"
        rpm-ostree status | head -n 10
        echo ""
        echo "Next: Reboot to activate: systemctl reboot"
        echo "Rollback available if issues: rpm-ostree rollback && systemctl reboot"
    else
        echo ""
        echo "❌ Rebase failed"
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════
# Cleanup Functions
# ═══════════════════════════════════════════════════════════

# Deep clean: rpm-ostree + flatpak + caches
deep-clean() {
    echo "🧹 Deep system cleanup starting..."
    echo ""

    # rpm-ostree cleanup
    echo "1/5: Cleaning rpm-ostree deployments..."
    rpm-ostree cleanup --rollback --pending
    echo "✅ rpm-ostree cleaned"
    echo ""

    # Flatpak unused runtimes
    echo "2/5: Removing unused Flatpak runtimes..."
    flatpak uninstall --unused -y
    echo "✅ Flatpak runtimes cleaned"
    echo ""

    # User cache
    echo "3/5: Cleaning user cache..."
    rm -rf ~/.cache/thumbnails/*
    rm -rf ~/.cache/mesa_shader_cache/*
    echo "✅ User cache cleaned"
    echo ""

    # Distrobox containers
    echo "4/5: Cleaning distrobox containers..."
    for container in $(distrobox list --no-color | awk 'NR>1 {print $3}'); do
        echo "  Cleaning: $container"
        distrobox enter "$container" -- sh -c 'command -v apt && sudo apt autoremove -y && sudo apt autoclean || command -v dnf && sudo dnf autoremove -y || command -v pacman && sudo pacman -Sc --noconfirm' 2>/dev/null
    done
    echo "✅ Distrobox containers cleaned"
    echo ""

    # Journal logs (keep last 7 days)
    echo "5/5: Cleaning old journal logs..."
    sudo journalctl --vacuum-time=7d
    echo "✅ Journal logs cleaned"
    echo ""

    # Report space freed
    echo "✅ Deep clean complete!"
    df -h / | tail -1
}

# ═══════════════════════════════════════════════════════════
# Rollback Functions
# ═══════════════════════════════════════════════════════════

# Emergency rollback and reboot
emergency-rollback() {
    echo "🚨 Emergency rollback initiated"
    echo ""
    echo "Previous deployment:"
    rpm-ostree status | grep -A 5 "● (rollback)"
    echo ""

    read -p "Rollback and reboot NOW? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rpm-ostree rollback && systemctl reboot
    else
        echo "Cancelled"
    fi
}

# ═══════════════════════════════════════════════════════════
# Gaming Functions
# ═══════════════════════════════════════════════════════════

# Update gaming stack
update-gaming() {
    echo "🎮 Updating gaming stack..."
    echo ""

    # Update Proton-GE
    echo "1/3: Updating Proton-GE..."
    if command -v ujust &> /dev/null; then
        ujust install-proton-ge
    else
        echo "⚠️  ujust not found, skipping Proton-GE update"
    fi
    echo ""

    # Update Steam
    echo "2/3: Updating Steam..."
    flatpak update -y com.valvesoftware.Steam
    echo ""

    # Update gaming-related flatpaks
    echo "3/3: Updating gaming applications..."
    flatpak update -y \
        org.freedesktop.Platform.VulkanLayer.MangoHud \
        org.freedesktop.Platform.VulkanLayer.gamescope \
        net.davidotek.pupgui2 2>/dev/null || true
    echo ""

    echo "✅ Gaming stack updated!"
}

# Check Proton compatibility
check-proton() {
    local game_id="$1"

    if [ -z "$game_id" ]; then
        echo "Usage: check-proton <steam_app_id>"
        echo "Example: check-proton 1086940  # Baldur's Gate 3"
        return 1
    fi

    echo "🔍 Checking ProtonDB for app ID: $game_id"
    echo "URL: https://www.protondb.com/app/$game_id"
    echo ""

    # Try to open in browser if available
    if command -v xdg-open &> /dev/null; then
        xdg-open "https://www.protondb.com/app/$game_id" 2>/dev/null &
    fi
}

# ═══════════════════════════════════════════════════════════
# Diagnostics Functions
# ═══════════════════════════════════════════════════════════

# System health check
health-check() {
    echo "🏥 System health check"
    echo "════════════════════════════════════════════════════════════"
    echo ""

    # rpm-ostree status
    echo "📦 rpm-ostree deployments:"
    rpm-ostree status
    echo ""

    # Disk space
    echo "💾 Disk space:"
    df -h / /home /var | grep -v tmpfs
    echo ""

    # Memory
    echo "🧠 Memory usage:"
    free -h
    echo ""

    # Failed services
    echo "⚠️  Failed systemd services:"
    systemctl list-units --state=failed --no-pager
    echo ""

    # Journal errors (last boot)
    echo "📋 Recent errors (last boot):"
    journalctl -b -p err --no-pager | tail -20
    echo ""

    echo "════════════════════════════════════════════════════════════"
    echo "✅ Health check complete"
}

# Generate system report
system-report() {
    local report_file="/tmp/system-report-$(date +%Y%m%d-%H%M%S).txt"

    echo "📊 Generating system report: $report_file"
    echo ""

    {
        echo "System Report - $(date)"
        echo "════════════════════════════════════════════════════════════"
        echo ""

        echo "OS Information:"
        cat /etc/os-release
        echo ""

        echo "Kernel:"
        uname -a
        echo ""

        echo "rpm-ostree Status:"
        rpm-ostree status
        echo ""

        echo "Flatpak Applications:"
        flatpak list
        echo ""

        echo "Distrobox Containers:"
        distrobox list
        echo ""

        echo "Disk Usage:"
        df -h
        echo ""

        echo "Memory:"
        free -h
        echo ""

        echo "Failed Services:"
        systemctl list-units --state=failed
        echo ""

        echo "Recent Errors:"
        journalctl -b -p err --no-pager | tail -50
        echo ""

    } > "$report_file"

    echo "✅ Report generated: $report_file"
    echo ""
    echo "View with: cat $report_file"
    echo "Or open in editor: \$EDITOR $report_file"
}

echo "✅ Bazzite system functions loaded (KENL0)"
