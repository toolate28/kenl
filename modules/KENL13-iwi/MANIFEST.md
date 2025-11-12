---
project: Bazza-DX SAGE Framework
classification: OWI-DOC
atom: ATOM-DOC-20251112-006
status: active
version: 1.0.0
---

# KENL13-iwi Module Manifest

**Module:** KENL13-iwi
**Version:** 1.0.0
**Status:** Production Ready
**Last Updated:** 2025-11-12

---

## Purpose

KENL13-iwi (Installing With Intent) is a standalone installation framework for Bazzite with cryptographic resource verification. It captures installation decisions, validates resources against trusted checksums, and ensures reproducible system setups through ATOM-tagged audit trails.

---

## Module Information

| Property | Value |
|----------|-------|
| **Module ID** | KENL13 |
| **Module Name** | Installing With Intent (iWi) |
| **Category** | Installation & Configuration |
| **Privilege Level** | User-space (installation logging), Elevated (system install) |
| **Platform** | Bazzite (Fedora Atomic), extensible to other immutable distros |
| **Dependencies** | KENL0 (System), KENL1 (Framework) |

---

## Directory Structure

```
KENL13-iwi/
├── README.md                          # Module documentation
├── MANIFEST.md                        # This file
├── IWI_SPECIFICATION.md               # Complete iWi spec (TBD)
│
├── bin/                               # Executable tools
│   ├── iwi-capture                    # Installation capture tool (TBD)
│   ├── iwi-validate                   # Validation framework (TBD)
│   ├── iwi-verify-resources           # Resource verification ✓
│   └── iwi-profile-generate           # Profile generator (TBD)
│
├── lib/                               # Shared libraries
│   ├── iwi-common.sh                  # Common functions (TBD)
│   ├── iwi-verify.sh                  # Verification functions (TBD)
│   ├── iwi-capture.sh                 # Capture functions (TBD)
│   └── iwi-test.sh                    # Testing functions (TBD)
│
├── resources/                         # Trusted resources (VERIFIED)
│   ├── RESOURCES.md                   # Resource inventory ✓
│   ├── bazzite-docs/                  # Static docs from docs.bazzite.gg
│   ├── checksums/                     # SHA256 checksums
│   ├── signatures/                    # GPG signatures
│   └── iso-hashes/                    # Official Bazzite ISO hashes
│
├── docs/                              # iWi documentation
│   ├── GETTING_STARTED.md (TBD)
│   ├── INSTALLATION_CAPTURE.md (TBD)
│   ├── RESOURCE_VERIFICATION.md (TBD)
│   ├── VALIDATION_FRAMEWORK.md (TBD)
│   └── BAZZITE_INTEGRATION.md (TBD)
│
├── examples/                          # Example profiles
│   └── amd-ryzen5-5600h-vega.yaml (TBD)
│
├── tests/                             # Validation tests
│   ├── run-all-tests.sh (TBD)
│   ├── test-deployment.sh (TBD)
│   ├── test-packages.sh (TBD)
│   ├── test-performance.sh (TBD)
│   └── test-hardware.sh (TBD)
│
└── templates/                         # Document templates
    ├── installation-plan.yaml (TBD)
    ├── installation-capture.yaml (TBD)
    └── installation-profile.yaml (TBD)
```

---

## Files Inventory

### Core Files

| File | Purpose | Status |
|------|---------|--------|
| `README.md` | Module documentation | ✓ Complete |
| `MANIFEST.md` | This manifest | ✓ Complete |
| `IWI_SPECIFICATION.md` | Complete iWi specification | ⏳ Planned |

### Executables (bin/)

| File | Purpose | Status |
|------|---------|--------|
| `iwi-verify-resources` | Verify all trusted resources | ✓ Complete |
| `iwi-capture` | Capture installation process | ⏳ Planned |
| `iwi-validate` | Validate installation profiles | ⏳ Planned |
| `iwi-profile-generate` | Generate shareable profiles | ⏳ Planned |

### Resources

| Category | Purpose | Status |
|----------|---------|--------|
| `bazzite-docs/` | Static Bazzite documentation | ⏳ Framework ready |
| `checksums/` | SHA256 checksums for verification | ⏳ Framework ready |
| `signatures/` | GPG signatures for authenticity | ⏳ Framework ready |
| `iso-hashes/` | Official Bazzite ISO hashes | ⏳ Framework ready |

---

## Dependencies

### System Dependencies

**Required:**
```bash
# Built into Bazzite
bash >= 5.0
coreutils
sha256sum
```

