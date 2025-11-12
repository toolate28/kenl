# AnduinOS - Windows 7 Lives On

**The Windows 7 experience you loved, without the security risks.**

📊 **[DistroWatch: AnduinOS](https://distrowatch.com/table.php?distribution=anduin)**
💿 **[Official Website](https://www.anduinos.com/)**

## At a Glance

| Feature | Windows 7 | AnduinOS |
|---------|-----------|----------|
| **Visual appearance** | Aero Glass, classic taskbar | Identical clone |
| **Start Menu** | Classic left-corner menu | Authentic recreation |
| **Taskbar** | Bottom, left-aligned | Same |
| **Aero effects** | Transparent windows | ✅ Included |
| **Security updates** | ❌ Ended Jan 2020 | ✅ Active |
| **Cost** | $120 (no longer sold) | Free, forever |
| **Runs on old PCs** | ✅ Yes | ✅ Yes |

## 🎯 Best For

- ✅ Windows 7 holdouts who hate Windows 10/11
- ✅ People who refuse to "upgrade" because they want a functional Start Menu
- ✅ "Peak Windows was 2009" enthusiasts
- ✅ Businesses still running Windows 7 (hello, security nightmares)

## ❌ Not Best For

- Modern gaming (use [Bazzite-DX](../../modules/KENL2-gaming/README.md) instead)
- Latest hardware (drivers may lag)
- People who want cutting-edge features

## What It Looks Like

**Desktop (Aero Glass theme):**
```
┌─────────────────────────────────────────────────────────────────┐
│  My Computer          My Documents        Recycle Bin           │
│  ┌────┐               ┌────┐              ┌────┐                │
│  │ 💻 │               │ 📁 │              │ 🗑️ │                │
│  └────┘               └────┘              └────┘                │
│                                                                  │
│                                                                  │
│                     [Your windows here]                          │
│                  (with Aero transparency!)                       │
│                                                                  │
├──────────────────────────────────────────────────────────────────┤
│ ⊞ Start │ 🔍 │ 📁 │ 🌐 │ □ □ □          │ 🔊 🌐 🔋 │ 🕐 4:20 PM  │
└──────────────────────────────────────────────────────────────────┘
```

**Classic Start Menu:**
```
┌─────────────────────────────────────┐
│ 👤 Username                         │
├─────────────────────────────────────┤
│  📁 Documents                       │
│  🖼️  Pictures                        │
│  🎵 Music                            │
│  🎮 Games                            │
│  🌐 Internet                         │
│  📧 Email                            │
├─────────────────────────────────────┤
│  All Programs                     ▶ │
├─────────────────────────────────────┤
│ 🔍 Search programs and files...     │
├─────────────────────────────────────┤
│         Shut down ▼                 │
└─────────────────────────────────────┘
```

## Pre-installed Apps (Windows 7 Equivalents)

| Windows 7 | AnduinOS Equivalent | Nostalgia Factor |
|-----------|---------------------|------------------|
| Internet Explorer | Firefox (with IE theme available) | 🥲 |
| Windows Media Player | VLC | ✅ |
| Paint | GIMP + Pinta (simple Paint clone) | ✅ |
| Notepad | gedit | ✅ |
| Solitaire | Aisleriot Solitaire | 💯 |
| Minesweeper | GNOME Mines | 💯 |
| Windows Photo Viewer | gThumb | ✅ |
| Windows Explorer | PCManFM (looks identical) | ✅ |

## What Makes AnduinOS Special

**1. Authentic Windows 7 Aero Theme**
- Transparent window borders
- Taskbar preview thumbnails
- Flip 3D effect (Windows+Tab)
- Aero Peek (show desktop)
- Glass effects on menus

**2. Classic Start Menu**
- Left-aligned (where it belongs)
- Search box built-in
- All Programs expandable list
- Shutdown button in logical place
- No tiles, no metro, no nonsense

**3. Familiar File Manager**
- Libraries (Documents, Music, Pictures, Videos)
- Breadcrumb navigation
- Details pane
- Icon view, List view, Details view
- Looks exactly like Windows Explorer

**4. System Tray That Makes Sense**
- Network icon (click to see WiFi)
- Volume control
- Battery indicator
- Clock with date
- No "hidden icons" nonsense

## System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **CPU** | 1GHz single-core | 2GHz dual-core+ |
| **RAM** | 1GB | 2GB+ |
| **Storage** | 15GB | 30GB+ |
| **Graphics** | 128MB | 256MB+ for Aero effects |

**Translation:** If it ran Windows 7, it'll run AnduinOS (and probably faster because no bloat).

## Installing Apps (Windows 7 Style)

**Old Windows 7 way:**
1. Google app name + "download"
2. Download .exe file
3. Run installer
4. Hope it's not malware
5. Scan with antivirus
6. Find out it installed a toolbar

**AnduinOS way:**
1. Open "Software Center" (like Windows Update but for apps)
2. Search app name
3. Click "Install"
4. No malware, no toolbars, no registration

**OR** (for nerds):
```bash
# Installing Chrome (terminal way)
sudo apt install google-chrome-stable
```

But you don't need terminal - Software Center does it all.

## What Works Out of the Box

✅ **WiFi** - NetworkManager (same icon as Windows 7)
✅ **Printers** - Most auto-detected
✅ **USB devices** - Plug and play
✅ **Sound** - Just works
✅ **Dual monitors** - Detect automatically
✅ **Windows 7 keyboard shortcuts** - Most work identically

## Windows 7 Keyboard Shortcuts (That Still Work!)

| Shortcut | Windows 7 | AnduinOS |
|----------|-----------|----------|
| Win + E | Open Explorer | ✅ Opens File Manager |
| Win + R | Run dialog | ✅ Works |
| Win + D | Show Desktop | ✅ Works |
| Win + L | Lock screen | ✅ Works |
| Win + Tab | Flip 3D | ✅ Task switcher |
| Alt + Tab | Switch windows | ✅ Works |
| Win + Number | Launch taskbar app | ✅ Works |
| Print Screen | Screenshot | ✅ Works |

## Gaming Support

**Verdict:** 🟡 Moderate

- ✅ Older games (2000-2015 era) work great
- ✅ Steam games via Proton (60% compatible)
- ❌ Modern games with anti-cheat may not work
- ⚠️ Better than Windows 7 (Proton support) but not as good as Bazzite

**For serious gaming:** Use [Bazzite-DX](../../modules/KENL2-gaming/README.md) instead.

## Migration from Windows 7

**Your old Windows 7 habits that still work:**

| Windows 7 Habit | AnduinOS Equivalent |
|----------------|---------------------|
| Click Start → Type program name → Enter | ✅ Same |
| Right-click desktop → Personalize | ✅ Same |
| Control Panel | Settings (but organized better) |
| C:\Users\YourName\Documents | /home/yourname/Documents |
| .exe files | .deb files (but use Software Center instead) |
| Defragment disk | ❌ Not needed (Linux filesystems don't fragment) |
| Antivirus scan | ❌ Not needed (Linux malware is rare) |
| Registry cleaning | ❌ No registry to corrupt! |

## What You'll Never Miss

❌ **Registry corruption** - No registry to corrupt!
❌ **Forced reboots** - Updates don't force restart
❌ **Slowing down over time** - Stays fast forever
❌ **Antivirus nagging** - No need for antivirus
❌ **Bloatware** - Clean installation, no trial software
❌ **Activation hell** - No product keys, no activation

## How to Try It (No Risk)

1. **Download ISO** from [anduinos.com](https://www.anduinos.com/)
2. **Create bootable USB** (use [Rufus](https://rufus.ie/))
3. **Boot from USB** - doesn't touch Windows
4. **Try it out** - full Windows 7 experience, live
5. **Install if you like it** - or just remove USB

**Your Windows 7 installation is untouched during live USB mode.**

## Installation Options

**Option 1: Replace Windows 7**
- Finally escape security nightmare
- Use whole drive
- ⚠️ **Backup files first!**

**Option 2: Dual-boot**
- Keep Windows 7 (why though?)
- Choose OS at startup
- Requires 30GB free space

**Option 3: In-place migration**
- Install alongside Windows 7
- Keep all files in /home
- Safest option

## Security (The Real Reason to Switch)

| Windows 7 (EOL Jan 2020) | AnduinOS |
|--------------------------|----------|
| ❌ No security updates | ✅ Monthly security updates |
| ❌ No browser updates | ✅ Latest Firefox/Chrome |
| ❌ Vulnerable to malware | ✅ Linux malware is rare |
| ❌ No antivirus support | ✅ Doesn't need antivirus |

**Fun fact:** Running Windows 7 in 2025 is like leaving your front door unlocked with a "Free Stuff Inside" sign.

## Support & Community

- 📚 **Official Docs:** [anduinos.com/docs](https://www.anduinos.com/)
- 💬 **Forum:** Active community of Windows 7 refugees
- 🎥 **YouTube:** "AnduinOS tutorial" (lots of walkthrough videos)
- 📊 **DistroWatch:** [distrowatch.com/anduin](https://distrowatch.com/table.php?distribution=anduin)

## Update Schedule

- **Major releases:** Yearly (based on Debian stable)
- **Security updates:** Monthly (automatic)
- **Desktop updates:** Quarterly
- **EOL:** 5 years per release

**Translation:** Install once, stay secure for 5 years. No nagging to upgrade to "Windows 8" equivalent.

## The Catch

**There isn't one.** It's free, secure, and looks exactly like Windows 7.

The "catch" is admitting that Windows peaked in 2009 and Microsoft ruined it after that.

## Verdict

**If you loved Windows 7 and hate everything since, this is your escape.**

✅ Authentic Windows 7 Aero Glass theme
✅ Stays secure (Windows 7 doesn't)
✅ Classic Start Menu (no tiles!)
✅ Works on old hardware

❌ Not cutting-edge (and that's the point)
❌ Some newer hardware may not work
❌ Can't run Windows-only software

**Best for:** Windows 7 diehards who want security updates without sacrificing the best Windows UI ever made.

**Perfect quote:** "They don't make 'em like they used to. So we rebuilt it."

---

**Part of:** [Windows Alternatives Guide](./README.md)
**DistroWatch:** [anduin](https://distrowatch.com/table.php?distribution=anduin)
**Official Site:** [anduinos.com](https://www.anduinos.com/)
