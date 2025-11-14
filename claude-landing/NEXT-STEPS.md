---
title: KENL Project - Next Steps
date: 2025-11-15
atom: ATOM-DOC-20251115-003
status: active
---

# Next Steps - Actionable Priorities

**Last Updated:** 2025-11-15
**ATOM Tag:** ATOM-DOC-20251115-003
**Current Phase:** Windows Pre-Migration Testing

---

## Immediate Actions (Today)

### 1. Documentation Consistency ✅ (In Progress)

**Status:** Currently being updated by Claude Code

**Actions:**
- ✅ Audit claude-landing/ documentation
- ✅ Update CURRENT-STATE.md with latest commits
- ✅ Create OBSIDIAN-QUICK-START.md (local walkthrough)
- ⏳ Create this NEXT-STEPS.md
- 🔜 Update RECENT-WORK.md (remove "missing docs" claims)
- 🔜 Verify cross-references between all docs

**Why:** Ensure new AI instances get accurate orientation context

---

## Short-Term (This Week)

### 2. Bazzite ISO Download & Verification

**Status:** ⏳ In Progress

**Current State:**
- Script: `scripts/Install-Bazzite.ps1` (version-agnostic, parameterized)
- Target: Ventoy USB (28GB, ready)
- Variant: Bazzite KDE stable

**Actions:**
```powershell
# 1. Review download script
Get-Help .\scripts\Install-Bazzite.ps1 -Full

# 2. Run ISO download (if not already running)
.\scripts\Install-Bazzite.ps1 -Variant kde -Edition stable

# 3. Verify SHA256 hash after download
$IsoPath = "F:\bazzite-kde-stable.iso"
$ExpectedHash = "PASTE_FROM_GITHUB_RELEASE"
(Get-FileHash $IsoPath -Algorithm SHA256).Hash
```

**Reference:** `MIGRATION-PLAN.md` Phase 1.1

---

### 3. External Drive Data Recovery Check

**Status:** ⏳ Pending (after ISO download)

**Current State:**
- 2TB Seagate FireCuda - Corrupted
- 2 partitions detected (vs expected 5)
- Partition 1: 500GB "Unknown" type

**Actions:**
```powershell
# 1. Check if 500GB partition has recoverable data
Get-Partition -DiskNumber 1 | Format-Table -AutoSize

# 2. Try to assign drive letter and explore
Get-Partition -DiskNumber 1 -PartitionNumber 2 | Set-Partition -NewDriveLetter Z
Get-ChildItem Z:\ -Recurse -ErrorAction SilentlyContinue

# 3. If important data found, copy to D: drive temporarily
# 4. Document findings in ATOM trail
```

**Reference:** `MIGRATION-PLAN.md` Phase 1.2, `HARDWARE.md` Storage section

---

### 4. Gaming Baseline (BF6 Session)

**Status:** ⏳ Optional (for comparison data)

**Purpose:** Capture Windows gaming performance before Bazzite migration

**Actions:**
```powershell
# 1. Run network baseline
Test-KenlNetwork

# 2. Start background latency monitoring
1..999 | % { "$(Get-Date -Format 'HH:mm:ss') | $(ping -n 1 8.8.8.8 | Select-String 'time')" ; sleep 5 } > latency-bf6-session.log

# 3. Play BF6 session (30-60 minutes)
# Note FPS, stuttering, playability (subjective)

# 4. Create Play Card
New-Item -Path "~/.kenl/playcards" -ItemType Directory -Force
# Document FPS, settings, in-game latency, overall experience
```

**Reference:** `TESTING-RESULTS.md` Gaming Baseline section

---

### 5. Obsidian Vault Setup (Optional but Recommended)

**Status:** 🔜 Ready to start

**Purpose:** Visualize KENL SAGE methodology and ATOM trails

**Actions:**
```powershell
# 1. Install Obsidian (Windows)
choco install obsidian -y
# Or download from https://obsidian.md/download

# 2. Create vault structure
New-Item -ItemType Directory -Path "$env:USERPROFILE\.kenl\vault" -Force
New-Item -ItemType Directory -Path "$env:USERPROFILE\.kenl\vault\00-Index" -Force
New-Item -ItemType Directory -Path "$env:USERPROFILE\.kenl\vault\01-ATOM-Trails" -Force
New-Item -ItemType Directory -Path "$env:USERPROFILE\.kenl\vault\02-Modules" -Force
New-Item -ItemType Directory -Path "$env:USERPROFILE\.kenl\vault\03-Playbooks" -Force
New-Item -ItemType Directory -Path "$env:USERPROFILE\.kenl\vault\04-Resources" -Force

# 3. Launch Obsidian, open vault at %USERPROFILE%\.kenl\vault

# 4. Create Dashboard.md as landing page
```

