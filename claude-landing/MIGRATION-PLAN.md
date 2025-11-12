---
title: Windows → Bazzite-DX Migration Plan
date: 2025-11-12
atom: ATOM-DEPLOY-20251112-001
status: active
classification: OWI-CWI
---

# Windows → Bazzite-DX Migration Plan

**Migration Date:** TBD (Bazzite ISO download in progress)
**ATOM Tag:** ATOM-DEPLOY-20251112-001
**Target:** Bazzite-DX KDE (Fedora Atomic 43)

## Migration Context

**Reason:** Windows 10 EOL (October 2025) - 240M+ affected PCs
**Current:** Windows 11 (testing phase before migration)
**Target:** Bazzite-DX (immutable gaming-focused Linux)

**Hardware:**
- AMD Ryzen 5 5600H + Radeon Vega Graphics
- 512GB Internal NVMe (OS target)
- 2TB External HDD (data/games storage)

**Goals:**
1. Maintain gaming capability (Proton/GE-Proton)
2. Preserve development environment (distrobox)
3. Evidence-based configuration (ATOM trail)
4. Rollback-safe system (rpm-ostree immutability)

---

## Migration Phases

### Phase 0: Pre-Flight Preparation ✅ (In Progress)

**Status:** Windows baseline testing and preparation

#### Completed ✅

1. **PowerShell Modules Developed & Tested**
   - KENL.psm1, KENL.Network.psm1
   - Network optimization validated
   - Test-KenlNetwork: **ACK**

2. **Network Baseline Established**
   - Latency: 6.2ms average (EXCELLENT)
   - Tailscale impact identified and resolved
   - MTU optimized to 1492 bytes

3. **Hardware Configuration Documented**
   - AMD Ryzen 5 5600H + Vega specs recorded
   - Optimal settings identified
   - Performance expectations set

4. **Repository Prepared**
   - All modules on main branch
   - Clean git state
   - Documentation complete

5. **Ventoy USB Ready**
   - 28GB bootable USB (F:)
   - Ready for Bazzite ISO

#### In Progress ⏳

6. **Bazzite ISO Download**
   - Downloading directly to Ventoy USB (Partition 2)
   - SHA256 verification pending
   - Target: Latest stable Bazzite KDE

7. **External Drive Assessment**
   - 2TB Seagate FireCuda detected
   - Current state: Corrupted (2 partitions vs expected 5)
   - Data recovery check pending

#### Pending 🔜

8. **Gaming Baseline (BF6 Session)**
   - Purpose: Before/after performance comparison
   - Metrics: FPS, latency, playability
   - Play Card creation

9. **Data Backup**
   - Important files from Windows C:
   - Development projects
   - Configuration files

---

### Phase 1: Installation Preparation 🔜

**Trigger:** Bazzite ISO download complete

#### 1.1 ISO Verification

```powershell
# On Windows
$IsoPath = "F:\bazzite-stable-43.YYYYMMDD.iso"
$ExpectedHash = "PASTE_HASH_FROM_GITHUB_RELEASE"
$ActualHash = (Get-FileHash $IsoPath -Algorithm SHA256).Hash

if ($ActualHash -eq $ExpectedHash) {
    Write-Host "✅ ISO verified successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Hash mismatch - re-download required" -ForegroundColor Red
    Write-Host "Expected: $ExpectedHash"
    Write-Host "Actual:   $ActualHash"
}
```

**ATOM:** ATOM-DEPLOY-20251112-002

#### 1.2 Data Recovery Check

```powershell
# Check if 500GB partition on external drive has recoverable data
Get-Partition -DiskNumber 1 | Format-Table -AutoSize

# Try to assign drive letter and check contents
Get-Partition -DiskNumber 1 | Where-Object Size -eq 536887689216 | Set-Partition -NewDriveLetter Z
Get-ChildItem Z:\ -Recurse -ErrorAction SilentlyContinue | Measure-Object

# If important data found:
# - Copy to C: or D: temporarily
# - Then proceed with wipe
```

**ATOM:** ATOM-TASK-20251112-003

#### 1.3 Backup Critical Data

