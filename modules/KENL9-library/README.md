# modules/KENL9: Library - Multi-OS Game Library Management

**Version:** 1.0.0
**Target Platform:** Bazzite + Windows Dual-Boot
**Status:** Production Ready
**Focus:** Shared game libraries, save sync, storage optimization

---

## Overview

KENL9 manages your game library across **multiple operating systems** on the same machine. Instead of installing Battlefield 6 twice (100GB on Linux + 100GB on Windows = 200GB), install **once** on a shared NTFS partition and play from both OSes.

**Key capabilities:**
- 🎮 **Shared Steam libraries** (install once, play on Linux + Windows)
- 💾 **Save game synchronization** across dual-boot
- 📦 **Launcher integration** (Steam, EA App, Epic, GOG, Heroic)
- 📊 **Storage optimization** (deduplicate, compress, archive)
- 🔄 **Migration tools** (Windows → Linux, HDD → SSD)
- 🔐 **Cloud save backup** (encrypted via modules/KENL8)

---

## Why modules/KENL9?

### Problem: Dual-Boot Storage Waste

```mermaid
graph TD
    A[Traditional Dual-Boot] --> B[Linux: Elden Ring 60GB]
    A --> C[Windows: Elden Ring 60GB]
    A --> D[Linux: Cyberpunk 100GB]
    A --> E[Windows: Cyberpunk 100GB]

    B --> F[Total: 320GB wasted!]
    C --> F
    D --> F
    E --> F

    G[KENL9 Shared Library] --> H[Shared NTFS: Elden Ring 60GB]
    G --> I[Shared NTFS: Cyberpunk 100GB]

    H --> J[Total: 160GB saved ✅]
    I --> J

    style F fill:#ffe3e3,stroke:#fa5252
    style J fill:#d3f9d8,stroke:#51cf66
```

**Traditional dual-boot:**
- Install every game twice
- 10 games × 2 OSes = 1TB wasted
- Save games don't sync
- Updates download twice

**KENL9 approach:**
- Install once on shared partition
- Both OSes read same files
- Save game sync via cloud/symlinks
- Updates apply to both OSes

---

## Quick Start: Shared Steam Library

### 1. Create Shared Partition

**Recommended layout for 1.8TB external drive:**

```mermaid
pie title "1.8TB External Drive Layout"
    "Games-Universal (NTFS)" : 900
    "Claude-AI-Data (ext4)" : 500
    "Development (ext4)" : 200
    "Windows-Only (NTFS)" : 150
    "Transfer (exFAT)" : 50
```

**Partition table:**

| Partition | Size | Format | Mount | Purpose |
|-----------|------|--------|-------|---------|
| `sdb1` | 900GB | **NTFS** | `/mnt/games-universal` | Shared Steam library |
| `sdb2` | 500GB | ext4 | `/mnt/claude-ai` | Ollama models, ChromaDB |
| `sdb3` | 200GB | ext4 | `/mnt/development` | Distrobox containers |
| `sdb4` | 150GB | NTFS | `/mnt/windows-only` | Anti-cheat games (BF6) |
| `sdb5` | 50GB | exFAT | `/mnt/transfer` | Quick file exchange |

**Why NTFS for shared games?**
- ✅ Windows native read/write
- ✅ Linux via ntfs-3g (included in Bazzite)
- ✅ Supports large files (>4GB)
- ✅ Case-insensitive (game compatibility)

**Why NOT ext4 for shared games?**
- ❌ Windows can't read ext4 natively
- ❌ Requires 3rd-party drivers (unstable)

---

### 2. Partition the Drive

```bash
# Switch to system context
kenl-switch 0

# Run partitioning script
~/kenl/KENL9-library/tools/partition-external.sh /dev/sdb
```

**What changes:**

