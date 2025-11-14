---
title: SAIF Framework for Automotive R&D Prototyping
audience: Head R&D Prototyper / Lead Machinist
business: High-End Automotive Modification Garage, Wetherill Park NSW
specialization: Engine/Turbocharging Bespoke Modifications
framework: SAIF (System-Aware Intent Framework)
version: 2025-11-14
---

# SAIF for Fabrication Workflow
**System-Aware Intent Framework for Bespoke Automotive Modifications**

## What is SAIF for Your Workshop?

**SAIF = Traceable, reproducible, evidence-based custom fabrication**

Instead of "dotfiles," think **"build sheets"** — complete documentation that captures:
- **WHAT** you machined (dimensions, material, tolerances)
- **WHY** you made that choice (customer intent, performance goal)
- **HOW WELL** it worked (dyno results, before/after data)

---

## The Four Pillars (Workshop Translation)

### 1. **Transparency** — Document Everything
Every custom part clearly labeled:
- ✅ **CNC-machined in-house** (Wetherill Park, NSW)
- ✅ **Off-shelf modified** (Garrett turbo + custom manifold)
- ✅ **Customer-supplied base** (modified customer core)

**Why:** Customer knows exactly what they're paying for. No "black box" mods.

### 2. **Traceability** — ATOM Build Logs

**ATOM = Job log with intent**

Traditional job card:
```
Job #1247: Machine custom turbo flange
Material: 304 stainless, 10mm plate
Operations: Mill, drill, tap threads
```

**SAIF job card (ATOM trail):**
```
ATOM-FAB-20251114-001: Machine custom turbo flange
Material: 304 stainless, 10mm plate (intent: heat resistance)
Operations: CNC mill, drill, tap M8 threads
Intent: Customer upgrading GT3076R on RB26, OEM flange cracks under boost
Test plan: Pressure test to 35 PSI, thermal cycle 5x
Result: ✅ Held 40 PSI, no cracking after 200km test drive
```

**Benefit:** When customer comes back 6 months later: "Can you make another flange for my mate's RB26?" — you have complete context.

### 3. **Intentionality** — Capture WHY

Don't just write "bored manifold runners to 52mm" — write:

```
ATOM-FAB-20251114-002: Bored intake manifold runners 48mm → 52mm
Intent: Customer chasing 400kW at wheels (currently 350kW)
Theory: CFD analysis shows 48mm restrictive above 7500 RPM
Risk: May lose low-end torque below 3000 RPM
Test: Dyno before (350kW) → after (385kW) ✅ +35kW gain
Customer feedback: "Pulls harder top-end, acceptable trade-off"
```

**Why this matters:**
- Future customers with same goal → copy proven approach
- If customer complains about low-end torque → you documented the trade-off upfront
- Warranty claim? You have evidence of testing + customer acceptance

### 4. **Reproducibility** — Build Sheets

Create shareable "profiles" for common builds:

```yaml
Build Sheet: GT3076R Turbo Kit - Nissan RB26DETT
Hardware: RB26 (2.6L I6, twin-cam)
Target: 400kW @ wheels, street-driveable
Parts:
  - Garrett GT3076R turbo (off-shelf)
  - Custom stainless manifold (CNC'd in-house)
  - Custom wastegate bracket (lathe + mill)
  - Upgraded intercooler piping (mandrel bent)
Test Results:
  - Before: 280kW @ 18 PSI (stock turbos)
  - After: 410kW @ 28 PSI (GT3076R)
  - Spool: 3200 RPM (vs 2800 stock, acceptable)
Known Issues:
  - OEM oil feed line restrictive → use -4AN braided
  - Wastegate actuator needs stiffer spring for boost control
Customer: RB26 #1247 (2023-11-14) ✅ 5,000km, no issues
```

**Next RB26 customer?** Copy this proven build sheet → 80% of R&D done.

---

## SAIF in Your Daily Workflow

### **Morning: Check SAGE Suggestions**

**SAGE = Pattern-learning system**

After machining 15 custom turbo flanges, SAGE notices:
- "You always add 0.5mm extra material for post-weld warpage correction"
- "You always pressure-test to 1.5x target boost before delivery"

**SAGE suggests:** "Create standard procedure: turbo-flange-rb26.gcode with +0.5mm allowance"

### **During Fabrication: Log Intent**

Every CNC program, every lathe operation:

```bash
# Old way: Save file as "flange-v3.gcode"
# New way (SAIF):
ATOM-FAB-20251114-003: CNC program for turbo flange v3
Intent: Customer wants T4 flange (previous v2 was T3)
Changes from v2: Bolt pattern 66mm → 76mm spacing
Test plan: Mockup fit before final machining
```

