---
project: Bazza-DX SAGE Framework
classification: OWI-DOC
atom: ATOM-DOC-20251112-005
status: active
version: 1.0.0
---

# KENL8-iwi: Installing With Intent

**Standalone installation framework for Bazzite with resource verification**

---

## Overview

KENL8-iwi is a **self-contained, trust-verified installation framework** for Bazzite (Fedora Atomic). It captures installation decisions, validates resources, and ensures reproducible system setups.

**Key Features:**
- 🔒 **Cryptographic verification** of all trusted resources
- 📦 **Self-contained** - includes static copies of docs.bazzite.gg
- 🎯 **Intent capture** - documents *why*, not just *what*
- 🔄 **Repeatable** - exact reproduction with profiles
- 🧪 **Testable** - validation framework included
- 📋 **ATOM-integrated** - complete audit trails

---

## Quick Start

```bash
# Navigate to KENL8-iwi
cd ~/kenl/modules/KENL8-iwi

# Verify all trusted resources
./bin/iwi-verify-resources

# Start installation capture
./bin/iwi-capture start --plan my-install-plan.yaml

# Run validation tests
./tests/run-all-tests.sh
```

---

## Directory Structure

```
KENL8-iwi/
├── README.md                          # This file
├── MANIFEST.md                        # Module manifest
├── IWI_SPECIFICATION.md               # Complete iWi spec
│
├── bin/                               # Executable tools
│   ├── iwi-capture                    # Installation capture tool
│   ├── iwi-validate                   # Validation framework
│   ├── iwi-verify-resources           # Resource verification
│   └── iwi-profile-generate           # Profile generator
│
├── lib/                               # Shared libraries
│   ├── iwi-common.sh                  # Common functions
│   ├── iwi-verify.sh                  # Verification functions
│   ├── iwi-capture.sh                 # Capture functions
│   └── iwi-test.sh                    # Testing functions
│
├── resources/                         # Trusted resources (VERIFIED)
│   ├── RESOURCES.md                   # Resource inventory
│   ├── bazzite-docs/                  # Static docs from docs.bazzite.gg
│   │   ├── Installation_Guide.html
│   │   ├── Gaming.html
│   │   ├── AMD_GPU_Tuning.html
│   │   └── ...
│   ├── checksums/                     # SHA256 checksums
│   │   ├── bazzite-docs.sha256
│   │   ├── iso-hashes.sha256
│   │   └── resources.sha256
│   ├── signatures/                    # GPG signatures
│   │   ├── bazzite-docs.sig
│   │   └── resources.sig
│   └── iso-hashes/                    # Official Bazzite ISO hashes
│       ├── bazzite-kde-20251112.sha256
│       └── bazzite-gnome-20251112.sha256
│
├── docs/                              # iWi documentation
│   ├── GETTING_STARTED.md
│   ├── INSTALLATION_CAPTURE.md
│   ├── RESOURCE_VERIFICATION.md
│   ├── VALIDATION_FRAMEWORK.md
│   └── BAZZITE_INTEGRATION.md
│
├── examples/                          # Example profiles
│   ├── amd-ryzen5-5600h-vega.yaml
│   ├── intel-nvidia-gaming.yaml
│   └── framework-laptop.yaml
│
├── tests/                             # Validation tests
│   ├── run-all-tests.sh
│   ├── test-deployment.sh
│   ├── test-packages.sh
│   ├── test-performance.sh
│   └── test-hardware.sh
│
└── templates/                         # Document templates
    ├── installation-plan.yaml
    ├── installation-capture.yaml
    └── installation-profile.yaml
```

---

## Trusted Resource Verification

### Resource Integrity

All resources in KENL13-iwi are **cryptographically verified**:

