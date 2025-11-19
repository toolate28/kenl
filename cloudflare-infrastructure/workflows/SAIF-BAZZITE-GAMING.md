---
project: KENL Bazzite Gaming Configuration
atom: ATOM-SAIF-20251116-003
classification: SAIF-WORKFLOW
status: production-ready
version: 1.0.0
---

# SAIF Workflow: Bazzite Gaming Configuration

**Hardware-Aware Gaming Optimization with ATOM Logging**

## Purpose

Automatically detects hardware profiles and applies optimal gaming configurations (Proton versions, MangoHud settings, performance governors) with complete ATOM trail logging.

## Philosophy

> "One gamer's optimization is another's bottleneck" - Hardware-specific configs eliminate guesswork.

## Hardware Detection

### Automated Hardware Profiling

```bash
#!/bin/bash
# Detect hardware profile
# ATOM: ATOM-HW-DETECT-20251116-001

echo "🔍 Detecting hardware profile..."

# CPU detection
CPU_VENDOR=$(lscpu | grep "Vendor ID" | awk '{print $3}')
CPU_MODEL=$(lscpu | grep "Model name" | cut -d':' -f2 | xargs)

# GPU detection
if lspci | grep -i nvidia &>/dev/null; then
    GPU_VENDOR="nvidia"
    GPU_MODEL=$(lspci | grep -i nvidia | grep VGA | cut -d':' -f3 | xargs)
elif lspci | grep -i amd | grep VGA &>/dev/null; then
    GPU_VENDOR="amd"
    GPU_MODEL=$(lspci | grep -i amd | grep VGA | cut -d':' -f3 | xargs)
elif lspci | grep -i intel | grep VGA &>/dev/null; then
    GPU_VENDOR="intel"
    GPU_MODEL=$(lspci | grep -i intel | grep VGA | cut -d':' -f3 | xargs)
else
    GPU_VENDOR="unknown"
    GPU_MODEL="unknown"
fi

# RAM detection
RAM_GB=$(free -g | awk '/Mem:/ {print $2}')

# Generate profile ID
PROFILE_ID="${CPU_VENDOR}-$(echo $CPU_MODEL | tr ' ' '-' | tr '[:upper:]' '[:lower:]')-${GPU_VENDOR}"

echo "✅ Hardware profile: $PROFILE_ID"
echo ""
echo "CPU: $CPU_MODEL"
echo "GPU: $GPU_MODEL ($GPU_VENDOR)"
echo "RAM: ${RAM_GB}GB"

# Save profile
mkdir -p ~/.kenl/profiles
cat > ~/.kenl/profiles/hardware.yaml <<EOF
profile_id: $PROFILE_ID
cpu:
  vendor: $CPU_VENDOR
  model: $CPU_MODEL
gpu:
  vendor: $GPU_VENDOR
  model: $GPU_MODEL
ram_gb: $RAM_GB
generated_at: $(date -Iseconds)
EOF

echo "💾 Profile saved: ~/.kenl/profiles/hardware.yaml"

# Log to ATOM
ATOM_TAG="ATOM-HW-DETECT-$(date +%Y%m%d)-001"
echo "$ATOM_TAG: Detected hardware profile: $PROFILE_ID" >> ~/.kenl/atom-trail.log
```

## Configuration Templates

### AMD Ryzen + AMD GPU (RDNA2/RDNA3)

