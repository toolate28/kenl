---
project: Bazza-DX SAGE Framework
classification: OWI-STANDARD
atom: ATOM-IWI-20251112-001
status: active
version: 1.0.0
owi-fork: IWI
owi-variant: "Installing With Intent"
---

# ATOM-IWI: Installing With Intent

**Traceable, repeatable Bazzite installation and configuration**

---

## Vision

**iWi** (pronounced "ee-wee") is an OWI fork focused on capturing the **installation and configuration process** for immutable Linux distributions (Bazzite/Fedora Atomic), making system setup:

- 📋 **Traceable**: Every installation decision documented with ATOM tags
- 🔄 **Repeatable**: Complete installation instructions that others can follow
- 🎯 **Intent-Driven**: Capture *why* you chose each option, not just *what*
- 🔗 **Documentation-Integrated**: Links to docs.bazzite.gg for official guidance
- 🧪 **Testable**: Validation framework to verify installations
- 🛡️ **Rollback-Safe**: Every step includes rollback instructions

---

## The Problem iWi Solves

**Installing Bazzite shouldn't mean losing knowledge.**

Traditional installation:
```
1. Download ISO
2. Boot USB
3. Click through installer
4. Configure system
5. Install packages
...
6. "It works!" but you forgot what you did
```

**Result:** When you need to reinstall (hardware upgrade, fresh start), you can't remember:
- Which Bazzite variant you chose (KDE/GNOME/Deck?)
- What partitioning scheme you used
- Which packages you layered with rpm-ostree
- What ujust recipes you ran
- Why you made each choice

**iWi captures everything:**

```yaml
---
installation-session: ATOM-IWI-20251112-001
date: 2025-11-12
duration: 45 minutes
target-hardware: AMD Ryzen 5 5600H + Vega
outcome: success

decisions:
  - choice: Bazzite KDE
    reason: "Prefer KDE Plasma for gaming + customization"
    alternatives: [GNOME, Deck]
    docs-ref: https://docs.bazzite.gg/General/Installation_Guide/

  - choice: Dual-boot with Windows 11
    reason: "Keep Windows for anti-cheat games (BF6, Valorant)"
    docs-ref: https://docs.bazzite.gg/Advanced/dual_boot_setup/

  - choice: 900GB game partition (NTFS)
    reason: "Shared Steam library between Windows/Linux"
    rollback: "Can repartition with GParted from live USB"

layered-packages:
  - package: vim
    reason: "Preferred text editor"
    installed-via: rpm-ostree install vim

ujust-recipes:
  - recipe: ujust install-steam
    reason: "Gaming platform - required for BF6"
    docs-ref: https://docs.bazzite.gg/Gaming/
---
```

**Next install?** Copy-paste the config. 45 minutes → 20 minutes. Zero guesswork.

---

## Core Principles

### 1. Immutability-Aware

iWi understands immutable distributions:

- **System changes** go through rpm-ostree (traceable, atomic, rollback-safe)
- **User configs** go in `~/.config` or `~/.local` (survive rollbacks)
- **Layered packages** tracked separately from base image
- **ujust recipes** documented with intent

### 2. Documentation Integration

iWi links to official Bazzite documentation:

```yaml
step: "Install proprietary codecs"
command: ujust install-codecs
docs-ref: https://docs.bazzite.gg/General/codecs/
reason: "Need H.264 for Discord streaming"
evidence: "Tested Discord screen share - now works"
```

Every step references upstream docs. When docs.bazzite.gg changes, you know where to look.

### 3. Hardware-Specific

iWi captures hardware context:

```yaml
hardware-profile:
  cpu: AMD Ryzen 5 5600H
  gpu: AMD Radeon Vega Graphics (integrated)
  ram: 16GB DDR4

optimizations:
  - setting: amdgpu.ppfeaturemask=0xffffffff
    reason: "Enable GPU overclocking for Vega"
    docs-ref: https://docs.bazzite.gg/Advanced/amd_gpu_tuning/
    performance-gain: "+15% FPS in BF6"
```

When someone has the same hardware, they can use your exact config.

### 4. Intent Capture

Every choice documented with *why*:

