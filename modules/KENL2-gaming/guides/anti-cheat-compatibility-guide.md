---
title: Anti-Cheat Compatibility Guide for Linux Gaming
date: 2025-11-10
status: active
tags: [anti-cheat, linux, proton, compatibility, ea-javelin, easyanticheat]
atom: ATOM-DOC-20251110-020
---

# Anti-Cheat Compatibility Guide for Linux Gaming

This guide explains anti-cheat systems and their Linux/Proton compatibility, specifically for Bazzite-DX and Steam Deck gaming.

## Overview

Anti-cheat systems are designed to prevent cheating in online multiplayer games. However, many use kernel-level access that conflicts with Linux/Proton compatibility. Understanding which anti-cheat systems work on Linux is critical for gaming on Bazzite-DX.

## Anti-Cheat Status Legend

- **✅ Supported** - Works on Linux via Proton
- **⚠️ Partial** - Works for some games but not others
- **❌ Denied** - Does not work on Linux
- **❓ Unknown** - Status unclear or untested

## Major Anti-Cheat Systems

### ✅ EasyAntiCheat (EAC) - Partial Support

**Status:** Partial - Developer must enable Linux support

**How it works:**
- Owned by Epic Games
- Supports Linux/Proton when developers opt-in
- Requires no user configuration when enabled

**Games that work:**
- Elden Ring
- Apex Legends
- Dead by Daylight
- Lost Ark
- Halo: The Master Chief Collection

**Games that DON'T work (developer hasn't enabled):**
- Fortnite (Epic intentionally blocks it)
- Rainbow Six Siege
- Rust (developer choice)

**Reference:** https://dev.epicgames.com/en-US/news/epic-online-services-launches-anti-cheat-support-for-linux-mac-and-steam-deck

### ✅ BattlEye - Partial Support

**Status:** Partial - Developer must enable Linux support

**How it works:**
- Supports Linux/Proton when developers opt-in
- Used by many popular games
- Generally good Linux support when enabled

**Games that work:**
- DayZ
- Arma 3
- Insurgency: Sandstorm

