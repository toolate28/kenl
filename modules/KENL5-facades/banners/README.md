# modules/KENL Banners

Branded ASCII art banners for modules/KENL profiles, dotfiles, shells, and themes.

## Available Banners

### 1. Full Banner (`kenl-banner-full.txt`)
Complete modules/KENL branding with all 12 kennels displayed.

**Best for:**
- Desktop terminals with 80+ columns
- System login screens
- Project README headers

**Size:** 80 columns × 19 lines

### 2. Kennels Banner (`kenl-banner-kennels.txt`)
Multi-kennel layout showing all modules/KENL modules as dog kennels with ASCII art.

**Best for:**
- Visual representation of modules/KENL architecture
- Welcome screens
- Documentation

**Size:** 80 columns × 28 lines

### 3. Compact Banner (`kenl-banner-compact.txt`)
Smaller, terminal-friendly version suitable for most shells.

**Best for:**
- Daily shell use
- Smaller terminals (70+ columns)
- SSH sessions

**Size:** 64 columns × 8 lines

### 4. Single Kennel Banner (`kenl-banner-single.txt`)
Focused single kennel design with modules/KENL branding.

**Best for:**
- Emphasizing modules/KENL as a unified system
- modules/KENL philosophy documentation
- Single-purpose contexts

**Size:** 80 columns × 24 lines

### 5. Minimal Banner (`kenl-banner-minimal.txt`)
Tiny banner for space-constrained environments.

**Best for:**
- Prompts (PS1)
- Embedded systems
- Status lines
- Minimal shells

**Size:** 46 columns × 5 lines

### 6. Context-Aware Banner (`kenl-banner-context.sh`)
Dynamic banner that displays current modules/KENL context with appropriate colors and icons.

**Best for:**
- Development workflows
- When switching between modules/KENLs frequently
- Learning/exploring the modules/KENL system

**Features:**
- Color-coded by modules/KENL module
- Shows current context icon
- Displays available commands
- Updates based on `~/.kenl/current-context`

### 7. Context-Sync Memory Kennel Banner (`kenl-banner-context-sync.txt`)
Special banner for context-sync module showcasing the dog kennel → memory metaphor.

**Best for:**
- KENL3-dev context-sync module documentation
- Demonstrating persistent AI memory concept
- Introducing the "memory kennel" philosophy

**Features:**
- Dog kennel visual with memory icons 🐕💾
- Shows integration components (CLI, Code, D1, ATOM)
- Emphasizes "safe home for AI decisions"

**Size:** 80 columns × 21 lines

## Installation

### Quick Install

```bash
cd ~/kenl/KENL5-facades/banners
./install-banner.sh
```

Interactive menu will guide you through banner selection and shell integration.

### Manual Installation

**For Bash:**
```bash
echo 'cat ~/kenl/KENL5-facades/banners/kenl-banner-compact.txt' >> ~/.bashrc
source ~/.bashrc
```

**For Zsh:**
```bash
echo 'cat ~/kenl/KENL5-facades/banners/kenl-banner-compact.txt' >> ~/.zshrc
source ~/.zshrc
```

**For Tmux:**
```bash
echo "set-hook -g after-new-session 'run-shell ~/kenl/KENL5-facades/banners/kenl-banner-context.sh'" >> ~/.tmux.conf
tmux source-file ~/.tmux.conf
```

**Context-aware (recommended for modules/KENL developers):**
```bash
# Add to shell config
echo '~/kenl/KENL5-facades/banners/kenl-banner-context.sh' >> ~/.bashrc

# Set context when switching modules/KENLs
mkdir -p ~/.kenl
echo '2' > ~/.kenl/current-context  # For modules/KENL2-gaming
```

## Integration with switch-kenl.sh

To automatically update the context banner when switching modules/KENLs:

```bash
# In modules/KENL1-sanctuary/switch-kenl.sh, add:
mkdir -p ~/.kenl
echo "$KENL_NUM" > ~/.kenl/current-context

# Banner will auto-update on next shell launch
```

## modules/KENL Context Colors

Each modules/KENL has a designated color scheme:

