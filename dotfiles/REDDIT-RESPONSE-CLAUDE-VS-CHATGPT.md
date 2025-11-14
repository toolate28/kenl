## Re: New to Claude - What's it good at vs ChatGPT/Perplexity?

Welcome! Here's a quick breakdown from someone who uses all three:

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
   - SAIF = System-Aware Intent Framework
   - Claude helps you document WHY configs changed (not just WHAT)
   - Creates "ATOM trails" - intent logs for every change
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

**Edit:** Since you're new, check out r/ClaudeAI for tips. Also, Claude Desktop app (free) is worth downloading - better than web interface IMO. Projects feature is desktop-only right now.