```bash
# Verify all resources before use
./bin/iwi-verify-resources

Expected output:
✓ Verifying Bazzite documentation...
  ✓ Installation_Guide.html (sha256: abc123...)
  ✓ Gaming.html (sha256: def456...)
  ✓ AMD_GPU_Tuning.html (sha256: ghi789...)

✓ Verifying ISO hashes...
  ✓ bazzite-kde-20251112.sha256 (matched official)
  ✓ bazzite-gnome-20251112.sha256 (matched official)

✓ Verifying signatures...
  ✓ bazzite-docs.sig (GPG: VERIFIED)
  ✓ resources.sig (GPG: VERIFIED)

✓ All resources verified successfully
```

**Verification Process:**
1. **SHA256 checksums** - Detect tampering
2. **GPG signatures** - Verify authenticity
3. **Before-and-after** - Check integrity before/after use
4. **Official sources** - ISO hashes match bazzite.gg exactly

### Resource Sources

| Resource | Source | Verification |
|----------|--------|--------------|
| **Bazzite Docs** | https://docs.bazzite.gg/ | SHA256 + GPG sig |
| **ISO Hashes** | https://download.bazzite.gg/ | Official SHA256 |
| **ujust Recipes** | https://github.com/ublue-os/bazzite | Git commit hash |
| **Templates** | KENL repository | Git signed commits |

### Updating Resources

```bash
# Update Bazzite documentation (maintainers only)
./bin/iwi-update-docs

# This:
# 1. Fetches latest from docs.bazzite.gg
# 2. Generates SHA256 checksums
# 3. Signs with GPG key
# 4. Updates RESOURCES.md
# 5. Commits with ATOM tag
```

---

## Installation Capture Workflow

### Step 1: Create Installation Plan

```bash
# Use template
cp templates/installation-plan.yaml my-install-plan.yaml

# Edit with your hardware and goals
vim my-install-plan.yaml
```

Example plan:

```yaml
---
classification: IWI-PLAN
atom: ATOM-IWI-20251112-010

hardware:
  cpu: AMD Ryzen 5 5600H
  gpu: AMD Radeon Vega Graphics
  ram: 16GB
  disk: 512GB NVMe

goals:
  - "Gaming with Proton"
  - "Dual-boot Windows 11"
  - "Development environment"

bazzite-variant: bazzite-kde
reason: "KDE Plasma for gaming customization"

partitioning:
  - mount: /
    size: 100GB
    filesystem: btrfs
  - mount: /home
    size: 400GB
    filesystem: btrfs

documentation:
  - resources/bazzite-docs/Installation_Guide.html
  - resources/bazzite-docs/Gaming.html
---
```

### Step 2: Verify Resources

```bash
# Before starting installation, verify all resources
./bin/iwi-verify-resources

# Verify Bazzite ISO hash
./bin/iwi-verify-iso ~/Downloads/bazzite-kde.iso
```

### Step 3: Start Capture

```bash
# Start installation capture
./bin/iwi-capture start --plan my-install-plan.yaml

# This creates: ~/.iwi/captures/capture-20251112-HHMMSS.yaml
```

### Step 4: Installation Execution

**During installation**, manually log key decisions:

```bash
# Log each important step
iwi-log "Selected KDE Plasma desktop"
iwi-log "Created 250GB Btrfs partition for Bazzite"
iwi-log "Enabled LUKS encryption - passphrase in Bitwarden"
iwi-log "Created user: matthew, added to wheel group"
```

Or use automatic capture (if supported):

```bash
# Some installers support automated logging
iwi-capture-auto --anaconda-log /var/log/anaconda/anaconda.log
```

### Step 5: Post-Install Configuration

```bash
# Log rpm-ostree packages
iwi-log-package vim "Preferred text editor"
iwi-log-package htop "System monitoring"

# Log ujust recipes
iwi-log-ujust install-steam "Gaming platform"
iwi-log-ujust install-codecs "Proprietary codecs"

# Log config changes
iwi-log-config ~/.config/MangoHud/MangoHud.conf \
  "Enabled FPS + GPU monitoring for gaming"
```

### Step 6: Generate Profile

```bash
# Create shareable installation profile
./bin/iwi-profile-generate \
  --capture ~/.iwi/captures/capture-20251112-*.yaml \
  --output my-installation-profile.yaml

# Verify profile
./bin/iwi-validate my-installation-profile.yaml
```

