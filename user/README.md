---
title: User Landing Directory
atom: ATOM-DOC-20251205-008
classification: USER
status: production
created: 2025-12-05
updated: 2025-12-05
version: 1.1.0
---

# 👤 User Landing Directory

> **Your Personal Workspace** — Project files, configs, and symlinks that stay private by default

---

## 🎯 What This Directory Is For

The `user/` directory is your **personal command center** within KENL. Use it to:

| Feature                                  | Benefit                                         |
|------------------------------------------|-------------------------------------------------|
|    **Store project-specific configs**    | Keep Play Cards, SAIF workflows, custom scripts |
|    **Symlink local projects**            | Point to projects you're actively working on    |
|     **Maintain personal notes**          | Document your specific setup or use cases       |
|     **Quick access**                     | All your relevant files in one place            |

<table>
<tr>
<td>

### 🔒 Privacy First

Everything in `user/` is **gitignored by default** except:
- ✅ This README
- ✅ Example templates (optional)

Your personal files stay **local and private** 🛡️

</td>
</tr>
</table>

---

## 📁 Directory Layout

```ascii
user/                                    ← Your personal workspace
│
├── 📄 README.md                         ← You are here!
├── 🚫 .gitignore                        ← Keeps your files private
│
├── 🔗 projects/                         ← Symlinks to local projects
│   ├── my-game-config → /path/to/game-config/
│   └── my-dev-project → /path/to/dev-project/
│
├── 🎮 play-cards/                       ← Your personal Play Cards
│   └── battlefield-custom.yaml
│
├── 🔧 scripts/                          ← Personal utility scripts  
│   ├── my-setup.sh
│   └── backup-configs.sh
│
├── 📝 notes/                            ← Personal documentation
│   ├── my-setup-notes.md
│   └── troubleshooting-log.md
│
└── ⚙️ configs/                          ← Custom configurations
    └── custom-saif-workflow.yaml
```

---

## 🔗 Creating Project Symlinks

<table>
<tr>
<td width="33%">

### 🐧 Linux/macOS

```bash
# Navigate to user directory
cd ~/.kenl/user/projects/

# Create symlink to your project
ln -s /path/to/your/project project-name

# Verify
ls -la
```

</td>
<td width="33%">

### 🪟 Windows (with admin)

```powershell
# Navigate to user directory
cd $HOME\.kenl\user\projects\

# Create symlink
New-Item -ItemType SymbolicLink -Path "project-name" -Target "C:\path\to\your\project"

# Verify
Get-ChildItem
```

</td>
<td width="33%">

### 🪟 Windows (no admin)

```powershell
# Create directory junction (no admin needed)
cmd /c mklink /J "project-name" "C:\path\to\your\project"
```

</td>
</tr>
</table>

---

## 📋 Example Workflows

<table>
<tr>
<td width="33%">

### 🎮 Gaming Setup

```ascii
user/
├── play-cards/
│   ├── bf6.yaml
│   └── halo.yaml
└── notes/
    └── tweaks.md
```

**Use case:** Track game configs and optimization notes

</td>
<td width="33%">

### 💻 Development

```ascii
user/
├── projects/
│   ├── web-app/
│   └── api/
└── scripts/
    └── setup.sh
```

**Use case:** Quick access to active projects

</td>
<td width="33%">

### ⚙️ System Admin

```ascii
user/
├── configs/
│   └── backup.yaml
└── notes/
    └── maint-log.md
```

**Use case:** Track system configurations

</td>
</tr>
</table>

---

## 🚫 What NOT to Put Here

<table>
<tr>
<td>

| ❌ Don't Store        | ✅ Store Instead                   |
|-----------------------|-------------------------------------|
| Large binary files    | System locations (`/usr/local/bin`) |
| Secrets/credentials   | `~/.secrets/` or env variables      |
| Generated/build files | Project directories                 |
| Team-shared configs   | `modules/` directory                |

</td>
</tr>
</table>

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

## 💡 Pro Tips

> **🔧 Optional Directory** — KENL works perfectly fine without customizing this space

> **🔗 Symlinks are convenient** — But not required! Use whatever workflow suits you

> **📐 Flexible Structure** — These are recommendations, not requirements. Adapt to your needs!

> **🎯 Make it yours** — This is YOUR workspace. Organize it however works best for you!

---

<div align="center">

**🏷️ ATOM:** `ATOM-DOC-20251205-008` | **📊 Version:** `1.1.0` | **📅 Updated:** `2025-12-05`

---

**[⬆️ Back to Top](#-user-landing-directory)** | **[🏠 Back to Root](../README.md)** | **[📚 View Docs](../docs/)**

</div>
