---
project: KENL - Real World Scenario 06
status: production
version: 1.0.0
classification: OWI-DOC
atom: ATOM-DOC-20251110-016
owi-version: 1.0.0
---

# RWS-06: Complete Dual-Boot Gaming Setup (End-to-End)

**Scenario**: Fresh machine setup with Windows 11 + Bazzite dual-boot for gaming, complete validation and handover procedures for instance continuity across reboots.

**Timeline**: 4-6 hours (first-time setup)
**Complexity**: High (covers full stack from BIOS to gaming validation)
**Prerequisite**: Physical machine with 2 HDDs/SSDs

---

## Overview

This storyboard demonstrates **complete end-to-end setup** from cloning the repository to validated gaming on a dual-boot system. It includes:

1. **Pre-flight validation** - Hardware/firmware checks before starting
2. **Windows 11 parameter verification** - TPM 2.0, Secure Boot, UEFI mode
3. **Dual-boot preparation** - Partitioning, bootloader configuration
4. **Bazzite installation** - Gaming-optimized immutable Linux
5. **Container setup** - Distrobox environments for development
6. **Gaming configuration** - Proton, Play Cards, driver validation
7. **Post-installation validation** - Complete system verification
8. **Handover mechanism** - Instance continuity across reboots

### Expectations vs Reality Framework

Each phase includes:
- **Expected Outcome**: What should happen
- **Reality Check**: What actually happened
- **Diff Analysis**: Deviations and adjustments
- **Handover Notes**: What the next instance needs to know

---

## Phase 0: Pre-Flight Validation

**Duration**: 15-30 minutes
**Objective**: Verify hardware compatibility and capture baseline state

### Pre-Flight Checklist

```bash
# Create pre-flight validation script
cd ~/
mkdir -p kenl-setup && cd kenl-setup

# Download pre-flight checker
curl -O https://raw.githubusercontent.com/toolate28/kenl/main/scripts/preflight-validator.sh
chmod +x preflight-validator.sh

# Run validation
./preflight-validator.sh --full-report
```

### Expected Baseline

```yaml
hardware:
  cpu:
    expected: "Modern x86_64 CPU (2015+)"
    min_cores: 4
    virtualization: "Intel VT-x / AMD-V enabled"

  ram:
    expected: "16GB minimum"
    recommended: "32GB for gaming + containers"

  storage:
    primary_drive:
      expected: "NVMe/SSD 256GB+"
      purpose: "Windows 11"
    secondary_drive:
      expected: "NVMe/SSD 512GB+"
      purpose: "Bazzite Linux"

  gpu:
    expected: "Dedicated GPU (NVIDIA/AMD)"
    nvidia_note: "Will require proprietary drivers"
    amd_note: "Open-source drivers in kernel"

firmware:
  uefi_mode:
    expected: true
    validation: "Legacy BIOS not supported for Secure Boot"

  secure_boot:
    expected: "Enabled (can be configured later)"
    note: "Required for Windows 11, optional for Bazzite"

  tpm:
    version: "TPM 2.0"
    status: "Enabled"
    required_for: "Windows 11"

  virtualization:
    intel_vt_x: true
    amd_v: true
    required_for: "Distrobox containers"

network:
  connection: "Active internet connection required"
  bandwidth: "Stable connection for ISO downloads (4-6 GB)"
```

### Pre-Flight Validation Script

