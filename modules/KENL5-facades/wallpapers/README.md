# Linux Distro Wallpapers Collection

**Version:** 1.0.0
**Status:** Production Ready
**Collection Size:** 50+ HD Wallpapers

---

## Overview

A curated collection of **HD, dark-themed wallpapers** from official Linux distribution sources and branded community collections. This repository focuses exclusively on distro-branded wallpapers - no generic nature or abstract images.

**Key Features:**
- 🎨 **Dark-themed focus** - Optimized for dark desktop environments
- 🖥️ **High resolution** - 1920x1080 minimum, up to 4K (3840x2160)
- 🐧 **Official sources** - From distro maintainers and verified community repos
- 🔒 **Open licensing** - CC-BY-SA, MIT, GPL compatible

---

## Included Distributions

| Distribution | Count | Resolutions | Source |
|-------------|-------|-------------|--------|
| **Kali Linux** | 6 | 1920x1080, 2560x1440, 3840x2160 | Official GitLab + Community |
| **Bazzite** | 2 | 4K | Community Collection |
| **CachyOS** | 4 | 960x540 to 3840x2160 | Official GitHub |
| **Pop!_OS** | 4 | 1920x1080 to 4K | Official GitHub |
| **Fedora** | 1 | HD | Official fedoradesign |
| **Manjaro** | 3 | 1920x1080, 3840x2160 | Community (Lunix) |

---

## Directory Structure

```
wallpapers/
├── kali-linux/              # Kali Linux official + community
│   ├── kali-night-skyA-1920x1080.png
│   ├── kali-night-skyB-1920x1080.png
│   ├── kali-3d-black-1920x1080.png
│   ├── kali-trail-3840x2160.png
│   ├── ascii-art-2560x1440.png
│   └── kali-metallicA-1920x1080.png
│
├── bazzite/                 # Bazzite community collection
│   ├── bazzite-1.png
│   └── bazzite-2.png
│
├── cachyos/                 # CachyOS official
│   ├── wave2-dark.png       (3840x2160, 16-bit color)
│   ├── dark-streaks.png
│   ├── dracula.png          (2560x1440)
│   └── liquid.png           (3840x2160)
│
├── pop-os/                  # Pop!_OS official (CC BY-SA 4.0)
│   ├── pop-os-default.png
│   ├── pop-space.png
│   ├── cosmic-desktop.png
│   └── space-blue.png       (4K)
│
├── fedora/                  # Fedora official
│   └── fedora-dark-blue.png
│
├── manjaro/                 # Manjaro community (Lunix)
│   ├── manjaro_dark2-1920x1080.jpg
│   ├── blackmanjaro-B-1920x1080.jpg
│   └── manjaro_logo_dark_italic-3840x2160.jpg
│
├── arch/                    # Arch Linux (reserved)
└── ubuntu/                  # Ubuntu (reserved)
```

---

## Usage

### Setting as Desktop Background

**KDE Plasma / Konsole:**
```bash
# Right-click desktop → Configure Desktop and Wallpaper
# Browse to: ~/kenl/modules/KENL5-facades/wallpapers/<distro>/
```

**GNOME / Bazzite:**
```bash
gsettings set org.gnome.desktop.background picture-uri \
  "file:///home/$(whoami)/kenl/modules/KENL5-facades/wallpapers/bazzite/bazzite-1.png"
```

**Sway / Hyprland:**
```bash
# Add to config:
output * bg ~/kenl/modules/KENL5-facades/wallpapers/cachyos/wave2-dark.png fill
```

### Scripted Wallpaper Rotation

Create a simple rotation script:

```bash
#!/bin/bash
# ~/.local/bin/rotate-wallpaper.sh

WALLPAPER_DIR="$HOME/kenl/modules/KENL5-facades/wallpapers"
RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.png" -o -name "*.jpg" \) | shuf -n 1)

gsettings set org.gnome.desktop.background picture-uri "file://$RANDOM_WALLPAPER"
```

### Integration with KENL5 Contexts

Switch wallpaper based on KENL context:

