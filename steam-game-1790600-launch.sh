#!/usr/bin/env bash
# Steam Game ID: 1790600
# SAIF-GAMING-20251205-001
# Launch with optimized settings for AMD Ryzen 5 5600H + Vega

# Game ID
GAME_ID="1790600"

# Steam launch options (optimized for AMD)
STEAM_LAUNCH_OPTIONS=""
STEAM_LAUNCH_OPTIONS="${STEAM_LAUNCH_OPTIONS} RADV_PERFTEST=gpl,nggc,sam"
STEAM_LAUNCH_OPTIONS="${STEAM_LAUNCH_OPTIONS} AMD_VULKAN_ICD=RADV"
STEAM_LAUNCH_OPTIONS="${STEAM_LAUNCH_OPTIONS} PROTON_ENABLE_NVAPI=0"
STEAM_LAUNCH_OPTIONS="${STEAM_LAUNCH_OPTIONS} PROTON_HIDE_NVIDIA_GPU=1"
STEAM_LAUNCH_OPTIONS="${STEAM_LAUNCH_OPTIONS} mangohud"

# Full launch command for Steam
LAUNCH_CMD="steam -applaunch ${GAME_ID}"

echo "=== Steam Game Launch: ${GAME_ID} ==="
echo "Launch command: ${LAUNCH_CMD}"
echo "Environment:"
echo "  RADV_PERFTEST=gpl,nggc,sam (AMD optimizations)"
echo "  AMD_VULKAN_ICD=RADV (force RADV driver)"
echo "  MangoHud enabled (FPS overlay)"
echo ""
echo "Launching in separate window..."
echo ""

# Launch in background with nohup (separate process)
nohup env ${STEAM_LAUNCH_OPTIONS} ${LAUNCH_CMD} > /tmp/steam-${GAME_ID}.log 2>&1 &

STEAM_PID=$!
echo "Steam launched with PID: ${STEAM_PID}"
echo "Log file: /tmp/steam-${GAME_ID}.log"
echo ""
echo "ATOM-GAMING-20251205-001: Steam game ${GAME_ID} launched"
