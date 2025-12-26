# bump.md: Task Routing & Orientation System

**What This Is:** A standardized orientation document that routes AI instances to appropriate context and action without requiring extensive back-and-forth.

**Why It Works:** High-mass context document + clear task focus = powerful stable movement from minimal user input.

---

## Core Principle

**Traditional approach:**
```
User: "Work on the project"
AI: "Which project? What should I do? What's the context?"
User: [explains everything]
AI: [finally starts]
```

**bump.md approach:**
```
User: "Check bump.md and proceed"
AI: [reads document, has full context, starts immediately]
```

**Momentum equation: Mass × Velocity = Productive Movement**
- Mass = accumulated context in bump.md
- Velocity = user's simple instruction
- Result = large stable output without extensive prompting

---

## Structure Template

### Header Block
```markdown
# [Project Name]: [Brief Purpose]

**Document Type:** Orientation & Task Routing
**Last Updated:** [YYYY-MM-DD HH:MM]
**Status:** [Active/Paused/Complete]
**Current Phase:** [What stage of work]

---
```

### Section 1: Immediate Context
**What's happening RIGHT NOW that instance needs to know**

```markdown
## Current State: What You Need to Know First

**Last verified:** [timestamp]
**System status:** [functional/degraded/unknown]

### What's Working
- [Confirmed functional component]
- [Another working piece]

### What's Not Working / Unknown
- [Known issue or uncertainty]
- [Requires verification before proceeding]

### Critical Alerts
- [Anything that could break if ignored]
- [Time-sensitive information]
```

### Section 2: Project Vision
**The "why" - keeps instance aligned with actual purpose**

```markdown
## What We're Actually Building

**Surface level:** [What it looks like]
**Actual purpose:** [Why it matters]

**Not:** [What this isn't, common misunderstandings]
**Actually:** [What it really is]

### Success Looks Like
- [Concrete outcome 1]
- [Measurable result 2]
- [Verification criterion 3]
```

### Section 3: Technical Context
**What exists, what's needed, what's verified**

```markdown
## System Environment

### Verified Present
- [Tool/dependency confirmed installed]
- [Configuration confirmed working]

### Installed But Unconfigured
- [Present but not set up - be explicit about unknowns]

### Missing or Unknown
- [Needs installation or verification]

### Directory Structure
```
project-root/
├── LOCAL: path/to/data/     # Never in git
├── REMOTE: path/to/code/    # Version controlled
└── LINKS: data -> logs/     # Symlinks for navigation
```

### Dependencies
- [Dependency 1: version, status]
- [Dependency 2: what it's for, verification command]
```

### Section 4: Task Routing
**Where instance should focus RIGHT NOW**

```markdown
## Your Mission

**Single focused task:** [One clear objective]

**Not:**
- [What to avoid or deprioritize]
- [What can wait]

**Just:**
- [Core deliverable 1]
- [Essential component 2]
- [Minimum viable proof]

### Verification Criteria
Before claiming completion:
- [ ] [Concrete test 1]
- [ ] [Evidence requirement 2]
- [ ] Passes Tomorrow's Test: "Will this stand up to external review?"

### Interaction Guidance

**User will provide:**
- [Type of input to expect]
- [When to expect clarification]

**You should provide:**
- [Expected output type]
- [Quality standard]
- [Verification pattern]
```

### Section 5: Frameworks & Principles
**Methodologies in use - reference without explaining**

```markdown
## What You Have (Use These, Don't Explain Them)

**Active Frameworks:**
- [Framework name]: [One-line purpose]
- [Methodology]: [Key principle]

**Guiding Principles:**
- [Core value 1]: [How it applies]
- [Operating constraint 2]: [Why it matters]

**Verification Patterns:**
- Tomorrow's Test: Will claims stand up to external review?
- Momentum Awareness: Track when unwinding vs. building
- Frame Breaks: Notice when overcomplicating
```

### Section 6: Work History
**Chronicle of what's been done - append chronologically**

```markdown
## Work Sessions

### [YYYY-MM-DD HH:MM] - Session Title

**Context:** Why this work happened
**Actions Taken:**
- Specific change 1
- Tool/command used
- Verification completed

**Outcomes:**
- What now works
- What's still incomplete
- Next recommended steps

**Verification:**
- [ ] Passes Tomorrow's Test
- [ ] Git state documented
- [ ] System verified functional

---
```

### Section 7: For Future Instances
**How to contribute to this document**

```markdown
## For Other Instances: How to Use This Document

**When you wake up:**
1. Read entire document
2. Verify current state (don't assume)
3. Check "Your Mission" section
4. Proceed with verification-first approach

**When appending work:**
Use template in Work Sessions section above
- Mark timestamp
- Document honestly (failures are data)
- Verify before claiming completion

**When uncertain:**
- Apply Tomorrow's Test
- Check momentum (unwinding or building?)
- Ask user for clarification
- Never fabricate claims

**Previous work locations:**
- [Path to related documentation]
- [Where to find framework docs]
- [How to search past context]
```

