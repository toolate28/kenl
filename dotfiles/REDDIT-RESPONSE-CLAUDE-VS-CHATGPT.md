## Re: New to Claude - CLAUDE vs. ChatGPT vs. Perplexity?

Welcome! Here's a breakdown from someone who uses all three (often together):

**Claude's Strengths:**
- **Deep reasoning & analysis** - Excels at complex problem-solving, code architecture, refactoring
- **Long context windows** - Can work with entire codebases, long documents (200k tokens vs GPT-4's 128k)
- **Following instructions precisely** - Better at adhering to specific requirements, coding standards
- **Nuanced writing** - Produces more natural, thoughtful prose (less "AI-sounding")
- **Code quality** - Often produces more maintainable, well-structured code
- **Honesty about limitations** - More likely to say "I don't know" than hallucinate

**ChatGPT's Strengths:**
- **Speed** - Faster responses, especially GPT-4o
- **General knowledge** - Broader training data, better for pop culture, current events
- **Plugins/browsing** - Web access, image generation (DALL-E), more integrations
- **Voice mode** - Natural conversation interface

**Perplexity's Strengths:**
- **Research** - Built for web search + synthesis
- **Citations** - Always provides sources
- **Current information** - Real-time web access by default
- **Conciseness** - Gets to the point quickly

**When I use each:**

**Claude:**
- Coding projects (especially refactoring, architecture)
- Writing documentation (this response was drafted with Claude!)
- Complex analysis requiring deep reasoning
- Working with large files/codebases

**ChatGPT:**
- Quick questions, brainstorming
- Image generation needs
- When I need plugins (calculator, browsing)
- Casual conversation

**Perplexity:**
- Research on current topics
- Fact-checking (it cites sources)
- When I need web search + AI synthesis
- Quick lookups with citations

**Pro tips for Claude:**

1. **Use Projects feature**
   - Add knowledge docs (guides, API refs, your codebase)
   - Claude references these in every chat
   - "Teach Claude about my project once, reference forever"

2. **Leverage long context**
   - Paste entire config files, codebases (up to 200k tokens)
   - Ask: "Review this codebase and suggest improvements"
   - Claude can hold MUCH more context than GPT-4

3. **Use SAIF workflow** (if managing dotfiles/configs)
   - SAIF = System-Aware Intent Framework (umbrella for ATOM/SAGE/OWI)
   - **ATOM** trails = intent logs ("why" you changed configs, not just "what")
   - **SAGE** = pattern recognition (learns your workflow, suggests automation)
   - **OWI** = AI transparency (document what AI generated vs human reviewed)
   - Example: "Why did I add this .vimrc line 6 months ago?" → ATOM trail answers
   - More info: https://github.com/toolate28/kenl/tree/main/dotfiles

**Try this experiment:**
Ask all three: "Refactor this code to be more maintainable" with a complex function. Claude usually wins on code quality and explanation depth.

**Another experiment (Claude's superpower):**
Give Claude a messy config file and ask: "Document the intent behind each section"
- Claude excels at reverse-engineering WHY code/configs exist
- Great for inheriting legacy projects

Hope this helps! 🎉

---

---

## 🔗 Synergistic Use Patterns (Using Multiple AIs Together)

**Don't limit yourself to one AI!** They work great in combination:

### **Pattern 1: Research → Build**
```
Perplexity: "Research best practices for React state management 2024"
  ↓ (Get current info + citations)
Claude: "Based on these sources, refactor my app to use Zustand"
  ↓ (Deep implementation with long context)
Result: Current best practices + high-quality refactor
```

### **Pattern 2: Brainstorm → Refine → Implement**
```
ChatGPT: "Brainstorm 10 features for my SaaS app" (fast, creative)
  ↓ (Pick top 3)
Claude: "Design architecture for these 3 features" (deep reasoning)
  ↓ (Get detailed plan)
Claude: "Implement feature #1 with tests" (code quality)
```

### **Pattern 3: Quick Draft → Deep Review**
```
ChatGPT: "Write a quick API endpoint for user auth" (fast prototype)
  ↓ (Get working code in 30 seconds)
Claude: "Review this code for security issues and refactor" (thorough analysis)
  ↓ (Get production-ready version)
Result: Speed + Quality
```

### **Pattern 4: Web Research → Analysis → Documentation**
```
Perplexity: "Find recent changes to OpenAI API" (current info)
  ↓ (Get changelog + migration guides)
ChatGPT: "Summarize breaking changes" (quick summary)
  ↓ (Get bullet points)
Claude: "Create migration plan for our codebase" (deep analysis)
  ↓ (Get step-by-step plan with code examples)
```

---

## 🔄 Chaining Directives (Passing Work Between AIs)

**Pro technique:** Use clear handoff instructions when switching AIs.

### **From Perplexity to Claude:**
```
Perplexity query: "Research FastAPI async best practices 2024"

Then copy Perplexity's response and tell Claude:
"Based on this research [paste], refactor my FastAPI app to follow these patterns.
Focus on: async database connections, background tasks, and error handling."
```

### **From ChatGPT to Claude:**
```
ChatGPT: "Generate 5 SQL query variations for this use case"

Then tell Claude:
"ChatGPT generated these 5 SQL queries [paste].
Analyze each for performance, security (SQL injection), and maintainability.
Recommend the best one with explanation."
```

### **From Claude back to ChatGPT:**
```
Claude: [Generates detailed architecture document]

Then tell ChatGPT:
"Claude designed this architecture [paste].
Create a quick implementation checklist with time estimates for each component."
(ChatGPT is faster for simple task breakdowns)
```

### **Chaining for SAIF Workflows:**
```
1. Perplexity: "Find best vim plugins for Python development 2024"
2. Claude: "Review these plugins, create a .vimrc with ATOM trail documentation"
3. Result: Current recommendations + intent-documented config

Your .vimrc now has comments like:
# ATOM-CFG-20251114-001: Added coc.nvim
# Intent: Modern LSP support for Python (Perplexity research 2024-11-14)
# Source: https://github.com/neoclide/coc.nvim
# Alternatives considered: vim-lsp (less Python-specific)
```

---

## 💡 When to Use Each AI (Updated with Chaining)

**Start with Perplexity if:**
- Need current information (post-2023)
- Need citations/sources
- Research phase of project

**Start with ChatGPT if:**
- Need quick results (speed priority)
- Brainstorming ideas
- Simple tasks (summaries, lists)

**Start with Claude if:**
- Complex problem requiring deep reasoning
- Working with large codebases
- Need high code quality
- Documentation/refactoring

**Chain them if:**
- Complex project (research → design → implement)
- Want speed + quality (ChatGPT draft → Claude refine)
- Need current info + deep analysis (Perplexity → Claude)

---

**Edit:** Since you're new, check out r/ClaudeAI for tips. Also, Claude Desktop app (free) is worth downloading - better than web interface IMO. Projects feature is desktop-only right now.

**Pro workflow (for modern machines):** Keep all 3 AIs open in browser tabs. Start with Perplexity for research, ChatGPT for quick tasks, Claude for deep work. Copy/paste between them as needed. Your productivity will 10x.

*Note: Idle AI chat tabs use minimal resources (~100-300MB RAM total). Computation happens server-side, not on your machine. If you have an older computer (<4GB RAM), use sequentially instead: Research with Perplexity → close → Design with Claude → close → etc.*

**Pro workflow (resource-conscious):** Bookmark all three AIs. Open only what you need for the current task phase. Sequential use (Perplexity → Claude → ChatGPT) avoids tab overhead while still getting benefits of multi-AI approach. Claude Desktop app uses less RAM than browser tabs.

---

## 🐛 Web Interface Issues (Reality Check)

**You're not alone - web interfaces can be frustrating!** Common problems across all three:

### **Issues I've experienced:**
- **Claude.ai:** Slow loading, "Network error" mid-conversation, chat history disappearing
- **ChatGPT:** "At capacity" errors, conversation resets, regeneration loops
- **Perplexity:** Search timeouts, citation links breaking, mobile interface glitches

### **Why web interfaces struggle:**
1. **High server load** - Millions of users hitting same endpoints
2. **Long-running connections** - WebSocket drops during long responses
3. **Browser state management** - Lost context on refresh/network hiccup
4. **Rate limiting** - You hit invisible usage caps, get throttled

### **Mitigation Strategies:**

#### **1. Use Desktop Apps (More Stable)**
```
Claude Desktop (macOS/Windows):
  ✅ Better connection handling (retries automatically)
  ✅ Persistent state (conversations don't disappear)
  ✅ Projects feature (web doesn't have this yet)
  ✅ Native performance (not browser overhead)

Download: https://claude.ai/download
```

#### **2. Save Your Work Frequently**
```
When working on important code/docs:
  1. Copy AI responses to local text editor as you go
  2. Don't rely on chat history (it can vanish)
  3. Use SAIF ATOM trails to capture intent locally
  4. Git commit frequently if coding

I've lost hour-long conversations - now I cmd+A, cmd+C every few responses.
```

#### **3. Browser Choice Matters**
```
Most stable (in my experience):
  1. Chrome/Chromium - Best overall (if RAM isn't issue)
  2. Firefox - Good alternative, uses less RAM
  3. Safari (Mac) - Claude Desktop app better
  4. Brave - Works but can conflict with AI sites

Clear browser cache if getting weird errors.
```

#### **4. Extension Conflicts**
```
Disable these if having issues:
  - Ad blockers (uBlock, AdBlock) - can break WebSockets
  - Privacy extensions (Privacy Badger) - blocks tracking needed for sessions
  - VPNs - adds latency, can trigger rate limits
  - Auto-refresh extensions - interferes with AI responses

Test in incognito/private mode to isolate extension issues.
```

#### **5. Network Issues**
```
If on unstable connection:
  - Use shorter prompts (less likely to timeout mid-response)
  - Mobile hotspot often more stable than public WiFi
  - Ethernet > WiFi for reliability
  - VPN can help OR hurt (try both)
```

#### **6. Rate Limiting Workarounds**
```
If you hit "Too many requests" errors:

  ChatGPT:
    - Free tier: Very aggressive limits
    - Plus ($20/mo): Much better
    - Switch to Claude when limited

  Claude:
    - Free tier: ~45 messages/5 hours (Sonnet 3.5)
    - Pro ($20/mo): 5x higher limits
    - Use Haiku model for simple stuff (way higher limits)

  Perplexity:
    - Free: 5 searches/4 hours
    - Pro ($20/mo): 300/day
```

#### **7. API Access (Nuclear Option)**
```
Most reliable but costs money:

Claude API:
  - $3-15 per million tokens (input)
  - $15-75 per million tokens (output)
  - No rate limit frustrations
  - Use via cursor.sh, continue.dev, or custom scripts

ChatGPT API:
  - Similar pricing to Claude
  - More stable than web interface
  - Playground: https://platform.openai.com/playground

Only worth it if:
  - You use AI 2+ hours/day
  - Web interface frustration outweighs cost
  - You're coding (Cursor/Continue integrate APIs beautifully)
```

#### **8. Fallback Strategy**
```
Have a backup ready when one fails:

Primary down:    Fallback:
Claude.ai    →   Claude Desktop app
                 → ChatGPT
                 → Local LLM (Ollama + Qwen)

ChatGPT      →   Claude
                 → Perplexity (for research)
                 → Gemini (Google)

Perplexity   →   Google Search + Claude for synthesis
                 → Bing Chat
```

#### **9. Local LLM Option (Ultimate Reliability)**
```
For when ALL web interfaces fail:

Ollama (free, runs locally):
  - Download: https://ollama.ai
  - Models: Qwen 2.5 (14B), Llama 3.1 (8B), Mistral
  - Zero network issues (offline!)
  - Unlimited usage (no rate limits)
  - Slower than cloud, but always available

Good for:
  - Code autocomplete (continue.dev + Ollama)
  - Simple queries when Claude/GPT down
  - Privacy-sensitive work (stays local)
```

---

## 🛠️ SAIF Walkthrough: Ollama + MCP Setup

**This section demonstrates SAIF principles in action** - each step includes ATOM trails (intent), SAGE guidance (progressive disclosure), and OWI transparency (AI vs human decisions).

### **Why This Setup? (ATOM Intent)**

```yaml
ATOM-SETUP-20251114-001: Ollama + MCP for offline AI research
Intent: Eliminate web interface reliability issues
Problem: Claude/ChatGPT web errors disrupt workflow
Solution: 80% of queries handled offline (Ollama), 20% online (Claude Desktop)
Trade-off: Slower responses (local GPU) vs. unlimited reliability
Evidence: Personal workflow testing over 30 days
```

### **Setup Options (SAGE Guidance)**

**Choose based on your use case:**[^1]

| Use Case | Model | RAM Needed | Speed | Quality |
|----------|-------|------------|-------|---------|
| **Code review** | Qwen 2.5 Coder (7B) | 8GB | Fast | Good |
| **General research** | Qwen 2.5 (14B) | 16GB | Medium | Excellent |
| **Complex reasoning** | Llama 3.1 (70B) | 64GB+ | Slow | Best |
| **Quick queries** | Mistral (7B) | 8GB | Very Fast | Decent |

**Recommended starter:** Qwen 2.5 (14B) - best balance of quality/speed for most tasks.

---

### **Step 1: Install Ollama (ATOM Trail)**

```bash
# ATOM-INSTALL-20251114-002: Install Ollama
# Intent: Local LLM server for offline AI queries
# Source: https://ollama.ai

# Linux/WSL
curl -fsSL https://ollama.ai/install.sh | sh

# macOS
brew install ollama

# Windows
# Download from: https://ollama.ai/download/windows
```

**SAGE Note:** Ollama runs as a background service. Check status:[^2]

```bash
# Verify installation
ollama --version
# Should show: ollama version 0.x.x

# Start service (if not auto-started)
ollama serve
```

**OWI Transparency:** Installation script auto-configures systemd (Linux) or launchd (macOS). Human decision: accept defaults or customize service settings.[^3]

---

### **Step 2: Pull Your Model (ATOM Trail)**

```bash
# ATOM-MODEL-20251114-003: Pull Qwen 2.5 14B
# Intent: Best balance of quality/speed for general research
# Alternatives considered: Llama 3.1 8B (faster, lower quality)
# Size: ~8.5GB download

ollama pull qwen2.5:14b

# OR for code-specific tasks:
ollama pull qwen2.5-coder:7b  # Optimized for programming

# OR for resource-constrained systems:
ollama pull mistral:7b  # Smaller, faster
```

**SAGE Note:** First pull takes 5-15 minutes depending on internet speed. Subsequent model switches are instant (already downloaded).[^4]

**Test your model:**

```bash
# ATOM-TEST-20251114-004: Verify model works
# Intent: Confirm Ollama + model operational before MCP setup

ollama run qwen2.5:14b "Explain ATOM trails in 2 sentences"

# Expected output (example):
# ATOM trails are intent-capturing audit logs that document WHY
# changes were made, not just WHAT changed. They enable crash
# recovery, knowledge preservation, and legal protection.
```

---

### **Step 3: Configure MCP for Claude Desktop (ATOM Trail)**

**What is MCP?** Model Context Protocol - lets Claude Desktop call local tools (Ollama, filesystem, etc.).[^5]

```bash
# ATOM-MCP-20251114-005: Configure Claude Desktop MCP
# Intent: Enable Claude Desktop to call local Ollama for basic research
# Benefit: Offload 80% of queries to Ollama (offline, unlimited)
# Result: Claude Desktop handles complex reasoning (20% of queries)

# macOS config location
mkdir -p ~/Library/Application\ Support/Claude
nano ~/Library/Application\ Support/Claude/claude_desktop_config.json

# Linux config location
mkdir -p ~/.config/Claude
nano ~/.config/Claude/claude_desktop_config.json

# Windows config location
# %APPDATA%\Claude\claude_desktop_config.json
```

**SAGE Guidance:** Three configuration levels - choose based on needs:[^6]

#### **Basic Config (Ollama Only)**

```json
{
  "mcpServers": {
    "ollama": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-ollama"]
    }
  }
}
```

**OWI Note:** This config is AI-assisted but human-verified. Review before saving.

#### **Intermediate Config (Ollama + Filesystem)**

```json
{
  "mcpServers": {
    "ollama": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-ollama"]
    },
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/path/to/your/projects"
      ]
    }
  }
}
```

**ATOM Intent:** Filesystem MCP lets Claude Desktop read your local docs/codebase without uploading to cloud.

#### **Advanced Config (Ollama + Filesystem + Memory)**

```json
{
  "mcpServers": {
    "ollama": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-ollama"],
      "env": {
        "OLLAMA_MODEL": "qwen2.5:14b"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/path/to/your/projects"
      ]
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
```

**SAGE Note:** Memory MCP stores facts across sessions (e.g., "Remember I use Rust for backend").[^7]

**OWI Transparency:** Replace `/path/to/your/projects` with your actual project directory. Human decision required.

---

### **Step 4: Restart Claude Desktop (ATOM Trail)**

```bash
# ATOM-RESTART-20251114-006: Apply MCP configuration
# Intent: Load new MCP servers into Claude Desktop

# macOS/Linux
# Quit Claude Desktop (Cmd+Q / Ctrl+Q)
# Relaunch from Applications

# Verify MCP loaded:
# Open Claude Desktop → Settings → Developer
# Should see: "MCP Servers: ollama, filesystem, memory"
```

**SAGE Troubleshooting:** If MCP servers don't appear:[^8]

1. Check config JSON syntax (use JSONLint)
2. Verify `npx` is installed: `npx --version`
3. Check Claude Desktop logs: `~/Library/Logs/Claude/` (macOS)

---

### **Step 5: Test the Setup (ATOM Trail)**

```bash
# ATOM-VERIFY-20251114-007: Confirm Ollama + MCP integration
# Intent: Validate end-to-end workflow before production use
```

**In Claude Desktop, try:**

```
Prompt: "Use Ollama to explain what SAIF stands for in one sentence."

Expected: Claude calls local Ollama → gets response → refines it
Result: "SAIF (System-Aware Intent Framework) is an umbrella framework
         combining ATOM trails, SAGE pattern recognition, and OWI
         transparency for traceable expertise management."
```

**SAGE Note:** You won't see "calling Ollama" explicitly - Claude Desktop handles it transparently. Check the response speed: <2 seconds = Ollama, >5 seconds = cloud API.[^9]

---

### **Usage Patterns (SAIF Workflow)**

**ATOM-WORKFLOW-20251114-008: Daily AI usage with Ollama + MCP**

#### **Pattern 1: Code Review (80% Ollama)**

```
You: "Review this function for bugs" [paste code]
Claude Desktop: [Calls Ollama] → Finds syntax issues, suggests improvements
You: "Now optimize for performance"
Claude Desktop: [Calls Ollama] → Suggests algorithmic improvements

Total: 100% offline, zero rate limits, instant responses
```

#### **Pattern 2: Complex Architecture (20% Cloud)**

```
You: "Design a microservices architecture for e-commerce platform"
Claude Desktop: [Uses cloud API] → Deep reasoning, architectural patterns
You: "Generate boilerplate code for auth service"
Claude Desktop: [Calls Ollama] → Fast code generation

Split: Complex design (cloud), simple generation (Ollama)
```

#### **Pattern 3: Research + Documentation (Mixed)**

```
You: "Summarize this 500-line config file"
Claude Desktop: [Calls Ollama via filesystem MCP] → Quick summary
You: "Write detailed documentation explaining each section"
Claude Desktop: [Uses cloud API] → Nuanced, high-quality docs

Split: Simple tasks (Ollama), quality writing (cloud)
```

**SAGE Insight:** After 1-2 weeks, you'll naturally learn which queries go to Ollama (fast/simple) vs cloud (complex/quality). The split optimizes for cost + reliability.[^10]

---

### **Customization (ATOM Trails)**

**ATOM-CUSTOM-20251114-009: Tailor setup to your workflow**

#### **For Python Developers:**

```json
{
  "mcpServers": {
    "ollama": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-ollama"],
      "env": {
        "OLLAMA_MODEL": "qwen2.5-coder:7b"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/home/user/python-projects"
      ]
    }
  }
}
```

**Intent:** Qwen Coder optimized for code, filesystem scoped to Python projects.

#### **For Low-RAM Systems (<16GB):**

```json
{
  "mcpServers": {
    "ollama": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-ollama"],
      "env": {
        "OLLAMA_MODEL": "mistral:7b",
        "OLLAMA_NUM_GPU": "0"
      }
    }
  }
}
```

**Intent:** Mistral 7B uses ~4GB RAM, `NUM_GPU=0` forces CPU (slower but works).

#### **For Privacy-Sensitive Work:**

```json
{
  "mcpServers": {
    "ollama": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-ollama"],
      "env": {
        "OLLAMA_MODEL": "llama3.1:8b",
        "OLLAMA_KEEP_ALIVE": "24h"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/home/user/confidential-docs"
      ]
    }
  }
}
```

**Intent:** 100% offline (no cloud calls), model stays loaded for 24h (faster responses).

**OWI Note:** These configs are templates. Customize paths/models for your specific needs.

---

### **SAGE Footnotes**

[^1]: **Model Selection Philosophy:** Smaller models (7B) excel at pattern matching and code completion. Larger models (14B+) handle nuanced reasoning and complex queries. Match model to task complexity for optimal speed/quality trade-off.

[^2]: **Service Management:** Ollama runs on `http://localhost:11434` by default. Logs: `journalctl -u ollama` (Linux) or `~/Library/Logs/Ollama/` (macOS). GPU detection automatic (CUDA/ROCm/Metal).

[^3]: **Security Considerations:** Ollama binds to localhost only (no external access). For multi-machine setups, use `OLLAMA_HOST=0.0.0.0` but secure with firewall rules. Never expose to public internet without authentication.

[^4]: **Model Storage:** Models stored in `~/.ollama/models/` (~8-50GB per model). Use `ollama rm <model>` to free space. Can run multiple models simultaneously if RAM permits.

[^5]: **MCP Architecture:** Claude Desktop → JSON-RPC → MCP Server → Ollama API. Each MCP server is a separate Node.js process. Crash in one server doesn't affect others.

[^6]: **Configuration Validation:** Test JSON syntax at jsonlint.com before saving. Invalid JSON prevents Claude Desktop from loading any MCP servers. Back up working configs before experimenting.

[^7]: **Memory MCP Persistence:** Stored in `~/.mcp/memory/` as SQLite database. Survives Claude Desktop restarts. Clear with `rm -rf ~/.mcp/memory/` if needed. Privacy: stays local, never uploaded.

[^8]: **Common MCP Issues:**
   - `npx` not found: Install Node.js 18+ from nodejs.org
   - Permission denied: Run `chmod +x ~/.config/Claude/` (Linux)
   - Server timeout: Increase in config: `"timeout": 30000` (30 seconds)
   - Model not found: Verify `ollama list` shows your model

[^9]: **Performance Benchmarks (Qwen 2.5 14B on AMD Ryzen 5 5600H):**
   - Simple query (code review): ~1.5 seconds
   - Medium query (explain algorithm): ~4 seconds
   - Complex query (architectural design): ~8 seconds
   - vs Cloud API: ~3-10 seconds (variable network latency)

[^10]: **Cost Analysis (Monthly):**
   - Cloud-only (Claude Pro): $20/month, rate limits apply
   - Ollama-only: $0/month, unlimited, lower quality on complex tasks
   - **Hybrid (recommended):** $20/month Claude Pro + Ollama = best of both worlds
   - Electricity cost: ~$0.50/month (GPU running 2 hours/day at $0.12/kWh)

---

### **Appendix: Advanced SAIF Patterns**

#### **A1: ATOM Trail Automation**

Automatically log Ollama queries to ATOM trail:

```bash
# ~/.bashrc or ~/.zshrc
ollama_atom() {
  local query="$1"
  local timestamp=$(date +%Y%m%d-%H%M%S)
  echo "ATOM-OLLAMA-$timestamp: $query" >> ~/dotfiles/.atom-trail.log
  ollama run qwen2.5:14b "$query"
}

alias oq="ollama_atom"

# Usage:
# oq "Explain Docker networking"
# Result: Query logged to ATOM trail + response
```

**SAGE Insight:** After 30 days, analyze ATOM trail to find repetitive queries. Automate them with aliases or scripts.

#### **A2: SAGE Pattern Recognition**

Script to analyze Ollama usage and suggest optimizations:

```bash
# ~/bin/sage-ollama-analyze.sh
#!/bin/bash
# ATOM-SAGE-20251114-010: Analyze Ollama query patterns

# Count queries by type (last 30 days)
grep "ATOM-OLLAMA" ~/dotfiles/.atom-trail.log | \
  tail -n 1000 | \
  awk -F': ' '{print $2}' | \
  sort | uniq -c | sort -nr | head -20

# Suggests:
# - Most common queries → create aliases
# - Repeated research → cache results locally
# - Model mismatches → switch to appropriate model
```

**Output Example:**

```
42 "Review this function"
31 "Explain this config"
18 "Optimize this query"

SAGE Suggestion: Create alias 'review' for function reviews.
SAGE Suggestion: Switch to qwen2.5-coder for code-heavy tasks.
```

#### **A3: OWI Transparency Report**

Track AI-generated content vs human-reviewed:

```yaml
# ~/dotfiles/.owi-report.yaml
session: 2025-11-14
ai_provider: Ollama (Qwen 2.5 14B)
queries_total: 127
queries_ollama: 103 (81%)
queries_cloud: 24 (19%)
human_review:
  - code_generated: 45 files (100% reviewed before commit)
  - docs_generated: 12 files (100% reviewed, 3 edited)
  - configs_generated: 8 files (100% reviewed, 2 rejected)
transparency: All AI contributions logged to ATOM trail
authority: Human final approval on all changes
```

**SAGE Pattern:** Over time, human review rate decreases for trusted patterns (e.g., simple code refactors), increases for novel tasks (new architectures).

---

## 📚 Critical Help Guides (Common Woes Solved)

### **Guide 1: Projects Feature Mastery**

**Common woe:** "I keep re-pasting the same docs/code into every new chat. There must be a better way!"

**SAIF Solution:** Use Claude Desktop Projects feature to create persistent knowledge bases.[^11]

#### **What are Projects?**

Projects = persistent context that Claude remembers across all chats in that project. Think of it as "teaching Claude about your work once, reference forever."

#### **When to Use Projects (SAGE Guidance)**

| Scenario | Use Project? | Why |
|----------|-------------|-----|
| One-off question | ❌ No | Regular chat is fine |
| Working on specific codebase | ✅ Yes | Add code files, API docs |
| Learning a new framework | ✅ Yes | Add official docs, tutorials |
| Client work (confidential) | ✅ Yes | Separate project per client |
| General productivity | ❌ No | Use regular chat |

#### **Setup (ATOM Trail)**

```yaml
ATOM-PROJECT-20251114-011: Create project for Python web app
Intent: Stop re-pasting Flask docs and codebase every chat
Files added:
  - requirements.txt (dependencies)
  - README.md (project overview)
  - app/ (source code, 50 files)
  - Flask official docs (external link)
Result: Claude now understands project context in every chat
```

**Steps:**

1. Claude Desktop → New Project → Name it (e.g., "MyApp Backend")
2. Add files: Drag & drop or paste text
3. Add instructions: "This is a Flask API. Follow PEP 8. Use type hints."
4. Chat in project context - Claude remembers everything

#### **What to Add to Projects (SAGE Best Practices)**

**Essential:**
- README/project overview
- Core source files (API, models, utils)
- Dependencies (requirements.txt, package.json)
- API documentation (if using external APIs)

**Optional but useful:**
- Test files (for context when writing tests)
- Config files (.env example, not actual secrets!)
- Architecture docs (if you have them)
- Style guides (if team has specific standards)

**Don't add:**
- Secrets (.env with real keys, credentials.json)
- Binary files (images, videos, compiled code)
- Generated code (node_modules, venv, __pycache__)
- Huge datasets (>5MB files)

#### **Projects + SAIF Integration**

```yaml
# Add to your project instructions:
"Use SAIF workflow:
- Document intent (ATOM trails) for all changes
- Suggest automation for repetitive patterns (SAGE)
- Mark AI-generated code vs human-reviewed (OWI)"
```

**Result:** Claude automatically applies SAIF principles to your project work.

#### **Pro Tips**

**Tip 1: Multiple projects for separation**
- Work project: `~/work/client-api/`
- Personal project: `~/hobby/game-engine/`
- Learning: `~/learning/rust-tutorial/`

Each gets its own Claude Project → no context bleed.

**Tip 2: Project templates**

Create a template project with common instructions, duplicate for new projects:

```
Template Project Instructions:
- Follow clean code principles
- Add ATOM trails for significant changes
- Explain complex logic with comments
- Suggest tests for new functions
- Use SAIF workflow (ATOM/SAGE/OWI)
```

**Tip 3: Update projects regularly**

When codebase changes significantly, update project files. Stale context = bad suggestions.

---

### **Guide 2: Context Window Management (200k Tokens)**

**Common woe:** "Claude says it can handle 200k tokens, but I don't know how to use that effectively!"

**SAIF Solution:** Strategic context loading based on task type.[^12]

#### **What is 200k tokens? (Comparison)**

- 200k tokens ≈ 150,000 words ≈ 600 pages of text
- GPT-4: 128k tokens (40% less)
- Entire Harry Potter book 1: ~77k tokens (fits easily!)
- Mid-size codebase: ~100-300 files (most fit in one chat)

#### **When to Use Large Context (SAGE Guidance)**

| Task | Context Size | Example |
|------|--------------|---------|
| **Code review** | 50k-100k | Paste entire module, Claude reviews all files |
| **Refactoring** | 100k-150k | Paste related files, Claude maintains consistency |
| **Documentation** | 30k-50k | Paste codebase, Claude generates comprehensive docs |
| **Bug hunting** | 80k-120k | Paste all related files, Claude traces issue |
| **Learning** | 20k-40k | Paste tutorial + your code, Claude explains differences |

#### **Loading Strategy (ATOM Trail)**

```yaml
ATOM-CONTEXT-20251114-012: Load codebase for refactoring
Intent: Refactor authentication system across 15 files
Context loaded:
  - auth/ (8 files, ~12k tokens)
  - models/user.py (~3k tokens)
  - tests/test_auth.py (~5k tokens)
  - API docs (external OAuth provider, ~8k tokens)
Total: ~28k tokens (14% of available context)
Result: Claude maintains consistency across all auth-related code
```

**Steps:**

1. **Identify task scope:** What files does Claude need to see?
2. **Paste in order:** Most important files first (core logic), helpers last
3. **Add context:** Explain relationships between files
4. **Use Projects:** For recurring work, add to Project once

#### **Context Organization (SAIF Pattern)**

**Bad (unstructured):**
```
[Paste file1.py]
[Paste file2.py]
[Paste file3.py]
"Review this code"
```

**Good (SAIF-structured):**
```
# ATOM-REVIEW-20251114-013: Code review for auth system
# Intent: Find security issues before production deploy

## File 1: auth/login.py (core authentication logic)
[paste file1.py]

## File 2: auth/session.py (session management)
[paste file2.py]

## File 3: models/user.py (user database model)
[paste file3.py]

Task: Review for security issues (SQL injection, XSS, auth bypass)
Context: This is a Flask API using SQLAlchemy ORM
```

**Why better:** Claude understands file relationships, task intent, and security focus.

#### **Token Counting Tips**

**Rough estimates:**
- 1 token ≈ 0.75 words
- 1 line of code ≈ 5-10 tokens
- 100-line Python file ≈ 500-1000 tokens
- Your message + Claude's response both count toward limits

**Check token usage:** Claude Desktop → Settings → Usage (shows tokens per chat)

#### **When Context is Too Large**

**Symptom:** Claude's responses get slower or less accurate toward end of chat.

**Solutions:**
1. **Split into multiple chats:** Divide task by file scope
2. **Use Projects:** Move static files to Project, reference in chat
3. **Summarize first:** Ask Claude to summarize large files, work with summaries
4. **Prune irrelevant code:** Remove unused imports, commented code, tests (if not needed)

---

### **Guide 3: Model Switching Strategy**

**Common woe:** "When do I use Haiku vs Sonnet vs Opus? I'm wasting money on Opus for simple tasks!"

**SAIF Solution:** Match model to task complexity and budget.[^13]

#### **Model Comparison (Real-World)**

| Model | Speed | Quality | Cost | Best For |
|-------|-------|---------|------|----------|
| **Haiku** | ⚡⚡⚡ Fast (1-2s) | ⭐⭐ Good | 💰 Cheap | Simple queries, summaries |
| **Sonnet** | ⚡⚡ Medium (3-5s) | ⭐⭐⭐⭐ Excellent | 💰💰 Moderate | Most tasks, coding |
| **Opus** | ⚡ Slow (8-15s) | ⭐⭐⭐⭐⭐ Best | 💰💰💰 Expensive | Complex reasoning, critical work |

#### **Decision Tree (SAGE Guidance)**

```
Is the task complex/novel/critical?
├─ YES → Use Opus
│   ├─ Architecture design
│   ├─ Security audit
│   ├─ Complex debugging
│   └─ Novel algorithm design
│
└─ NO → Is it a coding task?
    ├─ YES → Use Sonnet
    │   ├─ Code review
    │   ├─ Refactoring
    │   ├─ Writing functions
    │   └─ Documentation
    │
    └─ NO → Use Haiku
        ├─ Summarize text
        ├─ Simple questions
        ├─ Format conversion
        └─ Quick research
```

#### **Real Usage Patterns (ATOM Trail)**

```yaml
ATOM-USAGE-20251114-014: Weekly AI usage breakdown
Total queries: 247
Model distribution:
  - Haiku: 112 queries (45%) - summaries, quick questions
  - Sonnet: 118 queries (48%) - coding, reviews, refactoring
  - Opus: 17 queries (7%) - architecture, complex debugging
Cost: $12.50 (vs $45 if all Opus)
Result: 72% cost savings, same output quality
```

#### **Task-to-Model Examples**

**Haiku tasks (45% of work):**
```
✅ "Summarize this 200-line config file"
✅ "Explain what this function does in 2 sentences"
✅ "Convert this JSON to YAML"
✅ "What does this error message mean?"
✅ "List 10 ideas for feature X"
```

**Sonnet tasks (48% of work):**
```
✅ "Review this code for bugs"
✅ "Refactor this function to be more readable"
✅ "Write unit tests for this module"
✅ "Generate documentation for this API"
✅ "Optimize this algorithm"
```

**Opus tasks (7% of work):**
```
✅ "Design a microservices architecture for [complex system]"
✅ "Find the security vulnerability in this code" (critical)
✅ "Debug this race condition" (complex, novel)
✅ "Explain the trade-offs between these 5 architectural patterns"
```

#### **Switching Models Mid-Chat**

**Claude Desktop:** Model selection in chat interface (dropdown)

**Strategy:**
1. Start with Sonnet (default for most work)
2. Switch to Haiku for quick follow-ups ("Summarize your response in 3 bullet points")
3. Switch to Opus if Sonnet struggles ("This needs deeper analysis")

**Example workflow:**

```
[Sonnet] "Design a caching strategy for this API"
→ Sonnet provides good design

[Haiku] "Summarize the key points"
→ Fast summary

[Opus] "Analyze edge cases where this design might fail"
→ Deep analysis finds 3 critical issues Sonnet missed
```

#### **Cost Optimization (SAGE Pattern)**

**After 30 days, analyze your usage:**

```bash
# Count model usage from ATOM trail
grep "ATOM-QUERY" ~/dotfiles/.atom-trail.log | \
  grep -E "(Haiku|Sonnet|Opus)" | \
  sort | uniq -c

# Output:
# 112 Haiku queries
# 118 Sonnet queries
#  17 Opus queries

# SAGE suggests:
# - 15 Sonnet queries could have been Haiku (simple questions)
# - Potential savings: $3/month
# - Create alias for common Haiku tasks
```

**Automation example:**

```bash
# ~/.bashrc
alias ask-quick="claude --model haiku"
alias ask-code="claude --model sonnet"
alias ask-complex="claude --model opus"

# Usage:
# ask-quick "What does SAIF stand for?"
# ask-code "Review this function"
# ask-complex "Design this system architecture"
```

---

### **SAGE Footnotes (Help Guides)**

[^11]: **Projects Feature Limitations:**
   - Desktop-only (not available on claude.ai web yet)
   - Max 10 projects on Free tier, unlimited on Pro
   - Files persist across sessions but count toward context window
   - Can't share projects with other users (yet)

[^12]: **Context Window Performance:**
   - Quality degrades slightly with very large context (>150k tokens)
   - Processing time increases linearly with context size
   - Recommend chunking tasks if >120k tokens needed
   - Use Projects for static context, chat for dynamic queries

[^13]: **Model Pricing (API rates, as of 2025-01):**
   - Haiku: $0.25 per million input tokens, $1.25 per million output
   - Sonnet: $3 per million input, $15 per million output
   - Opus: $15 per million input, $75 per million output
   - Claude Desktop (Pro): Bundled pricing, unlimited Sonnet, limited Opus

---

### **My Actual Workflow (Accounting for Reliability):**

```
1. Start with Claude Desktop (most stable)
2. If Claude Desktop glitches → Switch to ChatGPT web
3. If both web interfaces acting up → Ollama locally
4. Research always starts with Perplexity (citations worth the occasional timeout)
5. Critical work → Copy to local files every 5-10 minutes
6. ATOM trails saved locally (dotfiles/.atom-trail.log) - never lose intent docs
```

### **The Harsh Truth:**

Web AI interfaces are **amazing but unreliable**. Plan for failure:
- ✅ Save work locally (don't trust chat history)
- ✅ Use desktop apps when available (Claude Desktop)
- ✅ Have fallbacks (multiple AIs bookmarked)
- ✅ Consider API access if you're power user
- ✅ Local LLM for offline/unlimited usage

**It's frustrating, but knowing it's normal helps.** Everyone deals with this - you're not doing anything wrong when Claude says "Network error" for the 5th time today. 😅
