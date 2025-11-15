---
classification: AI-GUIDE
atom: ATOM-DOC-20251114-014
version: 1.0.0
last-updated: 2025-11-14
---

# AI Instance Maintenance Guide

**Purpose:** Proactive issue detection and prevention for AI assistants working on KENL.

This guide helps you catch common problems **before** the user reports them.

---

## Quick Self-Check (Run First)

When starting a new session or after major changes:

```bash
# 1. Validate all internal links
./scripts/validate-links.sh

# 2. Check module structure
ls -d modules/KENL* | wc -l  # Should be 14 (KENL0-13)

# 3. Verify key files exist
ls README.md ACKNOWLEDGMENTS.md SECURITY.md CODE_OF_CONDUCT.md

# 4. Check for uncommitted changes
git status --short
```

**If any checks fail:** Fix immediately before proceeding with user's task.

---

## Common Issues & Auto-Detection

### Issue 1: Broken Internal Links

**Pattern:** User says "this link doesn't work" or "404"

**Prevention:**
```bash
# Run link validator before committing docs
./scripts/validate-links.sh

# Add to pre-commit hook (optional)
```

**Common causes:**
- Old paths from before `modules/` reorganization
- File moved/renamed but links not updated
- Typo in filename or path
- Case sensitivity (Linux: `README.md` ≠ `readme.md`)

**Auto-fix:**
```bash
# The validator suggests fixes:
# "Did you mean: ./modules/KENL3-dev/ ?"
```

### Issue 2: Missing Module Links

**Pattern:** User says "KENLX isn't linked" or "can't click module name"

**Detection:**
```bash
# Check if all 14 modules are linked in README
grep -c '\[.*KENL[0-9].*\](./modules' README.md  # Should be ≥14
```

**Fix template:**
```markdown
# Before (not linked):
| **KENL11** Media | Streaming, Docker |

# After (linked):
| [**KENL11** Media](./modules/KENL11-media/) | Streaming, Docker |
```

### Issue 3: Footnote Mismatches

**Pattern:** "Footnote [^2] not found" or broken citation

**Detection:**
```bash
# Validator checks automatically:
./scripts/validate-links.sh | grep "FOOTNOTE"
```

**Manual check:**
```bash
# Count references vs definitions
grep -oP '\[\^[0-9]+\]' README.md | sort -u | wc -l     # References
grep -oP '^\[\^[0-9]+\]:' README.md | sort -u | wc -l   # Definitions
# Should match!
```

### Issue 4: Module Count Drift

**Pattern:** User says "you said 13 but there are 14"

**Prevention:**
```bash
# Auto-detect correct count
ACTUAL_COUNT=$(ls -d modules/KENL* | wc -l)
CLAIMED_COUNT=$(grep -oP '(?<=\*\*)\d+(?= specialized layers)' README.md)

if [[ "$ACTUAL_COUNT" != "$CLAIMED_COUNT" ]]; then
    echo "❌ Module count mismatch: README says $CLAIMED_COUNT, actually $ACTUAL_COUNT"
fi
```

**Fix locations:**
- `README.md` line ~106: "**14 specialized layers**"
- Module table (verify KENL0 through KENL13 listed)
- Mermaid diagrams (verify all modules shown)

### Issue 5: Old Path Patterns

**Pattern:** After refactoring, old paths persist

**Detection:**
```bash
# Find pre-modules reorganization paths
grep -r '](./KENL[0-9]' --include="*.md" . 2>/dev/null

# Should return nothing. If found, they're broken.
```

**Common legacy patterns:**
- `](./KENL2-gaming/)` → `](./modules/KENL2-gaming/)`
- `](KENL3/guides/)` → `](./modules/KENL3-dev/guides/)`

---

## Proactive Checks (Before Committing)

### Before Committing Documentation

```bash
# 1. Validate links
./scripts/validate-links.sh || exit 1

# 2. Check markdown formatting
pre-commit run --files $(git diff --name-only --cached)

# 3. Verify module references
grep "KENL" README.md | grep -v "modules/KENL" | grep "]("
# ^ Should be empty (all KENL refs should use modules/ path)

# 4. Check for Windows paths
grep -r '\\' --include="*.md" . | grep -v ".git"
# ^ Should only be in code blocks or Windows-specific docs
```

### Before Pushing PowerShell Modules