**Optional:**
```bash
# Enhanced functionality
gpg          # GPG signature verification
jq           # JSON parsing for ATOM logs
yq           # YAML parsing for profiles
```

### KENL Module Dependencies

- **KENL0 (System):** ATOM logging via system-atom.sh
- **KENL1 (Framework):** ATOM/SAGE/OWI methodology

**Optional Integration:**
- **KENL2 (Gaming):** Gaming-specific installation profiles
- **KENL3 (Development):** Development environment setup
- **KENL4 (Monitoring):** Performance validation

---

## Installation

### Quick Install

```bash
# KENL13-iwi operates from repository - no installation needed
cd ~/kenl/modules/KENL13-iwi

# Verify resources
./bin/iwi-verify-resources

# Expected: All checks pass (when resources populated)
```

### Verification

```bash
# Verify module files exist
ls -la ~/kenl/modules/KENL13-iwi/

# Verify executables are executable
test -x ~/kenl/modules/KENL13-iwi/bin/iwi-verify-resources && \
  echo "✓ Verification tool ready"
```

---

## Configuration

### Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `IWI_CAPTURE_DIR` | `~/.iwi/captures` | Installation capture storage |
| `IWI_PROFILE_DIR` | `~/.iwi/profiles` | Profile storage |
| `IWI_RESOURCES_DIR` | `$MODULE_DIR/resources` | Trusted resources location |

### Configuration Files

| File | Location | Purpose |
|------|----------|---------|
| Installation captures | `~/.iwi/captures/` | Captured installations |
| Generated profiles | `~/.iwi/profiles/` | User-generated profiles |
| ATOM logs | `~/.atom-logs/` | Audit trail |

---

## Usage

### Basic Usage

```bash
cd ~/kenl/modules/KENL13-iwi

# 1. Verify resources before use
./bin/iwi-verify-resources

# 2. Create installation plan (when capture tool ready)
# cp templates/installation-plan.yaml my-plan.yaml
# vim my-plan.yaml

# 3. Capture installation (when tool ready)
# ./bin/iwi-capture start --plan my-plan.yaml

# 4. Generate profile (when generator ready)
# ./bin/iwi-profile-generate --output my-profile.yaml

# 5. Validate installation (when validator ready)
# ./bin/iwi-validate my-profile.yaml
```

### Advanced Usage

```bash
# Verify specific resource category
./bin/iwi-verify-resources --category bazzite-docs

# Update resources (maintainers only)
# ./bin/iwi-update-docs

# Run validation tests
# ./tests/run-all-tests.sh
```

---

## Integration Points

### Integration with Other Modules

- **KENL0:** Uses `system-atom.sh` for ATOM trail logging
- **KENL1:** Follows ATOM/SAGE/OWI methodology
- **KENL2:** Gaming installation profiles
- **KENL3:** Development environment setup profiles

### System Integration

- **Bazzite:** Captures Bazzite-specific configuration
- **rpm-ostree:** Logs layered packages and deployments
- **ujust:** Documents ujust recipes executed
- **docs.bazzite.gg:** Static documentation integration

### OWI Framework Integration

**iWi is an OWI fork:**
- Classification: `IWI-*` (Installing With Intent)
- ATOM tags: `ATOM-IWI-*`
- Follows OWI metadata standards
- Links to ATOM-IWI fork in `modules/KENL1-framework/atom-sage-framework/forks/ATOM-IWI/`

---

## ATOM Traceability

### ATOM Tags

| Tag Pattern | Purpose |
|-------------|---------|
| `ATOM-IWI-*-001` | Installation plan created |
| `ATOM-IWI-*-002` | Installation capture started |
| `ATOM-IWI-*-003` | Bazzite variant selected |
| `ATOM-IWI-*-004` | Partitioning completed |
| `ATOM-IWI-*-005` | Package layered (rpm-ostree) |
| `ATOM-IWI-*-006` | ujust recipe executed |
| `ATOM-IWI-*-007` | Profile generated |
| `ATOM-IWI-*-020` | Resource verification |

### Logging

- **Log Location:** `~/.atom-logs/atom-YYYYMMDD.log`
- **Structured Capture:** `~/.iwi/captures/capture-YYYYMMDD-HHMMSS.yaml`
- **Log Format:** Standard KENL ATOM trail format

---

## Testing & Validation

### Resource Verification Tests

```bash
# Test: Verify all resources
./bin/iwi-verify-resources

# Expected: All checks pass (when resources populated)
```

### Installation Profile Validation

```bash
# Test: Validate example profile (when validator ready)
# ./bin/iwi-validate examples/amd-ryzen5-5600h-vega.yaml

# Expected: Profile meets iWi specification
```

