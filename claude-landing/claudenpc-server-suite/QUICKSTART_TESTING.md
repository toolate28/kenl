# QuickStart: Testing ClaudeNPC Plugin

**Time Required:** 30-60 minutes
**Goal:** Verify Phase 1 plugin works end-to-end

---

## Prerequisites Checklist

- [ ] Java 21+ installed (you have Java 25.0.1 ✅)
- [ ] Minecraft Java Edition client
- [ ] Claude API key from https://console.anthropic.com/
- [ ] 30 minutes of free time

---

## Step-by-Step Testing Guide

### Step 1: Install Minecraft Server (10 minutes)

**Option A: Automated (Recommended)**

```powershell
# Navigate to setup directory
cd setup

# Run automated installer
.\Setup.ps1

# Follow prompts:
# - Server path: C:\MinecraftServer (or your preference)
# - Accept EULA: Yes
# - Install profile: Standard (includes Citizens)
# - Memory: 4GB min, 8GB max (or adjust for your system)
```

**Option B: Manual**

```powershell
# Create server directory
mkdir C:\MinecraftServer
cd C:\MinecraftServer

# Download PaperMC (latest 1.21.3)
# Visit: https://papermc.io/downloads/paper
# Download jar to C:\MinecraftServer\paper.jar

# Accept EULA
echo "eula=true" > eula.txt

# Download Citizens plugin
# Visit: https://ci.citizensnpcs.co/job/Citizens2/
# Download Citizens.jar to C:\MinecraftServer\plugins\

# First run to generate files
java -Xms4G -Xmx8G -jar paper.jar --nogui
# Wait for "Done" message, then stop: type "stop"
```

---

### Step 2: Deploy ClaudeNPC Plugin (2 minutes)

```powershell
# Copy built plugin to server
copy ClaudeNPC\target\ClaudeNPC.jar C:\MinecraftServer\plugins\

# Verify it's there
dir C:\MinecraftServer\plugins\
# Should see: Citizens.jar, ClaudeNPC.jar
```

---

### Step 3: Configure API Key (1 minute)

```powershell
# Open config file
notepad C:\MinecraftServer\plugins\ClaudeNPC\config.yml

# Edit line 8 to add your API key:
api-key: "sk-ant-api03-YOUR-KEY-HERE"

# Save and close
```

**Getting your API key:**
1. Go to https://console.anthropic.com/
2. Click "API Keys"
3. Create new key or copy existing
4. Paste into config.yml

---

### Step 4: Start Server (2 minutes)

```powershell
# Navigate to server directory
cd C:\MinecraftServer

# Start server
java -Xms4G -Xmx8G -jar paper.jar --nogui

# Watch console for:
# [ClaudeNPC] ClaudeNPC v1.0.0 enabled!
# [ClaudeNPC] Model: claude-3-5-haiku-20241022
# [ClaudeNPC] Memory size: 5 messages

# Wait for "Done" message
```

**Troubleshooting:**
- Error: "Citizens plugin not found!" → Install Citizens first
- Warning: "API key not set" → Check config.yml
- Error: Java version mismatch → You need Java 21+

---

### Step 5: Join Server & Create Test NPC (5 minutes)

**In Minecraft Client:**

```
1. Click "Multiplayer"
2. Click "Add Server"
3. Server Address: localhost
4. Click "Done"
5. Click server to join
```

**In-Game Commands:**

```
# Give yourself op permissions
/op YourMinecraftUsername

# Create a test NPC
/npc create TestNPC

# Enable Claude integration for this NPC
/npc data set claudenpc.enabled true

# (Optional) Set custom personality
/npc data set claudenpc.personality "You are a friendly wizard who loves teaching about magic and code."

# Verify setup
/claudenpc status
```

Expected output:
```
ClaudeNPC Status:
Version: 1.0.0
Model: claude-3-5-haiku-20241022
Memory Size: 5 messages
API Key: Configured ✓
```