```bash
# 1. Verify manifests exist
ls modules/KENL0-system/powershell/*.psd1
# KENL.psd1, KENL.Network.psd1, KENL.Gaming.psd1, etc.

# 2. Check Author field (should be 'toolate28', NOT full name)
grep "Author = " modules/KENL0-system/powershell/*.psd1

# 3. Verify GUID uniqueness
grep "GUID = " modules/KENL0-system/powershell/*.psd1 | sort | uniq -d
# ^ Should be empty (no duplicate GUIDs)
```

### Before Major README Changes

```bash
# 1. Backup current README
cp README.md README.md.backup

# 2. Make changes

# 3. Validate everything
./scripts/validate-links.sh
grep -c "modules/KENL" README.md  # Should be high (lots of module refs)
grep -P '\[\^[0-9]+\]' README.md | sort | uniq | wc -l  # Count footnotes

# 4. Diff check
git diff README.md | grep "^-.*KENL" | grep -v "^---"
# ^ Review any removed KENL references
```

---

## Efficient Link Maintenance

### Pattern 1: Module Links in Tables

**Efficient approach:**
```markdown
| [**KENL0** System](./modules/KENL0-system/) | Purpose |
| [**KENL1** Framework](./modules/KENL1-framework/) | Purpose |
```

**Why:** Clickable module name, clear path, consistent pattern.

### Pattern 2: Deep Links to Guides

**Efficient approach:**
```markdown
[Ollama/Qwen](./modules/KENL3-dev/guides/OLLAMA-QWEN-LOCAL-AI-SETUP.md)
```

**Why:** Direct link to guide, not just module README.

### Pattern 3: Footnote Citations

**Efficient approach:**
```markdown
...claim here[^1]

[^1]: [Source Name](https://url) - Description of source.
```

**Why:** Footnote at bottom, inline reference in text, full citation.

---

## AI Self-Healing Workflows

### Workflow 1: User Reports Broken Link

1. **Don't ask for details** - Find and fix:
   ```bash
   ./scripts/validate-links.sh
   ```

2. **Fix all errors**, not just reported one

3. **Commit with clear message:**
   ```bash
   git commit -m "docs: fix broken internal links

   - Fixed [specific link]
   - Ran validator, found X other issues
   - All links now verified

   ATOM-DOC-YYYYMMDD-NNN"
   ```

### Workflow 2: Module Count Confusion

1. **Auto-detect actual count:**
   ```bash
   ls -d modules/KENL* | wc -l
   ```

2. **Update README in 3 places:**
   - "X specialized layers" text
   - Module table
   - Mermaid diagram

3. **Verify:**
   ```bash
   grep -c "KENL[0-9]" README.md  # Sanity check
   ```

### Workflow 3: New Module Added

**Checklist:**
- [ ] Create `modules/KENLX-name/README.md`
- [ ] Add to root README modules table (both columns)
- [ ] Add to Mermaid "Module Stack" diagram
- [ ] Update count: "14 specialized layers" → "15 specialized layers"
- [ ] Link from appropriate Documentation section
- [ ] Run `./scripts/validate-links.sh`
- [ ] Update CLAUDE.md module list

---

## Pattern Recognition

### When User Says "Check all the links"

**They mean:**
1. Internal markdown links (file:line references)
2. Footnote references vs definitions
3. Module links (especially newly added modules)
4. Old paths from refactoring

**Run:**
```bash
./scripts/validate-links.sh
```

### When User Says "The README needs attention"

**Check:**
1. Module count accuracy
2. All module names are linked
3. Mermaid diagrams render correctly
4. Footnotes match references
5. No broken Play Card examples

**Don't:**
- Rewrite entire README
- Change working links
- Remove Mermaid diagrams without reason

### When User Says "Add to docs so AI learns this"

**They want:**
- **This guide** updated with new patterns
- Pre-commit hooks for automation
- Scripts that catch issues automatically
- NOT just a list of what we fixed

---

## Maintenance Scripts

### Link Validator (`scripts/validate-links.sh`)

**What it checks:**
- ✅ All markdown links point to existing files
- ✅ Footnote references have definitions
- ✅ No old path patterns (pre-modules/ reorg)
- ✅ No Windows backslashes in paths

**Usage:**
```bash
./scripts/validate-links.sh           # Check only
./scripts/validate-links.sh --fix     # Suggest fixes (future)
```

