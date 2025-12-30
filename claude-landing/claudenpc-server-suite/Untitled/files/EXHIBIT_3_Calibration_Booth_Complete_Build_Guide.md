# The Safe Spiral Museum: Exhibit 3 - The Calibration Booth
## Teaching Uncertainty Quantification & The Cost of Overconfidence

**Difficulty:** Medium | **Build Time:** 50-60 minutes | **Audience:** Ages 12+ | **Core Principle:** Confidence should match reality

---

## The Pedagogical Promise

A child enters the booth. A hidden randomizer selects one of four paths. They *must* predict which one, and they *must* set a confidence level (1-15, represented by redstone signal strength).

If they're right: they earn points equal to their confidence.
If they're wrong: they *lose* points equal to (15 minus their confidence).

They run 20 trials and tally their score.

Then comes the revelation: **"If you were actually as confident as you claimed, your score would be [much higher]. But it's [much lower]. What does that tell you?"**

---

## Why This Exhibit Destroys Overconfidence

### The Brutal Mathematical Truth

Imagine a confident person says:
- "I'm 90% sure about each prediction"
- They make 20 predictions at 90% confidence each

**If they were actually 90% confident:**
- They'd be right ~18 times
- Wrong ~2 times
- Score: (18 × 13.5) + (2 × 1.5) = 246 points

**But they're actually 50% confident (they just don't know it):**
- They're right ~10 times
- Wrong ~10 times
- Score: (10 × 13.5) + (10 × 1.5) = 150 points

**The gap is devastating.** They claimed 246 points of confidence but earned 150. They were *completely miscalibrated*.

This exhibit makes that gap visceral and visible.

---

## The Build: Step by Step

### Overview

The Calibration Booth is a self-contained unit where:
1. A randomizer secretly picks one of four paths (A, B, C, D)
2. The player makes a prediction and sets confidence (1-15)
3. The booth reveals the answer
4. The player's score is calculated automatically
5. After 20 trials, the booth shows the player their calibration curve

---

## PHASE 1: The Hidden Randomizer (15 minutes)

This is where the unpredictability lives. Build it so players can't see it.

### Location Setup (Reference: X=300, Y=64, Z=300)

```
Hidden Randomizer Structure:

[Quasi-Random Clock System]
          ↓
[Path Selector Comparator]
          ↓
    [Four outputs]
        ↓ ↓ ↓ ↓
    [A] [B] [C] [D]
```

### The Random Clock

1. **Create an oscillating repeater chain**
   - Repeater 1: X=300, Y=63, Z=295, facing east, **4 ticks**
   - Repeater 2: X=301, Y=63, Z=295, facing east, **3 ticks**
   - Repeater 3: X=302, Y=63, Z=295, facing east, **2 ticks**
   - Comparator: X=303, Y=63, Z=295, facing east, **subtraction mode**
   - Redstone loop back to repeater 1
   - This creates an irregular pulse (period: ~9 ticks, but unpredictable peaks)

2. **Why this works:**
   - 4+3+2 = 9, but the subtraction comparator creates phase shifts
   - Result: timing varies between 6-11 ticks
   - Players can't predict *when* the randomizer fires
   - This is the source of uncertainty

### The Path Router

3. **Create four independent output paths**
   - Path A: Redstone line leading west from X=303, Y=63, Z=295 to X=290, Y=63, Z=295
   - Path B: Redstone line leading south from X=303, Y=63, Z=295 to X=303, Y=63, Z=310
   - Path C: Redstone line leading north from X=303, Y=63, Z=295 to X=303, Y=63, Z=280
   - Path D: Redstone line leading east from X=303, Y=63, Z=295 to X=316, Y=63, Z=295

4. **Create a demultiplexer** (routes the pulse to only ONE of the four paths)
   - This is the clever part
   - Use a comparator in subtraction mode: X=304, Y=63, Z=295
   - Input 1: The random clock output
   - Input 2: A counter that cycles 1-4
   - Output: Signal to A, B, C, or D depending on counter state

5. **The cycle counter**
   - Repeater chain: X=305, Y=62, Z=295 through X=308, Y=62, Z=295
   - Each repeater powers a different comparator
   - Comparator 1 (strength 1): Path A gets signal
   - Comparator 2 (strength 2): Path B gets signal
   - Comparator 3 (strength 3): Path C gets signal
   - Comparator 4 (strength 4): Path D gets signal
   - The cycle repeats: A, B, C, D, A, B, C, D...