---

### Step 6: Test Conversation (5 minutes)

**Basic Interaction:**
1. Right-click the NPC
2. You should see: "[You are now talking to TestNPC. Type your message in chat!]"
3. Type in chat: "Hello! Who are you?"
4. NPC should respond via Claude API
5. Continue conversation (try 5-10 messages)

**Test Scenarios:**

**Test 1: Context Memory**
```
You: "My name is Alex and I love coding."
NPC: [responds]
You: "What's my name?"
NPC: [should remember "Alex"]
```

**Test 2: Conversation Flow**
```
You: "Tell me about Minecraft modding"
NPC: [responds about modding]
You: "Can you give me an example?"
NPC: [should provide example related to previous response]
```

**Test 3: Exit**
```
You: "bye"
System: [Conversation ended with TestNPC]
```

**Test 4: Error Handling**
```
# Stop server (in console: "stop")
# Restart server
# Join again and talk to NPC
# Verify conversation memory is cleared
```

---

### Step 7: Multi-Player Test (Optional - 10 minutes)

**If you have a second account:**
1. Join with Player 1, start talking to NPC
2. Join with Player 2, start talking to SAME NPC
3. Verify each player has separate conversation
4. Player 1's messages shouldn't affect Player 2's context

---

### Step 8: Performance Test (10 minutes)

**Monitor Response Times:**
```
# In conversation, note response time
# Should be < 5 seconds average

# Send 20 messages and track:
# - Average response time
# - Any failures
# - Server lag
```

**Check Server Console:**
```
# Look for errors
# Check memory usage (should be stable)
# Verify no exceptions
```

**Use Admin Commands:**
```
/claudenpc status    # Check plugin health
/claudenpc reload    # Test config reload
```

---

## Phase 1 Test Checklist

From `bump.md` Phase 1 success criteria:

### Technical Criteria
- [ ] Minecraft server runs stable on localhost:25565
- [ ] Single NPC responds to player messages via Claude API
- [ ] Conversations flow naturally (3+ message exchanges)
- [ ] NPC remembers context within conversation
- [ ] Memory persists across player disconnect/reconnect (KNOWN: Currently clears on disconnect)
- [ ] Multiple players can talk to NPC simultaneously (separate conversations)
- [ ] No crashes during 1 hour of continuous testing
- [ ] Response time < 5 seconds average
- [ ] Code is clean, commented, and understandable (verified ✅)

### Verification Tests
```bash
# Server stability test
Run server for 1 hour, monitor console for errors

# Conversation test
Have 5-10 message exchange, verify context maintained

# Memory test
Disconnect, reconnect after 5 minutes, verify NPC remembers
(NOTE: Current implementation clears on disconnect - acceptable for Phase 1)

# Multi-player test
Two clients simultaneously, verify no context bleeding

# Performance test
Measure response times across 20+ messages
```

---

## Expected Results

### ✅ Success Looks Like:
- Server starts without errors
- ClaudeNPC plugin loads successfully
- NPC responds to messages via Claude
- Conversations feel natural and coherent
- Context maintained within session
- No server crashes
- Response times reasonable (< 5 sec)

### ❌ Failure Cases & Fixes:

**NPC doesn't respond:**
- Check API key configured correctly
- Check console for API errors (401 = bad key, 429 = rate limit)
- Run `/claudenpc status` to verify setup

**Responses are nonsensical:**
- Memory might be too small (increase in config.yml)
- Check NPC personality prompt
- Verify model is correct (haiku vs sonnet)

**Server crashes:**
- Check Java version (need 21+)
- Increase server memory allocation
- Check console logs for stack traces

**Slow responses (>10 seconds):**
- Network latency to Claude API
- Try different model (haiku is faster)
- Check rate limiting settings

---

## Collecting Test Evidence

**For documentation, capture:**

1. **Screenshots:**
   - NPC creation
   - First conversation
   - `/claudenpc status` output
   - Server console showing plugin loaded

