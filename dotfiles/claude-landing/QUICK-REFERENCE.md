---
title: SAIF Framework - Quick Reference
classification: OWI-REFERENCE
atom: ATOM-DOC-20251114-052
framework: SAIF
version: 2025-11-14
description: Quick commands, paths, and examples for SAIF framework
---

# SAIF Framework - Quick Reference

**Fast lookup for common operations**

---

## 📂 Key Paths

```bash
# SAIF root
cd ~/kenl/dotfiles

# Claude landing (orientation docs)
cd ~/kenl/dotfiles/claude-landing

# Profiles directory
cd ~/kenl/dotfiles/profiles

# Example profile
cd ~/kenl/dotfiles/profiles/amd-ryzen5-5600h-vega

# KENL parent project
cd ~/kenl
```

---

## 🚀 Common Commands

### **Navigation & Exploration**

```bash
# View SAIF documentation
cat ~/kenl/dotfiles/README.md

# View framework specification
cat ~/kenl/dotfiles/SAIF-FRAMEWORK.md

# View current state
cat ~/kenl/dotfiles/claude-landing/CURRENT-STATE.md

# View recent work
cat ~/kenl/dotfiles/claude-landing/RECENT-WORK.md

# List all SAIF documents
ls -lh ~/kenl/dotfiles/*.md

# List profiles
ls -la ~/kenl/dotfiles/profiles/
```

### **Git Operations**

```bash
# Check git status
git status

# View recent commits
git log --oneline -10

# View current branch
git branch --show-current

# View all branches
git branch -a

# View changes in current branch
git diff main..HEAD

# View files changed in SAIF work
git diff main..HEAD --name-only | grep dotfiles
```

### **ATOM Trail Operations**

```bash
# View ATOM trail (if exists)
cat ~/kenl/dotfiles/.atom-trail.log

# View recent ATOM entries
tail -n 20 ~/kenl/dotfiles/.atom-trail.log

# Search ATOM trail by type
grep "ATOM-CFG" ~/kenl/dotfiles/.atom-trail.log

# Search ATOM trail by date
grep "20251114" ~/kenl/dotfiles/.atom-trail.log

# Count ATOM entries
wc -l ~/kenl/dotfiles/.atom-trail.log
```

### **SAGE Pattern Recognition**

```bash
# View SAGE configuration
cat ~/kenl/dotfiles/.sage-dotfiles.yaml

# View learned patterns
grep "learned_patterns:" ~/kenl/dotfiles/.sage-dotfiles.yaml -A 30

# View pattern recognition settings
grep "pattern_recognition:" ~/kenl/dotfiles/.sage-dotfiles.yaml -A 20

# View guard rails
grep "guard_rails:" ~/kenl/dotfiles/.sage-dotfiles.yaml -A 15
```

### **Profile Operations**

```bash
# View example profile metadata
cat ~/kenl/dotfiles/profiles/amd-ryzen5-5600h-vega/profile.yaml

# List profile contents
ls -la ~/kenl/dotfiles/profiles/amd-ryzen5-5600h-vega/

# View profile bashrc
cat ~/kenl/dotfiles/profiles/amd-ryzen5-5600h-vega/kenl0-system/.bashrc

# View profile aliases
cat ~/kenl/dotfiles/profiles/amd-ryzen5-5600h-vega/kenl0-system/.bash_aliases
```

### **Bootstrap Operations**

```bash
# View bootstrap help
~/kenl/dotfiles/bootstrap.sh --help

# Test bootstrap (dry-run if implemented)
# ~/kenl/dotfiles/bootstrap.sh --dry-run

# Bootstrap with specific profile (when ready)
# ~/kenl/dotfiles/bootstrap.sh --profile amd-ryzen5-5600h-vega

# Bootstrap with backup
# ~/kenl/dotfiles/bootstrap.sh --profile minimal --backup-existing
```

---

## 📋 ATOM Tag Format

### **Standard Format**

```
ATOM-{TYPE}-{YYYYMMDD}-{NNN}: {ACTION} (intent: {INTENT})
```

### **Tag Types**

| Prefix | Usage | Example |
|--------|-------|---------|
| `ATOM-DOC-` | Documentation | ATOM-DOC-20251114-001: Created SAIF README |
| `ATOM-CFG-` | Configuration | ATOM-CFG-20251114-002: Applied gaming profile |
| `ATOM-FAB-` | Fabrication (automotive) | ATOM-FAB-20251114-003: Custom turbo flange |
| `ATOM-TEST-` | Testing/validation | ATOM-TEST-20251114-004: Dyno verification |
| `ATOM-INTAKE-` | Customer consultation | ATOM-INTAKE-20251114-005: Initial quote |
| `ATOM-NDA-` | Confidentiality/legal | ATOM-NDA-20251114-006: NDA executed |
| `ATOM-DEPLOY-` | Production deployment | ATOM-DEPLOY-20251114-007: Live system update |
| `ATOM-ROLLBACK-` | Rollback operation | ATOM-ROLLBACK-20251114-008: Reverted to previous |
| `ATOM-PATTERN-` | SAGE learned pattern | ATOM-PATTERN-20251114-009: Gaming-prep sequence |