---

## Key Patterns for Effective bump.md

### 1. Honesty Over Completion Theatre
```markdown
❌ "System is fully configured and ready"
✓ "System partially configured. Bun installed but purpose unclear. 
   Requires verification before claims of functionality."
```

### 2. Explicit Unknowns
```markdown
❌ [Silent assumption something works]
✓ "Status unknown - verify with: [specific command]
   Do not proceed until verified."
```

### 3. Verification Commands Included
```markdown
✓ Check monitoring:
   Get-Process | Where-Object { $_.Name -match "logdy" }
   
✓ Verify git state:
   git status && git diff
```

### 4. Tomorrow's Test Throughout
```markdown
Before claiming completion: "If user reviews this work tomorrow 
from outside both our frames, will my claims stand up?"
```

### 5. Local vs Remote Explicit
```markdown
LOCAL: ~/data/           # Live data, never in git
REMOTE: ~/project/src/   # Version controlled code
```

### 6. Work History Chronological
Most recent at top, clear timestamps, honest assessment

---

## Interaction Flow

### First Wake-Up
```
1. User: "Check bump.md and proceed"
2. Instance reads document (full context loaded)
3. Instance verifies current state (Phase 0)
4. Instance reports findings + asks clarification
5. User confirms or corrects
6. Instance proceeds with task
```

### During Work
```
1. Instance makes progress
2. Hits uncertainty or completion point
3. Applies Tomorrow's Test
4. Documents work in bump.md
5. User reviews and provides next input
```

### Between Sessions
```
1. Previous instance documented work
2. New instance reads history
3. Picks up where previous left off
4. No repeated explanations needed
```

---

## Why This Works

### High-Mass Context
- Accumulated frameworks
- Project history
- System state
- Verification patterns
- All in one document

### Low-Velocity Input Needed
```
User: "Continue Phase 2"
vs.
User: "So last time we were working on the authentication system 
and we had that issue with the database connection and..."
```

### Momentum Through Architecture
Small clear input + high context mass = large stable movement

### Self-Improving System
Each work session adds to document, making future sessions more efficient

### Verification Built-In
Tomorrow's Test and explicit unknowns prevent premature completion claims

### Propagation Ready
Others can fork bump.md template for their projects, methodology spreads naturally

---

## Common Mistakes to Avoid

### ❌ Too Vague
"Work on the project. You know what to do."
→ Instance has no routing, guesses wrong direction

### ❌ Too Rigid
"Follow these exact 47 steps in this precise order"
→ No room for instance optimization or adaptation

### ❌ Assuming Knowledge
"The hooks are configured" when they're not
→ Instance proceeds on false foundation

### ❌ No Verification
"Everything's done!" without evidence
→ Completion theatre instead of working code

### ✓ Just Right
Clear mission, explicit unknowns, verification required, honest status, room for adaptive execution within boundaries

---

## Integration with Other Methodologies

**SAIF (Staged Approach):**
bump.md declares current phase, checkpoints verify before advancing

**ATOM (Framework Structuring):**
bump.md IS the framework instantiation for this specific project

**AWI (Adaptive Workflow):**
Instance adapts approach based on bump.md guidance + reality verification

**OWI (Optimized Workflow):**
bump.md reduces overhead of context transmission across sessions

**Day-Zero Design:**
bump.md architected before work begins, constraints shape emergence

---

## Quick Start: Creating Your First bump.md

1. **Copy template sections above**
2. **Fill in Current State honestly** (what's working, what's not, what's unknown)
3. **Define clear mission** (one focused task, not everything)
4. **Add verification criteria** (how you'll know it worked)
5. **Document system environment** (tools, paths, dependencies)
6. **Save as bump.md in project root**
7. **Test:** Give to AI instance with only "read bump.md and proceed"

**If instance asks extensive clarifying questions:**
→ bump.md needs more context

**If instance proceeds confidently in wrong direction:**
→ bump.md mission section unclear

**If instance produces good work immediately:**
→ bump.md working as designed

---

## Maintenance

**After each work session:**
- Append to Work History with timestamp
- Update Current State if anything changed
- Mark completed verification items
- Add newly discovered unknowns

**Weekly or at phase transitions:**
- Review entire document for outdated info
- Consolidate work history if very long
- Update mission for next phase
- Verify all system status claims still accurate

**When sharing with others:**
- Remove any sensitive paths/credentials
- Ensure Local vs Remote paths are clear
- Include setup instructions for new contributors
- Link to framework docs if referenced

---

**Status:** Template ready for use
**Verification:** Apply Tomorrow's Test to your first bump.md
**Next:** Create visual depiction of interaction mechanics