**Add to CI:**
```yaml
# .github/workflows/ci.yml
- name: Validate Links
  run: ./scripts/validate-links.sh
```

### Module Counter (inline check)

```bash
#!/bin/bash
# Quick module count verification
ACTUAL=$(ls -d modules/KENL* | wc -l)
CLAIMED=$(grep -oP '(?<=\*\*)\d+(?= specialized)' README.md)
[[ "$ACTUAL" == "$CLAIMED" ]] || echo "❌ Count mismatch: $CLAIMED vs $ACTUAL"
```

---

## Common Pitfalls

### Pitfall 1: Assuming Links Work

**Wrong:**
- Edit README, commit immediately
- Trust that links work because "they look right"

**Right:**
- Edit README
- Run `./scripts/validate-links.sh`
- Fix any errors
- Commit

### Pitfall 2: Partial Fixes

**Wrong:**
- User: "KENL11 link broken"
- AI: Fixes only KENL11

**Right:**
- User: "KENL11 link broken"
- AI: Runs validator, finds KENL11 + 3 others, fixes all

### Pitfall 3: Documentation Drift

**Wrong:**
- Create new guide
- Don't update index/README
- User can't find it

**Right:**
- Create new guide
- Add to module README
- Add to root README "Documentation" section
- Add to relevant QUICK-REFERENCE

---

## Integration with Existing Tools

### Pre-commit Hooks

Add to `.pre-commit-config.yaml`:

```yaml
- repo: local
  hooks:
    - id: validate-links
      name: Validate Markdown Links
      entry: ./scripts/validate-links.sh
      language: system
      files: \.md$
      pass_filenames: false
```

### GitHub Actions

Already integrated via `ci.yml` (future):

```yaml
- name: Documentation Checks
  run: |
    ./scripts/validate-links.sh
    # Other checks...
```

---

## Success Metrics

**You're doing well when:**

1. ✅ `./scripts/validate-links.sh` passes consistently
2. ✅ User never says "this link is broken"
3. ✅ Module count stays accurate after additions
4. ✅ New guides are immediately discoverable
5. ✅ Footnotes always have matching definitions

**Red flags:**

1. ❌ User reports broken links multiple times
2. ❌ Module table out of sync with filesystem
3. ❌ Creating docs without linking from README
4. ❌ Committing without running validator

---

## Quick Reference

### File Validation Commands

```bash
# Link validation
./scripts/validate-links.sh

# Module count check
ls -d modules/KENL* | wc -l

# Footnote check
grep -P '\[\^[0-9]+\]' README.md | sort -u > /tmp/refs
grep -P '^\[\^[0-9]+\]:' README.md | sort -u > /tmp/defs
diff /tmp/refs /tmp/defs

# Old path pattern check
grep -r '](./KENL[0-9]' --include="*.md" .

# Pre-commit all checks
pre-commit run --all-files
```

### Fix Templates

**Broken link:**
```bash
# Before: [text](./path/that/doesnt/exist)
# After:  [text](./actual/correct/path)
```

**Missing module link:**
```markdown
# Before: | **KENL11** Media | Streaming, Docker |
# After:  | [**KENL11** Media](./modules/KENL11-media/) | Streaming, Docker |
```

**Missing footnote:**
```markdown
# Before: ...claim[^5]
# After:  ...claim[^5]
#
# [^5]: [Source](url) - Description
```

---

## Appendix: Historical Learnings

### Session 2025-11-14: Comprehensive Review

**Issues found:**
1. Play Card link pointed to non-existent file
2. Footnote [^2] linked to non-existent validation doc
3. Module links missing (only text, not clickable)
4. KENL11 specifically reported broken

**Root causes:**
- File renamed but links not updated
- Validation study not yet written (premature documentation)
- Modules table created without links (oversight)
- No automated link checking

**Preventive measures added:**
- ✅ `scripts/validate-links.sh` created
- ✅ This maintenance guide created
- ✅ All 14 modules now linked in README
- ✅ Footnote [^2] updated to reflect reality

**Lessons:**
- **Don't document future work as if complete**
- **Link validation must be automated**
- **Module additions need README updates in 3+ places**
- **User feedback = check everything, not just reported issue**

---

**ATOM Tag:** ATOM-DOC-20251114-014

**Last Updated:** 2025-11-14

**Maintained By:** KENL Project / AI Assistants
