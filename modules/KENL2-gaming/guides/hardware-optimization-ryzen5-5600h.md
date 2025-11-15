# Hardware Optimization Guide: AMD Ryzen 5 5600H + Radeon Vega

**Target Hardware**: AMD Ryzen 5 5600H (Zen 3) with integrated Radeon Vega Graphics
**Platform**: Bazzite-DX (Fedora Atomic/rpm-ostree)
**Goal**: Maximum gaming performance with NO software fallbacks
**ATOM**: ATOM-HW-20251110-001

---

## Table of Contents

1. [Hardware Overview](#hardware-overview)
2. [Driver Stack](#driver-stack)
3. [Installation Steps](#installation-steps)
4. [Performance Tuning](#performance-tuning)
5. [Gaming Configuration](#gaming-configuration)
6. [Verification](#verification)
7. [Troubleshooting](#troubleshooting)
8. [Performance Expectations](#performance-expectations)
9. [Rollback](#rollback)

---

## Hardware Overview

Your system configuration (detected from Windows AMD chipset logs):

**CPU**: AMD Ryzen 5 5600H
- Architecture: Zen 3 (Cezanne, 7nm)
- Cores: 6 / Threads: 12
- Base: 3.3 GHz / Boost: 4.2 GHz
- TDP: 45W (configurable)
- Cache: 16MB L3

**GPU**: AMD Radeon Vega (integrated)
- Architecture: Vega 7nm
- Compute Units: 7 (448 stream processors)
- Clock: Up to 1800 MHz
- Memory: Shared system RAM (512MB-2GB dynamic)

**Storage**:
- Kingston OM8SEP4 512GB NVMe (primary, fast)
- Seagate FireCuda HDD (secondary, games)
- WDC 500GB HDD (tertiary, storage)

**Network**: Intel AX200/201 (Wi-Fi 6, BT 5.2)

**Gaming Tier**: Mid-range 1080p gaming
- Esports: 60-100 FPS (Medium-High)
- AAA: 30-60 FPS (Low-Medium)
- Indie: 60+ FPS (High-Ultra)

---

## Driver Stack

### The Modern AMD Linux Stack (NO FALLBACKS)

```
┌─────────────────────────────────────────┐
│  GAMES (Steam, Lutris, Heroic)          │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│  Proton / Wine / DXVK                   │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│  Vulkan: RADV (Mesa)                    │  ← AMD's open-source Vulkan
│  OpenGL: RadeonSI (Mesa)                │  ← Modern OpenGL 4.6
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│  Kernel Driver: amdgpu                  │  ← Modern driver (NOT radeon!)
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│  Hardware: Vega iGPU                    │
└─────────────────────────────────────────┘
```

**Critical**: Use `amdgpu` kernel driver, NOT `radeon` (legacy). The `radeon` driver is for pre-GCN cards and will give you terrible performance.

**Components**:
- **Kernel Driver**: `amdgpu` (in mainline kernel)
- **Mesa**: Version 24.0+ (Vulkan RADV + OpenGL RadeonSI)
- **Vulkan ICD**: `RADV` (Mesa's Vulkan implementation)
- **DXVK**: DirectX 9/10/11 → Vulkan translation
- **VKD3D**: DirectX 12 → Vulkan translation

**Why This Stack?**:
- AMD contributes directly to RADV/Mesa
- Often better performance than Windows drivers
- No proprietary blob required
- Hardware video decode/encode support
- Wayland support (better for gaming)

---

## Installation Steps

### Prerequisites

- Bazzite-DX installed (or any rpm-ostree system)
- Administrator access (sudo)
- Active internet connection
- 30 minutes for setup + reboot

### Step 1: Apply Kernel Parameters

These parameters optimize the kernel for Zen 3 + Vega gaming.

```bash
sudo rpm-ostree kargs \
  --append="amdgpu.ppfeaturemask=0xffffffff" \
  --append="amdgpu.gpu_recovery=1" \
  --append="amdgpu.dc=1" \
  --append="amdgpu.dpm=1" \
  --append="amdgpu.aspm=1" \
  --append="amd_pstate=active" \
  --append="amd_pstate.shared_mem=1" \
  --append="initcall_blacklist=acpi_cpufreq_init" \
  --append="transparent_hugepage=madvise" \
  --append="vm.max_map_count=2147483642" \
  --append="mitigations=off" \
  --append="nowatchdog" \
  --append="nmi_watchdog=0" \
  --append="split_lock_detect=off"
```

**What these do**:
- `amdgpu.ppfeaturemask=0xffffffff`: Enable ALL power/performance features
- `amdgpu.dc=1`: Enable Display Core (modern display stack)
- `amdgpu.dpm=1`: Dynamic Power Management
- `amd_pstate=active`: Modern AMD CPU frequency driver (better than acpi_cpufreq)
- `vm.max_map_count=2147483642`: Required for many games (Elden Ring, etc.)
- `mitigations=off`: Disable CPU security mitigations for ~5% performance boost
- `transparent_hugepage=madvise`: Better memory allocation for games

**Reboot required**: Yes (rpm-ostree staged deployment)

```bash
sudo systemctl reboot
```

### Step 2: Configure Mesa Environment

Create Mesa driver configuration to force hardware acceleration:

```bash
sudo mkdir -p /etc/environment.d
sudo tee /etc/environment.d/50-mesa.conf << 'EOF'
MESA_LOADER_DRIVER_OVERRIDE=radeonsi
MESA_GL_VERSION_OVERRIDE=4.6
MESA_GLSL_VERSION_OVERRIDE=460
RADV_PERFTEST=gpl,nggc,sam
AMD_VULKAN_ICD=RADV
EOF
```

**What these do**:
- `MESA_LOADER_DRIVER_OVERRIDE=radeonsi`: Force RadeonSI (modern) driver
- `RADV_PERFTEST=gpl,nggc,sam`: Enable experimental optimizations:
  - `gpl`: Graphics Pipeline Library (faster shader compilation)
  - `nggc`: Next-Gen Geometry Culling (better geometry performance)
  - `sam`: Smart Access Memory (even for iGPUs)
- `AMD_VULKAN_ICD=RADV`: Ensure RADV is used (not AMDVLK if installed)

**Reboot required**: No (environment vars loaded on next login)

### Step 3: Create Performance Services

Create systemd services to set performance profiles at boot.

**CPU Performance Service**:

```bash
sudo tee /etc/systemd/system/cpu-performance.service << 'EOF'
[Unit]
Description=Set CPU governor to performance
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/bash -c 'echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor'

[Install]
WantedBy=multi-user.target
EOF
```

**GPU Performance Service**:

```bash
sudo tee /etc/systemd/system/amd-gpu-performance.service << 'EOF'
[Unit]
Description=Set AMD GPU to performance mode
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/bash -c 'echo high > /sys/class/drm/card0/device/power_dpm_force_performance_level'
ExecStart=/usr/bin/bash -c 'echo 1 > /sys/class/drm/card0/device/pp_power_profile_mode'

[Install]
WantedBy=multi-user.target
EOF
```

**Enable and start services**:

```bash
sudo systemctl daemon-reload
sudo systemctl enable cpu-performance.service
sudo systemctl enable amd-gpu-performance.service
sudo systemctl start cpu-performance.service
sudo systemctl start amd-gpu-performance.service
```

**Reboot required**: No (services run immediately)

### Step 4 (Optional): Install RyzenAdj for TDP Control

RyzenAdj allows you to adjust CPU power limits for better performance or battery life.

```bash
# Check if available in repos
rpm-ostree search ryzenadj

# If available, layer it
sudo rpm-ostree install ryzenadj
sudo systemctl reboot
```

**After install, you can adjust TDP**:

```bash
# Max performance (65W boost)
sudo ryzenadj --stapm-limit=54000 --fast-limit=65000 --slow-limit=54000 --tctl-temp=95

# Balanced (45W stock)
sudo ryzenadj --stapm-limit=45000 --fast-limit=54000 --slow-limit=45000 --tctl-temp=90

# Battery saver (25W)
sudo ryzenadj --stapm-limit=25000 --fast-limit=35000 --slow-limit=25000 --tctl-temp=85
```

---

## Performance Tuning

### CPU Tuning

**Check current governor**:
```bash
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor | sort -u
# Should show: performance
```

**Check CPU frequency**:
```bash
watch -n1 "grep MHz /proc/cpuinfo | sort -u"
# Should boost to ~4200 MHz under load
```

**Manual governor change (temporary)**:
```bash
# Performance mode
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Power saving mode (for battery)
echo schedutil | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

### GPU Tuning

**Check GPU power state**:
```bash
cat /sys/class/drm/card0/device/power_dpm_force_performance_level
# Should show: high
```

**Check GPU clock speeds**:
```bash
cat /sys/class/drm/card0/device/pp_dpm_sclk
# Shows available GPU frequencies, * indicates current
```

**Check GPU power profile**:
```bash
cat /sys/class/drm/card0/device/pp_power_profile_mode
# 1 = 3D gaming (should be selected)
```

**Manual GPU tuning (temporary)**:
```bash
# Set to high performance
echo high | sudo tee /sys/class/drm/card0/device/power_dpm_force_performance_level

# Set to auto (dynamic)
echo auto | sudo tee /sys/class/drm/card0/device/power_dpm_force_performance_level

# Force GPU to max clock (testing only)
echo manual | sudo tee /sys/class/drm/card0/device/power_dpm_force_performance_level
echo 7 | sudo tee /sys/class/drm/card0/device/pp_dpm_sclk  # Force max state
```

---

## Gaming Configuration

### Proton Setup

**Environment variables for Steam games** (add to game launch options):

```bash
# Basic AMD optimizations
RADV_PERFTEST=gpl,nggc,sam PROTON_HIDE_NVIDIA_GPU=1 %command%

# For DirectX 9/10/11 games
RADV_PERFTEST=gpl,nggc,sam PROTON_USE_WINED3D=0 %command%

# For problematic games (force Vulkan)
RADV_PERFTEST=gpl,nggc,sam VKD3D_CONFIG=dxr %command%
```

**Recommended Proton version**: GE-Proton (latest)
- Download from: https://github.com/GloriousEggroll/proton-ge-custom
- Install to: `~/.steam/steam/compatibilitytools.d/`

### GameScope Configuration

GameScope provides better performance through resolution scaling and frame limiting.

**Basic GameScope launch (1080p native)**:
```bash
gamescope -W 1920 -H 1080 -r 60 -f -- %command%
```

**GameScope with FSR upscaling (720p→1080p for demanding games)**:
```bash
gamescope -w 1280 -h 720 -W 1920 -H 1080 -r 60 -F fsr -f -- %command%
```

**GameScope flags explained**:
- `-w 1280 -h 720`: Render resolution (game renders at 720p)
- `-W 1920 -H 1080`: Output resolution (display at 1080p)
- `-F fsr`: Enable AMD FidelityFX Super Resolution upscaling
- `-r 60`: Refresh rate limit (prevents wasted frames)
- `-f`: Fullscreen
- `--force-grab-cursor`: Fix mouse capture issues

**For Steam games**, add to launch options:
```bash
gamescope -w 1280 -h 720 -W 1920 -H 1080 -r 60 -F fsr -f -- %command%
```

### MangoHud Configuration

MangoHud shows real-time performance metrics.

**Create config** (`~/.config/MangoHud/MangoHud.conf`):

```ini
# Performance metrics
fps
frametime
gpu_stats
gpu_temp
gpu_core_clock
gpu_mem_clock
cpu_stats
cpu_temp
cpu_power
ram
vram

# Game info
wine
vulkan_driver
engine_version

# Display settings
font_size=24
position=top-left
toggle_hud=Shift_R+F12
background_alpha=0.5

# FPS limit (optional, use GameScope instead)
# fps_limit=60
```

**Enable for all Vulkan games**:
```bash
echo "MANGOHUD=1" >> ~/.config/environment.d/gaming.conf
```

**Enable for specific Steam game**:
```bash
mangohud %command%
```

---

## Verification

### Check Kernel Parameters

```bash
cat /proc/cmdline | grep amdgpu
# Should show all amdgpu.* parameters
```

### Check GPU Driver

```bash
lspci -k | grep -A 3 VGA
# Should show:
# Kernel driver in use: amdgpu
```

### Check Vulkan

```bash
vulkaninfo --summary | grep deviceName
# Should show: AMD Radeon ... (RADV ...)
```

### Check OpenGL

```bash
glxinfo | grep "OpenGL renderer"
# Should show: AMD ... (renoir, LLVM ...)
```

### Check Mesa Version

```bash
glxinfo | grep "OpenGL version"
# Should show: 4.6 (Mesa 24.x or newer)
```

### Full System Info

```bash
# GPU details
sudo lshw -C display

# CPU details
lscpu | grep -E "Model name|Architecture|CPU MHz"

# Driver stack
inxi -G

# Vulkan capabilities
vulkaninfo --summary
```

---

## Troubleshooting

### Issue: GPU Not Using amdgpu Driver

**Symptoms**: `lspci -k` shows `radeon` or `vesa` driver

**Fix**:
1. Ensure kernel parameters are applied: `cat /proc/cmdline`
2. Blacklist radeon driver:
   ```bash
   echo "blacklist radeon" | sudo tee /etc/modprobe.d/blacklist-radeon.conf
   sudo dracut --force
   sudo systemctl reboot
   ```

### Issue: Low FPS in Games

**Diagnose**:
1. Check if GPU is in performance mode:
   ```bash
   cat /sys/class/drm/card0/device/power_dpm_force_performance_level
   ```
2. Check MangoHud GPU clock speeds (should be near 1800 MHz)
3. Check CPU governor (should be `performance`)

**Fix**:
- Ensure services are running: `systemctl status amd-gpu-performance.service`
- Check for thermal throttling: `sensors` (install with `lm_sensors`)
- Use GameScope FSR for demanding games

### Issue: Stuttering/Frame Drops

**Causes**:
- VRAM allocation too low (iGPU shares system RAM)
- Background processes
- Thermal throttling

**Fix**:
1. Close background apps (browsers, Discord, etc.)
2. Allocate more VRAM in BIOS (2GB recommended)
3. Use GameScope to cap FPS: `-r 60` (prevents frame pacing issues)
4. Enable `zram`: `sudo systemctl enable --now zram-generator`

### Issue: Crashes in Specific Games

**Diagnose**:
1. Check Proton version (try GE-Proton)
2. Check ProtonDB: https://www.protondb.com/
3. Look for shader cache issues

**Fix**:
- Delete shader cache: `rm -rf ~/.steam/steam/steamapps/shadercache/`
- Try different Proton versions
- Add game-specific launch options from ProtonDB

### Issue: Black Screen on Boot

**Cause**: Bad kernel parameter or driver conflict

**Fix**:
1. Boot into previous rpm-ostree deployment:
   - At GRUB, select previous entry
2. Remove problematic kernel parameter:
   ```bash
   sudo rpm-ostree kargs --delete="[parameter]"
   sudo systemctl reboot
   ```
3. Or full rollback:
   ```bash
   sudo rpm-ostree rollback
   sudo systemctl reboot
   ```

---

## Performance Expectations

### Esports Titles (1080p)

| Game | Settings | Target FPS | Expected FPS |
|------|----------|------------|--------------|
| CS:GO / CS2 | Medium-High | 60 | 60-100 |
| Valorant | Medium | 60 | 80-120 |
| Rocket League | High | 60 | 60-90 |
| Fortnite | Medium | 60 | 60-80 |
| Overwatch 2 | Medium | 60 | 60-75 |

### AAA Titles (1080p)

| Game | Settings | Upscaling | Target FPS | Expected FPS |
|------|----------|-----------|------------|--------------|
| Cyberpunk 2077 | Low-Medium | FSR 720p | 30 | 30-45 |
| Elden Ring | Medium | Native | 45-60 | 45-60 |
| Red Dead Redemption 2 | Low-Medium | Native | 30-45 | 35-50 |
| Horizon Zero Dawn | Medium | FSR 720p | 30-45 | 40-50 |
| God of War | Low-Medium | FSR 720p | 30-45 | 35-50 |

### Indie Titles (1080p)

| Game | Settings | Target FPS | Expected FPS |
|------|----------|------------|--------------|
| Hades | High-Ultra | 60 | 60+ |
| Stardew Valley | Ultra | 60 | 60+ |
| Hollow Knight | Ultra | 60 | 60+ |
| Celeste | Ultra | 60 | 60+ |
| Dead Cells | Ultra | 60 | 60+ |

**Notes**:
- FSR upscaling = render at 720p, display at 1080p (40-50% performance gain)
- Vega iGPU is equivalent to ~GTX 1050 / RX 550
- Ray tracing NOT supported (hardware limitation)
- DLSS NOT supported (NVIDIA-only, use FSR instead)

---

## Rollback

If you experience issues, here's how to revert changes.

### Remove All Kernel Parameters

```bash
sudo rpm-ostree kargs \
  --delete="amdgpu.ppfeaturemask=0xffffffff" \
  --delete="amdgpu.gpu_recovery=1" \
  --delete="amdgpu.dc=1" \
  --delete="amdgpu.dpm=1" \
  --delete="amdgpu.aspm=1" \
  --delete="amd_pstate=active" \
  --delete="amd_pstate.shared_mem=1" \
  --delete="initcall_blacklist=acpi_cpufreq_init" \
  --delete="transparent_hugepage=madvise" \
  --delete="vm.max_map_count=2147483642" \
  --delete="mitigations=off" \
  --delete="nowatchdog" \
  --delete="nmi_watchdog=0" \
  --delete="split_lock_detect=off"

sudo systemctl reboot
```

### Disable Performance Services

```bash
sudo systemctl disable cpu-performance.service
sudo systemctl disable amd-gpu-performance.service
sudo systemctl stop cpu-performance.service
sudo systemctl stop amd-gpu-performance.service
```

### Remove Mesa Configuration

```bash
sudo rm /etc/environment.d/50-mesa.conf
```

### Full Rollback to Previous Deployment

```bash
sudo rpm-ostree rollback
sudo systemctl reboot
```

### Verify Rollback

```bash
# Check kernel parameters (should not show optimizations)
cat /proc/cmdline

# Check CPU governor (should be default: schedutil or powersave)
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
```

---

## Additional Resources

**ProtonDB** (game compatibility): https://www.protondb.com/
**GE-Proton** (custom Proton builds): https://github.com/GloriousEggroll/proton-ge-custom
**MangoHud** (performance overlay): https://github.com/flightlessmango/MangoHud
**GameScope** (Wayland compositor): https://github.com/ValveSoftware/gamescope
**RADV** (Mesa Vulkan): https://docs.mesa3d.org/drivers/radv.html

**Bazzite-specific**:
- Discord: https://discord.gg/bazzite
- Docs: https://docs.bazzite.gg/
- GitHub: https://github.com/ublue-os/bazzite

**AMD Linux Gaming**:
- /r/linux_gaming (Reddit)
- /r/Amd (Reddit)
- Level1Techs Forums

---

## Summary

This guide configured your AMD Ryzen 5 5600H + Vega system for optimal gaming performance with:

✅ Modern `amdgpu` kernel driver (NO legacy radeon fallback)
✅ RADV Vulkan + RadeonSI OpenGL (Mesa 24+)
✅ Performance CPU governor (4.2 GHz boost)
✅ High-performance GPU profile (1800 MHz max)
✅ Optimized kernel parameters for Zen 3 + Vega
✅ GameScope with FSR for demanding games
✅ MangoHud for performance monitoring

**Expected Results**:
- Esports: 60-100 FPS (Medium-High, 1080p)
- AAA: 30-60 FPS (Low-Medium, 1080p or FSR 720p)
- Indie: 60+ FPS (High-Ultra, 1080p)

**Next Steps**:
1. Reboot to apply kernel parameters
2. Test with a game you know (CS:GO, Rocket League, etc.)
3. Monitor performance with MangoHud
4. Adjust settings per-game based on performance

**ATOM Trail**: ATOM-HW-20251110-001

Enjoy gaming on Linux! 🎮🐧