```yaml
partition-layout:
  - mount: /
    size: 100GB
    filesystem: btrfs
    reason: "Small root for OS, snapshots via Timeshift"

  - mount: /home
    size: 400GB
    filesystem: btrfs
    reason: "Separate /home survives reinstalls"

  - mount: /mnt/games
    size: 900GB
    filesystem: ntfs
    reason: "Shared game library with Windows dual-boot"
    alternative: "Could use ext4 + Ext2Fsd on Windows (slower)"
```

---

## Installation Capture Workflow

### Phase 1: Pre-Installation Planning

**Before you boot the ISO**, document your plan:

```yaml
# installation-plan.yaml
---
classification: IWI-PLAN
atom: ATOM-IWI-20251112-001

hardware:
  cpu: AMD Ryzen 5 5600H
  gpu: AMD Radeon Vega Graphics
  ram: 16GB
  disk-main: 512GB NVMe (internal)
  disk-data: 2TB HDD (external)

goals:
  - "Gaming on Linux with Proton"
  - "Dual-boot Windows 11 (anti-cheat games only)"
  - "Shared Steam library on external drive"
  - "Development environment (Python, Node.js)"

bazzite-variant: bazzite-kde
reason: "KDE Plasma for customization, MangoHud integration"

partitioning:
  internal-512gb:
    - Windows 11: 250GB
    - Bazzite: 250GB (root + home)
    - Swap: 12GB

  external-2tb:
    - Games (NTFS): 900GB
    - Claude AI Data (ext4): 500GB
    - Development (ext4): 200GB
    - Transfer (exFAT): 50GB

documentation-references:
  - https://docs.bazzite.gg/General/Installation_Guide/
  - https://docs.bazzite.gg/Advanced/dual_boot_setup/
  - https://universal-blue.discourse.group/
---
```

### Phase 2: Installation Execution

**During installation**, capture each decision:

```bash
# Start installation capture
iwi-capture start --plan installation-plan.yaml

# Each step gets logged automatically
# But you can add notes manually:
iwi-log "Partitioning internal drive - created 250GB for Bazzite"
iwi-log "Selected KDE Plasma desktop environment"
iwi-log "Enabled encryption on Bazzite partition (LUKS)"
iwi-log "Created user: matthew, added to wheel group"
```

Generates:

```yaml
# installation-capture-20251112.yaml
---
classification: IWI-CAPTURE
atom: ATOM-IWI-20251112-002
started: 2025-11-12T10:00:00Z
completed: 2025-11-12T10:45:00Z

steps:
  - timestamp: 2025-11-12T10:05:00Z
    step: "Partition internal drive"
    action: "Created 250GB Btrfs partition for Bazzite"
    tool: "Anaconda installer"

  - timestamp: 2025-11-12T10:10:00Z
    step: "Desktop environment selection"
    action: "Selected KDE Plasma"
    reason: "Better gaming integration, MangoHud overlay"
    alternative: "GNOME (simpler but less customizable)"

  - timestamp: 2025-11-12T10:15:00Z
    step: "Encryption setup"
    action: "Enabled LUKS encryption on Bazzite partition"
    passphrase-location: "Bitwarden vault"
    docs-ref: https://docs.bazzite.gg/Advanced/encryption/
---
```

### Phase 3: Post-Installation Configuration

**After first boot**, document your setup:

```bash
# Log rpm-ostree layered packages
iwi-log-package vim "Preferred text editor"
iwi-log-package htop "System monitoring"

# Log ujust recipes
iwi-log-ujust install-steam "Gaming platform"
iwi-log-ujust install-codecs "Proprietary codecs for Discord"

# Log configuration changes
iwi-log-config "~/.config/MangoHud/MangoHud.conf" "Enabled FPS + GPU monitoring"
```

Generates:

