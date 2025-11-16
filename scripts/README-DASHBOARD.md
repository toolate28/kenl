---
title: KENL Dashboard - Usage Guide
atom: ATOM-DOC-20251116-003
---

# KENL Dashboard Usage Guide

## Quick Start

```bash
# Run dashboard (interactive display)
./scripts/kenl-dashboard.sh

# JSON output (for scripts/APIs)
./scripts/kenl-dashboard.sh --json

# Parse with jq
./scripts/kenl-dashboard.sh --json | jq '.services'
```

---

## What It Shows

### 🖥️ Live System Status
- **Platform:** Current OS (Linux/Windows/macOS)
- **Hostname:** System name
- **Local IP:** Private network address
- **Public IP:** External IP (if available)
- **Git Branch:** Current working branch
- **Disk Usage:** Repository disk consumption

### ⚙️ Services
- **Logdy:** Web dashboard status (port 8080)
- **Tailscale:** VPN service status
- **Ollama:** Local AI inference server

### 📊 Repository Health
- **Documentation Score:** 0-100 based on structure quality
- **Code Reusability:** % of code that's not rework/deletions
- **Clicks to Confidence:** Avg navigation steps to find resources
- **Total Docs:** Markdown file count
- **ATOM Tagged:** Documents with ATOM trail tags
- **Modules:** KENL module count (should be 14)
- **Play Cards:** Verified gaming configurations

### 📝 Recent Activity
- **Last 3 ATOM Trails:** Most recently modified ATOM-tagged files
- **Last 3 Commits:** Recent git commits with timestamp and author

---

## Integration Options

### 1. Session Start Hook (Manual Setup)

To show the dashboard automatically on every session start, create a shell hook file in your user-space environment:

```bash
# Create a session start hook for KENL dashboard
mkdir -p ~/.kenl/hooks
cat <<'EOF' > ~/.kenl/hooks/session-dashboard.sh
#!/usr/bin/env bash
# ATOM-HOOK-20251116-001
./scripts/kenl-dashboard.sh
EOF
chmod +x ~/.kenl/hooks/session-dashboard.sh
```

**Expected:** `SAIF-HOOK-DASHBOARD-20251116-001` (CTFWI flag drop)

**Result:** Dashboard shows automatically on every session start (when sourced by your shell or session manager)

**Rollback:** Remove the hook file:

```bash
rm ~/.kenl/hooks/session-dashboard.sh
```
To show the dashboard automatically on every session start, create a shell hook file in your user-space environment:

```bash
# Create a session start hook for KENL dashboard
mkdir -p ~/.kenl/hooks
cat <<'EOF' > ~/.kenl/hooks/session-dashboard.sh
#!/usr/bin/env bash
# ATOM-HOOK-20251116-001
./scripts/kenl-dashboard.sh
EOF
chmod +x ~/.kenl/hooks/session-dashboard.sh
---

### 2. Slash Command (Planned Feature)

> **Note:** The slash command integration is not yet implemented.
> This section describes a planned feature for future releases.

**Planned Usage:**
```bash
# Future command (not yet available)
kenl-add-slash-command status dashboard
```

**Expected:** `SAIF-CMD-STATUS-20251116-001` (CTFWI flag drop)

**Planned:** Once implemented, typing `/status` will refresh the dashboard

---

### 3. Watch Mode (Continuous)

```bash
# Auto-refresh every 5 seconds
watch -n 5 ./scripts/kenl-dashboard.sh

# Or use a terminal multiplexer
tmux new-session -d './scripts/kenl-dashboard.sh; sleep 5'
```

**Use case:** Keep dashboard on second monitor for live monitoring.

---

## Customization

### Add Custom Metrics

Edit `kenl-dashboard.sh` and add to `get_repo_stats()`:

```bash
get_repo_stats() {
    local total_docs=$(find "$REPO_ROOT" -name "*.md" -type f 2>/dev/null | wc -l)
    local atom_docs=$(grep -r "^atom:" "$REPO_ROOT" --include="*.md" 2>/dev/null | wc -l)
    local modules=$(find "$REPO_ROOT/modules" -maxdepth 1 -type d -name "KENL*" 2>/dev/null | wc -l)
    local play_cards=$(find "$REPO_ROOT" -path "*/play-cards/*.yaml" -type f 2>/dev/null | wc -l)

    # ADD YOUR CUSTOM METRIC HERE
    local custom_metric=$(your_command_here)

    echo "$total_docs|$atom_docs|$modules|$play_cards|$custom_metric"
}
```

---

### Add Custom Services

Edit `check_service_status()` to add new services:

```bash
check_service_status() {
    local service="$1"

    case "$service" in
        # ... existing services ...

        your-service)
            # Check if your service is running
            if pgrep -f "your-service" >/dev/null 2>&1; then
                echo "UP"
                return 0
            fi
            echo "DOWN"
            return 1
            ;;

        # ... rest of cases ...
    esac
}
```

Then add to the render section:

```bash
local your_service_status=$(check_service_status your-service)

