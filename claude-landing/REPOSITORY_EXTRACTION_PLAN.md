# Repository Extraction Plan - Public Release

**Goal**: Extract 3 standalone projects into clean, public repositories
**Standard**: Clone → Install → Run in under 5 minutes
**Date**: 2025-12-28

---

## Repositories to Extract

### 1. kenl-command-center
**Description**: Context-aware PowerShell terminal dashboard
**Target Users**: Windows developers, sysadmins, PowerShell users
**Clone-to-Run**: 2 commands

### 2. claudenpc-server-suite
**Description**: AI-powered Minecraft NPCs with Claude API
**Target Users**: Minecraft server admins, educators, developers
**Clone-to-Run**: 5 commands (requires Minecraft server)

### 3. claude-hooks-dashboard
**Description**: All 12 Claude Code hooks with real-time web dashboard
**Target Users**: Claude Code users, AI developers
**Clone-to-Run**: 3 commands

---

## Rigorous Requirements (Per Repo)

### Must Have (Critical)

1. **README.md** with:
   - One-line description
   - Quick start (clone → run)
   - Prerequisites clearly listed
   - Screenshots/demo GIF
   - Installation verification steps
   - Troubleshooting section

2. **LICENSE** file (MIT recommended)

3. **.gitignore** appropriate for tech stack

4. **Working install script** that:
   - Checks prerequisites
   - Auto-installs if possible
   - Provides clear error messages
   - Confirms successful installation

5. **Example/demo** that works immediately after install

6. **CONTRIBUTING.md** (encourages PRs)

### Should Have (Important)