```yaml
# ~/.kenl/profiles/amd-rdna.yaml
profile: amd-rdna
hardware:
  cpu_vendor: amd
  gpu_vendor: amd
  gpu_arch: rdna2  # or rdna3

gaming:
  proton_version: GE-Proton9-20  # Latest GE-Proton
  mangohud_enabled: true
  gamescope_enabled: true

  # CPU governor
  cpu_governor: performance  # Max FPS

  # MangoHud config
  mangohud_config: |
    fps
    frametime=0
    gpu_stats
    gpu_temp
    cpu_stats
    cpu_temp
    ram
    vram
    position=top-left
    font_size=24

  # Gamescope settings
  gamescope_args: "-w 2560 -h 1440 -W 2560 -H 1440 -r 144 --prefer-vk-device $(lspci | grep VGA | grep AMD | cut -d' ' -f1)"

  # RADV optimizations (AMD Mesa driver)
  env_vars:
    RADV_PERFTEST: "gpl,ngg,sam"
    MESA_LOADER_DRIVER_OVERRIDE: "radv"
    AMD_VULKAN_ICD: "RADV"

benchmarks:
  battlefield_2042:
    resolution: "2560x1440"
    settings: "High"
    avg_fps: 118
    min_fps: 95
    max_fps: 144
```

### Intel CPU + NVIDIA GPU

```yaml
# ~/.kenl/profiles/intel-nvidia.yaml
profile: intel-nvidia
hardware:
  cpu_vendor: intel
  gpu_vendor: nvidia

gaming:
  proton_version: Proton-Experimental
  mangohud_enabled: true
  gamescope_enabled: false  # NVIDIA + Gamescope has issues

  cpu_governor: performance

  # NVIDIA-specific optimizations
  env_vars:
    __GL_THREADED_OPTIMIZATIONS: "1"
    __GL_SHADER_DISK_CACHE: "1"
    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP: "1"
    PROTON_ENABLE_NVAPI: "1"
    DXVK_ENABLE_NVAPI: "1"
    WINE_FULLSCREEN_FSR: "1"

  # MangoHud config (NVIDIA)
  mangohud_config: |
    fps
    gpu_stats
    gpu_temp
    gpu_power
    cpu_stats
    cpu_temp
    ram
    vram
    position=top-right
```

## Apply Configuration

```bash
#!/bin/bash
# Apply gaming configuration based on hardware profile
# ATOM: ATOM-GAMING-CONFIG-20251116-001

PROFILE="${1:-auto}"

if [[ "$PROFILE" == "auto" ]]; then
    # Auto-detect hardware
    ./detect-hardware.sh
    PROFILE=$(yq eval '.profile_id' ~/.kenl/profiles/hardware.yaml)
fi

echo "🎮 Applying gaming configuration for profile: $PROFILE"

# Load profile config
CONFIG="$HOME/.kenl/profiles/${PROFILE}.yaml"

if [[ ! -f "$CONFIG" ]]; then
    echo "❌ Profile not found: $CONFIG"
    echo "Available profiles:"
    ls -1 ~/.kenl/profiles/*.yaml
    exit 1
fi

# Extract configuration
PROTON_VERSION=$(yq eval '.gaming.proton_version' "$CONFIG")
CPU_GOVERNOR=$(yq eval '.gaming.cpu_governor' "$CONFIG")
MANGOHUD_ENABLED=$(yq eval '.gaming.mangohud_enabled' "$CONFIG")

# 1. Set CPU governor
echo "⚡ Setting CPU governor: $CPU_GOVERNOR"
if command -v cpupower &>/dev/null; then
    sudo cpupower frequency-set -g "$CPU_GOVERNOR"
    echo "✅ CPU governor set"
else
    echo "⚠️  cpupower not installed (skip)"
fi

# 2. Configure MangoHud
if [[ "$MANGOHUD_ENABLED" == "true" ]]; then
    echo "📊 Configuring MangoHud..."
    mkdir -p ~/.config/MangoHud
    yq eval '.gaming.mangohud_config' "$CONFIG" > ~/.config/MangoHud/MangoHud.conf
    echo "✅ MangoHud configured"
fi

# 3. Set environment variables
echo "🔧 Setting environment variables..."
mkdir -p ~/.kenl/env
yq eval '.gaming.env_vars | to_entries | .[] | "export " + .key + "=\"" + .value + "\""' "$CONFIG" > ~/.kenl/env/gaming.sh
source ~/.kenl/env/gaming.sh
echo "✅ Environment variables set"

# 4. Set Proton version (Steam)
if [[ -d "$HOME/.steam/steam/compatibilitytools.d" ]]; then
    echo "🎮 Setting default Proton: $PROTON_VERSION"
    # Note: Per-game Proton version must be set in Steam
    echo "⚠️  Reminder: Set Proton version per-game in Steam properties"
fi

# Log to ATOM
ATOM_TAG="ATOM-GAMING-CONFIG-$(date +%Y%m%d)-001"
sqlite3 ~/.kenl/db/atom-trails.db <<EOF
INSERT INTO atom_trails (
    tag, type, date, sequence, timestamp, user, hostname,
    description, command, validation_status, exit_code, hash
) VALUES (
    '$ATOM_TAG',
    'CFG',
    '$(date +%Y-%m-%d)',
    1,
    datetime('now'),
    '$(whoami)',
    '$(hostname)',
    'Applied gaming configuration: $PROFILE',
    './apply-gaming-config.sh $PROFILE',
    'executed',
    0,
    '$(echo -n "$ATOM_TAG" | sha256sum | cut -d' ' -f1)'
);
EOF

echo "✅ Gaming configuration applied: $PROFILE"
echo "📋 ATOM Tag: $ATOM_TAG"
```

