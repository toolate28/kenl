# RWS-04: rpm-ostree Rebase to Latest Release

```
⚙️  modules/KENL0 user@bazzite:~$ atom RESEARCH "Show me latest Bazzite releases I can rebase to"

════════════════════════════════════════════════════════════
  ATOM+SAGE: Bazzite Release Research
  ATOM Tag: ATOM-RESEARCH-20251109-028
════════════════════════════════════════════════════════════

Intent: Discover available Bazzite versions for rebasing
Current: Bazzite 40 (Fedora 40 base)

[1/3] Querying Bazzite release channels...

  🔍 Available Bazzite images on ghcr.io/ublue-os:

  ┌─────────────────────────────────────────────────────────┐
  │ Channel    │ Version │ Base    │ Updated   │ Notes      │
  ├─────────────────────────────────────────────────────────┤
  │ stable     │ 40      │ F40     │ 6 days    │ Current ✅ │
  │ stable     │ 41      │ F41     │ 2 days    │ NEW! 🆕    │
  │ testing    │ 41      │ F41     │ 1 day     │ Beta       │
  │ unstable   │ rawhide │ F42     │ 5 hours   │ Bleeding   │
  │ deck       │ 40      │ F40+SD  │ 6 days    │ Steam Deck │
  │ deck       │ 41      │ F41+SD  │ 2 days    │ Deck NEW   │
  │ nvidia     │ 40      │ F40+NV  │ 6 days    │ NVIDIA opt │
  │ nvidia     │ 41      │ F41+NV  │ 2 days    │ NVIDIA NEW │
  └─────────────────────────────────────────────────────────┘

  Your current image:
  ostree-image-signed:docker://ghcr.io/ublue-os/bazzite:40

  Detected hardware: NVIDIA RTX 3080
  💡 Recommended: bazzite-nvidia:41 (optimized for your GPU)

[2/3] Comparing Bazzite 40 vs 41...

  ┌─────────────────────────────────────────────────────────┐
  │ Feature              │ Bazzite 40  │ Bazzite 41         │
  ├─────────────────────────────────────────────────────────┤
  │ Fedora base          │ 40          │ 41 🆕               │
  │ Kernel               │ 6.11.3      │ 6.12.1 🆕           │
  │ Mesa (graphics)      │ 24.2.4      │ 24.3.0 🆕           │
  │ NVIDIA driver        │ 565.57.01   │ 570.86.10 🆕        │
  │ Proton GE            │ 9-15        │ 9-18 🆕             │
  │ Gamescope            │ 3.14.24     │ 3.15.2 🆕           │
  │ MangoHud             │ 0.7.2       │ 0.7.3 🆕            │
  │ Wayland              │ 1.23        │ 1.24 🆕             │
  │ Pipewire             │ 1.2.5       │ 1.2.6 🆕            │
  └─────────────────────────────────────────────────────────┘

  ✨ New in Bazzite 41:
  • HDR gaming support (Gamescope 3.15+)
  • Better NVIDIA explicit sync (kernel 6.12+)
  • Mesa Vulkan improvements (5-10% FPS boost)
  • Proton GE 9-18 (latest game fixes)
  • KDE Plasma 6.2 (if using KDE variant)

  ⚠️  Known issues in Bazzite 41:
  • Wayland HDR requires manual config (temporary)
  • Some RGB control apps may break (OpenRGB)

  🎮 Gaming impact:
  • Expect 5-10% better FPS in most games
  • HDR works in supported games (Cyberpunk 2077, Forza)
  • Better frame pacing with explicit sync

[3/3] Checking rebase safety...

  ✅ Your system is clean (no manual modifications)
  ✅ All flatpaks compatible with F41
  ✅ No layered packages that would break
  ✅ rpm-ostree upgrade --check: No pending updates

  Risk assessment: 🟢 LOW (standard upgrade path)

════════════════════════════════════════════════════════════

Research complete!

Recommended rebase: bazzite-nvidia:41
Reason: Latest gaming features + NVIDIA optimizations

Proceed with rebase? [Y/n]: Y

⚙️  modules/KENL0 user@bazzite:~$ atom SYSTEM "Rebase to Bazzite 41 NVIDIA - CTFWI: Verify compatibility and create rollback point"

════════════════════════════════════════════════════════════
  ATOM+SAGE: Bazzite Rebase Workflow
  ATOM Tag: ATOM-SYSTEM-20251109-029
════════════════════════════════════════════════════════════

Target: bazzite-nvidia:41
Source: bazzite:40 (current)
Type: Major version upgrade (F40 → F41)

[CTFWI Pre-Flight Checks]

1/7 Verifying current system health...

  rpm-ostree status:
  State: idle
  Deployments:
  ● bazzite:40
    Version: 40.20241103.0 (2024-11-03)
    Commit: a3f9b2c1d8e...

  ✅ No pending deployments
  ✅ System is healthy
  ✅ Last boot successful

2/7 Checking layered packages compatibility...

  Layered packages (installed via rpm-ostree install):
  • gnupg2 (GPG for modules/KENL8)
  • distrobox (containers for modules/KENL3)

  Testing against F41 repository...
  ✅ gnupg2: Available in F41 (v2.4.6)
  ✅ distrobox: Available in F41 (v1.7.3.1)

  All layered packages compatible!

3/7 Checking Flatpak compatibility...

  Installed Flatpaks: 47 applications

  Testing critical gaming flatpaks...
  ✅ com.valvesoftware.Steam: Compatible
  ✅ org.freedesktop.Platform.VulkanLayer.MangoHud: Compatible
  ✅ net.davidotek.pupgui2: Compatible (ProtonUp-Qt)
  ✅ com.discordapp.Discord: Compatible

  All flatpaks compatible with F41!

4/7 Checking disk space...

  Current deployment size: 8.2 GB
  New deployment size: 8.7 GB (estimated)
  Available space: 127 GB

  ✅ Sufficient space (need 15 GB, have 127 GB)

5/7 Creating rollback points...

  📸 modules/KENL10 Snapshot: "before-f41-rebase"
  ✅ Captured: ATOM trail (341 entries)
  ✅ Captured: Play Cards (8 cards)
  ✅ Captured: System state
  ✅ Size: 198 MB

  🔄 rpm-ostree rollback point:
  ✅ Current deployment will be kept as rollback target
  ✅ Can rollback with: rpm-ostree rollback

6/7 Downloading new Bazzite 41 image...

  Image: ostree-image-signed:docker://ghcr.io/ublue-os/bazzite-nvidia:41

  Pulling layers...
  [████████████████████████████████████          ] 85%

  Downloaded: 3.2 GB / 3.8 GB
  Speed: 89 MB/s
  ETA: 00:07

  [████████████████████████████████████████████] 100%

  ✅ Image downloaded: 3.8 GB
  ✅ Verifying GPG signature... Valid!

  New deployment details:
  • Version: 41.20241107.0 (2024-11-07)
  • Commit: e7d4a8f2b1c...
  • Packages: 2,847 (138 new, 42 updated)

7/7 Staging rebase...

  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/ublue-os/bazzite-nvidia:41

  Creating new deployment...
  [████████████████████████████████████] 100%

  Deployment complete!

  ════════════════════════════════════════════════════════════

  New deployment staged:

  Deployments:
  ○ bazzite-nvidia:41                              ← NEW (staged)
    Version: 41.20241107.0 (2024-11-07)
    Commit: e7d4a8f2b1c...

  ● bazzite:40                                     ← CURRENT (rollback)
    Version: 40.20241103.0 (2024-11-03)
    Commit: a3f9b2c1d8e...

  ════════════════════════════════════════════════════════════

  ✅ Rebase staged successfully!

  On next boot:
  • bazzite-nvidia:41 will be active
  • bazzite:40 will be available for rollback

  CTFWI Post-Boot Checklist:
  ☑ Test graphics (run a game)
  ☑ Test NVIDIA driver (nvidia-smi)
  ☑ Test Wayland session
  ☑ Check Steam/Proton
  ☑ Verify MangoHud overlay

  If any issues:
  1. Select "bazzite:40" in GRUB menu (rollback)
  2. Or run: rpm-ostree rollback && reboot

════════════════════════════════════════════════════════════

Ready to reboot to Bazzite 41? [Y/n]: Y

Logging to ATOM trail...
✅ ATOM-SYSTEM-20251109-029

Rebooting in 10 seconds... (Ctrl+C to cancel)

⚙️  modules/KENL0 user@bazzite:~$

[System reboots → GRUB shows both deployments]

════════════════════════════════════════════════════════════
                        GNU GRUB
════════════════════════════════════════════════════════════

  Bazzite 41.20241107.0 (6.12.1-200.fc41.x86_64)         [NEW]
  Bazzite 40.20241103.0 (6.11.3-200.fc40.x86_64)         [ROLLBACK]
  UEFI Firmware Settings

  Use ↑ and ↓ to change selection. Press Enter to boot.
  Booting in 5 seconds...

[User presses Enter → Boots into Bazzite 41]

[Login screen → User logs in]

⚙️  modules/KENL0 user@bazzite:~$ rpm-ostree status

State: idle
Deployments:
● bazzite-nvidia:41                              ← BOOTED! ✅
  Version: 41.20241107.0 (2024-11-07)
  Commit: e7d4a8f2b1c...

  bazzite:40
  Version: 40.20241103.0 (2024-11-03)
  Commit: a3f9b2c1d8e...

⚙️  modules/KENL0 user@bazzite:~$ uname -r

6.12.1-200.fc41.x86_64                           ← New kernel!

⚙️  modules/KENL0 user@bazzite:~$ nvidia-smi

+-------------------------------------------------------------------------+
| NVIDIA-SMI 570.86.10    Driver Version: 570.86.10    CUDA Version: 12.7|
+-------------------------------------------------------------------------+
| GPU  Name                 TCC/WDDM | Bus-Id        Disp.A | Volatile   |
| Fan  Temp   Perf          Pwr:Usage/Cap |         Memory-Usage | GPU-Util|
+=========================================================================+
|   0  NVIDIA GeForce RTX 3080   Off | 00000000:01:00.0  On |        N/A |
| 30%   42C    P8              25W / 370W |    628MiB / 10240MiB |      2% |
+-------------------------------------------------------------------------+

✅ NVIDIA driver loaded successfully!             ← Working!

⚙️  modules/KENL0 user@bazzite:~$ atom VERIFY "Bazzite 41 post-boot verification"

════════════════════════════════════════════════════════════
  ATOM+SAGE: Post-Rebase Verification
  ATOM Tag: ATOM-VERIFY-20251109-030
════════════════════════════════════════════════════════════

[1/6] Verifying system boot...
  ✅ Booted into: bazzite-nvidia:41
  ✅ Kernel: 6.12.1-200.fc41
  ✅ Boot time: 11 seconds (normal)
  ✅ All systemd services started

[2/6] Verifying graphics stack...
  ✅ NVIDIA driver: 570.86.10 (loaded)
  ✅ Mesa: 24.3.0 (updated from 24.2.4)
  ✅ Wayland: Active
  ✅ Display server: Running

[3/6] Verifying gaming components...
  ✅ Steam: Flatpak running
  ✅ Proton GE: 9-18 (updated from 9-15)
  ✅ Gamescope: 3.15.2 (supports HDR now!)
  ✅ MangoHud: 0.7.3
  ✅ GameMode: Active

[4/6] Testing NVIDIA explicit sync (new in 6.12 kernel)...
  ✅ Explicit sync: Enabled
  💡 This fixes tearing in Wayland games!

[5/6] Verifying flatpaks...
  Testing critical flatpaks...
  ✅ Steam launched successfully
  ✅ Discord launched
  ✅ All 47 flatpaks operational

[6/6] Performance test (quick)...
  Running glxgears for 10 seconds...

  FPS: 8,247 frames in 10.0 seconds = 824.7 FPS    ← Baseline
  Previous (Bazzite 40): 783.2 FPS
  Improvement: +5.3% FPS 🚀

════════════════════════════════════════════════════════════

✅ Bazzite 41 verification complete!

Summary:
• Boot: Successful ✅
• Graphics: NVIDIA working perfectly ✅
• Gaming: All components operational ✅
• Performance: +5.3% FPS improvement ✅
• Explicit sync: Enabled (better Wayland gaming) ✅
• HDR support: Available (Gamescope 3.15+) ✅

No issues detected. Rebase successful!

CTFWI Result: 🟢 ALL CHECKS PASSED

Rollback available for 7 days:
  rpm-ostree rollback && reboot

After 7 days of stability, old deployment auto-removed.

ATOM Trail: Complete rebase history logged
  ~/.config/atom-sage/trail/ATOM-SYSTEM-20251109-029.log

════════════════════════════════════════════════════════════

⚙️  modules/KENL0 user@bazzite:~$ # Let's test HDR gaming!

⚙️  modules/KENL0 user@bazzite:~$ gamescope --hdr-enabled --fullscreen -- steam steam://rungameid/1091500

[Cyberpunk 2077 launches with HDR enabled]

🎮 HDR working! Colors are 🔥

⚙️  modules/KENL0 user@bazzite:~$ atom STATUS "Bazzite 41 rebase complete and verified - HDR gaming working!"

✅ ATOM-STATUS-20251109-031

⚙️  modules/KENL0 user@bazzite:~$
```

## Key Features Demonstrated:

1. **Release Discovery**: Shows all available Bazzite channels
2. **Version Comparison**: Detailed F40 vs F41 comparison
3. **Hardware Detection**: Recommends NVIDIA variant
4. **Compatibility Checks**: Layered packages, flatpaks, disk space
5. **Automatic Rollback**: Keeps previous deployment for 7 days
6. **Post-Boot Verification**: Comprehensive testing
7. **Performance Benchmarking**: Measures improvement (+5.3% FPS)
8. **Feature Detection**: Explicit sync, HDR support

## Safety Features:

- modules/KENL10 snapshot before rebase
- rpm-ostree keeps previous deployment
- GRUB allows easy rollback selection
- Comprehensive post-boot testing
- 7-day rollback window before cleanup
- Complete ATOM trail audit
