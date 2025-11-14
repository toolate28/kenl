---
title: SAIF Framework - Claude Landing Zone
classification: OWI-DOC
atom: ATOM-DOC-20251114-050
framework: SAIF
version: 2025-11-14
description: Quick orientation for AI agents working with SAIF framework
---

# Claude Landing Zone - SAIF Framework

**START HERE when beginning any SAIF-related task**

## What is This Directory?

This is your **orientation hub** for the SAIF (System-Aware Intent Framework) project. Think of it as a "README for AI agents" - everything you need to get up to speed quickly.

---

## 🚀 Quick Start (New AI Instance)

### **1. Read These Files (In Order)**

**First 3 minutes:**
1. **This file** (README.md) - Overview and navigation
2. **CURRENT-STATE.md** - What's the current status?
3. **QUICK-REFERENCE.md** - Common paths, commands, examples

**Next 10 minutes (if doing real work):**
4. **RECENT-WORK.md** - What was done in the last session?
5. **FRAMEWORK-SUMMARY.md** - Core SAIF principles
6. **IMPLEMENTATION-STATUS.md** - What's built, what's pending?

### **2. Validate Documented State (CTF Protocol)**

Before starting work, verify these expectations match reality:

```bash
# Platform check
uname -a  # Should be: Linux (or report actual)

# Git status
git status
git log --oneline -5
# Should match: CURRENT-STATE.md recent commits

# SAIF files exist
ls -la dotfiles/
# Should see: README.md, SAIF-FRAMEWORK.md, bootstrap.sh, etc.

# Git branch
git branch --show-current
# Should be: claude/context-refactor-projects-01WXYnHnSHDhWhTnRmokDubX
```

**If anything doesn't match:** Report discrepancy in 🚩 FLAG MISMATCH format (see RECENT-WORK.md for template).

### **3. Understand the Context**

**What is SAIF?**
- **S**ystem-**A**ware **I**ntent **F**ramework (pronounced "safe")
- Dotfiles system capturing intent, not just actions
- Built on KENL/ATOM/SAGE/OWI principles
- Cross-platform: Linux/WSL2/Windows
- Industry-agnostic: Software, automotive, aerospace, medical devices

**Core Principles:**
1. **Transparency** - Document AI involvement (OWI metadata)
2. **Traceability** - ATOM trails capture WHY + WHAT + WHEN
3. **Intentionality** - Every change has documented reasoning
4. **Reproducibility** - Shareable profiles (Play Card style)
5. **Rollback Safety** - User-space only, multiple rollback strategies
6. **Confidentiality** - Multi-tier classification (PUBLIC → CLIENT-SPECIFIC)

---

## 📂 Directory Structure

```
dotfiles/
├── claude-landing/              ← YOU ARE HERE
│   ├── README.md               ← This file
│   ├── CURRENT-STATE.md        ← Current status snapshot
│   ├── RECENT-WORK.md          ← Session handoffs
│   ├── QUICK-REFERENCE.md      ← Commands, paths, examples
│   ├── FRAMEWORK-SUMMARY.md    ← Core SAIF principles
│   └── IMPLEMENTATION-STATUS.md ← What's done/pending
│
├── README.md                    ← Main SAIF documentation
├── SAIF-FRAMEWORK.md           ← Complete framework specification
├── SAIF-NDA-WORKFLOW.md        ← Confidentiality management
├── SAIF-PROFESSIONAL-AUTOMOTIVE.md  ← Enterprise version
├── SAIF-AUTOMOTIVE-R&D-PROTOTYPER.md  ← Shop floor view
├── SAIF-AUTOMOTIVE-GM-DIRECTOR.md     ← Executive view
│
├── .sage-dotfiles.yaml         ← Pattern recognition config
├── .atom-trail.log             ← Change history (if exists)
├── bootstrap.sh                ← Installation script
├── rollback.sh                 ← Rollback script (TODO)
│
├── profiles/                   ← Shareable configurations
│   └── amd-ryzen5-5600h-vega/  ← Example hardware profile
│       ├── profile.yaml        ← OWI metadata + benchmarks
│       └── kenl0-system/       ← Layer configs
│           ├── .bashrc
│           └── .bash_aliases
│
├── templates/                  ← Config templates (TODO)
└── backups/                    ← Timestamped backups (TODO)
```

