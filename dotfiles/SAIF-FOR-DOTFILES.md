---
title: SAIF for Dotfiles - Software Developer Guide
classification: OWI-DOC
atom: ATOM-DOC-20251114-060
framework: SAIF
saif-version: 1.0.0
version: 2025-11-14
audience: Software Developers, DevOps Engineers, System Administrators
description: Intent-driven dotfiles management with ATOM trails and pattern learning
---

# SAIF for Dotfiles
**System-Aware Intent Framework for Software Developers**

## What Problem Does This Solve?

**Traditional dotfiles approach:**
```bash
# You find a cool .vimrc online
cp cool-vimrc ~/.vimrc

# 6 months later...
# Why did I add this line? What does it do?
# Is it safe to remove?
# No idea. Better leave it.
```

**SAIF approach:**
```bash
# Apply dotfiles with intent tracking
./apply-config.sh .vimrc --intent "Add fuzzy file finder for faster navigation"

# ATOM trail records:
ATOM-CFG-20251114-001: Added fzf.vim plugin
Intent: Faster file navigation in large codebases
Source: Recommendation from r/vim
Test: Verified works with 500+ file projects
Rollback: ./rollback.sh ATOM-CFG-20251114-001

# 6 months later: Full context preserved
```

---

## Quick Start (5 Minutes)

### **1. Clone SAIF Dotfiles**

```bash
git clone https://github.com/toolate28/kenl.git ~/.kenl
cd ~/.kenl/dotfiles
```

### **2. Choose Your Profile**

```bash
# View available profiles
ls profiles/

# Options:
# - minimal: Bare essentials (bash, git)
# - dev-focused: VSCode, vim, tmux, git, Python/Node setups
# - mac-developer: macOS-specific (homebrew, iterm2)
# - linux-developer: Linux-specific (apt/dnf, X11/Wayland)
```

### **3. Bootstrap**

```bash
# Install with backup of existing configs
./bootstrap.sh --profile dev-focused --backup-existing

# Creates:
# - Symlinks: ~/.vimrc -> ~/.kenl/dotfiles/profiles/dev-focused/configs/.vimrc
# - Backup: ~/.kenl/dotfiles/backups/backup-20251114-103045.tar.gz
# - ATOM trail: Records every change
```

### **4. Verify**

```bash
# Check symlinks
./verify-dotfiles.sh

# Test configs
vim ~/.vimrc  # Should load with your new config
git config --list  # Should show your settings
```

---

## Core Concepts

### **1. ATOM Trails = Your Config History with Intent**

Every change gets documented:

```yaml
ATOM-CFG-20251114-001: Added vim-fugitive plugin
Date: 2025-11-14 10:30:00
Intent: Better git integration in vim (staging, committing, diffing)
Source: Recommendation from coworker
Changes:
  - File: ~/.vimrc
  - Added: Plugin 'tpope/vim-fugitive'
  - Added: Custom keybindings <leader>gs, <leader>gc
Test: Verified git status in vim works
Rollback: ./rollback.sh ATOM-CFG-20251114-001
```

**Why this matters:**
- **6 months later:** "Why did I add this? Oh, for git staging. Still useful."
- **New machine:** Copy ATOM trail → understand your setup
- **Team onboarding:** "Here's my dotfiles + intent trail, learn from it"

### **2. SAGE Pattern Learning**

After using your dotfiles for a few weeks, SAGE notices patterns:

```yaml
SAGE detected pattern:
- You always open VSCode in ~/projects/work directory
- You always run "git pull && npm install" first
- You always start the dev server on port 3000

Suggestion: Create alias 'work-start' to automate this?
  alias work-start='cd ~/projects/work && git pull && npm install && npm run dev'

Accept? (y/n)
```

**How it works:**
- SAGE watches your command history (bash_history, zsh_history)
- Identifies repetitive sequences (confidence threshold: 80%+)
- Suggests automation (aliases, functions, scripts)

### **3. Shareable Profiles**

Create profiles for different contexts:

```
profiles/
├── minimal/              # Just bash + git
├── dev-focused/          # Full dev stack
│   ├── .vimrc           # Vim with plugins
│   ├── .gitconfig       # Git aliases, GPG signing
│   ├── .tmux.conf       # Tmux with vim bindings
│   └── .zshrc           # ZSH with oh-my-zsh
├── mac-developer/        # macOS specifics
└── linux-developer/      # Linux specifics
```

