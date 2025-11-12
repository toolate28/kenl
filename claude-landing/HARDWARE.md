---
title: Hardware Configuration - AMD Ryzen 5 5600H + Vega
date: 2025-11-12
atom: ATOM-DOC-20251112-004
status: active
classification: OWI-DOC
---

# Hardware Configuration

**Last Updated:** 2025-11-12
**ATOM Tag:** ATOM-DOC-20251112-004

## System Overview

**Manufacturer:** [TBD - Laptop/Desktop model]
**Target Use Case:** Gaming + Development (Windows 10 EOL migration)
**OS Target:** Bazzite-DX KDE (Fedora Atomic 43)

---

## CPU

**Model:** AMD Ryzen 5 5600H
- **Architecture:** Zen 3 (7nm)
- **Cores:** 6 cores
- **Threads:** 12 threads (SMT enabled)
- **Base Clock:** 3.3 GHz
- **Boost Clock:** 4.2 GHz (single-core max)
- **TDP:** 45W (laptop variant)
- **Cache:**
  - L1: 384 KB (64 KB per core)
  - L2: 3 MB (512 KB per core)
  - L3: 16 MB (shared)

**Features:**
- ✅ AMD-V (Virtualization - for distrobox, KVM)
- ✅ SMT (Simultaneous Multithreading)
- ✅ Precision Boost 2
- ✅ Power management states (C-states)

**Performance:**
- Single-thread: Good for gaming
- Multi-thread: Excellent for compilation, AI workloads
- Gaming: 1080p 60+ FPS capable (dependent on GPU)

**Linux Compatibility:**
- ✅ Excellent - Native support in kernel 5.11+
- ✅ AMD P-State driver available
- ✅ Temperature monitoring via k10temp

**Optimization Files:**
- `modules/KENL2-gaming/configs/hardware/amd-ryzen5-5600h-vega-optimal.yaml`
- CPU governor scripts for performance/balanced modes

---

## GPU

**Model:** AMD Radeon Vega Graphics (Integrated)
- **Architecture:** Vega (GCN 5.0)
- **Compute Units:** 7 CUs
- **Stream Processors:** 448 SPs
- **Base Clock:** ~1400 MHz (varies by TDP)
- **Boost Clock:** ~1800 MHz
- **Memory:** Shared system RAM (UMA)
- **Memory Bandwidth:** Depends on RAM speed (DDR4-3200 recommended)

**Features:**
- ✅ FreeSync support
- ✅ Vulkan 1.3
- ✅ DirectX 12
- ✅ OpenGL 4.6
- ✅ Hardware video decode (H.264, H.265, VP9, AV1)

**Performance:**
- 1080p Low-Medium: 30-60 FPS (esports titles)
- 1080p High: 20-40 FPS (AAA titles)
- 720p: 60+ FPS (most games)

**Linux Compatibility:**
- ✅ Excellent - AMDGPU driver (open-source)
- ✅ Mesa 25.2.6+ for latest optimizations
- ✅ RADV Vulkan driver (better than Windows in many cases)
- ✅ No proprietary driver needed

**Proton/Gaming:**
- ✅ Native RADV Vulkan (faster than AMDVLK)
- ✅ ACO shader compiler (faster compilation)
- ✅ AMD FidelityFX Super Resolution (FSR) support

**Optimization:**
- Force GPU to high performance mode
- Disable power management during gaming
- Use GameScope for resolution scaling

---

## Memory

**Capacity:** 16 GB
**Type:** DDR4 (assumed, verify with `dmidecode`)
**Speed:** Likely 3200 MHz (verify)
**Channels:** Dual-channel (important for iGPU bandwidth!)

**Performance Impact:**
- Vega iGPU shares system RAM
- Dual-channel crucial for gaming performance
- 3200 MHz provides ~51 GB/s bandwidth

**Linux Tools:**
- Check with: `sudo dmidecode -t memory`
- Monitor with: `free -h`, `vmstat`

---

## Storage

### Disk 0: Internal NVMe (System Drive)