**Windows System:**
- Documents: `C:\Users\Matthew Ruhnau\Documents`
- Downloads: `C:\Users\Matthew Ruhnau\Downloads`
- PowerShell Profile: `C:\Users\Matthew Ruhnau\Documents\PowerShell\`
- SSH Keys: `C:\Users\Matthew Ruhnau\.ssh\` (if present)
- GPG Keys: `C:\Users\Matthew Ruhnau\.gnupg\` (if present)

**Development:**
- Git repositories (if not pushed)
- IDE configurations
- Virtual environments (record package lists)

**Backup Location:** D: drive (104GB NTFS partition, survives install)

#### 1.4 Installation Decision Point

**Option A: Dual-Boot (Recommended)**
- Keep Windows 11 on C: (shrink to ~200GB)
- Install Bazzite on remaining NVMe space (~300GB)
- Benefits: Fallback to Windows if needed, test gradually
- Tradeoff: Less space for each OS

**Option B: Full Bazzite (Advanced)**
- Wipe Windows completely
- Bazzite gets full 512GB NVMe
- Benefits: Maximum space, faster
- Tradeoff: No Windows fallback (must reinstall if issues)

**Recommendation:** **Option A (Dual-Boot)** for first migration
- Safer transition
- Windows available for testing/comparison
- Can remove Windows partition later if confident

---

### Phase 2: Bazzite Installation 🔜

**Prerequisite:** ISO verified, data backed up, installation option chosen

#### 2.1 Boot Bazzite Live USB

1. **Reboot with Ventoy USB inserted**
2. **Enter BIOS/UEFI boot menu** (usually F12, Del, or F2)
3. **Select:** USB Drive (Ventoy)
4. **Ventoy Menu:** Select Bazzite ISO from list
5. **Bazzite Boot Menu:** Select "Start Bazzite-DX"

**Expected:** Boots to Bazzite Live desktop (KDE Plasma)

#### 2.2 Test Hardware Compatibility

```bash
# From Bazzite Live environment, open Konsole terminal

# Check CPU
lscpu | grep "Model name"
# Expected: AMD Ryzen 5 5600H

# Check GPU
lspci | grep -i vga
# Expected: AMD/ATI Vega

# Check network
ip link show
nmcli device status
# Expected: Ethernet adapter detected

# Check internal drives
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
# Expected: 512GB NVMe + 2TB external USB

# Test network connectivity
ping -c 4 8.8.8.8
# Expected: ~6ms latency (similar to Windows baseline)
```

**If issues:** Check BIOS settings (UEFI mode, Secure Boot, AMD-V)

**ATOM:** ATOM-TASK-20251112-004

#### 2.3 Wipe and Repartition External Drive

**WARNING:** This erases ALL data on the 2TB external drive!

```bash
# Identify the 2TB external drive
lsblk -o NAME,SIZE,TYPE,MODEL
# Expected: 2TB Seagate FireCuda (likely /dev/sdb or /dev/sdc)

# Set drive variable (VERIFY THIS IS CORRECT!)
DRIVE="/dev/sdb"  # CHANGE if different!

# Safety check
echo "About to wipe $DRIVE - verify this is the 2TB Seagate!"
lsblk $DRIVE
read -p "Type 'YES' to continue: " confirm
[[ "$confirm" != "YES" ]] && exit 1

# Wipe partition table
sudo wipefs -af $DRIVE

# Zero out first/last sectors (thorough clean)
sudo dd if=/dev/zero of=$DRIVE bs=1M count=10 status=progress
sudo dd if=/dev/zero of=$DRIVE bs=1M seek=$(( $(sudo blockdev --getsz $DRIVE) / 2048 - 10 )) count=10 status=progress

# Create fresh GPT partition table
sudo parted $DRIVE mklabel gpt

# Create partitions (per documented layout)
sudo parted $DRIVE mkpart primary ntfs 1MiB 900GiB
sudo parted $DRIVE name 1 Games-Universal

sudo parted $DRIVE mkpart primary ext4 900GiB 1400GiB
sudo parted $DRIVE name 2 Claude-AI-Data

sudo parted $DRIVE mkpart primary ext4 1400GiB 1600GiB
sudo parted $DRIVE name 3 Development

sudo parted $DRIVE mkpart primary ntfs 1600GiB 1750GiB
sudo parted $DRIVE name 4 Windows-Only

sudo parted $DRIVE mkpart primary fat32 1750GiB 100%
sudo parted $DRIVE name 5 Transfer

sudo parted $DRIVE quit

