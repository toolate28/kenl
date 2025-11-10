#!/usr/bin/env bash
# bazzite-aliases.sh
# OS-specific aliases optimized for Bazzite (rpm-ostree)
# Source this in ~/.bashrc or via KENL5 facades

# ═══════════════════════════════════════════════════════════
# rpm-ostree Operations (Bazzite core)
# ═══════════════════════════════════════════════════════════

# System status
alias os-status='rpm-ostree status'
alias os-diff='rpm-ostree db diff'
alias os-check='rpm-ostree upgrade --check'

# System updates
alias os-update='rpm-ostree upgrade'
alias os-update-preview='rpm-ostree upgrade --preview'
alias os-update-download='rpm-ostree upgrade --download-only'

# System rollback
alias os-rollback='rpm-ostree rollback'
alias os-rollback-reboot='rpm-ostree rollback && systemctl reboot'

# Package management
alias os-install='rpm-ostree install'
alias os-uninstall='rpm-ostree uninstall'
alias os-search='rpm-ostree search'

# Cleanup
alias os-clean='rpm-ostree cleanup --rollback --pending'
alias os-clean-all='rpm-ostree cleanup --rollback --repomd'

# Rebasing
alias os-rebase-stable='rpm-ostree rebase ostree-image-signed:docker://ghcr.io/ublue-os/bazzite:stable'
alias os-rebase-testing='rpm-ostree rebase ostree-image-signed:docker://ghcr.io/ublue-os/bazzite:testing'

# ═══════════════════════════════════════════════════════════
# Flatpak Operations (Bazzite primary package manager)
# ═══════════════════════════════════════════════════════════

# Flatpak shortcuts
alias fp='flatpak'
alias fpl='flatpak list'
alias fpi='flatpak install'
alias fpu='flatpak uninstall'
alias fpup='flatpak update'
alias fps='flatpak search'
alias fpinfo='flatpak info'

# Flatpak maintenance
alias fp-clean='flatpak uninstall --unused'
alias fp-repair='flatpak repair'
alias fp-update-all='flatpak update -y'

# ═══════════════════════════════════════════════════════════
# Distrobox Operations
# ═══════════════════════════════════════════════════════════

# Distrobox shortcuts
alias dbl='distrobox list'
alias dbe='distrobox enter'
alias dbc='distrobox create'
alias dbr='distrobox rm'
alias dbs='distrobox stop'

# Quick distrobox enters
alias ubuntu='distrobox enter ubuntu'
alias arch='distrobox enter arch'
alias fedora='distrobox enter fedora'

# ═══════════════════════════════════════════════════════════
# Gaming Operations (Bazzite-specific)
# ═══════════════════════════════════════════════════════════

# Steam
alias steam-native='/usr/bin/steam'
alias steam-runtime='flatpak run com.valvesoftware.Steam'
alias steam-logs='journalctl -u steam'

# Proton management
alias proton-list='ls ~/.steam/steam/compatibilitytools.d/'
alias proton-ge-update='ujust install-proton-ge'

# GameScope
alias gamescope-session='gamescope-session-plus'
alias gamescope-logs='journalctl -u gamescope-session'

# MangoHud
alias mangohud-config='$EDITOR ~/.config/MangoHud/MangoHud.conf'

# ═══════════════════════════════════════════════════════════
# System Management
# ═══════════════════════════════════════════════════════════

# Systemd shortcuts
alias sc='systemctl'
alias scs='systemctl status'
alias scr='systemctl restart'
alias sce='systemctl enable'
alias scd='systemctl disable'
alias scu='systemctl --user'

# Journal logs
alias logs='journalctl -xe'
alias logs-boot='journalctl -b'
alias logs-follow='journalctl -f'
alias logs-error='journalctl -p err -b'

# System info
alias sys-info='rpm-ostree status && echo && flatpak list && echo && distrobox list'
alias sys-kernel='uname -r'
alias sys-version='cat /etc/os-release'

# ═══════════════════════════════════════════════════════════
# Quick Actions (KENL0 integration)
# ═══════════════════════════════════════════════════════════

# Chained operations
alias qa-update='~/kenl/modules/KENL0-system/quick-actions/update-verify.sh'
alias qa-rebase='~/kenl/modules/KENL0-system/quick-actions/rebase-clean.sh'
alias qa-ujust='~/kenl/modules/KENL0-system/ujust-integration/ujust-atom.sh'

# ═══════════════════════════════════════════════════════════
# Directory Navigation
# ═══════════════════════════════════════════════════════════

# KENL modules
alias kenl1='cd ~/kenl/modules/KENL1-framework'
alias kenl2='cd ~/kenl/modules/KENL2-gaming'
alias kenl3='cd ~/kenl/modules/KENL3-dev'
alias kenl4='cd ~/kenl/modules/KENL4-monitoring'
alias kenl5='cd ~/kenl/modules/KENL5-facades'
alias kenl0='cd ~/kenl/modules/KENL0-system'

# Common paths
alias games='cd ~/Games'
alias steam-compat='cd ~/.steam/steam/compatibilitytools.d'
alias steam-prefix='cd ~/.local/share/Steam/steamapps/compatdata'
alias proton='cd ~/.steam/steam/compatibilitytools.d'

# ═══════════════════════════════════════════════════════════
# Performance & Monitoring
# ═══════════════════════════════════════════════════════════

# System resources
alias top-gpu='nvtop'  # if NVIDIA
alias top-cpu='btop'   # if installed
alias top-mem='free -h'
alias top-disk='df -h'

# Temperature monitoring
alias temps='sensors'

echo "✅ Bazzite aliases loaded (KENL0)"
