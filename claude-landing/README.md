# Claude Landing Zone

**Purpose:** Immediate orientation and system integration for AI agents working on the KENL project.

---

## 🤖 AI Agent Quick Start

**Read these files in order:**

| Order | File | Purpose |
|-------|------|---------|
| 1 | [AI-AGENT-SYSTEM.md](./AI-AGENT-SYSTEM.md) | **System framework** - Ingestion, monitoring, review, update |
| 2 | [CURRENT-STATE.md](./CURRENT-STATE.md) | Current environment snapshot |
| 3 | [RECENT-WORK.md](./RECENT-WORK.md) | Last session's work and context |
| 4 | [NEXT-STEPS.md](./NEXT-STEPS.md) | Immediate actionable tasks |
| 5 | [QUICK-REFERENCE.md](./QUICK-REFERENCE.md) | Commands, paths, key files |

---

## 🧭 Navigation Hub

**[📁 DOCUMENTATION-PATHWAYS.md](./DOCUMENTATION-PATHWAYS.md)** - Navigate to any KENL documentation

---

## 🚩 CTF Flag System

**Documents contain "flags" - documented expectations about current state.**

When resuming work:

| Flag Status | Meaning | Action |
|-------------|---------|--------|
| ✅ **Validates** | Documented = Reality | Proceed |
| 🚩 **Fails** | Mismatch detected | Investigate |
| ⚠️ **Partial** | Some match, some don't | Use judgment |

---

## 📁 Directory Contents

### Core Context Files

| File | Purpose | Update Frequency |
|------|---------|------------------|
| `AI-AGENT-SYSTEM.md` | Agent learning/context framework | Stable |
| `CURRENT-STATE.md` | Environment snapshot | Every session |
| `RECENT-WORK.md` | Last session summary | Every session |
| `NEXT-STEPS.md` | Immediate tasks | When tasks change |
| `QUICK-REFERENCE.md` | Commands/paths | When discovered |
| `DOCUMENTATION-PATHWAYS.md` | Navigation hub | Stable |

### Agent-Facing Standards

| File | Purpose |
|------|---------|
| `AGENT-FACING-CONTENT-DESIGN.md` | Writing patterns for AI |
| `CLI-FORMATTING-STANDARDS.md` | CLI output formatting |
| `MARKDOWN-TABLE-FORMATTING.md` | Table alignment rules |

### Reference Documents

| File | Purpose |
|------|---------|
| `HARDWARE.md` | Hardware specs |
| `MIGRATION-PLAN.md` | Windows → Bazzite roadmap |
| `TESTING-RESULTS.md` | Validation results |

---

## 🔄 Session Protocol

### Start of Session

```
1. Read AI-AGENT-SYSTEM.md (understand framework)
2. Read CURRENT-STATE.md (validate environment)
3. Read RECENT-WORK.md (understand context)
4. Check NEXT-STEPS.md (identify tasks)
5. Validate CTF (Capture The Flag) expectations match reality
```

### During Work

```
1. Log ATOM tags for all decisions (ATOM-{TYPE}-YYYYMMDD-NNN)
2. Drop SAIF checkpoint flags (SAIF-{ACTION}-YYYYMMDD-NNN)
3. Commit frequently via report_progress
```

### End of Session

```
1. Update CURRENT-STATE.md with final state
2. Update RECENT-WORK.md with session summary
3. Update NEXT-STEPS.md with remaining tasks
4. Note: SAIF-HANDOVER-YYYYMMDD-NNN in commit message if work continues
```

---

## 🏷️ ATOM Tracking

All documents use ATOM tags for traceability:
- **Format:** `ATOM-DOC-YYYYMMDD-NNN`
- **Registry:** [../ATOM-REGISTER.md](../ATOM-REGISTER.md)

---

*Last Updated: 2025-11-26*
*ATOM: ATOM-DOC-20251126-006*