```mermaid
stateDiagram-v2
    [*] --> DetectDrive: Detect /dev/sdb
    DetectDrive --> ConfirmWipe: ⚠️ WARNING: All data will be erased
    ConfirmWipe --> CreatePartitions: User confirms
    ConfirmWipe --> [*]: User cancels

    CreatePartitions --> FormatNTFS: sdb1, sdb4 (NTFS)
    CreatePartitions --> FormatExt4: sdb2, sdb3 (ext4)
    CreatePartitions --> FormatExFAT: sdb5 (exFAT)

    FormatNTFS --> UpdateFstab
    FormatExt4 --> UpdateFstab
    FormatExFAT --> UpdateFstab

    UpdateFstab --> CreateMountPoints
    CreateMountPoints --> MountAll
    MountAll --> VerifyMounts
    VerifyMounts --> [*]
```

**Output:**
```
┌─────────────────────────────────────────────────────────────┐
│ 🔧 External Drive Partitioning                             │
├─────────────────────────────────────────────────────────────┤
│ Drive: /dev/sdb (1.8TB SanDisk Extreme Pro)                │
│                                                             │
│ ⚠️  WARNING: This will ERASE all data on /dev/sdb!          │
│                                                             │
│ Planned partitions:                                        │
│   1. Games-Universal    900GB  NTFS   (shared library)     │
│   2. Claude-AI-Data     500GB  ext4   (Ollama, ChromaDB)   │
│   3. Development        200GB  ext4   (containers)         │
│   4. Windows-Only       150GB  NTFS   (anti-cheat)         │
│   5. Transfer            50GB  exFAT  (file exchange)      │
│                                                             │
│ Continue? [y/N]:                                           │
└─────────────────────────────────────────────────────────────┘
```

**After partitioning:**

```diff
Before:
/dev/sdb: 1.8TB (unpartitioned)

After:
/dev/sdb1  900GB  NTFS   /mnt/games-universal  (shared)
/dev/sdb2  500GB  ext4   /mnt/claude-ai        (Linux-only)
/dev/sdb3  200GB  ext4   /mnt/development      (Linux-only)
/dev/sdb4  150GB  NTFS   /mnt/windows-only     (shared)
/dev/sdb5   50GB  exFAT  /mnt/transfer         (shared)
```

**Why:** Automated partitioning prevents mistakes, adds to `/etc/fstab` for auto-mount on boot.

---

### 3. Setup Steam Library (Linux)

```bash
# Create Steam library directory
mkdir -p /mnt/games-universal/SteamLibrary

# Open Steam → Settings → Storage → Add Drive
# Select: /mnt/games-universal/SteamLibrary
```

**What changes:**

```mermaid
sequenceDiagram
    participant User
    participant Steam
    participant NTFS as /mnt/games-universal
    participant modules/KENL9

    User->>Steam: Settings → Storage → Add Drive
    Steam->>NTFS: Check write permissions
    NTFS-->>Steam: ✅ Writable
    Steam->>NTFS: Create SteamLibrary/steamapps/
    Steam->>KENL9: Register library location
    modules/KENL9->>KENL9: Add to library tracking
    modules/KENL9-->>User: ✅ Library ready

    Note over User,KENL9: ATOM-LIBRARY-20251110-001 created
```

**Steam library structure:**
```
/mnt/games-universal/SteamLibrary/
├── steamapps/
│   ├── common/              # Game files
│   │   ├── Elden Ring/
│   │   ├── Cyberpunk 2077/
│   │   └── Halo Infinite/
│   ├── compatdata/          # Proton prefixes (Linux)
│   ├── shadercache/         # Vulkan shaders
│   └── appmanifest_*.acf    # Game metadata
└── config/                  # Library config
```

**Why:** Steam manages game installs, updates, and verification. modules/KENL9 tracks which library games belong to.

---

### 4. Setup Steam Library (Windows)

**In Windows:**
1. Open Steam
2. Settings → Storage → Add Drive
3. **Select the same path**: `E:\SteamLibrary` (maps to `/mnt/games-universal/SteamLibrary` on Linux)

**What happens:**

```diff
Linux installs Elden Ring:
  /mnt/games-universal/SteamLibrary/steamapps/common/Elden Ring/ (60GB)

Windows sees same location:
  E:\SteamLibrary\steamapps\common\Elden Ring\ (60GB)

Windows Steam:
  → Detects existing files
  → Verifies integrity
  → Downloads 0 bytes! ✅
  → Ready to play
```