# Format partitions
sudo mkfs.ntfs -f -L "Games-Universal" ${DRIVE}1
sudo mkfs.ext4 -L "Claude-AI-Data" ${DRIVE}2
sudo mkfs.ext4 -L "Development" ${DRIVE}3
sudo mkfs.ntfs -f -L "Windows-Only" ${DRIVE}4
sudo mkfs.exfat -n "Transfer" ${DRIVE}5

# Verify layout
lsblk -o NAME,SIZE,FSTYPE,LABEL $DRIVE
```

**Expected Output:**
```
sdb                 1.8T
├─sdb1              900G ntfs   Games-Universal
├─sdb2              500G ext4   Claude-AI-Data
├─sdb3              200G ext4   Development
├─sdb4              150G ntfs   Windows-Only
└─sdb5               50G exfat  Transfer
```

**ATOM:** ATOM-CFG-20251112-005

**Reference:** `scripts/1.8TB_EXTERNAL_DRIVE_LAYOUT.md`

#### 2.4 Install Bazzite to Internal NVMe

**Option A: Dual-Boot Install**

1. **Launch Installer**
   - From Live desktop: "Install to Hard Drive" icon
   - Or: Applications → System → Install to Hard Drive

2. **Language & Keyboard**
   - Select language (English)
   - Keyboard layout (US or appropriate)

3. **Installation Destination**
   - Select: Internal NVMe (512GB KINGSTON)
   - **Important:** Choose "Custom" or "Advanced" partitioning
   - **Do NOT select:** 2TB external drive (data only!)

4. **Partitioning (Dual-Boot)**
   - Shrink Windows C: partition to ~200GB
   - Create new partitions in free space:
     - `/boot/efi`: 512MB (or use existing Windows EFI partition)
     - `/boot`: 1GB (ext4)
     - `/`: ~290GB (btrfs or ext4)
     - `swap`: 16GB (optional, for hibernation)

5. **Bootloader**
   - Install to: NVMe EFI partition
   - Should detect Windows and add to boot menu

6. **User Account**
   - Username: (your choice)
   - Password: (set strong password)
   - Hostname: (e.g., "bazzite-gaming")

7. **Review & Install**
   - Verify: Installing to NVMe, NOT external drive
   - Verify: Windows partition preserved
   - Begin Installation

**Option B: Full Bazzite Install** (Advanced)

1-7. Same as above, but:
   - **Wipe entire NVMe** (goodbye Windows)
   - Full disk for Bazzite (~500GB for `/`)
   - No dual-boot complexity

**Installation Time:** 15-30 minutes

**ATOM:** ATOM-DEPLOY-20251112-006

#### 2.5 Post-Install Reboot

1. **Installer completes** → Reboot prompt
2. **Remove USB drive** (or Ventoy menu will appear)
3. **Boot Menu Appears:**
   - Option A (Dual-Boot): Select Bazzite or Windows 11
   - Option B (Full Install): Boots directly to Bazzite
4. **First Boot:** Bazzite welcome wizard (quick setup)

**ATOM:** ATOM-DEPLOY-20251112-007

---

### Phase 3: Post-Install Configuration 🔜

**Prerequisite:** Bazzite successfully installed and booted

#### 3.1 System Update (First Priority)

```bash
# Update to latest Bazzite image
ujust update

# Reboot after update
sudo systemctl reboot
```

**ATOM:** ATOM-CFG-20251112-008

#### 3.2 Mount External Drive Partitions

```bash
# Create mount points
sudo mkdir -p /mnt/{games-universal,claude-ai,development,windows-only,transfer}

# Get partition UUIDs
sudo blkid | grep sdb

# Add to /etc/fstab (use your actual UUIDs!)
sudo nano /etc/fstab

# Example entries (REPLACE UUIDs WITH YOUR VALUES):
# UUID=XXXX-XXXX /mnt/games-universal ntfs-3g defaults,uid=1000,gid=1000 0 0
# UUID=XXXX-XXXX /mnt/claude-ai ext4 defaults 0 2
# UUID=XXXX-XXXX /mnt/development ext4 defaults 0 2
# UUID=XXXX-XXXX /mnt/windows-only ntfs-3g defaults,uid=1000,gid=1000 0 0
# UUID=XXXX-XXXX /mnt/transfer exfat defaults,uid=1000,gid=1000 0 0

# Mount all
sudo mount -a