**Model:** KINGSTON OM8SEP4512N-A0
**Capacity:** 512 GB (476 GiB)
**Type:** NVMe PCIe SSD
**Interface:** PCIe 3.0 x4 (likely)

**Current Partitions (Windows):**
- C: 406 GB NTFS (Windows 11 system)
- D: 104 GB NTFS (Data partition)

**Target Configuration (After Bazzite Install):**
- Option 1: Dual-boot (Windows 11 + Bazzite on same drive)
- Option 2: Full Bazzite (wipe Windows, reclaim all 512 GB)

**Performance:**
- Read: ~3000-3500 MB/s (PCIe 3.0 typical)
- Write: ~2000-3000 MB/s
- IOPS: Excellent for OS and fast game loads

**Linux Compatibility:**
- ✅ Excellent - NVMe support in all kernels
- ✅ TRIM support automatic
- ✅ Power management (APST) for laptop battery life

### Disk 1: External HDD (Data/Games)

**Model:** Seagate FireCuda SSHD
**Capacity:** 2 TB (1.86 TiB)
**Type:** Hybrid (HDD + NAND cache)
**Interface:** USB 3.0/3.1 (SCSI over USB)

**Current Status:** ⚠️ **CORRUPTED - Needs repartitioning**

**Current Partitions:**
- Partition 0: 1.33 TB (GPT Basic Data)
- Partition 1: 500 GB (GPT Unknown type)

**Target Layout:** (See `scripts/1.8TB_EXTERNAL_DRIVE_LAYOUT.md`)
```
sdb1: Games-Universal (900GB, NTFS)    - Steam library (Windows + Linux)
sdb2: Claude-AI-Data (500GB, ext4)     - AI datasets, models, vectors
sdb3: Development (200GB, ext4)        - Distrobox, venvs, git repos
sdb4: Windows-Only (150GB, NTFS)       - EA App, anti-cheat games
sdb5: Transfer (50GB, exFAT)           - Quick file exchange between OSes
```

**Performance:**
- Sequential Read: ~140 MB/s (HDD + cache)
- Sequential Write: ~130 MB/s
- NAND Cache: 8-32 GB (faster for frequently accessed files)
- Use for: Game storage, large datasets

**Linux Compatibility:**
- ✅ Excellent - USB mass storage standard
- ✅ NTFS support via ntfs-3g (slower than ext4)
- ⚠️ exFAT requires `exfat-utils` package
- ✅ Auto-mount via `/etc/fstab`

### Other Storage

**Disk 4: Ventoy USB (Bootable Installer)**
- F: 28 GB exFAT (Ventoy - ISO storage)
- G: 33 MB FAT (VTOYEFI - EFI boot partition)
- **Status:** ✅ Ready for Bazzite ISO

---

## Network

### Physical Adapter

**Type:** Ethernet (assumed wired connection)
**Status:** Active
**Driver:** (Check with `lspci -k` or `ip link` on Linux)

**Performance (Current Baseline):**
- **Latency:** 5.9-6.2 ms average (EXCELLENT)
- **Test Hosts:** 5/5 passing
- **MTU:** 1492 bytes (optimized from default 1500)
- **Connection:** Stable, consistent

**Optimization Applied:**
- Tailscale VPN disabled (was causing 174ms latency)
- MTU tuned for minimal fragmentation
- Test-KenlNetwork validated

**Linux Configuration:**
- See: `modules/KENL2-gaming/configs/network/optimize-network-gaming.sh`
- TCP window scaling, SACK, ECN enabled
- BDP calculation for optimal buffer sizes

### VPN Status

**Tailscale:**
- **Status:** Disabled for gaming (service stopped)
- **Impact:** 174 ms → 6 ms latency reduction when disabled
- **Use Case:** Enable for remote access, disable for gaming
- **Alternative:** Split-tunneling or WSL2-only Tailscale

---

## Display

**Resolution:** 1920x1080 (Full HD)
**Refresh Rate:** (Verify - likely 60Hz or 144Hz)
**Panel Type:** (Verify - IPS/TN/VA)

**Gaming Considerations:**
- 1080p is optimal for Vega iGPU
- FreeSync support available
- GameScope can be used for resolution scaling