### Step 7: Validation

```bash
# Run all validation tests
./tests/run-all-tests.sh --profile my-installation-profile.yaml

# Individual tests
./tests/test-deployment.sh     # Verify rpm-ostree deployment
./tests/test-packages.sh        # Verify layered packages
./tests/test-performance.sh     # Network, GPU, disk performance
./tests/test-hardware.sh        # Hardware detection
```

---

## Resource Verification Details

### Checksums File Format

`resources/checksums/bazzite-docs.sha256`:

```
abc123def456...  resources/bazzite-docs/Installation_Guide.html
def456ghi789...  resources/bazzite-docs/Gaming.html
ghi789jkl012...  resources/bazzite-docs/AMD_GPU_Tuning.html
```

### Verification Process

```bash
#!/usr/bin/env bash
# resources/verify-docs.sh

set -euo pipefail

CHECKSUMS_FILE="resources/checksums/bazzite-docs.sha256"
DOCS_DIR="resources/bazzite-docs"

echo "Verifying Bazzite documentation..."

# Verify each file
while IFS= read -r line; do
    expected_hash=$(echo "$line" | awk '{print $1}')
    file_path=$(echo "$line" | awk '{print $2}')

    if [[ ! -f "$file_path" ]]; then
        echo "✗ File missing: $file_path"
        exit 1
    fi

    actual_hash=$(sha256sum "$file_path" | awk '{print $1}')

    if [[ "$expected_hash" == "$actual_hash" ]]; then
        echo "✓ $file_path"
    else
        echo "✗ $file_path (HASH MISMATCH)"
        echo "  Expected: $expected_hash"
        echo "  Actual:   $actual_hash"
        exit 1
    fi
done < "$CHECKSUMS_FILE"

echo "✓ All documentation verified"
```

### GPG Signature Verification

```bash
# Verify GPG signature on resources
gpg --verify resources/signatures/bazzite-docs.sig \
             resources/checksums/bazzite-docs.sha256

# Expected output:
# gpg: Signature made ...
# gpg: Good signature from "KENL Project <kenl@toolate28.dev>"
```

---

## ATOM Integration

Every iWi operation generates ATOM tags:

```yaml
# Installation capture
ATOM-IWI-20251112-010: Installation plan created
ATOM-IWI-20251112-011: Installation started
ATOM-IWI-20251112-012: Bazzite KDE selected
ATOM-IWI-20251112-013: Partitioning completed
ATOM-IWI-20251112-014: Installation completed
ATOM-IWI-20251112-015: Post-install configuration started
ATOM-IWI-20251112-016: vim package layered
ATOM-IWI-20251112-017: Steam installed via ujust
ATOM-IWI-20251112-018: Installation profile generated
ATOM-IWI-20251112-019: Validation tests passed
```

All ATOM tags logged to:
- `~/.atom-logs/atom-YYYYMMDD.log` (local)
- `~/.iwi/captures/capture-*.yaml` (structured)

---

## Validation Framework

### Test Categories

1. **Deployment Tests** (`test-deployment.sh`)
   - Verify rpm-ostree status
   - Check Bazzite variant
   - Validate deployment integrity

2. **Package Tests** (`test-packages.sh`)
   - Verify layered packages installed
   - Check package versions
   - Validate dependencies

3. **Performance Tests** (`test-performance.sh`)
   - Network latency (<10ms)
   - GPU acceleration enabled
   - Disk I/O benchmarks
   - RAM usage baseline

4. **Hardware Tests** (`test-hardware.sh`)
   - CPU detection
   - GPU detection
   - RAM capacity
   - Disk configuration

### Running Tests

```bash
# Run all tests
./tests/run-all-tests.sh

# Run specific test category
./tests/test-deployment.sh
./tests/test-performance.sh

# Run with profile validation
./tests/run-all-tests.sh --profile my-profile.yaml
```

Expected output:

