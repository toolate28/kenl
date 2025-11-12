#!/usr/bin/env bash
#
# New-GamingPartition.sh
# Creates optimized gaming partition layout on external drive
#
# Version: 1.0.0
# ATOM: ATOM-CFG-20251112-002
# Based on: 1.8TB_EXTERNAL_DRIVE_LAYOUT.md
#
# Usage:
#   ./New-GamingPartition.sh [OPTIONS]
#
# Options:
#   -d, --device DEVICE    Target device (e.g., /dev/sdb) [REQUIRED]
#   -l, --layout LAYOUT    Layout option: hybrid, ntfs-heavy, linux-first [default: hybrid]
#   -y, --yes              Skip confirmation prompts (dangerous!)
#   -n, --dry-run          Show what would be done without making changes
#   -h, --help             Show this help message
#
# Examples:
#   ./New-GamingPartition.sh -d /dev/sdb -l hybrid
#   ./New-GamingPartition.sh -d /dev/sdb -l linux-first --dry-run
#
# WARNING: This script will DESTROY all data on the target device!
#          Make backups before proceeding.
#

set -euo pipefail

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Script metadata
readonly SCRIPT_VERSION="1.0.0"
readonly ATOM_TAG="ATOM-CFG-20251112-002"

# Default values
DEVICE=""
LAYOUT="hybrid"
SKIP_CONFIRM=false
DRY_RUN=false

# Helper functions
log_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

write_atom_log() {
    local message="$1"
    local log_dir="${HOME}/.atom-logs"
    local date=$(date +%Y%m%d)
    local log_file="${log_dir}/atom-${date}.log"

    mkdir -p "$log_dir"

    local counter=$(wc -l < "$log_file" 2>/dev/null || echo 0)
    ((counter++))
    local atom_tag=$(printf "ATOM-CFG-%s-%03d" "$date" "$counter")
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    echo "$timestamp [$atom_tag] $message" | tee -a "$log_file"
}

show_usage() {
    sed -n '2,/^$/p' "$0" | sed 's/^# \?//'
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--device)
                DEVICE="$2"
                shift 2
                ;;
            -l|--layout)
                LAYOUT="$2"
                shift 2
                ;;
            -y|--yes)
                SKIP_CONFIRM=true
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    # Validate required arguments
    if [[ -z "$DEVICE" ]]; then
        log_error "Device is required. Use -d /dev/sdX"
        show_usage
        exit 1
    fi

    # Validate layout option
    case "$LAYOUT" in
        hybrid|ntfs-heavy|linux-first)
            ;;
        *)
            log_error "Invalid layout: $LAYOUT"
            log_error "Valid options: hybrid, ntfs-heavy, linux-first"
            exit 1
            ;;
    esac
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi

    # Check if device exists
    if [[ ! -b "$DEVICE" ]]; then
        log_error "Device not found: $DEVICE"
        exit 1
    fi

    # Check required tools
    local required_tools=("parted" "mkfs.ntfs" "mkfs.ext4" "mkfs.exfat" "lsblk")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log_error "Required tool not found: $tool"
            log_error "Install with: sudo dnf install parted ntfs-3g e2fsprogs exfatprogs"
            exit 1
        fi
    done

    log_success "Prerequisites check passed"
}

# Capture current device state
capture_device_state() {
    log_info "Capturing current device state..."

    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  Current Device Information: $DEVICE"
    echo "═══════════════════════════════════════════════════════════"

    lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT "$DEVICE" || true

    echo ""
    echo "Partition table:"
    parted "$DEVICE" print 2>/dev/null || echo "No partition table found"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
}

# Get partition layout configuration
get_layout_config() {
    case "$LAYOUT" in
        hybrid)
            cat <<EOF
Layout: Hybrid Approach (RECOMMENDED)
Best for: Balanced dual-boot usage, AI development

Partitions:
  1. Games-Universal    900GB   NTFS    (Steam library, both OSes)
  2. Claude-AI-Data     500GB   ext4    (Datasets, models, vectors)
  3. Development        200GB   ext4    (Distrobox, venvs, repos)
  4. Windows-Only       150GB   NTFS    (EA App, anti-cheat games)
  5. Transfer            50GB   exFAT   (Quick file exchange)