# Verify
df -h | grep sdb
```

**Expected:** All 5 partitions mounted successfully

**ATOM:** ATOM-CFG-20251112-009

**Reference:** `scripts/1.8TB_EXTERNAL_DRIVE_LAYOUT.md` (fstab section)

#### 3.3 Clone KENL Repository

```bash
# Clone to home directory
cd ~
git clone https://github.com/toolate28/kenl.git
cd kenl

# Verify branch
git branch -a
git log --oneline -5

# Expected: main branch with recent PowerShell commits
```

**ATOM:** ATOM-TASK-20251112-010

#### 3.4 Run KENL Bootstrap

```bash
# Bootstrap development environment
cd ~/kenl
./scripts/bootstrap.sh

# This installs:
# - Pre-commit hooks
# - Python dependencies (if needed)
# - Initial KENL configuration

# Follow prompts
```

**ATOM:** ATOM-CFG-20251112-011

#### 3.5 Initialize ATOM Framework

```bash
# Create Bazza-DX config directory
mkdir -p ~/.config/bazza-dx

# Create ATOM environment file
cat > ~/.config/bazza-dx/env.sh <<'EOF'
#!/usr/bin/env bash
# ATOM Trail Configuration

export ATOM_COUNTER_FILE="$HOME/.config/bazza-dx/atom_counter"
export ATOM_TRAIL_FILE="$HOME/.config/bazza-dx/atom_trail.log"

# Initialize counter if doesn't exist
if [[ ! -f "$ATOM_COUNTER_FILE" ]]; then
    echo "1" > "$ATOM_COUNTER_FILE"
fi

# Function to generate ATOM tags
generate_atom_tag() {
    local type=${1:-TASK}
    local counter=$(cat "$ATOM_COUNTER_FILE")
    local tag="ATOM-${type}-$(date +%Y%m%d)-$(printf '%03d' $counter)"
    echo "$tag"
    echo $(($counter + 1)) > "$ATOM_COUNTER_FILE"
    echo "$(date -Iseconds) | $tag | ${2:-No description}" >> "$ATOM_TRAIL_FILE"
}

export -f generate_atom_tag
EOF

# Source in ~/.bashrc
echo 'source ~/.config/bazza-dx/env.sh' >> ~/.bashrc
source ~/.bashrc

# Test
generate_atom_tag CFG "Bazzite post-install configuration"
```

**ATOM:** ATOM-CFG-20251112-012

#### 3.6 Configure Steam (Gaming Library)

```bash
# Install Steam (if not pre-installed)
flatpak install flathub com.valvesoftware.Steam

# Launch Steam, sign in

# Add Games-Universal partition as Steam library:
# 1. Steam → Settings → Storage
# 2. Add Library Folder: /mnt/games-universal
# 3. Move existing games (if coming from Windows shared library)

# Configure Proton:
# 1. Steam → Settings → Compatibility
# 2. Enable: "Enable Steam Play for all other titles"
# 3. Select: GE-Proton (latest) or Proton Experimental
```

**ATOM:** ATOM-CFG-20251112-013

#### 3.7 Configure Claude Desktop MCP

```bash
# Create Claude Desktop config directory
mkdir -p ~/.config/Claude

# Copy MCP configuration template
cp ~/kenl/modules/KENL3-dev/claude-code-setup/claude_desktop_config.json \
   ~/.config/Claude/claude_desktop_config.json

# Edit with actual paths
nano ~/.config/Claude/claude_desktop_config.json

# Configure MCP servers:
# - Filesystem (kenl repository access)
# - Git (repository operations)
# - Cloudflare (Workers/KV/D1/R2 - future)
```

**ATOM:** ATOM-CFG-20251112-014

**Reference:** `modules/KENL3-dev/claude-code-setup/claude-configuration-guide.md`

#### 3.8 Configure Distrobox (Development Environment)

```bash
# Create Ubuntu 24.04 development container
distrobox create --name dev-ubuntu --image ubuntu:24.04

# Enter container
distrobox enter dev-ubuntu

# Inside container: Install development tools
sudo apt update
sudo apt install -y build-essential git curl wget \
                     python3 python3-pip python3-venv \
                     nodejs npm

# Mount Development partition (already accessible at /mnt/development)
mkdir -p ~/projects
ln -s /mnt/development ~/projects

