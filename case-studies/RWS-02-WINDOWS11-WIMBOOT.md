# RWS-02: Windows 11 Installation via Ventoy wimboot

```
⚙️  modules/KENL0 user@bazzite:~$ atom RESEARCH "Install Windows 11 using Ventoy wimboot instead of Tiny11 ISO"

════════════════════════════════════════════════════════════
  ATOM+SAGE: Research Mode - Windows 11 wimboot
  ATOM Tag: ATOM-RESEARCH-20251109-025
════════════════════════════════════════════════════════════

Intent: Install Windows 11 on dual-boot system
Discovery: Ventoy wimboot feature (downloads official Win11)
Alternative: Tiny11 ISO (debloated, but unofficial)

[1/3] Researching Ventoy wimboot...

  🔍 What is wimboot?

  wimboot = Windows Imaging Boot
  • Ventoy plugin that downloads official Windows ISO
  • Uses Windows Media Creation Tool servers
  • Creates WinPE environment for installation
  • Downloads latest Windows 11 build on-the-fly

  ✅ Advantages over Tiny11:
  • Official Microsoft build (fully supported)
  • Always latest version (no stale ISOs)
  • Smaller USB footprint (downloads on demand)
  • No license concerns
  • Full feature set (Tiny11 removes features)

  ⚠️  Requirements:
  • Internet connection during install
  • 8+ GB download (Win11 ISO)
  • TPM 2.0 + Secureboot (Win11 requirement)

[2/3] Checking your hardware for Windows 11 compatibility...

  CPU: AMD Ryzen 7 5800X3D
  ✅ Supported (Zen 3, released 2020)

  TPM: fTPM 2.0 (v7.2.4.1)
  ✅ Compatible

  RAM: 32 GB DDR4
  ✅ Exceeds minimum (4 GB)

  Secureboot: Enabled
  ✅ Required for Win11

  Storage: 1TB NVMe (476 GB free)
  ✅ Sufficient (64 GB required)

  GPU: NVIDIA RTX 3080
  ✅ Supported

  💡 Your hardware fully supports Windows 11!

[3/3] Comparing installation methods...

  ┌─────────────────────────────────────────────────────────┐
  │ Method          │ wimboot      │ Tiny11 ISO             │
  ├─────────────────────────────────────────────────────────┤
  │ Source          │ Official MS  │ Community modified     │
  │ Size            │ ~8GB download│ ~3.5GB ISO             │
  │ Features        │ Full Windows │ Debloated (less bloat) │
  │ Updates         │ Latest       │ May be outdated        │
  │ Support         │ Official     │ Community only         │
  │ License         │ Valid        │ Gray area              │
  │ Install time    │ 45-60 min    │ 25-35 min              │
  │ Internet needed │ Yes          │ No                     │
  └─────────────────────────────────────────────────────────┘

  📊 Recommendation: wimboot (official, supported, latest)

════════════════════════════════════════════════════════════

Research complete! Proceed with wimboot installation? [Y/n]: Y

⚙️  modules/KENL0 user@bazzite:~$ atom SYSTEM "Install Windows 11 via Ventoy wimboot - CTFWI: Create dual-boot partition layout and backup"

════════════════════════════════════════════════════════════
  ATOM+SAGE: Windows 11 Dual-Boot Installation
  ATOM Tag: ATOM-SYSTEM-20251109-026
════════════════════════════════════════════════════════════

Intent: Install Windows 11 alongside Bazzite (dual-boot)
Method: Ventoy wimboot (official Microsoft ISO)
Risk Level: 🟡 MEDIUM - Partitioning can break boot

[CTFWI Pre-Flight Checks]

1/8 Analyzing current disk layout...

  Device: /dev/nvme0n1 (1TB Samsung 980 PRO)

  Current partitions:

  /dev/nvme0n1p1    512 MB  EFI System      (Bazzite bootloader)
  /dev/nvme0n1p2    1 GB    /boot           (Bazzite kernels)
  /dev/nvme0n1p3    499 GB  / (Btrfs)       (Bazzite system)

  Free space: 524 GB (unallocated)

  ✅ Sufficient space for Windows 11 (need 64 GB minimum)

2/8 Planning partition layout for dual-boot...

  Proposed layout:

  /dev/nvme0n1p1    512 MB  EFI System      (SHARED - Bazzite + Windows)
  /dev/nvme0n1p2    1 GB    /boot           (Bazzite)
  /dev/nvme0n1p3    499 GB  / (Btrfs)       (Bazzite)
  /dev/nvme0n1p4    16 MB   MSR (Reserved)  (Windows metadata)  [NEW]
  /dev/nvme0n1p5    300 GB  NTFS            (Windows 11 C:)     [NEW]
  /dev/nvme0n1p6    200 GB  NTFS            (Windows 11 D:)     [NEW]

  Remaining: 24 GB (future use)

  ⚠️  EFI partition will be shared (contains both bootloaders)
  ✅ Windows will be added to GRUB menu (via os-prober)

3/8 Creating modules/KENL10 snapshot before partitioning...

  📸 Snapshot: "before-windows-install"

  ✅ Captured: Full system state
  ✅ Captured: Partition table (GPT)
  ✅ Captured: GRUB configuration
  ✅ Captured: EFI bootloaders
  ✅ Size: 234 MB

  💾 Rollback available: ./atom-snapshot.sh restore before-windows-install

4/8 Preparing Ventoy USB with wimboot plugin...

  Insert USB drive (16GB minimum) for Ventoy...
  [User inserts USB]

  Detected: /dev/sdc (32GB Kingston)

  Installing Ventoy + wimboot plugin...

  [████████████████████████████████████] 100%

  ✅ Ventoy installed (v1.0.96)
  ✅ wimboot plugin configured

  📁 Ventoy structure:
     /dev/sdc1 - Ventoy (data partition)
     /dev/sdc2 - Ventoy boot (EFI)

  📝 wimboot menu will appear on boot

5/8 Creating Windows 11 installation partitions...

  ⚠️  This will modify disk: /dev/nvme0n1
  ⚠️  Backup created: ATOM snapshot + modules/KENL10

  Type 'CREATE' to create Windows partitions: CREATE

  Creating partitions with parted...

  • Creating MSR partition (16 MB)...        ✅
  • Creating Windows C: (300 GB, NTFS)...    ✅
  • Creating Windows D: (200 GB, NTFS)...    ✅

  Formatting partitions...

  • Formatting /dev/nvme0n1p5 as NTFS...     ✅
  • Formatting /dev/nvme0n1p6 as NTFS...     ✅

  Updating partition table...                ✅

  ✅ Windows partitions ready

6/8 Configuring EFI for dual-boot...

  Mounting EFI partition...

  Current EFI contents:
  /boot/efi/
  ├── EFI/
  │   ├── BOOT/
  │   │   └── BOOTX64.EFI (Bazzite)
  │   └── fedora/
  │       ├── grub.cfg
  │       ├── grubx64.efi
  │       └── shimx64.efi

  Creating space for Windows bootloader...
  ✅ Windows will install to: /boot/efi/EFI/Microsoft/

  Enabling os-prober in GRUB (detects Windows)...

  # /etc/default/grub
  GRUB_DISABLE_OS_PROBER=false  # Changed from true

  ✅ GRUB will auto-detect Windows after install

7/8 Generating installation instructions...

  ════════════════════════════════════════════════════════════
  📝 Windows 11 wimboot Installation Steps
  ════════════════════════════════════════════════════════════

  Your system is prepared for Windows 11 installation!

  Step 1: Reboot to Ventoy USB
    1. Reboot system
    2. Press F8/Del to enter boot menu
    3. Select USB: "Kingston 32GB"

  Step 2: Use wimboot in Ventoy menu
    1. Ventoy menu will appear
    2. Select: "wimboot - Windows 11"
    3. Choose language: English
    4. wimboot will download official Win11 ISO (~8 GB)
       ⚠️  Requires internet connection
       ⏱️  Takes 10-30 min depending on speed

  Step 3: Windows 11 Installation
    1. Windows setup will start
    2. Select: "Custom: Install Windows only (advanced)"
    3. Target partition: "Drive 0 Partition 5" (300 GB NTFS)
       ⚠️  DO NOT format other partitions!
       ⚠️  Bazzite is on Partition 3 (499 GB)
    4. Click "Next" and wait (~30 minutes)

  Step 4: First Boot (Windows)
    1. System will reboot to Windows 11
    2. Complete OOBE (Out Of Box Experience):
       - Skip Microsoft account (use local account)
       - Disable telemetry (privacy)
       - Skip Xbox/OneDrive prompts
    3. Windows 11 will boot

  Step 5: Return to Bazzite and Update GRUB
    1. Reboot system
    2. You'll see GRUB menu with:
       ⚠️  Only Bazzite options (Windows not detected yet)
    3. Boot into Bazzite
    4. Run: sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    5. os-prober will detect Windows 11
    6. Next reboot: GRUB menu shows both OS choices

  Step 6: Verify Dual-Boot
    1. Reboot
    2. GRUB menu should show:
       • Bazzite (default)
       • Windows 11
    3. Test both operating systems
    4. Set default in GRUB if needed

  ════════════════════════════════════════════════════════════

8/8 Final safety checklist...

  ☑ Ventoy USB created: /dev/sdc
  ☑ Windows partitions created: /dev/nvme0n1p5, p6
  ☑ Snapshot created: before-windows-install
  ☑ os-prober enabled in GRUB
  ☑ Internet connection verified
  ☑ TPM 2.0 enabled (Win11 requirement)
  ☑ Secureboot enabled (Win11 requirement)

  ⚠️  Important notes:

  1. During Windows install, select ONLY partition 5 (300 GB)
  2. DO NOT format any other partitions
  3. After first Windows boot, return to Bazzite and update GRUB
  4. Keep Ventoy USB for future Windows reinstalls

  💾 Rollback plan:
  • If Windows install fails: Boot Bazzite, restore snapshot
  • If GRUB breaks: Boot from live USB, chroot, regenerate GRUB
  • If dual-boot doesn't work: Run grub2-mkconfig again

════════════════════════════════════════════════════════════

✅ System prepared for Windows 11 installation!

Ventoy USB: /dev/sdc (ready to boot)
Snapshot: before-windows-install (rollback point)
Installation guide: ~/kenl/KENL0-system/windows11-install-guide.txt

Ready to reboot to Ventoy USB? [Y/n]: Y

Rebooting in 10 seconds...

⚙️  modules/KENL0 user@bazzite:~$

[System reboots → Ventoy menu appears]

════════════════════════════════════════════════════════════
                     Ventoy 1.0.96
════════════════════════════════════════════════════════════

[Press F1 for help]

┌────────────────────────────────────────────────────────────┐
│                                                            │
│  ▸ wimboot - Windows 11 (x64)                             │
│    Bazzite-40-x86_64.iso                                  │
│    Ubuntu-24.04-desktop-amd64.iso                         │
│                                                            │
│                                                            │
│                                                            │
└────────────────────────────────────────────────────────────┘

[User selects wimboot → Windows 11 download begins]

════════════════════════════════════════════════════════════
  wimboot - Windows 11 Downloader
════════════════════════════════════════════════════════════

Connecting to Microsoft servers...
✓ Connected

Downloading Windows 11 (23H2 Build 22631.4460)
Size: 7.8 GB

[██████████████████████████████████            ] 75% (5.8 GB)
Speed: 45 MB/s | ETA: 00:48

[Download completes → WinPE boots → Windows Setup starts]

[... Standard Windows 11 installation proceeds ...]

[After Windows install, user reboots back to Bazzite]

⚙️  modules/KENL0 user@bazzite:~$ sudo grub2-mkconfig -o /boot/grub2/grub.cfg

Generating grub configuration file ...
Found theme: /boot/grub2/themes/breeze/theme.txt
Found linux image: /boot/vmlinuz-6.11.3-200.fc40.x86_64
Found initrd image: /boot/initramfs-6.11.3-200.fc40.x86_64.img
Found Windows 11 on /dev/nvme0n1p5                           ← ✅ Detected!
done

⚙️  modules/KENL0 user@bazzite:~$ atom STATUS "Windows 11 dual-boot installation complete"

════════════════════════════════════════════════════════════
  ATOM+SAGE: Installation Complete
  ATOM Tag: ATOM-STATUS-20251109-027
════════════════════════════════════════════════════════════

✅ Windows 11 installed successfully via wimboot
✅ Dual-boot working (GRUB shows both OS)
✅ Partitions:
   • Bazzite: /dev/nvme0n1p3 (499 GB)
   • Windows: /dev/nvme0n1p5 (300 GB)
   • Data: /dev/nvme0n1p6 (200 GB, shared)

Next reboot will show:

  ┌────────────────────────────────────┐
  │ GNU GRUB                           │
  ├────────────────────────────────────┤
  │ ▸ Bazzite (6.11.3-200.fc40)       │
  │   Windows 11                       │
  │   UEFI Firmware Settings           │
  └────────────────────────────────────┘

⏱️  Boot timeout: 5 seconds (default: Bazzite)

To change default OS:
  sudo grub2-set-default "Windows 11"

ATOM Trail logged: Complete installation history
Snapshot available: Restore if needed

════════════════════════════════════════════════════════════

⚙️  modules/KENL0 user@bazzite:~$
```

## Key Features Demonstrated:

1. **Research Mode**: ATOM explains wimboot vs Tiny11
2. **Hardware Verification**: Checks Win11 compatibility (TPM 2.0, Secureboot)
3. **Intelligent Partitioning**: Creates proper dual-boot layout
4. **Safety First**: Snapshot before modifying partitions
5. **Guided Installation**: Step-by-step wimboot instructions
6. **Post-Install**: Auto-detect Windows via os-prober
7. **Complete ATOM Trail**: Full audit of dual-boot setup

## Why wimboot Recommendation:

- Official Microsoft build (no license issues)
- Always latest version
- Full Windows 11 features
- Supported updates
- Internet-based (no stale ISO)
