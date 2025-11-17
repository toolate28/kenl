---
title: Markdown Table Formatting - Agent Directive
atom: ATOM-DOC-20251116-004
classification: FORMATTING-STANDARD
purpose: Enforce consistent table formatting across all AI agents
---

# Markdown Table Formatting Standard

**For AI Agents:** This is a **DIRECTIVE**, not a suggestion. Follow these patterns exactly.

**The Problem:** Markdown tables are the hardest formatting element for AI agents to maintain consistently.

**The Rule:** **Longest string sets the column width. Period.**

---

## Pattern #1: Sort Longest First (Order-Agnostic Tables)

**When to use:** Tables where row order doesn't matter (features, modules, services)

**Strategy:**
1. Identify the longest entry in each column
2. Put the row with the longest total string **first**
3. All subsequent rows pad to match row 1
4. Never scan all rows - row 1 is your template

### Example: Module List

**❌ WRONG - Random order, inconsistent spacing:**

```markdown
| Module | Purpose |
|--------|---------|
| KENL0 | System |
| KENL1 | Framework |
| KENL2 | Gaming with Play Cards and Proton |
```

**Why wrong:** "Gaming with Play Cards and Proton" is longest but buried in row 3.

**✅ CORRECT - Longest first:**

```markdown
| Module | Purpose                                |
|--------|----------------------------------------|
| KENL2  | Gaming with Play Cards and Proton      |
| KENL1  | Framework                              |
| KENL0  | System                                 |
```

**Why correct:**
- Row 1 has longest entry → Sets width for column 2
- All subsequent rows pad to 40 chars (length of "Gaming with Play Cards and Proton")
- No scanning needed after row 1

---

## Pattern #2: Fixed-Width Columns (Sequential/Chronological Tables)

**When to use:** Tables where order matters (commits, ATOM trails, steps)

**Strategy:**
1. Pre-determine reasonable max widths per column
2. Stick to those widths for ALL rows
3. Use ellipsis (`...`) if content exceeds width

### Example: Recent Commits

**❌ WRONG - Varying widths:**

```markdown
| Hash | Author | Message |
|------|--------|---------|
| 2762303 | Copilot | fix: create missing RESEARCH-BUDGET.md |
| 3bcc73d | copilot-swe-agent[bot] | fix: resolve all ShellCheck errors in validate-links.sh |
| e596d09 | Claude | docs: add executive summary |
```

**Why wrong:** Column widths change row-to-row.

**✅ CORRECT - Fixed widths:**

```markdown
| Hash    | Author                 | Message                                             |
|---------|------------------------|-----------------------------------------------------|
| 2762303 | Copilot                | fix: create missing RESEARCH-BUDGET.md             |
| 3bcc73d | copilot-swe-agent[bot] | fix: resolve all ShellCheck errors in validate-... |
| e596d09 | Claude                 | docs: add executive summary                         |
```

**Why correct:**
- Hash: 7 chars (git short hash standard)
- Author: 22 chars (fits `copilot-swe-agent[bot]`)
- Message: 51 chars (reasonable terminal width)

---

## Pattern #3: Data Tables with Units

**When to use:** Tables with measurements, sizes, percentages

**Strategy:**
1. Align units separately from values
2. Right-align numbers, left-align text
3. Longest unit sets column width

### Example: Partition Layout

**❌ WRONG - Units misaligned:**

```markdown
| Label | Size | FS |
|-------|------|-----|
| Games-Universal | 900GB | NTFS |
| Claude-AI-Data | 500GB | ext4 |
| Transfer | 50GB | exFAT |
```

**Why wrong:** "Games-Universal" much longer than "Transfer" but no consistent padding.

**✅ CORRECT - Aligned with units:**

```markdown
| Label              | Size   | FS    |
|--------------------|--------|-------|
| Games-Universal    | 900GB  | NTFS  |
| Claude-AI-Data     | 500GB  | ext4  |
| Transfer           |  50GB  | exFAT |
```

**Why correct:**
- Label column: 18 chars (length of "Games-Universal")
- Size: Right-aligned numbers for visual comparison
- FS: 5 chars (length of "exFAT")

---

## The Golden Rules (AI Agent Checklist)

### Before Creating Any Table:

1. **Is row order flexible?**
   - YES → Use Pattern #1 (longest first)
   - NO → Use Pattern #2 (fixed widths)

2. **Count characters in longest entry per column**
   ```
   Column 1: "Games-Universal" = 15 chars
   Column 2: "Gaming with Play Cards and Proton" = 34 chars
   ```

3. **Set separator line to match longest entry**
   ```markdown
   |----------------|-------------------------------------|
   ```

4. **Pad ALL cells to match separator width**
   ```markdown
   | Games-Universal | Gaming with Play Cards and Proton   |
   | KENL0           | System                              |
   ```

5. **Use spaces ONLY (never tabs)**

6. **Align pipes vertically**
   ```markdown
   | Column 1 | Column 2 |
   |----------|----------|
   | Value    | Data     |
   ```

---

## Common Anti-Patterns (AVOID THESE)

### ❌ Anti-Pattern 1: No Padding

```markdown
| Hash | Author | Message |
|---|---|---|
| 2762303 | Copilot | fix |
```

**Fix:** Add padding to match longest entry in each column.

---

### ❌ Anti-Pattern 2: Inconsistent Spacing Around Pipes

```markdown
|Hash|Author |Message|
| 2762303| Copilot | fix |
```

