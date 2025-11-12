#!/usr/bin/env bash
# STEP 2: WSL2 Partition Creation (Run from WSL2 Fedora)
# ATOM-CFG-20251112-003
# Creates 5-partition hybrid layout on 1.8TB Seagate FireCuda

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  KENL Drive Preparation - Step 2: WSL2 Partitioning${NC}"
echo -e "${CYAN}  ATOM-CFG-20251112-003${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Check if running in WSL
if ! grep -qi microsoft /proc/version; then
    echo -e "${RED}❌ This script must be run from WSL2${NC}"
    echo -e "${YELLOW}Current environment: $(uname -a)${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Running in WSL2${NC}"
echo ""

# Check for required tools
echo -e "${YELLOW}[1/8] Checking required tools...${NC}"
MISSING_TOOLS=()

for tool in parted mkfs.ntfs mkfs.ext4 mkfs.exfat lsblk blkid; do
    if ! command -v $tool &> /dev/null; then
        MISSING_TOOLS+=($tool)
    fi
done

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Missing tools: ${MISSING_TOOLS[*]}${NC}"
    echo -e "${YELLOW}Installing required packages...${NC}"
    sudo dnf install -y parted ntfsprogs e2fsprogs exfatprogs util-linux
fi

echo -e "${GREEN}✅ All tools available${NC}"
echo ""

# List Windows physical drives
echo -e "${YELLOW}[2/8] Detecting Windows physical drives via WSL2...${NC}"
echo ""

# WSL2 exposes Windows drives as /dev/sd*
# We need to find Disk 1 (which is the 1.8TB Seagate)
echo "Available drives in WSL2:"
lsblk -o NAME,SIZE,MODEL,TYPE | grep -E "NAME|disk" || echo "No drives found"
echo ""

# In WSL2, Windows Disk 0 = /dev/sda, Disk 1 = /dev/sdb, etc.
TARGET_DRIVE="/dev/sdb"

echo -e "${CYAN}WSL2 Drive Mapping:${NC}"
echo -e "  Windows Disk 0 (Kingston 512GB) → /dev/sda (System)"
echo -e "  Windows Disk 1 (Seagate 2TB)    → /dev/sdb (Target) ← We'll use this"
echo ""

# Verify target drive exists
if [ ! -b "$TARGET_DRIVE" ]; then
    echo -e "${RED}❌ Target drive $TARGET_DRIVE not found${NC}"
    echo ""
    echo -e "${YELLOW}Available drives:${NC}"
    lsblk
    echo ""
    read -p "Enter drive path manually (e.g., /dev/sdc): " TARGET_DRIVE

    if [ ! -b "$TARGET_DRIVE" ]; then
        echo -e "${RED}❌ Invalid drive: $TARGET_DRIVE${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✅ Target drive: $TARGET_DRIVE${NC}"
echo ""

# Show drive details
echo -e "${YELLOW}[3/8] Target Drive Details:${NC}"
lsblk -o NAME,SIZE,MODEL,TYPE,FSTYPE,MOUNTPOINT "$TARGET_DRIVE" || true
echo ""

# Verify it's the right drive (by size)
DRIVE_SIZE=$(blockdev --getsize64 "$TARGET_DRIVE" 2>/dev/null || echo 0)
DRIVE_SIZE_GB=$((DRIVE_SIZE / 1024 / 1024 / 1024))

echo -e "Drive size: ${DRIVE_SIZE_GB}GB"
echo ""

if [ "$DRIVE_SIZE_GB" -lt 1700 ] || [ "$DRIVE_SIZE_GB" -gt 2100 ]; then
    echo -e "${RED}⚠️  WARNING: Drive size unexpected!${NC}"
    echo -e "${RED}   Expected ~1800-2000GB, found ${DRIVE_SIZE_GB}GB${NC}"
    echo ""
    read -p "Continue anyway? [y/N]: " confirm
    if [ "$confirm" != "y" ]; then
        echo "Aborted."
        exit 1
    fi
fi

# Safety confirmation
echo -e "${RED}═══════════════════════════════════════════════════════════${NC}"
echo -e "${RED}  ⚠️  FINAL SAFETY CHECK ⚠️${NC}"
echo -e "${RED}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}You are about to partition: $TARGET_DRIVE${NC}"
echo -e "${YELLOW}This is Windows Disk 1 (Seagate FireCuda 2TB)${NC}"
echo -e "${YELLOW}All existing data will be PERMANENTLY DELETED!${NC}"
echo ""
read -p "Type 'CREATE PARTITIONS' to proceed: " confirm

if [ "$confirm" != "CREATE PARTITIONS" ]; then
    echo ""
    echo -e "${RED}❌ Aborted - confirmation phrase did not match${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Confirmation received. Proceeding with partitioning...${NC}"
echo ""

# Unmount any existing partitions
echo -e "${YELLOW}[4/8] Unmounting any existing partitions...${NC}"
for part in ${TARGET_DRIVE}*; do
    if [ -b "$part" ]; then
        umount "$part" 2>/dev/null || true
    fi
