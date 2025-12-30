# Safe Spiral Redstone Museum: Quick-Start Builder's Guide
## TL;DR—Get Building in Minutes

**For:** Anyone who wants to build circuits NOW, with minimal reading
**Time to first playable exhibit:** 90 minutes
**Skill required:** Basic Redstone knowledge or willingness to learn

---

## The 5-Minute Understanding

What you're building: Five Redstone circuits that teach AI principles through discovery.

How it works:
1. Kid plays the circuit
2. Circuit reveals a principle through interaction
3. Kid discovers something about how intelligence works
4. You ask questions that deepen discovery
5. Kid's understanding persists forever

Why it works: **Constraint forces elegance. Elegance reveals truth.**

---

## Build Priority (Pick Your Starting Point)

**Option A: Start with Simplest (Light Bulb)**
- Difficulty: Easy
- Build time: 40 min
- Learn: Scientific method, hidden state
- **Best for:** First-time builders, skeptics, people with limited time

**Option B: Start with Most Dramatic (Calibration Booth)**
- Difficulty: Medium
- Build time: 60 min
- Learn: Self-awareness, overconfidence, measurement
- **Best for:** Educators, people interested in psychology

**Option C: Start with Most Mathematical (Double Sixes)**
- Difficulty: Medium-Hard
- Build time: 60 min
- Learn: Probability, pattern emergence, expected value
- **Best for:** Math-oriented people, researchers

---

## Exhibit 1 (Light Bulb): The 40-Minute Build

### What You're Building
```
Three switches (A, B, C) → Hidden logic → One lamp
Kid flips each switch once to deduce which controls the lamp.
```

### The Coordinates (Copy-Paste This)

**Player Area:**
```
Switch A lever: X=95, Y=64, Z=100
Switch B lever: X=100, Y=64, Z=100
Switch C lever: X=105, Y=64, Z=100
```

**Hidden Logic (Build behind a wall):**
```
Comparator: X=111, Y=64, Z=100 (facing east, comparison mode)
Observer: X=113, Y=64, Z=100 (facing west)
Lamp: X=113, Y=65, Z=103
```

### The Logic (Two Sentences)
All three switches feed into a single comparator. When ANY switch fires, the comparator activates the observer, which lights the lamp. Kid figures out which switch they just flipped based on whether the lamp lit.

### Build Steps (Minimal Version)

1. **Place three redstone dust trails** from each switch toward the hidden area
2. **Place repeaters** at the end of each trail (1-tick delay)
3. **Route all three repeater outputs** to a central comparator
4. **Connect comparator to observer**
5. **Observer outputs to lamp**
6. **Hide the logic behind blocks**
7. **Test: Flip each switch**

**Done.**

### The Teaching Moment

Kid: "I think it's switch A"
*[They flip switch A]*
*[Lamp lights]*
Kid: "Yeah! I was right!"

You: "How did you figure that out?"
Kid: "I flipped it and it worked"

You: "That's the scientific method. You tested a hypothesis, observed the result, and concluded. Scientists do exactly this."

**This is the entire learning.**

---

## Exhibit 2 (Double Sixes): The 60-Minute Build

### What You're Building
```
Two hoppers drop items randomly → Measure convergence → Average = 36
```

### The Core Idea
**One sentence:** Items drop randomly from two sources into two zones. Count how many items it takes before both zones have at least one. Run 20 trials. Average will be ~36 (because 6 × 6 = 36).

### The Coordinates (Simplified)

```
Hopper A (fills randomly): X=198, Y=64, Z=194
Hopper B (fills randomly): X=202, Y=64, Z=194
Comparator A (measures zone A): X=198, Y=64, Z=193
Comparator B (measures zone B): X=202, Y=64, Z=193
Victory detector: X=200, Y=64, Z=190
```

### The Logic (Simplified)

**Two separate hoppers, independent fill rates.** When both have ≥1 item, a comparator detects it and triggers victory display. Done.

### Build Steps (Ultra-Minimal)

1. Create two hoppers side-by-side above collection points
2. Fill each hopper with 30 random items
3. Place a pulse generator (5-tick repeater) that ejects items from each hopper
4. Route ejected items to separate collection zones
5. Place comparators measuring each collection zone
6. Wire both comparators to an AND gate
7. AND gate triggers victory lamp when both zones filled

