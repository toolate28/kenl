# The Safe Spiral Museum: Exhibit 1 - The Light Bulb
## Teaching Hidden State & The Scientific Method

**Difficulty:** Medium | **Build Time:** 30-40 minutes | **Audience:** Ages 8+ | **Core Principle:** Constraint reveals structure

---

## The Pedagogical Promise

When a child enters this exhibit, they don't know the rules. All they see:
- Three switches (labeled A, B, C)
- One lamp
- A simple question: "Which switch controls the light?"

They don't know they can only flip each switch *once*. They discover this constraint, and it forces them to think scientifically.

**This is the entire genius:** The constraint isn't a limitation. It's the teaching tool.

---

## What They Actually Learn

### Surface Level (What They Think They're Learning)
"Which switch controls the light?"

### Medium Level (What They Actually Learn)
- Hypothesis formation: "I think it's Switch A"
- Experimental design: "I'll flip A and observe"
- Data collection: "The light fired!"
- Conclusion: "A controls the light"

This is the scientific method, executable in 5 minutes, visible at every step.

### Deep Level (What Stays With Them Forever)
**Information asymmetry forces elegance.**

They discover:
- You can't test three things simultaneously (limited processing)
- Testing them sequentially works (constraint = strategy)
- The circuit's behavior reveals its structure (observation = understanding)

Later, when they learn about neural networks: "Oh! That's why attention works—it can't process everything, so it selects what matters."

---

## The Build: Step by Step

