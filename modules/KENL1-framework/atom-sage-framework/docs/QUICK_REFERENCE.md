# ATOM+SAGE Quick Reference Card

**Version 1.0.0** | Print this page for your desk!

---

## Essential Commands

```bash
# Create ATOM tags
atom TYPE "intent description"

# View trail summary
atom-analytics --summary

# Show last 10 operations
atom-analytics --last 10

# Recovery after crash
atom-analytics --recovery
```

---

## Common ATOM Types

| Type | Usage | Example |
|------|-------|---------|
| `STATUS` | Project status | `atom STATUS "Starting feature X"` |
| `CFG` | Configuration | `atom CFG "Configure database"` |
| `DEV` | Development | `atom DEV "Implement auth module"` |
| `TEST` | Testing | `atom TEST "Write unit tests"` |
| `DOC` | Documentation | `atom DOC "Update API docs"` |
| `TASK` | TODO items | `atom TASK "TODO: Fix bug #123"` |
| `DEPLOY` | Deployments | `atom DEPLOY "Deploy v1.0 to prod"` |
| `GWI` | Gaming | `atom GWI "Validate BG3 Play Card"` |

---

## CTFWI Pattern

**"Checked The Flags, What Intent?"** - Force AI validation

```bash
# Without CTFWI (risky)
atom DEPLOY "Deploy to production"

# With CTFWI (safe)
atom DEPLOY "Deploy to prod - CTFWI: Confirm tests pass first"
```

---

## Recovery Workflow

**After System Crash**:

1. ```bash
   atom-analytics --recovery
   ```
2. Review what was in progress
3. ```bash
   atom STATUS "Recovered from crash - continuing [task]"
   ```
4. Resume work

**That's it!** ATOM trail handles the rest.

---

## File Locations

```
~/.local/bin/atom              # Main command
~/.local/bin/atom-analytics    # Analytics

~/.config/atom-sage/
  └── trails/
      └── atom_trail.log       # Your audit trail
```

---

## Play Card Tools (Bazzite)

```bash
# Redact sensitive info
./tools/redact-playcard.sh card.yaml --output card-public.yaml

# Encrypt for sharing
gpg --encrypt --sign -r email@example.com card-public.yaml

# Validate format
./tools/validate-playcard.sh card.yaml

# Send via mailbox
./tools/send-playcard.sh --playcard card.yaml --recipient friend@example.com --mailbox --encrypt
```

---

## Common Patterns

**Daily Standup**:
```bash
atom STATUS "Daily standup: $(date +%Y-%m-%d)"
atom STATUS "Yesterday: [what you did]"
atom STATUS "Today: [what you're doing]"
atom STATUS "Blockers: [any blockers]"
```

**Before/After Optimization**:
```bash
atom STATUS "Baseline: 45fps, high CPU"
# ... make changes ...
atom STATUS "Optimized: 60fps, lower CPU (+33% improvement)"
```

**Troubleshooting**:
```bash
atom STATUS "Issue: [problem description]"
atom CFG "Attempted fix: [what you tried]"
atom STATUS "Result: [did it work?]"
```

---

## Emergency Recovery

**Minimal Input Recovery**:
```bash
atom STATUS "Continue from crash"
# That's literally all you need!
```

**View Recent Context**:
```bash
atom-analytics --last 20
atom-analytics --type DEV     # Development work
atom-analytics --type CFG     # Configuration changes
atom-analytics --pending      # TODO items
```

---

## Keyboard Shortcuts (Add to ~/.bashrc)

```bash
alias as='atom STATUS'
alias ad='atom DEV'
alias at='atom TASK'
alias aa='atom-analytics'
alias aar='atom-analytics --recovery'
```

Then use:
```bash
as "Quick status update"
ad "Implementing feature"
at "TODO: Write tests"
aar  # Quick recovery check
```

---

## Troubleshooting

**Command not found**:
```bash
source ~/.bashrc  # or ~/.zshrc
```

**Check installation**:
```bash
which atom
ls -la ~/.config/atom-sage/trails/
```

**View raw trail**:
```bash
tail -20 ~/.config/atom-sage/trails/atom_trail.log
```

---

## Devcontainer (Bazzite)

```bash
# Start devcontainer
cd ~/Projects/kenl/atom-sage-framework
podman-compose -f .devcontainer/docker-compose.yml up -d

# Enter container
podman exec -it atom-sage-dev bash

# Inside: ATOM works same as host
atom STATUS "Working in devcontainer"
```

---

## Help Resources

- **User Manual**: `docs/USER_MANUAL.md` (210+ pages)
- **Getting Started**: `docs/GETTING_STARTED.md` (15 minutes)
- **Examples**: Run `./examples/basic-workflow.sh`
- **GitHub Issues**: https://github.com/toolate28/kenl/issues

---

## The Meta-Validation

**Remember**: On 2025-11-06, ATOM+SAGE validated itself by recovering from a crash **that interrupted its own development**.

7 minutes. 147 characters. 100% recovery.

**It works.**

---

**Print this reference card | Keep at your desk | Share with your team**

Version 1.0.0 | MIT License | https://github.com/toolate28/kenl
