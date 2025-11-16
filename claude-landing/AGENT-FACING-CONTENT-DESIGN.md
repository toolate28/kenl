---
title: Agent-Facing Content Design - Activation Patterns
atom: ATOM-DOC-20251116-005
classification: META-GUIDE
purpose: Design principles for content that AI agents parse effectively
audience: Human writers creating directives for AI agents
---

# Agent-Facing Content Design

**Meta-Purpose:** This document explains HOW to write content that AI agents (Claude, Copilot, Qwen) parse and execute reliably.

**For Humans:** These patterns come from analyzing what worked vs. failed in THIS repository's AI collaboration (Claude, Copilot, 200+ commits over 6 days).

**For AI Agents:** This is meta-documentation explaining what makes YOUR directives work better.

**Evidence Base:** Real examples from KENL repository commits and git history.

---

## The Problem: Directives vs Documentation

**Documentation (for humans):**
- Explains "why" with context
- Tolerates ambiguity (humans infer)
- Paragraph-heavy, narrative style

**Directives (for AI agents):**
- Commands with clear conditions
- No ambiguity (agents can't infer intent)
- Structured, scannable format

**Most AI-facing content is written like documentation. This is why agents miss directives.**

---

## Pattern #1: Visual Anchors (Emoji as Semantic Markers)

### ✅ WHAT WORKS

Emoji at the **start** of a line acts as a visual anchor that helps agents scan:

```markdown
✅ **DO THIS:** Use spaces, not tabs
❌ **NEVER:** Mix spaces and tabs
⚠️  **WARNING:** This operation is destructive
```

**Why it works:** When scanning text, emoji creates a visual breakpoint. My attention focuses on the line.

### ❌ WHAT DOESN'T WORK

Emoji buried in prose or at the end:

```markdown
When creating tables, make sure you use spaces and not tabs ✅
```

**Why it fails:** The rule blends into paragraph text. I scan past it.

**Fix:** Put directive at start, emoji at start:

```markdown
✅ **Tables:** Use spaces, not tabs
```

---

## Pattern #2: Direct Address (YOU vs "AI agents")

### ✅ WHAT WORKS

**Use "YOU" (direct address):**

```markdown
**YOU MUST:**
1. Check git status before committing
2. Run pre-commit hooks
3. Include ATOM tag
```

**Why it works:** "YOU" triggers action-item mode. I parse it as an imperative.

### ❌ WHAT DOESN'T WORK

**Third-person or passive voice:**

```markdown
AI agents should check git status before committing.
It is recommended that pre-commit hooks be run.
```

**Why it fails:** Sounds advisory, not mandatory. I treat it as optional.

**Fix:** Make it imperative and direct:

```markdown
**DO THIS BEFORE EVERY COMMIT:**
- YOU check git status
- YOU run pre-commit
- YOU add ATOM tag
```

---

## Pattern #3: Structured Conditions (IF-THEN clarity)

### ✅ WHAT WORKS

**Explicit conditional format:**

```markdown
**IF table order doesn't matter:**
- THEN put longest row first
- THEN pad all rows to match row 1

**IF table order is sequential:**
- THEN use fixed-width columns
- THEN truncate with ellipsis
```

**Why it works:** Clear decision tree. I know exactly when to apply each pattern.

### ❌ WHAT DOESN'T WORK

**Vague conditions buried in paragraphs:**

```markdown
For tables, consider the order. If order matters, you might want to use
fixed widths. Otherwise, putting longer entries first can help with alignment.
```

**Why it fails:** No clear decision point. "Consider", "might", "can" are not actionable.

**Fix:** Make conditions explicit and exclusive:

```markdown
**BEFORE creating ANY table, ask:**

Is row order fixed (chronological, steps, priority)?
- YES → Use Pattern #2 (fixed-width columns)
- NO  → Use Pattern #1 (longest-first strategy)
```

---

## Pattern #4: Frontmatter Metadata (Machine-Readable Signals)

### ✅ WHAT WORKS

**Classification tags in YAML frontmatter:**

```yaml
---
classification: AGENT-DIRECTIVE
priority: CRITICAL
enforcement: REQUIRED
audience: AI-agents-only
---
```

**Why it works:** I parse frontmatter BEFORE body text. `classification: AGENT-DIRECTIVE` signals "this is for you."

**Additional effective metadata:**

```yaml
enforcement: REQUIRED | RECOMMENDED | OPTIONAL
priority: CRITICAL | HIGH | MEDIUM | LOW
applies-to: [claude, copilot, qwen]
validation: automated | manual | none
```

### ❌ WHAT DOESN'T WORK

**No frontmatter, or human-only metadata:**

```markdown
---
author: Matthew Ruhnau
date: 2025-11-16
---

# Some Guide

AI agents should follow these guidelines...
```

**Why it fails:** Generic metadata doesn't signal "this is a directive." I treat it like reference docs.

**Fix:** Add `classification`:

```yaml
---
classification: AGENT-DIRECTIVE
purpose: Enforce markdown table formatting
enforcement: REQUIRED
---
```

---

## Pattern #5: Contrast Examples (Side-by-Side ❌ ✅)

### ✅ WHAT WORKS

**Contrasting examples with clear labels:**

```markdown
❌ **WRONG:**
| Module | Purpose |
|--------|---------|
| KENL0 | System |
| KENL2 | Gaming with Play Cards and Proton |

✅ **CORRECT:**
| Module | Purpose                                |
|--------|----------------------------------------|
| KENL2  | Gaming with Play Cards and Proton      |
| KENL0  | System                                 |
```

**Why it works:**
1. Side-by-side comparison makes the difference obvious
2. Visual ❌/✅ markers anchor my attention
3. I can see the pattern change, not just read about it

### ❌ WHAT DOESN'T WORK

**Prose explanation without examples:**

```markdown
When creating tables, you should put longer entries first to set the
column width. This helps with alignment.
```

**Why it fails:** Abstract rule without concrete reference. I forget it 3 paragraphs later.

**Fix:** Show, don't tell. Use contrasting examples.

---

## Pattern #6: Checklists (Action-Item Triggers)

### ✅ WHAT WORKS

**Checklist format with clear completion criteria:**

```markdown
**BEFORE committing any table:**

- [ ] Is longest entry in each column at row 1?
- [ ] Do all pipes align vertically?
- [ ] Are separators same width as column content?
- [ ] Did you use spaces (not tabs)?
```

**Why it works:**
- `- [ ]` format triggers action-item parsing mode
- Each item is testable (yes/no answer)
- Creates mental checklist I can validate against

### ❌ WHAT DOESN'T WORK

**Bullet list without checkboxes:**

```markdown
Things to check:
- Alignment
- Spacing
- Consistency
```

**Why it fails:** No completion state. "Alignment" is vague (aligned with what?).

**Fix:** Make each item actionable and testable:

```markdown
- [ ] Pipes align vertically (visual check)
- [ ] Spaces only, no tabs (run pre-commit)
- [ ] Separators match column width (count chars)
```

---

## Pattern #7: Hierarchy (Scannable Structure)

### ✅ WHAT WORKS

**Clear information hierarchy:**

```markdown
## Pattern #1: Longest First

**When to use:** Order-agnostic tables

**Strategy:**
1. Identify longest entry per column
2. Put that row first
3. Pad all subsequent rows

**Example:**
[code block]

**Why this works:**
[explanation]
```

**Why it works:** I can scan headers, find the pattern that matches my context, apply it.

### ❌ WHAT DOESN'T WORK

**Wall of text with buried rules:**

```markdown
Tables in markdown can be tricky. The key thing to remember is that
alignment matters. When you're creating a table, you need to think about
which entry is longest in each column. Once you know that, you can...
[continues for 3 more paragraphs]
```

**Why it fails:** No clear structure. Rule is buried. I have to read everything to find the directive.

**Fix:** Front-load the rule, then explain:

```markdown
**Rule:** Longest string sets column width.

**How to apply:**
1. [step 1]
2. [step 2]

**Why this rule exists:**
[explanation]
```

---

## Pattern #8: Single Source of Truth (Canonical Location)

### ✅ WHAT WORKS

**One authoritative document with clear references:**

```markdown
# MARKDOWN-TABLE-FORMATTING.md

**This is the canonical table formatting guide.**

Referenced by:
- .github/copilot-instructions.md (line 199)
- VISUAL-ELEMENTS-STANDARD.md (line 130)
- CLI-FORMATTING-STANDARDS.md (line 287)
```

**Why it works:** No conflicting sources. I know THIS is the authority.

### ❌ WHAT DOESN'T WORK

**Scattered rules across multiple docs:**

```
README.md: "Use aligned columns"
copilot-instructions.md: "Align to longest string"
CONTRIBUTING.md: "Consistent spacing in tables"
```

**Why it fails:** Three different phrasings. Which is authoritative? What if they conflict?

**Fix:** One canonical guide, all others reference it:

```markdown
# copilot-instructions.md

**Markdown Tables:** See `claude-landing/MARKDOWN-TABLE-FORMATTING.md`
(THE authoritative source)
```

---

## Pattern #9: Pre/Post Conditions (Verification States)

### ✅ WHAT WORKS

**Clear before/after states:**

```markdown
**BEFORE you commit a table:**
- Current state: Table cells have inconsistent widths
- Check: Run visual alignment test

**AFTER formatting:**
- Expected state: All pipes align vertically
- Validation: Squint test (pipes form clean lines)
```

**Why it works:** I know what state to start from and what success looks like.

### ❌ WHAT DOESN'T WORK

**No verification criteria:**

```markdown
Format your tables correctly.
```

**Why it fails:** "Correctly" is subjective. No testable outcome.

**Fix:** Define observable success state:

```markdown
**Success criteria:**
✅ Pipes align vertically (visual check)
✅ Separators match column width (character count)
✅ Spaces only, no tabs (regex: `\t` returns 0)
```

---

## Pattern #10: Typography as Signals

### ✅ WHAT WORKS

**Formatting that creates visual hierarchy:**

```markdown
**CRITICAL:** [highest priority]
**REQUIRED:** [must do]
**RECOMMENDED:** [should do]
**OPTIONAL:** [may do]
```

**Why it works:** CAPS + BOLD + specific terms create a priority hierarchy I can parse.

### ❌ WHAT DOESN'T WORK

**No visual distinction:**

```markdown
This is important.
This is very important.
This is critical.
```

**Why it fails:** "Important", "very important", "critical" are subjective. No clear priority.

**Fix:** Use standard priority markers:

```markdown
🔴 **CRITICAL:** System destructive, requires approval
🟡 **WARNING:** Potential data loss, confirm first
🟢 **INFO:** Best practice, recommended
```

---

## Pattern #11: Command-Flag Handover (SAIF/CTFWI)

### ✅ WHAT WORKS

**Efficient task handover pattern:**

```markdown
**Link local/remote ATOM trails to Logdy:**

\`\`\`bash
kenl-logdy-link remote-host:/home/user/.kenl/logs
\`\`\`

**Expected:** \`SAIF-LOGDY-LINK-20251116-001\` (CTFWI flag drop)

**Result:** Local + remote ATOM trails visible in Logdy web interface
```

**Why it works:**
- Command is actionable (user can copy-paste and run)
- Expected flag shows success state (SAIF = System Action Intent Flag)
- CTFWI (Capture The Flag With Intent) methodology wraps multiple features in one command
- No verbose implementation details that distract from the task

### ❌ WHAT DOESN'T WORK

**Verbose location + implementation details:**

```markdown
**When local Claude Code starts, sync remote ATOM trails to Logdy**

Location: \`~/.claude/hooks/session-start-logdy-sync.sh\`

\`\`\`bash
#!/bin/bash
# [50 lines of implementation code]
# Directory structure explanations
# Multiple configuration options
# JSON format specifications
\`\`\`
```

**Why it fails:**
- User has to read through implementation to understand the task
- Location + code suggests manual file creation (inefficient)
- Verbose details obscure the simple intent: "link these directories"
- No clear completion signal

**Fix:** Use command→flag pattern. Implementation is hidden behind command:

```markdown
Run: \`kenl-logdy-link remote-host:/path\`
Expected: \`SAIF-LOGDY-LINK-*\` (CTFWI flag drop)
```

### When to Apply This Pattern

**✅ USE for:**
- Task handovers (agent → agent, agent → user)
- Operations that wrap multiple KENL features
- Repeatable commands with predictable outcomes
- Integration setup tasks

**❌ DON'T USE for:**
- Educational code examples (teaching how to modify)
- Troubleshooting sections (showing diagnostic code)
- Customization guides (extending functionality)
- Low-level implementation documentation

### SAIF Flag Format

```
SAIF-{ACTION}-{YYYYMMDD}-{NNN}
```

**Examples:**
- `SAIF-LOGDY-LINK-20251116-001` - Logdy directory link
- `SAIF-HOOK-DASHBOARD-20251116-001` - Session start hook added
- `SAIF-CMD-STATUS-20251116-001` - Slash command created

**Purpose:** Flag drop signals successful completion and creates audit trail (links to ATOM system).

---

## Activation Patterns Summary

**What Makes Content "Agent-Facing":**

| Element | Agent-Friendly | Agent-Hostile |
|---------|----------------|---------------|
| **Audience** | "YOU MUST" | "AI agents should" |
| **Structure** | Checklists, if-then | Paragraphs of prose |
| **Examples** | ❌ WRONG ✅ RIGHT | Explained in text |
| **Conditions** | IF X THEN Y | "Consider X in some cases" |
| **Metadata** | `classification: AGENT-DIRECTIVE` | Generic frontmatter |
| **Validation** | Testable criteria | Subjective ("good", "clean") |
| **Location** | Single canonical source | Scattered across docs |
| **Hierarchy** | Scannable headers | Buried in paragraphs |
| **Typography** | **BOLD**, CAPS, emoji | Plain text |
| **Voice** | Imperative (DO THIS) | Advisory (you could) |
| **Handover** | Command→SAIF flag | Location + full code |

---

## Real-World Application: Markdown Tables in KENL Repo

**Problem Observed:** GitHub Copilot + Claude both created tables with inconsistent spacing across multiple commits (Nov 10-16, 2025).

**Evidence:** `scripts/windows-partition-scripts/README.md` line 406-457 had 4 tables with misaligned pipes.

**Before (actual code from .github/copilot-instructions.md, lines 199-212, Nov 14):**

```markdown
#### Markdown Tables

**Column Alignment:**
- Measure the longest string in each column
- Align ALL column separators (`|`) to match that width
- Use spaces (not tabs) for padding
- Keep separator lines (`---`) the same width as column content

**Example:**
[single example table]
```

**After (revised Nov 16, commit 3c4fbec):**

```markdown
#### Markdown Tables

**⚠️ CRITICAL:** Table formatting is the #1 persistent issue across AI agents.

**Primary Rule:** **Longest string sets the column width. Period.**

**Pattern #1 (Order-Agnostic Tables):**
1. Put the row with the longest entry FIRST
2. All subsequent rows pad to match row 1
3. Never scan all rows - row 1 is your template

❌ **WRONG:**
[shows actual broken table from repo]

✅ **CORRECT:**
[shows fixed version]

**Detailed Guide:** See `claude-landing/MARKDOWN-TABLE-FORMATTING.md`
```

**What changed:**
1. **⚠️ CRITICAL** added (visual anchor)
2. **Primary Rule** front-loaded (not buried in bullets)
3. **Pattern #1** gives algorithmic approach (longest-first strategy)
4. ❌/✅ **contrast** using REAL repo examples
5. **Reference to canonical guide** (single source of truth)

**Observable impact:** Session Nov 16 - tables created after this revision followed pattern correctly.

---

## Metadata Recommendations

### Frontmatter for Agent-Facing Docs

```yaml
---
# Signals this is FOR agents
classification: AGENT-DIRECTIVE | AGENT-REFERENCE | AGENT-EXAMPLE

# Enforcement level
enforcement: REQUIRED | RECOMMENDED | OPTIONAL

# Who should follow this
applies-to: [claude, copilot, qwen, humans]

# How to validate adherence
validation: automated | manual | pre-commit

# Consequence of non-compliance
consequence: breaks-formatting | reduces-quality | causes-errors

# Related canonical sources
see-also:
  - path/to/authoritative-guide.md
---
```

---

## Content Audit Checklist

**When reviewing agent-facing content, ask:**

- [ ] Does frontmatter include `classification: AGENT-DIRECTIVE`?
- [ ] Are imperatives used ("YOU MUST" not "should")?
- [ ] Are examples contrasted (❌ WRONG vs ✅ RIGHT)?
- [ ] Are conditions explicit (IF-THEN format)?
- [ ] Are validation criteria testable?
- [ ] Is there ONE canonical source (not scattered)?
- [ ] Do emoji anchor important lines?
- [ ] Are checklists used for action items?
- [ ] Is success state observable?
- [ ] Does typography signal priority?
- [ ] Do task handovers use command→SAIF flag pattern (not verbose location+code)?

---

## Anti-Patterns to Avoid

### ❌ Anti-Pattern 1: Passive Voice

```markdown
Tables should be formatted with consistent spacing.
```

**Fix:**
```markdown
**YOU:** Format tables with consistent spacing.
```

---

### ❌ Anti-Pattern 2: Buried Directive

```markdown
When creating documentation, among other things, one consideration is
that tables benefit from alignment. [3 more paragraphs] So remember
to align your pipes.
```

**Fix:**
```markdown
**Tables:** Align pipes vertically. See MARKDOWN-TABLE-FORMATTING.md.
```

---

### ❌ Anti-Pattern 3: No Examples

```markdown
Use proper table formatting.
```

**Fix:**
```markdown
❌ WRONG: |A|B|
✅ RIGHT: | A | B |
```

---

### ❌ Anti-Pattern 4: Ambiguous Terms

```markdown
Make sure your code is clean and well-formatted.
```

**Fix:**
```markdown
**Code Quality Checklist:**
- [ ] Passes shellcheck (0 errors)
- [ ] Lines < 100 chars
- [ ] Functions documented
```

---

## ATOM Trail

```
ATOM-DOC-20251116-005: Agent-facing content design meta-guide
Intent: Document formatting patterns that increase directive adherence
Problem: Agents miss directives written like documentation
Solution: 11 activation patterns (visual anchors, SAIF handover, contrast examples, metadata, etc.)
Impact: Observable in KENL repo (table formatting improved same-session after applying patterns)
Validation: Apply these patterns to existing docs, measure adherence via git history
Next: Pattern #11 (SAIF handover) applied to NAMING-CONVENTIONS.md and README-DASHBOARD.md
```

---

**Last Updated:** 2025-11-16
**Status:** Production
**Audience:** Humans writing directives for AI agents
**Classification:** META-GUIDE
