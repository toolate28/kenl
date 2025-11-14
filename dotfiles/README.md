---
project: Bazza-DX SAGE Framework
status: current
version: 2025-11-14
classification: OWI-DOC
atom: ATOM-DOC-20251114-001
owi-version: 1.0.0
last-updated: 2025-11-14
description: Intent-driven dotfiles system with ATOM/SAGE/OWI integration
---

# KENL Dotfiles System

**Intent-driven, traceable, reproducible dotfiles for the Bazza-DX SAGE Framework**

## Philosophy

This dotfiles system embodies the core KENL principles:

### **Ethical Fundamentals**
- **Transparency:** Every config clearly documents its origin (manual, AI-assisted, imported)
- **Traceability:** ATOM trails capture WHY configs changed, not just WHAT
- **Intentionality:** Configuration intent documented alongside implementation
- **Reproducibility:** Shareable profiles enable cross-system deployment
- **User Authority:** Human-in-the-loop for critical changes
- **Rollback Safety:** Git-based versioning + backup snapshots

### **Technical Fundamentals**
- **User-space Only:** All configs in `~/.config` and `~/.local` (immutable-OS safe)
- **Pattern Recognition:** SAGE auto-learns from your usage patterns
- **Lightweight:** Minimal overhead (~0.1ms ATOM logging)
- **Modular:** Organized by KENL layers (gaming, dev, monitoring, etc.)
- **Cross-platform:** Works on Windows/WSL2/Linux
- **Evidence-based:** Benchmarked, validated configurations

## Architecture

```
dotfiles/
├── README.md                    # This file
├── .atom-trail.log             # Complete change history with intent
├── .sage-dotfiles.yaml         # SAGE pattern recognition config
├── bootstrap.sh                # One-command installation
├── rollback.sh                 # Safe rollback to previous state
│
├── profiles/                   # Shareable configuration profiles
│   ├── amd-ryzen5-5600h-vega/  # Hardware-specific profile
│   ├── gaming-focused/         # Gaming-optimized setup
│   ├── dev-focused/            # Development-optimized setup
│   └── minimal/                # Minimal baseline
│
├── kenl-layers/                # Modular configs by KENL layer
│   ├── kenl0-system/          # System operations (shell, env)
│   ├── kenl2-gaming/          # Gaming configs (MangoHud, GameScope)
│   ├── kenl3-dev/             # Development (git, vim, tmux)
│   ├── kenl4-monitoring/      # Monitoring dashboards
│   ├── kenl5-facades/         # Visual themes, prompts
│   └── kenl8-security/        # GPG, SSH configs
│
├── templates/                  # Config file templates
│   ├── bashrc.template
│   ├── gitconfig.template
│   └── vimrc.template
│
└── backups/                    # Timestamped backup snapshots
    └── .gitkeep
```

## Quick Start

### **1. Install Dotfiles**

```bash
# Clone dotfiles to ~/.dotfiles
git clone https://github.com/toolate28/kenl.git ~/.kenl
cd ~/.kenl/dotfiles

# Bootstrap installation (creates symlinks, applies configs)
./bootstrap.sh --profile amd-ryzen5-5600h-vega
```

### **2. Apply a Profile**

```bash
# Apply gaming-focused profile
./apply-profile.sh gaming-focused

# This records ATOM trail entry:
# ATOM-CFG-20251114-001: Applied gaming-focused profile (MangoHud + GameScope optimization)
```

### **3. Make Custom Changes**

```bash
# Edit config with intent tracking
./edit-config.sh ~/.config/MangoHud/MangoHud.conf \
  --intent "Disable FPS overlay for streaming"

# ATOM trail automatically records:
# ATOM-CFG-20251114-002: Disabled FPS overlay (intent: cleaner stream appearance)
```

### **4. Share Your Config**

