---
project: Bazza-DX SAGE Framework
status: active
version: 2025-11-07
classification: OWI-DOC
atom: ATOM-DOC-20251107-020
owi-version: 1.0.0
---

# Battlefield 2042 (BF6) Linux Launch Options Guide

**Purpose:** Comprehensive troubleshooting guide for running Battlefield 2042 on Linux via Proton/Wine, with focus on Bazzite-DX/Fedora Atomic systems.

**Status:** Active testing configurations
**ATOM Tag:** `ATOM-DOC-20251107-020`
**Target Distribution:** Bazzite-DX, Fedora Atomic, immutable Linux systems

---

## ⚠️ CRITICAL: Anti-Cheat Kernel-Level Issues

### Battlefield 2042 (Current Game)
**Status:** ❌ **NOT WORKING** - Easy Anti-Cheat Linux support NOT enabled by EA

**Root Cause:**
- **Easy Anti-Cheat (EAC)** technically supports Linux/Proton (since Sept 2021)
- EA/DICE has **NOT opted-in** to enable Linux support for BF2042
- Game will launch but **kicks players after joining matches** (anti-cheat detection)
- **No workaround exists** - this is a publisher decision, not a technical limitation

**Evidence:**
- EAC Linux support is opt-in via Epic Developer Portal
- Other games (Apex Legends, Halo MCC) enabled it successfully
- BF2042 ProtonDB reports: "Launches but anti-cheat kicks immediately"
- Source: [GitHub Proton Issue #5305](https://github.com/ValveSoftware/Proton/issues/5305)

### Battlefield 6 (Upcoming Game)
**Status:** ❌ **WILL NEVER WORK** - Javelin anti-cheat + Secure Boot requirement

**Root Cause:**
- EA's new **Javelin anti-cheat** operates at kernel-level
- **Requires Secure Boot** to be enabled (Windows only)
- Proton has **no Secure Boot emulation**
- Fundamentally incompatible with Wine/Proton/Linux kernel architecture

**Official Statement:**
- EA Executive VP Vince Zampella confirmed BF6 won't work on Steam Deck/Linux
- Javelin analyzes system at kernel-level in real-time
- Same anti-cheat added to BF4/BF5 in 2024, breaking Linux support

**Impact:**
- Steam Deck: ❌ Incompatible
- Linux (any distro): ❌ Incompatible
- Proton/Wine: ❌ Incompatible
- No technical workaround possible

**Sources:**
- [GamingOnLinux](https://www.gamingonlinux.com/2025/08/battlefield-6-will-be-a-unplayable-on-linux-systems-due-to-the-anti-cheat/)
- [PC Gamer - Secure Boot Requirement](https://www.pcgamer.com/hardware/battlefield-6-requires-secure-boot-to-run/)

---

## Why This Document Still Exists

While BF2042 multiplayer is **not playable** on Linux, this document serves:

1. **Historical Reference** - Documenting what was attempted and why it failed
2. **Single-Player / Offline** - Some modes may work without EAC
3. **Future Hope** - If EA enables EAC Linux support (unlikely but possible)
4. **Educational** - Anti-cheat kernel architecture understanding for other games

**TL;DR:** Don't expect Battlefield games to work on Linux. EA has chosen kernel-level anti-cheat incompatible with Linux.

---

## Table of Contents

1. [⚠️ CRITICAL: Anti-Cheat Kernel-Level Issues](#️-critical-anti-cheat-kernel-level-issues)
2. [Quick Reference](#quick-reference)
3. [GUI Method (Steam Interface)](#gui-method-steam-interface)
4. [Progressive Troubleshooting Ladder](#progressive-troubleshooting-ladder)
5. [Specific Issues & Solutions](#specific-issues--solutions)
6. [Environment Variables Reference](#environment-variables-reference)
7. [Kernel Architecture: Why Anti-Cheat Fails on Linux](#kernel-architecture-why-anti-cheat-fails-on-linux)
8. [Known Issues](#known-issues)

---

## Quick Reference

### Baseline (Working Configuration)
```bash
WINEDLLOVERRIDES="dinput8=n,b" PROTON_LOG=1 DXVK_HUD=fps gamemoderun mangohud -- %command%
```

### Most Common Fixes
```bash
# Anti-cheat compatibility (EAC)
PROTON_USE_WINED3D=1 PROTON_NO_ESYNC=1 PROTON_NO_FSYNC=1 %command%

# Performance optimization
DXVK_ASYNC=1 RADV_PERFTEST=gpl gamemoderun mangohud %command%

# Input issues
SDL_VIDEODRIVER=x11 WINEDLLOVERRIDES="dinput8=n,b;xinput1_3=n,b" %command%
```

---

## GUI Method (Steam Interface)

### Method 1: Steam Properties (Recommended)

1. **Open Steam Library**
2. **Right-click Battlefield 2042**
3. **Select "Properties..."**
4. **Navigate to "Launch Options" field**
5. **Paste one of the configurations below**

### Method 2: Compatibility Settings

1. **Right-click game → Properties**
2. **Compatibility tab → Force the use of a specific Steam Play compatibility tool**
3. **Select:** `Proton Experimental` or `GE-Proton` (latest)
4. **Apply launch options in previous tab**

---

## Progressive Troubleshooting Ladder

Try these in order, testing after each step:

### Level 1: Minimal (Diagnostic)
```bash
PROTON_LOG=1 %command%
```
**Purpose:** Generate log files in `$HOME/steam-*.log` for analysis
**Check:** Does game launch? Check logs for errors.

---

### Level 2: Basic Performance
```bash
PROTON_LOG=1 gamemoderun mangohud %command%
```
**Added:**
- `gamemoderun` - CPU governor optimization
- `mangohud` - Performance overlay (FPS, temps, frametimes)

---

### Level 3: Input Handling
```bash
WINEDLLOVERRIDES="dinput8=n,b" PROTON_LOG=1 gamemoderun mangohud %command%
```
**Added:**
- `dinput8=n,b` - DirectInput override (native then builtin)

---

### Level 4: Extended Input + Graphics
```bash
WINEDLLOVERRIDES="dinput8=n,b;xinput1_3=n,b" DXVK_HUD=fps PROTON_LOG=1 gamemoderun mangohud %command%
```
**Added:**
- `xinput1_3=n,b` - XInput controller support
- `DXVK_HUD=fps` - DXVK internal FPS counter

---

### Level 5: Anti-Cheat Compatibility (EAC)
```bash
PROTON_USE_WINED3D=1 PROTON_NO_ESYNC=1 PROTON_NO_FSYNC=1 WINEDLLOVERRIDES="dinput8=n,b" %command%
```
**Added:**
- `PROTON_USE_WINED3D=1` - Use OpenGL instead of Vulkan (EAC compatibility)
- `PROTON_NO_ESYNC=1` - Disable event synchronization
- `PROTON_NO_FSYNC=1` - Disable file synchronization

**⚠️ Warning:** Performance impact, but may fix EAC kicks.

---

### Level 6: AMD GPU Optimizations
```bash
RADV_PERFTEST=gpl DXVK_ASYNC=1 WINEDLLOVERRIDES="dinput8=n,b" gamemoderun mangohud %command%
```
**Added:**
- `RADV_PERFTEST=gpl` - Enable Graphics Pipeline Library (AMD)
- `DXVK_ASYNC=1` - Asynchronous shader compilation

---

### Level 7: NVIDIA GPU Optimizations
```bash
__GL_SHADER_DISK_CACHE=1 __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1 DXVK_ASYNC=1 WINEDLLOVERRIDES="dinput8=n,b" gamemoderun mangohud %command%
```
**Added:**
- `__GL_SHADER_DISK_CACHE=1` - Enable shader caching
- `__GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1` - Prevent cache cleanup

---

### Level 8: GameScope (Windowed/Fullscreen Issues)
```bash
gamescope -W 2560 -H 1440 -f -r 144 -- gamemoderun mangohud %command%
```
**Added:**
- `gamescope` - Wayland/X11 compositor for games
- `-W/-H` - Window width/height (adjust to your resolution)
- `-f` - Fullscreen
- `-r` - Refresh rate

**Variation (Borderless Windowed):**
```bash
gamescope -W 2560 -H 1440 -b -r 144 -- gamemoderun mangohud %command%
```

---

### Level 9: Maximum Compatibility (Kitchen Sink)
```bash
PROTON_USE_WINED3D=1 PROTON_NO_ESYNC=1 PROTON_NO_FSYNC=1 WINEDLLOVERRIDES="dinput8=n,b;xinput1_3=n,b;bcrypt=n,b" SDL_VIDEODRIVER=x11 PROTON_LOG=1 gamemoderun %command%
```
**Added:**
- `bcrypt=n,b` - Cryptography library override (EAC)
- `SDL_VIDEODRIVER=x11` - Force X11 (Wayland issues)

---

## Specific Issues & Solutions

### Issue: Game Crashes on Launch

**Solution 1: Verify Proton Version**
```bash
# Try Proton Experimental or GE-Proton
# Check ProtonDB: https://www.protondb.com/app/1517290
```

**Solution 2: Clear Shader Cache**
```bash
# Remove existing shader cache
rm -rf ~/.steam/steam/steamapps/shadercache/1517290/
```

**Solution 3: Verify Game Files**
```
Steam → Right-click BF2042 → Properties → Local Files → Verify Integrity
```

---

### Issue: EAC (Easy Anti-Cheat) Kicks

**Solution 1: Wine3D Fallback**
```bash
PROTON_USE_WINED3D=1 PROTON_NO_ESYNC=1 PROTON_NO_FSYNC=1 %command%
```

**Solution 2: Check EAC Linux Support**
```bash
# BF2042 may not officially support EAC on Linux
# Check current status: https://areweanticheatyet.com/
```

**Solution 3: Use Proton-GE**
```bash
# Install ProtonUp-Qt
flatpak install flathub net.davidotek.pupgui2

# Install GE-Proton and select in compatibility settings
```

---

### Issue: Mouse/Keyboard Not Working

**Solution 1: DirectInput Override**
```bash
WINEDLLOVERRIDES="dinput8=n,b" %command%
```

**Solution 2: Force X11**
```bash
SDL_VIDEODRIVER=x11 %command%
```

**Solution 3: Disable Steam Input**
```
Steam → Settings → Controller → Desktop Configuration → Disable Steam Input
```

---

### Issue: Controller Not Detected

**Solution 1: XInput Override**
```bash
WINEDLLOVERRIDES="xinput1_3=n,b;xinput1_4=n,b" %command%
```

**Solution 2: Steam Input Layer**
```
Steam → Game Properties → Controller → Enable Steam Input
```

---

### Issue: Poor Performance / Stuttering

**Solution 1: Async Shader Compilation**
```bash
DXVK_ASYNC=1 %command%
```

**Solution 2: CPU Governor (GameMode)**
```bash
# Check gamemode is installed
systemctl --user status gamemoded

# Use in launch options
gamemoderun %command%
```

**Solution 3: Shader Pre-Caching**
```
Steam → Settings → Shader Pre-Caching → Enable
```

---

### Issue: Audio Crackling

**Solution 1: PulseAudio Latency**
```bash
PULSE_LATENCY_MSEC=60 %command%
```

**Solution 2: PipeWire Configuration**
```bash
# Edit ~/.config/pipewire/pipewire.conf.d/99-custom.conf
default.clock.quantum = 1024
default.clock.min-quantum = 1024
```

---

### Issue: Fullscreen/Window Mode Issues

**Solution 1: Force Borderless Fullscreen**
```bash
# In-game settings: Set to Borderless
# OR use GameScope
gamescope -W 2560 -H 1440 -f -- %command%
```

**Solution 2: Disable Compositor (X11)**
```bash
# For KDE Plasma
qdbus org.kde.KWin /Compositor suspend
```

---

## Environment Variables Reference

### Proton Variables

| Variable | Values | Purpose |
|----------|--------|---------|
| `PROTON_LOG` | `0`, `1` | Enable verbose logging |
| `PROTON_USE_WINED3D` | `0`, `1` | Use OpenGL instead of Vulkan |
| `PROTON_NO_ESYNC` | `0`, `1` | Disable event synchronization |
| `PROTON_NO_FSYNC` | `0`, `1` | Disable file synchronization |
| `PROTON_DUMP_DEBUG_COMMANDS` | `0`, `1` | Log Wine commands |
| `PROTON_FORCE_LARGE_ADDRESS_AWARE` | `0`, `1` | Force LAA flag (32-bit games) |

### DXVK Variables

| Variable | Values | Purpose |
|----------|--------|---------|
| `DXVK_HUD` | `fps`, `devinfo`, `memory` | DXVK overlay |
| `DXVK_ASYNC` | `0`, `1` | Async shader compilation |
| `DXVK_LOG_LEVEL` | `none`, `error`, `warn`, `info`, `debug` | Log level |
| `DXVK_STATE_CACHE_PATH` | `path` | Custom cache location |

### Wine Variables

| Variable | Values | Purpose |
|----------|--------|---------|
| `WINEDLLOVERRIDES` | `dll=n,b` | DLL override (native, builtin) |
| `WINEPREFIX` | `path` | Custom Wine prefix |
| `WINEDEBUG` | `+all`, `-all`, `+relay` | Wine debug channels |

### GPU Variables (AMD)

| Variable | Values | Purpose |
|----------|--------|---------|
| `RADV_PERFTEST` | `gpl`, `nggc` | Performance features |
| `RADV_DEBUG` | `llvm`, `zerovram` | Debug options |
| `AMD_VULKAN_ICD` | `RADV`, `AMDVLK` | Select Vulkan driver |

### GPU Variables (NVIDIA)

| Variable | Values | Purpose |
|----------|--------|---------|
| `__GL_SHADER_DISK_CACHE` | `0`, `1` | Enable shader cache |
| `__GL_SHADER_DISK_CACHE_SKIP_CLEANUP` | `0`, `1` | Keep cache |
| `__GL_THREADED_OPTIMIZATION` | `0`, `1` | Threaded OpenGL |

---

## Known Issues

### BF2042 + EAC on Linux (as of Nov 2025)

**Status:** ⚠️ Partially Working

- **Single Player / Bot Matches:** Generally work
- **Multiplayer:** EAC may kick players on some Proton versions
- **Official Support:** Not guaranteed by EA/DICE

**Workarounds:**
1. Use Proton-GE (community fork with EAC patches)
2. Monitor ProtonDB for latest working configs
3. Check EAC status: https://areweanticheatyet.com/

### Performance vs. Windows

**Expected:** 5-15% lower FPS on Linux
**Causes:**
- Vulkan translation overhead (DXVK)
- EAC compatibility mode overhead
- Driver maturity (especially NVIDIA)

**Mitigation:**
- Use latest Mesa drivers (AMD)
- Use latest NVIDIA proprietary drivers
- Enable async shader compilation
- Use GameMode for CPU optimization

---

## Command Line Testing Workflow

### 1. Test from Terminal (Bypass Steam)

```bash
# Set Steam runtime environment
export STEAM_RUNTIME=/path/to/steam/ubuntu12_32/steam-runtime

# Test with minimal config
cd ~/.steam/steam/steamapps/common/Battlefield\ 2042/
PROTON_LOG=1 ~/.steam/steam/compatibilitytools.d/GE-Proton8-25/proton run ./bf2042.exe
```

### 2. Monitor Logs in Real-Time

```bash
# Terminal 1: Launch game
PROTON_LOG=1 %command%

# Terminal 2: Monitor logs
tail -f ~/steam-*.log
```

### 3. Capture Performance Metrics

```bash
# Install MangoHud CLI
mangohud --help

# Run with log output
MANGOHUD_CONFIG=fps,frametime,cpu_temp,gpu_temp MANGOHUD_OUTPUT=~/bf2042_perf.log mangohud %command%
```

---

## Rollback-Safe Testing (Immutable Systems)

For Bazzite-DX / Fedora Atomic:

### Before Major Changes

```bash
# Create deployment snapshot
sudo ostree admin pin 0

# Note current deployment
rpm-ostree status
```

### After Testing

```bash
# If issues occur, rollback
rpm-ostree rollback
systemctl reboot

# Remove pin when stable
sudo ostree admin pin --unpin <index>
```

---

## ATOM Traceability

**Document:** `BF6_LINUX_LAUNCH_OPTIONS.md`
**ATOM Tag:** `ATOM-DOC-20251107-020`
**Related:**
- `ATOM-SAGE-20251106-019` - SAGE framework launch
- Gaming config methodology

**Testing Status:**
- [ ] Single player verified
- [ ] Multiplayer verified
- [ ] EAC compatibility confirmed
- [ ] Performance benchmarked

---

## Kernel Architecture: Why Anti-Cheat Fails on Linux

### Understanding Kernel-Level Anti-Cheat

**Windows Architecture:**
```
┌─────────────────────────────────────────┐
│  User Space (Ring 3)                    │
│  ├─ Game.exe                            │
│  └─ Anti-cheat client (userspace)      │
├─────────────────────────────────────────┤
│  Kernel Space (Ring 0)                  │
│  ├─ ntoskrnl.exe (Windows kernel)      │
│  ├─ Anti-cheat driver (.sys)           │ ← Direct kernel access
│  └─ Secure Boot verification           │ ← TPM/UEFI integration
└─────────────────────────────────────────┘
```

**Linux + Proton Architecture:**
```
┌─────────────────────────────────────────┐
│  User Space                             │
│  ├─ Wine/Proton (translates Windows)   │
│  ├─ Game.exe (thinks it's on Windows)  │
│  └─ Anti-cheat (sees fake "Windows")   │ ← Sees translation layer
├─────────────────────────────────────────┤
│  Linux Kernel Space                     │
│  ├─ Linux kernel (not NT kernel)       │
│  ├─ No .sys driver support             │ ← Incompatible
│  └─ No Secure Boot emulation           │ ← Missing
└─────────────────────────────────────────┘
```

### The Three Technical Barriers

#### 1. Kernel Driver Incompatibility
**Problem:** Windows anti-cheat uses `.sys` kernel drivers that interact directly with the Windows NT kernel.

**Linux Reality:**
- Linux kernel architecture is fundamentally different
- `.sys` drivers cannot load (requires `.ko` kernel modules)
- Wine/Proton operates in **userspace only** (Ring 3)
- No mechanism to translate kernel-level calls

**Example:** Javelin anti-cheat monitors memory at kernel level:
```c
// Windows (works)
NTSTATUS ReadProcessMemory(HANDLE process, PVOID address, ...)
  └─ Kernel driver has Ring 0 access

// Linux + Wine (fails)
wine_translate(ReadProcessMemory(...))
  └─ Trapped in userspace, no Ring 0 access
```

#### 2. Secure Boot + TPM Verification
**Problem:** BF6's Javelin requires Secure Boot to verify system integrity.

**What Secure Boot Does:**
- UEFI firmware verifies bootloader signature
- Bootloader verifies kernel signature
- Kernel verifies driver signatures
- Creates "chain of trust" from firmware → kernel → drivers

**Why Linux Fails:**
- Proton cannot emulate UEFI/TPM layer
- Anti-cheat detects "unsigned" Wine/Proton components
- No way to present valid Windows boot chain to anti-cheat

#### 3. System Call Translation Overhead
**Problem:** Even user-space anti-cheat can detect Wine/Proton.

**Detection Methods:**
- **Timing attacks:** Wine syscalls are slower (translation overhead)
- **API fingerprinting:** Wine doesn't implement every Windows API perfectly
- **Registry/filesystem checks:** Wine's fake Windows directory structure is detectable

**Example Detection:**
```python
# Anti-cheat check (pseudo-code)
if os.path.exists("C:\\windows\\system32\\wine"):
    ban_player("Wine detected")

if syscall_latency > threshold:
    ban_player("Suspicious syscall timing")
```

### Why EAC "Sort Of" Works

**Easy Anti-Cheat** has a special **userspace-only mode** for Linux:
- Runs entirely in Ring 3 (no kernel driver)
- Uses heuristics instead of kernel monitoring
- Explicitly designed for Proton compatibility

**But it requires developer opt-in:**
```python
# Developer must enable in Epic Dev Portal
enable_linux_support = True  # EA set this to False for BF2042
```

**Why EA/DICE didn't enable it:**
- Policy decision (not technical)
- Concerns about "weaker" anti-cheat (userspace only)
- Smaller Linux player base (<2%)

### Technical Workarounds (That Don't Exist)

#### ❌ "Can't we patch Wine to fake kernel access?"
**No.** Linux kernel security model prevents userspace from:
- Accessing Ring 0 directly
- Loading unsigned kernel modules
- Bypassing memory protection

#### ❌ "Can't we run Windows in VM with passthrough?"
**Maybe**, but:
- Anti-cheat detects VM (CPUID checks)
- VM requires Windows license
- Defeats purpose of Linux gaming

#### ❌ "Can't we reverse-engineer the anti-cheat?"
**Illegal** and:
- Violates DMCA / EUCD
- Violates game EULA
- Results in permanent ban

### The Future: eBPF Anti-Cheat?

**Potential solution** for Linux-native anti-cheat:
```
┌─────────────────────────────────────────┐
│  User Space                             │
│  ├─ Game (native Linux)                 │
│  └─ Anti-cheat client                   │
├─────────────────────────────────────────┤
│  Linux Kernel                           │
│  └─ eBPF programs (sandboxed)          │ ← Safe kernel monitoring
└─────────────────────────────────────────┘
```

**eBPF (Extended Berkeley Packet Filter):**
- Allows sandboxed code in kernel space
- Used by Cilium, Falco for security monitoring
- Could provide anti-cheat with kernel-level visibility
- Without full Ring 0 driver access

**Challenges:**
- Game companies would need to rewrite anti-cheat
- No cross-platform compatibility with Windows
- Smaller Linux market share disincentivizes investment

### Summary: Why Battlefield Can't Work

| Component | Windows (Works) | Linux + Proton (Fails) |
|-----------|----------------|------------------------|
| **Kernel driver** | .sys loads in Ring 0 | No .sys support |
| **Secure Boot** | UEFI verifies chain | No emulation |
| **Memory access** | Direct kernel access | Userspace only |
| **Syscall speed** | Native | Translation overhead |
| **Detection** | Clean Windows APIs | Wine artifacts |

**Bottom line:** Without EA enabling EAC Linux support (for BF2042) or Javelin supporting Linux (impossible for BF6), there is **no technical solution**.

---

## Additional Resources

- **ProtonDB:** https://www.protondb.com/app/1517290
- **Wine User Guide:** https://gitlab.winehq.org/wine/wine/-/wikis/Wine-User's-Guide
- **DXVK GitHub:** https://github.com/doitsujin/dxvk
- **GameMode:** https://github.com/FeralInteractive/gamemode
- **MangoHud:** https://github.com/flightlessmango/MangoHud
- **Are We Anti-Cheat Yet:** https://areweanticheatyet.com/

---

## Contributing

Found a working configuration? Submit via:

1. Fork repository
2. Add to this document
3. Include:
   - Hardware specs (CPU/GPU)
   - Distribution (Bazzite-DX, Fedora, etc.)
   - Proton version
   - Test results (single/multi player)
4. Create PR with ATOM tag

**ATOM Tag Pattern:** `ATOM-TASK-<YYYYMMDD>-<NNN>`

---

**Last Updated:** 2025-11-07
**Maintainer:** Bazza-DX Community
**License:** MIT
