# ClaudeNPC Server - Plugin Configuration Guide

**Version:** 2.1.0
**Date:** December 9, 2025
**Status:** Production Ready with Optimized Configurations

---

## Table of Contents

1. [Plugin Overview](#plugin-overview)
2. [Citizens Configuration](#citizens-configuration)
3. [LuckPerms Configuration](#luckperms-configuration)
4. [PlaceholderAPI Configuration](#placeholderapi-configuration)
5. [Vault Configuration](#vault-configuration)
6. [Recommended Additions](#recommended-additions)
7. [Plugin Cohesion & Aliases](#plugin-cohesion--aliases)
8. [Prism Launcher Integration](#prism-launcher-integration)
9. [Troubleshooting](#troubleshooting)

---

## Plugin Overview

### Currently Installed Plugins

| Plugin | Version | Purpose | Status |
|--------|---------|---------|--------|
| **Citizens** | 2.0.35+ | NPC Creation & Management | ✅ Installed & Configured |
| **Vault** | 1.7.3 | Economy & Permissions API | ✅ Installed |
| **LuckPerms** | 5.4.148 | Permissions Management | ✅ Installed & Configured |
| **PlaceholderAPI** | 2.11.7 | Placeholder System | ✅ Installed |
| **CoreProtect** | 23.0 | Block Logging & Rollback | ⚠️ Download Failed (Retry Available) |

### Recommended Additional Plugins

| Plugin | Purpose | Priority | Download URL |
|--------|---------|----------|--------------|
| **EssentialsX** | Admin Commands & Extended Gameplay | 🔴 HIGH | https://github.com/EssentialsX/Essentials |
| **EssentialsX Chat** | Chat Formatting & Management | 🟡 MEDIUM | https://github.com/EssentialsX/Essentials |
| **EssentialsX Spawn** | Spawn Management | 🟡 MEDIUM | https://github.com/EssentialsX/Essentials |
| **WorldEdit** | Terrain Editing | 🟢 LOW | https://dev.bukkit.org/projects/worldedit |
| **WorldGuard** | Region Protection | 🟢 LOW | https://dev.bukkit.org/projects/worldguard |

---

## Citizens Configuration

**File:** `C:\MinecraftServer\plugins\Citizens\config.yml`

### Key Optimizations Applied

#### 1. Look-Close Behavior (AI Engagement)
```yaml
look-close:
  enabled: true              # ✅ ENABLED - NPCs look at players
  range: 15                  # ⬆️ INCREASED from 10 to 15 blocks
  random-look-enabled: true  # ✅ ENABLED - Natural looking around
  realistic-looking: true    # ✅ ENABLED - Line-of-sight checking
```

**Why:** Makes AI NPCs feel more alive and responsive to player presence.

#### 2. Talk-Close Behavior (AI Interaction)
```yaml
talk-close:
  random-talker: true        # ✅ ENABLED - NPCs initiate conversation
  enabled: true              # ✅ ENABLED - Auto-talk to nearby players
  range: 8                   # ⬆️ INCREASED from 5 to 8 blocks
  text:
    - Hi, I'm <npc>! I'm powered by Claude AI.
    - Need help? Just ask!
```

**Why:** Enables proactive AI engagement with players.

#### 3. Pathfinding Performance
```yaml
pathfinding:
  pathfinder-type: CITIZENS_ASYNC  # ⬆️ UPGRADED from MINECRAFT
  citizens:
    blocks-per-tick: 500            # ⬆️ INCREASED from 250
    maximum-search-blocks: 2048     # ⬆️ INCREASED from 1024
    open-doors: true                # ✅ ENABLED - Realistic movement
    check-bounding-boxes: true      # ✅ ENABLED - Better navigation
  default-range-blocks: 150.0       # ⬆️ INCREASED from 100
```

**Why:**
- `CITIZENS_ASYNC` uses multi-core processing for better performance
- Higher pathfinding limits allow smoother AI movement
- Door interaction makes NPCs behave more realistically

#### 4. Waypoint Caching
```yaml
waypoints:
  cache-paths: true          # ✅ ENABLED - Reduces CPU usage
```

**Why:** Eliminates repetitive pathfinding calculations for static routes.

---

## LuckPerms Configuration

**File:** `C:\MinecraftServer\plugins\LuckPerms\config.yml`

### Key Optimizations Applied

#### 1. NPC Permissions Group
```yaml
vault-npc-group: npc         # ⚠️ CHANGED from 'default' to 'npc'
vault-npc-op-status: true    # ✅ ENABLED - NPCs have full capabilities
```

**Required Setup:**
After starting the server, create the `npc` permission group:

```bash
# In-game or console commands:
lp creategroup npc
lp group npc permission set citizens.npc.* true
lp group npc permission set citizens.admin true
lp group npc permission set essentials.* true
lp group npc setweight 100
```

**Why:** Separates NPC permissions from player permissions for better control.

#### 2. Storage Method
```yaml
storage-method: h2           # Default (local database)
```

**Alternative Options:**
- `yaml` - For manual editing
- `mysql` - For multi-server setups
- `mariadb` - Preferred over MySQL

---

## PlaceholderAPI Configuration

**File:** `C:\MinecraftServer\plugins\PlaceholderAPI\config.yml`

### Current Settings
```yaml
check_updates: true
cloud_enabled: true          # Allows downloading expansions
cloud_sorting: "name"
debug: false
```

### Recommended Expansions

Install via in-game command: `/papi ecloud download <expansion>`

| Expansion | Purpose | Command |
|-----------|---------|---------|
| **Player** | Player data placeholders | `/papi ecloud download Player` |
| **Server** | Server info placeholders | `/papi ecloud download Server` |
| **LuckPerms** | Permission placeholders | `/papi ecloud download LuckPerms` |
| **Vault** | Economy placeholders | `/papi ecloud download Vault` |

**Example Placeholders:**
- `%player_name%` - Player's name
- `%player_world%` - Current world
- `%vault_eco_balance%` - Player's money
- `%luckperms_prefix%` - Player's prefix

---

## Vault Configuration

**File:** `C:\MinecraftServer\plugins\Vault\config.yml`

### Current Settings
```yaml
update-check: true           # Simple config - Vault is mostly API
```

**Purpose:** Vault acts as a bridge between:
- Economy plugins → Other plugins needing economy
- Permission plugins → Other plugins needing permissions

**Integration:**
- ✅ LuckPerms provides permissions via Vault
- ⚠️ No economy plugin installed yet (EssentialsX recommended)

---

## Recommended Additions

### 1. EssentialsX Suite

**Why Install:**
- Provides essential server commands (`/tp`, `/gamemode`, `/time`, etc.)
- Adds economy system (works with Vault)
- Includes chat formatting
- Spawn management
- Home/warp system

**Files to Download:**
- `EssentialsX.jar` - Core plugin
- `EssentialsXChat.jar` - Chat management
- `EssentialsXSpawn.jar` - Spawn management

**Download:** https://github.com/EssentialsX/Essentials/releases/latest

### 2. CoreProtect (Retry Installation)

**Why Install:**
- Logs all block changes
- Rollback griefing
- Track NPC actions
- Essential for server safety

**Current Status:** Download failed (connection issue)

**Manual Installation:**
1. Download from: https://modrinth.com/plugin/coreprotect/version/23.0
2. Place in `C:\MinecraftServer\plugins\`
3. Restart server

---

## Plugin Cohesion & Aliases

### Command Conflicts & Resolutions

#### Citizens vs EssentialsX

**Potential Conflicts:**
- `/npc` (Citizens) vs `/npc` (None)
- No direct conflicts expected

**Recommendations:**
- Keep Citizens commands as-is (no conflicts)
- EssentialsX commands won't overlap

#### LuckPerms Commands

**Primary Commands:**
- `/lp` or `/luckperms` - Main command
- `/lpb` or `/luckpermsbukkit` - Bukkit-specific

**No Conflicts:** LuckPerms uses unique command structure

### Custom Command Aliases

Create file: `C:\MinecraftServer\plugins\Citizens\aliases.yml`

```yaml
# Suggested aliases for easier NPC management
aliases:
  createbot: npc create
  editbot: npc select
  botmove: npc tphere
  bottalk: npc text
```

---

## Prism Launcher Integration

### Server Configuration for Prism Launcher

**Prism Launcher Location:**
`C:\Users\iamto\AppData\Roaming\PrismLauncher\`

### Method 1: Manual Server Addition

1. Launch Prism Launcher
2. Create/Select an instance (Minecraft 1.21.1)
3. Launch the game
4. In Minecraft Multiplayer menu:
   - Click "Add Server"
   - **Server Name:** ClaudeNPC Local Server
   - **Server Address:** localhost:25565
   - Click "Done"

### Method 2: servers.dat File (Advanced)

If you want to pre-configure the server for an instance:

**Location:** `C:\Users\iamto\AppData\Roaming\PrismLauncher\instances\<INSTANCE_NAME>\minecraft\servers.dat`

**Note:** This is a binary NBT file. Easier to add manually in-game.

### Creating a ClaudeNPC Instance

**Recommended Setup:**

1. **Instance Name:** ClaudeNPC Testing
2. **Minecraft Version:** 1.21.1 or 1.21.2
3. **Loader:** Vanilla (no mods needed for testing)
4. **Memory:** 2-4 GB

**Optional Client-Side Mods:**
- **Sodium** - Performance improvement
- **Litematica** - Schematic viewer
- **MiniHUD** - Lightweight info display

---

## Troubleshooting

### Issue: Plugin Not Loading

**Symptoms:**
- Plugin appears in `/plugins` but shows red
- Console shows errors on startup

**Solutions:**
1. Check Minecraft version compatibility (needs 1.21+)
2. Verify plugin dependencies (Citizens needs Vault)
3. Check for conflicting plugins
4. Review `logs/latest.log` for error details

### Issue: Citizens NPCs Not Spawning

**Symptoms:**
- `/npc create` command works but NPC doesn't appear
- Console shows pathfinding errors

**Solutions:**
1. Ensure you're in a loaded chunk
2. Check `pathfinder-type` setting (try `MINECRAFT` if `CITIZENS_ASYNC` fails)
3. Verify Java version (needs Java 17+)
4. Check server memory allocation

### Issue: Permissions Not Working

**Symptoms:**
- Commands return "no permission" errors
- NPCs can't interact with world

**Solutions:**
1. Verify LuckPerms is loaded: `/lp info`
2. Create `npc` group if missing
3. Check vault-npc-group setting
4. Grant permissions: `/lp group npc permission set <permission> true`

### Issue: PlaceholderAPI Not Replacing Placeholders

**Symptoms:**
- Chat shows `%player_name%` instead of actual name
- NPC text shows raw placeholders

**Solutions:**
1. Install required expansions: `/papi ecloud download Player`
2. Reload PlaceholderAPI: `/papi reload`
3. Verify expansion is loaded: `/papi list`
4. Check placeholder syntax (case-sensitive)

---

## Performance Optimization Tips

### 1. NPC Limits

**Default Limit:** 10 NPCs per player

**Adjust in Citizens config:**
```yaml
npc:
  limits:
    default-limit: 50  # Increase if needed
```

### 2. View Distance

**Server Properties:**
```properties
view-distance=10      # Default
entity-view-distance=8  # Lower than view distance
```

**Why:** Reduces entity rendering load

### 3. Garbage Collection Flags

**In `start.bat`:**
```batch
java -Xms4G -Xmx8G -XX:+UseG1GC -XX:+ParallelRefProcEnabled ^
     -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions ^
     -XX:+DisableExplicitGC -jar paper.jar --nogui
```

Already configured in installation!

---

## Next Steps

### Immediate Actions

1. ✅ **Install EssentialsX**
   - Download core plugin
   - Configure `/essentials/config.yml`
   - Set up economy system

2. ✅ **Retry CoreProtect Download**
   - Manual download if auto-download fails
   - Configure logging settings

3. ✅ **Create Permission Groups**
   ```bash
   lp creategroup admin
   lp creategroup moderator
   lp creategroup npc
   lp creategroup player
   ```

4. ✅ **Install PlaceholderAPI Expansions**
   ```bash
   /papi ecloud download Player
   /papi ecloud download Server
   /papi ecloud download LuckPerms
   /papi ecloud download Vault
   ```

### Testing Checklist

- [ ] Create test NPC: `/npc create TestBot`
- [ ] Test NPC pathfinding: `/npc path`
- [ ] Test look-close: Stand near NPC
- [ ] Test talk-close: Walk into range
- [ ] Test permissions: `/lp user <name> permission check <perm>`
- [ ] Test placeholders in chat
- [ ] Connect via Prism Launcher
- [ ] Test economy commands (after EssentialsX)

---

## Configuration Files Summary

| File | Purpose | Status |
|------|---------|--------|
| `plugins/Citizens/config.yml` | NPC behavior & pathfinding | ✅ Optimized |
| `plugins/LuckPerms/config.yml` | Permissions & NPC groups | ✅ Configured |
| `plugins/PlaceholderAPI/config.yml` | Placeholder settings | ✅ Ready |
| `plugins/Vault/config.yml` | API bridge settings | ✅ Minimal config |
| `plugins/EssentialsX/config.yml` | ⚠️ Awaiting installation | ❌ Not installed |
| `plugins/CoreProtect/config.yml` | ⚠️ Awaiting installation | ❌ Not installed |

---

## Support & Resources

### Official Documentation

- **Citizens:** https://wiki.citizensnpcs.co/
- **LuckPerms:** https://luckperms.net/wiki
- **PlaceholderAPI:** https://wiki.placeholderapi.com/
- **EssentialsX:** https://essentialsx.net/wiki/
- **PaperMC:** https://docs.papermc.io/

### Community Resources

- **SpigotMC Forums:** https://www.spigotmc.org/
- **PaperMC Discord:** https://discord.gg/papermc
- **LuckPerms Discord:** https://discord.gg/luckperms

### Troubleshooting Logs

**Location:** `C:\MinecraftServer\logs\latest.log`

**How to Read:**
- `[INFO]` - Normal operation
- `[WARN]` - Potential issue (not critical)
- `[ERROR]` - Critical problem (plugin failure)

---

**Configuration Guide Version:** 2.1.0
**Created:** December 9, 2025
**For:** ClaudeNPC Server Suite v2.0.0
**Compatibility:** Minecraft 1.21+ / PaperMC 1.21.1

*Making AI-powered Minecraft NPCs a reality!* ⚡
