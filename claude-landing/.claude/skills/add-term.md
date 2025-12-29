# Add Term (Dynamic Terminology)

Add terminology, aliases, skills, or patterns to KENL/SAIF on the fly.

## Usage

The skill wraps `Add-Terminology.ps1` to provide dynamic vocabulary expansion.

**Via Claude Code:**
```bash
/add-term
```

**Direct PowerShell:**
```powershell
# Add a new term
.\Add-Terminology.ps1 -Type Term -Name "HTTPTimeout408" -Definition "Request timeout error - server-side issue or network congestion" -Category "Network" -Evidence "First observed 2025-12-29 during git push"

# Add an alias
.\Add-Terminology.ps1 -Type Alias -Name "atomview" -Definition "View-AtomTrail.ps1"

# Add a Claude skill
.\Add-Terminology.ps1 -Type Skill -Name "analyze-logs" -Definition "Analyze system logs for patterns" -CreateSkill

# Add a quick function
.\Add-Terminology.ps1 -Type Function -Name "Test-Connectivity" -Definition "Quick network connectivity test" -CreateAlias

# Add a pattern
.\Add-Terminology.ps1 -Type Pattern -Name "DashboardIntegration" -Definition "Real-time data display in web UI" -Example "Logdy ATOM trail -> Claude hooks dashboard"
```

## Types

| Type | Creates | Updates |
|------|---------|---------|
| `Term` | TERMINOLOGY.md entry | Optional skill |
| `Alias` | PowerShell alias + term | Command Center module |
| `Skill` | Claude Code skill + term | .claude/skills/ |
| `Function` | PowerShell function + term | quick-functions/ |
| `Pattern` | Design pattern entry | TERMINOLOGY.md |

## Switches

- `-CreateSkill` - Also create Claude Code skill
- `-CreateAlias` - Also create PowerShell alias
- `-DryRun` - Preview changes without applying

## Integration

- ✅ Automatically updates TERMINOLOGY.md
- ✅ Writes ATOM trail entry
- ✅ Supports Command Center module aliases
- ✅ Creates Claude Code skills
- ✅ Git-trackable (all changes in files)

## Examples

### Add Network Term (HTTP 408)
```powershell
.\Add-Terminology.ps1 -Type Term -Name "HTTP408Timeout" `
  -Definition "Request timeout - rare GitHub error, likely rate limit or security measure" `
  -Category "Network Diagnostics" `
  -Evidence "Observed during git push 2025-12-29, 5 commits pending" `
  -Example "git push origin main -> HTTP 408 curl 22"
```

### Add Dashboard Pattern
```powershell
.\Add-Terminology.ps1 -Type Pattern -Name "LogdyDashboardIntegration" `
  -Definition "Display Logdy ATOM trail in Claude hooks dashboard for real-time monitoring" `
  -Example "Fetch .atom-trail via API, display in Vue.js component with auto-refresh"
```

### Add Quick Alias
```powershell
.\Add-Terminology.ps1 -Type Alias -Name "at" -Definition "Write-AtomTrail.ps1"
```

## Created

- **Date:** 2025-12-29
- **Tool:** Add-Terminology.ps1
- **Purpose:** Dynamic vocabulary expansion for KENL/SAIF + Claude Code collaboration

## Notes

This skill enables the "living document" pattern from TERMINOLOGY.md - both humans and AI can extend the shared vocabulary in real-time.