```yaml
# post-install-config-20251112.yaml
---
classification: IWI-CONFIG
atom: ATOM-IWI-20251112-003

layered-packages:
  - package: vim
    reason: "Preferred text editor"
    installed: 2025-11-12T11:00:00Z
    command: rpm-ostree install vim

  - package: htop
    reason: "System monitoring"
    installed: 2025-11-12T11:05:00Z
    command: rpm-ostree install htop

ujust-recipes:
  - recipe: install-steam
    reason: "Gaming platform - required for BF6"
    executed: 2025-11-12T11:10:00Z
    docs-ref: https://docs.bazzite.gg/Gaming/

  - recipe: install-codecs
    reason: "Proprietary codecs for Discord screen share"
    executed: 2025-11-12T11:15:00Z
    docs-ref: https://docs.bazzite.gg/General/codecs/

configs:
  - file: ~/.config/MangoHud/MangoHud.conf
    changes: "Enabled fps, gpu_temp, gpu_core_clock"
    reason: "Monitor performance during BF6 gameplay"
    backup: ~/.config/MangoHud/MangoHud.conf.backup
---
```

### Phase 4: Validation & Testing

**Test your installation**:

```bash
# Run iWi validation
iwi-validate installation-capture-20251112.yaml

# Expected tests:
# ✓ rpm-ostree status shows expected deployment
# ✓ All layered packages installed
# ✓ Steam launches successfully
# ✓ Discord codecs working
# ✓ GPU acceleration enabled
# ✓ Network latency < 10ms
```

---

## iWi Document Types

### IWI-PLAN
**Pre-installation planning document**

```yaml
---
classification: IWI-PLAN
purpose: "Define installation goals before execution"
includes:
  - Hardware inventory
  - Bazzite variant selection
  - Partitioning scheme
  - Package requirements
  - Performance goals
---
```

### IWI-CAPTURE
**Real-time installation capture**

```yaml
---
classification: IWI-CAPTURE
purpose: "Log decisions during installation process"
includes:
  - Installation steps with timestamps
  - Decision rationale
  - Alternative options considered
  - Documentation references
---
```

### IWI-CONFIG
**Post-installation configuration**

```yaml
---
classification: IWI-CONFIG
purpose: "Document system configuration after install"
includes:
  - Layered packages (rpm-ostree)
  - ujust recipes executed
  - Configuration files modified
  - Services enabled
---
```

### IWI-PROFILE
**Complete installation profile (shareable)**

```yaml
---
classification: IWI-PROFILE
purpose: "Complete installation profile for reproduction"
includes:
  - Combined plan + capture + config
  - Hardware specifications
  - Performance benchmarks
  - Validation tests
  - Rollback procedures
---
```

### IWI-GUIDE
**Step-by-step installation guide**

```markdown
---
classification: IWI-GUIDE
purpose: "Human-readable installation walkthrough"
---

# Bazzite KDE Installation Guide
## For AMD Ryzen 5 5600H + Vega

### Prerequisites
- 8GB USB drive
- 512GB+ internal storage
- Backup of important data

### Step 1: Download ISO
1. Visit https://bazzite.gg/
2. Select "Bazzite KDE"
3. Download for x86_64
4. Verify SHA256 hash

[Continue with detailed steps...]
```

---

## Integration with docs.bazzite.gg

iWi captures and references official Bazzite documentation:

### Documentation Capture

```bash
# During installation, capture relevant docs
iwi-docs-capture https://docs.bazzite.gg/General/Installation_Guide/

# Stores local copy with timestamp
# Location: ~/.iwi/docs-cache/bazzite.gg/Installation_Guide-20251112.html
```

### Documentation References

Every iWi document links to official docs:

```yaml
step: "Install Steam"
command: ujust install-steam
docs-ref: https://docs.bazzite.gg/Gaming/
docs-captured: ~/.iwi/docs-cache/bazzite.gg/Gaming-20251112.html
reason: "Gaming platform - following official guide"
```

**Why capture docs?**
- Docs change over time
- You have a snapshot of what you followed
- Works offline
- Can diff old vs new docs to understand changes

---

## Testing Framework

iWi includes validation tests:

### Installation Tests

