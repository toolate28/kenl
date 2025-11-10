# Git Cheatsheet

Quick reference for common Git operations.

## Basic Commands

```bash
# Initialize repository
git init

# Clone repository
git clone <url>

# Check status
git status

# View changes
git diff
git diff --staged  # Staged changes only
```

## Staging and Committing

```bash
# Stage files
git add <file>
git add .  # Stage all changes
git add -p  # Interactive staging

# Commit changes
git commit -m "commit message"
git commit -am "message"  # Stage + commit modified files
git commit --amend  # Amend last commit

# Unstage files
git restore --staged <file>

# Discard changes
git restore <file>
git restore .  # Discard all changes
```

## Branching

```bash
# List branches
git branch
git branch -a  # Include remote branches

# Create branch
git branch <name>
git checkout -b <name>  # Create and switch
git switch -c <name>  # Modern syntax

# Switch branches
git checkout <name>
git switch <name>  # Modern syntax

# Delete branch
git branch -d <name>  # Safe delete
git branch -D <name>  # Force delete

# Merge branch
git merge <branch>
git merge --no-ff <branch>  # Create merge commit
```

## Remote Operations

```bash
# Add remote
git remote add origin <url>

# List remotes
git remote -v

# Fetch changes
git fetch
git fetch origin

# Pull changes
git pull
git pull --rebase  # Rebase instead of merge

# Push changes
git push
git push -u origin <branch>  # Set upstream
git push --force-with-lease  # Safe force push

# Track remote branch
git branch --set-upstream-to=origin/<branch>
```

## History and Logs

```bash
# View commit history
git log
git log --oneline  # Compact view
git log --graph --oneline --all  # Visual graph
git log -p  # Show diff in each commit
git log --since="2 weeks ago"

# View specific file history
git log <file>
git log -p <file>

# Show commit
git show <commit>
git show HEAD  # Last commit

# Search commits
git log --grep="search term"
git log -S "code search"  # Search code changes
```

## Undoing Changes

```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Revert commit (create new commit)
git revert <commit>

# Reset to specific commit
git reset --hard <commit>

# Clean untracked files
git clean -n  # Dry run
git clean -fd  # Force remove files and directories
```

## Stashing

```bash
# Stash changes
git stash
git stash save "description"

# List stashes
git stash list

# Apply stash
git stash apply  # Keep stash
git stash pop  # Apply and remove stash
git stash apply stash@{0}  # Apply specific stash

# Drop stash
git stash drop
git stash clear  # Remove all stashes
```

## Tagging

```bash
# Create tag
git tag <name>
git tag -a v1.0.0 -m "Version 1.0.0"  # Annotated tag

# List tags
git tag
git tag -l "v1.*"  # Filter tags

# Push tags
git push origin <tag>
git push origin --tags  # Push all tags

# Delete tag
git tag -d <tag>  # Local
git push origin :refs/tags/<tag>  # Remote
```

## Rebase

```bash
# Rebase current branch
git rebase <branch>
git rebase -i HEAD~3  # Interactive rebase last 3 commits

# Continue after resolving conflicts
git rebase --continue

# Abort rebase
git rebase --abort

# Skip commit
git rebase --skip
```

## Configuration

```bash
# Set user info
git config --global user.name "Your Name"
git config --global user.email "you@example.com"

# Set default editor
git config --global core.editor "vim"

# Set default branch name
git config --global init.defaultBranch main

# List config
git config --list
git config --global --list

# Aliases
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
```

## Useful Aliases

Add to `~/.gitconfig`:

```ini
[alias]
    st = status
    co = checkout
    br = branch
    ci = commit
    unstage = restore --staged
    last = log -1 HEAD
    visual = log --graph --oneline --all
    amend = commit --amend --no-edit
```

## Tips

### Ignore files
Create `.gitignore`:
```
*.log
node_modules/
.env
```

### Force push safely
```bash
git push --force-with-lease
```

### Find who changed a line
```bash
git blame <file>
git blame -L 10,20 <file>  # Lines 10-20
```

### Cherry-pick commits
```bash
git cherry-pick <commit>
```

### Show file at specific commit
```bash
git show <commit>:<file>
```

## See Also

- [Git documentation](https://git-scm.com/doc)
- [GitHub Git cheatsheet](https://education.github.com/git-cheat-sheet-education.pdf)
- KENL7 Git tutorial: `../tutorials/git-basics.md`
