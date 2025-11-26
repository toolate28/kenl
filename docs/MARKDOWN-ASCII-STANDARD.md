# Markdown ASCII Standard for KENL

**ATOM Tag:** ATOM-DOC-20251118-008
**Authority:** documentation-standards
**Status:** Active

---

## Purpose

This document defines ASCII-only standards for markdown formatting to ensure stable rendering across terminals, fonts, and platforms.

## Problem

Unicode emojis and special characters can cause:
- Variable character widths breaking table alignment
- Different rendering across terminals (Windows CMD, PowerShell, bash, zsh)
- Font dependency issues (missing glyphs, fallback fonts)
- Copy-paste problems in plain-text environments
- Search/grep complexity with multi-byte characters

## ASCII Replacements

### Ratings and Stars

**DON'T:**
```markdown
⭐⭐⭐⭐⭐  (5 stars)
⭐⭐⭐⭐    (4 stars)
⭐⭐⭐      (3 stars)
```

**DO:**
```markdown
*****  (5 stars)
****   (4 stars)
***    (3 stars)
```

**Rationale:** Asterisks are monospace-safe, searchable with simple regex, and universally supported.

### Boolean/Status Indicators

**DON'T:**
```markdown
✅ Complete
❌ Failed
⚠️ Warning
```

**DO:**
```markdown
[Y] Complete / [PASS] / [OK]
[N] Failed / [FAIL] / [ERR]
[!] Warning / [WARN]
```

**Exception:** Checkboxes outside tables can use ✅/❌ for visual clarity in non-alignment-critical contexts.

### Priority/Emphasis

**DON'T:**
```markdown
🔥 Hot
⚡ Fast
💰 Expensive
```

**DO:**
```markdown
[!!!] Hot / [HIGH]
[>>] Fast / [FAST]
[$$$] Expensive / [COST-HIGH]
```

### Special Cases

#### In Tables
**ALWAYS use ASCII in tables** to maintain alignment:

```markdown
| Component    | Status | Priority |
|--------------|--------|----------|
| ATOM Server  | [Y]    | *****    |
| GitHub CI    | [Y]    | ****     |
```

#### In Headers/Narrative Text
**MAY use emojis** for visual wayfinding (not alignment-critical):

```markdown
## 🎯 Current Focus
## 🔍 Quick Searches
```

#### In Lists (Non-Table)
**PREFER ASCII but emojis acceptable** if not affecting layout:

```markdown
- [Y] **Operation Phoenix** - 7-min recovery
- [Y] **The Baton Pass** - 5.3x efficiency
```

OR

```markdown
- ✅ **Operation Phoenix** - 7-min recovery
- ✅ **The Baton Pass** - 5.3x efficiency
```

## Migration Guide

### Finding Violations

```bash
# Find emoji stars
grep -r "⭐" --include="*.md" .

# Find checkmarks in tables
grep -E "\|.*✅.*\|" --include="*.md" .

# Find warnings/errors
grep -r "[⚠️❌]" --include="*.md" .
```

### Replacement Patterns

```bash
# Stars (manual review recommended for context)
⭐⭐⭐⭐⭐ → *****
⭐⭐⭐⭐   → ****
⭐⭐⭐     → ***

# Status in tables only
✅ → [Y]
❌ → [N]
⚠️ → [!]
```

## Pre-commit Validation

Future enhancement: Add pre-commit hook to detect emojis in table cells.

```yaml
# .pre-commit-config.yaml (future)
- repo: local
  hooks:
    - id: check-table-emojis
      name: Check for emojis in markdown tables
      entry: scripts/check-table-emojis.sh
      language: script
      files: \.md$
```

## Exceptions

1. **Visual Elements Standard** (`docs/VISUAL-ELEMENTS-STANDARD.md`): Documents emoji usage for non-table contexts
2. **README badges**: GitHub renders these correctly, alignment not critical
3. **Case studies**: Narrative text may use emojis for readability if not in tables

## Implementation Status

- [Y] Core table files migrated (ATOM-DOC-20251118-008)
- [ ] Comprehensive audit of all markdown files
- [ ] Pre-commit hook implementation
- [ ] Update VISUAL-ELEMENTS-STANDARD.md with this guidance

---

**Last Updated:** 2025-11-18
**Maintained By:** Human+AI collaboration
**Related:** `claude-landing/MARKDOWN-TABLE-FORMATTING.md`, `docs/VISUAL-ELEMENTS-STANDARD.md`
