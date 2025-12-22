# PowerShell Environment Guide - What You'll See

**Date:** December 9, 2025
**Purpose:** Explain your PowerShell environment on startup

---

## When You Open PowerShell, You'll See:

### 1. **Oh My Posh Theme (Atomic)**

Your prompt will look something like this:

```
┌─[✓]─[iamto@WIN11-AMD0]─[~]
└─❯
```

**Theme:** `atomic` - Clean, informative theme showing:
- ✓ Last command success/failure
- Username@Computer
- Current directory
- Git branch (when in a git repo)

**Colors:**
- Blue/Cyan for paths
- Green for successful commands
- Red for errors
- Yellow for git branches

---

### 2. **Welcome Banner**

Every time you open PowerShell, you'll see:

```
╔══════════════════════════════════════════════════════════════════════╗
║                                                                      ║
║            Good Morning, iamto!                                      ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝

  📁 Location:    C:\Users\iamto
  📅 Date:        Monday, December 09, 2025
  🕒 Time:        17:30:45
  🎮 Server:      RUNNING (4521MB, up 2h 15m)
                  ^- Or "STOPPED (use 'mcstart' to start)"

  💡 Quick Commands:
     mcstatus       → Server status dashboard
     mcstart/mcstop → Start/stop server
     cnpc           → Go to ClaudeNPC directory
     sysinfo        → System information

  ✓ Profile loaded in 245ms
```

**What Each Line Shows:**
- 📁 **Location** - Your current directory
- 📅 **Date** - Current date (formatted nicely)
- 🕒 **Time** - Current time
- 🎮 **Server** - Minecraft server status (RUNNING or STOPPED)
  - If running: Shows memory usage and uptime
  - If stopped: Suggests command to start it
- 💡 **Quick Commands** - Most useful commands
- ✓ **Load Time** - How fast your profile loaded

---

## 3. **Available Modules**

### Modules That Will Be Loaded:

| Module | Status | Purpose |
|--------|--------|---------|
| **PSReadLine** | ✓ Auto-loaded | Enhanced command-line editing |
| **posh-git** | ✓ Auto-loaded | Git integration in prompt |
| **Terminal-Icons** | ○ If installed | Pretty file icons |

### Module Features You Get:

**PSReadLine Features:**
- ⬆️ **Up Arrow** - Search command history (type partial command first!)
- **Tab** - Menu completion (shows all options)
- **Ctrl+D** - Exit PowerShell (like bash)
- **Predictive IntelliSense** - Suggests commands as you type (PowerShell 7+)
- **Syntax Highlighting** - Commands in cyan, strings in yellow

**posh-git Features:**
- Git branch shows in prompt when in git repo
- Tab completion for git commands
- Git status indicators in prompt

---

## 4. **Quick Command Reference**

### Navigation Shortcuts

```powershell
kenl    → cd C:\Users\iamto\.kenl
cl      → cd C:\Users\iamto\.kenl\claude-landing
cnpc    → cd C:\Users\iamto\.kenl\claude-landing\claudenpc-server-suite
mcdir   → cd C:\MinecraftServer

..      → Go up one directory
...     → Go up two directories
....    → Go up three directories
```

### Minecraft Server Commands

```powershell
mcstart         → Start the ClaudeNPC server
mcstop          → Stop the ClaudeNPC server
mcstatus        → Show detailed server status dashboard
mcstatus -Detailed  → Show FULL server info (plugins, config, etc.)
mclogs          → Watch server logs in real-time
cnpcsetup       → Run the installation/setup
```

### File Operations

```powershell
ll              → List files (with details)
ll *.txt        → List all .txt files
la              → List all files including hidden
lt              → List files by time (20 most recent)

ff "pattern"    → Find files matching pattern (recursive)
mkcd dirname    → Create directory and cd into it
sha256 file.jar → Get SHA256 hash of file
```

### Git Shortcuts

```powershell
gs      → git status
ga      → git add <file>
gaa     → git add --all
gc      → git commit -m "message"
gp      → git push
gpull   → git pull
gl      → git log (pretty graph, last 10)
gd      → git diff
gco     → git checkout
gb      → git branch
```

### System Information

```powershell
sysinfo         → Show system info (OS, RAM, disk space)
Get-SystemHealth → Show CPU, memory, uptime
topmem          → Show top 10 memory-using processes
```

### Profile Management

```powershell
ep              → Edit profile (opens in VS Code/notepad++)
rp              → Reload profile (apply changes without restart)
Test-Profile    → Check which components loaded
```

---

## 5. **How to Know Module Status**

### Check Immediately on Startup:

The welcome banner shows at the bottom:
```
✓ Profile loaded in 245ms
```

If there were issues loading modules, you'd see:
```
[!] Oh My Posh not installed
[!] posh-git failed to load
```

### Check Anytime:

```powershell
Test-Profile
```