**Share your optimized setup:**

```bash
# Export your profile
./export-profile.sh my-optimized-dev \
  --description "VSCode + Vim + Tmux setup for Python/JS development" \
  --benchmarks "Tested on macOS Sonoma, Ubuntu 22.04"

# Creates: profiles/my-optimized-dev.tar.gz
# Share with team or community
```

---

## Real-World Example: Git Config

### **Traditional Approach**

```bash
# Copy someone's .gitconfig
curl https://gist.github.com/someone/.gitconfig > ~/.gitconfig

# No idea what half these settings do
# Scared to change anything
```

### **SAIF Approach**

```bash
# 1. Start with minimal profile
./bootstrap.sh --profile minimal

# 2. Add features incrementally with intent
./edit-config.sh ~/.gitconfig --intent "Add GPG commit signing for security"

# ATOM trail records:
ATOM-CFG-20251114-010: Enabled GPG commit signing
Intent: Company requires signed commits for compliance
Source: https://docs.github.com/en/authentication/managing-commit-signature-verification
Changes:
  [user]
    signingkey = ABC123
  [commit]
    gpgsign = true
Test: git commit -m "test" → shows "Signed-off-by"
Rollback: ./rollback.sh ATOM-CFG-20251114-010

# 3. Later: Add more features
./edit-config.sh ~/.gitconfig --intent "Add git aliases for faster workflow"

ATOM-CFG-20251114-011: Added git aliases
Intent: Typing "git status" 50x/day is tedious
Changes:
  [alias]
    st = status
    co = checkout
    br = branch
    ci = commit
Source: Personal preference
Test: git st → works
```

**Result:**
- You understand every line in your .gitconfig
- You know why each setting exists
- You can confidently modify/remove things
- New team members learn from your ATOM trail

---

## Dotfile Categories

### **1. Shell Configuration**

```
profiles/dev-focused/shell/
├── .bashrc           # Bash config
├── .bash_profile     # Bash login shell
├── .bash_aliases     # Custom aliases
├── .zshrc            # ZSH config
└── .zsh_aliases      # ZSH aliases
```

**ATOM trail example:**
```
ATOM-CFG-20251114-020: Added Docker aliases
Intent: Faster Docker workflow (typing "docker ps" 20x/day)
Aliases:
  dps='docker ps'
  dimg='docker images'
  dstop='docker stop $(docker ps -q)'
Source: Personal need
Test: dps → works
```

### **2. Editor Configuration**

```
profiles/dev-focused/editors/
├── .vimrc            # Vim config
├── .vim/             # Vim plugins, colors
├── .config/nvim/     # Neovim config
└── .config/Code/     # VSCode settings
    └── User/
        ├── settings.json
        └── keybindings.json
```

**ATOM trail example:**
```
ATOM-CFG-20251114-021: Added vim-airline plugin
Intent: Better status bar (shows git branch, file encoding)
Source: https://github.com/vim-airline/vim-airline
Changes:
  - Plugin 'vim-airline/vim-airline'
  - Plugin 'vim-airline/vim-airline-themes'
  - let g:airline_theme='dark'
Test: Vim shows nice status bar ✅
Screenshot: atom-trail-screenshots/vim-airline.png
```

### **3. Git Configuration**

```
profiles/dev-focused/git/
├── .gitconfig        # Git settings
├── .gitignore_global # Global gitignore
└── .gitmessage       # Commit message template
```

**ATOM trail example:**
```
ATOM-CFG-20251114-022: Added global gitignore
Intent: Stop accidentally committing .DS_Store, node_modules
Source: https://github.com/github/gitignore/blob/main/Global/macOS.gitignore
Files ignored:
  - .DS_Store (macOS)
  - .idea/ (JetBrains IDEs)
  - .vscode/ (VSCode settings)
  - node_modules/ (JS dependencies)
Test: Created test repo, .DS_Store not tracked ✅
```

### **4. Development Tools**

```
profiles/dev-focused/devtools/
├── .tmux.conf        # Tmux config
├── .editorconfig     # Editor consistency
└── .tool-versions    # asdf version manager
```

**ATOM trail example:**
```
ATOM-CFG-20251114-023: Configured tmux with vim bindings
Intent: Navigate tmux panes like vim (hjkl)
Source: https://github.com/tmux-plugins/tmux-sensible
Changes:
  bind h select-pane -L  # Left
  bind j select-pane -D  # Down
  bind k select-pane -U  # Up
  bind l select-pane -R  # Right
Test: Ctrl+b h/j/k/l → pane navigation works ✅
Muscle memory: 2 days to adjust
```