**Reference:**
- `claude-landing/OBSIDIAN-QUICK-START.md` (quick setup)
- `modules/KENL7-learning/guides/SAGE-OBSIDIAN-WALKTHROUGH.md` (full walkthrough)

---

## Medium-Term (Next 1-2 Weeks)

### 6. Bazzite Installation

**Trigger:** ISO download complete + SHA256 verified + data recovery checked

**Pre-Flight Checklist:**
- ✅ Bazzite ISO verified (SHA256 match)
- ✅ External drive data backed up (or confirmed safe to wipe)
- ✅ Important Windows files backed up to D: drive
- ✅ Installation decision made (dual-boot vs full install)
- ✅ Ventoy USB boots successfully

**Installation Steps:**
1. Boot Bazzite Live USB
2. Test hardware compatibility
3. Wipe/repartition 2TB external drive (5-partition layout)
4. Install Bazzite to internal NVMe
5. Configure bootloader (GRUB for dual-boot)

**Time Estimate:** 2-3 hours

**Reference:** `MIGRATION-PLAN.md` Phase 2

---

### 7. Post-Install Configuration

**Trigger:** Bazzite successfully installed and booted

**Critical Tasks:**
```bash
# 1. System update first
ujust update
sudo systemctl reboot

# 2. Mount external drive partitions
# See MIGRATION-PLAN.md Phase 3.2 for fstab entries

# 3. Clone KENL repository
git clone https://github.com/toolate28/kenl.git ~/kenl

# 4. Run bootstrap
cd ~/kenl
./scripts/bootstrap.sh

# 5. Initialize ATOM framework
# See MIGRATION-PLAN.md Phase 3.5

# 6. Configure Steam library (Games-Universal partition)
# 7. Set up Claude Desktop MCP
# 8. Create distrobox dev container
```

**Time Estimate:** 3-4 hours

**Reference:** `MIGRATION-PLAN.md` Phase 3

---

### 8. Validation & Testing

**Trigger:** All post-install configuration complete

**Tests to Run:**
```bash
# Network baseline (compare to Windows 6.2ms)
bash ~/kenl/modules/KENL2-gaming/configs/network/test-network-latency.sh

# Hardware optimization
cd ~/kenl/modules/KENL2-gaming/configs/hardware/amd-ryzen5-5600h-vega-optimal

# Gaming performance test (BF6 or similar)
# Create Play Card, compare to Windows baseline

# Module health check
ls -la ~/kenl/modules/
cat ~/.config/bazza-dx/atom_trail.log
```

**Reference:** `MIGRATION-PLAN.md` Phase 4

---

## Long-Term (Future Enhancements)

### 9. MCP Integration (Claude Desktop)

**Status:** 🔮 Planned for after Bazzite migration

**Features:**
- Cloudflare MCP (Workers/KV/D1/R2 management)
- Filesystem MCP (KENL repository access)
- Git MCP (repository operations)
- Obsidian vault MCP (SAGE integration)

**Reference:** `modules/KENL3-dev/claude-code-setup/claude-configuration-guide.md`

---

### 10. Local AI Setup (Ollama + Qwen)

**Status:** 🔮 Planned

**Purpose:** Offline AI assistance (60% of AI usage per strategy)

**Setup:**
```bash
# Install Ollama
flatpak install flathub io.ollama.Ollama

# Pull Qwen model
ollama pull qwen2.5:14b

# Test
ollama run qwen2.5:14b "Hello, test Qwen model"
```

**Storage:** `/mnt/claude-ai` (500GB partition on external drive)

---

### 11. Play Card Library

**Status:** 🔮 Planned

**Purpose:** Build shareable gaming configs for AMD Ryzen 5 5600H + Vega

**Target Games:**
- Battlefield 6 (multiplayer shooter)
- Baldur's Gate 3 (RPG)
- Counter-Strike 2 (competitive FPS)
- Elden Ring (action RPG)
- City Skylines (simulation)

**Format:** YAML Play Cards in `modules/KENL2-gaming/play-cards/games/`

---

## Decision Points

### Dual-Boot vs Full Bazzite Install

