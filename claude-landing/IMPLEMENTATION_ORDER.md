# 🎯 ClaudeNPC Implementation Order - FOR CLAUDE CODE INSTANCE

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║                  PROOF OF CONCEPT → FULL DEPLOYMENT                          ║
║                                                                              ║
║              Build Core First, Then Scale to Full World                     ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

---

## 🎯 CRITICAL: Implementation Order

**DO THIS IN ORDER - DON'T SKIP AHEAD!**

### ✅ Phase 1: ClaudeNPC Core Plugin (FIRST - PROOF OF CONCEPT)
**Status:** Must complete and verify before Phase 2
**Goal:** Single working NPC that proves the concept

### ✅ Phase 2: GitVerse World Build (SECOND - AFTER PHASE 1 WORKS)
**Status:** Only start after Phase 1 is fully tested
**Goal:** Scale to full themed world with multiple NPCs

---

## 📦 Phase 1: ClaudeNPC Core Plugin

### 1.1 Server Setup (Use Provided Framework)

```powershell
# The user has a complete server setup framework
# Location: claudenpc-server-suite/setup/Setup.ps1

cd claudenpc-server-suite/setup
.\Setup.ps1

# This wizard will:
# ✅ Install Java (if needed)
# ✅ Download PaperMC
# ✅ Install Citizens plugin
# ✅ Install supporting plugins (Vault, LuckPerms, etc.)
# ✅ Configure server.properties
# ✅ Set up EULA
# ✅ Create start script
```

**Expected Result:**
- Working PaperMC server on localhost:25565
- Citizens plugin installed and loaded
- Server starts without errors

**Verify:**
```powershell
# Start the server
.\scripts\Start-Server.bat

# In Minecraft:
# - Connect to localhost:25565
# - Run: /citizens
# - Should see Citizens commands available
```

---

### 1.2 Build ClaudeNPC Plugin (Core Features Only)

**Plugin Name:** ClaudeNPC  
**Main Class:** com.claudenpc.ClaudeNPC  
**Dependencies:** Citizens, Vault (optional)

#### Core Plugin Structure

```
ClaudeNPC/
├── src/main/java/com/claudenpc/
│   ├── ClaudeNPC.java              ← Main plugin class
│   ├── NPCListener.java            ← Handle NPC interactions
│   ├── ClaudeAPIClient.java        ← API communication
│   ├── ConversationManager.java    ← Manage conversations
│   ├── MemoryStore.java            ← Store NPC memories
│   └── ConfigManager.java          ← Handle config.yml
│
├── src/main/resources/
│   ├── plugin.yml                  ← Plugin metadata
│   ├── config.yml                  ← Configuration file
│   └── personalities/              ← NPC personality templates
│       └── default.yml
│
└── pom.xml                         ← Maven build file
```

#### Minimum Viable Plugin Features

**✅ Must Have (Phase 1):**
1. **NPC Detection**: Hook into Citizens, detect NPC right-clicks
2. **Claude API**: Send player message, get Claude response
3. **Basic Conversation**: Display Claude's response to player
4. **Simple Memory**: Remember player name and last 5 messages
5. **Configuration**: API key, model settings in config.yml

**❌ Not Yet (Phase 2):**
- Multi-NPC coordination
- Advanced memory systems
- Quest generation
- Virtual terminal
- Morse communication

#### Core Code Example