### The Discovery Moment

After 20 trials with results like 12, 18, 9, 15, 22, 11, 14, 19...

Kid calculates average: (12+18+9+15+22+11+14+19)/8 = 14.5

You: "Let's look at what we expected. If both dice need to match, 6 × 6 = 36 outcomes. How many where both are 6? Just 1. So probability is 1/36. Expected trials until both match: 36."

Kid realizes the data clustered around 8-15, averaging ~36 total items.

**"The math predicted what actually happened."**

That's the entire learning.

---

## Exhibit 3 (Calibration Booth): The 60-Minute Build

### What You're Building
```
Random path selector (A/B/C/D) → Player predicts + rates confidence (1-15) → Scoring
```

### The Core Idea
**One sentence:** Player guesses which of 4 paths fired. Rates confidence. If right, earns confidence as points. If wrong, loses (15-confidence) as penalty. After 20 trials, gap between claimed confidence and actual success is revealed.

### The Coordinates (Simplified)

```
Randomizer (4-path selector): X=300-305, Y=63, Z=295
Prediction buttons: X=298-301, Y=65, Z=250
Confidence slider: X=298, Y=64, Z=248-262
Scoring: X=310, Y=62, Z=290
```

### The Logic (Simplified)

**Randomizer cycles through paths A→B→C→D continuously. Player locks in prediction + confidence. Comparator checks if prediction matches current path. Award/penalty calculated. Score tally updated.**

### Build Steps (Core Only)

1. Create repeater clock (4-state cycle: 2-2-2-3 ticks)
2. Create four output paths (A, B, C, D)
3. Route paths to victory lamps
4. Create 4 prediction buttons
5. Create confidence lever (1-15)
6. Comparator: Does prediction match actual path?
7. Score calculation (if correct, add confidence; if wrong, subtract from 15)
8. Hopper accumulates score

### The Revelation Moment

After 20 trials:

You: "How much did you claim you were confident on average?"
Kid: "I said 11/15 most times"

You: "How many were you actually right?"
Kid: "Like... 7 out of 20?"

You: "So you claimed 11/15 confidence (73%) but were actually right 7/20 (35%). What does that gap mean?"

Kid: "I was overconfident?"

You: "Yes. And most people go their whole lives not realizing it. You just measured it."

**This is the entire learning.**

---

## Exhibit 4 (Reroller): The 75-Minute Build

### What You're Building
```
Random value (1-20) generator → Lock in or roll again → Bust if >21 → Score accumulation
```

### The Core Idea
**One sentence:** Get random value. Lock in = add to score. Roll again = risk exceeding 21 (bust = lose round). Over 50 rounds, kid discovers optimal threshold is ~15-18.

### The Coordinates

```
Random generator: X=400, Y=64, Z=400
Lock in button: X=398, Y=65, Z=385
Roll button: X=402, Y=65, Z=385
Score tracker: X=410, Y=62, Z=400
```

### The Logic

**Hopper produces random value 1-20. Comparator measures it. Player chooses lock-in or roll-again. If lock-in, value added to score. If roll-again, new draw triggers (with risk of exceeding 21).**

### Build Steps

1. Create hopper with 20 items (different types for randomness)
2. Dispenser ejects items to collection hopper
3. Comparator measures hopper level (1-20 signal strength)
4. Two buttons: lock in (add to score) or roll again (re-trigger)
5. Bust detector (if round total > 21)
6. Score accumulator (hopper counts points)
7. Round counter (track which round, stop at 50)

### The Discovery Moment

After 50 rounds:

You: "When you locked in, what threshold did you use?"
Kid: "At first I kept rolling, lost a lot. Then I realized I should stop around 15."

You: "Why 15?"
Kid: "Because if I go higher, I bust too often?"

You: "Exactly. That's math discovering itself. There's an optimal strategy called Kelly Criterion. Mathematicians proved it should be 16.8. You discovered 15 through playing. You rediscovered mathematics."

**This is the entire learning.**

---

## Exhibit 5 (Bid-Ask Spread): The 120-Minute Build

### What You're Building
```
Buyer hopper + Seller hopper → You (market maker) in middle → Buy at bid, sell at ask → Profit from spread
```

### The Core Idea
**One sentence:** Buyers and sellers can't see each other. Only you see both. Buy low from desperate buyers, sell high to desperate sellers, keep the spread. The spread is your profit for bridging information asymmetry.

