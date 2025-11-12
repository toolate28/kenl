---
project: Bazza-DX SAGE Framework
classification: IWI-RESOURCE
atom: ATOM-IWI-20251112-021
status: active
version: 1.0.0
---

# KENL13-iwi Trusted Resources

**Inventory of all verified resources in KENL13-iwi**

---

## Overview

All resources in KENL13-iwi are:
- ✅ **SHA256 verified** - Checksums prevent tampering
- ✅ **GPG signed** - Signatures ensure authenticity
- ✅ **Timestamped** - Capture date documented
- ✅ **Sourced** - Original URLs recorded

---

## Bazzite Documentation

### Static Snapshots

**Last Updated:** 2025-11-12
**Source:** https://docs.bazzite.gg/
**Checksum File:** `checksums/bazzite-docs.sha256`
**Signature File:** `signatures/bazzite-docs.sig`

| File | Purpose | SHA256 (first 16 chars) |
|------|---------|-------------------------|
| `Installation_Guide.html` | Fresh install instructions | TBD |
| `Dual_Boot_Setup.html` | Dual-boot with Windows | TBD |
| `Gaming.html` | Gaming setup guide | TBD |
| `Steam.html` | Steam configuration | TBD |
| `Proton.html` | Proton compatibility | TBD |
| `AMD_GPU_Tuning.html` | AMD GPU optimizations | TBD |
| `NVIDIA_GPU_Setup.html` | NVIDIA GPU setup | TBD |
| `Network_Optimization.html` | Network tuning | TBD |
| `ujust_Recipes.html` | ujust command reference | TBD |
| `Troubleshooting.html` | Common issues | TBD |

**Note:** Documentation files will be added during first resource update.
Run: `./bin/iwi-update-docs` to populate.

---

## Bazzite ISO Hashes

### Official Release Hashes

**Last Updated:** 2025-11-12
**Source:** https://download.bazzite.gg/
**Checksum File:** `checksums/iso-hashes.sha256`

| ISO Variant | Date | SHA256 Hash |
|-------------|------|-------------|
| bazzite-kde | 2025-11-12 | (from official source) |
| bazzite-gnome | 2025-11-12 | (from official source) |
| bazzite-deck | 2025-11-12 | (from official source) |

**Note:** These are **official hashes from Bazzite**, not the ISOs themselves.
Use these to verify your downloaded ISO.

---

## Templates

### Installation Templates

**Checksum File:** `checksums/templates.sha256`

| Template | Purpose | Status |
|----------|---------|--------|
| `installation-plan.yaml` | Pre-installation planning | ✓ |
| `installation-capture.yaml` | Real-time capture | ✓ |
| `installation-profile.yaml` | Complete profile | ✓ |

---

## Examples

### Community Installation Profiles

**Checksum File:** `checksums/examples.sha256`

| Profile | Hardware | Status |
|---------|----------|--------|
| `amd-ryzen5-5600h-vega.yaml` | AMD laptop | ✓ |
| `intel-nvidia-gaming.yaml` | Intel/NVIDIA desktop | Planned |
| `framework-laptop.yaml` | Framework laptop | Planned |

---

## Verification Commands

### Verify All Resources

```bash
./bin/iwi-verify-resources
```

### Verify Specific Category

```bash
# Bazzite documentation
./bin/iwi-verify-resources --category bazzite-docs

# ISO hashes
./bin/iwi-verify-resources --category iso-hashes

# Templates
./bin/iwi-verify-resources --category templates

# Examples
./bin/iwi-verify-resources --category examples
```

### Verify Single File

```bash
./bin/iwi-verify-file resources/bazzite-docs/Installation_Guide.html
```

---

## Resource Update Process

### For Maintainers

```bash
# Update Bazzite documentation
./bin/iwi-update-docs --snapshot-date $(date +%Y-%m-%d)

# Update ISO hashes
./bin/iwi-update-iso-hashes

# Regenerate checksums
./bin/iwi-generate-checksums

# Sign checksums with GPG
./bin/iwi-sign-checksums

# Commit with ATOM tag
git add resources/
git commit -m "chore: update iWi resources

Updated Bazzite documentation and ISO hashes.

ATOM-IWI-$(date +%Y%m%d)-XXX"
```

### Verification After Update

```bash
# Always verify after updating
./bin/iwi-verify-resources

# Expected: All checks pass
```

---

## GPG Signature Details

### KENL Project GPG Key

**Key ID:** TBD (to be generated)
**Fingerprint:** TBD
**Email:** kenl@toolate28.dev

### Importing Public Key

```bash
# Import from file
gpg --import resources/kenl-gpg-public-key.asc

# Or from keyserver (when published)
gpg --recv-keys <KEY_ID>
```

### Verifying Signatures