**Option A: Dual-Boot (Recommended)**
- ✅ Keep Windows 11 as fallback
- ✅ Gradual migration, test Bazzite thoroughly
- ✅ Can boot Windows for comparison/testing
- ⚠️ Less space for each OS (~200GB Windows, ~300GB Bazzite)

**Option B: Full Bazzite (Advanced)**
- ✅ Full 512GB for Bazzite
- ✅ Simpler partition layout
- ⚠️ No Windows fallback (must reinstall if issues)
- ⚠️ Requires confidence in Bazzite compatibility

**Recommendation:** **Option A** for first migration

**When to Decide:** Before starting Bazzite installation (Phase 2)

---

## Blockers & Dependencies

### Current Blockers

**None** - All prerequisites met for next steps

### Dependencies

1. **Bazzite Installation** depends on:
   - ✅ ISO download complete
   - ✅ SHA256 verification passed
   - ✅ External drive data recovery checked
   - ✅ Important files backed up

2. **Post-Install Configuration** depends on:
   - ⏳ Bazzite successfully installed
   - ⏳ All partitions mounted correctly

3. **Validation Testing** depends on:
   - ⏳ Post-install configuration complete
   - ⏳ Steam library configured
   - ⏳ Network optimizations applied

---

## Risk Mitigation

### Rollback Plans

**If critical issues during installation:**
- Dual-boot: Reboot to Windows 11, debug from there
- Full install: Boot Bazzite Live USB, backup data, reinstall Windows if needed

**If performance worse than Windows:**
- Compare ATOM trails and Play Cards
- Adjust Proton versions, launch options
- Check hardware optimization scripts
- Consult Bazzite docs + ProtonDB

**If external drive issues:**
- Re-check partition UUIDs in fstab
- Verify filesystem formats (ntfs-3g for NTFS, exfat-utils for exFAT)
- Mount manually first, then add to fstab

**Reference:** `MIGRATION-PLAN.md` Rollback Plan section

---

## Success Metrics

**Migration is successful when:**
- ✅ Bazzite boots reliably
- ✅ External drive all 5 partitions mounted
- ✅ Network latency ≤ 10ms (comparable to Windows baseline)
- ✅ Steam library accessible, games launch
- ✅ Gaming performance acceptable (via Play Card comparison)
- ✅ KENL modules functional (scripts run without errors)
- ✅ ATOM trail logging operational
- ✅ Dual-boot working (if chosen)

**Reference:** `MIGRATION-PLAN.md` Success Criteria

---

## Timeline Estimate

| Phase | Duration | Status |
|-------|----------|--------|
| **Documentation consistency** | 1-2 hours | ⏳ In progress |
| **ISO download + verification** | 1-2 hours | ⏳ Pending |
| **External drive data check** | 30 min - 1 hour | 🔜 Next |
| **Gaming baseline (optional)** | 1-2 hours | 🔜 Optional |
| **Obsidian setup (optional)** | 30 min - 1 hour | 🔜 Optional |
| **Bazzite installation** | 2-3 hours | 🔜 Pending |
| **Post-install configuration** | 3-4 hours | 🔜 Pending |
| **Validation & testing** | 2-4 hours | 🔜 Pending |
| **Total** | **11-18 hours** | Spread over 2-3 days recommended |

---

## Quick Reference Commands

### Network Testing
```powershell
# Windows
Test-KenlNetwork

# Linux/Bazzite (after install)
bash ~/kenl/modules/KENL2-gaming/configs/network/test-network-latency.sh
```

### ATOM Trail
```bash
# Generate ATOM tag
generate_atom_tag CFG "Description of change"

# View trail
cat ~/.config/bazza-dx/atom_trail.log
```

### Git Operations
```bash
# Check status
git status
git log --oneline -10

# Commit changes
git add .
git commit -m "type: description

ATOM-TYPE-YYYYMMDD-NNN"
```

---

## Related Documents

- **CURRENT-STATE.md** - Current environment snapshot
- **MIGRATION-PLAN.md** - Detailed migration roadmap (phases, commands, rollback)
- **HARDWARE.md** - Hardware specifications and optimization
- **TESTING-RESULTS.md** - Validation results and baselines
- **QUICK-REFERENCE.md** - Common commands and paths
- **OBSIDIAN-QUICK-START.md** - Local Obsidian setup guide

---

**ATOM:** ATOM-DOC-20251115-003
**Next Update:** After Bazzite ISO download completes
**Current Priority:** Complete documentation consistency, then ISO verification
