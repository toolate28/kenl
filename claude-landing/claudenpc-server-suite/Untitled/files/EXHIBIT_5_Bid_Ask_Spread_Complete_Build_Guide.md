# The Safe Spiral Museum: Exhibit 5 - The Bid-Ask Spread
## Teaching Market Microstructure & Information Asymmetry

**Difficulty:** Very Hard | **Build Time:** 90-120 minutes | **Audience:** Ages 16+ & Researchers | **Core Principle:** Asymmetric information creates profit opportunity

---

## The Pedagogical Promise

A player enters a simulated market. There are **buyers** (on the left) and **sellers** (on the right). They can't see each other. Only you—the market maker—can see both sides.

Your job: Accept buy orders and sell orders, capturing the spread (the difference between what you buy for and what you sell for).

**The magic:** In early rounds, you'll make mistakes. But after 20 trades, you'll discover:
- High buyer pressure → raise your ask (sellers become scarce)
- High seller pressure → lower your bid (buyers become desperate)
- The spread widens when information is asymmetric
- The spread narrows when both sides see each other's prices

**This is how real markets work.** The spread isn't a "fee." It's compensation for *resolving uncertainty.*

---

## Why This Exhibit Changes Everything

### The Economic Principle

In a perfect market where buyers and sellers see each other:
- Buyer: "I'll pay $100"
- Seller: "I'll accept $100"
- Trade happens instantly, no spread

In a real market where they can't see each other:
- Buyer: "I'll pay [unknown what seller will accept]"
- Seller: "I'll accept [unknown what buyer will pay]"
- **This creates uncertainty, which creates the spread**

The market maker profits from:
1. **Accepting both sides** (taking on inventory risk)
2. **Bridging the information gap** (allowing trade to happen)
3. **Capturing the spread** (compensation for these services)

### The Moral Dimension

Most people think market makers are "middlemen parasites" extracting rents. This exhibit shows the truth:
- **Without market makers, there is no market**
- Spreads are *payment for information resolution*
- Tighter spreads = more competitive market = better prices for everyone
- But market makers need to be compensated or they disappear

This is where capitalism works: The price mechanism (the spread) signals when information is scarce and compensates those who resolve it.

---

## The Build: Step by Step

### Overview

The Bid-Ask Spread exhibit has five interconnected systems:
1. **Buyer side** (creates demand)
2. **Seller side** (creates supply)
3. **Price discovery mechanism** (sets bid/ask)
4. **Market maker position** (you, bridging the gap)
5. **Profit tally** (how well you did)

---

## PHASE 1: The Buyer Side (20 minutes)

Where demand originates.

### Location Setup (Reference: X=500, Y=64, Z=500)

```
Buyer Side:
[Buyer Input] ──→ [Hopper A] ──→ [Comparator: Buyer Pressure]
                                        ↓
                              [Signal to Price Discovery]
```

### The Buyer Hopper

1. **Create the buyer hopper**
   - At: X=500, Y=64, Z=498
   - Facing east (toward the market)
   - This hopper collects "buy orders"
   - Fill it with 20-30 stackable items (represents buyer eagerness)

2. **Measure buyer pressure**
   - Comparator at: X=500, Y=64, Z=497
   - Facing east (toward the price mechanism)
   - Measures hopper fill level: 1-15 signal strength
   - Full hopper (28 items) = max pressure (signal 15)
   - Empty hopper = no pressure (signal 1)
   - **Signal represents: "How desperate are buyers?"**

3. **Create buyer input mechanism**
   - Hopper at: X=499, Y=65, Z=498 (above the main buyer hopper)
   - This allows new buy orders to enter from above
   - Can be refilled externally to simulate "wave of buyer demand"

---

## PHASE 2: The Seller Side (Mirror of Buyer) (20 minutes)

Where supply originates. Exact mirror of buyer side.

### Location Setup (Reference: X=500, Y=64, Z=502)

1. **Create the seller hopper**
   - At: X=500, Y=64, Z=502
   - Facing west (toward the market)
   - This hopper collects "sell orders"
   - Fill it with 20-30 stackable items (represents seller supply)

2. **Measure seller pressure**
   - Comparator at: X=500, Y=64, Z=503
   - Facing west (toward the price mechanism)
   - Measures hopper fill level: 1-15 signal strength
   - Full hopper = max pressure (signal 15 = "sellers desperate to sell")
   - Empty hopper = no pressure (signal 1 = "scarce inventory")