```bash
# Test 1: System deployment is correct
test-iwi-deployment() {
    local expected_variant="bazzite-kde"
    local actual_variant=$(rpm-ostree status --json | jq -r '.deployments[0].id')

    if [[ "$actual_variant" == *"$expected_variant"* ]]; then
        echo "✓ Bazzite variant: $expected_variant"
    else
        echo "✗ Expected $expected_variant, got $actual_variant"
        return 1
    fi
}

# Test 2: Layered packages installed
test-iwi-packages() {
    local expected_packages=("vim" "htop")

    for pkg in "${expected_packages[@]}"; do
        if rpm -q "$pkg" &>/dev/null; then
            echo "✓ Package installed: $pkg"
        else
            echo "✗ Package missing: $pkg"
            return 1
        fi
    done
}

# Test 3: Performance baselines met
test-iwi-performance() {
    # Network latency
    local latency=$(ping -c 5 1.1.1.1 | tail -1 | awk -F'/' '{print $5}')
    if (( $(echo "$latency < 10" | bc -l) )); then
        echo "✓ Network latency: ${latency}ms (< 10ms target)"
    else
        echo "✗ Network latency: ${latency}ms (> 10ms target)"
        return 1
    fi
}
```

### Hardware Validation

```bash
# Verify hardware detected correctly
test-iwi-hardware() {
    # GPU detection
    if lspci | grep -i "vega" &>/dev/null; then
        echo "✓ GPU detected: AMD Vega"
    else
        echo "✗ GPU not detected"
        return 1
    fi

    # CPU frequency
    local cpu_freq=$(lscpu | grep "MHz" | awk '{print $3}')
    echo "✓ CPU frequency: ${cpu_freq}MHz"
}
```

---

## Example: Complete Installation Profile

```yaml
---
project: Bazza-DX SAGE Framework
classification: IWI-PROFILE
atom: ATOM-IWI-20251112-004
status: verified
version: 1.0.0
created: 2025-11-12
tested-on:
  - AMD Ryzen 5 5600H
  - AMD Radeon Vega Graphics
  - 16GB DDR4 RAM
---

# Bazzite KDE Installation Profile
## Gaming + Development Setup

### Hardware Target
- **CPU:** AMD Ryzen 5 5600H (6C/12T, Zen 3)
- **GPU:** AMD Radeon Vega Graphics (integrated, 7 CUs)
- **RAM:** 16GB DDR4
- **Storage:** 512GB NVMe + 2TB HDD

### Installation Decisions

#### 1. Bazzite Variant
**Choice:** bazzite-kde
**Reason:** KDE Plasma offers better gaming integration (MangoHud, Steam input, theme customization)
**Alternative:** bazzite-gnome (simpler, less customizable)
**Docs:** https://docs.bazzite.gg/General/Installation_Guide/

#### 2. Partitioning Scheme
**Internal 512GB NVMe:**
- `/` - 100GB Btrfs (OS)
- `/home` - 400GB Btrfs (user data)
- `swap` - 12GB

**External 2TB HDD:**
- Games: 900GB NTFS (shared with Windows)
- AI Data: 500GB ext4 (Linux-only)
- Development: 200GB ext4 (distrobox containers)
- Transfer: 50GB exFAT (cross-OS file exchange)

**Reason:** Immutable OS needs small root. Large /home survives reinstalls. External drive for games (dual-boot shared library).

#### 3. Encryption
**Choice:** LUKS on `/` and `/home`
**Reason:** Laptop - needs encryption for security
**Passphrase:** Stored in Bitwarden
**Docs:** https://docs.bazzite.gg/Advanced/encryption/

### Post-Install Configuration

#### Layered Packages
```bash
rpm-ostree install vim htop ncdu
```
**Reason:** Essential CLI tools not in base image

#### ujust Recipes
```bash
ujust install-steam        # Gaming platform
ujust install-codecs       # Proprietary codecs (H.264)
ujust configure-amd-gpu    # AMD GPU optimizations
```

#### Manual Configurations
1. **MangoHud:** Enabled FPS + GPU monitoring
   - File: `~/.config/MangoHud/MangoHud.conf`
   - Settings: `fps, gpu_temp, gpu_core_clock, frame_timing`

2. **Steam:** Added external game library
   - Path: `/mnt/games/SteamLibrary`
   - Verified: BF6 launches successfully

3. **Network:** Optimized for gaming
   - MTU: 1492 (tested optimal)
   - QoS: Enabled on router

### Validation Results

| Test | Result | Benchmark |
|------|--------|-----------|
| rpm-ostree deployment | ✓ | bazzite-kde:stable |
| Layered packages | ✓ | 3/3 installed |
| GPU detection | ✓ | AMD Vega (7 CUs) |
| Network latency | ✓ | 6.2ms avg |
| BF6 launch | ✓ | Loads in 45s |
| BF6 performance | ✓ | 60 FPS avg |

### Rollback Procedure

If installation fails:
```bash
# Boot previous deployment
sudo rpm-ostree rollback
sudo systemctl reboot