```bash
# Export current setup as shareable profile
./export-profile.sh my-gaming-setup \
  --description "Optimized for AMD Ryzen 5 5600H + Vega" \
  --hardware "amd-ryzen5-5600h-vega" \
  --benchmarks "BF6: 118 FPS @ 1080p medium"

# Creates: profiles/my-gaming-setup/ with OWI metadata
```

### **5. Rollback if Needed**

```bash
# View ATOM trail to find change
cat .atom-trail.log

# Rollback to specific ATOM tag
./rollback.sh ATOM-CFG-20251114-001

# Or rollback to timestamp
./rollback.sh --timestamp "2025-11-14 10:30"
```

## ATOM Trail Integration

Every dotfile change generates an ATOM trail entry:

```bash
# Example ATOM trail entries
ATOM-CFG-20251114-001: Applied gaming-focused profile (MangoHud + GameScope optimization)
ATOM-CFG-20251114-002: Disabled FPS overlay (intent: cleaner stream appearance)
ATOM-CFG-20251114-003: Increased network buffer (intent: reduce BF6 packet loss)
ATOM-CFG-20251114-004: Added vim-fugitive plugin (intent: improve git workflow)
```

**Why ATOM trails matter:**
- **Crash recovery:** Restore context from vague user input (e.g., "continue from crash")
- **Collaboration:** Share complete change history with collaborators
- **Learning:** SAGE analyzes patterns to suggest optimizations
- **Debugging:** Understand what changed before a regression

## SAGE Pattern Recognition

SAGE monitors your dotfile usage and learns patterns:

```yaml
# .sage-dotfiles.yaml
pattern_recognition:
  watch:
    - "**/.bashrc"
    - "**/.gitconfig"
    - "**/.vimrc"
    - "**/MangoHud.conf"

  learned_patterns:
    - name: "gaming-session-startup"
      trigger: "Launch BF6"
      actions:
        - disable_tailscale_vpn
        - set_cpu_governor_performance
        - enable_mangohud_overlay
      confidence: 0.95
      atom_ref: "ATOM-PATTERN-20251114-001"

    - name: "dev-session-startup"
      trigger: "Open VSCode"
      actions:
        - enable_tailscale_vpn
        - set_cpu_governor_powersave
        - launch_distrobox_dev
      confidence: 0.87
      atom_ref: "ATOM-PATTERN-20251114-002"
```

**SAGE suggests:** "I've noticed you disable Tailscale before gaming sessions. Create a gaming-mode alias?"

## OWI Metadata Standard

All profiles include OWI metadata:

```yaml
---
profile: amd-ryzen5-5600h-vega
classification: CWI-PLAYBOOK
atom: ATOM-CFG-20251114-001
owi-version: 1.0.0
hardware:
  cpu: "AMD Ryzen 5 5600H (6C/12T)"
  gpu: "AMD Radeon Vega Graphics (7 CUs)"
  ram: "16GB"
benchmarks:
  bf6:
    fps: 118
    resolution: "1920x1080"
    settings: "medium"
  network:
    latency: "6.2ms"
    mtu: 1492
ai_involvement:
  generated_by: "Claude Sonnet 4.5"
  human_review: true
  modifications: "User customized MangoHud FPS position"
rollback_plan: |
  ./rollback.sh ATOM-CFG-20251114-001
  # Restores default configs, removes hardware-specific optimizations
---
```

## Shareable Profiles (Play Card Style)

Profiles are complete, portable configurations:

```bash
profiles/
└── amd-ryzen5-5600h-vega/
    ├── profile.yaml           # OWI metadata + benchmarks
    ├── kenl0-system/
    │   ├── .bashrc
    │   └── .bash_aliases
    ├── kenl2-gaming/
    │   ├── MangoHud.conf
    │   └── gamescope-session.sh
    ├── kenl3-dev/
    │   ├── .gitconfig
    │   └── .vimrc
    └── README.md              # Human-readable setup guide
```

**Share your profile:**

```bash
# Export as tarball
./export-profile.sh amd-ryzen5-5600h-vega --format tarball

# Creates: profiles/amd-ryzen5-5600h-vega.tar.gz
# Others can import: ./import-profile.sh amd-ryzen5-5600h-vega.tar.gz
```