3. **Create seller input mechanism**
   - Hopper at: X=501, Y=65, Z=502 (above the main seller hopper)
   - Allows new sell orders to enter from above

---

## PHASE 3: The Price Discovery Mechanism (30 minutes)

The heart of the market. This is where prices are set based on supply/demand.

### The Bid Price Calculator

1. **Create the bid price logic**
   - Location: X=505, Y=63, Z=498 (near buyer side)
   - Comparator (subtraction mode): X=505, Y=64, Z=498
   - Input 1: Buyer pressure signal (from buyer-side comparator)
   - Input 2: Static reference signal (set to 8 = baseline price)
   - Output: Bid price = buyer pressure - 8
   - **Interpretation:** High buyer pressure (15) → high bid price (7). Buyers are willing to pay more.

2. **Create the ask price logic**
   - Location: X=495, Y=63, Z=502 (near seller side)
   - Comparator (subtraction mode): X=495, Y=64, Z=502
   - Input 1: Seller pressure signal (from seller-side comparator)
   - Input 2: Static reference signal (set to 8 = baseline price)
   - Output: Ask price = seller pressure + 8
   - **Interpretation:** High seller pressure (15) → low ask price (23). Wait, that's backwards...

   *Actually, let me recalculate the logic to be intuitive:*
   - High buyer pressure → they're desperate → willing to pay MORE → bid price INCREASES
   - High seller pressure → they're desperate → willing to accept LESS → ask price DECREASES

3. **The corrected price logic**
   - Bid price: (Buyer pressure) + (Baseline 10) = price buyers will pay
     - Max 25, Min 10
   - Ask price: (Baseline 10) - (Seller pressure - 8) = price sellers will accept
     - Or better: Ask price = 20 - (Seller pressure - 8) 
     - Max 20, Min 10
   - **The spread: Ask price - Bid price**
     - When both are balanced (pressure = 8): Spread = 0
     - When buyer pressure high & seller pressure low: Spread = large (difficult conditions)
     - When both pressures balanced: Spread = small (efficient market)

4. **Create the spread display**
   - Repeater chain: X=500, Y=65, Z=500-510
   - Each repeater represents 1 unit of spread
   - Lamps above show current spread visually
   - Large spread = many lamps lit
   - Small spread = few lamps lit
   - **This is the visual heart of the exhibit**

---

## PHASE 4: The Market Maker Position (Your Job) (25 minutes)

Now you enter the market. Your goal: capture the spread.

### Your Inventory Hopper

1. **Create your inventory space**
   - Hopper at: X=500, Y=64, Z=500 (center, between buyers and sellers)
   - This hopper stores items you've purchased but haven't sold yet
   - This is your "inventory risk"

2. **Create the buy order acceptance**
   - When you press "accept bid," you:
     - Remove an item from the buyer hopper
     - Add it to your inventory
     - Pay the bid price (reduce your score by bid amount)

3. **Create the sell order acceptance**
   - When you press "accept ask," you:
     - Remove an item from your inventory
     - Add it to the seller hopper
     - Collect the ask price (increase your score by ask amount)

### The Control Interface

4. **Create two action buttons**
   - Button A (Green): X=499, Y=65, Z=500 - "ACCEPT BID (Buy from buyer)"
   - Button B (Blue): X=501, Y=65, Z=500 - "ACCEPT ASK (Sell to seller)"
   - Label clearly: "You are the market maker"

