# Getting Started with ClaudeNPC

**Your AI-Powered Minecraft NPCs in 15 Minutes**

Welcome! ClaudeNPC transforms Minecraft into an interactive AI experience where NPCs have real conversations, remember context, and help players learn.

---

## What is ClaudeNPC?

ClaudeNPC is a Minecraft server plugin that creates AI-powered NPCs using Claude (Anthropic's AI). Unlike traditional NPCs with scripted responses, ClaudeNPC NPCs:

- **Understand natural language** - Talk to them like real people
- **Remember conversations** - Context persists across interactions
- **Adapt their personality** - Configure each NPC's role and behavior
- **Support multiplayer** - Isolated conversations per player
- **Work async** - No server lag while AI thinks

**Current Status**:
- ✅ **Phase 1**: Single NPC system (complete, ready for testing)
- 📋 **Phase 2**: GitVerse multi-NPC world generation (planned)

---

## Prerequisites

Before starting, ensure you have:

### Required
- ✅ **Minecraft Server** (Java Edition, version 1.16+)
- ✅ **Java 17+** installed
- ✅ **Claude API Key** ([Get one here](https://console.anthropic.com/))
- ✅ **Basic command-line knowledge** (copy, paste, run commands)

### Optional but Recommended
- ⭐ **Maven** (for building from source)
- ⭐ **Git** (for version control)
- ⭐ **VSCode** or similar editor (for config editing)

---

## Installation Guide

### Option 1: Quick Start (Pre-Built JAR)

**Step 1: Download the Plugin**
```bash
# Navigate to your Minecraft server's plugins folder
cd /path/to/minecraft/server/plugins

# Download the latest ClaudeNPC JAR
# (Replace with actual download link once available)
wget https://github.com/your-repo/claudenpc/releases/latest/ClaudeNPC.jar
```

**Step 2: Get Your Claude API Key**

1. Visit [Anthropic Console](https://console.anthropic.com/)
2. Sign up or log in
3. Navigate to **API Keys**
4. Create a new key (name it "ClaudeNPC-Production")
5. Copy the key (starts with `sk-ant-...`)

**Step 3: Configure the Plugin**

```bash
# Start your server once to generate config files
java -jar server.jar

# Stop the server after configs are created
# Edit the ClaudeNPC configuration
nano plugins/ClaudeNPC/config.yml
```

**Basic `config.yml`**:
```yaml
# ClaudeNPC Configuration
api:
  key: "sk-ant-your-api-key-here"  # Replace with your actual key
  model: "claude-sonnet-4-5-20250929"  # Best balance of speed and quality
  max-tokens: 150  # Response length limit

npc:
  default-personality: |
    You are a helpful village guide in a Minecraft world.
    Be friendly, concise, and helpful.
    You can answer questions about the village and game mechanics.

  memory:
    enabled: true
    max-messages: 10  # Remember last 10 messages per player

performance:
  rate-limit:
    enabled: true
    max-requests-per-minute: 20  # Prevent API abuse

  timeout: 10  # Seconds before request times out

logging:
  level: INFO  # Change to DEBUG for troubleshooting
```

**Step 4: Start Your Server**
```bash
java -Xmx2G -Xms1G -jar server.jar nogui
```

**Step 5: Create Your First NPC**

In-game, run:
```
/claudenpc create GuideNPC
```

Right-click the NPC and say "Hello!" - your first AI conversation!

---

### Option 2: Build from Source (Developers)

**Step 1: Clone the Repository**
```bash
git clone https://github.com/your-repo/claudenpc-server-suite.git
cd claudenpc-server-suite
```

**Step 2: Build with Maven**
```bash
# Clean build
mvn clean package

# The JAR will be in target/ClaudeNPC-1.0.0.jar
cp target/ClaudeNPC-*.jar /path/to/server/plugins/
```

**Step 3: Follow steps 2-5 from Option 1 above**

---

## Your First AI Conversation

### Creating an NPC

**Basic NPC**:
```
/claudenpc create <name>
```

**NPC with Custom Personality**:
```
/claudenpc create Librarian --personality "You are a wise librarian who loves books and history. Speak in an old-fashioned, scholarly way."
```

**NPC at Specific Location**:
```
/claudenpc create ShopKeeper --location ~ ~ ~ --personality "You run the village shop. Be helpful but businesslike."
```

### Talking to NPCs

1. **Right-click** the NPC to start a conversation
2. **Type your message** in chat
3. **Wait a moment** - the NPC will respond (usually 1-3 seconds)
4. **Continue the conversation** - context is remembered!

**Example Conversation**:
```
Player: Hello! What's your name?
NPC: Greetings! I'm Eldrin, the village librarian. How may I assist you today?

Player: What books do you recommend?
NPC: Ah, a fellow book lover! I'd recommend our collection on Minecraft enchantments. Very practical knowledge.

Player: Tell me about enchantments
NPC: Enchantments enhance your tools and armor. For instance, Sharpness increases sword damage, while Unbreaking makes items last longer. Would you like to know about a specific enchantment?
```

### NPC Commands Reference

| Command | Description | Permission |
|---------|-------------|------------|
| `/claudenpc create <name>` | Create a new NPC | `claudenpc.admin` |
| `/claudenpc remove <name>` | Remove an NPC | `claudenpc.admin` |
| `/claudenpc list` | List all NPCs | `claudenpc.user` |
| `/claudenpc reload` | Reload configuration | `claudenpc.admin` |
| `/claudenpc setpersonality <name> <text>` | Update NPC personality | `claudenpc.admin` |
| `/claudenpc clearmemory <name> [player]` | Clear conversation memory | `claudenpc.admin` |
| `/claudenpc stats` | View API usage statistics | `claudenpc.admin` |

---

## Configuration Deep Dive

### API Settings

```yaml
api:
  key: "sk-ant-..."
  model: "claude-sonnet-4-5-20250929"  # Options below
  max-tokens: 150  # 50-500 recommended
  temperature: 0.7  # 0.0 (deterministic) to 1.0 (creative)
```

**Model Comparison**:

| Model | Speed | Quality | Cost | Best For |
|-------|-------|---------|------|----------|
| **claude-haiku-3-5** | ⚡⚡⚡ | ⭐⭐ | $ | Simple NPCs, high traffic |
| **claude-sonnet-4-5** | ⚡⚡ | ⭐⭐⭐⭐ | $$ | General purpose (recommended) |
| **claude-opus-4-5** | ⚡ | ⭐⭐⭐⭐⭐ | $$$ | Complex storytelling NPCs |

### Personality Examples

**Village Guide**:
```yaml
personality: |
  You are Marcus, a friendly village guide.
  Help players find buildings, resources, and answer questions about the village.
  Be warm and welcoming. Use simple, clear language.
```

**Quest Giver**:
```yaml
personality: |
  You are Thalira, a mysterious quest giver.
  Offer challenging quests and speak in riddles occasionally.
  Be enigmatic but helpful. Reward brave adventurers.
```

**Merchant**:
```yaml
personality: |
  You are Grog, a gruff but fair merchant.
  Talk about trades, prices, and rare items.
  Be businesslike but with a sense of humor.
```

**Lore Master**:
```yaml
personality: |
  You are Eldrin, keeper of ancient knowledge.
  Share stories about the world's history and legends.
  Speak in an old-fashioned, scholarly manner.
```

### Performance Tuning

**High-Traffic Server** (50+ players):
```yaml
performance:
  rate-limit:
    max-requests-per-minute: 30
    per-player-cooldown: 5  # Seconds between messages

api:
  model: "claude-haiku-3-5"  # Faster, cheaper
  max-tokens: 100  # Shorter responses
```

**Small Server** (< 10 players):
```yaml
performance:
  rate-limit:
    max-requests-per-minute: 60
    per-player-cooldown: 2

api:
  model: "claude-sonnet-4-5"  # Better quality
  max-tokens: 200  # Longer responses
```

---

## Advanced Features

### Memory System

NPCs remember conversations:

```yaml
npc:
  memory:
    enabled: true
    max-messages: 10  # Last 10 messages
    persist-to-disk: true  # Save across server restarts
    storage-path: "plugins/ClaudeNPC/memories/"
```

**Clear memory** if an NPC gets confused:
```
/claudenpc clearmemory GuideNPC PlayerName
```

### Multi-NPC Coordination (Phase 2)

Coming soon in GitVerse:
- NPCs that reference each other
- Shared world knowledge
- Quest chains across multiple NPCs

---

## Troubleshooting

### NPC Doesn't Respond

**Check 1: API Key**
```bash
# Verify your API key in config.yml
grep "key:" plugins/ClaudeNPC/config.yml

# Test API access (Linux/Mac)
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: $YOUR_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"model":"claude-sonnet-4-5-20250929","max_tokens":10,"messages":[{"role":"user","content":"hi"}]}'
```

**Check 2: Server Logs**
```bash
tail -f logs/latest.log | grep ClaudeNPC
```

Look for errors like:
- `API key invalid` → Check your key
- `Rate limit exceeded` → Reduce requests or upgrade API plan
- `Timeout` → Increase timeout in config

**Check 3: Permissions**
```
/lp user YourName permission check claudenpc.user
```

### High API Costs

**Monitor usage**:
```
/claudenpc stats
```

**Reduce costs**:
1. Switch to `claude-haiku-3-5` model
2. Reduce `max-tokens` to 75-100
3. Increase `per-player-cooldown`
4. Disable memory: `memory.enabled: false`
5. Set daily budget caps in Anthropic Console

### NPC Responses Are Off-Topic

**Problem**: NPC talks about things outside Minecraft

**Solution**: Improve personality prompt:
```yaml
personality: |
  You are a Minecraft NPC in a medieval village.
  IMPORTANT: Stay in character. Only discuss topics relevant to Minecraft gameplay.
  If asked about real-world topics, gently redirect to in-game matters.

  You are helpful and friendly, but focused on the game world.
```

---

## Cost Estimation

### Example Usage

**Small Server** (10 players, moderate activity):
- 100 conversations/day
- Average 5 messages per conversation
- Using Sonnet model

**Estimated Cost**: ~$5-10/month

**Large Server** (50 players, high activity):
- 500 conversations/day
- Average 8 messages per conversation
- Using Sonnet model

**Estimated Cost**: ~$50-100/month

**Tips to Reduce Costs**:
1. Use Haiku for simple NPCs
2. Limit `max-tokens` (fewer words = less cost)
3. Set rate limits
4. Use NPCs strategically (not everywhere)

---

## Next Steps

### For Server Admins

1. ✅ **Test with one NPC** - Verify it works
2. ✅ **Create 3-5 specialized NPCs** - Guide, merchant, quest giver
3. ✅ **Set rate limits** - Protect your API budget
4. ✅ **Monitor logs** - Watch for issues
5. ✅ **Get player feedback** - Iterate on personalities

### For Developers

1. 📖 **Read Phase 2 Roadmap**: `PHASE_2_ROADMAP.md`
2. 🔧 **Explore the codebase**: `src/main/java/`
3. 🧪 **Run tests**: `mvn test`
4. 🚀 **Contribute**: Check `CONTRIBUTING.md` (if available)

### Join the Community

- 💬 **Discord**: [Your Discord Link]
- 🐛 **Report Issues**: [GitHub Issues](https://github.com/your-repo/issues)
- 📚 **Documentation**: This folder!
- ⭐ **Star the Repo**: Help others discover ClaudeNPC

---

## FAQ

**Q: Can NPCs trade items?**
A: Not yet in Phase 1. Planned for Phase 2.

**Q: Do NPCs work in creative mode?**
A: Yes! All game modes supported.

**Q: Can I use this on Bedrock Edition?**
A: No, Java Edition only. Bedrock support not planned.

**Q: Is my API key safe?**
A: Yes, stored locally in `config.yml`. Never shared. Use file permissions:
```bash
chmod 600 plugins/ClaudeNPC/config.yml
```

**Q: Can NPCs see what players are doing?**
A: Currently no. They only see text conversations. Phase 2 may add world awareness.

**Q: What if Claude API goes down?**
A: NPCs will show a friendly error message. Your server continues running normally.

**Q: Can I backup NPC memories?**
A: Yes! Copy `plugins/ClaudeNPC/memories/` directory.

---

## Quick Reference Card

### Essential Commands
```
Create NPC:     /claudenpc create <name>
Remove NPC:     /claudenpc remove <name>
List NPCs:      /claudenpc list
Reload Config:  /claudenpc reload
Clear Memory:   /claudenpc clearmemory <name> [player]
View Stats:     /claudenpc stats
```

### File Locations
```
Plugin JAR:     plugins/ClaudeNPC.jar
Configuration:  plugins/ClaudeNPC/config.yml
Memories:       plugins/ClaudeNPC/memories/
Logs:           logs/latest.log
```

### Support Resources
```
Documentation:  claudenpc-server-suite/docs/
Quick Start:    QUICKSTART_TESTING.md
Phase 2 Plans:  PHASE_2_ROADMAP.md
Troubleshooting: This file (scroll up!)
```

---

**Ready to create your first AI NPC?**

Start with a simple village guide, test it out, then expand to more complex personalities. Have fun, and welcome to the future of Minecraft NPCs!

---

**Documentation Version**: 1.0.0
**Last Updated**: 2025-12-28
**ClaudeNPC Version**: Phase 1 (v1.0.0)
**Maintained By**: KENL Project

For technical questions: Check `PHASE_2_ROADMAP.md` and source code
For user support: See FAQ above or file an issue