---

## 🎯 Common Tasks

### **Task: Understand SAIF Framework**
**Read:** `SAIF-FRAMEWORK.md` (comprehensive philosophy)
**Quick version:** `FRAMEWORK-SUMMARY.md` (this directory)

### **Task: Add New Profile**
1. Read: `profiles/amd-ryzen5-5600h-vega/profile.yaml` (example)
2. Create: `profiles/YOUR-PROFILE-NAME/profile.yaml`
3. Include: OWI metadata, hardware specs, benchmarks, ATOM tags
4. Test: `./bootstrap.sh --profile YOUR-PROFILE-NAME`

### **Task: Implement Missing Script**
**Check:** `IMPLEMENTATION-STATUS.md` (lists TODOs)
**Examples needed:**
- `rollback.sh` - Rollback to previous ATOM tag
- `verify-dotfiles.sh` - Check symlinks/configs
- `export-profile.sh` - Package profile as tarball
- `import-profile.sh` - Import external profile

**Pattern:** Look at `bootstrap.sh` for coding style, error handling, ATOM trail integration.

### **Task: Apply to New Industry**
**Templates available:**
- Software: `SAIF-FRAMEWORK.md` (original dotfiles)
- Automotive: `SAIF-PROFESSIONAL-AUTOMOTIVE.md`
- Shop floor: `SAIF-AUTOMOTIVE-R&D-PROTOTYPER.md`
- Executive: `SAIF-AUTOMOTIVE-GM-DIRECTOR.md`

**Process:**
1. Copy relevant template
2. Replace industry-specific examples
3. Keep core principles intact (ATOM, SAGE, OWI, confidentiality)
4. Add industry-specific ATOM tag prefixes

### **Task: Debug Issue**
1. **Check ATOM trail:** `cat .atom-trail.log` (if exists)
2. **Check recent commits:** `git log --oneline -10`
3. **Check recent work:** Read `RECENT-WORK.md`
4. **Validate state:** Run commands from QUICK-REFERENCE.md

---

## 🚩 CTF (Capture The Flag) Protocol

**What are flags?**
Documented expectations in `CURRENT-STATE.md` that you should validate before starting work.

**Why validate?**
Documentation can drift from reality (git state changed, files moved, configs updated).

**How to capture flags:**
1. Read expectations in CURRENT-STATE.md
2. Run validation commands
3. Report results (✅ pass or 🚩 fail)
4. If failed: Investigate root cause, update docs

**Example flag:**
```
FLAG: SAIF-01
Expectation: Git branch is claude/context-refactor-projects-01WXYnHnSHDhWhTnRmokDubX
Validation: git branch --show-current
Status: ✅ PASS (matches documented state)
```

**See:** `RECENT-WORK.md` for complete CTF protocol and flag examples.

---

## 📋 Quick Reference

### **Key Files**

| File | Purpose | Read When... |
|------|---------|--------------|
| `README.md` | Main SAIF docs | Learning framework |
| `SAIF-FRAMEWORK.md` | Complete spec | Deep dive needed |
| `SAIF-NDA-WORKFLOW.md` | Confidentiality | Handling sensitive data |
| `SAIF-PROFESSIONAL-AUTOMOTIVE.md` | Enterprise version | Professional deployment |
| `bootstrap.sh` | Installation | Implementing new features |
| `.sage-dotfiles.yaml` | SAGE config | Understanding pattern learning |

### **Essential Commands**

```bash
# Navigate to SAIF
cd ~/kenl/dotfiles

# View recent work
cat claude-landing/RECENT-WORK.md

# Check git status
git status
git log --oneline -10

# Test bootstrap (dry-run)
./bootstrap.sh --help

# View ATOM trails (if exists)
cat .atom-trail.log

# View SAGE patterns (if exists)
grep "learned_patterns:" .sage-dotfiles.yaml -A 20
```

### **ATOM Tag Format**

```
ATOM-{TYPE}-{YYYYMMDD}-{NNN}: {ACTION} (intent: {INTENT})

Types:
- ATOM-DOC-*   - Documentation
- ATOM-CFG-*   - Configuration changes
- ATOM-FAB-*   - Fabrication work (automotive)
- ATOM-TEST-*  - Testing/validation
- ATOM-NDA-*   - Confidentiality/legal
```