**Output:**
```
╔══════════════════════════════════════════════════════════════════════╗
║                    Profile Component Status                          ║
╚══════════════════════════════════════════════════════════════════════╝

  Oh My Posh            ✓ Loaded
  PSReadLine            ✓ Loaded
  Git                   ✓ Loaded

  Loaded Modules:
    • posh-git
    • Terminal-Icons

  Profile loaded in: 245 ms
```

---

## 6. **Server Status Dashboard**

### Check Server Status:

```powershell
mcstatus
```

**Example Output:**

```
╔════════════════════════════════════════════════════════════════════════╗
║                                                                        ║
║              CLAUDENPC SERVER SUITE - STATUS DASHBOARD                 ║
║                                                                        ║
╚════════════════════════════════════════════════════════════════════════╝

╔════════════════════════════════════════════════════════════════════════╗
║  PowerShell Environment                                                ║
╚════════════════════════════════════════════════════════════════════════╝
  PowerShell Version                                   7.4.1
  Execution Policy                                     RemoteSigned
  PowerShell Profile                                   Loaded
  Oh My Posh (Theme)                                   ✓ Installed
  posh-git (Git Integration)                           ✓ Loaded

╔════════════════════════════════════════════════════════════════════════╗
║  PowerShell Modules                                                    ║
╚════════════════════════════════════════════════════════════════════════╝
  posh-git                                             ✓ Loaded
  PSReadLine                                           ✓ Loaded
  PowerShellGet                                        ✓ Loaded
  PackageManagement                                    ✓ Loaded

╔════════════════════════════════════════════════════════════════════════╗
║  ClaudeNPC Minecraft Server                                            ║
╚════════════════════════════════════════════════════════════════════════╝
  Server Path                                          C:\MinecraftServer
  Server Status                                        ✓ RUNNING
  Process ID                                           12345
  Memory Usage                                         4521 MB
  CPU Time                                             345.67 seconds
  Uptime                                               02h 15m 43s
  paper.jar                                            ✓ Present
  start.bat                                            ✓ Present
  EULA Accepted                                        ✓ Yes

╔════════════════════════════════════════════════════════════════════════╗
║  Installed Plugins                                                     ║
╚════════════════════════════════════════════════════════════════════════╝
  Citizens                                             ✓ Installed
  Vault                                                ✓ Installed
  LuckPerms                                            ✓ Installed
  PlaceholderAPI                                       ✓ Installed
  EssentialsX                                          ○ Not Installed
  CoreProtect                                          ○ Not Installed

╔════════════════════════════════════════════════════════════════════════╗
║  Server Logs (Last 3 Errors)                                           ║
╚════════════════════════════════════════════════════════════════════════╝
  ✓ No errors in recent logs!

  Log File Size                                        45.23 KB
  Last Modified                                        2025-12-09 17:30:15

╔════════════════════════════════════════════════════════════════════════╗
║  Quick Actions                                                         ║
╚════════════════════════════════════════════════════════════════════════╝
  • Stop Server:  Get-Process java | Stop-Process -Force
  • View Console: Get-Content C:\MinecraftServer\logs\latest.log -Tail 20 -Wait
  • Check Status: Get-ClaudeNPCStatus -Detailed
  • Edit Config:  code C:\MinecraftServer\plugins\Citizens\config.yml

════════════════════════════════════════════════════════════════════════
```

### Detailed Status:

```powershell
mcstatus -Detailed
```

Adds additional sections:
- Server Configuration (port, players, memory, etc.)
- Full plugin list with version info
- More detailed module information

---

## 7. **Last 3 Console Errors**

### How to See Them:

**Option 1: Via Status Dashboard**
```powershell
mcstatus
```

Scroll to the "Server Logs (Last 3 Errors)" section.

**Option 2: Directly**
```powershell
Get-Content C:\MinecraftServer\logs\latest.log | Select-String "\[ERROR\]" | Select-Object -Last 3
```

**Example Output:**
```
[17:25:12] [ERROR]: Failed to load plugin Citizens: Missing dependency Vault
[17:28:45] [ERROR]: Could not pass event PlayerJoinEvent to LuckPerms
[17:30:01] [ERROR]: Connection timeout to session.minecraft.net
```

### If No Errors:
```
✓ No errors in recent logs!
```

---

## 8. **Enhanced Features You Have**

### History Search (POWERFUL!)

Type part of a command, then press ↑:
```powershell
# Type: Get-
# Press: ↑
# See: Get-ClaudeNPCStatus (if you ran it before)
# Press: ↑ again to cycle through all Get-* commands
```

### Tab Completion Menu

Press Tab to see all options:
```powershell
Get-C<Tab>
# Shows menu:
# Get-ChildItem
# Get-Command
# Get-Content
# Get-ClaudeNPCStatus
# ... etc
```

### Syntax Highlighting