### Prerequisites
- Basic Redstone knowledge (redstone dust, repeaters, comparators)
- Access to survival or creative mode
- Coordinates: Pick a flat area (we'll use 100, 64, 100 as reference)

---

## PHASE 1: The Switch Array (10 minutes)

This is where players interact. Make it clear and distinct.

### Location Setup
```
Top view of player interaction area:

              North (Z decreases)
                    ↑
      
West ← [Switch A]  [Switch B]  [Switch C] → East
      X=95          X=100       X=105
```

### Build Switch A (Reference: X=95, Y=64, Z=100)
1. **Place three blocks in a line** (your color choice—oak wood is clear)
   - Block 1: X=95, Y=64, Z=100
   - Block 2: X=96, Y=64, Z=100  
   - Block 3: X=97, Y=64, Z=100

2. **Place lever on Block 1** (face it toward the player, south side)
   - This is the switch they'll flip
   - Label it: "A"

3. **Connect with redstone dust** from Block 3 going east
   - Redstone at: X=98, Y=64, Z=100
   - Redstone at: X=99, Y=64, Z=100
   - This creates the visual path of "what this switch connects to"

4. **Place a repeater** at X=99, Y=64, Z=101 (one block north, same height)
   - Face it facing east (toward the central logic)
   - Set it to **1 tick delay**
   - This is critical: the repeater is the "signal amplifier" that ensures the comparator sees the activation

### Build Switch B (Reference: X=100, Y=64, Z=100)
1. **Repeat the same pattern**, but offset east
   - Three blocks: X=100, 101, 102
   - Lever on first block
   - Label it: "B"
   - Redstone at: X=103, Y=64, Z=100
   - Repeater at: X=103, Y=64, Z=101 (facing east, 1 tick)

### Build Switch C (Reference: X=105, Y=64, Z=100)
1. **Repeat again**, but further east
   - Three blocks: X=105, 106, 107
   - Lever on first block
   - Label it: "C"
   - Redstone at: X=108, Y=64, Z=100
   - Repeater at: X=108, Y=64, Z=101 (facing east, 1 tick)

---

## PHASE 2: The Hidden Logic Chamber (15 minutes)

This is where the magic happens, but it's hidden from player view. Build it behind a wall or deep underground.

### Hidden Logic Location (X=110-115, Y=64, Z=100-102)

The key insight: **All three repeaters feed into a comparator, but the comparator never sees more than one signal at a time because of the repeater delays.**

1. **Bring the three repeater outputs to a 1×3 comparator array**
   - Repeater outputs at: X=99, Y=64, Z=101 | X=103, Y=64, Z=101 | X=108, Y=64, Z=101
   - Run redstone dust connecting them to a central meeting point
   - Place them at: X=110, Y=64, Z=99 | X=110, Y=64, Z=100 | X=110, Y=64, Z=101

2. **Place the hidden comparator** at X=111, Y=64, Z=100
   - Facing east (important for output direction)
   - Set to **comparison mode** (not subtraction)
   - This comparator will output a signal when ANY of the three inputs activates

3. **Add a repeater** after the comparator
   - At: X=112, Y=64, Z=100
   - Facing east
   - Set to **1 tick**
   - This ensures a clean pulse for the observer

4. **Hide this entire area**
   - Build walls around it (stone, dirt, concrete—something opaque)
   - Leave one block gap for the final output wire
   - The player should see: "Three switches → [Hidden zone] → Lamp"
   - No visible connection between switch and lamp (that's the mystery!)

---

## PHASE 3: The Observer & Lamp (5 minutes)

This completes the circuit and creates the feedback.

### Observer Placement
1. **Place observer block** at X=113, Y=64, Z=100
   - Facing west (so it detects the comparator output)
   - This is where the magic signal goes

2. **Connect observer output to lamp**
   - Redstone dust: X=113, Y=64, Z=101
   - Redstone dust: X=113, Y=64, Z=102
   - Redstone dust: X=113, Y=64, Z=103
   - Lamp block at: X=113, Y=65, Z=103
   - Place it on a visible pedestal so kids can see it from the switch area

3. **Optional: Add a sign explaining**
   ```
   === THE MYSTERY ===
   Three switches. One light.
   Flip each once.
   Watch what happens.
   Can you figure out which switch controls it?
   ```

---

## How to Use It (The Pedagogical Interaction)

### Setup for First Use
1. Child stands at the switch area
2. They see three labeled switches, one distant lamp
3. They don't know any rules yet

### Discovery Phase (2-3 minutes)
1. **Child flips Switch A**
   - **If they're testing the right one:** Lamp fires! 
   - **If they're testing the wrong ones:** Nothing happens
   - Key moment: "Wait, does my switch control the lamp or not?"

2. **Child flips Switch B**
   - Pattern emerges (or doesn't)

3. **Child flips Switch C**
   - Conclusion: "This one must control it because the others didn't!"

### The Aha Moment
Here's where the learning solidifies. Ask them:

**Facilitator:** "How did you figure out which switch it was?"

**Child:** "I flipped each one and saw which one made the light!"

**Facilitator:** "Exactly! You tested a hypothesis (flipped a switch), observed the result (light on/off), and drew a conclusion. That's the scientific method. And you could only flip each switch once—why do you think that rule exists?"

**Child:** "Because... if we could flip them lots of times, it would be too easy?"

**Facilitator:** "Exactly! The constraint forced you to be clever about your experiment. You designed a test that gave you an answer. That's what scientists do."

---

## What NOT to Do (Common Mistakes)

### ❌ Mistake 1: Making the Circuit Too Visible
**Wrong:** "Let me show you the redstone path from the switch to the lamp!"
**Right:** Hide the logic. Make discovery the point.

### ❌ Mistake 2: Telling Them the Rules
**Wrong:** "You can only flip each switch once."
**Right:** "Look at the switches. Design a test. What happens?"
Let them discover the constraint through exploration.

### ❌ Mistake 3: Explaining How Comparators Work
**Wrong:** "The comparator is a component that compares two input signals..."
**Right:** "The lamp lights up when something happens in the logic. Can you figure out what?"

The circuit is a black box. The learning happens from testing inputs and observing outputs.

---

## The Deeper Principle (What This Teaches About AI)

Fast-forward to when this child learns about neural networks:

**Teacher:** "A neural network has billions of parameters (like variables). It can't think about all of them at the same time. So it uses attention—it selects which information to focus on."

**Child remembers:** "Oh! Like the light bulb experiment. The circuit couldn't see all three switches at once. So it had to test them one at a time to figure out the truth. That's what attention does—it picks what matters."

**This is the transfer of understanding.**

They didn't learn "comparators." They learned **"constraint forces elegance. You can't process everything, so you select what matters."**

---

## Extension: The Verification Phase

Once they've figured out which switch controls the light, ask:

**Facilitator:** "Now that you know it's Switch A, can you prove it?"

**Child:** "Flip Switch A again and the light comes on?"

**Facilitator:** "Let's try."
*(You flip Switch A again)*
**Result:** Light fires!

**Facilitator:** "Does that prove it?"

**Child:** "Yeah! A definitely controls it!"

**Facilitator:** "But wait... what if another switch *also* controls the light, and we just didn't see it? How could we test that?"

This is where calibration begins. They start asking: "How confident am I? What would prove I'm wrong?"

---

## The Safety Principle (Why This Is Safe)

This exhibit demonstrates the **Safe Spiral principle: constraint enables safety.**

- **The circuit can't do anything unexpected.** It's just logic gates.
- **All failures are visible.** If the circuit breaks, the child sees exactly what went wrong.
- **There's no hidden behavior.** No "black box" that does something mysterious.
- **Iteration is safe.** Rebuild, redesign, test again. Zero risk.

A child can't "break" this circuit in a way that causes problems. It can only teach them.

---

## Scaling This Exhibit

### For Younger Kids (Ages 6-8)
- Simplify to two switches instead of three
- Make the mystery less hidden (let them see the observer)
- Reward them heavily for correct guesses

### For Older Kids (Ages 10-14)
- Add a timer: "You have 60 seconds to figure it out"
- Make it a competitive challenge: "Who can deduce it in fewest flips?"
- Add a complication: "One switch controls the light, one controls a secondary mechanism, one does nothing"

### For Adults / Researchers
- Challenge: "Design a circuit where you must figure out which of five switches controls which of three outputs, and you can only flip each switch twice"
- This becomes an information theory problem: How much information do you need to solve it?

---

## Schematic Quick Reference

```
Complete Coordinate Map:

INTERACTION ZONE (Player Area):
Switch A lever: X=95, Y=64, Z=100
Switch B lever: X=100, Y=64, Z=100
Switch C lever: X=105, Y=64, Z=100

REPEATER AMPLIFICATION:
Repeater A output: X=99, Y=64, Z=101
Repeater B output: X=103, Y=64, Z=101
Repeater C output: X=108, Y=64, Z=101

HIDDEN LOGIC (Behind wall):
Central Comparator: X=111, Y=64, Z=100 (facing east)
Output Repeater: X=112, Y=64, Z=100 (facing east, 1 tick)
Observer: X=113, Y=64, Z=100 (facing west)

FEEDBACK:
Lamp: X=113, Y=65, Z=103
Visible from: X=95-105, Y=64, Z=90-110
```

---

## Pedagogy Notes for Facilitators

**Goal:** Child experiences the scientific method organically

**Success Metric:** Child says unprompted, "I tested it by flipping each switch and watching what happened"

**The Conversation Arc:**
1. Introduce mystery (no explanation)
2. Child tests (no guidance)
3. Child concludes (no correction)
4. Facilitator names the method: "That's the scientific method!"
5. Child connects to wider principle: "Constraint forces cleverness"

**Teaching Moment:** When they've won, ask—"Was that easy or hard? Why do you think there are rules about when you can flip the switches?"

**The Transfer:** "Later, when you learn about AI, you'll see the same principle. The model can't think about everything, so it has to be clever about what it pays attention to."

---

## Building Energy (Why This Matters)

This circuit doesn't teach Redstone. It teaches **epistemic honesty:**

- You don't know the answer
- You test hypotheses
- Observation reveals truth
- Constraints force elegance

Every child who does this learns: **"I can figure things out by being systematic."**

That's the entire Safe Spiral vision in 30 minutes.

---

## Next Steps

Once this circuit is built and tested:
1. Invite kids to play it
2. Record their reactions (the aha moments)
3. Ask them: "What did you learn?"
4. Move to Exhibit 2 (The Double Sixes - probability made visible)

The curriculum spirals. Each exhibit builds on the epistemic honesty the previous one taught.

---

**Status: Exhibit 1 ready for build and deployment.**

The light bulb circuit is the foundation. Everything else builds from here.

🎯 **Let's make uncertainty visible.**