---

## 🎓 Learning Path

### **Beginner (1 hour)**
1. Read: This README
2. Read: `SAIF-FRAMEWORK.md` (skim sections)
3. Explore: `profiles/amd-ryzen5-5600h-vega/` (example)
4. Understand: What problem SAIF solves

### **Intermediate (3 hours)**
1. Read: `SAIF-NDA-WORKFLOW.md` (confidentiality)
2. Study: `bootstrap.sh` (implementation patterns)
3. Review: `.sage-dotfiles.yaml` (pattern recognition)
4. Practice: Create a test profile

### **Advanced (8 hours)**
1. Read: All SAIF documents
2. Study: ATOM/SAGE/OWI/KENL frameworks (parent repo)
3. Implement: Missing scripts (rollback, verify, export)
4. Apply: To new industry (your use case)

---

## ❓ Decision Trees

### **"Should I use SAIF for my project?"**

**YES if:**
- ✅ You do custom/bespoke work (not mass production)
- ✅ Expertise is valuable and hard-won
- ✅ You need to preserve knowledge (training, continuity)
- ✅ Legal liability is a concern (warranty, disputes)
- ✅ Customer confidentiality matters
- ✅ You want to productize proven solutions

**NO if:**
- ❌ You do identical work every time (assembly line)
- ❌ Processes are fully documented elsewhere (ISO procedures)
- ❌ No customization (pure off-shelf products)
- ❌ Knowledge preservation not important (high turnover OK)

**MAYBE if:**
- ⚠️ You do semi-custom work (configure from catalog)
- ⚠️ You're a solo operator (SAIF helps, but overhead higher)
- ⚠️ You're in regulated industry (SAIF can help, but check compliance first)

### **"Which SAIF document should I read?"**

```
START: What's your role?

├─ Software Developer
│  └─ Read: SAIF-FRAMEWORK.md (original dotfiles context)
│
├─ Automotive Technician/Machinist
│  └─ Read: SAIF-AUTOMOTIVE-R&D-PROTOTYPER.md (shop floor focus)
│
├─ Business Owner/Manager
│  └─ Read: SAIF-AUTOMOTIVE-GM-DIRECTOR.md (ROI, business value)
│
├─ Enterprise IT/Compliance
│  └─ Read: SAIF-PROFESSIONAL-AUTOMOTIVE.md (enterprise-grade)
│      Then: SAIF-NDA-WORKFLOW.md (confidentiality management)
│
└─ AI Agent/Developer
   └─ Read: This README → FRAMEWORK-SUMMARY.md → IMPLEMENTATION-STATUS.md
```

---

## 🔧 Troubleshooting

