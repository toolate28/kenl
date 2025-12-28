# CTFWI Verification Flags - Expected vs Reality

**Session**: Full Environment Verification
**Date**: 2025-12-28
**Method**: Capture The Flag With Intent
**ATOM**: ATOM-VERIFY-20251228-001

---

## Flag Categories

### Environment Configuration Flags

| Flag ID | Expectation | Validation | Complexity |
|---------|-------------|------------|------------|
| **ENV-01** | Command Center module exists and is valid PowerShell | `Test-Path env-config/KENL-CommandCenter.psm1; pwsh -Command "Test-ModuleManifest would work"` | Simple |
| **ENV-02** | Command Center installer exists | `Test-Path env-config/Install-CommandCenter.ps1` | Simple |
| **ENV-03** | WaveTerm profiles JSON is valid | `Test-Path env-config/waveterm-profiles.json; Get-Content | ConvertFrom-Json` | Simple |
| **ENV-04** | Windows Terminal profiles JSON is valid | `Test-Path env-config/windows-terminal-profiles.json; Get-Content | ConvertFrom-Json` | Simple |
| **ENV-05** | Startup script exists and has correct syntax | `Test-Path env-config/Start-KenlEnvironment.ps1; syntax check` | Moderate |
| **ENV-06** | VS Code workspace file is valid JSON | `Test-Path kenl-workspace.code-workspace; ConvertFrom-Json` | Simple |

### Service Status Flags

| Flag ID | Expectation | Validation | Complexity |
|---------|-------------|------------|------------|
| **SVC-01** | Claude Dashboard is running on port 3456 | `netstat -ano \| findstr ":3456.*LISTENING"` | Simple |
| **SVC-02** | Dashboard returns HTTP 200 | `curl -I http://localhost:3456` | Simple |
| **SVC-03** | Dashboard HTML contains "Claude Dashboard" title | `curl http://localhost:3456 \| Select-String "Claude Dashboard"` | Simple |
| **SVC-04** | SSE endpoint exists at /events | `curl -I http://localhost:3456/events` | Moderate |
| **SVC-05** | Hook log file exists | `Test-Path claude-bun-win11-hooks/.claude/hooks/hooks-log.txt` | Simple |

### Bun Hooks Flags

| Flag ID | Expectation | Validation | Complexity |
|---------|-------------|------------|------------|
| **BUN-01** | All 12 hook handlers exist | `ls claude-bun-win11-hooks/.claude/hooks/handlers/*.ts \| Count = 12` | Simple |
| **BUN-02** | package.json has correct scripts | `Get-Content package.json \| ConvertFrom-Json \| Check viewer script` | Simple |
| **BUN-03** | Bun runtime is installed and working | `bun --version` returns valid version | Simple |
| **BUN-04** | TypeScript files have no syntax errors | `cd hooks; bun run tsc --noEmit` (if available) | Moderate |
| **BUN-05** | Viewer server file exists | `Test-Path claude-bun-win11-hooks/.claude/hooks/viewer/server.ts` | Simple |

### ClaudeNPC Documentation Flags

| Flag ID | Expectation | Validation | Complexity |
|---------|-------------|------------|------------|
| **DOC-01** | GETTING_STARTED.md exists and is 370+ lines | `wc -l claudenpc-server-suite/GETTING_STARTED.md` | Simple |
| **DOC-02** | PROJECT_STATUS_REPORT.md exists (ClaudeNPC) | `Test-Path claudenpc-server-suite/PROJECT_STATUS_REPORT.md` | Simple |
| **DOC-03** | PROJECT_STATUS_REPORT.md exists (Bun Hooks) | `Test-Path claude-bun-win11-hooks/PROJECT_STATUS_REPORT.md` | Simple |
| **DOC-04** | COMMAND_CENTER_README.md exists | `Test-Path claudenpc-server-suite/COMMAND_CENTER_README.md` | Simple |
| **DOC-05** | ENVIRONMENT_READY.md exists | `Test-Path ENVIRONMENT_READY.md` | Simple |

### Configuration Validity Flags

| Flag ID | Expectation | Validation | Complexity |
|---------|-------------|------------|------------|
| **CFG-01** | WaveTerm config has 6 profiles | `(Get-Content waveterm-profiles.json \| ConvertFrom-Json).profiles.Count -eq 6` | Moderate |
| **CFG-02** | Windows Terminal config has 7 profiles | `(Get-Content windows-terminal-profiles.json \| ConvertFrom-Json).profiles.Count -eq 7` | Moderate |
| **CFG-03** | VS Code workspace has 4 folders | `(Get-Content kenl-workspace.code-workspace \| ConvertFrom-Json).folders.Count -eq 4` | Moderate |
| **CFG-04** | Command Center module exports functions | `Import-Module check for exported functions` | Moderate |

### Functional Execution Flags

| Flag ID | Expectation | Validation | Complexity |
|---------|-------------|------------|------------|
| **EXE-01** | PowerShell can parse Command Center module | `pwsh -Command "Get-Content env-config/KENL-CommandCenter.psm1 \| Out-Null"` | Simple |
| **EXE-02** | JSON configs parse without errors | `ConvertFrom-Json on all JSON files` | Simple |
| **EXE-03** | Dashboard server can be started | `bun run viewer starts without error` | Moderate |
| **EXE-04** | Installer script has valid PowerShell syntax | `Test script syntax` | Moderate |

---

## Validation Priority

### Critical (Must Pass)
- ENV-01, ENV-02, ENV-03, ENV-04, ENV-06
- SVC-01, SVC-02, SVC-03
- BUN-01, BUN-03
- DOC-01, DOC-02, DOC-05

### Important (Should Pass)
- ENV-05, SVC-04, SVC-05
- BUN-02, BUN-05
- CFG-01, CFG-02, CFG-03
- DOC-03, DOC-04

### Nice-to-Have (Can Fix Later)
- BUN-04, CFG-04
- EXE-01, EXE-02, EXE-03, EXE-04

---

## Flag Validation Results

*To be filled during verification*

### Passed Flags
```
✅ FLAG-ID: Description
```

### Failed Flags
```
🚩 FLAG-ID: Description
   Expected: [what docs said]
   Reality: [what we found]
   Impact: [does this break anything?]
   Fix: [how to correct]
```

### Partial Flags
```
⚠️ FLAG-ID: Description
   Status: Works but with caveats
   Note: [explanation]
```

---

**Flags Created**: 30 total
**Categories**: 6
**Next Step**: Run verification commands