# Exit container
exit
```

**ATOM:** ATOM-CFG-20251112-015

---

### Phase 4: Validation & Testing 🔜

**Prerequisite:** All configuration complete

#### 4.1 Network Performance Test

```bash
# Run bash version of network test
cd ~/kenl
bash modules/KENL2-gaming/configs/network/test-network-latency.sh

# Expected: ~6ms latency (similar to Windows baseline)

# Apply optimizations
sudo bash modules/KENL2-gaming/configs/network/optimize-network-gaming.sh
```

**Compare Against:** Windows baseline (6.2ms average)

**ATOM:** ATOM-TASK-20251112-016

#### 4.2 Hardware Optimization

```bash
# Apply AMD Ryzen 5 5600H + Vega optimal settings
cd ~/kenl/modules/KENL2-gaming/configs/hardware/amd-ryzen5-5600h-vega-optimal

# Review scripts before running
ls -la
cat README.md

# Apply optimizations (review each script first!)
# ./scripts/cpu-governor-performance.sh
# ./scripts/gpu-high-performance.sh
# etc.
```

**ATOM:** ATOM-CFG-20251112-017

#### 4.3 Gaming Performance Test (BF6 or Similar)

```bash
# Launch game via Steam with Proton
# Use MangoHud for FPS overlay:
mangohud %command%  # Add to Steam launch options

# Monitor during gameplay:
# - FPS (average, min, 1% low)
# - Frame times
# - GPU/CPU usage
# - Temperature

# Create Play Card after session
cd ~/kenl
mkdir -p ~/.kenl/playcards
nano ~/.kenl/playcards/bf6-bazzite-$(date +%Y%m%d).json

# Compare against Windows baseline Play Card
```

**ATOM:** ATOM-TASK-20251112-018

#### 4.4 Module Health Check

```bash
# Verify all KENL modules accessible
ls -la ~/kenl/modules/

# Test key scripts
bash ~/kenl/modules/KENL2-gaming/configs/network/monitor-network-gaming.sh &

# Check ATOM trail
cat ~/.config/bazza-dx/atom_trail.log

# Verify git status
cd ~/kenl
git status
git log --oneline -10
```

**ATOM:** ATOM-TASK-20251112-019

---

### Phase 5: Handover & Documentation 🔜

**Prerequisite:** All validation tests passing

#### 5.1 Create Installation Handover Document

```bash
cd ~/kenl
cat > ~/INSTALLATION-HANDOVER-$(date +%Y%m%d).md <<EOF
# Bazzite-DX Installation Handover
# Date: $(date -Iseconds)
# ATOM: $(generate_atom_tag DOC "Bazzite installation completion handover")

## Actions Taken
- ✅ Bazzite-DX KDE installed to internal NVMe
- ✅ 2TB external drive wiped and repartitioned (5-partition layout)
- ✅ External drive auto-mounted via /etc/fstab
- ✅ KENL repository cloned to ~/kenl
- ✅ ATOM framework initialized
- ✅ Steam configured with Games-Universal library
- ✅ Claude Desktop MCP configured
- ✅ Distrobox dev-ubuntu container created

## System Configuration
$(lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT)

## Network Baseline
$(bash ~/kenl/modules/KENL2-gaming/configs/network/test-network-latency.sh)

## Next Steps
- [ ] Test additional games from Steam library
- [ ] Configure game-specific Proton versions
- [ ] Set up Ollama/Qwen in /mnt/claude-ai
- [ ] Migrate development projects to /mnt/development
- [ ] Create Play Cards for comparison with Windows baseline
- [ ] Fine-tune hardware optimizations

## ATOM Trail Summary
$(tail -20 ~/.config/bazza-dx/atom_trail.log)

## Rollback Information
- Dual-boot: Can boot to Windows 11 from GRUB menu
- External drive: fstab entries can be commented out
- Containers: distrobox rm dev-ubuntu
- Steam library: Can be removed from Steam settings