EOF
            ;;
        ntfs-heavy)
            cat <<EOF
Layout: Maximum Compatibility (NTFS-Heavy)
Best for: Mostly Windows gaming, occasional Linux access

Partitions:
  1. Games-Shared       1.2TB   NTFS    (Steam library, shared between OSes)
  2. Claude-Workspace   300GB   ext4    (Linux-only AI/dev work)
  3. Backups            200GB   NTFS    (System images, configs)
  4. Projects           100GB   ext4    (Git repos, code)
EOF
            ;;
        linux-first)
            cat <<EOF
Layout: Linux-First (ext4-Heavy)
Best for: Mostly Linux gaming (Proton), Windows for anti-cheat only

Partitions:
  1. Games-Linux        800GB   ext4    (Steam Proton library)
  2. Games-Windows      400GB   NTFS    (Windows-exclusive games)
  3. Claude-AI          400GB   ext4    (LLM models, datasets)
  4. Development        150GB   ext4    (Docker, distrobox, Python)
  5. Shared              50GB   exFAT   (Transfer files between OSes)
EOF
            ;;
    esac
}

# Show partition plan
show_partition_plan() {
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  PARTITION PLAN"
    echo "═══════════════════════════════════════════════════════════"
    get_layout_config
    echo "═══════════════════════════════════════════════════════════"
    echo ""
}

# Confirmation prompt
confirm_operation() {
    if [[ "$SKIP_CONFIRM" == true ]]; then
        log_warn "Skipping confirmation (--yes flag)"
        return 0
    fi

    echo ""
    log_warn "╔════════════════════════════════════════════════════════════╗"
    log_warn "║                     ⚠️  WARNING  ⚠️                        ║"
    log_warn "╚════════════════════════════════════════════════════════════╝"
    echo ""
    log_warn "This will DESTROY ALL DATA on $DEVICE"
    log_warn "All existing partitions and data will be PERMANENTLY ERASED"
    echo ""
    log_info "Device: $DEVICE"
    log_info "Layout: $LAYOUT"
    echo ""

    read -p "Type 'DESTROY' to confirm (or anything else to cancel): " confirm
    if [[ "$confirm" != "DESTROY" ]]; then
        log_info "Operation cancelled by user"
        exit 0
    fi

    echo ""
    read -p "Are you absolutely sure? (yes/no): " confirm2
    if [[ "$confirm2" != "yes" ]]; then
        log_info "Operation cancelled by user"
        exit 0
    fi

    log_success "Confirmation received"
}

# Unmount all partitions on device
unmount_device() {
    log_info "Unmounting all partitions on $DEVICE..."

    # Get all mounted partitions for this device
    local mounted_parts=$(lsblk -no MOUNTPOINT "$DEVICE" | grep -v '^$' || true)

    if [[ -z "$mounted_parts" ]]; then
        log_info "No mounted partitions found"
        return 0
    fi

    while IFS= read -r mountpoint; do
        if [[ -n "$mountpoint" ]]; then
            log_info "Unmounting: $mountpoint"
            if [[ "$DRY_RUN" == false ]]; then
                umount "$mountpoint" || log_warn "Failed to unmount $mountpoint"
            fi
        fi
    done <<< "$mounted_parts"

    log_success "Device unmounted"
}

# Create partitions based on layout
create_partitions_hybrid() {
    log_info "Creating hybrid layout partitions..."

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY RUN] Would create 5 partitions on $DEVICE"
        return 0
    fi

    # Create GPT partition table
    parted -s "$DEVICE" mklabel gpt

    # Create partitions
    parted -s "$DEVICE" mkpart primary ntfs 1MiB 900GiB
    parted -s "$DEVICE" name 1 Games-Universal

    parted -s "$DEVICE" mkpart primary ext4 900GiB 1400GiB
    parted -s "$DEVICE" name 2 Claude-AI-Data

    parted -s "$DEVICE" mkpart primary ext4 1400GiB 1600GiB
    parted -s "$DEVICE" name 3 Development

    parted -s "$DEVICE" mkpart primary ntfs 1600GiB 1750GiB
    parted -s "$DEVICE" name 4 Windows-Only

    parted -s "$DEVICE" mkpart primary fat32 1750GiB 100%
    parted -s "$DEVICE" name 5 Transfer

    log_success "Partitions created"
}

