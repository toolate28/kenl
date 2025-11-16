# Hardware Profiles for Gaming

Hardware-specific optimization configurations for gaming on Bazzite-DX and other immutable Linux distributions.

**ATOM**: ATOM-HW-20251110-001

---

## Overview

This directory contains optimized configurations for specific hardware combinations, focusing on **NO SOFTWARE FALLBACKS** - only hardware acceleration.

### Current Profiles

#### AMD Ryzen 5 5600H + Radeon Vega iGPU

**Target Hardware**:
- CPU: AMD Ryzen 5 5600H (Zen 3, 6C/12T, up to 4.2 GHz)
- GPU: AMD Radeon Vega integrated graphics (7 CUs, 448 SPs, up to 1800 MHz)
- Gaming Tier: Mid-range 1080p (esports 60-100 FPS, AAA 30-60 FPS)

**Files**:
- `ryzen5-5600h-vega.yaml` - Complete hardware profile and configuration
- `environment.d/50-mesa-amd.conf` - Mesa driver configuration
- `environment.d/60-gaming-amd.conf` - Gaming environment variables
- `systemd/cpu-performance.service` - CPU performance governor service
- `systemd/amd-gpu-performance.service` - GPU performance mode service
- `ujust/optimize-ryzen5-5600h.just` - Automated setup recipe

**Documentation**:
- `../../guides/hardware-optimization-ryzen5-5600h.md` - Complete optimization guide

---

## Quick Start

### AMD Ryzen 5 5600H + Vega

**Automated Setup (Recommended)**:

```bash
# Copy ujust recipe
sudo cp ujust/optimize-ryzen5-5600h.just /etc/just/kenl.just

# Run optimization
ujust optimize-ryzen5-5600h

# Reboot
sudo systemctl reboot

# Verify after reboot
ujust verify-ryzen5-5600h
```

**Manual Setup**:

See the complete guide at `../../guides/hardware-optimization-ryzen5-5600h.md`

---

## File Structure

```
hardware-profiles/
├── README.md                           # This file
├── ryzen5-5600h-vega.yaml             # Hardware profile
├── environment.d/                      # Environment configs
│   ├── 50-mesa-amd.conf               # Mesa driver settings
│   └── 60-gaming-amd.conf             # Gaming environment
├── systemd/                            # System services
│   ├── cpu-performance.service        # CPU governor
│   └── amd-gpu-performance.service    # GPU performance mode
└── ujust/                              # Just recipes
    └── optimize-ryzen5-5600h.just     # Automated setup
```

---

## Installation Methods

### Method 1: Automated (ujust)

Best for most users - handles everything automatically.

```bash
# Install ujust recipe
sudo cp ujust/optimize-[hardware].just /etc/just/kenl.just

# Run optimization
ujust optimize-[hardware]

# Reboot
sudo systemctl reboot
```

### Method 2: Manual Step-by-Step

For users who want to understand each step or customize the configuration.

1. **Apply kernel parameters** (requires reboot):
   ```bash
   # See hardware-specific .yaml file for parameters
   sudo rpm-ostree kargs --append="..."
   ```

2. **Install environment configs**:
   ```bash
   sudo cp environment.d/*.conf /etc/environment.d/
   ```

3. **Install systemd services**:
   ```bash
   sudo cp systemd/*.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable cpu-performance.service
   sudo systemctl enable amd-gpu-performance.service
   ```

4. **Reboot**:
   ```bash
   sudo systemctl reboot
   ```

### Method 3: Cherry-Pick

For advanced users who want specific optimizations only.

**Example: Only GPU performance tuning**:
```bash
sudo cp systemd/amd-gpu-performance.service /etc/systemd/system/
sudo systemctl enable --now amd-gpu-performance.service
```

**Example: Only Mesa driver config**:
```bash
sudo cp environment.d/50-mesa-amd.conf /etc/environment.d/
# Re-login or reboot
```

---

## Verification

### Automated Verification

```bash
ujust verify-[hardware]
```

### Manual Verification

**Check kernel parameters**:
```bash
cat /proc/cmdline | grep amdgpu
```

**Check GPU driver**:
```bash
lspci -k | grep -A 3 VGA
# Should show: Kernel driver in use: amdgpu
```

**Check CPU governor**:
```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
# Should show: performance
```

**Check GPU performance level**:
```bash
cat /sys/class/drm/card0/device/power_dpm_force_performance_level
# Should show: high
```

**Check Vulkan driver**:
```bash
vulkaninfo --summary | grep deviceName
# Should show: AMD ... (RADV ...)
```

---

## Rollback

If you experience issues, you can rollback all changes.

### Automated Rollback

```bash
ujust rollback-[hardware]
sudo systemctl reboot
```

### Manual Rollback

**Remove kernel parameters**:
```bash
sudo rpm-ostree kargs --delete="amdgpu.ppfeaturemask=0xffffffff" ...
# (see .yaml file for full list)
```

**Disable services**:
```bash
sudo systemctl disable cpu-performance.service
sudo systemctl disable amd-gpu-performance.service
```

**Remove config files**:
```bash
sudo rm /etc/environment.d/50-mesa-amd.conf
sudo rm /etc/environment.d/60-gaming-amd.conf
```

