---
title: KENL Dashboard
type: dashboard
updated: {{date:YYYY-MM-DD HH:mm}}
---

# 🎮💻 KENL Dashboard

> **System:** Bazzite {{bazzite-version}} | **Last Active:** {{date:YYYY-MM-DD}}

---

## 🎯 What Do You Want to Do?

### Gaming 🎮
- [[Gaming-Setup|Set up a new game]]
- [[Troubleshooting|Fix game crashes]]
- [[Play-Cards-Index|Browse Play Cards]]
- [[ProtonDB-Notes|Check compatibility]]
- [[Performance-Tuning|Optimize performance]]

### Development 💻
- [[Dev-Environment|Set up dev container]]
- [[MCP-Integration|Configure Claude MCP]]
- [[Ollama-Setup|Install local AI (Qwen)]]
- [[PowerShell-Modules|Use KENL PowerShell]]
- [[Git-Workflow|Git commands]]

### System ⚙️
- [[System-Updates|Update Bazzite]]
- [[Firmware-Updates|Update firmware]]
- [[Rollback-Guide|Undo changes (rpm-ostree)]]
- [[Distrobox-Setup|Manage containers]]
- [[Backup-Restore|Backup strategy]]

### Learning 📚
- [[Bazzite-Docs-Index|Bazzite documentation]]
- [[KENL-Modules-Overview|KENL modules guide]]
- [[ATOM-Trail-Guide|ATOM methodology]]
- [[Play-Card-Guide|Play Card creation]]

---

## 📋 Active Tasks

```dataview
TABLE status, date, module
FROM "01-ATOM-Trails"
WHERE status != "completed"
SORT date DESC
LIMIT 10
```

*No active tasks? [[ATOM-Entry|Create new task]]*

---

## 🏷️ Recent ATOM Trails

```dataview
LIST
FROM "01-ATOM-Trails"
SORT file.ctime DESC
LIMIT 15
```

---

## 🎮 Gaming Stats

```dataview
TABLE
  hardware as "Hardware",
  performance.fps_average as "FPS",
  configuration.proton_version as "Proton"
FROM "02-Modules/Play-Cards"
WHERE type = "game-config"
SORT file.ctime DESC
LIMIT 5
```

---

## 🔗 Quick Links

### External
- [Bazzite Docs](https://docs.bazzite.gg/)
- [ProtonDB](https://www.protondb.com/)
- [KENL GitHub](https://github.com/toolate28/kenl)

### Internal
- [[Quick-Reference]] - Common commands
- [[Current-Context]] - What you're working on
- [[Hardware-Config]] - Your system specs
- [[Troubleshooting]] - Common issues

---

## 📊 Knowledge Graph

*Press `Ctrl+G` (or `Cmd+G` on macOS) to open graph view*

### Recent Connections
- Gaming → [[Gaming-Setup]] → [[ATOM trails]]
- Development → [[Dev-Environment]] → [[MCP-Integration]]
- System → [[System-Updates]] → [[Rollback-Guide]]

---

## 🛠️ System Health

**Last System Update:** [[System-Updates|Check updates]]

**Disk Usage:**
```bash
# Run in terminal
df -h / /home
```

**ATOM Trail Integrity:**
```dataview
LIST
WHERE contains(file.path, "ATOM-Trails") AND !contains(tags, "#verified")
LIMIT 3
```

---

## 📝 Quick Notes

*Capture quick thoughts here, organize later:*

-

---

*Dashboard auto-updates when you create new ATOM trails or Play Cards*
