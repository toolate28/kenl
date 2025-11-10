# RWS-05: Halo Infinite Gaming Setup

```
🎮 modules/KENL2 user@bazzite:~$ atom RESEARCH "What do I need to run Halo Infinite on my PC?"

════════════════════════════════════════════════════════════
  ATOM+SAGE: Gaming Research - Halo Infinite
  ATOM Tag: ATOM-RESEARCH-20251109-032
════════════════════════════════════════════════════════════

Intent: Determine optimal setup for Halo Infinite on Bazzite
Game: Halo Infinite (Steam App ID: 1240440)
Platform: PC (Bazzite Linux)

[1/5] Checking ProtonDB compatibility...

  🔍 ProtonDB Rating: Gold ⭐⭐⭐ (Playable with tweaks)

  Community reports:
  • 2,847 reports total
  • 73% "Runs perfectly" or "Runs great"
  • 18% "Runs with minor issues"
  • 9% "Doesn't run"

  Latest reports (November 2024):
  ✅ "Flawless with Proton GE 9-18, 165 FPS stable"
  ✅ "Multiplayer works, Easy Anti-Cheat functioning"
  ⚠️  "Campaign has stutters on first load (shader compilation)"
  ❌ "Broken with Proton 9.0-3 (Steam default), use GE instead"

[2/5] Analyzing your hardware...

  CPU: AMD Ryzen 7 5800X3D (8C/16T)
  ✅ Exceeds minimum (Ryzen 5 1600)
  ✅ Meets recommended (Ryzen 7 3700X)
  💡 3D V-Cache perfect for gaming!

  GPU: NVIDIA RTX 3080 (10GB VRAM)
  ✅ Exceeds recommended (RTX 2070)
  🎯 Target: 1440p Ultra @ 120+ FPS

  RAM: 32 GB DDR4
  ✅ Exceeds recommended (16 GB)

  Storage: NVMe SSD
  ✅ Fast loading times

  Overall: Hardware is excellent for Halo Infinite! 🚀

[3/5] Determining optimal Proton version...

  Testing compatibility (based on ProtonDB):

  ┌─────────────────────────────────────────────────────────┐
  │ Proton Version  │ Status      │ FPS    │ Issues         │
  ├─────────────────────────────────────────────────────────┤
  │ Steam 9.0-3     │ ❌ Broken   │ N/A    │ Won't launch   │
  │ Steam 8.0-5     │ ⚠️  Poor    │ 60-80  │ Stutters       │
  │ Proton GE 9-15  │ ✅ Good     │ 100+   │ Minor stutter  │
  │ Proton GE 9-18  │ ✅ Perfect  │ 120+   │ None! 🎯       │
  │ Proton Exp      │ ⚠️  Mixed   │ Varies │ Unstable       │
  └─────────────────────────────────────────────────────────┘

  🎯 Recommended: Proton GE 9-18 (latest)

[4/5] Researching required components...

  Essential stack for Halo Infinite:

  1. ✅ Proton GE 9-18
     • Custom Proton with game-specific fixes
     • Installed via ProtonUp-Qt

  2. ✅ GameMode
     • Auto-optimizes CPU governor
     • Already installed on Bazzite

  3. ✅ MangoHud
     • FPS overlay + performance monitoring
     • Already installed on Bazzite

  4. ⚠️  GameScope (Optional)
     • Micro-compositor for better frame pacing
     • Recommended for 1% lows stability
     • Command: gamescope -f -W 2560 -H 1440 -- %command%

  5. ✅ Easy Anti-Cheat Runtime
     • Required for multiplayer
     • Auto-installed by Steam/Proton

  6. ⚠️  Launch Options (Required!)
     • Shader pre-caching
     • Fixes first-run stuttering

[5/5] Generating optimal configuration...

  Recommended Steam launch options:

  PROTON_ENABLE_NVAPI=1 PROTON_HIDE_NVIDIA_GPU=0 DXVK_ASYNC=1 %command%

  Explanation:
  • PROTON_ENABLE_NVAPI=1   - Enables NVIDIA API (better perf)
  • PROTON_HIDE_NVIDIA_GPU=0 - Game sees GPU correctly
  • DXVK_ASYNC=1            - Async shader compilation (less stutter)

  GameScope variant (advanced):
  gamescope -f -W 2560 -H 1440 -r 165 -- env PROTON_ENABLE_NVAPI=1 %command%

════════════════════════════════════════════════════════════

Research complete!

🎯 Optimal setup for Halo Infinite:
  • Proton GE 9-18
  • NVIDIA-specific launch options
  • Optional: GameScope for frame pacing

Would you like me to:
  1. Install Proton GE 9-18
  2. Configure Steam launch options
  3. Create a Play Card for future reference
  4. Download and test the game

Select [1-4 or 'all']: all

════════════════════════════════════════════════════════════
  ATOM+SAGE: Halo Infinite Setup Workflow
  ATOM Tag: ATOM-GAMING-20251109-033
════════════════════════════════════════════════════════════

[Task 1/4] Installing Proton GE 9-18...

  Opening ProtonUp-Qt...

  ┌────────────────────────────────────────────────────────┐
  │ ProtonUp-Qt - Proton Installer                        │
  ├────────────────────────────────────────────────────────┤
  │                                                        │
  │ Available Proton-GE versions:                          │
  │                                                        │
  │ ▸ GE-Proton 9-18 (Latest) - Nov 5, 2024              │
  │   GE-Proton 9-17          - Oct 28, 2024             │
  │   GE-Proton 9-16          - Oct 20, 2024             │
  │                                                        │
  │ [Install]  [Cancel]                                    │
  └────────────────────────────────────────────────────────┘

  Installing GE-Proton 9-18...
  [████████████████████████████████████] 100%

  ✅ Installed to: ~/.steam/steam/compatibilitytools.d/GE-Proton9-18/

  Restarting Steam to detect new Proton version...
  ✅ Steam restarted

[Task 2/4] Configuring Steam launch options...

  Opening Steam Library...
  Searching for Halo Infinite...

  ┌────────────────────────────────────────────────────────┐
  │ Halo Infinite - Properties                            │
  ├────────────────────────────────────────────────────────┤
  │                                                        │
  │ Compatibility:                                         │
  │   ☑ Force the use of a specific Steam Play tool       │
  │   [GE-Proton 9-18 ▼]                         ← SET!   │
  │                                                        │
  │ Launch Options:                                        │
  │ ┌─────────────────────────────────────────────────┐   │
  │ │ PROTON_ENABLE_NVAPI=1 PROTON_HIDE_NVIDIA_GPU=0 │   │
  │ │ DXVK_ASYNC=1 %command%                          │   │
  │ └─────────────────────────────────────────────────┘   │
  │                                                        │
  │ [Close]                                                │
  └────────────────────────────────────────────────────────┘

  ✅ Proton GE 9-18 selected
  ✅ Launch options configured

[Task 3/4] Creating Play Card for Halo Infinite...

  Generating Play Card with optimal settings...

  📝 Play Card: halo-infinite.yaml

  ✅ Created: ~/kenl/KENL2-gaming/play-cards/halo-infinite.yaml

  Contents:
  ═══════════════════════════════════════════════════════
  game: "Halo Infinite"
  steam_app_id: 1240440
  protondb_rating: "gold"

  proton:
    version: "GE-Proton 9-18"
    source: "ProtonUp-Qt"

  launch_options: |
    PROTON_ENABLE_NVAPI=1 PROTON_HIDE_NVIDIA_GPU=0
    DXVK_ASYNC=1 %command%

  hardware:
    cpu: "AMD Ryzen 7 5800X3D"
    gpu: "NVIDIA RTX 3080"
    ram: "32 GB"

  performance:
    target_resolution: "2560x1440"
    target_fps: 120
    graphics_preset: "Ultra"

  known_issues:
    - issue: "First launch shader compilation stutter"
      fix: "Let game idle in menu for 5 min before playing"
      severity: "minor"

  multiplayer:
    anti_cheat: "Easy Anti-Cheat"
    status: "working"
    tested_date: "2024-11-09"

  notes: |
    - Campaign and multiplayer both work flawlessly
    - Use MangoHud for FPS monitoring
    - GameScope optional for better 1% lows

  compatibility_rating: 9/10
  last_tested: "2024-11-09"
  atom_tag: "ATOM-GAMING-20251109-033"
  ═══════════════════════════════════════════════════════

  ✅ Play Card created and saved

[Task 4/4] Downloading and testing Halo Infinite...

  Checking if game is installed...
  ❌ Not installed (67 GB required)

  Download Halo Infinite now? [Y/n]: Y

  Opening Steam download...

  ┌────────────────────────────────────────────────────────┐
  │ Downloading Halo Infinite                              │
  ├────────────────────────────────────────────────────────┤
  │                                                        │
  │ [████████████████████              ] 62% (41.5 GB)    │
  │                                                        │
  │ Speed: 87 MB/s                                         │
  │ ETA: 00:05:13                                          │
  │                                                        │
  │ [Pause] [Cancel]                                       │
  └────────────────────────────────────────────────────────┘

  [Download completes after ~7 minutes]

  ✅ Halo Infinite downloaded (67.3 GB)

  Installing Easy Anti-Cheat...
  ✅ EAC installed

  Compiling shaders (first launch)...
  ℹ️  This may take 3-5 minutes...
  [████████████████████████████████████] 100%
  ✅ Shaders compiled

  Launching Halo Infinite with MangoHud overlay...

════════════════════════════════════════════════════════════

🎮 modules/KENL2 user@bazzite:~$ mangohud gamemoderun steam steam://rungameid/1240440

[Halo Infinite launches]

┌────────────────────────────────────────────────────────────┐
│ Halo Infinite                                              │
├────────────────────────────────────────────────────────────┤
│                                                            │
│                    [MAIN MENU]                             │
│                                                            │
│              ► Campaign                                    │
│                Multiplayer                                 │
│                Academy                                     │
│                Customize                                   │
│                Store                                       │
│                                                            │
│ ┌────────────────────────────────────────────────────┐    │
│ │ MangoHud                                           │    │
│ │ FPS: 127  FrameTime: 7.9ms  1% Low: 98             │    │
│ │ GPU: RTX 3080 67% 1845MHz 62C 187W                 │    │
│ │ CPU: R7 5800X3D 34% 3.8GHz 48C                     │    │
│ │ RAM: 8.2 GB / 32 GB                                │    │
│ │ VRAM: 3.1 GB / 10 GB                               │    │
│ │ Proton: GE 9-18  GameMode: ON                      │    │
│ └────────────────────────────────────────────────────┘    │
│                                                            │
└────────────────────────────────────────────────────────────┘

🎮 It's working! 127 FPS in menu!

[User plays campaign for 10 minutes]

┌────────────────────────────────────────────────────────────┐
│ [IN-GAME - The Ring]                                       │
│                                                            │
│ ┌────────────────────────────────────────────────────┐    │
│ │ MangoHud                                           │    │
│ │ FPS: 118  FrameTime: 8.5ms  1% Low: 94    ← Great! │    │
│ │ GPU: RTX 3080 94% 1935MHz 68C 312W                 │    │
│ │ CPU: R7 5800X3D 67% 4.2GHz 61C                     │    │
│ │ RAM: 14.8 GB / 32 GB                               │    │
│ │ VRAM: 7.2 GB / 10 GB                               │    │
│ │ Proton: GE 9-18  GameMode: ON                      │    │
│ │                                                    │    │
│ │ Settings: Ultra 1440p                              │    │
│ │ No stutters! Smooth gameplay! 🎯                    │    │
│ └────────────────────────────────────────────────────┘    │
└────────────────────────────────────────────────────────────┘

[User exits game]

🎮 modules/KENL2 user@bazzite:~$ atom STATUS "Halo Infinite setup complete - 118 FPS average on Ultra"

════════════════════════════════════════════════════════════
  ATOM+SAGE: Gaming Session Complete
  ATOM Tag: ATOM-STATUS-20251109-034
════════════════════════════════════════════════════════════

✅ Halo Infinite configured and tested!

Performance summary:
• Average FPS: 118 (target: 120) ✅
• 1% Low: 94 FPS (excellent frame pacing) ✅
• Settings: Ultra, 1440p ✅
• Multiplayer: Tested, EAC working ✅

Optimal setup achieved:
✅ Proton GE 9-18
✅ NVIDIA-optimized launch options
✅ GameMode enabled (CPU optimization)
✅ MangoHud overlay (performance monitoring)
✅ Shaders pre-compiled (no stutter)

Play Card created:
  ~/kenl/KENL2-gaming/play-cards/halo-infinite.yaml

Share with friends? [Y/n]: Y

════════════════════════════════════════════════════════════
  modules/KENL6: Sharing Play Card
════════════════════════════════════════════════════════════

Encrypting Play Card via modules/KENL8...
✅ Encrypted: halo-infinite.yaml.gpg

Share via:
  1) Matrix (clan room)
  2) Discord webhook
  3) Generate shareable link

Select [1-3]: 1

Matrix room: !halo-players:matrix.org

Uploading to Matrix...
✅ Shared to Matrix room: !halo-players:matrix.org

Your clan can now replicate your exact setup! 🎮

════════════════════════════════════════════════════════════

🎮 modules/KENL2 user@bazzite:~$ # Let's try multiplayer!

🎮 modules/KENL2 user@bazzite:~$ mangohud gamemoderun steam steam://rungameid/1240440

[Halo Infinite launches → User selects Multiplayer]

┌────────────────────────────────────────────────────────────┐
│ Multiplayer - Big Team Battle                             │
│                                                            │
│ [SLAYER - Fragmentation]                                   │
│                                                            │
│ ┌────────────────────────────────────────────────────┐    │
│ │ MangoHud                                           │    │
│ │ FPS: 142  FrameTime: 7.0ms  1% Low: 108   ← 🔥     │    │
│ │ GPU: RTX 3080 89% 1920MHz 70C 298W                 │    │
│ │ CPU: R7 5800X3D 58% 4.0GHz 59C                     │    │
│ │ RAM: 12.3 GB / 32 GB                               │    │
│ │ VRAM: 6.1 GB / 10 GB                               │    │
│ │ Ping: 23ms  Players: 24/24                         │    │
│ │ EAC: ✅ Connected                                   │    │
│ └────────────────────────────────────────────────────┘    │
│                                                            │
│ Kills: 18  Deaths: 12  K/D: 1.5                           │
│                                                            │
└────────────────────────────────────────────────────────────┘

🎮 Multiplayer working perfectly!
   • 142 FPS (even better than campaign)
   • Easy Anti-Cheat: No issues
   • No lag, no stutters
   • Full crossplay with Windows players

[After gaming session]

🎮 modules/KENL2 user@bazzite:~$ atom GAMING "Halo Infinite session - 2 hours campaign + 1 hour multiplayer - Flawless"

✅ ATOM-GAMING-20251109-035

Session stats:
• Duration: 3 hours
• Average FPS: 125
• Min FPS: 94 (no drops!)
• Max FPS: 152
• Temperature: GPU 70C max (safe)
• No crashes, no bugs, no issues

Play Card validated: halo-infinite.yaml
Rating: 10/10 - Perfect setup! 🏆

🎮 modules/KENL2 user@bazzite:~$
```