```bash
#!/bin/bash
# scripts/preflight-validator.sh

set -euo pipefail

OUTPUT_DIR="$HOME/kenl-setup/preflight-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUTPUT_DIR"

echo "🔍 KENL Pre-Flight Validation"
echo "=============================="
echo ""
echo "Output directory: $OUTPUT_DIR"
echo ""

# Hardware detection
echo "📊 Hardware Detection..."
{
    echo "=== CPU ==="
    lscpu | grep -E "Model name|CPU\(s\)|Thread|Virtualization"
    echo ""

    echo "=== Memory ==="
    free -h
    echo ""

    echo "=== Storage ==="
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT
    echo ""

    echo "=== GPU ==="
    lspci | grep -i vga
    lspci | grep -i 3d
    echo ""
} | tee "$OUTPUT_DIR/hardware-detection.txt"

# Firmware detection
echo "🔐 Firmware Configuration..."
{
    echo "=== UEFI Mode ==="
    if [ -d /sys/firmware/efi ]; then
        echo "✅ UEFI mode detected"
    else
        echo "❌ Legacy BIOS mode detected (UEFI required!)"
    fi
    echo ""

    echo "=== Secure Boot ==="
    if command -v mokutil &> /dev/null; then
        mokutil --sb-state || echo "mokutil not available (OK if on Windows)"
    else
        echo "⚠️  mokutil not found (check after Linux install)"
    fi
    echo ""

    echo "=== TPM 2.0 ==="
    if [ -e /dev/tpm0 ]; then
        echo "✅ TPM device detected: /dev/tpm0"
        if command -v tpm2_getcap &> /dev/null; then
            tpm2_getcap properties-fixed || echo "TPM tools not installed (OK for now)"
        fi
    else
        echo "❌ TPM device not found (required for Windows 11!)"
    fi
    echo ""

    echo "=== Virtualization ==="
    if grep -qE 'vmx|svm' /proc/cpuinfo; then
        echo "✅ CPU virtualization enabled"
        grep -E 'vmx|svm' /proc/cpuinfo | head -1
    else
        echo "❌ CPU virtualization not detected (required for containers!)"
    fi
    echo ""
} | tee "$OUTPUT_DIR/firmware-config.txt"

# Network detection
echo "🌐 Network Status..."
{
    echo "=== Network Interfaces ==="
    ip addr show | grep -E "^[0-9]+:|inet "
    echo ""

    echo "=== Internet Connectivity ==="
    if ping -c 3 8.8.8.8 &> /dev/null; then
        echo "✅ Internet connection active"
    else
        echo "❌ No internet connection (required for downloads!)"
    fi
    echo ""
} | tee "$OUTPUT_DIR/network-status.txt"

# Generate expectations file
echo "📝 Generating expectations document..."
cat > "$OUTPUT_DIR/EXPECTATIONS.yaml" <<'EOF'
---
# Pre-Flight Expectations vs Reality
# Generated: $(date -Iseconds)

phase: pre-flight
status: pending

expectations:
  uefi_mode:
    expected: true
    actual: null  # Fill after validation
    status: pending

  secure_boot:
    expected: true
    actual: null
    status: pending

  tpm_version:
    expected: "2.0"
    actual: null
    status: pending

  virtualization:
    expected: true
    actual: null
    status: pending

  storage_layout:
    primary_drive:
      expected: "Windows 11"
      actual: null
      status: pending
    secondary_drive:
      expected: "Available for Bazzite"
      actual: null
      status: pending

deviations: []

handover_notes:
  - "Review all validation outputs in $OUTPUT_DIR"
  - "Verify UEFI mode before proceeding"
  - "Confirm TPM 2.0 enabled in BIOS if not detected"
  - "Enable CPU virtualization if disabled"

next_phase: "windows-11-verification"
EOF

echo ""
echo "✅ Pre-flight validation complete!"
echo ""
echo "📁 Results saved to: $OUTPUT_DIR"
echo ""
echo "Next steps:"
echo "1. Review all .txt files in output directory"
echo "2. Update EXPECTATIONS.yaml with actual values"
echo "3. Fix any ❌ failures before proceeding"
echo "4. Continue to Phase 1: Windows 11 Verification"
```

### Reality Check Template

```yaml
# After running pre-flight validation, fill this out

reality:
  uefi_mode:
    actual: true  # or false
    deviation: null
    action_taken: null

  secure_boot:
    actual: true
    deviation: null
    action_taken: null

  tpm_version:
    actual: "2.0"
    deviation: null
    action_taken: null

  virtualization:
    actual: true
    deviation: "Was disabled, enabled in BIOS"
    action_taken: "Rebooted into BIOS, enabled Intel VT-x"

  storage_layout:
    primary_drive:
      device: "/dev/nvme0n1"
      size: "512GB"
      current_use: "Windows 11"
    secondary_drive:
      device: "/dev/nvme1n1"
      size: "1TB"
      current_use: "Empty (ready for Bazzite)"
```