```bash
# Verify documentation checksums
gpg --verify resources/signatures/bazzite-docs.sig \
             resources/checksums/bazzite-docs.sha256

# Expected output:
# gpg: Signature made ...
# gpg: Good signature from "KENL Project <kenl@toolate28.dev>"
```

---

## Checksum File Format

### Example: bazzite-docs.sha256

```
# Bazzite Documentation Checksums
# Generated: 2025-11-12
# Source: https://docs.bazzite.gg/

abc123def456789...  resources/bazzite-docs/Installation_Guide.html
def456ghi789012...  resources/bazzite-docs/Gaming.html
ghi789jkl012345...  resources/bazzite-docs/AMD_GPU_Tuning.html
```

### Verification Process

```bash
# Manual verification
cd /path/to/KENL13-iwi
sha256sum -c resources/checksums/bazzite-docs.sha256

# Expected output:
# resources/bazzite-docs/Installation_Guide.html: OK
# resources/bazzite-docs/Gaming.html: OK
# resources/bazzite-docs/AMD_GPU_Tuning.html: OK
```

---

## Resource Lifecycle

### States

1. **Planned** - Resource identified, not yet added
2. **Captured** - Downloaded/created, awaiting verification
3. **Verified** - Checksums generated, GPG signed
4. **Published** - Committed to repository
5. **Deprecated** - No longer maintained (marked for removal)

### Maintenance Schedule

| Resource | Update Frequency | Last Update |
|----------|------------------|-------------|
| Bazzite Docs | Monthly | 2025-11-12 |
| ISO Hashes | Weekly | 2025-11-12 |
| Templates | As needed | 2025-11-12 |
| Examples | As contributed | 2025-11-12 |

---

## Security Considerations

### Trust Chain

```
Official Source (docs.bazzite.gg)
    ↓
  Download
    ↓
SHA256 Checksum
    ↓
  GPG Sign
    ↓
Commit to Git (signed commit)
    ↓
  User Verifies
```

### Threat Model

**Protected Against:**
- ✓ Tampered resources (SHA256 detects changes)
- ✓ Man-in-the-middle during distribution (GPG signatures)
- ✓ Unauthorized modifications (signed commits)

**Not Protected Against:**
- ✗ Compromised official source (trust docs.bazzite.gg)
- ✗ Compromised GPG key (protect private key!)
- ✗ Social engineering (always verify resources!)

---

## Troubleshooting

### Checksum Mismatch

**Problem:** Resource fails SHA256 verification

**Solution:**
```bash
# Re-download resource
./bin/iwi-update-docs --force --file <filename>

# Verify again
./bin/iwi-verify-resources
```

### Missing GPG Key

**Problem:** Can't verify GPG signature

**Solution:**
```bash
# Import KENL public key
gpg --import resources/kenl-gpg-public-key.asc

# Verify import
gpg --list-keys kenl@toolate28.dev
```

### Outdated Resources

**Problem:** Documentation doesn't match current Bazzite version

**Solution:**
```bash
# Update to latest
./bin/iwi-update-docs

# Verify update
./bin/iwi-verify-resources

# Check version
cat resources/bazzite-docs/VERSION.txt
```

---

## Contributing

### Adding New Resources

1. **Identify resource** - Official source URL
2. **Download/create** - Capture resource locally
3. **Generate checksum** - `sha256sum <file>`
4. **Sign checksum** - `gpg --detach-sign <checksum-file>`
5. **Update manifest** - Add to this file
6. **Verify** - `./bin/iwi-verify-resources`
7. **Commit** - Signed commit with ATOM tag

### Example: Adding New Documentation

```bash
# 1. Download
wget https://docs.bazzite.gg/new-guide.html \
  -O resources/bazzite-docs/new-guide.html

# 2. Generate checksum
sha256sum resources/bazzite-docs/new-guide.html >> \
  resources/checksums/bazzite-docs.sha256

# 3. Sign checksums
gpg --detach-sign --armor \
  resources/checksums/bazzite-docs.sha256

# 4. Update this manifest
# (Add entry to table above)

# 5. Verify
./bin/iwi-verify-resources

# 6. Commit
git add resources/
git commit -S -m "feat(iwi): add new Bazzite documentation

Added: new-guide.html

ATOM-IWI-$(date +%Y%m%d)-XXX"
```

---

## References

### Internal
- `../README.md` - KENL13-iwi overview
- `../IWI_SPECIFICATION.md` - Complete iWi spec
- `../docs/RESOURCE_VERIFICATION.md` - Verification details

### External
- [Bazzite Documentation](https://docs.bazzite.gg/)
- [Bazzite Downloads](https://download.bazzite.gg/)
- [Universal Blue](https://universal-blue.org/)

---

## Metadata

- **Created:** 2025-11-12
- **Last Updated:** 2025-11-12
- **Maintainer:** toolate28/kenl
- **ATOM Tag:** ATOM-IWI-20251112-021
- **Classification:** IWI-RESOURCE
- **Status:** Active - Foundation Phase

---