**Or use rpm-ostree rollback**:
```bash
sudo rpm-ostree rollback
sudo systemctl reboot
```

---

## Adding New Hardware Profiles

To add a new hardware profile:

1. **Create hardware profile YAML**:
   ```yaml
   hardware_profile:
     id: HW-[CPU]-[GPU]-001
     name: "Hardware Name"
     # ... (see ryzen5-5600h-vega.yaml as template)
   ```

2. **Create environment configs** (if needed):
   - `environment.d/50-mesa-[vendor].conf` for GPU driver settings
   - `environment.d/60-gaming-[hardware].conf` for gaming variables

3. **Create systemd services** (if needed):
   - `systemd/cpu-performance-[hardware].service`
   - `systemd/gpu-performance-[hardware].service`

4. **Create ujust recipe**:
   ```bash
   # ujust/optimize-[hardware].just
   optimize-[hardware]:
       # Setup steps
   ```

5. **Create documentation**:
   - `../../guides/hardware-optimization-[hardware].md`

6. **Test thoroughly**:
   - Verify all components work
   - Test gaming performance
   - Document rollback procedures
   - Create ATOM tag: `ATOM-HW-[YYYYMMDD]-[NNN]`

---

## Common Optimizations by Vendor

### AMD

**Kernel Parameters**:
- `amdgpu.ppfeaturemask=0xffffffff` - Enable all power features
- `amd_pstate=active` - Modern CPU frequency driver
- `amdgpu.dc=1` - Display Core (required for modern features)

**Environment**:
- `AMD_VULKAN_ICD=RADV` - Use open-source Vulkan driver
- `RADV_PERFTEST=gpl,nggc,sam` - Enable experimental features
- `MESA_LOADER_DRIVER_OVERRIDE=radeonsi` - Force modern OpenGL driver

### Intel (Future)

**Kernel Parameters** (placeholder):
- `i915.enable_guc=3` - Enable GuC/HuC firmware
- `i915.enable_fbc=1` - Framebuffer compression

**Environment** (placeholder):
- `INTEL_DEBUG=0` - Disable debug
- `ANV_ENABLE_PIPELINE_CACHE=1` - Enable Vulkan pipeline cache

### NVIDIA (Future)

**Note**: Proprietary drivers required, configuration differs significantly.

---

## Performance Expectations

### Entry-Level (Vega iGPU, Intel Iris Xe)

- **Esports** (CS2, Valorant, Rocket League): 60-100 FPS at Medium-High
- **AAA** (Cyberpunk, RDR2, Elden Ring): 30-60 FPS at Low-Medium (720p-1080p)
- **Indie** (Hades, Stardew Valley): 60+ FPS at High-Ultra

### Mid-Range (GTX 1060, RX 580, Arc A380)

- **Esports**: 100-144 FPS at High-Ultra
- **AAA**: 60-90 FPS at Medium-High (1080p)
- **Indie**: 60+ FPS at Ultra

### High-End (RTX 3060+, RX 6700+, Arc A770)

- **Esports**: 144-240 FPS at Ultra
- **AAA**: 60-120 FPS at High-Ultra (1080p-1440p)
- **Ray Tracing**: Supported (with performance hit)

---

## Troubleshooting

### Low FPS

1. Check CPU governor: `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`
2. Check GPU performance level: `cat /sys/class/drm/card0/device/power_dpm_force_performance_level`
3. Use MangoHud to monitor: `MANGOHUD=1 %command%`
4. Check for thermal throttling: `sensors`

### Driver Issues

1. Verify correct driver: `lspci -k | grep -A 3 VGA`
2. Check Mesa version: `glxinfo | grep "OpenGL version"`
3. Verify Vulkan: `vulkaninfo --summary`
4. Check kernel messages: `dmesg | grep -i drm`

### Crashes

1. Check ProtonDB for game-specific issues
2. Try different Proton versions (GE-Proton recommended)
3. Clear shader cache: `rm -rf ~/.steam/steam/steamapps/shadercache/`
4. Check system logs: `journalctl -b -p err`

---

## Resources

**Proton/Gaming**:
- ProtonDB: https://www.protondb.com/
- GE-Proton: https://github.com/GloriousEggroll/proton-ge-custom
- GameScope: https://github.com/ValveSoftware/gamescope
- MangoHud: https://github.com/flightlessmango/MangoHud

**AMD Drivers**:
- RADV (Mesa): https://docs.mesa3d.org/drivers/radv.html
- AMD Linux: https://www.amd.com/en/support/linux-drivers

**Bazzite**:
- Docs: https://docs.bazzite.gg/
- Discord: https://discord.gg/bazzite
- GitHub: https://github.com/ublue-os/bazzite

**Community**:
- /r/linux_gaming
- /r/Amd
- Level1Techs Forums

---

## Contributing

To contribute a new hardware profile:

1. Test thoroughly on target hardware
2. Document all optimizations and their effects
3. Include performance metrics (FPS in various games)
4. Provide rollback procedures
5. Create PR with:
   - Hardware profile YAML
   - Environment configs
   - Systemd services
   - ujust recipe
   - Optimization guide
   - ATOM tag

**Format**: Follow existing profiles as templates.

---

## License

Part of the KENL framework - see repository root LICENSE for details.

**ATOM**: ATOM-HW-20251110-001