if [[ "$your_service_status" == "UP" ]]; then
    echo -e "  Your Service:  ${GREEN}$CHECK $your_service_status${RESET}"
else
    echo -e "  Your Service:  ${GRAY}$CROSS $your_service_status${RESET}"
fi
```

---

## Programmatic Use (JSON API)

### Parse with jq

```bash
# Get only network info
./scripts/kenl-dashboard.sh --json | jq '.network'

# Check if Ollama is running
OLLAMA_STATUS=$(./scripts/kenl-dashboard.sh --json | jq -r '.services.ollama')
if [[ "$OLLAMA_STATUS" == "UP" ]]; then
    echo "Ollama is running, proceed with AI task"
fi

# Get current branch
BRANCH=$(./scripts/kenl-dashboard.sh --json | jq -r '.git.branch')
echo "Current branch: $BRANCH"
```

---

### Use in Scripts

```bash
#!/bin/bash
# Example: Auto-deploy only if on correct branch

DASHBOARD_JSON=$(./scripts/kenl-dashboard.sh --json)
CURRENT_BRANCH=$(echo "$DASHBOARD_JSON" | jq -r '.git.branch')

if [[ "$CURRENT_BRANCH" != "main" ]]; then
    echo "❌ Error: Not on main branch (currently on $CURRENT_BRANCH)"
    exit 1
fi

echo "✅ On main branch, proceeding with deployment..."
```

---

## Performance

**Execution time:** ~2 seconds (including network calls)

**Breakdown:**
- Local metrics: <100ms (git, filesystem)
- Service checks: ~500ms (port scans)
- Public IP lookup: ~1s (optional, can be disabled)

**Optimization:**
- Skip public IP if not needed: Comment out `get_public_ip` call
- Cache results: Add timestamp check to avoid re-checking services
- Parallel execution: Background jobs for slow checks

---

## Troubleshooting

### Dashboard shows wrong IP

**Cause:** Multiple network interfaces or VPN active

**Fix:** Edit `get_local_ip()` to filter specific interface:

```bash
# Linux: Get specific interface
ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+\.\d+\.\d+\.\d+'

# Windows: Get specific adapter
ipconfig | findstr /C:"Ethernet adapter" /C:"IPv4"
```

---

### Service shows as DOWN when it's UP

**Cause:** Service running on non-standard port

**Fix:** Update port check in `check_service_status()`:

```bash
logdy)
    # Change 8080 to your Logdy port
    if lsof -i :8080 -sTCP:LISTEN >/dev/null 2>&1; then
        echo "UP (port 8080)"
        return 0
    fi
    ;;
```

---

### ATOM trails not showing

**Cause:** ATOM tags not in standard format

**Expected format:**
```yaml
---
atom: ATOM-TYPE-YYYYMMDD-NNN
---
```

**Fix:** Ensure ATOM tags use `atom:` prefix (lowercase) in YAML frontmatter.

---

## FAQ

### Q: Can I run this on Windows?

**A:** Yes! The script is compatible with Git Bash (comes with Git for Windows).

```cmd
# Run in Git Bash (not PowerShell)
bash scripts/kenl-dashboard.sh
```

---

### Q: Does this send data anywhere?

**A:** The only external network calls are made by `get_public_ip()` which queries `https://api.ipify.org` or `https://ifconfig.me` to determine your public IP address.

**Privacy consideration:** This external call may reveal your public IP to these services. All other data is collected locally.

**To disable public IP lookup:**
```bash
# Set environment variable before running
export KENL_SKIP_PUBLIC_IP=1
./scripts/kenl-dashboard.sh

# Or add to your shell profile (~/.bashrc, ~/.zshrc)
echo 'export KENL_SKIP_PUBLIC_IP=1' >> ~/.bashrc
```

---

### Q: Can I export dashboard as HTML?

**A:** Not yet, but planned for Phase 2. Current workaround:

```bash
# Use ANSI-to-HTML converter
./scripts/kenl-dashboard.sh | ansi2html > dashboard.html
```

---

## Related Documentation

- **Value Proposition:** `claude-landing/DASHBOARD-VALUE-PROPOSITION.md`
- **ATOM Framework:** `modules/KENL1-framework/atom-sage-framework/README.md`
- **Repository Health:** `claude-landing/AI-MAINTENANCE-GUIDE.md`

---

**ATOM:** ATOM-DOC-20251116-003
**Maintainer:** KENL Project
**Version:** 1.0.0
