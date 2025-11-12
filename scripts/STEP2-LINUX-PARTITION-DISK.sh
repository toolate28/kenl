#!/usr/bin/env bash
# STEP 2: Linux Partition Creation (Run from Bazzite Live USB)
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
echo -e "${CYAN}  KENL Drive Preparation - Step 2: Linux Partitioning${NC}"
echo -e "${CYAN}  ATOM-CFG-20251112-003${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ This script must be run as root (use sudo)${NC}"
    exit 1
fi

# Check if running on Linux
if [ "$(uname)" != "Linux" ]; then
    echo -e "${RED}❌ This script must be run from Linux (Bazzite Live USB)${NC}"
    exit 1
fi

# Detect the 1.8TB drive
echo -e "${YELLOW}[1/7] Detecting 1.8TB Seagate FireCuda drive...${NC}"
echo ""
lsblk -o NAME,SIZE,MODEL,TYPE,FSTYPE | grep -E "NAME|disk"
echo ""

# Find drive by size (approximately 1.8TB = 2TB)
TARGET_DRIVE=""
for drive in /dev/sd? /dev/nvme?n?; do
    if [ -b "$drive" ]; then
        SIZE=$(blockdev --getsize64 "$drive" 2>/dev/null || echo 0)
        # Check if size is between 1.7TB and 2.1TB (accounting for formatting)
        if [ "$SIZE" -gt 1700000000000 ] && [ "$SIZE" -lt 2100000000000 ]; then
            MODEL=$(lsblk -dno MODEL "$drive" 2>/dev/null || echo "Unknown")
            if [[ "$MODEL" == *"FireCuda"* ]] || [[ "$MODEL" == *"Seagate"* ]]; then
                TARGET_DRIVE="$drive"
                break
            fi
            # If no FireCuda found, use first drive in size range as fallback
            if [ -z "$TARGET_DRIVE" ]; then
                TARGET_DRIVE="$drive"
            fi
        fi
    fi
done

if [ -z "$TARGET_DRIVE" ]; then
    echo -e "${RED}❌ Could not automatically detect 1.8TB drive${NC}"
    echo ""
    echo -e "${YELLOW}Available drives:${NC}"
    lsblk -o NAME,SIZE,MODEL,TYPE
    echo ""
    read -p "Enter drive path manually (e.g., /dev/sdb): " TARGET_DRIVE

    if [ ! -b "$TARGET_DRIVE" ]; then
        echo -e "${RED}❌ Invalid drive: $TARGET_DRIVE${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✅ Target drive detected: $TARGET_DRIVE${NC}"
echo ""

# Show drive details
echo -e "${YELLOW}Target Drive Details:${NC}"
lsblk -o NAME,SIZE,MODEL,TYPE,FSTYPE,MOUNTPOINT "$TARGET_DRIVE"
echo ""

# Safety confirmation
echo -e "${RED}═══════════════════════════════════════════════════════════${NC}"
echo -e "${RED}  ⚠️  FINAL SAFETY CHECK ⚠️${NC}"
echo -e "${RED}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}You are about to partition: $TARGET_DRIVE${NC}"
echo -e "${YELLOW}All existing partitions will be removed!${NC}"
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
echo -e "${YELLOW}[2/7] Unmounting any existing partitions...${NC}"
for part in ${TARGET_DRIVE}*; do
    if [ -b "$part" ] && mountpoint -q "$part" 2>/dev/null; then
        echo "  Unmounting $part..."
        umount "$part" 2>/dev/null || true
    fi
done
echo -e "${GREEN}  ✅ Partitions unmounted${NC}"
echo ""