---

## Advanced Features

### **1. Conditional Configuration**

Different configs for different machines:

```bash
# In .bashrc
if [[ "$HOSTNAME" == "work-laptop" ]]; then
    # ATOM-CFG-20251114-030: Work-specific aliases
    # Intent: Connect to work VPN, mount network drives
    alias vpn-connect='sudo openconnect vpn.work.com'
    alias mount-nas='mount -t cifs //nas.work.com/share /mnt/nas'
elif [[ "$HOSTNAME" == "home-desktop" ]]; then
    # ATOM-CFG-20251114-031: Personal machine aliases
    # Intent: Gaming, media server management
    alias start-plex='systemctl start plexmediaserver'
fi
```

### **2. Secret Management**

Don't commit secrets to dotfiles:

```bash
# In .gitconfig
[user]
    name = Your Name
    email = you@example.com
    # ATOM-CFG-20251114-040: Load GPG key from external file
    # Intent: Keep GPG key out of git history
    signingkey = !cat ~/.gnupg/signing-key-id

# Add to .gitignore
echo ".gnupg/" >> ~/.kenl/dotfiles/.gitignore
```

**ATOM trail records:**
```
ATOM-SEC-20251114-040: Externalized GPG signing key
Intent: Prevent accidental commit of private key
Security: Key stored in ~/.gnupg/ (not in git)
Backup: Key backed up to 1Password vault
Test: Git signing still works ✅
```

### **3. Cross-Platform Support**

Same dotfiles on macOS, Linux, Windows (WSL):

```bash
# In .bashrc
case "$(uname -s)" in
    Darwin*)
        # ATOM-CFG-20251114-050: macOS-specific
        # Intent: Homebrew, macOS tools
        export PATH="/opt/homebrew/bin:$PATH"
        alias updateall='brew update && brew upgrade'
        ;;
    Linux*)
        # ATOM-CFG-20251114-051: Linux-specific
        # Intent: Package manager commands
        alias updateall='sudo apt update && sudo apt upgrade'
        ;;
    MINGW*|MSYS*|CYGWIN*)
        # ATOM-CFG-20251114-052: Windows (Git Bash/WSL)
        # Intent: Windows-compatible commands
        alias open='explorer'
        ;;
esac
```

---

## SAIF Dotfiles Workflow

### **Daily Usage**

```bash
# Morning: Update dotfiles from git
cd ~/.kenl/dotfiles
git pull

# Apply any updates
./bootstrap.sh --profile dev-focused

# Work all day...

# Evening: Discovered new alias you want to keep
./edit-config.sh ~/.bash_aliases \
  --intent "Add kubectl alias for faster K8s debugging"

# ATOM trail automatically records change
# Git commit with: git commit -m "feat: add kubectl alias (ATOM-CFG-20251114-060)"
```

### **Weekly Review**

```bash
# View SAGE suggestions
./check-sage-suggestions.sh

# SAGE found 3 patterns:
# 1. You run "docker-compose up -d" in ~/projects/api 15 times/week
#    Suggest: alias api-start='cd ~/projects/api && docker-compose up -d'
# 2. You run "npm run test && npm run lint" before every commit
#    Suggest: Create pre-commit hook?
# 3. You switch between node v16 and v18 based on project
#    Suggest: Add .nvmrc files to projects?

# Accept suggestions you like
```

### **Monthly Cleanup**

```bash
# View ATOM trail
cat .atom-trail.log

# Find unused configs
grep "unused" .atom-trail.log

# Example:
# ATOM-CFG-20251014-010: Added vim-latex plugin
# Last used: 2025-10-15 (30 days ago)
# Suggest: Remove if still unused?

# Remove if no longer needed
./rollback.sh ATOM-CFG-20251014-010
```

---

## Sharing Your Dotfiles

### **Option 1: GitHub Public Repo**

```bash
# Fork SAIF dotfiles template
# Add your configs to profiles/your-name/

# Public .gitconfig (safe to share)
[user]
    name = Your Name
    email = you@example.com  # Public email
[alias]
    st = status
    co = checkout
# ... (no secrets)

# Share: https://github.com/yourusername/dotfiles
```

### **Option 2: Private Repo + Redacted Public**

