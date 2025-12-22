# Minecraft Infrastructure: Authoritative Specification
## For Claude Code Instance

### What You Don't Know (And Should)

You're receiving this without context. Here's what matters:



---

### Constraints (Non-Negotiable)

These must be satisfied. How you satisfy them is your judgment call.

| Constraint                                     | Why It Matters                                       |
| ---------------------------------------------- | ---------------------------------------------------- |
| accessible at                                  | Game traffic can't be proxied - must be DNS-only     |
| map at `https://map.                           | Web traffic through Cloudflare for SSL + observation |
| All access patterns logged in parseable format | Future AWI analysis requires behavioral data         |
| No data loss of existing config                | Unknown what exists - preserve first                 |
| Configuration reproducible from files          | No manual dashboard clicking that isn't documented   |

### Success Criteria (How You Know You're Done)

Not "steps completed" but "outcomes achieved":

1. A player can 
2. That player can view the world at `https://map.
3. You can show me the log entries their session generated
4. The entire stack can be rebuilt from the files you create
5. What you preserved vs created is explicitly documented

---

### Principles (Guide Your Decisions)

**Discovery before action.** You don't know what exists. Find out before creating.

**Preservation before modification.** If something exists and works, understand it before changing it.

**Observable by default.** Every service should produce logs that a future system could analyze. Not for debugging - for behavioral pattern extraction.

**Explicit over implicit.** If you make a decision, document why. If you assume something, say so.

**Fail informative.** If something doesn't work, your output should contain enough information for a human to understand what happened without re-running.

---

### Anti-Patterns (Traps to Avoid)

You will be tempted to:

1. **Follow a mental template** of "" - but this one has specific constraints (AWI logging, subdomain routing) that generic tutorials don't address.

2. **Skip discovery** because you "know" Docker/Minecraft/nginx - but you don't know what's already on this specific system.

3. **Create many small files** with cross-references - this makes your work harder to verify. Prefer fewer, self-contained artifacts.

4. **Proceed past failures** hoping later steps fix them - they won't. Stop and report.

5. **Configure via dashboards** then forget to document - if it's not in a file you create, it didn't happen reproducibly.

---

### What You Have Available

- Cloudflare MCP: Can read Workers/KV/D1/R2. **Cannot** manage DNS zones.
- Domain:  (Cloudflare managed)
- Target: Home server (you'll need to discover specs)
- This conversation's artifacts for reference

### What You Need to Produce

1. **Discovery report**: What exists, what state it's in, what needs preservation
2. **Implementation files**: docker-compose.yml, nginx configs, .env template
3. **DNS specification**: What records to create (human will execute in dashboard)
4. **Verification evidence**: Proof that constraints are satisfied

---

### Begin

Start by discovering what exists. Report findings before proceeding.