### **Examples**

```bash
# Software development
ATOM-CFG-20251114-001: Applied dev-focused profile (intent: optimize for VSCode)
ATOM-TEST-20251114-002: Verified git GPG signing works (intent: security)

# Automotive fabrication
ATOM-FAB-20251114-010: Custom turbo manifold RB26 (intent: 400kW target)
ATOM-TEST-20251114-011: Pressure test 40 PSI passed (intent: safety validation)

# Business operations
ATOM-INTAKE-20251114-020: Customer consultation CUST-2025-047 (intent: quote turbo kit)
ATOM-NDA-20251114-021: Executed CLIENT-SPECIFIC NDA (intent: prototype vehicle)
```

---

## 🔐 Confidentiality Tiers

| Tier | Symbol | Who Sees It | Use Case |
|------|--------|-------------|----------|
| **PUBLIC** | 🌍 | Everyone | Marketing, education |
| **COMMUNITY-SHARED** | 🤝 | Industry peers | Anonymized tech sharing |
| **INTERNAL-ONLY** | 🏢 | Staff only | Full customer records |
| **CLIENT-SPECIFIC** | 🔒 | Customer + authorized staff | NDA-protected work |
| **NO-DOCUMENTATION** | 🚫 | Nobody | ⚠️ Reject these jobs |

### **Classification Examples**

```yaml
# PUBLIC
classification: PUBLIC
content: "We specialize in turbo fabrication"
sharing: Unrestricted

# COMMUNITY-SHARED
classification: COMMUNITY-SHARED
content: "RB26 turbo kit build sheet (anonymized)"
sharing: Forums, industry peers, no customer identity

# INTERNAL-ONLY
classification: INTERNAL-ONLY
content: "Customer: John Smith, VIN: ABC123, Phone: 0412-345-678"
sharing: Staff access only, encrypted storage

# CLIENT-SPECIFIC
classification: CLIENT-SPECIFIC
content: "2026 GTR prototype testing"
sharing: NDA required, customer approval mandatory
```

---

## 🛠️ OWI Metadata Template

### **YAML Frontmatter (All Documents)**

```yaml
---
title: [Document Title]
classification: [OWI-DOC|OWI-STANDARD|CWI-PLAYBOOK|etc]
atom: ATOM-DOC-YYYYMMDD-NNN
framework: SAIF
version: YYYY-MM-DD
description: [Brief description]
confidentiality: [PUBLIC|COMMUNITY-SHARED|INTERNAL-ONLY|CLIENT-SPECIFIC]
---
```

### **Profile Metadata Template**

```yaml
---
profile: [profile-name]
framework: SAIF
classification: CWI-PLAYBOOK
atom: ATOM-CFG-YYYYMMDD-NNN
owi-version: 1.0.0
saif-version: 1.0.0
last-updated: YYYY-MM-DD
description: [Profile description]

hardware:
  cpu: [CPU model]
  gpu: [GPU model]
  ram: [RAM size]

benchmarks:
  [benchmark-name]:
    [metric]: [value]

ai_involvement:
  generated_by: [AI model]
  human_review: [true|false]
  modifications: [Description of human changes]

rollback_plan: |
  [Instructions for reverting this profile]
---
```

---

## 📝 Git Commit Message Format

### **Standard Format**

```
<type>: <subject>

<optional body>

ATOM-<TYPE>-<YYYYMMDD>-<NNN>
```

### **Types**

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation only
- `refactor:` Code restructuring
- `test:` Adding tests
- `chore:` Maintenance

### **Examples**

```bash
# Feature commit
git commit -m "feat: add rollback script with ATOM trail integration

Implements rollback.sh with three strategies:
- Git commit-based rollback
- ATOM tag-based rollback
- Timestamped backup restoration

ATOM-CFG-20251114-050"

# Documentation commit
git commit -m "docs: complete claude-landing orientation docs

Created README, CURRENT-STATE, QUICK-REFERENCE for AI agents.

ATOM-DOC-20251114-052"

# Fix commit
git commit -m "fix: correct bootstrap.sh platform detection

WSL2 was incorrectly detected as native Linux.
Added /proc/version check for Microsoft signature.

ATOM-CFG-20251114-055"
```

---

## 🎯 Validation Commands (CTF Protocol)

### **Platform Validation**

```bash
# Detect platform
uname -a

# Expected patterns:
# Linux: "Linux ... x86_64"
# WSL2: "Linux ... Microsoft"
# macOS: "Darwin"
```