```
═══════════════════════════════════════════════════════════
  iWi Validation Framework
═══════════════════════════════════════════════════════════

Running deployment tests...
  ✓ rpm-ostree deployment is bazzite-kde:stable
  ✓ System uptime > 5 minutes
  ✓ No pending deployments

Running package tests...
  ✓ vim installed
  ✓ htop installed
  ✓ No broken dependencies

Running performance tests...
  ✓ Network latency: 6.2ms (< 10ms target)
  ✓ GPU detected: AMD Vega
  ✓ Disk read speed: 2.8 GB/s
  ✓ RAM usage: 3.2GB / 16GB (20%)

Running hardware tests...
  ✓ CPU: AMD Ryzen 5 5600H (6 cores)
  ✓ GPU: AMD Radeon Vega Graphics
  ✓ RAM: 16GB
  ✓ Disk: 512GB NVMe

═══════════════════════════════════════════════════════════
  Results: 15/15 tests passed (100%)
═══════════════════════════════════════════════════════════
```

---

## Example: Complete Workflow

### Scenario: Fresh Bazzite Installation

```bash
# 1. Verify KENL13-iwi resources
cd ~/kenl/modules/KENL13-iwi
./bin/iwi-verify-resources

# 2. Create installation plan
cp templates/installation-plan.yaml my-plan.yaml
vim my-plan.yaml  # Edit with your hardware

# 3. Download Bazzite ISO
wget https://download.bazzite.gg/bazzite-kde-latest.iso

# 4. Verify ISO hash
./bin/iwi-verify-iso ~/Downloads/bazzite-kde-latest.iso

# 5. Create bootable USB (use Ventoy or dd)
# ... boot from USB, start installation ...

# 6. During installation, capture decisions
./bin/iwi-capture start --plan my-plan.yaml
iwi-log "Selected KDE Plasma"
iwi-log "Created 100GB / partition (Btrfs)"
iwi-log "Created 400GB /home partition (Btrfs)"
iwi-log "Enabled LUKS encryption"

# 7. After first boot, configure system
iwi-log-package vim "Text editor"
iwi-log-ujust install-steam "Gaming"
iwi-log-config ~/.config/MangoHud/MangoHud.conf "FPS overlay"

# 8. Generate installation profile
./bin/iwi-profile-generate \
  --capture ~/.iwi/captures/capture-*.yaml \
  --output ~/my-bazzite-install.yaml

# 9. Run validation
./tests/run-all-tests.sh --profile ~/my-bazzite-install.yaml

# 10. Share profile (optional)
cp ~/my-bazzite-install.yaml ~/kenl/modules/KENL13-iwi/examples/
```

---

## Bazzite Documentation Integration

### Static Documentation Copies

KENL13-iwi includes **offline copies** of essential Bazzite documentation:

```
resources/bazzite-docs/
├── Installation_Guide.html       # Fresh install instructions
├── Dual_Boot_Setup.html          # Dual-boot configuration
├── Gaming.html                   # Gaming setup
├── Steam.html                    # Steam configuration
├── Proton.html                   # Proton compatibility
├── AMD_GPU_Tuning.html           # AMD GPU optimizations
├── NVIDIA_GPU_Setup.html         # NVIDIA GPU setup
├── Network_Optimization.html     # Network tuning
├── ujust_Recipes.html            # ujust command reference
└── Troubleshooting.html          # Common issues
```

**Why static copies?**
- Works offline during installation
- Documentation snapshot (matches tested setup)
- Faster than web lookups
- Can diff old vs new when docs change

### Documentation Updates

```bash
# Update documentation (maintainers)
./bin/iwi-update-docs --snapshot-date 2025-11-12

# This:
# 1. Fetches latest from docs.bazzite.gg
# 2. Stores as HTML (preserving formatting)
# 3. Generates SHA256 checksums
# 4. Signs with GPG
# 5. Commits with ATOM tag
```

---

## Installation Profiles

### Shareable Profiles

Installation profiles can be shared with the community:

```bash
# Export profile for sharing
./bin/iwi-profile-export \
  --profile my-bazzite-install.yaml \
  --output bazzite-amd-ryzen5-gaming.yaml \
  --sanitize  # Remove private info (usernames, passphrases)
```