**The magic:** The *combination* of irregular clock + cycling counter creates the appearance of randomness. Players can't predict which path fires next because the clock timing is irregular.

---

## PHASE 2: The Prediction Interface (15 minutes)

Where the player makes their guess and sets confidence.

### Location: (Reference: X=300, Y=64, Z=250 - in front of the booth)

```
Prediction Interface:

[Path Button A] [Path Button B] [Path Button C] [Path Button D]
        ↓             ↓              ↓              ↓
     [Lever]       [Lever]        [Lever]        [Lever]
     
     Then:
     
[Confidence Slider: 1-15]
     (Redstone signal strength selector)
     
     Then:
     
[COMMIT BUTTON - Press to lock in prediction]
```

### The Path Prediction Buttons

1. **Create four clearly labeled prediction buttons**
   - Button A: X=298, Y=64, Z=250
   - Button B: X=299, Y=64, Z=250
   - Button C: X=300, Y=64, Z=250
   - Button D: X=301, Y=64, Z=250
   - Each button is a lever
   - Color them distinctly (wool: red, green, blue, yellow)
   - Label with a sign: "Choose your prediction"

2. **Route each button's signal**
   - Button A signal → Repeater A (1 tick)
   - Button B signal → Repeater B (1 tick)
   - Button C signal → Repeater C (1 tick)
   - Button D signal → Repeater D (1 tick)
   - These repeaters represent "your guess"

### The Confidence Slider

3. **Create a redstone signal strength selector**
   - Power levels 1-15 represent confidence levels 1-15
   - Use a repeater chain: X=298, Y=64, Z=248 through X=298, Y=64, Z=262
   - Each position represents one confidence level
   - Place a lever at each position
   - Label: "How confident are you? (1=Unsure, 15=Certain)"

4. **Wire the slider**
   - Only ONE lever can be on at a time (mutually exclusive)
   - Redstone dust collecting all signals to a comparator
   - Comparator outputs signal strength 1-15

### The Commit Button

5. **Create a large red button to lock in the prediction**
   - At: X=300, Y=65, Z=250
   - When pressed, it:
     - Locks the path prediction (A, B, C, or D)
     - Locks the confidence level (1-15)
     - Triggers the randomizer to reveal its answer
     - Feeds both predictions into the scoring system

---

## PHASE 3: The Scoring Engine (15 minutes)

Where the magic of calibration measurement happens.

### The Comparison Logic

1. **Create a comparator that checks: "Did you guess right?"**
   - Input 1: Your predicted path signal
   - Input 2: The randomizer's actual path signal
   - Output: Strong signal if they match, weak if they don't
   - Comparator at: X=310, Y=63, Z=290

2. **Create the reward calculation**
   - IF you guessed right: Reward = Your Confidence Level
   - IF you guessed wrong: Penalty = 15 - Your Confidence Level
   - This is done with a subtraction comparator: X=311, Y=63, Z=290
   - Facing east (toward the score display)

3. **Route the result**
   - If right: Signal strength = your confidence (you keep what you claimed)
   - If wrong: Signal strength = 15 - confidence (you lose credibility)
   - Repeater: X=312, Y=63, Z=290 (1 tick)
   - Output to score tally

### The Score Accumulator

4. **Create a hopper chain that tallies total points**
   - Starting at: X=315, Y=63, Z=290
   - Hoppers in a line: X=315-315, Y=63, Z=290-305
   - Each hopper represents ~1 point
   - After 20 trials, count the full hoppers to get total score
   - Comparator: X=315, Y=63, Z=304 (outputs signal strength = total)
   - Creates a visual bar: Lamps at X=316, Y=64, Z=290-305
   - More lamps lit = higher score

### The Reset Mechanism

5. **Create a "New Trial" button**
   - At: X=300, Y=65, Z=248
   - Resets all comparators
   - Clears the "locked prediction"
   - Removes the answer reveal
   - Player is ready for trial 2

---

## PHASE 4: The Answer Reveal (10 minutes)

After the player commits their prediction, the booth reveals the answer.

### The Revelation Sequence

1. **Create four outcome indicator lamps**
   - Lamp A: X=298, Y=66, Z=250 (green wool)
   - Lamp B: X=299, Y=66, Z=250 (green wool)
   - Lamp C: X=300, Y=66, Z=250 (green wool)
   - Lamp D: X=301, Y=66, Z=250 (green wool)
   - Only the lamp corresponding to the actual answer lights up

