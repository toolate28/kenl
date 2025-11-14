---
project: KENL SAGE Demonstration
status: active
version: 1.0.0
classification: GUIDE
atom: ATOM-GUIDE-20251114-012
last-updated: 2025-11-14
---

# SAGE Just-in-Time Documentation Walkthrough

**Purpose:** Demonstrate how SAIF (System-Aware Intelligent Framework) delivers contextual documentation exactly when needed, using Obsidian or Tangent as a visual knowledge base that mirrors KENL's SAGE methodology.

**Reference Model:** [Bazzite Documentation](https://docs.bazzite.gg/) - Clean, contextual, task-focused documentation that appears exactly when users need it.

---

## Table of Contents

1. [The SAGE Philosophy](#the-sage-philosophy)
2. [Setup: Obsidian vs Tangent](#setup-obsidian-vs-tangent)
3. [Building Your KENL Knowledge Vault](#building-your-kenl-knowledge-vault)
4. [Full Function Walkthrough](#full-function-walkthrough)
5. [SAIF Integration Points](#saif-integration-points)
6. [Comparison: Traditional Docs vs SAGE](#comparison-traditional-docs-vs-sage)

---

## The SAGE Philosophy

**SAGE = System-Aware Guided Evolution**

Traditional documentation:
- ❌ Read everything upfront (overwhelming)
- ❌ Search when stuck (reactive)
- ❌ Outdated the moment it's written

SAGE/SAIF approach:
- ✅ **Contextual:** Documentation appears based on what you're doing
- ✅ **Progressive:** Learn as you go, not all at once
- ✅ **Living:** Updates with your system state
- ✅ **Intent-Driven:** Captures *why* not just *what*

### Bazzite Docs as Reference

Bazzite documentation exemplifies just-in-time delivery:
- Task-focused landing page (what do you want to do?)
- Progressive disclosure (basics → advanced)
- Context-aware (gaming vs development vs desktop)
- Integration guides exactly when you install something

**KENL enhances this with:**
- ATOM trails (audit every change with intent)
- OWI integration (AI assistance when needed)
- Local-first (works offline, syncs optionally)
- Multi-tier privacy (public/private/confidential)

---

## Setup: Obsidian vs Tangent

### Option 1: Obsidian (Recommended for Rich Features)

**Why Obsidian:**
- Graph view shows knowledge connections
- Dataview plugin for dynamic queries
- Templates for ATOM trail entries
- Cross-platform sync (optional)
- Rich plugin ecosystem

**Installation (Flatpak on Bazzite):**

```bash
# Install Obsidian
flatpak install flathub md.obsidian.Obsidian

# Launch
flatpak run md.obsidian.Obsidian
```

**Initial Configuration:**
1. Create vault at `~/.kenl/vault` or `~/Documents/KENL-Vault`
2. Enable "Community plugins" in Settings
3. Install recommended plugins:
   - **Dataview** (dynamic content queries)
   - **Templater** (ATOM tag templates)
   - **Calendar** (timeline view)
   - **Graph Analysis** (visualize connections)
   - **Excalidraw** (diagrams)

### Option 2: Tangent (Lightweight Alternative)

**Why Tangent:**
- Lightweight and fast
- Native markdown support
- Simpler interface
- Lower resource usage

**Installation:**

```bash
# Check if Tangent is available (may vary by distro)
flatpak search tangent

# Alternative: Use Joplin (similar concept)
flatpak install flathub net.cozic.joplin_desktop
```

**Note:** Obsidian provides richer integration for this walkthrough, so examples below assume Obsidian.

---

## Building Your KENL Knowledge Vault

### Vault Structure

Mirror KENL's modular architecture:

```
KENL-Vault/
├── 00-Index/
│   ├── Dashboard.md              # Landing page (context-aware)
│   ├── Quick-Reference.md        # Common commands
│   └── Current-Context.md        # What you're working on NOW
├── 01-ATOM-Trails/
│   ├── 2025-11-14-SESSION-001.md
│   └── templates/
│       └── ATOM-Entry.md
├── 02-Modules/
│   ├── KENL0-System.md
│   ├── KENL2-Gaming.md
│   ├── KENL3-Dev.md
│   └── ... (one file per module)
├── 03-Playbooks/
│   ├── Gaming-Setup.md
│   ├── Dev-Environment.md
│   ├── Troubleshooting.md
│   └── Bazzite-Integration.md
├── 04-Resources/
│   ├── Bazzite-Docs-Index.md    # Local mirror of key Bazzite pages
│   ├── ProtonDB-Notes.md
│   └── Hardware-Configs.md
└── 05-Archives/
    └── Completed-Tasks/
```

### Template: ATOM Entry

Create `.obsidian/templates/ATOM-Entry.md`:

```markdown
---
atom: ATOM-{{type}}-{{date:YYYYMMDD}}-{{counter}}
date: {{date:YYYY-MM-DD HH:mm}}
type: [TASK|RESEARCH|CFG|DEPLOY|STATUS]
status: [pending|in-progress|completed]
---

# {{title}}

## Intent (Why)

Why are you doing this? What problem are you solving?

## Context

- **Module:** KENL{{module-number}}-{{name}}
- **Related:** [[Link to related notes]]
- **Prerequisites:**

## Actions Taken

1.
2.
3.

## Result

✅ Success / ❌ Failed / ⚠️ Partial

## Rollback Plan

If this breaks something:

```bash
# Commands to undo changes
```

## Tags

#kenl #atom-trail #{{module}}
```

### Template: Dashboard (Context-Aware Landing)

Create `00-Index/Dashboard.md`:

```markdown
---
title: KENL Dashboard
updated: {{date:YYYY-MM-DD HH:mm}}
---

# 🎮💻 KENL Dashboard

> **Current Context:** `dataview inline js dv.current().file.folder`

---

## 🎯 What Do You Want to Do?

### Gaming 🎮
- [[Gaming-Setup|Set up a new game]]
- [[Troubleshooting|Fix game crashes]]
- [[Play-Cards|Share game configs]]
- [[ProtonDB-Notes|Check compatibility]]

### Development 💻
- [[Dev-Environment|Set up dev container]]
- [[MCP-Integration|Configure Claude MCP]]
- [[Ollama-Setup|Install local AI]]
- [[PowerShell-Modules|Use KENL PowerShell]]

### System ⚙️
- [[System-Updates|Update Bazzite]]
- [[Firmware-Updates|Update firmware]]
- [[Rollback|Undo changes]]
- [[Performance|Optimize performance]]

---

## 📋 Active Tasks

```dataview
TABLE status, date
FROM "01-ATOM-Trails"
WHERE status != "completed"
SORT date DESC
LIMIT 5
```

---

## 🏷️ Recent ATOM Trails

```dataview
LIST
FROM "01-ATOM-Trails"
SORT file.ctime DESC
LIMIT 10
```

---

## 🔗 Quick Links

- [Bazzite Docs](https://docs.bazzite.gg/)
- [[Quick-Reference]] - Common commands
- [[Current-Context]] - What you're working on
- [[Troubleshooting]] - Common issues

---

## 📊 Knowledge Graph

![[graph-view]]

*Use Obsidian graph view to visualize connections between notes*
```

---

## Full Function Walkthrough

**Scenario:** You want to set up Baldur's Gate 3 on Bazzite and document the process using SAGE methodology.

### Step 1: Start with Intent

Open Obsidian → Dashboard → Click "Set up a new game"

This takes you to `03-Playbooks/Gaming-Setup.md` which provides:
- Pre-flight checklist
- Common issues to watch for
- Template for documenting your setup

### Step 2: Create ATOM Trail Entry

Create new note from template: `01-ATOM-Trails/2025-11-14-BG3-Setup.md`

```markdown
---
atom: ATOM-GAMING-20251114-001
date: 2025-11-14 14:30
type: TASK
status: in-progress
---

# Baldur's Gate 3 Setup on Bazzite

## Intent (Why)

Setting up BG3 on Bazzite to test DirectX 11 performance with GE-Proton.
Want to document config for sharing with friends.

## Context

- **Module:** KENL2-Gaming
- **Hardware:** AMD Ryzen 5 5600H + Vega Graphics
- **Related:** [[ProtonDB-Notes#Baldur's Gate 3]]
- **Prerequisites:** Steam installed, GE-Proton available

## Research Phase

**ProtonDB Status:** Platinum (15,234 reports)
**Recommended:** GE-Proton 9-15 or newer
**Known Issues:** None for AMD

**Bazzite-Specific Notes:**
- Check [Bazzite Gaming Guide](https://docs.bazzite.gg/Gaming/)
- MangoHud enabled by default
- GameScope available via Steam properties

## Actions Taken

1. Install BG3 via Steam
2. Enable GE-Proton 9-20 in compatibility settings
3. Add launch options: `PROTON_ENABLE_NVAPI=1 %command%`
4. Test launch

## Result

✅ Game launches successfully
⚠️ Initial shader compilation takes 5 minutes
✅ 60 FPS @ 1080p Medium settings

## Rollback Plan

If performance degrades:
```bash
# Revert to Proton Experimental
# Steam → Game Properties → Compatibility → Proton Experimental
```

## Play Card Created

See [[Play-Cards/BG3-AMD-Vega.yaml]]

## Tags

#kenl2-gaming #atom-gaming #baldurs-gate-3 #proton #amd
```

### Step 3: Just-in-Time Bazzite Docs

While setting up, you encounter shader compilation delay. SAGE methodology:

**Traditional approach:**
1. Google "bazzite shader cache"
2. Read 5 articles
3. Still not sure if it's normal

**SAGE approach:**
Your `Troubleshooting.md` note auto-links to relevant Bazzite docs:

```markdown
## Shader Compilation Delays

This is **normal behavior** on first launch. Bazzite pre-compiles shaders.

**From [Bazzite Gaming Guide](https://docs.bazzite.gg/Gaming/Steam_Gaming_Mode/):**

> Shader pre-caching improves performance after initial compilation.
> Expected duration: 3-10 minutes depending on game size.

**KENL Enhancement:**
- ATOM trail captures this as expected behavior
- Next time you see shader compilation: check ATOM history
- Share Play Card with friends: they expect delay too

**Monitor progress:**
```bash
# Watch shader cache growth
watch -n 1 du -sh ~/.local/share/Steam/steamapps/shadercache/
```

## Step 4: Create Shareable Play Card

Generate YAML config for sharing:

`modules/KENL2-gaming/play-cards/games/baldurs-gate-3.yaml`:

```yaml
---
game:
  name: "Baldur's Gate 3"
  steam_id: 1086940
  protondb_rating: "Platinum"

hardware:
  cpu: "AMD Ryzen 5 5600H"
  gpu: "Vega Graphics (iGPU)"
  ram: "16GB DDR4"

configuration:
  proton_version: "GE-Proton 9-20"
  launch_options: "PROTON_ENABLE_NVAPI=1 %command%"
  game_mode: true
  mangohud: true

performance:
  resolution: "1920x1080"
  settings: "Medium"
  fps_average: 60
  shader_compile_time: "~5 minutes"

notes: |
  Shader compilation on first launch is normal (3-10 min).
  Performance is excellent on AMD iGPU.
  No tweaks needed beyond GE-Proton.

atom_trail: ATOM-GAMING-20251114-001
tested_date: 2025-11-14
bazzite_version: "41 (2025-11-12)"
```

### Step 5: Update Dashboard

Your dashboard now shows:

```markdown
## 📋 Active Tasks

- ✅ ATOM-GAMING-20251114-001: Baldur's Gate 3 Setup (completed)

## 🏷️ Recent ATOM Trails

- [[2025-11-14-BG3-Setup]]
- Connection to [[ProtonDB-Notes]]
- Connection to [[Play-Cards/BG3-AMD-Vega.yaml]]

## 🎮 Gaming Playbook Updated

New entry: Baldur's Gate 3 now documented with:
- Hardware specs
- Expected shader compilation delay
- Performance metrics
- Shareable Play Card
```

---

## SAIF Integration Points

### 1. Context Detection

**How SAGE knows what you need:**

```markdown
<!-- In Dashboard.md -->
```dataview
TABLE file.ctime as "Started", status
FROM "01-ATOM-Trails"
WHERE status = "in-progress"
```

This shows active tasks. When you open dashboard:
- See what you were working on last
- Jump directly to in-progress ATOM trails
- No searching, no guessing

### 2. Progressive Disclosure

**Information appears as you need it:**

1. **Starting:** Simple dashboard with "What do you want to do?"
2. **During setup:** Playbook with step-by-step guidance
3. **Troubleshooting:** Detailed notes + Bazzite doc links
4. **Sharing:** Play Card export for community

### 3. Bazzite Docs Integration

Create `04-Resources/Bazzite-Docs-Index.md`:

```markdown
# Bazzite Documentation Quick Reference

## Gaming
- [Steam Gaming Mode](https://docs.bazzite.gg/Gaming/Steam_Gaming_Mode/)
- [Windows Games (Proton)](https://docs.bazzite.gg/Gaming/Windows_games/)
- [Game Launchers](https://docs.bazzite.gg/Gaming/Game_Launchers/)

## System
- [Installing Software](https://docs.bazzite.gg/Installing_and_Managing_Software/)
- [Updates & Rollback](https://docs.bazzite.gg/Installing_and_Managing_Software/Updates_Rollbacks_Rebasing/)
- [Handheld-Specific](https://docs.bazzite.gg/Handheld/)

## KENL Enhancements

**What KENL adds to Bazzite docs:**

| Bazzite Docs | KENL Enhancement |
|--------------|------------------|
| How to install games | Why this config works (ATOM intent) |
| Proton compatibility | Hardware-specific perf data (Play Cards) |
| General troubleshooting | Your specific hardware history (ATOM trails) |
| One-size-fits-all | Your exact config (shareable YAML) |

**Example:**

Bazzite docs say: "Use GE-Proton for best compatibility"

KENL adds:
```yaml
# From YOUR Play Card
proton_version: "GE-Proton 9-20"  # Tested on your hardware
performance:
  fps_average: 60                 # YOUR results
  shader_compile_time: "~5 min"   # Set expectations
notes: "AMD iGPU works great"     # YOUR experience
```
```

### 4. ATOM Trail Timeline

**Obsidian Calendar Plugin:** Visualize your KENL journey

- Each ATOM trail appears on calendar
- Click date → see what you did that day
- Hover → preview note without opening
- Tag filtering: show only gaming, only dev, etc.

### 5. Graph View: Knowledge Connections

**Obsidian Graph View shows:**

```
[Dashboard] ──┬── [Gaming-Setup] ── [BG3-Setup]
              │                         │
              │                         ├── [ProtonDB-Notes]
              │                         ├── [Play-Card: BG3]
              │                         └── [Troubleshooting]
              │
              ├── [Dev-Environment] ── [MCP-Integration]
              │                            │
              │                            └── [Bazzite-Docs-Index]
              │
              └── [System-Updates] ── [ATOM-DEPLOY-...]
```

**This visualizes:**
- How gaming knowledge connects to troubleshooting
- Which Bazzite docs you reference most
- Evolution of your config over time

---

## Comparison: Traditional Docs vs SAGE

### Scenario: Setting Up New Game

#### Traditional Documentation Approach

```
User journey:
1. Google "how to install games on bazzite"
2. Find Bazzite docs (generic instructions)
3. Game doesn't launch
4. Google "proton compatibility"
5. Find ProtonDB
6. Try 3 different Proton versions
7. Finally works (but why?)
8. Next month: forgot which version worked
9. Repeat entire process

Documentation state:
- Static Bazzite docs (helpful but generic)
- ProtonDB reports (mixed hardware configs)
- No record of what YOU did
- Can't share YOUR config easily
```

#### SAGE/KENL Approach

```
User journey:
1. Open KENL Dashboard
2. Click "Set up a new game"
3. Create ATOM trail (captures intent)
4. Check Play Cards for similar hardware
5. Apply recommended config
6. Document results in ATOM trail
7. Export Play Card for sharing

Next time:
1. Open Dashboard
2. See previous ATOM trail
3. Apply same config (2 minutes vs 2 hours)

Documentation state:
- Living ATOM trails (YOUR history)
- Hardware-specific Play Cards (YOUR config)
- Bazzite docs integrated (when needed)
- Shareable with friends (exact config)
```

### Table: Feature Comparison

| Feature | Traditional Docs | Bazzite Docs | KENL + SAGE |
|---------|------------------|--------------|-------------|
| **Searchable** | ✅ | ✅ | ✅ |
| **Up-to-date** | ⚠️ Often stale | ✅ | ✅ |
| **Context-aware** | ❌ | ⚠️ Partial | ✅ |
| **Hardware-specific** | ❌ | ❌ | ✅ |
| **Captures intent** | ❌ | ❌ | ✅ |
| **Audit trail** | ❌ | ❌ | ✅ |
| **Shareable configs** | ❌ | ❌ | ✅ |
| **Works offline** | ❌ | ❌ | ✅ |
| **Rollback instructions** | ⚠️ Sometimes | ✅ | ✅ |
| **Your config history** | ❌ | ❌ | ✅ |

---

## Advanced: MCP Integration (Future)

**Model Context Protocol integration allows:**

### Claude Desktop + KENL Vault

```javascript
// MCP server provides Obsidian vault access
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  switch (request.params.name) {
    case "search-vault":
      // Claude can search your KENL vault
      return searchObsidianVault(query);

    case "create-atom-trail":
      // Claude generates ATOM entry from conversation
      return createAtomEntry(intent, context, actions);

    case "update-play-card":
      // Claude updates Play Card with new data
      return updatePlayCard(game, hardware, results);

    case "get-context":
      // Claude reads Current-Context.md for awareness
      return getCurrentContext();
  }
});
```

### Example Flow

**You:** "Claude, I'm having shader compilation issues with Elden Ring"

**Claude (via MCP):**
1. Searches your vault: `search-vault("elden ring shader")`
2. Finds ATOM trail: `ATOM-GAMING-20251110-003` (you fixed this before)
3. Reads solution from YOUR notes
4. Responds: "You encountered this 4 days ago. Here's what worked..."

**Result:** Claude has access to YOUR documented solutions, not just generic web data.

---

## Practical Exercises

### Exercise 1: Setup Your Vault (15 minutes)

```bash
# 1. Install Obsidian
flatpak install flathub md.obsidian.Obsidian

# 2. Create vault structure
mkdir -p ~/.kenl/vault/{00-Index,01-ATOM-Trails,02-Modules,03-Playbooks,04-Resources,05-Archives}

# 3. Copy KENL templates
cp ~/kenl/modules/KENL7-learning/guides/obsidian-templates/* ~/.kenl/vault/.obsidian/templates/

# 4. Launch Obsidian and open vault at ~/.kenl/vault
flatpak run md.obsidian.Obsidian
```

### Exercise 2: Document a Game Setup (30 minutes)

Pick any game you've already set up:

1. Create ATOM trail entry using template
2. Document hardware, Proton version, launch options
3. Note any issues you encountered
4. Export as Play Card YAML
5. Link from Dashboard

### Exercise 3: Integrate Bazzite Docs (10 minutes)

1. Browse [docs.bazzite.gg](https://docs.bazzite.gg/)
2. For each page you reference, create note in `04-Resources/`
3. Add your commentary: "This applies to my setup because..."
4. Link from relevant ATOM trails

### Exercise 4: Visualize Connections (5 minutes)

1. Open Obsidian Graph View (Ctrl+G / Cmd+G)
2. Color nodes by folder (Settings → Graph View → Groups)
3. Filter by tag: `#kenl2-gaming`
4. Explore connections between your notes

---

## Validation: SAGE Working Correctly

**You'll know SAGE is working when:**

✅ **Opening Obsidian = Instant context**
- Dashboard shows active tasks
- Current-Context is immediately visible
- No "where was I?" confusion

✅ **Troubleshooting takes minutes, not hours**
- Search vault for error message
- Find previous solution in ATOM trails
- Apply fix (documented last time)

✅ **Sharing configs is trivial**
- Export Play Card YAML
- Friend copies to their KENL install
- Works immediately (same hardware config)

✅ **Bazzite docs integrated, not isolated**
- Obsidian notes link to Bazzite docs
- Your experience annotates their docs
- Best of both worlds

✅ **Offline capability**
- Vault works without internet
- ATOM trails are local-first
- Sync optional (Git, Obsidian Sync, etc.)

---

## Next Steps

1. **Set up vault** (Exercise 1)
2. **Document one task** with ATOM trail (Exercise 2)
3. **Install Dataview plugin** for dynamic queries
4. **Create Dashboard** with current context
5. **Link Bazzite docs** you reference frequently

**Advanced:**
- Set up Git sync for vault backup
- Create custom Dataview queries for gaming stats
- Build Play Card library for your hardware
- Integrate with Claude Desktop via MCP (future)

---

## Resources

- [Obsidian Documentation](https://help.obsidian.md/)
- [Bazzite Documentation](https://docs.bazzite.gg/)
- [Dataview Plugin Guide](https://blacksmithgu.github.io/obsidian-dataview/)
- [KENL ATOM Framework](../../KENL1-framework/README.md)
- [KENL Play Cards](../../KENL2-gaming/play-cards/)

---

## Troubleshooting

### Obsidian Won't Launch (Flatpak)

```bash
# Check Flatpak permissions
flatpak info md.obsidian.Obsidian

# Grant filesystem access if needed
flatpak override md.obsidian.Obsidian --filesystem=home

# Run from terminal to see errors
flatpak run md.obsidian.Obsidian
```

### Plugins Not Loading

1. Settings → Community plugins → Turn on
2. Browse → Search for plugin
3. Install → Enable
4. Restart Obsidian

### Graph View Empty

- Ensure notes have links: `[[Other Note]]`
- Use tags: `#kenl2-gaming`
- Check graph view filters (all enabled)

---

**ATOM Tag:** ATOM-GUIDE-20251114-012

**Last Updated:** 2025-11-14

**Maintained By:** toolate28 / KENL Project
