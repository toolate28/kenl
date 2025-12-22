# 📦 Production-Ready Code Snippets

**Complete, tested, drop-in code ready for immediate use**

---

## 📋 What's In This Directory

```
snippets/
├── phases/
│   └── 01-Preflight.ps1         ✅ PRODUCTION READY
│
├── scripts/
│   ├── Start-Server.bat         ✅ PRODUCTION READY
│   └── Backup-Server.ps1        ✅ PRODUCTION READY
│
└── templates/
    └── server.properties.template ✅ PRODUCTION READY
```

---

## 🎯 Quick Usage

### Drop-In: Preflight Phase

**File:** `phases/01-Preflight.ps1`  
**Status:** ✅ Complete, tested, production-ready  
**Size:** ~7KB  
**Lines:** ~250  

**What it does:**
- Checks PowerShell version (5.1+)
- Verifies administrator privileges
- Detects Java installation (17+)
- Validates disk space (10GB+ required, critical if <5GB)
- Tests network connectivity to required services
- Searches for PaperMC JAR in Downloads folder
- Displays beautiful formatted results table
- Returns detailed status for orchestrator

**How to use:**

```powershell
# 1. Copy to your project
copy snippets\phases\01-Preflight.ps1 setup\phases\

# 2. Use in Setup.ps1
. (Join-Path $script:SetupRoot "phases\01-Preflight.ps1")
$result = Invoke-PreflightChecks -SkipPreflight:$SkipPreflight

if (-not $result.Success) {
    # Handle failure
    exit 1
}

# 3. Done! It just works.
```

**Return value:**
```powershell
@{
    Success = $true/$false
    Critical = 0  # Number of critical failures
    Warnings = 2  # Number of warnings
    AllPassed = $false  # True if no warnings
    Skipped = $false  # True if skipped
    UserCancelled = $false  # True if user declined warnings
}
```

---

### Drop-In: Server Start Script

**File:** `scripts/Start-Server.bat`  
**Status:** ✅ Complete, tested, production-ready  
**Size:** ~5KB  
**Lines:** ~180  

**Features:**
- Beautiful ASCII art banner
- Pre-flight checks (Java, JAR, EULA)
- Aikar's optimized JVM flags
- Configurable memory (edit MIN_MEMORY/MAX_MEMORY at top)
- Color-coded status messages
- Error handling with exit codes
- Clean shutdown detection

**How to use:**

```batch
REM 1. Copy to server directory
copy snippets\scripts\Start-Server.bat C:\MinecraftServer\

REM 2. Edit memory settings (optional)
REM Open Start-Server.bat and modify:
set MIN_MEMORY=4G
set MAX_MEMORY=8G

REM 3. Double-click to run, or:
cd C:\MinecraftServer
Start-Server.bat
```

**Memory recommendations:**
- Small (1-10 players): `MIN_MEMORY=2G` `MAX_MEMORY=4G`
- Medium (10-20 players): `MIN_MEMORY=4G` `MAX_MEMORY=8G`
- Large (20-50 players): `MIN_MEMORY=8G` `MAX_MEMORY=12G`

---

### Drop-In: Backup Script

**File:** `scripts/Backup-Server.ps1`  
**Status:** ✅ Complete, tested, production-ready  
**Size:** ~8KB  
**Lines:** ~270  

**Features:**
- Beautiful ASCII art banner
- Backs up worlds, plugins, and configs
- Automatic compression with size reporting
- Configurable retention (default: keep last 7)
- Detailed logging to backup.log
- Progress indicators
- Error handling with rollback
- Can run quietly for automation

**How to use:**

```powershell
# Manual backup
.\snippets\scripts\Backup-Server.ps1 `
    -ServerPath "C:\MinecraftServer" `
    -BackupPath "C:\Backups" `
    -KeepBackups 7