| modules/KENL | Name           | Icon | Color        |
|------|----------------|------|--------------|
| 0    | ATOM Trail     | 📝   | Orange       |
| 1    | Sanctuary      | 🏠   | Blue         |
| 2    | Gaming         | 🎮   | Magenta      |
| 3    | Development    | 💻   | Green        |
| 4    | Monitoring     | 📊   | Yellow       |
| 5    | Facades        | 🎨   | Purple       |
| 6    | Isolation      | 🔒   | Red          |
| 7    | Learning       | 📚   | Cyan         |
| 8    | Crypto         | 🔐   | Gold         |
| 9    | Networking     | 🌐   | Deep Blue    |
| 10   | Infrastructure | 🏗️  | Orange-Yellow|
| 11   | Media          | 📺   | Pink         |
| 12   | Resources      | 📦   | Cyan         |

## Usage Examples

### Shell Login Banner
```bash
# ~/.bashrc or ~/.zshrc
if [ -t 0 ] && [ -z "$KENL_BANNER_SHOWN" ]; then
    export modules/KENL_BANNER_SHOWN=1
    ~/kenl/KENL5-facades/banners/kenl-banner-context.sh
fi
```

### Tmux Session Banner
```bash
# ~/.tmux.conf
set-hook -g after-new-session 'run-shell ~/kenl/KENL5-facades/banners/kenl-banner-context.sh'
```

### MOTD (Message of the Day)
```bash
# /etc/motd (requires root)
sudo cp ~/kenl/KENL5-facades/banners/kenl-banner-compact.txt /etc/motd
```

### VS Code Terminal
```json
// settings.json
"terminal.integrated.shellArgs.linux": [
    "-c",
    "cat ~/kenl/KENL5-facades/banners/kenl-banner-minimal.txt && exec bash"
]
```

## Customization

### Create Custom Banner

Copy and modify any banner:
```bash
cp kenl-banner-compact.txt kenl-banner-custom.txt
nano kenl-banner-custom.txt
```

Then reference in shell config:
```bash
cat ~/kenl/KENL5-facades/banners/kenl-banner-custom.txt
```

### Conditional Display

Only show banner on first shell (not nested):
```bash
if [ "$SHLVL" -eq 1 ] && [ -z "$KENL_BANNER_SHOWN" ]; then
    export modules/KENL_BANNER_SHOWN=1
    cat ~/kenl/KENL5-facades/banners/kenl-banner-compact.txt
fi
```

Only show on specific hosts:
```bash
if [ "$HOSTNAME" = "bazzite-gaming" ]; then
    cat ~/kenl/KENL5-facades/banners/kenl-banner-full.txt
fi
```

## Technical Details

### ASCII Art Format
- Uses UTF-8 box-drawing characters
- ANSI escape codes for colors (context-aware only)
- Compatible with most modern terminals

### Performance
- Static banners: Instant (simple file read)
- Context-aware: ~10ms (bash script execution)

### Dependencies
- bash (for context-aware banner)
- ANSI color support (for context-aware banner)
- No external dependencies for static banners

## Troubleshooting

**Banner doesn't show colors:**
```bash
# Ensure terminal supports 256 colors
echo $TERM  # Should be xterm-256color or similar
export TERM=xterm-256color
```

**Banner shows on every nested shell:**
```bash
# Add to shell config:
if [ -z "$KENL_BANNER_SHOWN" ]; then
    export modules/KENL_BANNER_SHOWN=1
    # ... banner command
fi
```

**Banner breaks terminal width:**
- Use compact or minimal version
- Or check terminal columns: `echo $COLUMNS`

**Context banner shows wrong modules/KENL:**
```bash
# Check context file
cat ~/.kenl/current-context

# Update manually
echo '3' > ~/.kenl/current-context  # For modules/KENL3-dev
```

## Integration with modules/KENL5 Theming

These banners complement other modules/KENL5 facades:

- **Cheatsheets** (`KENL5-facades/cheatsheets/`): Terminal background images
- **Themes** (`KENL5-facades/themes/`): Color schemes and profiles
- **ASCII Art** (`KENL5-facades/ascii-art/`): Additional modules/KENL artwork

For complete theming, combine banner with matching terminal theme.

## Contributing

Found a cool banner design? Add it!

1. Create new banner file: `kenl-banner-yourname.txt`
2. Add entry to this README
3. Submit PR

**Guidelines:**
- Keep width ≤ 80 columns (or note wider width)
- Use UTF-8 box-drawing characters
- Include dog kennel motif 🏠🐕
- Test in multiple terminals (Konsole, GNOME Terminal, Alacritty)

---

**Part of:** modules/KENL5-facades (Visual theming layer)
**Status:** Active
**Maintained by:** modules/KENL Builders 🏠