create_partitions_ntfs_heavy() {
    log_info "Creating NTFS-heavy layout partitions..."

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY RUN] Would create 4 partitions on $DEVICE"
        return 0
    fi

    parted -s "$DEVICE" mklabel gpt

    parted -s "$DEVICE" mkpart primary ntfs 1MiB 1200GiB
    parted -s "$DEVICE" name 1 Games-Shared

    parted -s "$DEVICE" mkpart primary ext4 1200GiB 1500GiB
    parted -s "$DEVICE" name 2 Claude-Workspace

    parted -s "$DEVICE" mkpart primary ntfs 1500GiB 1700GiB
    parted -s "$DEVICE" name 3 Backups

    parted -s "$DEVICE" mkpart primary ext4 1700GiB 100%
    parted -s "$DEVICE" name 4 Projects

    log_success "Partitions created"
}

create_partitions_linux_first() {
    log_info "Creating Linux-first layout partitions..."

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY RUN] Would create 5 partitions on $DEVICE"
        return 0
    fi

    parted -s "$DEVICE" mklabel gpt

    parted -s "$DEVICE" mkpart primary ext4 1MiB 800GiB
    parted -s "$DEVICE" name 1 Games-Linux

    parted -s "$DEVICE" mkpart primary ntfs 800GiB 1200GiB
    parted -s "$DEVICE" name 2 Games-Windows

    parted -s "$DEVICE" mkpart primary ext4 1200GiB 1600GiB
    parted -s "$DEVICE" name 3 Claude-AI

    parted -s "$DEVICE" mkpart primary ext4 1600GiB 1750GiB
    parted -s "$DEVICE" name 4 Development

    parted -s "$DEVICE" mkpart primary fat32 1750GiB 100%
    parted -s "$DEVICE" name 5 Shared

    log_success "Partitions created"
}

# Format partitions based on layout
format_partitions_hybrid() {
    log_info "Formatting hybrid layout partitions..."

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY RUN] Would format partitions"
        return 0
    fi

    # Wait for kernel to recognize partitions
    sleep 2
    partprobe "$DEVICE" || true
    sleep 1

    mkfs.ntfs -f -L "Games-Universal" "${DEVICE}1"
    mkfs.ext4 -F -L "Claude-AI-Data" "${DEVICE}2"
    mkfs.ext4 -F -L "Development" "${DEVICE}3"
    mkfs.ntfs -f -L "Windows-Only" "${DEVICE}4"
    mkfs.exfat -n "Transfer" "${DEVICE}5"

    log_success "Partitions formatted"
}

format_partitions_ntfs_heavy() {
    log_info "Formatting NTFS-heavy layout partitions..."

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY RUN] Would format partitions"
        return 0
    fi

    sleep 2
    partprobe "$DEVICE" || true
    sleep 1

    mkfs.ntfs -f -L "Games-Shared" "${DEVICE}1"
    mkfs.ext4 -F -L "Claude-Workspace" "${DEVICE}2"
    mkfs.ntfs -f -L "Backups" "${DEVICE}3"
    mkfs.ext4 -F -L "Projects" "${DEVICE}4"

    log_success "Partitions formatted"
}

format_partitions_linux_first() {
    log_info "Formatting Linux-first layout partitions..."

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY RUN] Would format partitions"
        return 0
    fi

    sleep 2
    partprobe "$DEVICE" || true
    sleep 1

    mkfs.ext4 -F -L "Games-Linux" "${DEVICE}1"
    mkfs.ntfs -f -L "Games-Windows" "${DEVICE}2"
    mkfs.ext4 -F -L "Claude-AI" "${DEVICE}3"
    mkfs.ext4 -F -L "Development" "${DEVICE}4"
    mkfs.exfat -n "Shared" "${DEVICE}5"

    log_success "Partitions formatted"
}

# Verify final state
verify_partitions() {
    log_info "Verifying partition layout..."

    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  Final Partition Layout"
    echo "═══════════════════════════════════════════════════════════"

    lsblk -o NAME,SIZE,FSTYPE,LABEL "${DEVICE}"

    echo "═══════════════════════════════════════════════════════════"
    echo ""

    if [[ "$DRY_RUN" == false ]]; then
        write_atom_log "New-GamingPartition.sh: Created $LAYOUT layout on $DEVICE"
    fi
}