**Fix:** Always use ` | ` (space-pipe-space) for separators.

---

### ❌ Anti-Pattern 3: Misaligned Separators

```markdown
| Column Header              | Another Column                    |
|---|-----------------------------------|
```

**Fix:** Separator dashes must match header width exactly.

---

### ❌ Anti-Pattern 4: Buried Longest Entry

```markdown
| Module | Purpose |
|--------|---------|
| KENL0  | System  |
| KENL2  | Gaming with Play Cards and Proton optimization for AMD/NVIDIA GPUs |
```

**Fix:** Move longest entry to row 1, then pad all rows to match.

---

## Validation Examples

### Self-Test: Is This Table Correct?

**Example 1:**

```markdown
| Platform | IP Address      | Status |
|----------|-----------------|--------|
| Linux    | 192.168.1.100   | UP     |
| Windows  | 10.0.0.5        | DOWN   |
```

**Answer:** ✅ CORRECT
- "IP Address" (10 chars) sets column 2 width
- "192.168.1.100" (13 chars) fits within padding
- Separators align with headers

---

**Example 2:**

```markdown
| Service | Status |
|---------|--------|
| Logdy | DOWN |
| Tailscale | UP |
| Ollama | UP |
```

**Answer:** ❌ WRONG
- "Tailscale" (9 chars) is longest service
- Should be row 1 to set width
- Current padding inconsistent

**Corrected:**

```markdown
| Service   | Status |
|-----------|--------|
| Tailscale | UP     |
| Logdy     | DOWN   |
| Ollama    | UP     |
```

---

## Agent Self-Check Commands

### Before Committing a Table:

```python
# Pseudo-code for AI agent validation
for each column:
    max_width = len(longest_entry_in_column)

    for each row:
        if len(cell) > max_width:
            ERROR: "Cell exceeds column width"

        if len(cell) != max_width:
            cell = cell.ljust(max_width)  # Pad with spaces

    separator = '-' * max_width
```

### Visual Check:

```markdown
| Column 1 | Column 2 |
|----------|----------|
| AAAA     | BBBB     |
| CC       | DDDD     |
     ↑          ↑
   These pipes should align vertically
```

---

## Real Examples from KENL Repo

### ✅ GOOD: Dashboard Value Proposition Table

```markdown
| Metric                | Value        | Rating              |
|-----------------------|--------------|---------------------|
| Clicks to Confidence  | 1.8 clicks   | EXCELLENT (<3)      |
| Information Scent     | 95/100       | STRONG (>80)        |
| Cognitive Load        | 25/100       | LOW (<30)           |
```

**Why good:**
- Consistent 21-char width for column 1
- Consistent 12-char width for column 2
- Consistent 19-char width for column 3

---

### ❌ BAD: Real Example from Repository

**Source:** `scripts/windows-partition-scripts/README.md` (verified present in codebase)

```markdown
| File | Purpose | Key Topics |
|------|---------|------------|
| **README.md** (this file) | Main usage guide | Prerequisites, execution steps, troubleshooting |
```

**Why bad:**
- No padding in column 1
- Separator inconsistent with content
- Column 3 much wider than separator

**Fixed:**

```markdown
| File                       | Purpose          | Key Topics                                       |
|----------------------------|------------------|--------------------------------------------------|
| **README.md** (this file)  | Main usage guide | Prerequisites, execution steps, troubleshooting  |
```

---

## Pre-Commit Validation (Future)

**Planned:** `scripts/validate-table-formatting.sh`

```bash
#!/bin/bash
# Validate markdown table formatting

# Check: All pipes align vertically
# Check: Separator width matches longest cell
# Check: Consistent spacing (space-pipe-space)
# Check: No tabs, only spaces

# Exit 1 if any table fails validation
```

---

## Quick Reference Card (Print This)

```
╔════════════════════════════════════════════════════════╗
║         MARKDOWN TABLE FORMATTING RULES                ║
╟────────────────────────────────────────────────────────╢
║  1. Longest string sets column width                   ║
║  2. If order-agnostic, put longest row FIRST           ║
║  3. Pad ALL cells to match column width                ║
║  4. Use spaces ONLY (no tabs)                          ║
║  5. Align pipes vertically                             ║
║  6. Separator dashes = column width                    ║
║  7. Format: ` | ` (space-pipe-space)                   ║
╚════════════════════════════════════════════════════════╝

Example Template:
| Longest Entry Here | Another Long Column Name |
|--------------------|--------------------------|
| Short              | Data                     |
| Tiny               | Val                      |
```

---

## When In Doubt

**Ask yourself:**

1. Is this the longest entry in its column? → If no, pad it.
2. Are my pipes vertically aligned? → If no, fix spacing.
3. Do my separators match column width? → If no, recalculate.

**Golden Rule:** If you can't see clean vertical lines when you squint, the table is wrong.

---

## ATOM Trail

```
ATOM-DOC-20251116-004: Created markdown table formatting directive for AI agents
Intent: Eliminate the #1 persistent formatting issue across Claude, Copilot, and Qwen
Problem: Tables break visual consistency despite documented standards
Solution: Agent-directed imperative guide with longest-first pattern
Validation: Pre-commit hook (planned), visual alignment check
Next: Implement validate-table-formatting.sh pre-commit hook
```

---

**Last Updated:** 2025-11-16
**Status:** Production
**Enforcement:** Manual (pre-commit validation planned)
**Applies To:** All AI agents (Claude, Copilot, Qwen), human contributors