**Visual:**

```mermaid
flowchart LR
    A[Linux: Install Elden Ring] --> B[NTFS: /mnt/games-universal/]
    C[Windows: Install Elden Ring] --> B

    B --> D{Files exist?}
    D -->|Yes| E[Verify files]
    D -->|No| F[Download 60GB]

    E --> G[✅ Play immediately]
    F --> G

    style E fill:#d3f9d8,stroke:#51cf66
    style F fill:#ffe3e3,stroke:#fa5252
```

**Result:**
| Metric | Without modules/KENL9 | With modules/KENL9 |
|--------|---------------|------------|
| **Disk space** | 120GB (60GB × 2) | 60GB |
| **Install time** | 30 min × 2 = 60 min | 30 min + 2 min verify = 32 min |
| **Updates** | Download twice | Download once |

**Why:** Both OSes access **identical files**. Steam is smart enough to detect and verify existing installs.

---

## Save Game Synchronization

### Cloud Saves (Automatic)

**Supported by:**
- ✅ Steam (auto-sync to Steam Cloud)
- ✅ Epic Games (auto-sync)
- ✅ GOG Galaxy (auto-sync if enabled)
- ✅ EA App (auto-sync for EA games)

**No manual sync needed!** Boot into Windows → load save → play → save → boot into Linux → save is there.

---

### Manual Save Sync (for games without cloud saves)

```bash
# Detect save locations
~/kenl/KENL9-library/tools/find-saves.sh "Elden Ring"
```

**Output:**
```
🔍 Elden Ring save locations:

Linux (Proton):
  ~/.steam/steam/steamapps/compatdata/1245620/pfx/drive_c/users/steamuser/AppData/Roaming/EldenRing/

Windows:
  C:\Users\Bazza\AppData\Roaming\EldenRing\

Recommendation:
  1. Move Windows saves to NTFS shared partition
  2. Create symlink from Windows AppData to shared location
  3. Create symlink from Linux compatdata to shared location

Run sync setup? [y/N]:
```

**Sync setup:**

```mermaid
flowchart TD
    A[KENL9 Save Sync] --> B[Move saves to /mnt/transfer/saves/EldenRing/]

    B --> C[Linux symlink]
    B --> D[Windows symlink]

    C --> E[~/.steam/steamapps/compatdata/.../EldenRing/]
    E -.->|points to| B

    D --> F[C:\Users\Bazza\AppData\Roaming\EldenRing\]
    F -.->|points to| B

    B --> G[✅ Both OSes read/write same files]

    style G fill:#d3f9d8,stroke:#51cf66
```

**Commands (automated by modules/KENL9):**

Linux:
```bash
# Backup existing saves
mv ~/.steam/steam/steamapps/compatdata/1245620/pfx/drive_c/users/steamuser/AppData/Roaming/EldenRing/ \
   ~/.steam/elden-ring-backup/

# Create symlink to shared location
ln -s /mnt/transfer/saves/EldenRing/ \
   ~/.steam/steam/steamapps/compatdata/1245620/pfx/drive_c/users/steamuser/AppData/Roaming/EldenRing
```

Windows (PowerShell as Admin):
```powershell
# Backup existing saves
Move-Item C:\Users\Bazza\AppData\Roaming\EldenRing C:\Users\Bazza\Desktop\EldenRing-Backup

# Create symlink to shared location
New-Item -ItemType SymbolicLink `
  -Path "C:\Users\Bazza\AppData\Roaming\EldenRing" `
  -Target "E:\Transfer\saves\EldenRing"
```

**Result:**
- Save in Linux → appears in Windows
- Save in Windows → appears in Linux
- No cloud service needed
- Works for ANY game

---

## Launcher Integration

### Steam

**Status:** ✅ Fully supported (see above)

**Play Cards integration:**
```bash
# modules/KENL2 Play Cards work across OSes
kenl-switch 2
apply-playcard.sh elden-ring.yaml

# Automatically:
# 1. Detects if game in shared library
# 2. Applies Proton settings (Linux)
# 3. Notes Windows compatibility in ATOM trail
```

---