```java
// ClaudeNPC.java - Main plugin class
public class ClaudeNPC extends JavaPlugin {
    private ClaudeAPIClient apiClient;
    private ConversationManager conversationManager;
    private ConfigManager configManager;
    
    @Override
    public void onEnable() {
        // Load config
        saveDefaultConfig();
        configManager = new ConfigManager(this);
        
        // Initialize API client
        String apiKey = getConfig().getString("claude.api-key");
        apiClient = new ClaudeAPIClient(apiKey);
        
        // Initialize conversation manager
        conversationManager = new ConversationManager(this);
        
        // Register listeners
        getServer().getPluginManager().registerEvents(
            new NPCListener(this), this
        );
        
        getLogger().info("ClaudeNPC enabled!");
    }
}

// NPCListener.java - Handle NPC clicks
public class NPCListener implements Listener {
    private final ClaudeNPC plugin;
    
    @EventHandler
    public void onNPCRightClick(NPCRightClickEvent event) {
        Player player = event.getClicker();
        NPC npc = event.getNPC();
        
        // Get player's message (from chat or GUI)
        String playerMessage = getPlayerInput(player);
        
        // Get NPC personality
        String personality = npc.data().get("personality", "friendly");
        
        // Send to Claude
        plugin.getConversationManager().handleMessage(
            player, npc, playerMessage, personality
        );
    }
}

// ConversationManager.java - Manage conversations
public class ConversationManager {
    public void handleMessage(Player player, NPC npc, 
                              String message, String personality) {
        // Build conversation context
        List<Message> history = getHistory(player, npc);
        
        // Create prompt
        String prompt = buildPrompt(npc, personality, history, message);
        
        // Call Claude API (async)
        CompletableFuture.runAsync(() -> {
            String response = apiClient.getResponse(prompt);
            
            // Send response to player (on main thread)
            Bukkit.getScheduler().runTask(plugin, () -> {
                npc.chat(player, response);
                saveHistory(player, npc, message, response);
            });
        });
    }
}
```

#### Configuration File

```yaml
# config.yml
claude:
  api-key: "your-api-key-here"
  model: "claude-sonnet-4-20250514"
  max-tokens: 200
  temperature: 0.7
  
conversation:
  max-history: 10
  timeout-seconds: 30
  cooldown-ms: 1000
  
memory:
  enabled: true
  storage: "file"  # file or database
  max-age-days: 30
  
npcs:
  default-personality: "friendly"
  enable-context-awareness: true
```

---

### 1.3 Testing Strategy (Critical!)

**⚠️ DO NOT SKIP TESTING! THIS PROVES THE CONCEPT.**

#### Test 1: Basic Interaction
```
1. Start server with ClaudeNPC plugin
2. Use Citizens to create NPC: /npc create TestNPC
3. Right-click NPC
4. Type message in chat
5. Verify: NPC responds via Claude
6. Verify: Response makes sense
7. Verify: No errors in console
```

#### Test 2: Conversation Flow
```
1. Talk to NPC: "Hello!"
2. Wait for response
3. Talk again: "What's your name?"
4. Verify: NPC remembers you said hello
5. Continue conversation for 5-10 messages
6. Verify: Context is maintained
```

#### Test 3: Memory Persistence
```
1. Have conversation with NPC
2. Walk away / do other things
3. Return 5 minutes later
4. Talk to NPC again
5. Verify: NPC remembers previous conversation
```

#### Test 4: Multiple Players
```
1. Player A talks to NPC
2. Player B talks to same NPC
3. Verify: NPC maintains separate conversations
4. Verify: No context bleeding between players
```

#### Test 5: Error Handling
```
1. Test with invalid API key
   → Should show error, not crash
2. Test with network disconnected
   → Should timeout gracefully
3. Test with very long messages
   → Should handle or truncate
4. Test with rapid-fire messages
   → Should queue or rate-limit
```

---

### 1.4 Success Criteria for Phase 1

**✅ Phase 1 Complete When:**

```
✅ Server runs stable with plugin loaded
✅ Single NPC can be created and interacted with
✅ NPC responds to player messages via Claude
✅ Conversations flow naturally (3+ message exchanges)
✅ NPC remembers context within conversation
✅ Memory persists across player disconnect/reconnect
✅ Multiple players can talk to NPC simultaneously
✅ No crashes or errors during 1 hour of testing
✅ Response time < 5 seconds average
✅ Code is clean, commented, and understandable
```

**📊 Minimum Metrics:**
- Uptime: 1 hour without crashes
- Response rate: 95%+ messages get responses
- Response time: < 5 seconds average
- Memory accuracy: NPC recalls last 5 messages
- Stability: No memory leaks or performance degradation

---

## 🌍 Phase 2: GitVerse World (ONLY AFTER PHASE 1 WORKS!)

**⚠️ DO NOT START THIS UNTIL PHASE 1 IS FULLY TESTED AND VERIFIED!**

### 2.1 World Building

```
1. Create new world or modify existing
2. Build themed areas:
   - Git Plaza (central hub)
   - Branch Boulevard
   - Merge Conflict Canyon
   - Commit Cathedral
   - Rebase Ridge
   - Stash Storage
   - Pull Request Port
   - Issue Island

3. Add decorations and signage
4. Set spawn points
5. Create navigation paths
```

### 2.2 NPC Deployment