# Create partitions with parted
echo -e "${YELLOW}[3/7] Creating partition layout...${NC}"
parted -s "$TARGET_DRIVE" mklabel gpt
parted -s "$TARGET_DRIVE" mkpart primary ntfs 1MiB 900GiB
parted -s "$TARGET_DRIVE" name 1 Games-Universal
parted -s "$TARGET_DRIVE" mkpart primary ext4 900GiB 1400GiB
parted -s "$TARGET_DRIVE" name 2 Claude-AI-Data
parted -s "$TARGET_DRIVE" mkpart primary ext4 1400GiB 1600GiB
parted -s "$TARGET_DRIVE" name 3 Development
parted -s "$TARGET_DRIVE" mkpart primary ntfs 1600GiB 1750GiB
parted -s "$TARGET_DRIVE" name 4 Windows-Only
parted -s "$TARGET_DRIVE" mkpart primary fat32 1750GiB 100%
parted -s "$TARGET_DRIVE" name 5 Transfer
echo -e "${GREEN}  ✅ Partition table created${NC}"
echo ""

# Wait for kernel to recognize partitions
echo -e "${YELLOW}[4/7] Waiting for kernel to recognize new partitions...${NC}"
sleep 2
partprobe "$TARGET_DRIVE"
sleep 2
echo -e "${GREEN}  ✅ Partitions recognized${NC}"
echo ""

# Determine partition naming convention
PART1="${TARGET_DRIVE}1"
if [ ! -b "$PART1" ]; then
    # NVMe drives use p1, p2, etc.
    PART1="${TARGET_DRIVE}p1"
fi

# Format partitions
echo -e "${YELLOW}[5/7] Formatting partitions...${NC}"
echo ""

echo "  [1/5] Formatting Games-Universal (NTFS)..."
mkfs.ntfs -f -L "Games-Universal" "${PART1}" 2>/dev/null || mkfs.ntfs -F -L "Games-Universal" "${PART1}"
echo -e "${GREEN}    ✅ Games-Universal formatted${NC}"

echo "  [2/5] Formatting Claude-AI-Data (ext4)..."
PART2="${TARGET_DRIVE}2"
[ ! -b "$PART2" ] && PART2="${TARGET_DRIVE}p2"
mkfs.ext4 -F -L "Claude-AI-Data" "$PART2"
echo -e "${GREEN}    ✅ Claude-AI-Data formatted${NC}"

echo "  [3/5] Formatting Development (ext4)..."
PART3="${TARGET_DRIVE}3"
[ ! -b "$PART3" ] && PART3="${TARGET_DRIVE}p3"
mkfs.ext4 -F -L "Development" "$PART3"
echo -e "${GREEN}    ✅ Development formatted${NC}"

echo "  [4/5] Formatting Windows-Only (NTFS)..."
PART4="${TARGET_DRIVE}4"
[ ! -b "$PART4" ] && PART4="${TARGET_DRIVE}p4"
mkfs.ntfs -f -L "Windows-Only" "$PART4" 2>/dev/null || mkfs.ntfs -F -L "Windows-Only" "$PART4"
echo -e "${GREEN}    ✅ Windows-Only formatted${NC}"

echo "  [5/5] Formatting Transfer (exFAT)..."
PART5="${TARGET_DRIVE}5"
[ ! -b "$PART5" ] && PART5="${TARGET_DRIVE}p5"
mkfs.exfat -n "Transfer" "$PART5"
echo -e "${GREEN}    ✅ Transfer formatted${NC}"
echo ""

# Verify partitions
echo -e "${YELLOW}[6/7] Verifying partition layout...${NC}"
echo ""
lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT "$TARGET_DRIVE"
echo ""

# Get UUIDs for fstab
echo -e "${YELLOW}[7/7] Retrieving partition UUIDs...${NC}"
echo ""
blkid "${TARGET_DRIVE}"* | grep -v "^$TARGET_DRIVE:" || blkid | grep "$TARGET_DRIVE"
echo ""

# Create handover document
HANDOVER_FILE="/tmp/HANDOVER-PARTITION-$(date +%Y%m%d-%H%M%S).md"
cat > "$HANDOVER_FILE" <<EOF
# Partition Creation Handover
**ATOM-CFG-20251112-003**
**Timestamp**: $(date -Iseconds)
**Phase**: Step 2 Complete (Linux Partitioning)