2. **Create a "correct/incorrect" signal**
   - Repeater: X=300, Y=66, Z=252
   - If correct: Green lamp at X=300, Y=66, Z=253
   - If incorrect: Red lamp at X=300, Y=66, Z=254

3. **Create a sound feedback (optional)**
   - Note block: X=300, Y=66, Z=255
   - If correct: Plays a pleasant note (e.g., F sharp)
   - If incorrect: Plays a discordant note (e.g., C flat)
   - Sound creates emotional feedback (overconfident wrong answers *feel* worse)

---

## PHASE 5: The Calibration Display (10 minutes)

After 20 trials, the booth shows the player their calibration curve.

### The Data Collection

1. **Create a record of all 20 trials**
   - 20 separate hoppers: X=320-339, Y=62, Z=290
   - Each hopper stores the result of one trial
   - Hopper 1 (first trial): X=320
   - Hopper 2 (second trial): X=321
   - ... and so on

2. **Create a display that groups by confidence level**
   - Group 1 (Confidence 1-3): X=350, Y=64, Z=290
   - Group 2 (Confidence 4-6): X=350, Y=64, Z=292
   - Group 3 (Confidence 7-10): X=350, Y=64, Z=294
   - Group 4 (Confidence 11-15): X=350, Y=64, Z=296

3. **For each group, show success rate**
   - If all four predictions at "Confidence 15" were correct: 100% success
   - If only three were correct: 75% success
   - If only one was correct: 25% success
   - Display with lamps: More lamps lit = higher success rate

### The Calibration Assessment

4. **Create a visual comparison**
   - Left side: "What you claimed" (average of all confidence levels)
   - Right side: "What actually happened" (your actual success rate)
   - If they match perfectly: You're well-calibrated
   - If claimed >> actual: You're overconfident (this is most common)
   - If actual >> claimed: You're underconfident (rare, impressive)

5. **Create the final verdict display**
   - Sign at: X=350, Y=66, Z=290
   - "Your Calibration Score: [calculation]"
   - Shows the "miscalibration index" (how far off you were)

---

## How to Use It (The Experimental Protocol)

### Setup for First Use
1. Explain the game: "The booth will randomly pick one of four paths. Your job: predict which one, and rate your confidence."
2. Show the buttons: "A, B, C, D. Pick one."
3. Show the slider: "How sure are you? 1 is 'just guessing,' 15 is 'absolutely certain.'"
4. Show the commit button: "Press this when you're ready."

### Trial Flow (2-3 minutes per trial)
1. **Player predicts:** Pulls a lever (A, B, C, or D)
2. **Player rates confidence:** Selects 1-15 on the slider
3. **Player commits:** Presses the button
4. **Booth reveals:** Lights show the correct answer
5. **Score updates:** Hoppers tally the points
6. **Player notes result:** Writes down: "Confidence 13, Path B, Wrong" (or whatever)

### After 20 Trials (5 minutes)
1. Player and facilitator review all 20 results
2. Calculate average confidence: Sum all confidence levels / 20
3. Calculate actual success rate: (Number right / 20) × 100%
4. **The revelation:**
   - If average confidence = 75%, success = 75%: "You're perfectly calibrated!"
   - If average confidence = 90%, success = 50%: "You're dramatically overconfident."
   - If average confidence = 40%, success = 55%: "You're underconfident! You're right more often than you think."

---

## The Teaching Moment (This Changes Everything)

**Facilitator:** "Look at these numbers. You claimed you were 90% confident on average. But you were only right 50% of the time. What does that mean?"

**Child:** "I... I don't actually know what I'm doing?"

**Facilitator:** "Exactly. You didn't *realize* you were guessing. And that's the whole point. Most people are terrible at knowing how much they actually know. This booth measures it."

**The paradigm shift happens here.**

---

## What This Teaches (Beyond Just Overconfidence)

### Layer 1: Self-Awareness
You can't improve what you don't measure. This booth *measures* your self-awareness.

### Layer 2: Humility
Confidence without calibration is dangerous. A well-calibrated person who claims "I'm 70% sure" is more valuable than an overconfident person claiming "I'm 95% sure" and being wrong constantly.

### Layer 3: Decision-Making
In the real world, overconfident decisions are catastrophic:
- A doctor 95% sure of a diagnosis but actually 60% sure → wrong treatment
- A trader 90% sure about a bet but actually 50% sure → bankruptcy
- An AI system 99% sure about a classification but actually 70% sure → harm