# Generate mount instructions
generate_mount_instructions() {
    log_info "Generating mount instructions..."

    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  Next Steps: Mounting Partitions"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo "1. Get UUIDs:"
    echo "   sudo blkid ${DEVICE}*"
    echo ""
    echo "2. Create mount points:"

    case "$LAYOUT" in
        hybrid)
            cat <<EOF
   sudo mkdir -p /mnt/{games-universal,claude-ai,development,windows-only,transfer}

3. Add to /etc/fstab (replace UUIDs):
   UUID=XXXX-XXXX /mnt/games-universal ntfs-3g defaults,uid=1000,gid=1000,umask=022 0 0
   UUID=YYYY-YYYY /mnt/claude-ai ext4 defaults,noatime 0 2
   UUID=ZZZZ-ZZZZ /mnt/development ext4 defaults,noatime 0 2
   UUID=AAAA-AAAA /mnt/windows-only ntfs-3g defaults,uid=1000,gid=1000,umask=022 0 0
   UUID=BBBB-BBBB /mnt/transfer exfat defaults,uid=1000,gid=1000,umask=022 0 0
EOF
            ;;
        ntfs-heavy)
            cat <<EOF
   sudo mkdir -p /mnt/{games-shared,claude-workspace,backups,projects}

3. Add to /etc/fstab (replace UUIDs):
   UUID=XXXX-XXXX /mnt/games-shared ntfs-3g defaults,uid=1000,gid=1000,umask=022 0 0
   UUID=YYYY-YYYY /mnt/claude-workspace ext4 defaults,noatime 0 2
   UUID=ZZZZ-ZZZZ /mnt/backups ntfs-3g defaults,uid=1000,gid=1000,umask=022 0 0
   UUID=AAAA-AAAA /mnt/projects ext4 defaults,noatime 0 2
EOF
            ;;
        linux-first)
            cat <<EOF
   sudo mkdir -p /mnt/{games-linux,games-windows,claude-ai,development,shared}

3. Add to /etc/fstab (replace UUIDs):
   UUID=XXXX-XXXX /mnt/games-linux ext4 defaults,noatime 0 2
   UUID=YYYY-YYYY /mnt/games-windows ntfs-3g defaults,uid=1000,gid=1000,umask=022 0 0
   UUID=ZZZZ-ZZZZ /mnt/claude-ai ext4 defaults,noatime 0 2
   UUID=AAAA-AAAA /mnt/development ext4 defaults,noatime 0 2
   UUID=BBBB-BBBB /mnt/shared exfat defaults,uid=1000,gid=1000,umask=022 0 0
EOF
            ;;
    esac

    echo ""
    echo "4. Mount all:"
    echo "   sudo mount -a"
    echo ""
    echo "5. Verify:"
    echo "   df -h | grep ${DEVICE##*/}"
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo "Full documentation: scripts/1.8TB_EXTERNAL_DRIVE_LAYOUT.md"
    echo "ATOM Tag: $ATOM_TAG"
    echo ""
}

# Main execution
main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║          New Gaming Partition Script v${SCRIPT_VERSION}           ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""

    parse_args "$@"
    check_prerequisites
    capture_device_state
    show_partition_plan

    if [[ "$DRY_RUN" == false ]]; then
        confirm_operation
        unmount_device
    else
        log_info "DRY RUN MODE - No changes will be made"
    fi

    # Create and format partitions based on layout
    case "$LAYOUT" in
        hybrid)
            create_partitions_hybrid
            format_partitions_hybrid
            ;;
        ntfs-heavy)
            create_partitions_ntfs_heavy
            format_partitions_ntfs_heavy
            ;;
        linux-first)
            create_partitions_linux_first
            format_partitions_linux_first
            ;;
    esac

    verify_partitions
    generate_mount_instructions

    if [[ "$DRY_RUN" == false ]]; then
        log_success "Partition creation complete!"
    else
        log_info "Dry run complete. Run without --dry-run to apply changes."
    fi
}

# Run main function
main "$@"