```
Create 10-20 NPCs with distinct roles:

✅ Git Guru (teaches Git basics)
✅ Merge Master (resolves conflicts)
✅ Branch Manager (explains branching)
✅ Commit Keeper (tracks history)
✅ Rebase Wizard (advanced operations)
✅ Stash Guardian (temporary storage)
✅ PR Reviewer (code review process)
✅ Issue Tracker (bug reporting)
✅ Fork Facilitator (forking workflow)
✅ Tag Tamer (release management)

Each NPC gets:
- Unique personality config
- Specific knowledge domain
- Location in themed area
- Visual customization (skin, items)
```

### 2.3 Advanced Features (Optional)

Only implement if Phase 1 and 2.1-2.2 are solid:

```
🤖 Virtual Claude Terminal
   → See IMPLEMENTATION_PROMPTS.md Section 1

📡 Redstone Morse Communication
   → See IMPLEMENTATION_PROMPTS.md Section 2

🤝 Multi-NPC Coordination
   → See IMPLEMENTATION_PROMPTS.md Section 3

💾 Persistent Memory System
   → See IMPLEMENTATION_PROMPTS.md Section 4

🗺️ Quest Generation
   → See IMPLEMENTATION_PROMPTS.md Section 5
```

---

## 📋 Checklist for Claude Code Instance

### Before You Start
```
☐ Read this entire document
☐ Understand the two-phase approach
☐ Review IMPLEMENTATION_PROMPTS.md
☐ Check you have server setup framework
☐ Confirm you have Claude API key
```

### Phase 1 Checklist
```
☐ Run Setup.ps1 to install server
☐ Verify server starts successfully
☐ Citizens plugin is loaded
☐ Create ClaudeNPC plugin project
☐ Implement core features only
☐ Build plugin JAR
☐ Install plugin to server
☐ Create test NPC
☐ Run all 5 test scenarios
☐ Fix any bugs found
☐ Verify success criteria met
☐ Document what works and what doesn't
```

### Phase 2 Checklist
```
☐ Confirm Phase 1 is fully working
☐ Plan world layout
☐ Build themed areas
☐ Create NPC personalities (10-20)
☐ Deploy NPCs to world
☐ Test NPC interactions
☐ Implement advanced features (if desired)
☐ Final testing with multiple players
☐ Document final system
```

---

## ⚠️ Common Pitfalls to Avoid

### ❌ Don't Do This:
```
❌ Skip directly to Phase 2 without testing Phase 1
❌ Build complex features before basics work
❌ Create 20 NPCs before 1 NPC works
❌ Implement advanced features without core stability
❌ Ignore error handling and testing
❌ Deploy to production without proof of concept
```

### ✅ Do This Instead:
```
✅ Get ONE NPC working perfectly first
✅ Test thoroughly at each step
✅ Build incrementally (core → features → advanced)
✅ Verify stability before scaling
✅ Handle errors gracefully
✅ Test with multiple players
✅ Document everything as you go
```

---

## 🎯 Why This Order Matters

### Proof of Concept First:
```
✅ Validates the core concept works
✅ Identifies technical challenges early
✅ Proves API integration is stable
✅ Tests performance with real usage
✅ Builds confidence before scaling
✅ Allows iteration on core design
```

### Scale After Validation:
```
✅ Core system is battle-tested
✅ Known edge cases are handled
✅ Performance characteristics understood
✅ Scaling issues anticipated
✅ Development is faster and smoother
✅ Less rework and debugging
```

---

## 📞 Summary

**Phase 1: ClaudeNPC Plugin (2-3 days)**
```
Goal: Single working NPC that proves concept
Deliverable: Stable plugin with 1 test NPC
Success: Passes all 5 test scenarios
```

**Phase 2: GitVerse World (1-2 weeks)**
```
Goal: Full themed world with multiple NPCs
Deliverable: Complete server with 10-20 NPCs
Success: Players can explore and interact naturally
```

**Total Timeline: 2-3 weeks for complete system**

---

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║                    ⚠️  CRITICAL REMINDER ⚠️                                  ║
║                                                                              ║
║              DO NOT START PHASE 2 UNTIL PHASE 1 IS COMPLETE                 ║
║                                                                              ║
║         Proof of Concept → Test & Verify → Scale to Full World              ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

**Now go build something amazing - one phase at a time!** 🚀