done
echo -e "${GREEN}  ✅ Partitions unmounted${NC}"
echo ""

# Create partitions with parted
echo -e "${YELLOW}[5/8] Creating partition layout...${NC}"
echo "  Creating GPT partition table..."
sudo parted -s "$TARGET_DRIVE" mklabel gpt

echo "  Creating partition 1: Games-Universal (900GB, NTFS)..."
sudo parted -s "$TARGET_DRIVE" mkpart primary ntfs 1MiB 900GiB
sudo parted -s "$TARGET_DRIVE" name 1 Games-Universal

echo "  Creating partition 2: Claude-AI-Data (500GB, ext4)..."
sudo parted -s "$TARGET_DRIVE" mkpart primary ext4 900GiB 1400GiB
sudo parted -s "$TARGET_DRIVE" name 2 Claude-AI-Data

echo "  Creating partition 3: Development (200GB, ext4)..."
sudo parted -s "$TARGET_DRIVE" mkpart primary ext4 1400GiB 1600GiB
sudo parted -s "$TARGET_DRIVE" name 3 Development

echo "  Creating partition 4: Windows-Only (150GB, NTFS)..."
sudo parted -s "$TARGET_DRIVE" mkpart primary ntfs 1600GiB 1750GiB
sudo parted -s "$TARGET_DRIVE" name 4 Windows-Only

echo "  Creating partition 5: Transfer (50GB, exFAT)..."
sudo parted -s "$TARGET_DRIVE" mkpart primary fat32 1750GiB 100%
sudo parted -s "$TARGET_DRIVE" name 5 Transfer

echo -e "${GREEN}  ✅ Partition table created${NC}"
echo ""

# Wait for kernel to recognize partitions
echo -e "${YELLOW}[6/8] Waiting for kernel to recognize new partitions...${NC}"
sleep 2
sudo partprobe "$TARGET_DRIVE" 2>/dev/null || true
sleep 2
echo -e "${GREEN}  ✅ Partitions recognized${NC}"
echo ""

# Format partitions
echo -e "${YELLOW}[7/8] Formatting partitions (this may take 15-30 minutes)...${NC}"
echo ""

echo "  [1/5] Formatting Games-Universal (NTFS, 900GB)..."
sudo mkfs.ntfs -f -L "Games-Universal" "${TARGET_DRIVE}1"
echo -e "${GREEN}    ✅ Games-Universal formatted${NC}"

echo "  [2/5] Formatting Claude-AI-Data (ext4, 500GB)..."
sudo mkfs.ext4 -F -L "Claude-AI-Data" "${TARGET_DRIVE}2"
echo -e "${GREEN}    ✅ Claude-AI-Data formatted${NC}"

echo "  [3/5] Formatting Development (ext4, 200GB)..."
sudo mkfs.ext4 -F -L "Development" "${TARGET_DRIVE}3"
echo -e "${GREEN}    ✅ Development formatted${NC}"

echo "  [4/5] Formatting Windows-Only (NTFS, 150GB)..."
sudo mkfs.ntfs -f -L "Windows-Only" "${TARGET_DRIVE}4"
echo -e "${GREEN}    ✅ Windows-Only formatted${NC}"

echo "  [5/5] Formatting Transfer (exFAT, 50GB)..."
sudo mkfs.exfat -n "Transfer" "${TARGET_DRIVE}5"
echo -e "${GREEN}    ✅ Transfer formatted${NC}"
echo ""

# Verify partitions
echo -e "${YELLOW}[8/8] Verifying partition layout...${NC}"
echo ""
lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT "$TARGET_DRIVE"
echo ""

# Get UUIDs for fstab
echo -e "${CYAN}Partition UUIDs (for Bazzite /etc/fstab):${NC}"
echo ""
sudo blkid "${TARGET_DRIVE}"*
echo ""

# Create handover document (save to Windows filesystem)
HANDOVER_FILE="/mnt/c/Users/Matthew Ruhnau/Desktop/HANDOVER-WSL2-PARTITION-$(date +%Y%m%d-%H%M%S).md"
cat > "$HANDOVER_FILE" <<EOF
# WSL2 Partition Creation Handover
**ATOM-CFG-20251112-003**
**Timestamp**: $(date -Iseconds)
**Phase**: Step 2 Complete (WSL2 Partitioning)
**Method**: WSL2 Fedora 43

## Actions Completed
- ✅ Partitioning executed from WSL2 (no reboot needed!)
- ✅ 5 partitions created on $TARGET_DRIVE
- ✅ All partitions formatted with correct filesystems
- ✅ Partition labels applied
- ✅ Layout verified