5. **Create decision support displays**
   - Sign showing current bid price
   - Sign showing current ask price
   - Sign showing current spread
   - Sign showing your inventory count (how many items you're holding)
   - Sign showing your current profit/loss
   - **This helps players make intelligent decisions**

### Risk Management Signal

6. **Create an inventory warning**
   - If your inventory exceeds 15 items: Red warning lamp
   - Message: "You're holding too much! Price movement could hurt you!"
   - This teaches: Inventory risk is real. Market makers must manage it.

---

## PHASE 5: The Profit/Loss Tally (20 minutes)

Where the learning happens: did you make money?

### The Scoring System

1. **Create a profit hopper**
   - At: X=510, Y=62, Z=500
   - Each successful trade (capture spread) adds items here
   - Example: You buy at price 11, sell at price 14, earn 3 points

2. **Create a loss hopper**
   - At: X=490, Y=62, Z=500
   - Tracks when your positions go negative (bought high, sold low)
   - If a buyer orders arrive at high pressure and then vanish, you're stuck with inventory that's now "out of fashion"

3. **Create the net score display**
   - Comparator: X=500, Y=62, Z=505
   - Measures: Profit hopper - Loss hopper
   - Output signal strength = net profit
   - Visual display: X=500, Y=64, Z=510-520
   - Lamps showing your total score

### The Strategy Memory

4. **Create a record of all trades**
   - 20 separate cells: X=520-540, Y=62, Z=500
   - Each cell records one trade
   - Content: Hopper level shows profit/loss on that trade
   - After 20 trades, you can see: "I made 5 points on trade 3, lost 2 on trade 7, etc."

---

## PHASE 6: The Market Dynamics Simulation (25 minutes)

This is where the exhibit becomes *real*—where market conditions change.

### Demand Waves

1. **Create a "buyer demand wave" mechanism**
   - Automatically refills the buyer hopper at intervals
   - Redstone clock: X=498, Y=63, Z=495 (10 tick repeater)
   - When clock pulses, add items to buyer hopper
   - Simulates: "Wave of new buyers entering the market"

2. **Create supply shocks**
   - Separate trigger: X=502, Y=63, Z=505
   - When triggered, floods the seller hopper with items
   - Simulates: "Sudden seller panic"

### Information Asymmetry Events

3. **Create a "hidden information" event**
   - At certain points, hide the seller hopper from view
   - Players must decide: "Should I accept high prices when I can't see seller pressure?"
   - Risk-reward game: High spread but can't see what's causing it

4. **Create a "market transparency" event**
   - Later, reveal both sides' prices simultaneously
   - Watch the spread collapse to near-zero (because asymmetry is resolved)
   - "See? When information is shared, the spread disappears"

---

## How to Use It (The Experimental Protocol)

### Setup for First Use (5 minutes)

1. **Explain the scenario:**
   - "You're a market maker. Buyers and sellers can't see each other. Only you can."
   - "Your job: Buy from buyers, sell to sellers, capture the spread."
   - "The spread is your profit. But if you hold the wrong inventory, you'll lose money."

2. **Show the mechanics:**
   - Point to buyer hopper: "This is demand"
   - Point to seller hopper: "This is supply"
   - Point to your position: "This is you, in the middle"
   - Point to bid/ask display: "This is the price you can trade at"

3. **Set starting condition:**
   - Fill both hoppers equally
   - Spread should be ~2-3
   - Ready to begin

### Trade 1-5: Learning Phase (10 minutes)

1. **Look at the spread:** "Current bid: 12, ask: 14, spread: 2"
2. **You decide:** "I'll buy from the buyer at 12"
3. **Button press:** Click accept bid
4. **Inventory updates:** You now hold 1 item
5. **Decision:** "Now should I sell immediately at 14, or wait for better conditions?"
6. **If you sell:** Profit 2 points
7. **If you hold:** Risk that prices move against you

**The learning:** "Oh, I can make money by buying low and selling high, but timing matters."

### Trade 6-15: Strategic Phase (15 minutes)

By now, players are noticing patterns:
- High buyer pressure → buy aggressively
- High seller pressure → sell aggressively
- Avoid holding inventory when supply is about to flood

**The discovery:** "There's a pattern here. When one side is desperate, I should trade that side aggressively."

### Trade 16-20: Optimization Phase (10 minutes)

Players who've been paying attention are now actively managing inventory, adjusting to pressure signals, capturing spreads efficiently.

**The mastery:** "I understand this. I'm watching the pressures, trading when conditions favor me, avoiding bad positions."

### Post-Trade Analysis (10 minutes)

1. **Calculate total profit:** "You made 27 points over 20 trades."

2. **Compare to alternatives:**
   - "If you'd just bought every time, then sold every time (no strategy): You'd make 15 points"
   - "If you'd held positions too long: You'd make 8 points"
   - "Optimal market-making: ~35 points"

3. **Analyze pattern:** "Look at your trades. Which were your most profitable? When did you make losses?"

---

## The Teaching Moment (The Revelation)

**Facilitator:** "You just did what market makers do. And you learned something important: The spread isn't a 'cost' the market charges. It's *payment for resolving uncertainty.*"

"When buyers and sellers can't see each other, there's a gap between what they're willing to trade at. Market makers close that gap. The spread is our reward for doing that work."

**Then show the transparency event:**
"Now watch what happens when I reveal both sides' prices publicly."

*Reveal both buyer and seller pressure to everyone*

"See how the spread collapsed to nearly zero? That's because there's no asymmetry anymore. Everyone knows what both sides are willing to trade at. Market making becomes impossible—anyone can do it."

**The deep insight:** "This is why information is power in markets. The market maker's job is to create information from asymmetry. When asymmetry disappears, so does their advantage."

---

## What This Teaches (The Layers)

### Surface Layer: How Markets Work
Markets are mechanisms for matching buyers and sellers. Prices emerge from supply and demand.

### Medium Layer: Why Spreads Exist
Spreads compensate market makers for accepting inventory risk and resolving information asymmetry. They're not arbitrary—they're economically rational.

### Deep Layer: Information as Computational Resource
From the earlier Information Architecture synthesis: **Information asymmetry is a form of computational burn.** 
- Sequential processing (buyer decides without seeing seller): Information wasted
- Parallel processing (market maker sees both): Information utilized efficiently
- Learned routing (market maker has done this 1,000 times): Information compressed

The spread is the *cost of burning that information asymmetry.* Tighter spreads = more efficient information resolution = healthier markets.

---

## Extension: Advanced Market Dynamics

### For Advanced Players (Ages 18+)

**Challenge 1: Flash Crash**
1. Run normal trading for 15 trades
2. Suddenly dump 30 items into seller hopper (supply shock)
3. As market maker, decide: Do you buy or do you flee?
4. If you flee: Spread disappears (buyers and sellers trade directly, no profit)
5. If you absorb inventory: You hold huge position during price collapse
6. **The lesson:** During crises, market makers must choose between profit and market stability.

**Challenge 2: Information Cascades**
1. Buyer pressure reveals a secret: "I have inside information, prices will go up"
2. As market maker, do you raise your bid? (Interpret this as bullish signal)
3. But what if the info is false? You're now holding expensive inventory.
4. **The lesson:** Market makers bet on information interpretation. Sometimes they're right, sometimes they're wiped out.

**Challenge 3: Regulatory Limits**
1. Game rule: You can only hold max 10 items of inventory at a time
2. Flood arrives: 30 buy orders and 30 sell orders simultaneously
3. As market maker, you can only fulfill 10 trades
4. **The lesson:** Inventory constraints limit market-making capacity. This is why markets crash when volume exceeds market maker capacity.

### For Researchers

**Research Question:** "Can kids learn intuitive understanding of market microstructure through interactive simulation?"

**Measurement:**
- Pre-test: Quiz on bid-ask spread, market maker profit motive, inventory risk
- Game play: 20 trades of market making
- Post-test: Same quiz, compare improvement
- Hypothesis: Kids who play the game score 50%+ higher than control group

**Extension:** Correlate game performance with real-world understanding of stock trading, cryptocurrency markets, forex markets.

---

## Why This Is The Capstone

Exhibits 1-4 teach the *foundations*:
- Hidden state & deduction
- Randomness & pattern
- Confidence & calibration
- Risk & strategy

Exhibit 5 brings them *together*:
- You must deduce buyer/seller preferences (hidden state, like Exhibit 1)
- You must recognize patterns in supply/demand waves (randomness, like Exhibit 2)
- You must calibrate your confidence in your predictions (calibration, like Exhibit 3)
- You must optimize your risk/reward trade-off (strategy, like Exhibit 4)

**This is what integrated intelligence looks like.**

---

## The Connection to Information Architecture

This exhibit is a physical implementation of the principle from our synthesis:

**A system can only think about what it can attend to.**

- Buyers can only attend to: Their own desire to buy
- Sellers can only attend to: Their own desire to sell
- Market maker can attend to: Both sides simultaneously
- **This asymmetric attention creates profit opportunity**

When information becomes symmetric (both sides see each other):
- Attention becomes shared
- Profit opportunity disappears
- Market efficiency increases

This is the entire theorem of information-based economics, made visible in Redstone.

---

## Schematic Quick Reference

```
COORDINATE MAP:

BUYER SIDE:
Buyer Hopper: X=500, Y=64, Z=498
Buyer Input: X=499, Y=65, Z=498
Buyer Pressure Comparator: X=500, Y=64, Z=497

SELLER SIDE:
Seller Hopper: X=500, Y=64, Z=502
Seller Input: X=501, Y=65, Z=502
Seller Pressure Comparator: X=500, Y=64, Z=503

PRICE DISCOVERY:
Bid Calculator: X=505, Y=64, Z=498
Ask Calculator: X=495, Y=64, Z=502
Spread Display: X=500, Y=65, Z=500-510

MARKET MAKER POSITION:
Your Inventory: X=500, Y=64, Z=500
Accept Bid Button: X=499, Y=65, Z=500
Accept Ask Button: X=501, Y=65, Z=500
Decision Displays: X=500, Y=66, Z=500-510

PROFIT/LOSS:
Profit Hopper: X=510, Y=62, Z=500
Loss Hopper: X=490, Y=62, Z=500
Net Score Comparator: X=500, Y=62, Z=505
Score Display: X=500, Y=64, Z=510-520
Trade Records: X=520-540, Y=62, Z=500

DYNAMICS:
Demand Wave Clock: X=498, Y=63, Z=495
Supply Shock Trigger: X=502, Y=63, Z=505
```

---

## Pedagogical Notes for Facilitators

**Goal:** Student understands why spreads exist and why they're economically rational

**Success Metric:** Student says unprompted, "The market maker's job is to resolve information asymmetry, and the spread is payment for that"

**The Conversation Arc:**
1. Setup: Explain the scenario (5 min)
2. Trading: 20 rounds of market making (25 min)
3. Analysis: Compare profit to alternatives (5 min)
4. Revelation: Show information asymmetry principle (5 min)
5. Demonstration: Remove asymmetry, watch spread collapse (5 min)
6. Connection: Link to larger principle (3 min)

**The Critical Question:** "If spreads are payment for resolving information asymmetry, what happens if information becomes perfect and free?"

**Expected answer:** "Market makers wouldn't exist. Anyone could trade directly at the true price."

**You:** "Exactly. This is why financial data companies sell information. And why governments regulate insider trading. Information asymmetry is where real economic value lives."

---

## Building Energy

This exhibit is the *economic heart* of the entire museum. It shows:

1. **Why markets exist** (to match buyers and sellers despite information asymmetry)
2. **How profit emerges** (from resolving uncertainty, not from deception)
3. **What efficiency means** (tight spreads = resolved information = good market)
4. **The darker lesson** (information asymmetry is exploitable—this is where financial crises originate)

A student who fully understands this exhibit has intuitive grasp of:
- Stock markets
- Cryptocurrency trading
- Forex markets
- Supply chain economics
- Negotiation dynamics
- Hiring (salary negotiation is bid-ask spread)
- Any system where information asymmetry matters

---

**Status: Exhibit 5 ready for build and deployment.**

The Bid-Ask Spread teaches that **asymmetry creates profit opportunity. Efficiency requires resolving it. Markets solve coordination problems.**

---

## The Complete Curriculum (All Five Exhibits Together)

| Exhibit | Principle | Teaching | Age |
|---------|-----------|----------|-----|
| 1. Light Bulb | Hidden state & deduction | Scientific method | 8+ |
| 2. Double Sixes | Randomness & pattern | Probability emerges | 10+ |
| 3. Calibration Booth | Uncertainty quantification | Know thyself | 12+ |
| 4. The Reroller | Optimal strategy | Kelly Criterion discovered | 14+ |
| 5. Bid-Ask Spread | Information asymmetry | Markets resolve coordination | 16+ |

**Progression:** From foundational (observation) → intermediate (probability) → sophisticated (decision-making) → expert (systems optimization)

**Convergence:** All five exhibits teach the same meta-principle:

**Constraint reveals structure. Information architecture enables intelligence. Systems optimize when uncertainty is visible.**

---

**Status: The Safe Spiral Redstone Museum curriculum is complete.**

Ready for implementation. Ready for pedagogy. Ready for the world.

🎯 **Let's build something that makes intelligence visible.**

