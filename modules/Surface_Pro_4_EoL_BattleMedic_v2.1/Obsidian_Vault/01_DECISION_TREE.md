---
title: Recovery Path Decision Tree
tags: [decision-tree, triage, emergency]
created: 2025-11-26
priority: P0
---

# 🚨 wof.sys Recovery - Which Path Is Right for You?

[[00_HOME|← Back to Home]]

---

## Quick Triage - Answer These Questions

Follow this decision tree to identify your recovery path. **Answer honestly** - choosing the wrong path wastes time.

---

### ❓ Question 1: Can you boot to Windows desktop?

**Test**: Turn on your Surface Pro 4. Does it:
- Show the Windows login screen?
- Let you log in?
- Reach the desktop (even if slow)?

**Choose ONE:**

#### ✅ YES - I can boot to desktop
→ **Go to**: [[PATH_A_NORMAL_BOOT|Path A: Normal Boot Recovery]]

**Your situation**: System boots but may have errors or instability
**Recovery time**: 20-30 minutes
**Difficulty**: Easy
**Success rate**: 90-95%

---

#### ❌ NO - Cannot boot to desktop

Continue to Question 2 ↓

---

### ❓ Question 2: Can you boot to Safe Mode?

**Test**:
1. Restart your Surface Pro 4
2. During startup, press `F8` repeatedly
3. Select "Safe Mode" from the menu

Does it boot to Safe Mode desktop?

**Choose ONE:**

#### ✅ YES - Safe Mode works
→ **Go to**: [[PATH_B_SAFE_MODE|Path B: Safe Mode Recovery]]

**Your situation**: Normal boot fails, Safe Mode works
**Recovery time**: 30-45 minutes
**Difficulty**: Medium
**Success rate**: 85-90%

---

#### ❌ NO - Safe Mode also fails

Continue to Question 3 ↓

---

### ❓ Question 3: Can you access Windows Recovery Environment (WinRE)?

**Test**:
1. **Force shutdown** 3 times during Windows logo (hold power button 10 seconds each time)
2. On 3rd restart, Windows should say "Preparing Automatic Repair"
3. You'll see a blue screen with "Automatic Repair" options

OR manually:
- Restart and press `F11` during boot

Do you see the blue "Automatic Repair" or "Choose an option" screen?

**Choose ONE:**

#### ✅ YES - WinRE accessible
→ **Go to**: [[PATH_C_WINRE_OFFLINE|Path C: WinRE Offline Recovery]]

**Your situation**: Cannot boot normally or Safe Mode, but WinRE works
**Recovery time**: 45-60 minutes
**Difficulty**: Hard
**Success rate**: 75-85%

---

#### ❌ NO - WinRE doesn't appear

→ **Go to**: [[PATH_D_RECOVERY_MEDIA|Path D: Recovery Media Required]]

**Your situation**: Complete boot failure - needs external recovery
**Recovery time**: 2-3 hours
**Difficulty**: Very Hard
**Success rate**: 60-70%
**Requirements**: USB drive, another computer

---

## 🤔 Not Sure? Use This Guide

### If you're seeing...

| Symptom | Path |
|---------|------|
| Green screen during boot | Try Question 1 first |
| Blue screen with STOP code 0xD3 | Try Question 1 first |
| Automatic Repair loop | Go to Question 3 |
| Black screen, nothing happens | Try forcing WinRE (Question 3) |
| "No bootable device" message | Go directly to Path D |

### Still Unsure?

**Start with the most severe option** (higher letter = more severe):
- If in doubt between two paths, try the **less severe** one first
- You can always escalate to a more severe path if the easier one fails

**Safe progression**: Path A → Path B → Path C → Path D

---

## 📊 Path Comparison

| Path | Boot Status | Time | Difficulty | Success | Requirements |
|------|-------------|------|------------|---------|--------------|
| **A** | Desktop loads | 20-30m | Easy | 90-95% | Admin access |
| **B** | Safe Mode only | 30-45m | Medium | 85-90% | Safe Mode |
| **C** | WinRE only | 45-60m | Hard | 75-85% | WinRE access |
| **D** | Nothing works | 2-3h | Very Hard | 60-70% | USB, PC |

---

## 🔗 Direct Path Links

**Once you've decided, click your path:**

- [[PATH_A_NORMAL_BOOT|🟢 Path A: Normal Boot Recovery]]
- [[PATH_B_SAFE_MODE|🟡 Path B: Safe Mode Recovery]]
- [[PATH_C_WINRE_OFFLINE|🟠 Path C: WinRE Offline Recovery]]
- [[PATH_D_RECOVERY_MEDIA|🔴 Path D: Recovery Media Required]]

---

[[00_HOME|← Back to Home]]