### **Git Validation**

```bash
# Check current branch
git branch --show-current
# Expected: claude/context-refactor-projects-01WXYnHnSHDhWhTnRmokDubX

# Check working directory status
git status
# Expected: "nothing to commit, working tree clean" (or pending changes)

# Check recent commits match docs
git log --oneline -5
# Compare with CURRENT-STATE.md recent commits
```

### **File Existence Validation**

```bash
# Core SAIF files
test -f ~/kenl/dotfiles/README.md && echo "✅ README exists"
test -f ~/kenl/dotfiles/SAIF-FRAMEWORK.md && echo "✅ Framework spec exists"
test -f ~/kenl/dotfiles/.sage-dotfiles.yaml && echo "✅ SAGE config exists"
test -x ~/kenl/dotfiles/bootstrap.sh && echo "✅ Bootstrap is executable"

# Profile structure
test -d ~/kenl/dotfiles/profiles/amd-ryzen5-5600h-vega && echo "✅ Example profile exists"
test -f ~/kenl/dotfiles/profiles/amd-ryzen5-5600h-vega/profile.yaml && echo "✅ Profile metadata exists"

# Claude landing
test -d ~/kenl/dotfiles/claude-landing && echo "✅ Claude landing exists"
test -f ~/kenl/dotfiles/claude-landing/README.md && echo "✅ Landing README exists"
```

### **Content Validation**

```bash
# Count SAIF documents
ls ~/kenl/dotfiles/*.md | wc -l
# Expected: 6-7 files

# Count profile directories
ls -d ~/kenl/dotfiles/profiles/*/ 2>/dev/null | wc -l
# Expected: 1 (amd-ryzen5-5600h-vega)

# Check SAGE config syntax (YAML)
grep "^system:" ~/kenl/dotfiles/.sage-dotfiles.yaml
# Should return: "system:"
```

---

## 🔄 Common Workflows

### **Workflow 1: Create New Profile**

```bash
# 1. Create profile directory
mkdir -p ~/kenl/dotfiles/profiles/my-new-profile

# 2. Copy example profile.yaml
cp ~/kenl/dotfiles/profiles/amd-ryzen5-5600h-vega/profile.yaml \
   ~/kenl/dotfiles/profiles/my-new-profile/profile.yaml

# 3. Edit profile.yaml
vim ~/kenl/dotfiles/profiles/my-new-profile/profile.yaml
# Update: profile name, hardware specs, benchmarks

# 4. Create kenl-layer configs
mkdir -p ~/kenl/dotfiles/profiles/my-new-profile/kenl0-system
# Add: .bashrc, .bash_aliases, etc.

# 5. Test bootstrap
~/kenl/dotfiles/bootstrap.sh --profile my-new-profile

# 6. Commit with ATOM tag
git add ~/kenl/dotfiles/profiles/my-new-profile
git commit -m "feat: add my-new-profile

ATOM-CFG-20251114-XXX"
```

### **Workflow 2: Apply Existing Profile**

```bash
# 1. View available profiles
ls ~/kenl/dotfiles/profiles/

# 2. Read profile metadata
cat ~/kenl/dotfiles/profiles/PROFILE-NAME/profile.yaml

# 3. Backup current configs (optional)
tar -czf ~/dotfiles-backup-$(date +%Y%m%d).tar.gz \
  ~/.bashrc ~/.bash_aliases ~/.gitconfig 2>/dev/null

# 4. Apply profile
~/kenl/dotfiles/bootstrap.sh --profile PROFILE-NAME --backup-existing

# 5. Verify installation
~/kenl/dotfiles/verify-dotfiles.sh  # (when implemented)

# 6. Test (restart shell, run apps, verify configs work)
```

### **Workflow 3: Rollback Changes**

```bash
# 1. View ATOM trail to find rollback point
cat ~/kenl/dotfiles/.atom-trail.log

# 2. Identify ATOM tag or git commit
# Example: ATOM-CFG-20251114-025

# 3. Rollback via ATOM tag (when implemented)
~/kenl/dotfiles/rollback.sh ATOM-CFG-20251114-025

# Or rollback via git commit
git log --oneline -10  # Find commit hash
git reset --hard abc1234

# Or rollback via backup
ls ~/kenl/dotfiles/backups/
~/kenl/dotfiles/rollback.sh --from-backup dotfiles-backup-20251114.tar.gz

# 4. Verify rollback successful
git status
source ~/.bashrc  # Reload configs
```

### **Workflow 4: Redact INTERNAL → COMMUNITY-SHARED**