## Contact Points
- Repository: https://github.com/toolate28/kenl
- Case Study Reference: case-studies/RWS-06-COMPLETE-DUAL-BOOT-GAMING-SETUP.md
- Documentation: modules/*/README.md

---
**ATOM Trail:** See ~/.config/bazza-dx/atom_trail.log
**Next ATOM:** $(generate_atom_tag TASK "Begin post-migration optimization")
EOF

cat ~/INSTALLATION-HANDOVER-$(date +%Y%m%d).md
```

**ATOM:** ATOM-DOC-20251112-020

#### 5.2 Update claude-landing/ Documents

```bash
# Update CURRENT-STATE.md
nano ~/kenl/claude-landing/CURRENT-STATE.md
# Change platform from "Windows 11" to "Bazzite-DX KDE"
# Update git status, partitions, testing status

# Add Bazzite testing results to TESTING-RESULTS.md
nano ~/kenl/claude-landing/TESTING-RESULTS.md

# Commit updates
cd ~/kenl
git add claude-landing/
git commit -m "docs: update claude-landing for Bazzite migration

ATOM-DOC-$(date +%Y%m%d)-XXX"
git push
```

**ATOM:** ATOM-DOC-20251112-021

---

## Success Criteria

Migration is considered successful when:

- ✅ Bazzite boots reliably
- ✅ External drive all 5 partitions mounted and accessible
- ✅ Network latency ≤ 10ms (comparable to Windows)
- ✅ Steam library accessible and games launch
- ✅ KENL modules functional (scripts run without errors)
- ✅ ATOM trail logging operational
- ✅ Dual-boot working (if Option A chosen)
- ✅ Gaming performance acceptable (Play Card comparison)

## Rollback Plan

**If critical issues arise:**

### Immediate Rollback (Dual-Boot)

1. **Reboot to Windows 11** (select from GRUB menu)
2. **Use Windows as primary** until issues resolved
3. **External drive accessible** from both OSes
4. **Research/fix Bazzite issues** while on Windows

### Full Rollback (If Needed)

1. **Boot Bazzite Live USB**
2. **Backup important data** from Bazzite partition
3. **Wipe Bazzite partition** (GParted or parted)
4. **Expand Windows partition** to reclaim space
5. **Fix Windows bootloader** (if needed):
   ```
   bootrec /fixmbr
   bootrec /fixboot
   bootrec /rebuildbcd
   ```

### Data Preservation

- External drive remains intact (NOT OS drive)
- Windows partition preserved (dual-boot)
- Git repository: Push changes before major operations
- ATOM trail: Backed up to external drive

## Timeline Estimate

| Phase | Duration | Dependencies |
|-------|----------|--------------|
| Phase 0: Prep | 2-4 hours | BF6 gaming session, data backup |
| Phase 1: Pre-Install | 1 hour | ISO verification, data recovery check |
| Phase 2: Installation | 1-2 hours | Bazzite installer, partitioning |
| Phase 3: Configuration | 2-3 hours | KENL setup, Steam, MCP |
| Phase 4: Validation | 2-4 hours | Testing, gaming, comparison |
| Phase 5: Handover | 1 hour | Documentation |
| **Total** | **9-15 hours** | Spread over 2-3 days recommended |

## Current Status

**Phase 0:** ✅ In Progress (80% complete)
- PowerShell modules: ✅ Developed and tested
- Network baseline: ✅ Established
- Hardware docs: ✅ Complete
- Repository: ✅ Clean and ready
- Ventoy USB: ✅ Ready
- Bazzite ISO: ⏳ Downloading
- External drive: ⏳ Needs wipe/repartition
- BF6 baseline: ⏳ Pending

**Next Action:** Complete Bazzite ISO download + SHA256 verification

---

## References

**KENL Documentation:**
- `claude-landing/CURRENT-STATE.md` - Current environment
- `claude-landing/HARDWARE.md` - Hardware specifications
- `claude-landing/TESTING-RESULTS.md` - Validation results
- `claude-landing/QUICK-REFERENCE.md` - Commands and paths

**Case Studies:**
- `case-studies/RWS-06-COMPLETE-DUAL-BOOT-GAMING-SETUP.md` (1,210 lines!)
- `case-studies/RWS-04-RPMOSTREE-REBASE.md` - Rebasing strategies

**External Drive:**
- `scripts/1.8TB_EXTERNAL_DRIVE_LAYOUT.md` - Partition layout and fstab

**Bazzite Docs:**
- https://docs.bazzite.gg/
- https://universal-blue.org/

---

**ATOM:** ATOM-DEPLOY-20251112-001
**Status:** Ready for execution (awaiting ISO download completion)
**Risk Level:** Medium (dual-boot provides safety net)
**Expected Outcome:** Functional gaming + development system with evidence-based configuration