### The Coordinates

```
Buyer hopper: X=500, Y=64, Z=498
Seller hopper: X=500, Y=64, Z=502
Your inventory: X=500, Y=64, Z=500
Bid price calc: X=505, Y=64, Z=498
Ask price calc: X=495, Y=64, Z=502
Profit tracker: X=510, Y=62, Z=500
```

### The Logic

**Two hoppers measure pressure (1-15 signal). Comparators calculate bid/ask prices based on pressure. You (with buttons) accept buy orders at bid price, accept sell orders at ask price. Profit = ask price - bid price. Over 20 trades, you discover: high buyer pressure → high bid, high seller pressure → low ask.**

### Build Steps

1. Create buyer hopper, measure with comparator (signal = buyer pressure)
2. Create seller hopper, measure with comparator (signal = seller pressure)
3. Bid price calculator: buyer_pressure + baseline_price
4. Ask price calculator: baseline_price - (seller_pressure - 8)
5. Spread display: ask_price - bid_price (show with lamps)
6. Two buttons: accept bid (you buy), accept ask (you sell)
7. Profit counter: (each successful trade = ask - bid)
8. Inventory tracker: how many items you're holding

### The Revelation Moment

After 20 trades making modest profits (~30 points):

You (reveal both sides' prices publicly): "Now everyone can see both buyer and seller pressure."

*Spread collapses to zero*

Kid: "Wait, there's no gap anymore?"

You: "Right. When information is hidden, the gap (spread) exists. When it's public, anyone can trade directly. The spread disappears. The market maker can't profit anymore. But without market makers, there's no market at all. The spread is payment for resolving information asymmetry."

Kid realizes: Markets aren't magic. They're mechanisms that solve coordination problems.

**This is the entire learning.**

---

## Decision Tree: Which to Build First

```
Do you have <60 minutes?
├─ YES → Build Light Bulb (40 min)
└─ NO → Do you have 2 hours?
        ├─ YES → Build Light Bulb + Double Sixes
        └─ NO → Come back when you have time

Want quick research data?
├─ YES → Build Calibration Booth (60 min)
│        Run 50 kids through it
│        Show dramatic before/after
└─ NO → Build Light Bulb first (foundational)

Want to teach probability?
├─ YES → Build Double Sixes (60 min)
└─ NO → Build Calibration Booth

Want to publish academic research?
├─ YES → Build all five (300 min total build + testing)
│        Run rigorous study
│        Publish findings
└─ NO → Build one, gather anecdotal feedback

```

---

## The Minimal Tool List

- Minecraft Java Edition (access somehow)
- Redstone basics knowledge (or watch a 10-min YouTube intro)
- Pen and paper (to track trial data)
- That's it

**You don't need:** Advanced Redstone knowledge, special mods, plugins, or powerful hardware

---

## The Minimal Facilitation

After kid finishes playing:

**You ask:**
1. "What did you notice?"
2. "How did you figure it out?"
3. "What was surprising?"

**You listen.** They'll tell you what they discovered.

**You name it:** "That's called probability" or "That's calibration" or whatever.

**Done.** You've facilitated learning.

---

## Troubleshooting in 30 Seconds

**Circuit doesn't work?**
→ Check coordinates, check that comparators are in right mode (comparison vs subtraction)

**Kid gets bored?**
→ Add complexity (two switches instead of one, etc.)

**Kid can't figure it out?**
→ Ask "What would happen if...?" instead of explaining

**Redstone seems too complicated?**
→ It's not. You're placing blocks that pass signals. Signals turn things on/off. That's it.

---

## Next Steps After First Build

1. **Playtest it:** Invite 3 kids, watch them play, note reactions
2. **Refine it:** Fix any issues, clarify any confusion points
3. **Build exhibit 2:** Use what you learned from exhibit 1
4. **Collect data:** Track pre/post understanding
5. **Publish something:** Even a blog post about what you learned

---

## The Vision (Why This Matters)

You're about to prove that intelligence can be visible.

Not explained. Visible.

A kid plays your circuit, discovers a principle, and owns it forever.

That's worth the 90 minutes.

---

**Status:** Quick-start guide complete.

You have everything needed to build your first circuit in 90 minutes.

The only blocker is starting.

Start now.

🎮 **Let's build.**