## Key Features Demonstrated:

1. **ProtonDB Research**: Automatic compatibility checking
2. **Hardware Analysis**: Determines FPS targets
3. **Proton Selection**: Recommends GE 9-18 (not Steam default)
4. **Component Stack**: Lists all required helpers (GameMode, MangoHud, etc)
5. **Launch Options**: NVIDIA-specific optimizations
6. **Play Card Creation**: Captures working config for sharing
7. **Real-time Performance**: MangoHud overlay shows everything
8. **KENL6 Integration**: Share Play Card with community
9. **Multiplayer Verification**: Tests EAC anti-cheat

## The Complete Stack:

```
Halo Infinite
     ↓
Proton GE 9-18 (compatibility layer)
     ↓
DXVK (DirectX → Vulkan)
     ↓
NVIDIA Driver 570.86.10
     ↓
GameMode (CPU optimization)
     ↓
MangoHud (overlay)
     ↓
Bazzite (immutable OS)
```

## What Makes This Different:

- **Not just "install and hope"** - Research-driven setup
- **Hardware-aware** - Targets YOUR specific GPU/CPU
- **Community knowledge** - ProtonDB integration
- **Reproducible** - Play Card captures exact setup
- **Shareable** - Encrypted sharing via modules/KENL6
- **Auditable** - Complete ATOM trail of setup + session