---

## Phase 1: Windows 11 Parameter Verification

**Duration**: 15-30 minutes
**Objective**: Verify Windows 11 installation meets dual-boot requirements

### Windows 11 Validation Checklist

Boot into Windows 11 and run these commands in PowerShell (Administrator):

```powershell
# Create validation script
$OutputDir = "$env:USERPROFILE\Desktop\kenl-win11-validation"
New-Item -ItemType Directory -Force -Path $OutputDir

# System Information
Get-ComputerInfo | Out-File "$OutputDir\system-info.txt"

# TPM Status
Get-Tpm | Out-File "$OutputDir\tpm-status.txt"

# Secure Boot Status
Confirm-SecureBootUEFI | Out-File "$OutputDir\secure-boot-status.txt"

# Disk Layout
Get-Disk | Format-Table -AutoSize | Out-File "$OutputDir\disk-layout.txt"
Get-Partition | Format-Table -AutoSize | Out-File "$OutputDir\partitions.txt"

# Bitlocker Status (important for dual-boot)
Get-BitLockerVolume | Format-Table -AutoSize | Out-File "$OutputDir\bitlocker-status.txt"

# Virtualization Check
Get-WmiObject -Class Win32_Processor | Select-Object Name, VirtualizationFirmwareEnabled | Out-File "$OutputDir\virtualization.txt"

Write-Host "✅ Windows 11 validation complete!"
Write-Host "📁 Results: $OutputDir"
```

### Expected Windows 11 Configuration

```yaml
windows_11:
  version:
    expected: "22H2 or newer"
    check: "winver"

  tpm:
    enabled: true
    version: "2.0"
    ownership: "Owned"

  secure_boot:
    status: "Enabled"
    note: "Must configure MOK for Linux kernel signing"

  disk_layout:
    system_drive:
      type: "GPT"
      efi_partition: "100-500MB"
      recovery_partition: "Present"
      windows_partition: "Remainder"

    second_drive:
      status: "Unallocated or formatted"
      note: "Will be wiped for Bazzite installation"

  bitlocker:
    status: "Disabled or suspended"
    reason: "BitLocker can interfere with dual-boot bootloader"

  fast_startup:
    status: "Disabled"
    reason: "Fast Startup locks NTFS partitions for Linux"

  hibernation:
    status: "Optional (disable recommended)"
    reason: "Reduces partition locking issues"
```

### Windows 11 Preparation Script

```powershell
# scripts/windows11-dual-boot-prep.ps1
# Run as Administrator

Write-Host "🪟 Preparing Windows 11 for Dual-Boot"
Write-Host "======================================"
Write-Host ""

# Disable Fast Startup
Write-Host "⚙️  Disabling Fast Startup..."
powercfg /hibernate off
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 0
Write-Host "✅ Fast Startup disabled"
Write-Host ""

# Check BitLocker
Write-Host "🔐 Checking BitLocker status..."
$BitLockerStatus = Get-BitLockerVolume -MountPoint "C:"
if ($BitLockerStatus.ProtectionStatus -eq "On") {
    Write-Host "⚠️  BitLocker is ENABLED"
    Write-Host "   Recommendation: Suspend BitLocker before Linux install"
    Write-Host "   Command: Suspend-BitLocker -MountPoint 'C:' -RebootCount 0"
} else {
    Write-Host "✅ BitLocker not active"
}
Write-Host ""

# Check Secure Boot
Write-Host "🔒 Checking Secure Boot..."
$SecureBoot = Confirm-SecureBootUEFI
if ($SecureBoot) {
    Write-Host "✅ Secure Boot: Enabled"
    Write-Host "   Note: You'll need to enroll MOK keys for Bazzite"
} else {
    Write-Host "⚠️  Secure Boot: Disabled"
}
Write-Host ""

# Check TPM
Write-Host "🔑 Checking TPM 2.0..."
$TPM = Get-Tpm
if ($TPM.TpmPresent -and $TPM.TpmReady) {
    Write-Host "✅ TPM 2.0: Present and ready"
} else {
    Write-Host "❌ TPM 2.0: Not ready (required for Windows 11!)"
}
Write-Host ""

# Disk space check
Write-Host "💾 Checking disk space..."
Get-Disk | ForEach-Object {
    $DiskNum = $_.Number
    $DiskSize = [math]::Round($_.Size / 1GB, 2)
    Write-Host "   Disk $DiskNum`: $DiskSize GB"
}
Write-Host ""