```bash
# 1. Create INTERNAL version first (full customer data)
vim ~/kenl/dotfiles/atom-trails/ATOM-FAB-20251114-XXX-INTERNAL.yaml

# 2. Run automated redaction
~/kenl/dotfiles/redact-atom-trail.sh \
  ~/kenl/dotfiles/atom-trails/ATOM-FAB-20251114-XXX-INTERNAL.yaml

# Creates: ATOM-FAB-20251114-XXX-INTERNAL-REDACTED.yaml

# 3. Manual review checklist
# - Customer name → Customer ID
# - VIN/Rego → [REDACTED]
# - Phone/Email → [REDACTED]
# - Address → [REDACTED]
# - Photos: Blur plates, faces

# 4. Rename to COMMUNITY-SHARED
mv ~/kenl/dotfiles/atom-trails/ATOM-FAB-20251114-XXX-INTERNAL-REDACTED.yaml \
   ~/kenl/dotfiles/atom-trails/ATOM-FAB-20251114-XXX-COMMUNITY.yaml

# 5. Publish (if approved)
cp ~/kenl/dotfiles/atom-trails/ATOM-FAB-20251114-XXX-COMMUNITY.yaml \
   ~/kenl/modules/KENL12-resources/community-profiles/
```

---

## 🐛 Troubleshooting Quick Fixes

### **Problem: Bootstrap fails**

```bash
# Check executable permissions
chmod +x ~/kenl/dotfiles/bootstrap.sh

# Check syntax
bash -n ~/kenl/dotfiles/bootstrap.sh

# Run with debug output
bash -x ~/kenl/dotfiles/bootstrap.sh --profile minimal
```

### **Problem: Git branch wrong**

```bash
# View current branch
git branch --show-current

# Switch to correct branch
git checkout claude/context-refactor-projects-01WXYnHnSHDhWhTnRmokDubX

# Or create if missing
git checkout -b claude/context-refactor-projects-01WXYnHnSHDhWhTnRmokDubX
```

### **Problem: Files don't match docs**

```bash
# Check if you're in correct directory
pwd
# Should be: /home/user/kenl/dotfiles

# Check git status (uncommitted changes?)
git status

# Check if on correct branch
git branch --show-current

# View file differences
git diff main..HEAD -- dotfiles/
```

### **Problem: Can't find ATOM trail**

```bash
# ATOM trail might not exist yet (no real usage)
test -f ~/kenl/dotfiles/.atom-trail.log && echo "Exists" || echo "Not created yet"

# Create empty ATOM trail
touch ~/kenl/dotfiles/.atom-trail.log
echo "ATOM-INIT-$(date +%Y%m%d)-001: Initialized ATOM trail" >> ~/kenl/dotfiles/.atom-trail.log
```

---

## 🔗 Important Links

### **Within Repository**

- Main KENL README: `/home/user/kenl/README.md`
- KENL instructions: `/home/user/kenl/CLAUDE.md`
- OWI framework: `/home/user/kenl/OWI_FRAMEWORK_OVERVIEW.md`
- ATOM/SAGE: `/home/user/kenl/atom-sage-framework/README.md`
- KENL modules: `/home/user/kenl/modules/KENL*/`

### **SAIF Documents**

- SAIF root: `/home/user/kenl/dotfiles/`
- Main docs: `/home/user/kenl/dotfiles/README.md`
- Framework spec: `/home/user/kenl/dotfiles/SAIF-FRAMEWORK.md`
- NDA workflow: `/home/user/kenl/dotfiles/SAIF-NDA-WORKFLOW.md`
- Professional version: `/home/user/kenl/dotfiles/SAIF-PROFESSIONAL-AUTOMOTIVE.md`
- Orientation: `/home/user/kenl/dotfiles/claude-landing/`

### **External Resources**

- KENL GitHub: https://github.com/toolate28/kenl
- Current branch PR: https://github.com/toolate28/kenl/pull/new/claude/context-refactor-projects-01WXYnHnSHDhWhTnRmokDubX

---

## 🎓 Learning Resources

### **Quick Start (15 minutes)**
1. Read: `claude-landing/README.md`
2. Skim: `SAIF-FRAMEWORK.md` (just section headers)
3. Explore: `profiles/amd-ryzen5-5600h-vega/`

### **Deep Dive (2 hours)**
1. Read: `SAIF-FRAMEWORK.md` (complete)
2. Read: `SAIF-NDA-WORKFLOW.md` (if handling confidential data)
3. Study: `bootstrap.sh` (implementation patterns)

### **Industry Application (1 hour each)**
- Software: `SAIF-FRAMEWORK.md` (original context)
- Automotive: `SAIF-PROFESSIONAL-AUTOMOTIVE.md`
- Shop floor: `SAIF-AUTOMOTIVE-R&D-PROTOTYPER.md`
- Executive: `SAIF-AUTOMOTIVE-GM-DIRECTOR.md`

---

**Quick reference complete. For detailed documentation, see full SAIF documents.**

**ATOM:** ATOM-DOC-20251114-052
**Classification:** OWI-REFERENCE
**Framework:** SAIF v1.0.0
