# Linuxfx - "Windows 11" Without Microsoft

**Visual clone of Windows 11. Seriously, it's uncanny.**

📊 **[DistroWatch: Linuxfx](https://distrowatch.com/table.php?distribution=linuxfx)**
💿 **[Official Website](https://www.linuxfx.org/)**

## At a Glance

| Feature | Windows 11 | Linuxfx |
|---------|------------|---------|
| **Visual appearance** | Modern, centered taskbar | Identical (seriously) |
| **Start Menu** | Centered, app grid | Identical clone |
| **Settings app** | Windows Settings | Looks the same |
| **File Explorer** | Modern redesign | Nearly identical |
| **Cost** | $139+ OR new PC | Free, forever |
| **Ads & telemetry** | Yes, baked in | None |
| **Runs on old PCs** | No (TPM 2.0 required) | Yes (10+ year old hardware) |

## 🎯 Best For

- ✅ Windows 10 users forced to "upgrade" but PC isn't "compatible"
- ✅ People who want Windows 11 looks without buying new hardware
- ✅ "I don't want to learn anything new" users
- ✅ Fooling your IT department (just kidding... mostly)

## ❌ Not Best For

- Gaming (use [Bazzite-DX](../../modules/KENL2-gaming/README.md) instead)
- Professional work requiring Adobe/Microsoft apps
- People who want maximum stability (use Linux Mint instead)

## What It Looks Like

**Desktop:**
```
┌─────────────────────────────────────────────────────────────────┐
│  🌤️  Mon, Nov 10                                     ⚙️ 🔊 📶 🔋 │
│                                                                  │
│                                                                  │
│                     [Your apps/windows here]                     │
│                                                                  │
│                                                                  │
│                                                                  │
├──────────────────────────────────────────────────────────────────┤
│        🪟  🌐  📁  ⊞                        🔔  📅  ⏰        │
│       Start Files Browser                 Notifications  Tray   │
└──────────────────────────────────────────────────────────────────┘
```

**Start Menu (centered):**
```
    ┌─────────────────────────────────────┐
    │  🔍 Search apps, settings, files    │
    ├─────────────────────────────────────┤
    │  📌 Pinned                          │
    │  ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐   │
    │  │ 🌐│ │ 📁│ │ 📧│ │ 🎵│ │ 🎮│   │
    │  └───┘ └───┘ └───┘ └───┘ └───┘   │
    │  ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐   │
    │  │ 📝│ │ 🖼️│ │ 📊│ │ ⚙️│ │ 💬│   │
    │  └───┘ └───┘ └───┘ └───┘ └───┘   │
    ├─────────────────────────────────────┤
    │  👤 User          🔒 Power          │
    └─────────────────────────────────────┘
```

## Pre-installed Apps (Windows Equivalents)

| Windows 11 | Linuxfx Equivalent | Does the same thing? |
|------------|-------------------|---------------------|
| Edge Browser | Firefox | ✅ Yes (better privacy) |
| Microsoft Office | LibreOffice | ✅ Yes (opens .docx, .xlsx) |
| Windows Media Player | VLC | ✅ Yes (plays more formats) |
| Paint | GIMP | ✅ Yes (way more powerful) |
| Notepad | gedit | ✅ Yes |
| File Explorer | Dolphin | ✅ Yes (looks like Windows 11) |
| Windows Settings | Plasma Settings | ✅ Yes (looks identical) |
| Microsoft Store | Discover Software Center | ✅ Yes (more apps, all free) |

## Installing Apps (Visual Guide)

**Windows way:**
1. Google "download chrome"
2. Download .exe file
3. Run installer
4. Click through 5 screens
5. Uncheck "install toolbar"
6. Hope it's not malware

**Linuxfx way:**
1. Open "Discover" (like Microsoft Store)
2. Search "chrome"
3. Click "Install"
4. Done. No malware, no toolbars, no bloat.

```
┌─────────────────────────────────────┐
│ Discover Software Center           │
├─────────────────────────────────────┤
│ 🔍 Search apps...                   │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ 🌐 Google Chrome                │ │
│ │    Web browser by Google        │ │
│ │    ⭐⭐⭐⭐⭐ 4.5 (2.1M reviews)   │ │
│ │    [Install]                    │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

## System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **CPU** | Dual-core 1GHz | Quad-core 2GHz+ |
| **RAM** | 2GB | 4GB+ |
| **Storage** | 20GB | 50GB+ |
| **Graphics** | Any | Intel/AMD/Nvidia all work |
| **TPM 2.0?** | ❌ Not required | ❌ Not required |
| **Secure Boot?** | ❌ Not required | ❌ Not required |

**Translation:** If it ran Windows 10, it'll run Linuxfx (probably faster).

## What Works Out of the Box

✅ **WiFi** - Just click network icon, select network, enter password
✅ **Bluetooth** - Same as Windows (settings → bluetooth)
✅ **Printers** - Most auto-detected (HP, Canon, Epson, Brother)
✅ **USB devices** - Mouse, keyboard, webcam, external drives
✅ **Sound** - Speakers, headphones, HDMI audio
✅ **Dual monitors** - Detect automatically, same as Windows

## What Doesn't Work (Yet)

❌ **Microsoft Office** - Use LibreOffice instead (opens .docx/.xlsx files)
❌ **Adobe Creative Suite** - Use GIMP (Photoshop), Inkscape (Illustrator), or dual-boot
❌ **Some games with anti-cheat** - Most Steam games work fine, competitive games may not
❌ **iTunes** - Use Rhythmbox or web player

## Gaming Support

**Verdict:** 🟡 Moderate

- ✅ Steam games via Proton (60-80% work)
- ✅ GOG games via Heroic Launcher
- ❌ Games with anti-cheat (Valorant, Fortnite) don't work
- 👉 **For gaming, use [Bazzite-DX](../../modules/KENL2-gaming/README.md) instead**

## How to Try It (No Installation Required)

1. **Download ISO** from [linuxfx.org](https://www.linuxfx.org/)
2. **Create bootable USB** (use [Rufus](https://rufus.ie/) on Windows)
3. **Reboot** with USB inserted
4. **Try it live** - boots from USB, doesn't touch your hard drive
5. **If you like it** - click "Install" icon on desktop

**Your Windows installation is untouched during "try it live" mode.**

## Installation Options

**Option 1: Replace Windows (easiest)**
- Erases Windows, uses whole drive
- ⚠️ **Backup files first!**

**Option 2: Dual-boot (safest)**
- Keep Windows, add Linuxfx
- Choose which OS at startup
- Requires 50GB free space

**Option 3: Virtual Machine (lowest commitment)**
- Run Linuxfx inside Windows
- Uses VirtualBox or VMware
- Slower, but safe to test

## Support & Community

- 📚 **Official Docs:** [linuxfx.org/documentation](https://www.linuxfx.org/)
- 💬 **Forum:** Active community on website
- 🎥 **YouTube:** Search "Linuxfx tutorial" (lots of guides)
- 📊 **DistroWatch:** [distrowatch.com/linuxfx](https://distrowatch.com/table.php?distribution=linuxfx)

## Update Schedule

- **Major releases:** Yearly (based on Ubuntu LTS)
- **Security updates:** Weekly (automatic)
- **Feature updates:** Monthly
- **EOL:** 5 years of support per release

**Translation:** Install once, get updates for 5 years. No forced "Windows 12" upgrade.

## The Catch

**There isn't one.** It's free, open-source, no ads, no telemetry, no subscriptions.

The "catch" is learning that not all Windows software works (but there are alternatives for 95% of use cases).

## Verdict

**If you want Windows 11 without Microsoft, this is it.**

✅ Looks identical to Windows 11
✅ Works on old hardware Windows 11 won't
✅ Free forever, no forced upgrades
✅ Privacy-respecting (no telemetry)

❌ Not the best for gaming (use Bazzite instead)
❌ Can't run Windows-only software (Adobe, etc.)

**Best for:** Windows 10 refugees who want the Windows 11 experience without buying new hardware.

---

**Part of:** [Windows Alternatives Guide](./README.md)
**DistroWatch:** [linuxfx](https://distrowatch.com/table.php?distribution=linuxfx)
**Official Site:** [linuxfx.org](https://www.linuxfx.org/)