2. **Logs:**
   - Server console output
   - ClaudeNPC plugin logs
   - Any error messages

3. **Metrics:**
   - Response time measurements
   - Message count
   - Uptime duration

4. **Issues Found:**
   - Document any bugs
   - Note unexpected behavior
   - Suggest improvements

---

## After Testing

### If Tests Pass ✅

**Document results:**
1. Update `bump.md` with test results
2. Mark Phase 1 as "TESTED AND VERIFIED"
3. Create test report document
4. Increment SAIF counter (5 → 6)

**Next steps:**
- Review Phase 2 roadmap
- Decide: continue to Phase 2 or refine Phase 1?
- Consider deploying to external server

### If Tests Fail ❌

**Debug process:**
1. Document exact failure (screenshots, logs)
2. Identify root cause
3. Create issue in git (or document in KNOWN_ISSUES.md)
4. Fix and retest
5. DO NOT proceed to Phase 2 until Phase 1 passes

---

## Common Issues & Solutions

### Issue: "Citizens plugin not found!"
**Solution:** Install Citizens plugin first
```powershell
# Download from: https://ci.citizensnpcs.co/job/Citizens2/
# Place in plugins/ folder
# Restart server
```

### Issue: "API key not configured"
**Solution:** Add API key to config.yml
```yaml
claude:
  api-key: "sk-ant-api03-YOUR-KEY-HERE"
```

### Issue: NPC created but not responding
**Solution:** Enable Claude integration
```
/npc data set claudenpc.enabled true
```

### Issue: "API error: 401"
**Solution:** Invalid API key
- Verify key from https://console.anthropic.com/
- Check for copy/paste errors
- Ensure no extra spaces

### Issue: "API error: 429"
**Solution:** Rate limit exceeded
- Wait a few minutes
- Check your Anthropic usage
- Consider upgrading API tier

### Issue: Server won't start
**Solution:** Check Java version
```powershell
java -version
# Should show 21 or higher
```

---

## Quick Reference

### Useful Commands

```bash
# Server Management
/stop                   # Stop server gracefully

# NPC Management
/npc create <name>      # Create NPC
/npc select             # Select nearby NPC
/npc remove             # Remove selected NPC

# ClaudeNPC Commands
/claudenpc status       # Show plugin status
/claudenpc reload       # Reload configuration

# NPC Data
/npc data set claudenpc.enabled true
/npc data set claudenpc.personality "Your custom prompt"
```

### Config Locations

```
C:\MinecraftServer\
├── plugins\
│   ├── ClaudeNPC.jar
│   ├── Citizens.jar
│   └── ClaudeNPC\
│       └── config.yml          ← Edit API key here
├── paper.jar
└── start.bat                   ← Create for easy startup
```

### Performance Tips

```yaml
# In config.yml, optimize for testing:
npc:
  memory-size: 3              # Smaller = faster, less context
claude:
  model: "claude-3-5-haiku-20241022"  # Fastest model
  max-tokens: 512             # Shorter responses
  timeout: 20                 # Quicker timeout
```

---

## Support & Resources

**Documentation:**
- `DEVELOPMENT_LOG.md` - Implementation details
- `bump.md` - Phase 1 requirements
- `PROJECT_STATE.md` - Project overview

**Getting Help:**
- Check server console for errors
- Review Claude API docs: https://docs.anthropic.com/
- Check Citizens wiki: https://wiki.citizensnpcs.co/

**Reporting Issues:**
- Document exact steps to reproduce
- Include server logs
- Note Java version, OS, plugin versions
- Create issue in git repository

---

**Time to test:** ~30-60 minutes
**Difficulty:** Beginner-friendly
**Blockers:** Need Minecraft client + Claude API key

**Good luck! 🚀**

---

**ATOM:** ATOM-TEST-20251228-001
**Version:** 1.0
**Created:** 2025-12-28