### EA App (Battlefield 6, anti-cheat)

**Status:** ⚠️ Install to Windows-only partition

**Why separate?**
- Battlefield 6 uses **Javelin anti-cheat**
- Anti-cheat doesn't work with Proton/Wine
- Must boot Windows to play

**Setup:**

```bash
# modules/KENL9 tracks Windows-only games
~/kenl/KENL9-library/tools/track-windows-only.sh "Battlefield 6"
```

**What this does:**
```
📝 Tracking Windows-only game: Battlefield 6

Reason: Javelin anti-cheat (incompatible with Linux)
Recommended install: /mnt/windows-only/EA Games/Battlefield 6/

ATOM trail entry created: ATOM-LIBRARY-20251110-002

Note: Game will NOT appear in Linux Steam library
      Boot Windows to play
```

**Integration with modules/KENL2:**
```yaml
# Play Card: battlefield-6.yaml (KENL2)
game: Battlefield 6
os: Windows-only
reason: Javelin anti-cheat
install_location: /mnt/windows-only/EA Games/Battlefield 6/
launcher: EA App
proton: Not compatible
verified: 2025-11-10
performance:
  windows:
    resolution: 1920x1080
    settings: High
    fps_avg: 75
    gpu_usage: 85%
```

---

### Epic Games / Heroic Launcher

**Status:** ✅ Supported via Heroic (Linux) + Epic Games Store (Windows)

**Heroic Launcher (Linux):**
```bash
# Install Heroic via Flatpak
flatpak install flathub com.heroicgameslauncher.hgl

# Configure library to shared NTFS
# Heroic → Settings → Games → Install Path
# Set: /mnt/games-universal/Heroic/
```

**Windows Epic Games Store:**
- Install games to `E:\Heroic\` (same as Linux `/mnt/games-universal/Heroic/`)
- Heroic on Linux can launch games installed by Epic on Windows!

---

## Storage Optimization

### Compress Old Games

```bash
# Compress games not played in 6+ months
~/kenl/KENL9-library/tools/compress-inactive.sh
```

**What changes:**

```
🗜️ Compressing inactive games...

Scanning /mnt/games-universal/SteamLibrary/...
Found 3 games not played in 6 months:

1. Cyberpunk 2077    (100GB, last played: 2025-05-10)
2. GTA V             (110GB, last played: 2025-04-15)
3. RDR2              (120GB, last played: 2025-03-20)

Total: 330GB → Compressed: ~200GB (estimate)

Compress? [y/N]: y

[1/3] Compressing Cyberpunk 2077...
  100GB → 65GB (35% saved) ✅

[2/3] Compressing GTA V...
  110GB → 70GB (36% saved) ✅

[3/3] Compressing RDR2...
  120GB → 75GB (38% saved) ✅

Total saved: 120GB
Compression time: 45 minutes

Note: Decompression takes ~10 minutes per game when you want to play again
```

**Decompression on-demand:**
```bash
# Want to play Cyberpunk again?
~/kenl/KENL9-library/tools/decompress-game.sh "Cyberpunk 2077"

# 10 minutes later: ready to play!
```

**Why:** Free up space without uninstalling. Redownloading takes hours, decompression takes minutes.

---

### Move Games Between Libraries

```bash
# Move Elden Ring: SSD → External
~/kenl/KENL9-library/tools/move-game.sh "Elden Ring" /mnt/games-universal/
```

**What happens:**

```mermaid
stateDiagram-v2
    [*] --> DetectGame: Find Elden Ring in Steam libraries
    DetectGame --> CheckSpace: Target has 60GB free?
    CheckSpace --> MoveFiles: rsync --progress
    CheckSpace --> Error: Not enough space
    Error --> [*]

    MoveFiles --> UpdateManifest: Update appmanifest_*.acf
    UpdateManifest --> VerifyIntegrity: Steam verify files
    VerifyIntegrity --> [*]

    note right of MoveFiles
        Uses rsync to show progress
        Preserves all metadata
        Atomic operation (all or nothing)
    end note
```

**Progress:**
```
Moving Elden Ring: ~/.local/share/Steam → /mnt/games-universal/