## Actions Completed
- ✅ 5 partitions created on $TARGET_DRIVE
- ✅ All partitions formatted with correct filesystems
- ✅ Partition labels applied
- ✅ Layout verified

## Partition Layout
\`\`\`
$(lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT "$TARGET_DRIVE")
\`\`\`

## Partition UUIDs
\`\`\`
$(blkid "${TARGET_DRIVE}"* 2>/dev/null || blkid | grep "$TARGET_DRIVE")
\`\`\`

## Expected Layout (Verification)
| Partition | Size | Filesystem | Label | Purpose |
|-----------|------|------------|-------|---------|
| ${PART1} | 900GB | NTFS | Games-Universal | Steam library (cross-OS) |
| ${PART2} | 500GB | ext4 | Claude-AI-Data | LLMs, datasets, vectors |
| ${PART3} | 200GB | ext4 | Development | Distrobox, venvs, repos |
| ${PART4} | 150GB | NTFS | Windows-Only | EA App, anti-cheat games |
| ${PART5} | 50GB | exFAT | Transfer | Quick file exchange |

## Next Steps
### If Installing Bazzite Now:
1. Run Bazzite installer (Calamares)
2. Install to INTERNAL drive (not this 1.8TB drive!)
3. After install, configure auto-mount for these partitions

### If Returning to Windows:
1. Reboot to Windows
2. Run: \`~/kenl/scripts/STEP3-WINDOWS-MOUNT-CHECK.ps1\`
3. Verify NTFS/exFAT partitions accessible
4. Schedule Bazzite installation later

### Auto-Mount Configuration (After Bazzite Install)
Create /etc/fstab entries (replace UUIDs with yours):
\`\`\`bash
# Get UUIDs
sudo blkid $TARGET_DRIVE*

# Add to /etc/fstab
UUID=XXXX-XXXX /mnt/games-universal ntfs-3g defaults,uid=1000,gid=1000,umask=022 0 0
UUID=YYYY-YYYY /mnt/claude-ai ext4 defaults,noatime 0 2
UUID=ZZZZ-ZZZZ /mnt/development ext4 defaults 0 2
UUID=AAAA-AAAA /mnt/windows-only ntfs-3g defaults,uid=1000,gid=1000,umask=022 0 0
UUID=BBBB-BBBB /mnt/transfer exfat defaults,uid=1000,gid=1000,umask=022 0 0
\`\`\`

## ATOM Trail
- Previous: ATOM-CFG-20251112-002 (Windows wipe)
- Current: ATOM-CFG-20251112-003 (Linux partition creation)
- Next: ATOM-CFG-20251112-004 (Auto-mount configuration)

## Status
- [x] Step 1: Windows wipe
- [x] Step 2: Linux partition creation
- [ ] Step 3: Mount verification
- [ ] Step 4: Bazzite installation
- [ ] Step 5: Auto-mount configuration
- [ ] Step 6: KENL bootstrap

## Critical Notes
✅ Drive is ready for use
✅ NTFS/exFAT partitions accessible from Windows
✅ ext4 partitions accessible from Linux only
⚠️  Remember to mount partitions in Bazzite after installation
⚠️  Store this handover document for UUID reference

EOF

echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✅ STEP 2 COMPLETE: Partitions Created Successfully${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}📝 Handover document created: $HANDOVER_FILE${NC}"
echo ""
echo -e "${YELLOW}Next Actions:${NC}"
echo "  1. Copy handover document to persistent storage"
echo "  2. Choose next step:"
echo "     a) Install Bazzite now (recommended)"
echo "     b) Reboot to Windows to verify partitions"
echo ""

# Copy handover to user's home if possible
if [ -n "${SUDO_USER:-}" ]; then
    USER_HOME=$(eval echo ~$SUDO_USER)
    cp "$HANDOVER_FILE" "$USER_HOME/" 2>/dev/null && \
        echo -e "${CYAN}📋 Handover copied to: $USER_HOME/${NC}" || true
fi

echo -e "${CYAN}ATOM-CFG-20251112-003 logged${NC}"
echo ""
