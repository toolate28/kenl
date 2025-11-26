# GitHub Copilot Instructions: KENL2 Gaming

Module for gaming configurations, Play Cards, and Proton optimization.

## Context

You are assisting with gaming configuration on Linux (Bazzite/Fedora Atomic) using Proton/Wine.

## Primary Tasks

1. **Generate Play Cards** - Document game configurations as YAML
2. **Research Compatibility** - Check ProtonDB for game compatibility
3. **Optimize Performance** - Suggest launch options and settings
4. **Troubleshoot Issues** - Debug anti-cheat, performance, crashes

## Play Card Structure

```yaml
---
title: "Game Title - Hardware Description"
game: game-slug-lowercase
category: fps | rpg | strategy | racing | etc
compatibility: platinum | gold | silver | bronze | borked

hardware:
  cpu: "AMD Ryzen 5 5600H"
  gpu: "AMD Radeon Vega Graphics"
  ram: "16GB DDR4"
  os: "Bazzite KDE"

performance:
  resolution: "1920x1080"
  settings: "High"
  avg_fps: 60
  min_fps: 45
  max_fps: 75
  frametime_99th: "16.7ms"

compatibility:
  proton: "GE-Proton9-20"
  launch_options: "PROTON_USE_WINED3D=1 %command%"
  anti_cheat: "EAC - Working"

issues:
  - "Occasional stuttering in multiplayer"
  - "Intro videos crash (skip with launch option)"

workarounds:
  - "Add -skipIntro to launch options"
  - "Disable in-game overlay for stability"

benchmarks:
  date: "2025-11-16"
  method: "Built-in benchmark + 30min gameplay"
  notes: "Tested on Exodus map, 64 players"

atom_tag: ATOM-PLAYCARD-20251116-001
created_by: username
verified: true
---

# Additional Notes

## Installation
Standard Steam install, no special steps required.

## Performance Tips
- Use GameMode: `gamemoderun %command%`
- Enable MangoHud: `mangohud %command%`
- Combined: `gamemoderun mangohud %command%`

## Known Issues
None at this time.
```

## Common Launch Options

```bash
# Game Mode (CPU performance boost)
gamemoderun %command%

# MangoHud (FPS overlay)
mangohud %command%

# Both
gamemoderun mangohud %command%

# Proton fixes
PROTON_USE_WINED3D=1 %command%  # Use WineD3D instead of DXVK
PROTON_NO_ESYNC=1 %command%     # Disable esync
PROTON_NO_FSYNC=1 %command%     # Disable fsync
DXVK_ASYNC=1 %command%          # Async shader compilation

# Skip intro videos
-skipIntro -novid %command%

# Fullscreen optimizations
MANGOHUD_CONFIG=fps_only=1 gamemoderun %command%
```

## ProtonDB Research Pattern

When user asks "Can I run Game X?":

1. Research on ProtonDB
2. Check anti-cheat status (areweanticheatyet.com)
3. Find optimal Proton version
4. Suggest launch options
5. Generate Play Card template

Example response:
```
Based on ProtonDB reports:
- Status: Gold (mostly works)
- Recommended Proton: GE-Proton9-20
- Anti-cheat: EAC supported on Linux
- Known issues: Intro crashes (skip with -novid)
- Launch options: gamemoderun mangohud -novid %command%

I can generate a Play Card template for your hardware if you'd like.
```

## ATOM Tags for Gaming

```bash
# ATOM-GAMING-20251116-001: Configured BF6 Play Card
# Intent: Document working config for AMD Ryzen + Vega setup
# Evidence: 45 FPS average, no crashes in 2hr session

# ATOM-PLAYCARD-20251116-002: Updated Proton version
# Intent: Fix shader compilation crashes
# Evidence: GE-Proton9-20 resolves issue (0 crashes vs 3/hour)

# ATOM-RESEARCH-20251116-003: Checked ProtonDB for Game X
# Intent: Verify compatibility before purchase
# Evidence: Gold rating, EAC supported, no blockers
```

## When to Ask for More Info

- "What's your hardware?" (CPU, GPU, RAM)
- "What issue are you experiencing?" (crashes, performance, anti-cheat)
- "What have you tried already?" (avoid redundant suggestions)
- "Which Proton version are you using?" (steam properties → compatibility)

## Error Patterns

### Game Won't Launch
1. Check Proton version (try GE-Proton)
2. Verify anti-cheat status
3. Check Steam logs: `~/.steam/steam/logs/`
4. Try safe launch options: `PROTON_LOG=1 %command%`

### Low Performance
1. Verify GameMode enabled
2. Check GPU driver version
3. Test different Proton versions
4. Disable compositor (KDE: Alt+Shift+F12)
5. Check thermal throttling

### Multiplayer Issues
1. Verify anti-cheat compatibility
2. Check firewall/router settings
3. Test without VPN
4. Verify Steam overlay enabled

## Best Practices

1. **Always include hardware specs** in Play Cards
2. **Benchmark consistently** (same map/settings)
3. **Document workarounds** for known issues
4. **Verify anti-cheat** before recommending
5. **Share Play Cards** via KENL6 (encrypted if sensitive)

## Related Modules

- **KENL0**: System optimization (CPU governor)
- **KENL4**: Performance monitoring (metrics)
- **KENL6**: Play Card sharing (community)
- **KENL9**: Game library management (storage)