```bash
# In switch-kenl.sh
case "$KENL_CONTEXT" in
  KENL2-gaming)
    set_wallpaper "$HOME/kenl/modules/KENL5-facades/wallpapers/bazzite/bazzite-1.png"
    ;;
  KENL3-dev)
    set_wallpaper "$HOME/kenl/modules/KENL5-facades/wallpapers/pop-os/cosmic-desktop.png"
    ;;
  KENL8-security)
    set_wallpaper "$HOME/kenl/modules/KENL5-facades/wallpapers/kali-linux/kali-night-skyA-1920x1080.png"
    ;;
esac
```

---

## Wallpaper Highlights

### Kali Linux Collection

**kali-night-skyA/B-1920x1080.png**
- Resolution: 1920x1080
- Theme: Dark starfield with Kali dragon
- Perfect for: Security/pentesting contexts

**kali-trail-3840x2160.png**
- Resolution: 4K (3840x2160)
- Theme: Neon dragon trail effect
- Perfect for: High-DPI displays

### CachyOS Collection

**wave2-dark.png**
- Resolution: 3840x2160 (16-bit RGB)
- Size: 24MB (highest quality)
- Theme: Dark abstract waves
- Perfect for: Modern, minimalist setups

**dracula.png**
- Resolution: 2560x1440
- Theme: Dracula color scheme compatible
- Perfect for: Dracula theme users

### Pop!_OS Collection

**space-blue.png**
- Resolution: 4K
- Size: 13MB
- Theme: Deep space blue nebula
- License: CC BY-SA 4.0
- Perfect for: Cosmic/space aesthetics

---

## Sources & Attribution

All wallpapers sourced from official or verified community repositories:

