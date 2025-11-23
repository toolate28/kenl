---
title: iWINSTALL Interactive Wizard Builder
purpose: Extract Windows workflows and build slide-based post-install wizard
classification: CLAUDE-AGENT-PROMPT
atom: ATOM-RESEARCH-20251123-001
---

# iWINSTALL Builder - Agent Instructions

## Mission

Build an **interactive post-install wizard** for Windows 11 gaming setup that presents one slide at a time, showing exactly what the user will see in their terminal, with clear next steps and rollback instructions.

---

## Your Task

Extract Windows-only workflows from this repository and transform them into an **iWINSTALL** (interactive Windows Install) wizard with these characteristics:

### Slide Format (CRITICAL)

Each slide MUST:

1. **Show the actual terminal display** using box-drawing characters and formatting from `claude-landing/CLI-FORMATTING-STANDARDS.md`
2. **Present one action** (command, setting, download)
3. **Show expected result** (what success looks like visually)
4. **Provide next step** (if result matches expected)
5. **Provide rollback** (if result doesn't match or error occurs)

### Visual Requirements

- Use Unicode box-drawing characters (┌─┐, ╔═╗, etc.)
- Include status symbols (✓ ⚡ ❌ ⚠️ 📄 🔧 💾 🌐)
- Color indicators where appropriate (Green=success, Red=error, Yellow=warning)
- Format output EXACTLY as it would appear in PowerShell/cmd terminal
- Make it **scannable** - user should understand state at a glance

---

## Source Materials

### Primary Sources (Read These First)

1. **`scripts/WINDOWS_GAMING_ESSENTIALS.md`**
   - Core gaming libraries (DirectX, Visual C++, .NET)
   - GPU drivers (AMD Radeon)
   - Game launchers (Steam, EA App)
   - Performance monitoring (MSI Afterburner)
   - Windows optimizations (Game DVR, power plans)
   - BF6-specific settings
   - Automated setup script

2. **`scripts/windows-partition-scripts/README.md`**
   - 3-step partition workflow (STEP1-STEP3)
   - Disk safety checks
   - Partition layout (5 partitions: NTFS, ext4, exFAT)
   - Troubleshooting common issues
   - Handover document generation

3. **`scripts/windows-partition-scripts/WORKFLOW_DIAGRAM.md`**
   - Visual flowcharts (Mermaid diagrams)
   - Decision trees for disk operations
   - Error handling paths

4. **`scripts/windows-partition-scripts/PROFILES_SETUP.md`**
   - PowerShell profile automation
   - WSL2 safety warnings (DO NOT format disks in WSL2)
   - Helper functions for disk operations

5. **`claude-landing/LONG-TASK-PATTERN.md`**
   - How to run long-running tasks in separate windows
   - Status file patterns (RUNNING → SUCCESS/FAILED)
   - Progress monitoring templates

### Formatting Standards

6. **`claude-landing/CLI-FORMATTING-STANDARDS.md`**
   - Box-drawing templates (light, heavy, rounded, double-line)
   - Output types (reports, approvals, progress, errors)
   - ANSI color codes for PowerShell
   - Context-aware styling guide

### Disk Operations Scripts

7. **`scripts/windows-partition-scripts/STEP1-WINDOWS-WIPE-DISK1.ps1`**
   - Disk wipe with safety checks
   - Confirmation prompts
   - Handover document creation

8. **`scripts/windows-partition-scripts/STEP2-WINDOWS-PARTITION-DISK1.ps1`**
   - Partition creation (5 partitions)
   - Filesystem formatting (NTFS, exFAT)
   - Write testing
   - Error handling for "device not ready"

9. **`scripts/windows-partition-scripts/STEP3-WINDOWS-MOUNT-CHECK.ps1`**
   - Verification checks
   - Write access testing
   - Layout validation

10. **`scripts/Download-Bazzite-ISO.ps1`**
    - Long-task pattern implementation
    - Separate terminal window example
    - Status file usage

---

## Wizard Structure

Build the wizard in **phases**, each phase containing **slides**:

### Phase 1: Pre-Installation Checks (Slides 1-5)

**Goal:** Verify system readiness before making changes

**Slides:**
1. System information check (OS version, RAM, disk space)
2. PowerShell version check (5.1+ required)
3. Administrator privileges check
4. Disk inventory (identify external drive)
5. Pre-check summary + user confirmation

### Phase 2: Essential Software Installation (Slides 6-15)

**Goal:** Install critical gaming dependencies

**Slides:**
6. DirectX Runtime download + install
7. Visual C++ Redistributables (AIO repack recommended)
8. .NET Framework 4.8
9. .NET 8.0 Desktop Runtime
10. AMD Radeon drivers (or detect GPU and adjust)
11. Steam installation
12. EA App installation
13. MSI Afterburner + RivaTuner
14. Essential utilities (7-Zip, Notepad++)
15. Software installation summary

### Phase 3: Windows Optimizations (Slides 16-25)

**Goal:** Optimize Windows 11 for gaming performance

**Slides:**
16. Disable Xbox Game Bar
17. Disable Windows Search indexing (SSD check first)
18. Disable telemetry services
19. Disable Game DVR (registry edits)
20. Set High Performance power plan
21. Disable hibernation
22. Visual effects for best performance
23. Disable Game Mode
24. Network optimizations (TCP settings)
25. Windows optimization summary

### Phase 4: Disk Partitioning (Slides 26-35)

**Goal:** Partition external drive for hybrid Windows/Linux gaming

**⚠️ CRITICAL SAFETY WARNINGS ⚠️**

**Slides:**
26. Disk safety overview (WSL2 warning, backup reminder)
27. Disk inventory + target disk selection
28. Safety checks (verify not system disk)
29. **STEP1: Disk wipe** (with confirmation prompt)
30. Verify disk wipe success
31. **STEP2: Partition creation** (5 partitions)
32. Monitor partition creation progress
33. **STEP3: Verification** (layout + write tests)
34. Linux ext4 formatting instructions (to be done after reboot)
35. Disk setup complete summary

### Phase 5: Post-Install Configuration (Slides 36-45)

**Goal:** Configure applications and system settings

**Slides:**
36. AMD Radeon Software settings (Anti-Lag, Boost, FreeSync)
37. Steam settings (downloads, shader pre-caching)
38. EA App settings (disable overlay, set game library location)
39. MSI Afterburner OSD configuration
40. Windows Defender game folder exclusions
41. Verify all installations (checklist)
42. Create system restore point
43. Free up disk space (temp file cleanup)
44. Final system status check
45. Post-install complete + next steps

### Phase 6: Game-Specific Setup (Slides 46-50)

**Goal:** BF6-optimized settings

**Slides:**
46. BF6 in-game graphics settings (predicted recommendations)
47. BF6 advanced settings (DirectX 12, FSR)
48. Performance monitoring setup (OSD overlay)
49. Pre-launch checklist (close background apps, check temps)
50. Ready to game! 🎮

---

## Slide Template

Each slide MUST follow this exact structure:

```markdown
---
## Slide N: [Action Title]

**Phase:** [Phase Number] - [Phase Name]
**Estimated Time:** [X minutes]
**Risk Level:** [LOW/MEDIUM/HIGH]

### What You'll Do

[Clear explanation of the action in 1-2 sentences]

### Terminal Display

[Show EXACTLY what the user will see - use box drawing characters]

Example:
```
╔═══════════════════════════════════════════════════════════════════════╗
║  iWINSTALL - Windows 11 Gaming Setup Wizard                          ║
║  Phase 1/6: Pre-Installation Checks                                  ║
╚═══════════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────────┐
│ Action: Check PowerShell Version                                     │
└─────────────────────────────────────────────────────────────────────┘

Run this command:
> $PSVersionTable.PSVersion

Expected output:
Major  Minor  Build  Revision
-----  -----  -----  --------
5      1      XXXXX  XXX

✓ PowerShell 5.1 detected - ready to proceed
```
```

### Expected Result

**Success looks like:**
- ✓ [Specific success criterion 1]
- ✓ [Specific success criterion 2]
- ✓ [Specific success criterion 3]

**Example output:**
[Show example success output]

### Next Step

**If result matches:**
→ Proceed to Slide N+1: [Next Action Title]

**Command to continue:**
```powershell
# [Next command or "Press Enter to continue"]
```

### Rollback / Troubleshooting

**If result doesn't match:**

❌ **Error: [Specific error condition]**

**Cause:** [Why this happens]

**Fix:**
```powershell
# [Rollback command or recovery steps]
```

**Alternative:**
- [Alternative approach if fix doesn't work]

**Get Help:**
- Check documentation: [relevant file path]
- ATOM Tag: ATOM-XXX-YYYYMMDD-NNN
---
```

---

## Key Requirements

### 1. Visual Authenticity

Each slide must show **actual terminal output** - not pseudocode or descriptions. User should be able to:
- Copy-paste commands directly
- Compare their terminal output to the slide
- Instantly recognize success or failure visually

### 2. Safety First

For **HIGH RISK** operations (disk wipe, partition creation):
- **Triple-check** disk numbers
- Require explicit confirmation (e.g., "type WIPE DISK 1 to confirm")
- Show rollback for every risky operation
- Include WSL2 warnings where relevant

### 3. Long-Task Handling

For operations >30 seconds (downloads, disk formatting):
- Use long-task pattern from `LONG-TASK-PATTERN.md`
- Launch in separate terminal window
- Show status file monitoring
- Provide progress indicators

Example:
```powershell
# Launch download in new window
.\scripts\Download-Bazzite-ISO.ps1 -Variant kde

# Main window shows:
═══════════════════════════════════════
⚡ Download running in separate window
═══════════════════════════════════════
Status file: C:\Users\...\kenl-download-....status

Monitor progress in new terminal window
Press Enter when download completes...
```

### 4. Error Recovery

Every slide with potential errors must include:
- **Error condition** (what does failure look like?)
- **Cause** (why did it fail?)
- **Fix** (recovery command or manual steps)
- **Alternative** (if fix doesn't work)

### 5. ATOM Traceability

Each slide should reference relevant ATOM tags:
- Link to source documentation
- Include ATOM tag from original file
- Maintain audit trail for changes

---

## Output Format

### Deliverable 1: Master Wizard Document

**File:** `iWINSTALL-WIZARD-MASTER.md`

**Structure:**
```markdown
# iWINSTALL - Interactive Windows 11 Gaming Setup Wizard

[Introduction and overview]

## How to Use This Wizard

[Instructions for navigating slides]

## Table of Contents

[All 50 slides with links]

---

[All 50 slides in sequence using template above]

---

## Appendix A: Quick Reference

[Command cheat sheet]

## Appendix B: Troubleshooting Index

[Common errors and fixes]

## Appendix C: ATOM Traceability

[All ATOM tags referenced]
```

### Deliverable 2: Slide Index

**File:** `iWINSTALL-SLIDE-INDEX.md`

Quick navigation document:
```markdown
# iWINSTALL Slide Index

| Slide | Phase | Action | Risk | Time | Status |
|-------|-------|--------|------|------|--------|
| 1 | Pre-Check | System Info | LOW | 1m | ⬜ |
| 2 | Pre-Check | PowerShell Version | LOW | 1m | ⬜ |
[... all 50 slides ...]
```

### Deliverable 3: Automation Script

**File:** `iWINSTALL-Runner.ps1`

PowerShell script that:
- Presents slides one at a time
- Waits for user confirmation between slides
- Tracks completion status
- Saves progress (resume if interrupted)
- Generates final report

---

## Design Principles

### 1. One Thing at a Time

Each slide = **one action**. Don't combine multiple operations.

❌ BAD:
> Slide 10: Install DirectX, Visual C++, and .NET

✅ GOOD:
> Slide 6: Install DirectX Runtime
> Slide 7: Install Visual C++ Redistributables
> Slide 8: Install .NET Framework 4.8

### 2. Visual Before Verbal

Show the terminal output **first**, then explain. User should understand state from visuals alone.

### 3. Assume Zero Knowledge

User may not know:
- What DirectX is or why it's needed
- How to check if they have administrator privileges
- What a "partition" is

Explain **why** each action matters, not just **how** to do it.

### 4. Celebrate Progress

Each phase completion = small celebration:
```
╔═══════════════════════════════════════════════════════════════╗
║  ✓ Phase 2 Complete: Essential Software Installation         ║
║                                                               ║
║  Installed: DirectX, Visual C++, .NET, GPU drivers,          ║
║            Steam, EA App, MSI Afterburner, utilities         ║
║                                                               ║
║  Next: Phase 3 - Windows Optimizations (10 slides)          ║
╚═══════════════════════════════════════════════════════════════╝
```

### 5. Always Provide Exit

Every slide should have:
- Continue → next slide
- Skip → jump to next phase
- Quit → save progress and exit

---

## Special Instructions

### Handling GPU Detection

Don't assume AMD GPU. Detect and adapt:

```powershell
$GPU = Get-WmiObject Win32_VideoController | Select -ExpandProperty Name

if ($GPU -match "AMD|Radeon") {
    Write-Host "✓ AMD GPU detected - will install Radeon drivers"
} elseif ($GPU -match "NVIDIA|GeForce") {
    Write-Host "✓ NVIDIA GPU detected - will install GeForce drivers"
} elseif ($GPU -match "Intel") {
    Write-Host "⚠️  Intel integrated GPU - gaming performance limited"
} else {
    Write-Host "❓ GPU: $GPU - manual driver installation required"
}
```

### Handling Disk Numbers

NEVER hardcode "Disk 1" - always prompt user to verify:

```powershell
Get-Disk | Format-Table Number, FriendlyName, Size, PartitionStyle -AutoSize

Write-Host ""
Write-Host "⚠️  CRITICAL: Verify your external drive disk number above" -ForegroundColor Yellow
Write-Host ""
$diskNum = Read-Host "Enter external drive disk number"
```

### WSL2 Safety Blocks

Every disk operation slide must include:

```
⚠️  CRITICAL SAFETY WARNING ⚠️

❌ NEVER run disk partitioning from WSL2
✅ ALWAYS use native Windows PowerShell

Running from WSL2 will cause DATA CORRUPTION.
```

---

## Success Criteria

Your wizard is successful if:

1. ✅ A complete beginner can follow it without getting stuck
2. ✅ Every slide shows actual terminal output (not descriptions)
3. ✅ Every risky operation has rollback instructions
4. ✅ All 50 slides maintain consistent visual formatting
5. ✅ Long-running tasks use separate terminal windows
6. ✅ GPU and disk configurations are dynamic (not hardcoded)
7. ✅ All ATOM tags are traceable to source documents
8. ✅ User can resume if interrupted (progress tracking)

---

## Testing Protocol

After building the wizard:

1. **Visual Test:** Check first 5 slides - do box characters render correctly?
2. **Safety Test:** Verify all HIGH RISK slides have confirmation prompts
3. **Rollback Test:** Verify every slide with errors includes recovery steps
4. **Link Test:** Check all ATOM tag references resolve to actual files
5. **Flow Test:** Walk through Phase 1 end-to-end - does navigation work?

---

## Example: Complete Slide

Here's a fully-formed example slide to guide your work:

```markdown
---
## Slide 6: Install DirectX Runtime

**Phase:** 2/6 - Essential Software Installation
**Estimated Time:** 3-5 minutes
**Risk Level:** LOW

### What You'll Do

Install Microsoft DirectX End-User Runtime, which is required by almost all modern games including BF6. This provides the graphics APIs games use to render 3D graphics.

### Terminal Display

```
╔═══════════════════════════════════════════════════════════════════════╗
║  iWINSTALL - Windows 11 Gaming Setup Wizard                          ║
║  Phase 2/6: Essential Software Installation                           ║
║  Slide 6/50: Install DirectX Runtime                                 ║
╚═══════════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────────┐
│ 📦 Installing: DirectX End-User Runtime                              │
└─────────────────────────────────────────────────────────────────────┘

Step 1: Download installer
> Invoke-WebRequest -Uri "https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe" -OutFile "$env:TEMP\dxwebsetup.exe"

Downloading...
[████████████████████████████████████████] 100% (291 KB)

✓ Downloaded to: C:\Users\...\AppData\Local\Temp\dxwebsetup.exe

Step 2: Run installer
> Start-Process "$env:TEMP\dxwebsetup.exe" -Wait

[DirectX installer window will open]
- Click "I accept the agreement"
- Click "Next"
- Wait for download and installation (2-3 minutes)
- Click "Finish"

Step 3: Verify installation
> dxdiag /t "$env:TEMP\dxdiag.txt" && Select-String "DirectX Version" "$env:TEMP\dxdiag.txt"

DirectX Version: DirectX 12

✓ DirectX 12 installed successfully
```
```

### Expected Result

**Success looks like:**
- ✓ Download completes (291 KB file)
- ✓ Installer runs without errors
- ✓ `dxdiag` shows "DirectX 12"

**Example output:**
```
DirectX Version: DirectX 12
```

### Next Step

**If result matches:**
→ Proceed to Slide 7: Install Visual C++ Redistributables

**Command to continue:**
```powershell
Write-Host "✓ DirectX installed" -ForegroundColor Green
Write-Host "Press Enter to continue to next step..."
Read-Host
```

### Rollback / Troubleshooting

**If download fails:**

❌ **Error:** `Invoke-WebRequest : Unable to connect to the remote server`

**Cause:** Network connectivity issue or Microsoft servers down

**Fix:**
```powershell
# Option 1: Download manually via browser
Start-Process "https://www.microsoft.com/en-us/download/details.aspx?id=35"
# Download and run manually
```

**Alternative:**
- DirectX 12 is built into Windows 10/11 - if `dxdiag` shows DX12, you're already set
- Skip this step if verification passes

**If dxdiag shows older version:**

❌ **Error:** `DirectX Version: DirectX 11`

**Cause:** Windows Update hasn't installed DX12 feature

**Fix:**
```powershell
# Run Windows Update
Start-Process ms-settings:windowsupdate
# Install all updates, then reboot and re-check
```

**Get Help:**
- Documentation: `scripts/WINDOWS_GAMING_ESSENTIALS.md:22-39`
- ATOM Tag: ATOM-CFG-20251107-022
---
```

---

## Your Checklist

Before you submit the wizard:

- [ ] All 50 slides created using exact template
- [ ] Every slide shows actual terminal output with box characters
- [ ] All HIGH RISK slides have safety warnings and confirmations
- [ ] Every error condition includes rollback instructions
- [ ] Long-running tasks (>30s) use separate terminal windows
- [ ] GPU detection is dynamic (AMD/NVIDIA/Intel)
- [ ] Disk operations prompt user to verify disk numbers
- [ ] WSL2 warnings present on all disk operation slides
- [ ] All ATOM tags link to source files
- [ ] Progress tracking implemented in runner script
- [ ] Master document includes Table of Contents
- [ ] Slide index created with completion checkboxes
- [ ] Quick reference appendix with command cheat sheet
- [ ] Troubleshooting index with common errors

---

## Final Notes

**Remember:** This wizard will be used by someone who may have **zero** technical experience. They should be able to:
- Follow it without asking questions
- Understand what's happening at each step
- Recover from errors without panic
- See their progress visually
- Feel confident about risky operations (because rollback is always provided)

**Your goal:** Make Windows 11 gaming setup **boring** - so routine and well-documented that nothing can go wrong. And when something does go wrong, recovery is **obvious** from the slide itself.

---

**ATOM Tag:** ATOM-RESEARCH-20251123-001
**Classification:** CLAUDE-AGENT-PROMPT
**Version:** 1.0.0
**Last Updated:** 2025-11-23

---

## Start Working

Read the source materials in this order:

1. `claude-landing/CLI-FORMATTING-STANDARDS.md` - Learn visual templates
2. `scripts/WINDOWS_GAMING_ESSENTIALS.md` - Core content for Phase 2-3
3. `scripts/windows-partition-scripts/README.md` - Core content for Phase 4
4. `claude-landing/LONG-TASK-PATTERN.md` - Learn async operation patterns
5. All PowerShell scripts in `scripts/windows-partition-scripts/` - Extract commands

Then build all 50 slides following the template exactly.

**Good luck!** 🚀
