# ujust recipe for AMD Ryzen 5 5600H + Vega optimization
# Install to: /etc/just/kenl.just or ~/.config/just/kenl.just
# Then run: ujust optimize-ryzen5-5600h
# ATOM: ATOM-HW-20251110-001

# Full optimization (all steps)
optimize-ryzen5-5600h:
    @echo "🎮 Optimizing AMD Ryzen 5 5600H + Vega for gaming..."
    @echo ""
    just _optimize-kernel-params
    just _optimize-mesa-config
    just _optimize-gaming-config
    just _optimize-performance-services
    just _optimize-mangohud-config
    @echo ""
    @echo "✅ Optimization complete!"
    @echo ""
    @echo "⚠️  REBOOT REQUIRED to apply kernel parameters"
    @echo "   Run: sudo systemctl reboot"
    @echo ""
    @echo "After reboot, verify with: ujust verify-ryzen5-5600h"

# Step 1: Apply kernel parameters
_optimize-kernel-params:
    @echo "📦 Applying kernel parameters..."
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
    @echo "✅ Kernel parameters staged (requires reboot)"

# Step 2: Configure Mesa drivers
_optimize-mesa-config:
    @echo "🎨 Configuring Mesa drivers..."
    sudo mkdir -p /etc/environment.d
    sudo tee /etc/environment.d/50-mesa-amd.conf > /dev/null << 'EOF'
MESA_LOADER_DRIVER_OVERRIDE=radeonsi
MESA_GL_VERSION_OVERRIDE=4.6
MESA_GLSL_VERSION_OVERRIDE=460
RADV_PERFTEST=gpl,nggc,sam
AMD_VULKAN_ICD=RADV
RADV_DEBUG=0
mesa_glthread=true
vblank_mode=0
EOF
    @echo "✅ Mesa configuration created"

# Step 3: Configure gaming environment
_optimize-gaming-config:
    @echo "🎮 Configuring gaming environment..."
    mkdir -p ~/.config/environment.d
    tee ~/.config/environment.d/gaming.conf > /dev/null << 'EOF'
MANGOHUD=1
PROTON_HIDE_NVIDIA_GPU=1
PROTON_ENABLE_NVAPI=0
DXVK_HUD=0
DXVK_STATE_CACHE_PATH=$HOME/.cache/dxvk
DXVK_LOG_LEVEL=none
VKD3D_CONFIG=dxr
VKD3D_SHADER_CACHE_PATH=$HOME/.cache/vkd3d
WINE_CPU_TOPOLOGY=6:6
SDL_VIDEODRIVER=wayland
QT_QPA_PLATFORM=wayland
EOF
    @echo "✅ Gaming environment configured"

# Step 4: Create and enable performance services
_optimize-performance-services:
    @echo "⚡ Creating performance services..."
    sudo tee /etc/systemd/system/cpu-performance.service > /dev/null << 'EOF'
[Unit]
Description=Set CPU governor to performance for gaming
After=multi-user.target
ConditionPathExists=/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

[Service]
Type=oneshot
ExecStart=/usr/bin/bash -c 'echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor'
ExecStartPost=/usr/bin/bash -c 'if [ -f /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference ]; then echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; fi'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
    sudo tee /etc/systemd/system/amd-gpu-performance.service > /dev/null << 'EOF'
[Unit]
Description=Set AMD GPU to performance mode for gaming
After=multi-user.target
ConditionPathExists=/sys/class/drm/card0/device/power_dpm_force_performance_level

[Service]
Type=oneshot
ExecStart=/usr/bin/bash -c 'echo high > /sys/class/drm/card0/device/power_dpm_force_performance_level'
ExecStartPost=/usr/bin/bash -c 'if [ -f /sys/class/drm/card0/device/pp_power_profile_mode ]; then echo 1 > /sys/class/drm/card0/device/pp_power_profile_mode; fi'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
    sudo systemctl daemon-reload
    sudo systemctl enable cpu-performance.service amd-gpu-performance.service
    @echo "✅ Performance services created and enabled"
    @echo "   (will start after reboot, or run: sudo systemctl start cpu-performance.service amd-gpu-performance.service)"

# Step 5: Configure MangoHud
_optimize-mangohud-config:
    @echo "📊 Configuring MangoHud..."
    mkdir -p ~/.config/MangoHud
    tee ~/.config/MangoHud/MangoHud.conf > /dev/null << 'EOF'
fps
frametime=1
frame_timing=1
gpu_stats
gpu_temp
gpu_core_clock
gpu_mem_clock
gpu_power
cpu_stats
cpu_temp
cpu_power
cpu_mhz
ram
vram
wine
vulkan_driver
engine_version
gpu_name
font_size=24
position=top-left
horizontal
background_alpha=0.5
background_color=020202
text_color=FFFFFF
toggle_hud=Shift_R+F12
toggle_logging=Shift_L+F2
throttling_status
round_corners=5
EOF
    @echo "✅ MangoHud configured"