### Validation Checklist

- [ ] Module README exists and documents purpose
- [ ] MANIFEST.md complete with dependencies
- [x] Resource verification tool (`iwi-verify-resources`) functional
- [ ] Installation capture tool (`iwi-capture`) functional
- [ ] Profile generator (`iwi-profile-generate`) functional
- [ ] Validator (`iwi-validate`) functional
- [ ] At least one example profile provided
- [ ] Templates for all document types
- [ ] ATOM logging integration tested

---

## Rollback & Recovery

### Uninstallation

```bash
# KENL13-iwi has no system installation
# Simply stop using the module

# Optional: Remove captured data
rm -rf ~/.iwi/
```

### Resource Corruption Recovery

```bash
# If resources fail verification
./bin/iwi-verify-resources

# If checksums mismatch, re-download (when update tool ready)
# ./bin/iwi-update-docs --force
```

---

## Maintenance

### Update Procedure

```bash
# Update KENL13-iwi with kenl repository
cd ~/kenl
git pull origin main

# Verify resources after update
cd modules/KENL13-iwi
./bin/iwi-verify-resources
```

### Resource Updates (Maintainers)

```bash
# Update Bazzite documentation (when tool ready)
# ./bin/iwi-update-docs --snapshot-date $(date +%Y-%m-%d)

# Update ISO hashes
# ./bin/iwi-update-iso-hashes

# Regenerate checksums and signatures
# ./bin/iwi-generate-checksums
# ./bin/iwi-sign-checksums

# Verify all resources
./bin/iwi-verify-resources

# Commit with ATOM tag
# git add resources/
# git commit -m "chore: update iWi resources
#
# ATOM-IWI-$(date +%Y%m%d)-XXX"
```

### Health Checks

```bash
# Verify resources integrity
./bin/iwi-verify-resources

# Check ATOM logs
tail ~/.atom-logs/atom-$(date +%Y%m%d).log | grep IWI

# Verify module files
ls -la bin/ lib/ resources/ docs/ examples/ tests/ templates/
```

---

## Known Issues

### Current Issues

1. **Incomplete Tooling**: Capture, validation, and profile generation tools not yet implemented
   - **Status**: Framework complete, tools planned
   - **Workaround**: Manual YAML creation using templates (when available)

2. **Empty Resources**: Static Bazzite documentation not yet populated
   - **Status**: Framework and verification ready, awaiting first snapshot
   - **Workaround**: Reference online docs.bazzite.gg

### Limitations

1. **Manual Capture**: Installation capture requires manual logging (automated capture planned)
2. **Bazzite-Specific**: Currently focused on Bazzite (extensible to other immutable distros)
3. **GPG Key**: KENL project GPG key not yet generated (planned)

---

## Roadmap

### Phase 1: Foundation (Current)
- [x] Module structure created
- [x] Resource verification framework
- [x] Documentation (README, MANIFEST, RESOURCES)
- [ ] IWI_SPECIFICATION.md
- [ ] Document templates

### Phase 2: Core Tools
- [ ] iwi-capture tool
- [ ] iwi-validate tool
- [ ] iwi-profile-generate tool
- [ ] Example installation profiles

### Phase 3: Resources
- [ ] Capture Bazzite documentation
- [ ] Official ISO hashes
- [ ] GPG key generation and signing
- [ ] Community profiles repository

### Phase 4: Integration
- [ ] Automated installation logging
- [ ] Hardware profile detection
- [ ] Performance benchmarking
- [ ] Web-based profile viewer

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-11-12 | Initial release with resource verification framework |

---

## References

### Internal Documentation

- `README.md` - Module overview and usage
- `IWI_SPECIFICATION.md` - Complete iWi specification (TBD)
- `resources/RESOURCES.md` - Trusted resources inventory
- `../KENL1-framework/atom-sage-framework/forks/ATOM-IWI/` - OWI fork documentation

### External Resources

- [Bazzite Official](https://bazzite.gg/) - Bazzite homepage
- [Bazzite Documentation](https://docs.bazzite.gg/) - Official docs
- [Universal Blue](https://universal-blue.org/) - Upstream project
- [rpm-ostree](https://coreos.github.io/rpm-ostree/) - Immutable OS documentation

---

## Metadata

- **Created:** 2025-11-12
- **Last Updated:** 2025-11-12
- **Maintainer:** toolate28/kenl
- **ATOM Tag:** ATOM-DOC-20251112-006
- **Classification:** OWI-DOC
- **Status:** Active - Foundation Phase
- **Module:** KENL13-iwi (Installing With Intent)

---
