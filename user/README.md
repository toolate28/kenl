---
title: User Landing Directory
atom: ATOM-DOC-20251205-004
classification: USER
status: production
created: 2025-12-05
version: 1.0.0
---

# User Landing Directory

**Purpose:** Your personal workspace for project-specific files, configurations, and symlinks to local projects.

---

## 🎯 What This Directory Is For

The `user/` directory is your **personal landing zone** within KENL. Use it to:

- **Symlink local projects** - Point to projects you're actively working on
- **Store project-specific configs** - Keep Play Cards, SAIF workflows, or custom scripts
- **Maintain personal notes** - Document your specific setup or use cases
- **Quick access** - All your relevant files in one place

**Git Behavior:** By default, `user/` ignores everything except the README and example templates, so your personal files stay private.

---

## 📁 Recommended Structure

```
user/
├── README.md                    # This file
├── .gitignore                   # Ignores personal files
├── projects/                    # Symlinks to your local projects
│   ├── my-game-config -> /path/to/game-config/
│   └── my-dev-project -> /path/to/dev-project/
├── play-cards/                  # Your personal Play Cards
│   └── my-custom-game.yaml
├── scripts/                     # Personal utility scripts
│   └── my-setup.sh
└── notes/                       # Personal documentation
    └── my-setup-notes.md
```

---

## 🔗 Creating Project Symlinks

### Linux/macOS

```bash
# Navigate to user directory
cd ~/.kenl/user/projects/

# Create symlink to your project
ln -s /path/to/your/project project-name

# Verify
ls -la
```

### Windows (PowerShell - requires admin)

```powershell
# Navigate to user directory
cd $HOME\.kenl\user\projects\

# Create symlink
New-Item -ItemType SymbolicLink -Path "project-name" -Target "C:\path\to\your\project"

# Verify
Get-ChildItem
```

### Windows (PowerShell - without admin, junction)

```powershell
# Create directory junction (no admin needed)
cmd /c mklink /J "project-name" "C:\path\to\your\project"
```

---

## 📋 Example Use Cases

### Gaming Setup

```bash
user/
├── play-cards/
│   ├── battlefield-6.yaml
│   └── halo-infinite.yaml
└── notes/
    └── gaming-tweaks.md
```

### Development Environment

```bash
user/
├── projects/
│   ├── web-app -> /home/dev/projects/my-web-app/
│   └── api-service -> /home/dev/projects/api/
└── scripts/
    └── dev-env-setup.sh
```

### System Administration

```bash
user/
├── configs/
│   ├── network-monitoring.yaml
│   └── backup-schedule.yaml
└── notes/
    └── system-maintenance-log.md
```

---

## 🚫 What NOT to Put Here

- **Secrets or credentials** - Use `~/.secrets/` or environment variables
- **Large binary files** - Keep binaries in appropriate system locations
- **Generated files** - Build artifacts should stay in project directories
- **Shared configurations** - Use `modules/` for team-shared configs

---

## 🔄 Git Integration

By default, the `user/.gitignore` excludes everything except:
- `README.md`
- Example templates (if you create any)

**To share a specific file:**

```bash
# Add exception to .gitignore
echo "!my-shared-template.yaml" >> user/.gitignore

# Add and commit
git add user/my-shared-template.yaml
git commit -m "docs: add shared template to user directory"
```

---

## 🆘 Getting Help

**Note:** These paths are relative to the repository root. If you cloned KENL to `~/.kenl`, these paths will work as-is.

- **For KENL-specific questions:** See [GETTING-STARTED.md](../GETTING-STARTED.md)
- **For documentation navigation:** See [claude-landing/DOCUMENTATION-PATHWAYS.md](../claude-landing/DOCUMENTATION-PATHWAYS.md)
- **For general documentation:** See [docs/](../docs/)

---

## 📝 Notes

- This directory is **optional** - KENL works fine without it
- Symlinks are a convenience, not a requirement
- Structure is a **recommendation**, not a rule
- Make it work for **your** workflow

---

**ATOM:** ATOM-DOC-20251205-004
**Version:** 1.0.0
**Last Updated:** 2025-12-05