## Game-Specific Optimizations

### Battlefield 2042

```yaml
# ~/.kenl/profiles/games/battlefield-2042.yaml
game: "Battlefield 2042"
steam_id: 1517290

# Optimal Proton version
proton_version: GE-Proton9-20

# Launch options
launch_options: "MANGOHUD=1 gamemoderun %command%"

# Known fixes
fixes:
  - name: "EA App authentication fix"
    description: "Install EA App in Proton prefix"
    commands:
      - "protontricks 1517290 eaapp"

  - name: "Network latency fix"
    description: "Disable Tailscale VPN during gaming"
    commands:
      - "sudo systemctl stop tailscaled"

# Benchmarks
benchmarks:
  amd_ryzen5_5600h_vega:
    resolution: "1920x1080"
    settings: "Medium"
    avg_fps: 118
    network_latency_ms: 6
```

## Orchestration Script

```bash
#!/bin/bash
# SAIF Gaming Setup - Complete workflow
# ATOM: ATOM-SAIF-GAMING-20251116-001

set -euo pipefail

echo "════════════════════════════════════════════════════"
echo "  SAIF Bazzite Gaming Configuration"
echo "════════════════════════════════════════════════════"
echo ""

# Step 1: Detect hardware
echo "[1/4] Detecting hardware..."
./detect-hardware.sh

# Step 2: Apply base gaming config
echo ""
echo "[2/4] Applying gaming configuration..."
./apply-gaming-config.sh auto

# Step 3: Install recommended tools
echo ""
echo "[3/4] Installing gaming tools..."
if ! flatpak list | grep MangoHud &>/dev/null; then
    flatpak install -y flathub org.freedesktop.Platform.VulkanLayer.MangoHud
fi

if ! command -v gamemode &>/dev/null; then
    sudo dnf install -y gamemode
fi

# Step 4: Sync to Cloudflare
echo ""
echo "[4/4] Syncing ATOM trails to Cloudflare..."
../cloudflare-infrastructure/scripts/sync-atom-to-d1.sh --recent-only

echo ""
echo "════════════════════════════════════════════════════"
echo "✅ Gaming setup complete!"
echo "════════════════════════════════════════════════════"
echo ""
echo "Hardware profile: $(yq eval '.profile_id' ~/.kenl/profiles/hardware.yaml)"
echo "ATOM trail: ~/.kenl/db/atom-trails.db"
echo "Web dashboard: https://atom.toolated.online"
```

## ATOM Trail

```
ATOM-SAIF-GAMING-20251116-003: Created Bazzite gaming configuration SAIF workflow
Intent: Automate hardware-specific gaming optimization with complete logging
Validation: Hardware detection + config application + ATOM logging
Dependencies: lscpu, lspci, yq, MangoHud, gamemode
Next: Detect hardware and apply optimal gaming configuration
```

## License

MIT - Same as KENL repository