7. **docs/** folder with:
   - Architecture overview
   - API reference
   - Configuration guide
   - FAQ

8. **examples/** folder with working samples

9. **tests/** that pass (`make test` or equivalent)

10. **Changelog** or release notes

### Nice to Have

11. CI/CD (GitHub Actions)
12. Package manager support (npm, PSGallery, etc.)
13. Docker support (where applicable)
14. Video walkthrough

---

## Repo 1: kenl-command-center

### Structure
```
kenl-command-center/
├── README.md                    # Quick start, screenshots
├── LICENSE                      # MIT
├── .gitignore                   # PowerShell specific
├── Install.ps1                  # One-command install
├── KENL-CommandCenter.psm1      # Main module
├── CONTRIBUTING.md              # How to contribute
├── docs/
│   ├── ARCHITECTURE.md          # How it works
│   ├── CUSTOMIZATION.md         # Glyphs, colors, contexts
│   └── FAQ.md                   # Common questions
├── examples/
│   ├── custom-context.ps1       # Add your own context
│   └── custom-theme.ps1         # Color scheme example
└── tests/
    └── CommandCenter.Tests.ps1  # Pester tests
```

### Quick Start (Target)
```powershell
# 1. Clone
git clone https://github.com/kenl/command-center.git
cd command-center

# 2. Install
.\Install.ps1

# 3. Reload profile
. $PROFILE

# Done! Navigate to see it in action
cd C:\your-project
```

### Prerequisites Check
```powershell
# Install.ps1 checks:
- PowerShell 5.1+ (Get $PSVersionTable)
- Write access to $PROFILE
- Terminal supports Unicode
```

---

## Repo 2: claudenpc-server-suite

### Structure
```
claudenpc-server-suite/
├── README.md                    # Quick start with video
├── LICENSE                      # MIT
├── .gitignore                   # Java/Maven/Minecraft
├── pom.xml                      # Maven build
├── GETTING_STARTED.md           # User guide (already created!)
├── CONTRIBUTING.md              # Dev setup
├── src/
│   └── main/java/...            # Plugin source
├── docs/
│   ├── PHASE_2_ROADMAP.md       # GitVerse plans
│   ├── API_INTEGRATION.md       # Claude API usage
│   └── CONFIGURATION.md         # Config guide
├── examples/
│   ├── config.yml               # Sample config
│   └── personalities/           # Example NPC personalities
│       ├── guide.yml
│       ├── merchant.yml
│       └── quest-giver.yml
├── scripts/
│   ├── install.sh               # Linux installer
│   └── install.ps1              # Windows installer
└── .github/
    └── workflows/
        └── build.yml            # CI/CD
```

### Quick Start (Target)
```bash
# 1. Prerequisites
# - Minecraft server (Paper/Spigot 1.16+)
# - Java 17+
# - Claude API key

# 2. Clone
git clone https://github.com/kenl/claudenpc.git
cd claudenpc

# 3. Build
mvn clean package

# 4. Install to server
cp target/ClaudeNPC-*.jar /path/to/server/plugins/

# 5. Configure
cd /path/to/server/plugins/ClaudeNPC
nano config.yml  # Add API key

# 6. Start server
cd ../..
java -jar server.jar

# 7. Create first NPC in-game
/claudenpc create GuideNPC
```

### Prerequisites Check
```bash
# install.sh checks:
- Java version (java -version)
- Maven installed (mvn -version)
- Server path exists
- API key format valid
```

---

## Repo 3: claude-hooks-dashboard

### Structure
```
claude-hooks-dashboard/
├── README.md                    # Quick start, demo GIF
├── LICENSE                      # MIT
├── .gitignore                   # Bun/Node specific
├── install.sh                   # Linux/Mac installer
├── install.ps1                  # Windows installer
├── package.json                 # Bun scripts
├── CONTRIBUTING.md              # Dev guide
├── .claude/
│   ├── settings.json            # Hook configuration
│   └── hooks/
│       ├── handlers/            # 12 hook handlers
│       │   ├── user-prompt-submit.ts
│       │   ├── pre-tool-use.ts
│       │   └── ... (10 more)
│       ├── utils/
│       │   └── logger.ts        # Shared logger
│       └── viewer/
│           ├── server.ts        # Bun HTTP server
│           ├── index.html       # Vue.js dashboard
│           └── styles/
│               └── theme.css
├── docs/
│   ├── HOOKS_REFERENCE.md       # All 12 hooks explained
│   ├── DASHBOARD.md             # Dashboard features
│   └── CUSTOMIZATION.md         # Extend hooks
├── examples/
│   ├── custom-hook.ts           # Template
│   └── slack-integration.ts     # Notification example
└── tests/
    └── viewer/
        └── __tests__/
            ├── server.test.ts
            └── components.test.ts
```

### Quick Start (Target)
```bash
# 1. Prerequisites
# - Bun runtime (curl -fsSL https://bun.sh/install | bash)
# - Claude Code CLI

# 2. Clone into Claude project
cd your-claude-project
git clone https://github.com/kenl/claude-hooks-dashboard.git .claude

# 3. Install dependencies
cd .claude/hooks
bun install

# 4. Start dashboard
bun run viewer

# 5. Open browser
open http://localhost:3456

# Done! Dashboard auto-updates with hook events
```

### Prerequisites Check
```bash
# install.sh checks:
- Bun installed (bun --version)
- Claude Code CLI (claude --version)
- Port 3456 available
- Directory is .claude/ (correct location)
```

---

## Preparation Steps (Before Push)

### For Each Repo

1. **Create clean directory**
   ```bash
   mkdir temp-repo-name
   cp -r source-files/* temp-repo-name/
   cd temp-repo-name
   ```

2. **Remove private data**
   - No API keys
   - No personal paths
   - No internal references
   - Sanitize example configs

3. **Add LICENSE**
   ```bash
   # MIT License with current year
   ```

4. **Create .gitignore**
   - Language-specific templates
   - OS-specific (Windows, Mac, Linux)
   - IDE files (.vscode, .idea)

5. **Write README.md**
   - Badge for build status
   - One-line description
   - Quick start section
   - Prerequisites
   - Installation
   - Usage examples
   - Screenshots/demo
   - Links to docs
   - Contributing
   - License

6. **Test clean install**
   ```bash
   # On fresh VM or container
   git clone <repo>
   # Follow README quick start
   # Verify it works
   ```

7. **Initialize git**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   ```

8. **Create GitHub repo**
   - Public visibility
   - Add description
   - Add topics/tags
   - Enable issues
   - Enable discussions

9. **Push**
   ```bash
   git remote add origin https://github.com/user/repo.git
   git push -u origin main
   ```

10. **Add extras**
    - GitHub topics: powershell, terminal, dashboard, etc.
    - About section description
    - Website link (if docs hosted)
    - Social preview image

---

## README Template (Universal)

```markdown
# Project Name

> One-line description that captures essence

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Build Status](badge-if-applicable)]()

[Screenshot or Demo GIF here]

## Quick Start

\`\`\`bash
# Clone
git clone https://github.com/user/repo.git
cd repo

# Install
./install.sh  # or Install.ps1 on Windows

# Run
command-to-start
\`\`\`

**That's it!** See it in action.

## What Is This?

[2-3 sentence explanation]

## Features

- ✅ Feature 1
- ✅ Feature 2
- ✅ Feature 3

## Prerequisites

- Requirement 1 (link to install)
- Requirement 2
- Requirement 3

## Installation

### Option 1: Quick Install (Recommended)

\`\`\`bash
./install.sh
\`\`\`

### Option 2: Manual Install

[Step-by-step instructions]

### Verify Installation

\`\`\`bash
command-to-verify
# Expected output: ...
\`\`\`

## Usage

### Basic Example

\`\`\`bash
[simplest possible example]
\`\`\`

### Advanced Examples

See [examples/](examples/) for more.

## Configuration

[Key config options with examples]

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [API Reference](docs/API.md)
- [FAQ](docs/FAQ.md)

## Troubleshooting

**Problem**: Common issue 1
**Solution**: Fix for issue 1

**Problem**: Common issue 2
**Solution**: Fix for issue 2

## Contributing

We love contributions! See [CONTRIBUTING.md](CONTRIBUTING.md).

Quick start for contributors:
\`\`\`bash
# Fork, clone, make changes
# Run tests
make test  # or npm test, bun test, etc.
# Submit PR
\`\`\`

## License

MIT License - see [LICENSE](LICENSE) file.

## Credits

Built by [Name] using [Tech Stack].

---

**Star this repo** if you find it useful! ⭐
```

---

## Post-Release Checklist

### Marketing

- [ ] Post to r/PowerShell (Command Center)
- [ ] Post to r/admincraft (ClaudeNPC)
- [ ] Post to Claude Discord (Hooks Dashboard)
- [ ] Tweet about it
- [ ] Create demo video (< 3 min)
- [ ] Write blog post

### Maintenance

- [ ] Enable GitHub Discussions
- [ ] Create issue templates
- [ ] Set up GitHub Actions (CI)
- [ ] Monitor issues daily (first week)
- [ ] Respond to PRs within 48h

### Iteration

- [ ] Collect user feedback
- [ ] Create roadmap based on requests
- [ ] Release v1.1 with improvements
- [ ] Add to package managers (npm, PSGallery)

---

## Success Metrics (Per Repo)

**Week 1**:
- 10+ GitHub stars
- 3+ issues opened
- 1+ PR submitted
- 50+ clones

**Month 1**:
- 50+ stars
- 10+ forks
- 5+ contributors
- 200+ clones

**Month 3**:
- 100+ stars
- Featured in newsletter/blog
- Package manager listing
- Video tutorial by community

---

**Next Step**: Execute extraction for Command Center first (lowest complexity)