# Quiet mode (for scheduled tasks)
.\snippets\scripts\Backup-Server.ps1 `
    -ServerPath "C:\MinecraftServer" `
    -BackupPath "C:\Backups" `
    -Quiet

# Schedule daily backups (Task Scheduler)
schtasks /create /tn "Minecraft Backup" /tr "PowerShell.exe -ExecutionPolicy Bypass -File C:\path\to\Backup-Server.ps1 -ServerPath C:\MinecraftServer -BackupPath C:\Backups -Quiet" /sc daily /st 03:00
```

**What gets backed up:**
- world/ (Overworld)
- world_nether/
- world_the_end/
- plugins/
- server.properties
- All config files (bukkit.yml, spigot.yml, paper*.yml)
- ops.json, whitelist.json
- banned-players.json, banned-ips.json

---

### Drop-In: Server Configuration Template

**File:** `templates/server.properties.template`  
**Status:** ✅ Complete, production-ready  
**Size:** ~2KB  
**Lines:** ~80  

**Placeholders:**
```properties
server-port={{ServerPort}}           # e.g., 25565
max-players={{MaxPlayers}}           # e.g., 20
gamemode={{Gamemode}}                # survival/creative/adventure
difficulty={{Difficulty}}            # peaceful/easy/normal/hard
pvp={{PVP}}                          # true/false
view-distance={{ViewDistance}}       # e.g., 10
simulation-distance={{SimulationDistance}}  # e.g., 10
motd={{MOTD}}                        # Server description
online-mode={{OnlineMode}}           # true/false
```

**How to use:**

```powershell
# Load template
$template = Get-Content "snippets\templates\server.properties.template" -Raw

# Replace placeholders
$config = $template `
    -replace '{{ServerPort}}', '25565' `
    -replace '{{MaxPlayers}}', '20' `
    -replace '{{Gamemode}}', 'survival' `
    -replace '{{Difficulty}}', 'normal' `
    -replace '{{PVP}}', 'true' `
    -replace '{{ViewDistance}}', '10' `
    -replace '{{SimulationDistance}}', '10' `
    -replace '{{MOTD}}', 'ClaudeNPC Server - AI Powered NPCs' `
    -replace '{{OnlineMode}}', 'true'

# Write to server
$config | Set-Content "C:\MinecraftServer\server.properties" -Encoding ASCII
```

---

## 🔧 Integration Examples

### Example 1: Complete Setup with All Snippets

```powershell
# Setup.ps1
param()

# Import core modules
. ".\setup\core\Display.ps1"
. ".\setup\core\Logger.ps1"

# Show banner and initialize
Show-Banner
$log = Initialize-Logger -LogPath ".\logs"

try {
    # Phase 1: Preflight (using snippet)
    . ".\setup\phases\01-Preflight.ps1"
    $preflight = Invoke-PreflightChecks
    
    if (-not $preflight.Success) {
        throw "Preflight checks failed"
    }
    
    # Phase 2-5: Your other phases...
    
    # Success!
    Write-StatusBox -Title "Setup Complete" -Status "Success" -Type "Success"
    Close-Logger -Success $true
    
} catch {
    Write-StatusBox -Title "Setup Failed" -Status $_.Exception.Message -Type "Error"
    Write-LogError -ErrorRecord $_
    Close-Logger -Success $false
    exit 1
}
```

### Example 2: Standalone Backup Job

```powershell
# daily-backup.ps1
# Simple wrapper for scheduled backups

param(
    [string]$ServerPath = "C:\MinecraftServer",
    [string]$BackupPath = "D:\Backups\Minecraft"
)

# Run the backup script
& "C:\path\to\snippets\scripts\Backup-Server.ps1" `
    -ServerPath $ServerPath `
    -BackupPath $BackupPath `
    -KeepBackups 14 `
    -Quiet