**Games that DON'T work:**
- PUBG (developer hasn't enabled)
- Escape from Tarkov

### ❌ EA Javelin Anticheat - NO SUPPORT

**Status:** ❌ DENIED - Intentionally blocks Linux/Steam Deck

**How it works:**
- Proprietary kernel-mode anti-cheat by EA
- Formerly called "EA AntiCheat"
- Rebranded to "EA Javelin Anticheat" in 2025
- Used across 14+ EA games
- Does **NOT** support Linux or Steam Deck

**Common Error Codes:**
- **(7)(2)** - Anti-cheat system error (Linux not supported)
- **(115)** - Unacceptable configuration

**Affected Games (UNPLAYABLE on Linux):**
- **Battlefield 2042** ❌ (switched to Javelin in Oct 2023)
- **Battlefield 6** ❌ (launches with Javelin)
- **Madden NFL 25** ❌
- **FIFA/EA Sports FC** ❌
- All future EA multiplayer titles ❌

**Historical Context:**
- Battlefield 2042 previously used EasyAntiCheat and worked on Linux
- EA switched to Javelin in October 2023, breaking Linux compatibility
- No plans announced for Linux support

**References:**
- Official announcement: https://www.ea.com/security/news/anticheat-progress-report
- Linux impact: https://www.gamingonlinux.com/2025/04/ea-rebrand-and-refresh-their-anti-cheat-into-ea-javelin-anticheat-still-blocks-linux-steam-deck/

**Workaround:** None - requires Windows or dual boot

### ❌ Vanguard (Riot Games) - NO SUPPORT

**Status:** ❌ DENIED - Kernel-level, requires Windows

**How it works:**
- Extremely invasive kernel-level anti-cheat
- Runs at boot, even when game isn't running
- Blocks virtualization and dual-boot in some cases

**Affected Games:**
- Valorant ❌
- League of Legends (being added) ❌

**Workaround:** None - requires dedicated Windows system

### ❌ nProtect GameGuard - NO SUPPORT

**Status:** ❌ DENIED

**Affected Games:**
- Many Korean MMOs
- Blade & Soul
- Black Desert Online (uses different AC now)

### ✅ VAC (Valve Anti-Cheat) - Full Support

**Status:** ✅ SUPPORTED - Native Linux support

**How it works:**
- Valve's own anti-cheat
- Fully supports Linux natively
- Works seamlessly via Proton

**Games that work:**
- Counter-Strike 2
- Team Fortress 2
- Dota 2
- All Valve multiplayer games

### ⚠️ Custom/Proprietary Solutions

Many games use custom anti-cheat solutions. Compatibility varies:

**Working Examples:**
- Fall Guys (custom solution, works)
- Rocket League (custom, works)

**Not Working:**
- Call of Duty (Ricochet) ❌
- Destiny 2 (custom) ❌
- Genshin Impact (miHoYo AC) ❌

## Checking Game Compatibility

### Are We Anti-Cheat Yet?

The definitive resource: **https://areweanticheatyet.com/**

This community-maintained database tracks:
- Which anti-cheat system each game uses
- Current Linux/Proton status
- Recent status changes

### ProtonDB

Check community reports: **https://www.protondb.com/**

Look for mentions of:
- "Anti-cheat working"
- "Kicked from multiplayer"
- Error codes like (7)(2), (115), etc.

## Error Code Reference

### EA Javelin Anticheat Errors

| Code | Meaning | Solution |
|------|---------|----------|
| (7)(2) | System error - OS not supported | None - Linux not supported |
| (115) | Unacceptable configuration | None - requires Windows |
| (117) | Anticheat detected... | Usually false positive on Windows |

### EasyAntiCheat Errors

| Code | Meaning | Solution |
|------|---------|----------|
| 30005 | Client initialization failed | Developer hasn't enabled Linux support |
| 10011 | Game files corrupted | Verify game files in Steam |

## Workarounds and Solutions

### When Anti-Cheat Blocks Linux

**Option 1: Find Alternatives**
- Look for similar games with Linux-compatible anti-cheat
- Check older titles in same series (e.g., Battlefield 1 vs 2042)

**Option 2: Dual Boot**
- Keep Windows installation for incompatible games
- Use Bazzite-DX for compatible games

**Option 3: Community Servers**
- Some games have community servers without anti-cheat
- Example: Older Battlefield titles (BF3, BF4)

**Option 4: Cloud Gaming**
- GeForce NOW
- Xbox Cloud Gaming
- Play Windows versions via streaming

### What DOESN'T Work

❌ Trying different Proton versions (anti-cheat blocks at OS level)
❌ Wine/Proton tweaks (anti-cheat specifically detects these)
❌ Virtual machines (most anti-cheat blocks VMs)
❌ Emulation layers (detected and blocked)

## Best Practices for Linux Gaming

1. **Check before buying** - Always verify anti-cheat compatibility at:
   - https://areweanticheatyet.com/
   - https://www.protondb.com/

2. **Read recent reports** - Anti-cheat status can change:
   - Games can add/remove Linux support
   - Developers can switch anti-cheat systems
   - Example: BF2042 worked until Oct 2023

3. **Prioritize Linux-friendly games** - Vote with your wallet:
   - Games with VAC, EAC (enabled), BattlEye (enabled)
   - Single-player or co-op games
   - Linux-native titles

4. **Join communities:**
   - ProtonDB comments
   - r/linux_gaming on Reddit
   - Bazzite Discord
   - Steam Deck forums

## Future Outlook

### Positive Trends

- More developers enabling EAC/BattlEye Linux support
- Valve's Steam Deck pushing for compatibility
- Growing Linux gaming community

### Negative Trends

- EA Javelin Anticheat expanding (blocks all EA multiplayer)
- Riot Vanguard expanding to League of Legends
- Some publishers actively hostile to Linux

### What to Watch

- **Proton updates** - Valve constantly improving compatibility
- **Developer announcements** - Anti-cheat decisions can change
- **Steam Deck verified** - Valve's compatibility badge
- **Community pressure** - Voice your desire for Linux support

## Reporting and Advocacy

### How to Request Linux Support

1. **Official forums** - Post respectfully on game/publisher forums
2. **Steam discussions** - Request Linux/Deck support
3. **Social media** - Tag developers on Twitter/X
4. **Support tickets** - Open tickets requesting Linux support

### Be Constructive

✅ "I'd love to play this on Steam Deck, please enable EAC Linux support"
✅ "Steam Deck is a significant market, please consider Linux players"
✅ "Your competitor enables Linux support and I prefer their game now"

❌ Demanding, hostile, or entitled language
❌ Piracy threats or mentions
❌ Technical misinformation

## Resources

**Compatibility Databases:**
- Are We Anti-Cheat Yet: https://areweanticheatyet.com/
- ProtonDB: https://www.protondb.com/
- Steam Deck Verified: https://www.steamdeck.com/verified

**Communities:**
- r/linux_gaming: https://reddit.com/r/linux_gaming
- Bazzite Discord: https://discord.gg/bazzite
- ProtonDB Discord: https://discord.gg/protondb

**Official Resources:**
- Proton on GitHub: https://github.com/ValveSoftware/Proton
- EAC Linux support docs: https://dev.epicgames.com/docs/game-services/anti-cheat
- BattlEye statement: https://www.battleye.com/

## Conclusion

Anti-cheat compatibility is the biggest limitation for Linux gaming in 2025. While progress has been made with EAC and BattlEye supporting Linux when developers opt-in, proprietary solutions like EA Javelin Anticheat and Riot Vanguard remain hard blockers.

**Always check compatibility before purchasing multiplayer games.**

For the Bazzite-DX project specifically:
- Focus on compatible titles for Play Cards
- Mark incompatible games clearly (like BF2042)
- Track anti-cheat status changes
- Provide alternatives when games break

---

**ATOM Tag:** ATOM-DOC-20251110-020
**Last Updated:** 2025-11-10
**Maintainer:** Bazza-DX Gaming Working Group