## Cross-Platform Support

Works on Windows, WSL2, and Linux:

```bash
# Platform detection (from KENL.psm1)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  PLATFORM="linux"
  CONFIG_DIR="$HOME/.config"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
  PLATFORM="windows"
  CONFIG_DIR="$APPDATA"
else
  PLATFORM="unknown"
fi

# Apply platform-specific configs
./bootstrap.sh --platform "$PLATFORM"
```

## Modular Organization (KENL Layers)

Dotfiles organized by KENL purpose:

| KENL Layer | Dotfiles Included | Purpose |
|------------|------------------|---------|
| **KENL0** System | `.bashrc`, `.bash_profile`, `.zshrc` | Shell environment |
| **KENL2** Gaming | `MangoHud.conf`, `gamescope.conf` | Gaming optimization |
| **KENL3** Dev | `.gitconfig`, `.vimrc`, `.tmux.conf` | Development tools |
| **KENL4** Monitoring | Grafana dashboards, Prometheus configs | Performance monitoring |
| **KENL5** Facades | Shell prompts, themes, banners | Visual customization |
| **KENL8** Security | `.gnupg/`, `.ssh/config` | Security configs |

**Benefits:**
- **Selective installation:** Only install KENL layers you need
- **Clear purpose:** Each config's role is obvious
- **Easy maintenance:** Update one layer without affecting others

## Rollback Safety

Git-based versioning + timestamped backups:

```bash
# Automatic backup before changes
./bootstrap.sh
# Creates: backups/dotfiles-backup-20251114-103045.tar.gz

# Git commit after changes
git add .
git commit -m "feat: apply gaming-focused profile

ATOM-CFG-20251114-001"

# Rollback to previous commit
git log --oneline
./rollback.sh <commit-hash>

# Or rollback from backup
./rollback.sh --from-backup backups/dotfiles-backup-20251114-103045.tar.gz
```

## Usage Examples

### **Example 1: Gaming Session Setup**

```bash
# Apply gaming profile
./apply-profile.sh gaming-focused

# ATOM trail records:
# ATOM-CFG-20251114-001: Applied gaming profile
# - Enabled MangoHud with FPS overlay
# - Set CPU governor to performance
# - Disabled Tailscale VPN (reduced latency 174ms → 6ms)
# - Set MTU to 1492 (optimized for gaming)

# Launch game
mangohud gamescope -f -W 1920 -H 1080 -- %command%
```

### **Example 2: Development Session Setup**

```bash
# Apply dev profile
./apply-profile.sh dev-focused

# ATOM trail records:
# ATOM-CFG-20251114-002: Applied dev profile
# - Enabled Tailscale VPN (secure remote access)
# - Launched distrobox dev container
# - Set CPU governor to powersave
# - Configured git with GPG signing

# Start coding
distrobox enter dev
code .
```

### **Example 3: Sharing Config with Community**

```bash
# Export your optimized setup
./export-profile.sh my-bf6-setup \
  --description "Battlefield 6 optimized for AMD Ryzen 5 5600H + Vega" \
  --benchmarks "118 FPS @ 1080p medium, 6ms latency" \
  --include-hardware-info

# Share tarball
# profiles/my-bf6-setup.tar.gz uploaded to KENL12-resources

# Others import with:
# ./import-profile.sh my-bf6-setup.tar.gz
```

## Integration with KENL Modules

Dotfiles integrate seamlessly with KENL modules:

```bash
# KENL0-system: Shell aliases for KENL operations
alias kenl-gaming="apply-profile.sh gaming-focused"
alias kenl-dev="apply-profile.sh dev-focused"

# KENL2-gaming: Gaming-specific configs
~/.config/MangoHud/MangoHud.conf
~/.config/gamescope/gamescope.conf

# KENL3-dev: Development tool configs
~/.gitconfig (with GPG signing)
~/.vimrc (with plugins)
~/.config/Code/User/settings.json

# KENL4-monitoring: Monitoring dashboards
~/.config/grafana/dashboards/kenl-gaming.json
~/.config/prometheus/prometheus.yml

# KENL8-security: Security tool configs
~/.gnupg/gpg.conf
~/.ssh/config
```