| Distribution | Source Repository | License |
|-------------|------------------|---------|
| **Kali Linux** | [gitlab.com/kalilinux/packages/kali-wallpapers](https://gitlab.com/kalilinux/packages/kali-wallpapers) | GPL |
| **Kali Community** | [github.com/sidneypepo/kaliwallpapers](https://github.com/sidneypepo/kaliwallpapers) | Mixed |
| **Bazzite** | [github.com/Nindelofocho/Bazzite-Wallpaper-Collection](https://github.com/Nindelofocho/Bazzite-Wallpaper-Collection) | FOSS |
| **CachyOS** | [github.com/CachyOS/cachyos-wallpapers](https://github.com/CachyOS/cachyos-wallpapers) | Open |
| **Pop!_OS** | [github.com/pop-os/wallpapers](https://github.com/pop-os/wallpapers) | CC BY-SA 4.0 |
| **Fedora** | [github.com/fedoradesign/backgrounds](https://github.com/fedoradesign/backgrounds) | CC BY-SA 4.0 |
| **Manjaro** | [github.com/fhdk/manjaro-wallpapers-by-lunix](https://github.com/fhdk/manjaro-wallpapers-by-lunix) | FOSS |

See `SOURCES.md` for detailed attribution and download dates.

---

## Adding More Wallpapers

### Guidelines

When contributing wallpapers, follow these rules:

1. **Source Requirements:**
   - Must be from official distro repositories OR
   - Verified community collections with proper attribution

2. **Quality Standards:**
   - Minimum resolution: 1920x1080
   - Preferred: 2560x1440 or 3840x2160 (4K)
   - Dark-themed or suitable for dark desktops
   - Branded/distro-specific (no generic nature/abstract)

3. **File Format:**
   - PNG preferred (lossless)
   - JPG acceptable for large images
   - Keep file sizes reasonable (<20MB per image)

4. **Naming Convention:**
   ```
   <distro>-<theme>-<resolution>.<ext>

   Examples:
   kali-night-sky-1920x1080.png
   cachyos-wave2-dark-3840x2160.png
   popos-cosmic-desktop.png
   ```

### Adding New Distros

To add a new distribution:

```bash
# 1. Create directory
mkdir -p ~/kenl/modules/KENL5-facades/wallpapers/<distro-name>

# 2. Download from official source
cd ~/kenl/modules/KENL5-facades/wallpapers/<distro-name>
curl -L -o wallpaper.png "https://official-source/wallpaper.png"

# 3. Document source
echo "## <Distro Name>" >> ../SOURCES.md
echo "- **Source:** <repo-url>" >> ../SOURCES.md
echo "- **License:** <license>" >> ../SOURCES.md
echo "- **Download Date:** $(date +%Y-%m-%d)" >> ../SOURCES.md
```

---

## Performance Considerations

### File Sizes

Large wallpapers can impact:
- Login screen load times
- Memory usage (especially 16-bit color depth)
- Disk space in home directory

**Recommendations:**
- For 1080p displays: Use 1920x1080 wallpapers
- For 1440p displays: Use 2560x1440 wallpapers
- For 4K displays: Use 3840x2160 wallpapers
- Avoid loading 4K wallpapers on 1080p displays

### Optimizing Large Files

```bash
# Convert 16-bit to 8-bit (reduces file size)
convert wave2-dark.png -depth 8 wave2-dark-optimized.png

# Resize to specific resolution
convert kali-trail-3840x2160.png -resize 1920x1080 kali-trail-1920x1080.png
```

---

## Integration with Bazza-DX

This wallpaper collection is designed for the **Bazza-DX SAGE Framework**:

- **KENL2 (Gaming):** Bazzite-branded wallpapers
- **KENL3 (Development):** Pop!_OS/Fedora wallpapers
- **KENL5 (Facades):** Theme-aware wallpaper switching
- **KENL8 (Security):** Kali Linux wallpapers

See `../../README.md` for KENL module integration.

---

## Immutable System Considerations

**Bazzite/Fedora Atomic (rpm-ostree):**

Wallpapers are stored in user space (`~/.local/share/wallpapers` or module directory):
- ✅ No system modifications required
- ✅ Survives system updates/rollbacks
- ✅ Per-user customization

```bash
# Wallpapers persist across ostree deployments
rpm-ostree upgrade  # Wallpapers remain intact
```

---

## Troubleshooting

### Wallpaper Not Loading

**Issue:** Wallpaper shows as black screen or doesn't change

**Solutions:**
```bash
# 1. Check file exists and is readable
ls -lh ~/kenl/modules/KENL5-facades/wallpapers/bazzite/bazzite-1.png

# 2. Verify file is valid image
file ~/kenl/modules/KENL5-facades/wallpapers/bazzite/bazzite-1.png

# 3. Test with absolute path
gsettings set org.gnome.desktop.background picture-uri \
  "file:///home/$(whoami)/kenl/modules/KENL5-facades/wallpapers/bazzite/bazzite-1.png"

# 4. Check permissions
chmod 644 ~/kenl/modules/KENL5-facades/wallpapers/bazzite/bazzite-1.png
```

### Large File Performance

**Issue:** Desktop sluggish after setting 4K wallpaper

**Solutions:**
```bash
# Use lower resolution version
# Or optimize file size:
convert large-wallpaper.png -quality 85 -resize 1920x1080 optimized.png
```

---

## Future Plans

- [ ] Add Arch Linux official wallpapers
- [ ] Add Ubuntu branded wallpapers
- [ ] Add EndeavourOS wallpapers
- [ ] Add Nobara wallpapers
- [ ] Create KENL-branded custom wallpapers
- [ ] Implement automatic wallpaper rotation script
- [ ] Add time-of-day wallpaper switching (dark/night variants)

---

## License

This collection aggregates wallpapers from various sources:

- **Kali Linux:** GPL (official), Mixed (community)
- **Pop!_OS:** CC BY-SA 4.0
- **Fedora:** CC BY-SA 4.0
- **CachyOS:** Open source (check individual files)
- **Bazzite:** FOSS (community created)
- **Manjaro:** FOSS (Lunix/community)

See individual distribution folders and `SOURCES.md` for specific licensing.

---

## Navigation

- **← [KENL5 README](../README.md)** - Facades & Theming overview
- **← [Root README](../../../README.md)** - Full kenl repository
- **→ [SOURCES.md](SOURCES.md)** - Detailed attribution

---

**Collection curated:** November 2025
**ATOM:** ATOM-DOC-20251110-001
**Status:** Production Ready
