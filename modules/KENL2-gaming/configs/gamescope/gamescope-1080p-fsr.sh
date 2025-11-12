#!/usr/bin/env bash
# GameScope wrapper for AMD Ryzen 5 5600H + Vega
# Optimized for 1080p gaming with FSR upscaling
# ATOM: ATOM-HW-20251110-001

# Usage:
# For demanding games (render 720p, upscale to 1080p):
#   gamescope-1080p-fsr.sh -u %command%
#
# For lighter games (native 1080p):
#   gamescope-1080p-fsr.sh -n %command%
#
# Custom resolution:
#   gamescope-1080p-fsr.sh -w 1280 -h 720 %command%

set -euo pipefail

# Default configuration
RENDER_WIDTH=1280
RENDER_HEIGHT=720
OUTPUT_WIDTH=1920
OUTPUT_HEIGHT=1080
REFRESH_RATE=60
USE_FSR=1
FULLSCREEN=1
BORDERLESS=0
VSYNC=0

# Parse arguments
NATIVE_MODE=0
while getopts "unw:h:r:bvs" opt; do
  case $opt in
    u)  # Upscaling mode (720p->1080p FSR)
      RENDER_WIDTH=1280
      RENDER_HEIGHT=720
      USE_FSR=1
      ;;
    n)  # Native mode (1080p no upscaling)
      RENDER_WIDTH=1920
      RENDER_HEIGHT=1080
      USE_FSR=0
      NATIVE_MODE=1
      ;;
    w)  # Custom render width
      RENDER_WIDTH=$OPTARG
      ;;
    h)  # Custom render height
      RENDER_HEIGHT=$OPTARG
      ;;
    r)  # Refresh rate
      REFRESH_RATE=$OPTARG
      ;;
    b)  # Borderless windowed
      BORDERLESS=1
      FULLSCREEN=0
      ;;
    v)  # Enable vsync
      VSYNC=1
      ;;
    s)  # Sharp upscaling (FSR sharpness = 5)
      SHARPNESS=5
      ;;
    \?)
      echo "Usage: $0 [-u|-n] [-w width] [-h height] [-r rate] [-b] [-v] [-s] -- game_command"
      echo "  -u: Upscaling mode (720p FSR, default)"
      echo "  -n: Native mode (1080p no FSR)"
      echo "  -w: Render width (default: 1280 for upscale, 1920 for native)"
      echo "  -h: Render height (default: 720 for upscale, 1080 for native)"
      echo "  -r: Refresh rate (default: 60)"
      echo "  -b: Borderless windowed mode"
      echo "  -v: Enable vsync"
      echo "  -s: Sharp upscaling (FSR sharpness = 5)"
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

# Build GameScope command
GAMESCOPE_CMD="gamescope"

# Resolution
if [ "$NATIVE_MODE" -eq 1 ]; then
  # Native mode: same render and output resolution
  GAMESCOPE_CMD+=" -W $OUTPUT_WIDTH -H $OUTPUT_HEIGHT"
else
  # Upscaling mode: different render and output resolution
  GAMESCOPE_CMD+=" -w $RENDER_WIDTH -h $RENDER_HEIGHT -W $OUTPUT_WIDTH -H $OUTPUT_HEIGHT"
fi

# Refresh rate
GAMESCOPE_CMD+=" -r $REFRESH_RATE"

# FSR upscaling
if [ "$USE_FSR" -eq 1 ]; then
  GAMESCOPE_CMD+=" -F fsr"
  # Optional: FSR sharpness (0-20, default=2)
  if [ -n "${SHARPNESS:-}" ]; then
    GAMESCOPE_CMD+=" -S $SHARPNESS"
  fi
fi

# Fullscreen or borderless
if [ "$FULLSCREEN" -eq 1 ]; then
  GAMESCOPE_CMD+=" -f"
elif [ "$BORDERLESS" -eq 1 ]; then
  GAMESCOPE_CMD+=" -b"
fi

# VSync
if [ "$VSYNC" -eq 1 ]; then
  GAMESCOPE_CMD+=" --expose-wayland"
fi

# AMD-specific optimizations
GAMESCOPE_CMD+=" --force-grab-cursor"  # Fix mouse capture
GAMESCOPE_CMD+=" --adaptive-sync"      # Enable FreeSync/VRR if available

# Performance mode
GAMESCOPE_CMD+=" --prefer-output eDP-1"  # Laptop internal display
# For external monitor, use: --prefer-output HDMI-A-1 or DP-1

# Debug options (uncomment if needed)
# GAMESCOPE_CMD+=" --debug-hud"  # Show GameScope debug info
# GAMESCOPE_CMD+=" --stats-path /tmp/gamescope-stats.csv"  # Log stats

# Append game command
GAMESCOPE_CMD+=" -- $@"

# Print command for debugging
echo "Running: $GAMESCOPE_CMD"

# Execute
exec $GAMESCOPE_CMD