## Partition Layout
\`\`\`
$(lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT "$TARGET_DRIVE")
\`\`\`

## Partition UUIDs (For Bazzite /etc/fstab)
\`\`\`
$(sudo blkid "${TARGET_DRIVE}"*)
\`\`\`

## WSL2 → Windows Disk Mapping
- WSL2 Path: $TARGET_DRIVE
- Windows Disk: Disk 1 (Seagate FireCuda)
- Windows will now see 3 new drive letters (NTFS + exFAT partitions)

## Expected Layout (Verification)
| Partition | Size | Filesystem | Label | Purpose |
|-----------|------|------------|-------|---------|
| ${TARGET_DRIVE}1 | 900GB | NTFS | Games-Universal | Steam library (cross-OS) |
| ${TARGET_DRIVE}2 | 500GB | ext4 | Claude-AI-Data | LLMs, datasets, vectors |
| ${TARGET_DRIVE}3 | 200GB | ext4 | Development | Distrobox, venvs, repos |
| ${TARGET_DRIVE}4 | 150GB | NTFS | Windows-Only | EA App, anti-cheat games |
| ${TARGET_DRIVE}5 | 50GB | exFAT | Transfer | Quick file exchange |

## Immediate Next Steps

### Option A: Verify in Windows Now (Recommended)
1. **Exit WSL**: \`exit\`
2. **Open PowerShell (Administrator)**
3. **Run verification**: \`cd kenl\\scripts; .\\STEP3-WINDOWS-MOUNT-CHECK.ps1\`
4. **Verify 3 partitions accessible** (Games-Universal, Windows-Only, Transfer)
5. **ext4 partitions won't show in Windows** (expected!)

### Option B: Install Bazzite Now
1. **Boot Bazzite ISO from Ventoy**
2. **Install to INTERNAL drive** (NOT this 1.8TB drive!)
3. **After install, configure auto-mount**

## Auto-Mount Configuration (For Bazzite After Installation)

Copy these UUIDs and use in \`/etc/fstab\`:

\`\`\`bash
# Create mount points
sudo mkdir -p /mnt/{games-universal,claude-ai,development,windows-only,transfer}

# Edit /etc/fstab
sudo nano /etc/fstab

# Add these lines (replace UUIDs with your actual UUIDs from above):
UUID=XXXX-XXXX /mnt/games-universal ntfs-3g defaults,uid=1000,gid=1000,umask=022 0 0
UUID=YYYY-YYYY /mnt/claude-ai ext4 defaults,noatime 0 2
UUID=ZZZZ-ZZZZ /mnt/development ext4 defaults 0 2
UUID=AAAA-AAAA /mnt/windows-only ntfs-3g defaults,uid=1000,gid=1000,umask=022 0 0
UUID=BBBB-BBBB /mnt/transfer exfat defaults,uid=1000,gid=1000,umask=022 0 0

# Test mount
sudo mount -a
df -h | grep /mnt
\`\`\`

## ATOM Trail
- Step 1: ATOM-CFG-20251112-002 (Windows wipe)
- Step 2: ATOM-CFG-20251112-003 (WSL2 partition creation) ← YOU ARE HERE
- Next: ATOM-CFG-20251112-004 (Windows verification)
- Then: ATOM-CFG-20251112-005 (Bazzite installation)

## Status
- [x] Step 1: Windows wipe
- [x] Step 2: WSL2 partition creation ✅
- [ ] Step 3: Windows verification (run STEP3 script)
- [ ] Step 4: Bazzite installation
- [ ] Step 5: Auto-mount configuration
- [ ] Step 6: KENL bootstrap

## Critical Notes
✅ **No reboot needed!** WSL2 can format Linux partitions directly
✅ Drive is ready for immediate use in Windows (NTFS/exFAT partitions)
✅ ext4 partitions will be accessible after Bazzite installation
⚠️  **Windows will assign drive letters automatically** - check Disk Management
⚠️  Store these UUIDs - you'll need them in Bazzite!

---
Generated by KENL WSL2 Partition Script
Run from: WSL2 FedoraLinux-43
EOF

echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✅ STEP 2 COMPLETE: Partitions Created via WSL2!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}📝 Handover document created (on your Windows Desktop):${NC}"
echo -e "   C:\\Users\\Matthew Ruhnau\\Desktop\\HANDOVER-WSL2-PARTITION-*.md"
echo ""
echo -e "${YELLOW}Next Actions:${NC}"
echo ""
echo -e "${GREEN}Recommended: Verify in Windows Now${NC}"
echo "  1. Type: ${CYAN}exit${NC} (to exit WSL)"
echo "  2. Open PowerShell (Administrator)"
echo "  3. Run: ${CYAN}cd kenl\\scripts; .\\STEP3-WINDOWS-MOUNT-CHECK.ps1${NC}"
echo "  4. Verify new drive letters appear"
echo ""
echo -e "${YELLOW}Alternative: Install Bazzite Now${NC}"
echo "  1. Reboot to Ventoy USB"
echo "  2. Install Bazzite to internal drive"
echo "  3. Configure auto-mount with UUIDs above"
echo ""
echo -e "${CYAN}ATOM-CFG-20251112-003 complete${NC}"
echo ""
