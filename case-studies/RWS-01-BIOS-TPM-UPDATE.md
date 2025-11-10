# RWS-01: BIOS/TPM/Secureboot Update

```
⚙️  KENL0 user@bazzite:~$ atom SYSTEM "Update BIOS firmware, TPM, and Secureboot keys - CTFWI: Verify hardware compatibility and create recovery plan"

════════════════════════════════════════════════════════════
  ATOM+SAGE: System Firmware Update Workflow
  ATOM Tag: ATOM-SYSTEM-20251109-024
════════════════════════════════════════════════════════════

Intent Detected: Critical firmware update (BIOS, TPM, Secureboot)
Risk Level: 🔴 HIGH - System may not boot if interrupted
Recovery Plan: Creating USB recovery media + ATOM snapshot

[CTFWI Pre-Flight Checks]

1/6 Detecting hardware...
  ✅ Manufacturer: ASUS
  ✅ Model: ROG STRIX B550-F GAMING
  ✅ Current BIOS: v2803 (2023-06-15)
  ✅ TPM: fTPM 2.0 (Firmware 7.2.0.0)
  ✅ Secureboot: Enabled (Microsoft UEFI CA keys)

2/6 Checking for firmware updates...
  🔍 Querying LVFS (Linux Vendor Firmware Service)...

  Available updates:
  • BIOS: v3005 (2024-11-01) - CRITICAL SECURITY UPDATE
    - Fixes AMD SMM vulnerability CVE-2023-12345
    - Adds AGESA 1.2.0.9 support
    - Size: 32 MB

  • TPM: v7.2.4.1 (2024-09-15) - Recommended
    - Enhanced measured boot support
    - Size: 512 KB

  ⚠️  No Secureboot key updates available
  ℹ️  Your current keys are valid until 2028

3/6 Validating prerequisites...
  ✅ Battery/AC: Plugged in (required)
  ✅ Disk space: 2.3 GB free (required: 500 MB)
  ✅ fwupd service: Active
  ❌ Kernel lockdown: Enabled (blocks BIOS update)

  💡 Fix required:
     sudo grub2-editenv - unset lockdown
     # Will re-enable after update

4/6 Creating recovery points...
  📸 Creating KENL10 snapshot: "before-firmware-update"

  ✅ Captured: ATOM trail (234 entries)
  ✅ Captured: System state (rpm-ostree)
  ✅ Captured: Boot configuration
  ✅ Snapshot size: 127 MB

  💾 Creating bootable USB recovery (REQUIRED for firmware update)

  Insert USB drive (8GB minimum) and press Enter...
  [User inserts USB]

  Detected: /dev/sdb (SanDisk 16GB)
  ⚠️  This will ERASE all data on /dev/sdb

  Type 'YES' to continue: YES

  Creating recovery USB...
  [████████████████████████████████████] 100%

  ✅ Recovery USB created: /dev/sdb
  ✅ Contains: Bazzite recovery image + ATOM snapshot

  📝 Recovery instructions written to:
     ~/kenl/KENL10-backup/recovery-instructions.txt

5/6 Preparing firmware update...
  Disabling kernel lockdown...
  ✅ Lockdown disabled temporarily

  Downloading firmware from LVFS...
  • BIOS v3005: [████████████████] 32.1 MB/32.1 MB
  • TPM v7.2.4.1: [████████████] 512 KB/512 KB

  Verifying signatures...
  ✅ BIOS: GPG signature valid (ASUS key)
  ✅ TPM: GPG signature valid (AMD key)

6/6 Final safety check...

  ════════════════════════════════════════════════════════════
  ⚠️  CRITICAL FIRMWARE UPDATE CONFIRMATION
  ════════════════════════════════════════════════════════════

  You are about to update:

  1. BIOS: v2803 → v3005 (CRITICAL SECURITY)
     • System will reboot to UEFI update mode
     • Takes ~5 minutes
     • DO NOT INTERRUPT or power off

  2. TPM: v7.2.0.0 → v7.2.4.1
     • Updates during boot
     • May clear TPM (Bitlocker users: backup keys!)

  Recovery options prepared:
  ✅ USB recovery drive: /dev/sdb
  ✅ ATOM snapshot: before-firmware-update
  ✅ rpm-ostree rollback available

  CTFWI Checklist:
  ☑ AC power connected
  ☑ Recovery USB created
  ☑ Snapshot created
  ☑ Signatures verified
  ☑ No processes can interrupt

  ════════════════════════════════════════════════════════════

  Type 'UPDATE' to proceed with firmware update: UPDATE

[Executing firmware update...]

Stage 1: Preparing system...
  • Stopping non-essential services...
  • Syncing filesystems...
  • Scheduling BIOS update for next boot...

Stage 2: Rebooting to UEFI update mode...

  ⚠️  System will reboot now
  ⚠️  DO NOT POWER OFF during BIOS update
  ⚠️  Screen may be blank for up to 5 minutes

  Rebooting in 10 seconds... (Ctrl+C to cancel)

[System reboots → UEFI firmware update screen]

════════════════════════════════════════════════════════════
  ASUS UEFI BIOS Updater
════════════════════════════════════════════════════════════

  Current Version: 2803
  Update Version: 3005

  Updating... [████████████████████████████    ] 85%

  DO NOT POWER OFF OR RESTART YOUR COMPUTER

  Estimated time remaining: 00:43

[Update completes, system reboots back to Bazzite]

════════════════════════════════════════════════════════════
  ATOM+SAGE: Firmware Update - Post-Flight Verification
════════════════════════════════════════════════════════════

[1/5] Verifying BIOS update...
  ✅ BIOS version: v3005 (Updated successfully!)
  ✅ Boot time: 12 seconds (normal)
  ✅ All boot services started

[2/5] Verifying TPM update...
  ✅ TPM version: v7.2.4.1 (Updated successfully!)
  ✅ TPM status: Ready
  ⚠️  TPM was cleared during update (expected)

  💡 If you use Bitlocker: Re-seal keys now
     If you use LUKS: No action needed

[3/5] Verifying Secureboot...
  ✅ Secureboot: Enabled
  ✅ Keys: Microsoft UEFI CA (unchanged)
  ✅ Boot chain: Verified

[4/5] Re-enabling kernel lockdown...
  ✅ Lockdown restored

[5/5] Updating ATOM trail...
  ✅ ATOM-SYSTEM-20251109-024

  Success summary:
  • BIOS: v2803 → v3005 ✅
  • TPM: v7.2.0.0 → v7.2.4.1 ✅
  • Secureboot: No updates needed ✅
  • Total time: 8 minutes
  • Rollback points: 2 (snapshot + rpm-ostree)

════════════════════════════════════════════════════════════

✅ Firmware update completed successfully!

Recovery USB location: /dev/sdb (keep for emergencies)
Snapshot: ~/kenl/KENL10-backup/snapshots/before-firmware-update

Next steps:
  1. Test system thoroughly (gaming, boot times, TPM apps)
  2. If issues occur: Boot from USB recovery drive
  3. Keep recovery USB for 7 days, then reformat

ATOM Trail: ~/.config/atom-sage/trail/ATOM-SYSTEM-20251109-024.log

⚙️  KENL0 user@bazzite:~$
```

## Key Features Demonstrated:

1. **CTFWI Validation**: Hardware detection, update verification, safety checks
2. **Risk Assessment**: High-risk operation flagged immediately
3. **Recovery Plan**: Automatic USB creation + snapshot before dangerous operation
4. **Guided Process**: Step-by-step with clear warnings
5. **Post-Flight Verification**: Ensures everything worked
6. **ATOM Trail**: Complete audit log of firmware update
7. **Rollback Options**: USB recovery + snapshot + rpm-ostree

## Safety Features:

- Won't proceed without AC power
- Creates bootable USB recovery automatically
- Verifies GPG signatures on firmware
- Clears lockdown only temporarily
- Tests TPM/Secureboot post-update
- Keeps recovery options for 7 days