**Tool:** Simple logbook (paper or tablet) + photos of setups

### **After Testing: Record Results**

```
ATOM-TEST-20251114-004: Dyno test RB26 #1247
Before: 280kW @ 18 PSI
After: 410kW @ 28 PSI
Boost profile: Smooth ramp, no spiking
AFR: 11.8:1 WOT (target 11.5-12.0) ✅
EGT: 850°C pre-turbo (safe, <950°C) ✅
Customer approval: Signed dyno sheet
```

### **When Customer Returns: Fast Context Recovery**

Customer: "Mate, the wastegate bracket cracked after 2000km"

You check ATOM trail:
```
ATOM-FAB-20251114-005: Custom wastegate bracket (mild steel)
Intent: Budget option, customer declined stainless ($150 → $80)
Warning documented: "Mild steel may fatigue under thermal cycling"
Customer signed: Acknowledged risk
```

**Resolution:** "We discussed this trade-off — see your signed job card. We can remake in stainless ($150) or reinforce the mild steel ($50). Your call."

**Without SAIF:** "Uh... I think we made it out of mild steel? Not sure why. I'll check with the boss."

---

## Workshop Tools Integration

### **CNC Machines**
- Save G-code with ATOM tags: `ATOM-FAB-20251114-006_turbo-flange-rb26.gcode`
- Comment blocks include intent:
  ```gcode
  (ATOM-FAB-20251114-006: Turbo flange for RB26 #1247)
  (Intent: T4 flange, +0.5mm warpage allowance)
  (Material: 304 stainless, 10mm plate)
  ```

### **Lathes / Manual Mills**
- Logbook next to machine (waterproof notebook)
- Photo each setup with phone → save to job folder
- Note critical dimensions + intent

### **CAD/CAM Software**
- File naming: `RB26-turbo-manifold_ATOM-FAB-20251114-007.step`
- Include notes layer with: customer, vehicle, intent, test results

---

## Benefits for You (R&D Prototyper)

1. **Less rework:** "Did I use 0.5mm or 1mm allowance last time?" → Check ATOM trail
2. **Faster quoting:** Similar job? Copy proven build sheet → accurate time estimate
3. **Liability protection:** Customer claims you "never warned them"? → Signed ATOM trail
4. **Knowledge preservation:** You train a new machinist? → Build sheets are complete training docs
5. **Reputation:** Customers brag: "These guys document everything — proper engineering"

---

## Getting Started (This Week)

### **Day 1: Pick One Job**
- Next custom turbo kit or manifold
- Create first ATOM trail entry (intent + test plan)

### **Day 2-5: Log Everything**
- CNC programs → add ATOM tags
- Lathe work → photo + logbook entry
- Testing → dyno sheet + ATOM result

### **Week 2: Review**
- Did documenting slow you down? (Should add <5 min/job)
- Did it help when customer called with questions? ✅
- Can you quote similar job faster? ✅

### **Month 2: Share Build Sheets**
- Create profiles for common builds (RB26 turbo, 2JZ, Barra)
- New customer with RB26? → "We've done 8 of these. Here's proven spec."

---

## Example: Complete ATOM Trail for Turbo Kit

```
ATOM-FAB-20251114-010: Custom turbo kit - RB26DETT #1247
Customer: John Smith, 1999 R34 GT-R, street + track use
Goal: 400kW @ wheels, responsive spool, pump 98 RON
Budget: $8,500 all-in

Parts fabricated:
- Custom stainless manifold (CNC + TIG welded)
- Turbo flange (304 SS, 10mm, T4 pattern)
- Wastegate bracket (reinforced, 5mm stainless)
- Oil feed adaptor (lathe-turned, -4AN)

Testing:
- Pressure test: 40 PSI (target 28 PSI) ✅
- Dyno: 410kW @ 28 PSI (exceeded goal) ✅
- 200km test drive: No boost leaks, smooth delivery ✅

Customer signed: 2025-11-14
Follow-up: 1000km service check (free)

ATOM-FAB-20251114-011: Follow-up RB26 #1247 (1000km check)
Result: No issues, customer reports "pulls like a train"
Wastegate bracket: No cracks (stainless choice validated)
```

**Next RB26 customer?** → Start with this proven build sheet → $6,000 saved in R&D time.

---

**Questions? Chat with workshop team or GM about SAIF rollout.**

**ATOM:** ATOM-DOC-20251114-020
**Framework:** SAIF for Automotive Fabrication v1.0
**Target:** R&D Prototyper / Lead Machinist