### Profile Repository

Community profiles stored in `examples/`:

```
examples/
├── amd-ryzen5-5600h-vega.yaml         # AMD gaming laptop
├── intel-core-i7-nvidia-rtx.yaml      # Intel/NVIDIA desktop
├── framework-laptop-11th-gen.yaml     # Framework laptop
├── steam-deck-desktop-mode.yaml       # Steam Deck
└── raspberry-pi-5.yaml                # ARM (if supported)
```

Each profile includes:
- Hardware specifications
- Installation decisions
- Performance benchmarks
- Validation test results
- ATOM trail references

---

## Security Considerations

### Trust Model

1. **Signed Resources**
   - All static resources signed with KENL GPG key
   - Verify signatures before use

2. **Official Sources**
   - ISO hashes match bazzite.gg official hashes
   - Documentation from docs.bazzite.gg (official)

3. **Immutable Base**
   - Bazzite uses immutable OS (rpm-ostree)
   - System changes are atomic and rollback-safe

4. **User-Space Only**
   - KENL13-iwi operates in user-space (`~/.iwi/`)
   - No system-level modifications required

### Threat Model

**Protected Against:**
- ✓ Resource tampering (SHA256 checksums)
- ✓ Unauthorized modifications (GPG signatures)
- ✓ Supply chain attacks (official sources)
- ✓ Documentation drift (static snapshots)

**Not Protected Against:**
- ✗ Compromised Bazzite ISO (verify with official hash!)
- ✗ Malicious installation profiles (review before use!)
- ✗ Physical access attacks (use LUKS encryption!)

---

## Dependencies

### System Dependencies

**Required:**
```bash
# Core tools (built into Bazzite)
bash >= 5.0
coreutils
rpm-ostree
systemd
```

**Optional:**
```bash
# Enhanced functionality
gpg          # Signature verification
jq           # JSON parsing
yq           # YAML parsing
mangohud     # Performance overlay
```

### KENL Dependencies

**Required:**
- **KENL0:** System operations and ATOM logging
- **KENL1:** Framework core (ATOM/SAGE/OWI)

**Optional:**
- **KENL2:** Gaming configurations
- **KENL3:** Development environments
- **KENL4:** Monitoring (for performance validation)

---

## Troubleshooting

### Resource Verification Fails

```bash
# Problem: SHA256 mismatch
✗ Installation_Guide.html (HASH MISMATCH)

# Solution: Re-download resource
./bin/iwi-update-docs --force --file Installation_Guide.html
```

### GPG Signature Verification Fails

```bash
# Problem: No public key
gpg: Can't check signature: No public key

# Solution: Import KENL GPG key
gpg --import resources/kenl-gpg-public-key.asc
```

### Capture Tool Not Working

```bash
# Problem: iwi-capture command not found

# Solution: Add bin/ to PATH
export PATH="$HOME/kenl/modules/KENL13-iwi/bin:$PATH"

# Or use full path
~/kenl/modules/KENL13-iwi/bin/iwi-capture start
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-11-12 | Initial release with resource verification |

---

## References

### Internal Documentation
- `IWI_SPECIFICATION.md` - Complete iWi specification
- `docs/GETTING_STARTED.md` - Quick start guide
- `docs/RESOURCE_VERIFICATION.md` - Verification details
- `MANIFEST.md` - Module manifest

### External Resources
- [Bazzite Official](https://bazzite.gg/) - Bazzite homepage
- [Bazzite Documentation](https://docs.bazzite.gg/) - Official docs
- [Universal Blue](https://universal-blue.org/) - Upstream project
- [rpm-ostree Documentation](https://coreos.github.io/rpm-ostree/) - Immutable OS

---

## Metadata

- **Created:** 2025-11-12
- **Last Updated:** 2025-11-12
- **Maintainer:** toolate28/kenl
- **ATOM Tag:** ATOM-DOC-20251112-005
- **Classification:** OWI-DOC
- **Status:** Active - Production Ready
- **Module:** KENL13-iwi (Installing With Intent)

---