## Best Practices

1. **Always capture intent:**
   ```bash
   # Bad: Direct edit
   vim ~/.bashrc

   # Good: Edit with intent tracking
   ./edit-config.sh ~/.bashrc --intent "Add Docker aliases for faster container management"
   ```

2. **Test before committing:**
   ```bash
   # Apply changes
   ./apply-profile.sh new-profile

   # Test (e.g., launch game, run dev tools)
   # If broken, rollback immediately
   ./rollback.sh ATOM-CFG-20251114-XXX

   # If works, commit
   git commit -m "feat: add new-profile with [description]"
   ```

3. **Share evidence-based configs:**
   ```bash
   # Include benchmarks in profile metadata
   benchmarks:
     bf6:
       fps: 118
       resolution: "1920x1080"
       settings: "medium"
     network:
       latency: "6.2ms"
   ```

4. **Use SAGE suggestions:**
   ```bash
   # SAGE notices pattern: "You always disable Tailscale before gaming"
   # Suggestion: "Create alias: gaming-mode = disable Tailscale + set performance governor"

   # Accept suggestion
   ./apply-sage-suggestion.sh ATOM-PATTERN-20251114-001
   ```

## Troubleshooting

### **Dotfiles not applying?**

```bash
# Check ATOM trail for errors
tail -n 20 .atom-trail.log

# Verify symlinks
./verify-dotfiles.sh

# Re-run bootstrap
./bootstrap.sh --force
```

### **Config conflicts?**

```bash
# Backup existing configs
./bootstrap.sh --backup-existing

# View conflicts
./verify-dotfiles.sh --check-conflicts

# Resolve manually or rollback
./rollback.sh --to-backup
```

### **SAGE not learning patterns?**

```bash
# Verify SAGE config
cat .sage-dotfiles.yaml

# Check SAGE logs
tail -n 50 ~/.local/share/kenl/sage-dotfiles.log

# Manually trigger pattern analysis
./analyze-patterns.sh
```

## Advanced Usage

### **Custom ATOM Trail Entries**

```bash
# Add manual entry
echo "ATOM-CFG-20251114-999: Custom tweak to vim colorscheme (intent: reduce eye strain)" >> .atom-trail.log
```

### **Conditional Profiles**

```bash
# Apply profile based on hardware
if [[ $(grep "AMD Ryzen 5 5600H" /proc/cpuinfo) ]]; then
  ./apply-profile.sh amd-ryzen5-5600h-vega
else
  ./apply-profile.sh generic
fi
```

### **Multi-System Sync**

```bash
# Git-based sync across machines
git remote add origin https://github.com/yourusername/dotfiles.git
git push -u origin main

# On another machine
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

## Contributing Profiles

Share your optimized configs with the community:

1. Export profile: `./export-profile.sh my-profile`
2. Add OWI metadata: `vim profiles/my-profile/profile.yaml`
3. Include benchmarks and hardware specs
4. Test on clean install
5. Submit PR to `modules/KENL12-resources/community-profiles/`

## Resources

- **ATOM Framework:** `/home/user/kenl/atom-sage-framework/README.md`
- **OWI Standard:** `/home/user/kenl/OWI_METADATA_STANDARD.md`
- **KENL Modules:** `/home/user/kenl/modules/`
- **Case Studies:** `/home/user/kenl/case-studies/`

## License

MIT License - Share freely, attribution appreciated

---

**ATOM:** ATOM-DOC-20251114-001
**Next Steps:** Implement bootstrap.sh, rollback.sh, SAGE integration
**Related:** CLAUDE.md, OWI_FRAMEWORK_OVERVIEW.md, .sage-manifest.yaml