# Verification
verify-ryzen5-5600h:
    @echo "🔍 Verifying AMD Ryzen 5 5600H + Vega optimization..."
    @echo ""
    @echo "=== Kernel Parameters ==="
    @cat /proc/cmdline | grep -o 'amdgpu\.[^ ]*' || echo "❌ amdgpu parameters not found"
    @cat /proc/cmdline | grep -o 'amd_pstate[^ ]*' || echo "❌ amd_pstate not found"
    @cat /proc/cmdline | grep -o 'vm.max_map_count[^ ]*' || echo "❌ vm.max_map_count not found"
    @echo ""
    @echo "=== GPU Driver ==="
    @lspci -k | grep -A 3 VGA | grep "Kernel driver in use" || echo "❌ GPU driver not detected"
    @echo ""
    @echo "=== CPU Governor ==="
    @cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor || echo "❌ CPU governor not found"
    @echo ""
    @echo "=== GPU Performance Level ==="
    @cat /sys/class/drm/card0/device/power_dpm_force_performance_level 2>/dev/null || echo "❌ GPU performance level not accessible"
    @echo ""
    @echo "=== Mesa Driver ==="
    @glxinfo | grep "OpenGL renderer" | head -1 || echo "❌ OpenGL info not available (install mesa-demos)"
    @echo ""
    @echo "=== Vulkan Driver ==="
    @vulkaninfo --summary 2>/dev/null | grep deviceName | head -1 || echo "❌ Vulkan info not available"
    @echo ""
    @echo "=== Services ==="
    @systemctl is-active cpu-performance.service || echo "❌ cpu-performance.service not active"
    @systemctl is-active amd-gpu-performance.service || echo "❌ amd-gpu-performance.service not active"
    @echo ""
    @echo "✅ Verification complete"

# Rollback all optimizations
rollback-ryzen5-5600h:
    @echo "⏪ Rolling back AMD Ryzen 5 5600H + Vega optimizations..."
    @echo ""
    @echo "Removing kernel parameters..."
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
      --delete="split_lock_detect=off" || true
    @echo "Disabling performance services..."
    sudo systemctl disable cpu-performance.service amd-gpu-performance.service || true
    sudo systemctl stop cpu-performance.service amd-gpu-performance.service || true
    @echo "Removing configuration files..."
    sudo rm -f /etc/environment.d/50-mesa-amd.conf || true
    sudo rm -f /etc/systemd/system/cpu-performance.service || true
    sudo rm -f /etc/systemd/system/amd-gpu-performance.service || true
    rm -f ~/.config/environment.d/gaming.conf || true
    @echo ""
    @echo "✅ Rollback complete"
    @echo "⚠️  REBOOT REQUIRED: sudo systemctl reboot"

# Show current system status
status-ryzen5-5600h:
    @echo "📊 AMD Ryzen 5 5600H + Vega Status"
    @echo ""
    @echo "=== CPU ==="
    @echo -n "Model: "
    @lscpu | grep "Model name" | sed 's/Model name: *//'
    @echo -n "Governor: "
    @cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "N/A"
    @echo -n "Current MHz: "
    @grep "cpu MHz" /proc/cpuinfo | head -1 | awk '{print $4}' || echo "N/A"
    @echo -n "Max MHz: "
    @lscpu | grep "CPU max MHz" | awk '{print $4}' || echo "N/A"
    @echo ""
    @echo "=== GPU ==="
    @lspci | grep VGA
    @echo -n "Driver: "
    @lspci -k | grep -A 3 VGA | grep "Kernel driver in use" | awk '{print $5}' || echo "N/A"
    @echo -n "Performance Level: "
    @cat /sys/class/drm/card0/device/power_dpm_force_performance_level 2>/dev/null || echo "N/A"
    @echo -n "Power Profile: "
    @cat /sys/class/drm/card0/device/pp_power_profile_mode 2>/dev/null | grep "*" | awk '{print $2}' || echo "N/A"
    @echo ""
    @echo "=== Memory ==="
    @free -h | grep "Mem:"
    @echo ""
    @echo "=== Services ==="
    @echo -n "CPU Performance: "
    @systemctl is-active cpu-performance.service 2>/dev/null || echo "inactive"
    @echo -n "GPU Performance: "
    @systemctl is-active amd-gpu-performance.service 2>/dev/null || echo "inactive"

# Quick performance check (run before/after gaming session)
perf-check:
    @echo "⚡ Quick Performance Check"
    @echo ""
    @echo -n "CPU Governor: "
    @cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    @echo -n "GPU Performance: "
    @cat /sys/class/drm/card0/device/power_dpm_force_performance_level 2>/dev/null || echo "N/A"
    @echo -n "CPU Temp: "
    @sensors 2>/dev/null | grep "Tctl" | awk '{print $2}' || echo "N/A (install lm_sensors)"
    @echo -n "CPU MHz (max): "
    @grep "cpu MHz" /proc/cpuinfo | awk '{print $4}' | sort -n | tail -1
    @echo ""