[####################] 60GB / 60GB (100%) - 5 minutes remaining
Speed: 200 MB/s
Files: 12,847 / 12,847

✅ Move complete
✅ Steam manifest updated
✅ Verifying integrity... (2 minutes)
✅ Ready to play from new location
```

---

## Migration Tools

### Windows → Linux Game Migration

```bash
# Detect games installed on Windows partition
~/kenl/KENL9-library/migrations/scan-windows-games.sh
```

**Output:**
```
🔍 Scanning Windows partition for games...

Detected game launchers:
  - Steam: C:\Program Files (x86)\Steam\
  - Epic Games: C:\Program Files\Epic Games\
  - EA App: C:\Program Files\Electronic Arts\

Found 15 games:

Steam games (10):
  ✅ Elden Ring            (60GB)   - Gold on ProtonDB
  ✅ Cyberpunk 2077        (100GB)  - Platinum on ProtonDB
  ⚠️  Battlefield 6        (85GB)   - Anti-cheat (Windows-only)
  ✅ Halo Infinite         (50GB)   - Gold on ProtonDB
  ... (6 more)

Epic games (3):
  ✅ Satisfactory          (15GB)   - Works with Heroic
  ⚠️  Fortnite             (30GB)   - Anti-cheat (Windows-only)
  ✅ Control               (40GB)   - Works with Heroic

EA games (2):
  ⚠️  Battlefield 2042     (100GB)  - Anti-cheat (Windows-only)
  ✅ Dragon Age            (50GB)   - Works with Proton

Recommendations:
  - Move 12 compatible games to shared NTFS library
  - Keep 3 anti-cheat games on Windows-only partition
  - Estimated space saved: 450GB (no re-download)

Start migration? [y/N]:
```

**Migration workflow:**

```mermaid
flowchart TD
    A[Scan Windows games] --> B{ProtonDB compatible?}
    B -->|Yes| C[Move to shared NTFS]
    B -->|No anti-cheat| D[Keep on Windows-only]

    C --> E[Update Steam library path]
    E --> F[Linux Steam detects files]
    F --> G[✅ Play on both OSes]

    D --> H[Create modules/KENL2 Play Card]
    H --> I[Note: Windows-only in metadata]
    I --> J[⚠️ Boot Windows to play]

    style G fill:#d3f9d8,stroke:#51cf66
    style J fill:#fff3bf,stroke:#fab005
```

---

### HDD → SSD Migration (Performance)

```bash
# Move frequently-played games to faster storage
~/kenl/KENL9-library/migrations/optimize-performance.sh
```

**Analysis:**
```
📊 Game Performance Analysis

Current libraries:
  1. Internal SSD (500GB, NVMe, 3500 MB/s read)
     - Usage: 450GB / 500GB (90% full)

  2. External HDD (1.8TB, USB 3.2, 150 MB/s read)
     - Usage: 600GB / 1.8TB (33% full)

Most-played games (last 30 days):
  1. Halo Infinite       50GB   External HDD   ⚠️ Slow loading
  2. Elden Ring          60GB   Internal SSD   ✅ Fast loading
  3. Cyberpunk 2077     100GB   External HDD   ⚠️ Slow loading

Recommendations:
  - Move Halo Infinite: HDD → SSD (50GB)
  - Move Cyberpunk: HDD → SSD (100GB)
  - Move old games from SSD → HDD to free space

  Result: 50% faster load times for most-played games

Apply optimization? [y/N]:
```

**Load time comparison:**

| Game | HDD Load | SSD Load | Improvement |
|------|----------|----------|-------------|
| **Halo Infinite** | 45s | 18s | **60% faster** |
| **Elden Ring** | 60s | 22s | **63% faster** |
| **Cyberpunk 2077** | 90s | 35s | **61% faster** |

**Why:** SSDs dramatically improve load times. modules/KENL9 automatically moves frequently-played games to fastest storage.

---

## Integration with Other modules/KENLs

### modules/KENL0: System Operations

```bash
# Partition external drive (privileged)
kenl-switch 0
partition-external.sh /dev/sdb

# ATOM trail: ATOM-SYSTEM-20251110-005
```

### modules/KENL2: Gaming

```bash
# Play Cards track library location
kenl-switch 2
create-playcard.sh "Elden Ring"

# Adds library metadata:
# library: /mnt/games-universal/SteamLibrary
# shared_with_windows: true
```

### modules/KENL8: Security

```bash
# Encrypt save games before cloud backup
kenl-switch 8
encrypt-file /mnt/transfer/saves/EldenRing/ER0000.sl2

# Result: ER0000.sl2.gpg (safe to upload to cloud)
```

### modules/KENL10: Backup

```bash
# Snapshot before major migration
kenl-switch 10
snapshot-create "before-hdd-to-ssd-migration"

# Backs up:
# - Library tracking database
# - modules/KENL9 configurations
# - Save game locations
# - ATOM trail
```

---

## Directory Structure

```
KENL9-library/
├── launchers/                    # Launcher integrations
│   ├── steam-library-manager.sh  # Steam library management
│   ├── heroic-setup.sh           # Epic/GOG via Heroic
│   ├── ea-app-tracker.sh         # EA App games tracking
│   └── windows-only-list.txt     # Anti-cheat games
├── saves/                        # Save game sync
│   ├── find-saves.sh             # Detect save locations
│   ├── setup-sync.sh             # Symlink saves to shared location
│   └── backup-saves.sh           # Encrypt + backup saves
├── tools/                        # Storage optimization
│   ├── partition-external.sh     # Partition external drive
│   ├── compress-inactive.sh      # Compress old games
│   ├── decompress-game.sh        # Decompress for playing
│   ├── move-game.sh              # Move between libraries
│   └── track-windows-only.sh     # Track anti-cheat games
├── migrations/                   # Migration workflows
│   ├── scan-windows-games.sh     # Detect Windows installs
│   ├── optimize-performance.sh   # HDD → SSD migration
│   └── import-library.sh         # Import existing library
└── README.md                     # This file
```

---

## Benefits

| Without modules/KENL9 | With modules/KENL9 |
|---------------|------------|
| Install every game twice | Install once, play on both OSes |
| 1TB wasted (10 games × 2) | 500GB saved |
| Save games don't sync | Auto-sync via symlinks |
| Updates download twice | Update once, applies to both |
| Manual library management | Automated optimization |
| No compression | Compress inactive games, save 30-40% |
| Games scattered across drives | Centralized tracking |

---

## Quick Reference

```bash
# Setup shared library
kenl-switch 9
partition-external.sh /dev/sdb          # Partition drive
setup-steam-library.sh                  # Configure Steam

# Save game sync
find-saves.sh "Game Name"               # Detect save location
setup-sync.sh "Game Name"               # Symlink to shared location

# Storage optimization
compress-inactive.sh                    # Compress old games
move-game.sh "Game" /mnt/target/        # Move to different library

# Migration
scan-windows-games.sh                   # Import Windows library
optimize-performance.sh                 # Move games to SSD

# Tracking
track-windows-only.sh "Game"            # Mark as Windows-only
list-libraries.sh                       # Show all libraries
```

---

## External Resources

- **Steam Library Management**: https://help.steampowered.com/en/faqs/view/4BD4-4528-6B2E-8327
- **Heroic Games Launcher**: https://heroicgameslauncher.com/
- **ProtonDB**: https://www.protondb.com/
- **NTFS-3G**: https://wiki.archlinux.org/title/NTFS-3G

---

## License

MIT License - See [../LICENSE](../LICENSE)

---

## Navigation

- **← [Root README](../README.md)** - Overview of all modules/KENL modules
- **→ [KENL0: System](../modules/KENL0-system/README.md)** - Partitioning, privileged ops
- **→ [KENL2: Gaming](../modules/KENL2-gaming/README.md)** - Play Cards
- **→ [KENL8: Security](../modules/KENL8-security/README.md)** - Save encryption
- **→ [KENL10: Backup](../modules/KENL10-backup/README.md)** - Library snapshots

---

**Status**: Production Ready | **Version**: 1.0.0 | **Focus**: Multi-OS Game Library Management
