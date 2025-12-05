---
title: Deprecated Modules Archive
date: 2025-12-05
atom: ATOM-DOC-20251205-006
classification: ARCHIVE
---

# Deprecated Modules Archive

**Date Archived:** 2025-12-05  
**Reason:** Module consolidation (14 → 8 modules)

---

## What Happened

KENL modules were consolidated from **14 modules to 8 core modules** to reduce complexity and improve maintainability. Smaller, overlapping modules were merged into larger, cohesive units.

---

## Module Consolidation Mapping

### New KENL5: System Tools
**Merged from:**
- `KENL5-facades/` → `KENL5-system-tools/theming/`
- `KENL8-security/` → `KENL5-system-tools/security/`
- `KENL10-backup/` → `KENL5-system-tools/backup/`

**Rationale:** System-level utilities (backup, security, theming) belong together as they all operate in user-space and share common patterns.

**New location:** `modules/KENL5-system-tools/`

---

### New KENL6: Library & Content Management
**Merged from:**
- `KENL9-library/` → `KENL6-library/game-library/`
- `KENL11-media/` → `KENL6-library/media-server/`
- `KENL12-resources/` → `KENL6-library/resources/`

**Rationale:** All content/resource management (games, media, community resources) belongs together as they share common patterns for storage optimization and content delivery.

**New location:** `modules/KENL6-library/`

---

### Archived (Minimal Content)
- `KENL6-social/` → Archived (only 3 files, functionality absorbed into KENL7-learning)

---

### Renumbered
- `KENL13-iwi/` → `KENL8-iwi/` (renumbered to fill gap)

---

## Final Module Structure (8 modules)

| Module | Name | Purpose | Files |
|--------|------|---------|-------|
| **KENL0** | System | System operations, PowerShell modules | 43 |
| **KENL1** | Framework | ATOM + SAGE core | 52 |
| **KENL2** | Gaming | Play Cards, Proton configs | 44 |
| **KENL3** | Dev | Distrobox, Claude Code, Ollama/Qwen, MCP | 22 |
| **KENL4** | Monitoring | Prometheus, Grafana, ATOM DB | 13 |
| **KENL5** | System Tools | Backup + Security + Theming | 63 |
| **KENL6** | Library | Game Library + Media Server + Resources | 13 |
| **KENL7** | Learning | Guides, tutorials, community | 13 |
| **KENL8** | IWI | Installing With Intent framework | 5 |

**Total:** 9 modules (including KENL0)

---

## Accessing Old Content

**All content is preserved** in the new consolidated modules. If you need to reference old paths:

### Old Path → New Path Examples

```bash
# Backup
~/kenl/modules/KENL10-backup/atom-snapshot.sh
→ ~/kenl/modules/KENL5-system-tools/backup/atom-snapshot.sh

# Security
~/kenl/modules/KENL8-security/gpg-keyring/
→ ~/kenl/modules/KENL5-system-tools/security/gpg-keyring/

# Theming
~/kenl/modules/KENL5-facades/switch-kenl.sh
→ ~/kenl/modules/KENL5-system-tools/theming/switch-kenl.sh

# Game Library
~/kenl/modules/KENL9-library/
→ ~/kenl/modules/KENL6-library/game-library/

# Media Server
~/kenl/modules/KENL11-media/docker-compose/
→ ~/kenl/modules/KENL6-library/media-server/docker-compose/

# Resources
~/kenl/modules/KENL12-resources/downloads/
→ ~/kenl/modules/KENL6-library/resources/downloads/

# IWI
~/kenl/modules/KENL13-iwi/
→ ~/kenl/modules/KENL8-iwi/
```

---

## Why This Change?

### Problems with 14 Modules

1. **Fragmentation:** Small modules (3-8 files) harder to discover
2. **Overlap:** Similar functionality spread across modules
3. **Confusion:** Users unsure which module to use
4. **Maintenance:** More directories to update and test

### Benefits of 8 Modules

1. **Clarity:** Related functionality grouped together
2. **Discoverability:** Easier to find what you need
3. **Consistency:** Single entry point for related tasks
4. **Maintainability:** Fewer directories to manage

---

## Rollback (If Needed)

**To restore old structure:**

```bash
# Copy archived modules back to modules/
cd ~/.kenl
cp -r .archive/modules-deprecated/KENL5-facades modules/
cp -r .archive/modules-deprecated/KENL8-security modules/
cp -r .archive/modules-deprecated/KENL9-library modules/
cp -r .archive/modules-deprecated/KENL10-backup modules/
cp -r .archive/modules-deprecated/KENL11-media modules/
cp -r .archive/modules-deprecated/KENL12-resources modules/
cp -r .archive/modules-deprecated/KENL6-social modules/

# Rename KENL8-iwi back to KENL13-iwi
mv modules/KENL8-iwi modules/KENL13-iwi

# Remove consolidated modules
rm -rf modules/KENL5-system-tools
rm -rf modules/KENL6-library
```

**Note:** Not recommended. New structure is superior for maintainability.

---

## Migration Timeline

- **2025-12-05:** Modules consolidated, old modules archived
- **v2.0.0 → v2.9.9:** Both old and new paths work (compatibility)
- **v3.0.0:** Archived modules removed from repository

**Current version:** v2.0.0 (both paths work)

---

**ATOM:** ATOM-DOC-20251205-006  
**Date:** 2025-12-05