# Check result
if ($LASTEXITCODE -ne 0) {
    # Send email notification or log error
    Write-EventLog -LogName Application -Source "MinecraftBackup" `
        -EntryType Error -EventId 1 -Message "Backup failed!"
}
```

### Example 3: Custom Health Check Using Preflight

```powershell
# health-check.ps1
# Uses preflight logic for health monitoring

. ".\setup\core\Display.ps1"
. ".\snippets\phases\01-Preflight.ps1"

Show-Banner
Write-Section -Title "Server Health Check" -Icon "🏥"

$result = Invoke-PreflightChecks -SkipPreflight:$false

if ($result.Success) {
    if ($result.AllPassed) {
        Write-Host "  ✓ All systems operational" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "  ⚠ $($result.Warnings) warnings detected" -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "  ✗ $($result.Critical) critical issues" -ForegroundColor Red
    exit 2
}
```

---

## 🎨 Customization Guide

### Customize Start Script Memory

Edit `Start-Server.bat` lines 12-13:

```batch
set MIN_MEMORY=8G    REM Changed from 4G
set MAX_MEMORY=16G   REM Changed from 8G
```

### Customize Backup Retention

Use `-KeepBackups` parameter:

```powershell
.\Backup-Server.ps1 -KeepBackups 30  # Keep 30 backups instead of 7
```

### Customize Server Template

Edit `server.properties.template` and add your own placeholders:

```properties
# Add custom setting
my-custom-setting={{MyCustomSetting}}
```

Then replace in code:

```powershell
$template -replace '{{MyCustomSetting}}', 'my-value'
```

---

## 🧪 Testing Snippets

### Test Preflight Independently

```powershell
# Create test script
@'
. ".\setup\core\Display.ps1"
. ".\setup\core\Logger.ps1"
. ".\setup\core\Safety.ps1"
. ".\snippets\phases\01-Preflight.ps1"

Show-Banner
$log = Initialize-Logger -LogPath ".\test-logs"
$result = Invoke-PreflightChecks
Close-Logger -Success $result.Success

Write-Host "`nResult:"
$result | ConvertTo-Json -Depth 3
'@ | Set-Content test-preflight.ps1

# Run test
.\test-preflight.ps1
```

### Test Backup Script

```powershell
# Create test server directory
mkdir C:\TestServer
New-Item -ItemType File -Path C:\TestServer\server.properties
mkdir C:\TestServer\plugins

# Run backup
.\snippets\scripts\Backup-Server.ps1 `
    -ServerPath C:\TestServer `
    -BackupPath C:\TestBackups

# Check results
Get-ChildItem C:\TestBackups
```

### Test Start Script

```powershell
# Create minimal server setup
mkdir C:\TestServer
copy snippets\scripts\Start-Server.bat C:\TestServer\

# Create dummy JAR (for testing checks only)
"dummy" | Set-Content C:\TestServer\paper.jar

# Run (will show Java check, JAR check, EULA check)
cd C:\TestServer
.\Start-Server.bat
```

---

## ✅ Quality Checklist

All snippets have been validated for:

- [x] **Syntax**: No PowerShell/Batch syntax errors
- [x] **Error Handling**: Try/catch blocks, exit codes
- [x] **Logging**: Comprehensive Write-Log calls
- [x] **UI**: Uses Display module consistently
- [x] **Documentation**: Inline comments explaining logic
- [x] **Parameterization**: Configurable via parameters
- [x] **Return Values**: Clear success/failure indication
- [x] **Cross-compatibility**: Works on Windows PowerShell 5.1+
- [x] **Production-ready**: Tested patterns, no placeholders

---

## 📚 Next Steps

1. **Copy snippets to your project**
2. **Test each snippet independently**
3. **Integrate into Setup.ps1**
4. **Customize as needed**
5. **Build remaining phases using these as templates**

---

## 🎯 Summary

**You have 4 complete, production-ready components:**

✅ **01-Preflight.ps1** - Full prerequisite validation  
✅ **Start-Server.bat** - Optimized server launcher  
✅ **Backup-Server.ps1** - Complete backup solution  
✅ **server.properties.template** - Configuration template  

**These snippets are:**
- Fully implemented
- Tested patterns
- Ready to use
- Well documented
- Error handled
- Production quality

**Just copy and use them!**

---

**Built for ClaudeNPC Server Suite • Ready for Production Use**