```bash
# Private repo: Full dotfiles with secrets
# Classification: INTERNAL-ONLY
[user]
    name = Your Name
    email = you@work.com  # Work email
    signingkey = ABC123DEF456  # GPG key

# Public repo: Redacted version
# Classification: PUBLIC
./redact-dotfiles.sh --output public-dotfiles/

# Creates public version:
[user]
    name = Your Name
    email = [REDACTED]
    signingkey = [REDACTED]
[alias]
    st = status  # These are fine to share
    co = checkout
```

### **Option 3: Team-Shared Profiles**

```bash
# Company dotfiles repository
company-dotfiles/
├── profiles/
│   ├── backend-engineer/   # Python, Docker, K8s tools
│   ├── frontend-engineer/  # Node, npm, VSCode settings
│   └── devops-engineer/    # Terraform, AWS CLI, kubectl
└── README.md

# New hire onboarding:
git clone https://github.com/company/dotfiles.git ~/.kenl/dotfiles
cd ~/.kenl/dotfiles
./bootstrap.sh --profile backend-engineer

# Instant setup with company best practices
```

---

## Troubleshooting

### **Problem: Symlink conflicts**

```bash
# Error: ~/.vimrc already exists
# Solution 1: Backup first
./bootstrap.sh --backup-existing --profile dev-focused

# Solution 2: Force overwrite (careful!)
./bootstrap.sh --force --profile dev-focused

# Solution 3: Manual backup
mv ~/.vimrc ~/.vimrc.backup-$(date +%Y%m%d)
./bootstrap.sh --profile dev-focused
```

### **Problem: Config breaks after update**

```bash
# View recent ATOM trail
tail -n 20 .atom-trail.log

# Find breaking change
# ATOM-CFG-20251114-070: Updated vim plugin manager

# Rollback
./rollback.sh ATOM-CFG-20251114-070

# Or rollback via git
git log --oneline -5
git reset --hard abc1234
```

### **Problem: SAGE suggestions seem wrong**

```bash
# View SAGE confidence scores
./check-sage-suggestions.sh --verbose

# Pattern: "docker-compose down && docker-compose up"
# Confidence: 0.65 (below 0.80 threshold)
# Frequency: 3 times (low)
# Suggestion: Ignore (confidence too low)

# Adjust threshold if getting too many false positives
vim .sage-dotfiles.yaml
# Change: confidence_threshold: 0.75 → 0.85
```

---

## FAQ

**Q: Do I have to document every single config change?**
A: No. Use ATOM trails for significant changes. Minor tweaks (changing a color) can skip it.

**Q: Can I use this with my existing dotfiles?**
A: Yes! Import your existing dotfiles:
```bash
./import-existing-dotfiles.sh ~/my-old-dotfiles --profile my-profile
# Converts to SAIF format, asks for intent on import
```

**Q: What if I just want the ATOM trail part, not the full SAIF framework?**
A: Totally fine. Just use the `atom-trail` helper:
```bash
atom-trail "Added fzf.vim" --intent "Faster file finding" --file ~/.vimrc
# Appends to .atom-trail.log, that's it
```

**Q: Can SAIF work with dotfiles managers like GNU Stow, chezmoi, yadm?**
A: Yes, use SAIF for intent tracking, your existing manager for symlinks.

---

## Resources

**Example Dotfiles Using SAIF:**
- https://github.com/toolate28/kenl/tree/main/dotfiles (reference implementation)

**Dotfiles Inspiration:**
- https://dotfiles.github.io/ (community showcase)
- https://github.com/mathiasbynens/dotfiles (popular example)
- https://github.com/thoughtbot/dotfiles (thoughtbot's setup)

**SAIF Documentation:**
- [SAIF Framework](SAIF-FRAMEWORK.md) - Complete specification
- [NDA Workflow](SAIF-NDA-WORKFLOW.md) - Confidentiality management
- [Claude Landing](claude-landing/README.md) - AI agent guide

---

## Contributing

Found a useful pattern? Share your profile!

```bash
./export-profile.sh my-profile \
  --description "Your setup description" \
  --benchmarks "Tested on: macOS Sonoma, Ubuntu 22.04"

# Submit PR to: https://github.com/toolate28/kenl
```

---

**Happy dotfile managing!** 🚀

**ATOM:** ATOM-DOC-20251114-060
**Framework:** SAIF for Dotfiles v1.0.0
**Audience:** Software Developers, DevOps, SysAdmins