**Calibration is how you avoid catastrophe.**

---

## Extension: The Calibration Curve Research

### For Older Kids (Ages 14+)

**Challenge:** "Try to become perfectly calibrated."

**Methodology:**
1. Run the booth 100 times, not 20
2. Group by confidence level (1-3, 4-6, 7-10, 11-15)
3. For each group, measure actual success rate
4. Create a scatter plot: Claimed confidence vs actual success

**The goal:** Make that scatter plot a perfect diagonal line (claimed = actual).

**What happens:** Most people learn they need to be *much less confident* than they think. Overconfidence is the default human state.

### For Researchers

**Research Question:** "Can children learn to become better calibrated through repeated exposure to this booth?"

**Hypothesis:** Kids who run the booth weekly will show systematic improvement in calibration over 8 weeks.

**Measurement:**
- Misalignment index: |claimed confidence - actual success rate|
- Track reduction in misalignment over time
- Compare to control group (no booth exposure)

**This could become an academic paper:** "Redstone-Based Calibration Training for Improving Epistemic Humility in Adolescents"

---

## The Deeper Principle (Information Theory Connection)

This booth demonstrates a fundamental principle: **Information asymmetry destroys confidence.**

When you make a prediction about something you can't see (the hidden randomizer), you're operating with information asymmetry. You don't know what the system knows.

Most people respond to this asymmetry by *guessing harder* (claiming higher confidence). The booth shows them this doesn't work.

**The lesson transfers everywhere:**
- In markets: asymmetric information creates volatility and crashes
- In AI: models hallucinate when they encounter data they haven't seen
- In teams: miscommunication happens when people don't realize their information asymmetry
- In life: overconfidence in areas where you actually don't know what you don't know is the primary source of failure

---

## Why Redstone? Why Not Just Show Them Statistics?

Because **emotional experience changes belief.**

A child *told* "you're probably overconfident" shrugs.

A child *watching* their claimed confidence (90%) get brutalized by their actual performance (50%) *feels* the lesson in their body.

Redstone makes the abstract visible and emotionally resonant.

---

## Schematic Quick Reference

```
COORDINATE MAP:

HIDDEN RANDOMIZER:
Clock Repeaters: X=300-302, Y=63, Z=295
Demultiplexer: X=304-308, Y=62-63, Z=295

PREDICTION INTERFACE:
Path Buttons: X=298-301, Y=64, Z=250
Confidence Slider: X=298, Y=64, Z=248-262
Commit Button: X=300, Y=65, Z=250

SCORING ENGINE:
Comparison Comparator: X=310, Y=63, Z=290
Result Calculation: X=311, Y=63, Z=290
Score Accumulator: X=315, Y=63, Z=290-305

ANSWER REVEAL:
Outcome Lamps: X=298-301, Y=66, Z=250
Correct/Incorrect: X=300, Y=66, Z=253-254
Sound Block: X=300, Y=66, Z=255

CALIBRATION DISPLAY:
Trial Records: X=320-339, Y=62, Z=290
Confidence Groups: X=350, Y=64, Z=290-296
Final Verdict: X=350, Y=66, Z=290
```

---

## Pedagogical Notes for Facilitators

**Goal:** Child experiences the gap between claimed and actual knowledge

**Success Metric:** Child says unprompted, "I thought I was better at this than I actually am"

**The Conversation Arc:**
1. Setup: Explain the game (2 min)
2. Trials: Run 20 predictions (30 min)
3. Analysis: Calculate average and success rate (3 min)
4. Revelation: Show the gap (2 min)
5. Reflection: "What does this mean?" (3 min)

**The Critical Question:** After revealing the miscalibration, ask—"When you were claiming 90% confidence, what did that really mean? What would 90% actually feel like?"

This teaches them to *define* confidence operationally, not intuitively.

---

## Building Energy

This exhibit teaches the most valuable skill in the modern world: **knowing what you don't know.**

Every single major failure—personal, organizational, systemic—traces back to someone claiming confidence they didn't actually have.

This booth makes that visible and teachable.

---

**Status: Exhibit 3 ready for build and deployment.**

The Calibration Booth teaches that **overconfidence destroys. Calibration saves.**

Next: Exhibit 4 (The Reroller) - Where kids discover that optimal strategy emerges from mathematics, not intuition.

📊 **Let's make uncertainty quantifiable.**