# Or boot from GRUB menu
# Select previous deployment (second entry)
```

### References

**Official Docs:**
- Installation Guide: https://docs.bazzite.gg/General/Installation_Guide/
- AMD GPU Tuning: https://docs.bazzite.gg/Advanced/amd_gpu_tuning/
- Gaming Setup: https://docs.bazzite.gg/Gaming/

**ATOM Trail:**
- ATOM-IWI-20251112-001: Installation plan
- ATOM-IWI-20251112-002: Installation capture
- ATOM-IWI-20251112-003: Post-install config
- ATOM-IWI-20251112-004: This profile

---

**Installation Time:** 45 minutes
**Confidence:** High (tested 3 times on same hardware)
**Reproducibility:** Exact reproduction possible with this profile
```

---

## Directory Structure

```
ATOM-IWI/
├── README.md                          # This file
├── IWI_SPECIFICATION.md               # Complete iWi spec
├── docs/
│   ├── GETTING_STARTED.md             # Quick start guide
│   ├── INSTALLATION_CAPTURE.md        # How to capture installations
│   ├── VALIDATION_FRAMEWORK.md        # Testing framework
│   └── BAZZITE_INTEGRATION.md         # docs.bazzite.gg integration
├── specs/
│   ├── IWI-PLAN.yaml                  # Plan document spec
│   ├── IWI-CAPTURE.yaml               # Capture document spec
│   ├── IWI-CONFIG.yaml                # Config document spec
│   └── IWI-PROFILE.yaml               # Profile document spec
├── tests/
│   ├── test-deployment.sh             # Deployment validation
│   ├── test-packages.sh               # Package validation
│   ├── test-performance.sh            # Performance validation
│   └── test-hardware.sh               # Hardware validation
├── examples/
│   ├── amd-ryzen5-5600h-vega.yaml     # Complete example profile
│   ├── intel-core-i7-nvidia.yaml      # Intel/NVIDIA example
│   └── framework-laptop.yaml          # Framework laptop example
└── templates/
    ├── installation-plan.yaml         # Blank plan template
    ├── installation-capture.yaml      # Blank capture template
    └── installation-profile.yaml      # Blank profile template
```

---

## Roadmap

### Phase 1: Foundation (Current)
- [x] Define iWi methodology
- [x] Create document specifications
- [ ] Implement basic capture tools
- [ ] Create validation framework

### Phase 2: Integration
- [ ] docs.bazzite.gg documentation capture
- [ ] Automated installation logging
- [ ] Hardware profile detection
- [ ] Performance benchmarking

### Phase 3: Sharing
- [ ] iWi profile repository
- [ ] Web-based profile viewer
- [ ] Community validation
- [ ] Hardware compatibility database

---

## Contributing

See [CONTRIBUTING.md](../../../../CONTRIBUTING.md) for contribution guidelines.

**Focus areas:**
- Hardware-specific installation profiles
- Validation test improvements
- Documentation capture automation
- Performance benchmarking tools

---

## Related Forks

- **ATOM-EOL:** Windows 10 EOL migration framework
- **ATOM-GOV:** MCP governance and policy enforcement
- **ATOM-SEC:** Security hardening and compliance

---

## Metadata

- **Created:** 2025-11-12
- **ATOM Tag:** ATOM-IWI-20251112-001
- **Classification:** OWI-STANDARD
- **Status:** Active - Foundation Phase
- **OWI Fork:** IWI (Installing With Intent)
- **Target Platform:** Bazzite (Fedora Atomic)

---