As you type, commands are colored:
- **Cyan**: Commands (Get-Process, Set-Location)
- **Yellow**: Strings ("hello", 'world')
- **Green**: Variables ($Path, $env:HOME)
- **Magenta**: Operators (|, >, -eq)
- **Dark Gray**: Comments (# this is a comment)

---

## 9. **Troubleshooting**

### If Oh My Posh Doesn't Load:

**You'll see:**
```
[!] Oh My Posh not installed
Install: winget install JanDeDobbeleer.OhMyPosh
```

**Fix:**
```powershell
winget install JanDeDobbeleer.OhMyPosh
```

Then restart PowerShell or reload profile:
```powershell
rp
```

### If posh-git Shows Errors:

**Common Issue:** OneDrive cloud files not synced

**You'll see:**
```
. : The cloud file provider is not running.
At posh-git.psm1:8 char:3
```

**Fix 1:** Ignore it (doesn't affect functionality)

**Fix 2:** Disable posh-git temporarily:
Edit your profile and comment out:
```powershell
# Import-Module posh-git
```

### If Profile Loads Slowly:

**Check load time:**
```powershell
Test-Profile
```

If >500ms, consider disabling:
- Terminal-Icons (nice but slow)
- OneDrive paths in PSModulePath

---

## 10. **Complete Module List**

### What's Installed vs What's Loaded:

| Module | Installed | Auto-Load | Purpose |
|--------|-----------|-----------|---------|
| **PSReadLine** | ✓ Built-in | ✓ Yes | Command editing |
| **PackageManagement** | ✓ Built-in | ✓ Yes | Install modules |
| **PowerShellGet** | ✓ Built-in | ✓ Yes | Manage modules |
| **posh-git** | ○ External | ✓ If installed | Git integration |
| **Terminal-Icons** | ○ External | ✓ If installed | File icons |
| **Oh My Posh** | ○ External | ✓ If installed | Pretty prompt |

### Check What's Available:

```powershell
Get-Module -ListAvailable
```

### Check What's Currently Loaded:

```powershell
Get-Module
```

### Load a Module Manually:

```powershell
Import-Module posh-git
Import-Module Terminal-Icons
```

---

## 11. **File: $PROFILE Location**

Your PowerShell profile is stored at:

```
C:\Users\iamto\OneDrive\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
```

**Access it:**
```powershell
$PROFILE                 # Show path
code $PROFILE            # Edit in VS Code
notepad $PROFILE         # Edit in Notepad
ep                       # Shortcut: Edit Profile
```

**Reload after editing:**
```powershell
. $PROFILE               # Standard way
rp                       # Shortcut: Reload Profile
```

---

## 12. **Upgrading Your Profile**

### Current Profile: v1.0 (Basic)

**Location:**
`C:\Users\iamto\OneDrive\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`

### Enhanced Profile: v2.0 (Available)

**Location:**
`C:\Users\iamto\.kenl\claude-landing\claudenpc-server-suite\ENHANCED_PROFILE.ps1`

### To Upgrade:

**Option 1: Replace Completely**
```powershell
Copy-Item "C:\Users\iamto\.kenl\claude-landing\claudenpc-server-suite\ENHANCED_PROFILE.ps1" -Destination $PROFILE -Force
```

**Option 2: Merge Features**
Open both files and copy desired sections:
```powershell
code "C:\Users\iamto\.kenl\claude-landing\claudenpc-server-suite\ENHANCED_PROFILE.ps1"
code $PROFILE
```

### What Enhanced Profile Adds:

- ✅ Better error handling
- ✅ PSReadLine advanced configuration
- ✅ More keyboard shortcuts
- ✅ Server status in welcome banner
- ✅ `Test-Profile` command
- ✅ `Get-SystemHealth` command
- ✅ Enhanced git shortcuts
- ✅ More navigation aliases
- ✅ Memory/CPU monitoring
- ✅ Better prompt fallback (if Oh My Posh fails)

---

## Summary: What You'll See on Startup

1. **Oh My Posh atomic theme** (colorful prompt)
2. **Welcome banner** with:
   - Greeting
   - Current location
   - Date & time
   - Server status (RUNNING or STOPPED)
   - Quick commands list
3. **Load time** at bottom (~200-300ms typical)
4. **Ready prompt** waiting for your command

**Example Session:**
```
╔══════════════════════════════════════════════════════════════════════╗
║            Good Afternoon, iamto!                                    ║
╚══════════════════════════════════════════════════════════════════════╝

  📁 Location:    C:\Users\iamto
  📅 Date:        Monday, December 09, 2025
  🕒 Time:        17:45:23
  🎮 Server:      RUNNING (4521MB, up 2h 30m)

  💡 Quick Commands:
     mcstatus       → Server status dashboard
     mcstart/mcstop → Start/stop server
     cnpc           → Go to ClaudeNPC directory
     sysinfo        → System information

  ✓ Profile loaded in 245ms

┌─[✓]─[iamto@WIN11-AMD0]─[~]
└─❯ mcstatus
```

Then the full status dashboard appears!

---

**Guide Version:** 1.0.0
**Date:** December 9, 2025
**For:** ClaudeNPC Development Environment

*Enjoy your enhanced PowerShell experience!* 🚀