### **"I can't find file X"**
- Check: `IMPLEMENTATION-STATUS.md` (might be TODO)
- Check: `git log --all --oneline -- path/to/file` (might be in different branch)
- Check: `RECENT-WORK.md` (might document why it's missing)

### **"Documentation contradicts reality"**
- This is a 🚩 FLAG MISMATCH
- Report format (from RECENT-WORK.md):
  ```
  🚩 FLAG MISMATCH: [Description]
  Expected: [What docs say]
  Reality: [What you found]
  Impact: [Does this affect current task?]
  Action: [Update docs OR investigate root cause]
  ```

### **"I don't understand ATOM/SAGE/OWI/KENL"**
- Read: `FRAMEWORK-SUMMARY.md` (quick overview)
- Read: `/home/user/kenl/CLAUDE.md` (parent project docs)
- Read: `/home/user/kenl/OWI_FRAMEWORK_OVERVIEW.md` (OWI details)
- Read: `/home/user/kenl/atom-sage-framework/README.md` (ATOM/SAGE deep dive)

### **"Git branch is wrong"**
**Expected:** `claude/context-refactor-projects-01WXYnHnSHDhWhTnRmokDubX`

**If different:**
```bash
# Check if branch exists
git branch -a | grep context-refactor

# Switch to correct branch
git checkout claude/context-refactor-projects-01WXYnHnSHDhWhTnRmokDubX

# Or create if needed
git checkout -b claude/context-refactor-projects-01WXYnHnSHDhWhTnRmokDubX
```

---

## 🤝 Working with Other AI Agents

### **Session Handoff Protocol**

**When you finish work:**
1. Update `RECENT-WORK.md` with:
   - What you accomplished
   - What's incomplete
   - Any blockers/issues
   - New flags to validate
2. Update `IMPLEMENTATION-STATUS.md` if you completed TODOs
3. Update `CURRENT-STATE.md` if environment changed
4. Create ATOM trail entries (if working with actual dotfiles)
5. Git commit with descriptive message + ATOM tags

**When you start work:**
1. Read `RECENT-WORK.md` first (last session's context)
2. Validate flags (CTF protocol)
3. Check git log (what changed since docs written)
4. Report any mismatches before proceeding

### **Communication Standards**

**Use ATOM tags in:**
- Git commit messages
- Documentation updates
- File headers (YAML frontmatter)
- Code comments (where intent matters)

**Use OWI metadata in:**
- All new documents (YAML frontmatter)
- Profile definitions
- Build sheets
- Anything AI-generated

**Use consistent terminology:**
- "SAIF" not "the framework" or "this system"
- "ATOM trail" not "log" or "history"
- "Profile" not "config" or "setup"
- "Classification" not "confidentiality level" (use standard tiers)

---

## 📊 Success Metrics

**You're on the right track if:**
- ✅ You read orientation docs before starting work
- ✅ You validated flags (CTF protocol)
- ✅ You understand the intent behind SAIF (not just implementation)
- ✅ You're preserving existing patterns (ATOM tags, OWI metadata)
- ✅ You're updating docs as you go (not just code)

**Red flags:**
- ❌ You started coding without reading claude-landing/
- ❌ You don't understand why SAIF exists (just implementing features)
- ❌ You're not using ATOM tags in commits
- ❌ You're not including OWI metadata in new files
- ❌ You haven't checked if docs match reality

---

## 🎯 Next Steps

**Choose your path:**

### **Path 1: I'm learning SAIF**
→ Read `FRAMEWORK-SUMMARY.md` next
→ Then explore example profile: `profiles/amd-ryzen5-5600h-vega/`

### **Path 2: I'm implementing SAIF features**
→ Read `IMPLEMENTATION-STATUS.md` (see TODOs)
→ Study `bootstrap.sh` (coding patterns)
→ Pick a TODO and implement

### **Path 3: I'm applying SAIF to new industry**
→ Read relevant template (automotive, software, etc.)
→ Study industry-specific examples
→ Create your own industry-specific document

### **Path 4: I'm debugging an issue**
→ Read `RECENT-WORK.md` (recent session context)
→ Check `CURRENT-STATE.md` (documented expectations)
→ Validate flags (find the mismatch)

---

## 📚 Related Resources

**In this repository:**
- `/home/user/kenl/CLAUDE.md` - Parent KENL project instructions
- `/home/user/kenl/OWI_FRAMEWORK_OVERVIEW.md` - OWI specification
- `/home/user/kenl/atom-sage-framework/` - ATOM/SAGE deep dive
- `/home/user/kenl/claude-landing/` - KENL orientation (parent project)

**External:**
- SAIF originated from KENL dotfiles refactoring
- KENL originated from Bazzite-DX gaming + Windows 10 EOL migration
- ATOM/SAGE/OWI are the foundational methodologies

---

## 💡 Philosophy

**SAIF exists because:**
1. **Knowledge is expensive** - Years of expertise shouldn't walk out the door
2. **Intent matters** - "What" without "why" is fragile (breaks when assumptions change)
3. **Transparency builds trust** - Customers/users deserve to know what AI generated
4. **Reproducibility scales** - Proven solutions should be shareable
5. **Confidentiality is real** - Not everything should be public
6. **Rollback is essential** - Changes should be reversible (safety net)

**Core belief:**
> "AI tools should enhance the human, not replace them. Documentation captures intent so humans remain authoritative, even when AI assists."

---

**Welcome to SAIF! 🎉**

**ATOM:** ATOM-DOC-20251114-050
**Classification:** OWI-DOC
**Framework:** SAIF v1.0.0
**Purpose:** AI agent orientation for SAIF framework