**Linux Tools:**
- Check with: `xrandr` or `wayland-info`
- Configure with: KDE Display Settings

---

## Peripherals

**Input Devices:**
- (TBD - Keyboard/Mouse details if relevant for gaming)

**Audio:**
- (TBD - Verify audio chipset with `lspci | grep -i audio`)
- Linux compatibility usually excellent (snd-hda-intel)

---

## Thermals & Power

**Cooling:**
- (Laptop: integrated cooling solution)
- Monitor with: `sensors` command (lm-sensors package)
- AMD k10temp for CPU, amdgpu for GPU

**Power Management:**
- Laptop: TLP or power-profiles-daemon
- Performance mode for gaming
- Balanced mode for general use
- Power-save mode for battery life

**Thermal Targets:**
- CPU: <85°C gaming, <95°C absolute max
- GPU: <80°C gaming, <90°C absolute max

**Tools:**
- `sensors` - Real-time monitoring
- `powerstat` - Power consumption
- `turbostat` - CPU frequency/C-state monitoring

---

## Virtualization & Containers

**VM Support:**
- ✅ AMD-V enabled (hardware virtualization)
- ✅ KVM/QEMU support
- ✅ libvirt for VM management

**Container Support:**
- ✅ Podman (rootless containers - Bazzite default)
- ✅ Distrobox (for development environments)
- ✅ Docker (if needed via ujust)

**Use Cases:**
- KENL3-dev: Ubuntu 24.04 distrobox for development
- Windows VM: For testing (if needed)
- Local AI: Ollama containers for Qwen models

---

## BIOS/UEFI Settings

**Recommended Settings for Linux:**
- ✅ Secure Boot: Can be enabled with Fedora/Bazzite (signed bootloader)
- ✅ UEFI Mode: Required (not legacy BIOS)
- ✅ AMD-V: Enabled (for VMs)
- ✅ IOMMU: Enabled (for PCI passthrough if needed)
- ⚠️ Fast Boot: Disable (can cause issues with dual-boot)

**Check Current Settings:**
- Reboot and enter BIOS/UEFI (usually Del, F2, or F12 during boot)

---

## Performance Optimization Summary

**For Gaming:**
1. CPU: Performance governor (`cpupower frequency-set -g performance`)
2. GPU: Force high performance mode (see KENL2 config)
3. Network: Tailscale disabled, MTU 1492, optimized TCP settings
4. RAM: Ensure dual-channel configuration
5. Storage: NVMe for OS, external for games (acceptable)

**For Development:**
1. CPU: Balanced/schedutil governor
2. Containers: Distrobox with Ubuntu 24.04
3. Storage: External drive Development partition (ext4)

**For AI Workloads:**
1. CPU: Performance mode (Qwen inference)
2. RAM: Monitor usage (16GB may be tight for large models)
3. Storage: External Claude-AI-Data partition (500GB ext4)

---

## Known Hardware Issues

**None Currently Identified**

**If Issues Arise:**
- Check: `dmesg` for kernel messages
- Check: `journalctl -xe` for systemd logs
- Report: Create ATOM-tagged issue with hardware context

---

## References

**Configuration Files:**
- `modules/KENL2-gaming/configs/hardware/amd-ryzen5-5600h-vega-optimal.yaml`
- `modules/KENL2-gaming/configs/hardware/amd-ryzen5-5600h-vega-optimal/README.md`

**Case Studies:**
- `case-studies/RWS-06-COMPLETE-DUAL-BOOT-GAMING-SETUP.md`

**Vendor Documentation:**
- AMD Ryzen 5 5600H: https://www.amd.com/en/products/apu/amd-ryzen-5-5600h
- Vega Architecture: https://www.amd.com/en/technologies/vega-architecture

**Linux Compatibility:**
- Bazzite Hardware Requirements: https://docs.bazzite.gg/
- Fedora Hardware Compatibility: https://fedoraproject.org/wiki/Architectures

---

**ATOM:** ATOM-DOC-20251112-004
**Related:** CURRENT-STATE.md, TESTING-RESULTS.md
**Next Update:** After Bazzite installation and hardware detection