# Create expectations file
$ExpectationsPath = "$env:USERPROFILE\Desktop\kenl-win11-validation\EXPECTATIONS-WIN11.yaml"
@"
---
# Windows 11 Validation Results
# Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

phase: windows-11-verification
status: complete

expectations:
  fast_startup:
    expected: false
    actual: $((Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled").HiberbootEnabled -eq 0)
    status: $(if ((Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled").HiberbootEnabled -eq 0) { "pass" } else { "fail" })

  bitlocker:
    expected: false
    actual: $($BitLockerStatus.ProtectionStatus -eq "On")
    status: $(if ($BitLockerStatus.ProtectionStatus -ne "On") { "pass" } else { "warn" })

  secure_boot:
    expected: true
    actual: $SecureBoot
    status: $(if ($SecureBoot) { "pass" } else { "warn" })

  tpm:
    expected: true
    actual: $($TPM.TpmPresent -and $TPM.TpmReady)
    status: $(if ($TPM.TpmPresent -and $TPM.TpmReady) { "pass" } else { "fail" })

deviations: []

handover_notes:
  - "Windows 11 preparation complete"
  - "Fast Startup disabled - safe to proceed"
  - "Review BitLocker status before Linux install"
  - "MOK enrollment required if Secure Boot enabled"

next_phase: "dual-boot-partitioning"
"@ | Out-File -FilePath $ExpectationsPath

Write-Host "📝 Expectations file created: $ExpectationsPath"
Write-Host ""
Write-Host "✅ Windows 11 preparation complete!"
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Reboot to apply Fast Startup changes"
Write-Host "2. Download Bazzite ISO"
Write-Host "3. Create bootable USB with Rufus or Ventoy"
Write-Host "4. Continue to Phase 2: Dual-Boot Partitioning"
```

---

## Phase 2: Dual-Boot Partitioning Strategy

**Duration**: 30 minutes (planning) + 1-2 hours (execution)
**Objective**: Prepare second drive for Bazzite without affecting Windows 11

### Recommended Partition Layout

```
Drive 0 (Primary): Windows 11
┌────────────────────────────────────────────┐
│ EFI System (ESP)         │ 512MB  │ FAT32  │
│ Windows Recovery         │ 500MB  │ NTFS   │
│ Windows C:\              │ Rest   │ NTFS   │
└────────────────────────────────────────────┘

Drive 1 (Secondary): Bazzite Linux
┌────────────────────────────────────────────┐
│ /boot (shared EFI)       │ 1GB    │ FAT32  │
│ / (root)                 │ 50GB   │ BTRFS  │
│ /home                    │ Rest   │ BTRFS  │
│ swap (optional)          │ 16-32GB│ swap   │
└────────────────────────────────────────────┘

Alternative: Single BTRFS with subvolumes
┌────────────────────────────────────────────┐
│ /boot (shared EFI)       │ 1GB    │ FAT32  │
│ BTRFS (all subvolumes)   │ Rest   │ BTRFS  │
│   ├─ @ (root)                              │
│   ├─ @home                                 │
│   ├─ @var_log                              │
│   └─ @snapshots                            │
└────────────────────────────────────────────┘
```

### Partitioning Expectations

```yaml
partitioning:
  strategy: "dedicated-second-drive"

  drive_0_windows:
    device: "/dev/nvme0n1"
    partition_table: "GPT"
    partitions:
      - number: 1
        type: "EFI System"
        size: "512MB"
        filesystem: "FAT32"
        mountpoint: "/boot/efi (from Linux)"
        note: "Shared EFI partition"

      - number: 2
        type: "Microsoft Reserved"
        size: "16MB"
        note: "Windows required partition"

      - number: 3
        type: "Windows"
        filesystem: "NTFS"
        mountpoint: "C:\"
        note: "Do not modify from Linux"

      - number: 4
        type: "Windows Recovery"
        size: "500MB"
        filesystem: "NTFS"
        note: "Windows recovery tools"

  drive_1_bazzite:
    device: "/dev/nvme1n1"
    partition_table: "GPT"
    partitions:
      - number: 1
        type: "Linux filesystem"
        size: "1GB"
        filesystem: "FAT32"
        label: "BAZZITE_BOOT"
        mountpoint: "/boot"
        note: "Optional: can share Windows EFI instead"

      - number: 2
        type: "Linux filesystem"
        size: "Rest"
        filesystem: "BTRFS"
        label: "BAZZITE_ROOT"
        mountpoint: "/"
        subvolumes:
          - "@"
          - "@home"
          - "@var_log"
          - "@snapshots"

  bootloader:
    type: "GRUB2"
    install_location: "/dev/nvme0n1 EFI partition"
    config:
      - os_prober: true
      - windows_entry: "Windows Boot Manager"
      - default: "Bazzite Linux"
      - timeout: 10

  expected_boot_menu:
    - "Bazzite Linux"
    - "Bazzite Linux (fallback)"
    - "Windows Boot Manager"
```

### Pre-Install Checklist

Before booting Bazzite installer:

```bash
# From Bazzite Live USB
# Verify drives are detected

lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,LABEL

# Expected output:
# NAME          SIZE TYPE FSTYPE MOUNTPOINT LABEL
# nvme0n1     512GB disk
# ├─nvme0n1p1  512M part vfat              EFI
# ├─nvme0n1p2   16M part
# ├─nvme0n1p3  500G part ntfs              Windows
# └─nvme0n1p4  500M part ntfs              Recovery
# nvme1n1       1TB disk
# (empty - ready for installation)

# Verify UEFI mode
[ -d /sys/firmware/efi ] && echo "✅ UEFI mode" || echo "❌ Legacy BIOS"

# Verify Secure Boot status
mokutil --sb-state || echo "⚠️  Secure Boot check failed"
```

---

## Phase 3: Bazzite Installation

**Duration**: 30-60 minutes
**Objective**: Install Bazzite Linux to secondary drive with proper dual-boot configuration

### Installation Parameters

```yaml
installation:
  iso:
    source: "https://download.bazzite.gg/"
    version: "latest stable"
    variant: "bazzite-deck (gaming optimized)"
    checksum_verify: true

  installation_method:
    type: "Calamares installer"
    mode: "Manual partitioning"

  manual_partitioning:
    device: "/dev/nvme1n1"

    partition_1:
      mountpoint: "/boot/efi"
      filesystem: "FAT32"
      size: "1GB"
      flags: ["boot", "esp"]

    partition_2:
      mountpoint: "/"
      filesystem: "BTRFS"
      size: "remainder"
      compression: "zstd"
      subvolumes:
        - name: "@"
          mountpoint: "/"
        - name: "@home"
          mountpoint: "/home"
        - name: "@var_log"
          mountpoint: "/var/log"

  bootloader:
    install: true
    location: "/dev/nvme0n1p1 (shared EFI partition)"
    type: "GRUB2"
    enable_os_prober: true

  user_account:
    username: "bazza"
    realname: "Gaming User"
    autologin: false
    sudo_access: true

  hostname: "bazzite-gaming-rig"

  timezone: "America/New_York"  # Adjust to your location

  keyboard: "us"

  locale: "en_US.UTF-8"
```

### Installation Expectations vs Reality

```yaml
installation_reality:
  expected_duration: "30-45 minutes"
  actual_duration: null  # Fill after install

  expected_outcome:
    - "Bazzite installed to /dev/nvme1n1"
    - "GRUB bootloader shows both OS options"
    - "Windows 11 boots successfully"
    - "Bazzite boots successfully"

  deviations:
    - issue: null
      expected: null
      actual: null
      resolution: null

  handover_checkpoint:
    timestamp: null
    status: null
    notes:
      - "Installation completed successfully"
      - "GRUB menu configured and tested"
      - "Both OS boot successfully"
      - "Ready for Phase 4: First Boot Configuration"
```

### Post-Install Validation (Before Reboot)

```bash
# From installer before final reboot
# Verify installation

# Check partitions were created
lsblk -f /dev/nvme1n1

# Verify GRUB installation
test -d /boot/efi/EFI/fedora && echo "✅ GRUB installed" || echo "❌ GRUB missing"

# Check for Windows boot entry
efibootmgr | grep -i windows && echo "✅ Windows entry found" || echo "❌ Windows entry missing"

# Create handover document
cat > /tmp/HANDOVER-PHASE3-TO-PHASE4.md <<'EOF'
# Handover: Phase 3 → Phase 4
# Post-Installation Reboot

## What Was Done
- Bazzite installed to /dev/nvme1n1
- GRUB bootloader configured
- Manual partitioning with BTRFS subvolumes
- User account created: bazza

## Expected First Boot
1. GRUB menu appears with options:
   - Bazzite Linux
   - Windows Boot Manager
2. Select Bazzite Linux
3. Boot to GDM login screen
4. Login as bazza
5. First-boot setup wizard may appear

## Potential Issues
- GRUB doesn't appear: Check BIOS boot order
- Windows doesn't boot: os-prober may need manual configuration
- Secure Boot blocks boot: Enroll MOK keys

## Next Instance Tasks
1. Boot into Bazzite
2. Verify network connectivity
3. Run system updates
4. Clone KENL repository
5. Begin container setup

## Critical Commands for Next Instance
```bash
# Verify boot
systemctl status
rpm-ostree status

# Check network
ip addr
ping 8.8.8.8

# Update system
rpm-ostree upgrade

# Clone KENL
git clone https://github.com/toolate28/kenl.git ~/.kenl
```

## Status
- [x] Installation complete
- [ ] First boot successful
- [ ] Network configured
- [ ] System updated
- [ ] KENL cloned
EOF

cp /tmp/HANDOVER-PHASE3-TO-PHASE4.md /home/bazza/Desktop/ 2>/dev/null || echo "Copy handover to Desktop after first boot"
```

---

## Phase 4: First Boot & System Configuration

**Duration**: 45-60 minutes
**Objective**: Configure Bazzite system, verify hardware, prepare for container setup

### First Boot Checklist

Boot into Bazzite for the first time and run:

```bash
# First boot validation script
cd ~/
cat > first-boot-validation.sh <<'EOF'
#!/bin/bash
set -euo pipefail

echo "🚀 Bazzite First Boot Validation"
echo "================================="
echo ""

# System status
echo "📊 System Status..."
systemctl is-system-running
rpm-ostree status
echo ""

# Network
echo "🌐 Network..."
ip addr show | grep -E "^[0-9]+:|inet "
ping -c 3 8.8.8.8 && echo "✅ Internet OK" || echo "❌ No internet"
echo ""

# Hardware
echo "🖥️  Hardware..."
echo "GPU: $(lspci | grep -i vga)"
echo "CPU: $(lscpu | grep 'Model name' | cut -d: -f2 | xargs)"
echo "RAM: $(free -h | grep Mem | awk '{print $2}')"
echo ""

# Dual-boot verification
echo "🪟 Dual-Boot Check..."
efibootmgr | grep -i windows && echo "✅ Windows entry present" || echo "⚠️  Windows entry missing"
echo ""

echo "✅ First boot validation complete"
EOF

chmod +x first-boot-validation.sh
./first-boot-validation.sh
```

---

## Phase 5: Container Setup (Distrobox)

**Duration**: 30-45 minutes
**Objective**: Create isolated development/gaming containers

```bash
# Clone KENL repository
git clone https://github.com/toolate28/kenl.git ~/.kenl
cd ~/.kenl

# Create Ubuntu development container
distrobox create --name ubuntu-dev --image docker.io/library/ubuntu:24.04

# Enter and configure
distrobox enter ubuntu-dev
# Inside container:
sudo apt update && sudo apt install -y build-essential git curl vim

# Verify container isolation
echo "Container hostname: $(hostname)"
exit

# Create container validation expectations
cat > ~/container-expectations.yaml <<'EOF'
containers:
  ubuntu-dev:
    expected_packages:
      - build-essential
      - git
      - curl
    expected_user: "same as host"
    expected_home: "shared with host"
    network_access: true
    gpu_access: false  # Enable for gaming container
EOF
```

---

## Phase 6: Gaming Configuration

**Duration**: 1-2 hours
**Objective**: Configure Proton, validate GPU drivers, create first Play Card

```bash
# Update system (includes latest drivers)
rpm-ostree upgrade
systemctl reboot

# After reboot - verify GPU drivers
lspci -k | grep -A 3 VGA  # Check driver in use

# For NVIDIA (if applicable)
rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia-cuda

# Install Proton GE
cd ~/.local/share/Steam/compatibilitytools.d
curl -L https://github.com/GloriousEggroll/proton-ge-custom/releases/latest/download/GE-Proton.tar.gz | tar xz

# Create first Play Card
cd ~/.kenl/modules/KENL2-gaming/play-cards
cp template.yaml halo-infinite.yaml
# Edit and test

# Validate gaming stack
~/.kenl/scripts/validate-gaming-stack.sh
```

---

## Phase 7: Complete Validation & Handover

**Final Checklist** - Run all validations:

```bash
# Create master validation script
cat > ~/final-validation.sh <<'EOF'
#!/bin/bash

echo "🎯 COMPLETE SYSTEM VALIDATION"
echo "=============================="
echo ""

# 1. Dual-boot
echo "1️⃣  Dual-Boot..."
efibootmgr | grep -q "Windows" && echo "✅ Windows bootable" || echo "❌ Windows missing"
echo ""

# 2. MOK/Secure Boot
echo "2️⃣  Secure Boot..."
mokutil --sb-state
echo ""

# 3. TPM 2.0
echo "3️⃣  TPM..."
cat /sys/class/tpm/tpm0/device/description 2>/dev/null || echo "⚠️  TPM check"
echo ""

# 4. GPU Drivers
echo "4️⃣  GPU Drivers..."
lspci -k | grep -A 2 VGA
echo ""

# 5. Containers
echo "5️⃣  Containers..."
distrobox list
echo ""

# 6. Gaming
echo "6️⃣  Gaming Stack..."
ls ~/.local/share/Steam/compatibilitytools.d/
echo ""

# 7. KENL
echo "7️⃣  KENL..."
~/.kenl/scripts/kenl-health-check.sh
echo ""

echo "✅ Validation complete - system ready for gaming!"
EOF

chmod +x ~/final-validation.sh
./final-validation.sh
```

### Expectations vs Reality Summary

```yaml
final_validation:
  phase_0_preflight:
    expected: "All hardware compatible"
    actual: "✅ PASS"
    deviations: "Virtualization was disabled, fixed in BIOS"

  phase_1_windows:
    expected: "Windows 11 configured for dual-boot"
    actual: "✅ PASS"
    deviations: "None"

  phase_2_partitioning:
    expected: "Bazzite on /dev/nvme1n1"
    actual: "✅ PASS"
    deviations: "None"

  phase_3_install:
    expected: "Bazzite boots, GRUB shows Windows"
    actual: "✅ PASS"
    deviations: "Had to manually run os-prober"

  phase_4_first_boot:
    expected: "Network, hardware detection"
    actual: "✅ PASS"
    deviations: "None"

  phase_5_containers:
    expected: "ubuntu-dev container functional"
    actual: "✅ PASS"
    deviations: "None"

  phase_6_gaming:
    expected: "Proton GE installed, Play Card created"
    actual: "✅ PASS"
    deviations: "NVIDIA driver required extra reboot"

  phase_7_validation:
    expected: "All systems operational"
    actual: "✅ PASS"
    deviations: "None"

handover_to_production:
  system_state: "fully_configured"
  dual_boot: "operational"
  gaming: "validated"
  containers: "running"
  next_steps:
    - "Install games via Steam"
    - "Create additional Play Cards"
    - "Configure MangoHud overlays"
    - "Set up KENL4 monitoring"
```

---

## Handover Mechanism: Instance Continuity

### Cross-Reboot Handover Pattern

**Before Reboot** (Current Instance):

```bash
# Create handover document
cat > ~/HANDOVER-$(date +%Y%m%d-%H%M%S).md <<EOF
# Instance Handover
# From: Pre-reboot instance
# To: Post-reboot instance
# Timestamp: $(date -Iseconds)

## What Was Done
- Phase N completed
- Configurations applied: X, Y, Z
- Packages installed: A, B, C

## Expected Post-Reboot State
- System should boot to GRUB
- Both Windows and Bazzite bootable
- Network should auto-connect
- Containers should auto-start (if configured)

## Known Deviations
- NVIDIA driver install pending reboot to activate

## Next Instance Must Do
1. Verify GRUB menu shows both OS
2. Check rpm-ostree status for new deployment
3. Verify GPU driver loaded: lsmod | grep nvidia
4. Continue to Phase N+1

## Critical Files
- Config: /etc/some/config.conf
- Logs: /var/log/install.log
- Expectations: ~/expectations-phaseN.yaml
EOF
```

**After Reboot** (New Instance):

```bash
# Find most recent handover
HANDOVER=$(ls -t ~/HANDOVER-*.md | head -1)
cat "$HANDOVER"

# Verify expectations
# Compare expected vs actual state
# Update expectations.yaml with reality
# Document any deviations

# Create response handover
cat > ~/HANDOVER-RESPONSE-$(date +%Y%m%d-%H%M%S).md <<EOF
# Handover Response
# Previous Instance Handover: $HANDOVER
# Timestamp: $(date -Iseconds)

## Verification Results
- ✅ GRUB menu shows both OS
- ✅ rpm-ostree shows new deployment active
- ✅ GPU driver loaded successfully
- ⚠️  Network required manual reconnection (WiFi)

## Deviations from Expectations
- WiFi did not auto-connect (expected: auto, actual: manual)
- Resolution: nmcli connection up WiFiSSID

## Status
- Phase N: Complete
- Phase N+1: Ready to begin

## Commentary
Previous instance expected WiFi auto-connect. This is a
known issue on first boot after install. Manual connection
successful. Setting WiFi to auto-connect for future boots.

Fix: nmcli connection modify WiFiSSID connection.autoconnect yes
EOF
```

### Handover Best Practices

1. **Document State**: Before ANY reboot, document current state
2. **Set Expectations**: Write what SHOULD happen after reboot
3. **Verify Reality**: After reboot, compare expected vs actual
4. **Explain Deviations**: If reality ≠ expectation, explain why
5. **Update Knowledge**: Feed deviations back into process

### Automated Handover Script

```bash
# ~/.kenl/scripts/create-handover.sh
#!/bin/bash

PHASE="${1:-unknown}"
HANDOVER_FILE="$HOME/HANDOVER-PHASE-$PHASE-$(date +%Y%m%d-%H%M%S).md"

cat > "$HANDOVER_FILE" <<EOF
# Handover: Phase $PHASE
# Timestamp: $(date -Iseconds)
# Instance: Pre-action

## System State
$(rpm-ostree status)

## Network
$(ip addr show | grep inet)

## Containers
$(distrobox list 2>/dev/null || echo "None")

## Expectations
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

## Next Instance Must Verify
1. System boots successfully
2. All services running
3. No unexpected errors in logs

## Critical Info
- Add notes here
EOF

echo "📝 Handover created: $HANDOVER_FILE"
echo "Edit this file before rebooting!"
```

---

## Summary

**Total Duration**: 4-6 hours (first-time setup)

**Phases Completed**:
0. Pre-flight hardware validation
1. Windows 11 parameter verification
2. Dual-boot partitioning
3. Bazzite installation
4. First boot configuration
5. Container setup
6. Gaming configuration
7. Complete validation

**Artifacts Created**:
- Preflight validation reports
- Windows 11 configuration docs
- Partition layouts
- Installation logs
- Container definitions
- Play Cards
- Handover documents for each phase
- Expectations vs Reality comparisons

**Next Steps**:
- Install games
- Create additional Play Cards
- Configure monitoring (KENL4)
- Set up social sharing (KENL6)

---

**Status**: Production Ready | **Version**: 1.0.0
**Last Updated**: 2025-11-10
**ATOM**: ATOM-DOC-20251110-016
