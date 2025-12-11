# 🤖 Guide for New Claude Instances

**Everything you need to understand and extend this project**

---

## 📋 Quick Context

You're looking at a **modular PowerShell framework** for setting up a Minecraft PaperMC server with AI-powered NPCs (ClaudeNPC). This was built using **SAIF methodology** - modular, testable, production-ready.

### What's Already Done ✅

1. **4 Complete Core Modules** (~800 lines total)
   - Display.ps1 - Branded UI functions
   - Logger.ps1 - Logging system
   - Safety.ps1 - Validation & backups
   - Config.ps1 - Configuration management

2. **Main Orchestrator** - Setup.ps1 that ties everything together

3. **Complete Documentation** - README.md, DEPLOYMENT_GUIDE.md, PROJECT_OVERVIEW.md

### What's Not Done 🚧

- Phase modules (templates provided, need implementation)
- Utility scripts (backup, monitoring, etc.)
- Config templates
- Unit tests

---

## 🎯 Your Mission (If User Asks)

The user might ask you to:

1. **"Complete the phase modules"** → Implement 01-05 phase files
2. **"Create utility scripts"** → Build backup/monitoring scripts
3. **"Add feature X"** → Extend existing modules
4. **"Fix issue Y"** → Debug/improve code
5. **"Create templates"** → Add config file templates

---

## 📦 Project Structure Map

```
claudenpc-server-suite/
│
├── setup/
│   ├── core/                    ← 4 COMPLETE modules
│   │   ├── Display.ps1          ✅ UI/branding (200 lines)
│   │   ├── Logger.ps1           ✅ Logging (180 lines)
│   │   ├── Safety.ps1           ✅ Validation (220 lines)
│   │   └── Config.ps1           ✅ Configuration (200 lines)
│   │
│   ├── phases/                  ← NEED IMPLEMENTATION
│   │   ├── 01-Preflight.ps1     🚧 Prerequisites check
│   │   ├── 02-Java.ps1          🚧 Java installation
│   │   ├── 03-PaperMC.ps1       🚧 Server setup
│   │   ├── 04-Plugins.ps1       🚧 Plugin installation
│   │   └── 05-Configure.ps1     🚧 Final configuration
│   │
│   └── Setup.ps1                ✅ Main orchestrator
│
├── scripts/                     ← NEED CREATION
│   ├── Start-Server.bat         🚧 Server launcher
│   ├── Backup-Server.ps1        🚧 Backup automation
│   └── Monitor-Server.ps1       🚧 Health monitoring
│
├── configs/
│   ├── templates/               🚧 Config templates
│   └── profiles/                🚧 Install profiles
│
└── docs/                        ✅ Complete documentation
    ├── README.md
    ├── DEPLOYMENT_GUIDE.md
    ├── PROJECT_OVERVIEW.md
    └── CLAUDE_INSTANCE_GUIDE.md (this file)
```

---

## 🔍 Understanding the Core Modules

### Display.ps1 - The Branding Engine

**Purpose:** Consistent, branded UI across all scripts

**Key Concepts:**
```powershell
# Theme colors stored in $script:Theme
$script:Theme = @{
    Primary = "Cyan"      # Main brand color
    Success = "Green"     # Success messages
    Error = "Red"         # Error messages
    # ... etc
}

# All UI goes through these functions:
Show-Banner              # ASCII art header
Write-StatusBox          # Status with icon/color
Write-Section            # Section headers
Write-ProgressBar        # Progress indication
Write-ResultsTable       # Formatted tables
Read-Confirmation        # Yes/no prompts
Read-Choice              # Multiple choice
```

**When to use:**
- ANY time you need user output
- Building new phases or scripts
- Creating utility tools

**Example:**
```powershell
. .\setup\core\Display.ps1

Show-Banner
Write-Section -Title "My New Feature" -Icon "🔥"
Write-StatusBox -Title "Processing" -Status "Complete" -Type "Success"

$continue = Read-Confirmation -Message "Continue?" -DefaultYes
```

---

### Logger.ps1 - The Memory Keeper

**Purpose:** Track everything that happens, create audit trail

**Key Concepts:**
```powershell
# Initialize once per script
$logFile = Initialize-Logger -LogPath ".\logs"

# Log everything
Write-Log -Message "Info message" -Level "INFO"
Write-Log -Message "Success!" -Level "SUCCESS"
Write-Log -Message "Warning" -Level "WARNING"
Write-Log -Message "Error" -Level "ERROR"

# Log errors with full details
try {
    # risky operation
} catch {
    Write-LogError -ErrorRecord $_  # Captures stack trace, line numbers, etc.
}

# Close and summarize
Close-Logger -Success $true
```

**When to use:**
- ALWAYS in production scripts
- Any long-running operation
- Troubleshooting/debugging scenarios

**Log files are:**
- Timestamped: `setup-20241208-143022.log`
- Include system info header
- Auto-cleanup old logs (30 days)

---

### Safety.ps1 - The Guardian

**Purpose:** Prevent disasters, validate everything, create backups

**Key Concepts:**
```powershell
# Check for existing installation
$existing = Test-ExistingInstallation -ServerPath "C:\Server"
if ($existing.Exists) {
    # Prompt user or backup automatically
    $backup = Backup-ExistingServer -ServerPath "C:\Server" -BackupPath "C:\Backups"
}

# Validate disk space
$disk = Test-DiskSpace -Path "C:\Server" -RequiredGB 10
if (-not $disk.Success) {
    Write-Error "Only $($disk.FreeSpaceGB) GB available, need $($disk.RequiredGB) GB"
}

# Check network
$network = Test-NetworkConnectivity
if (-not $network.AllConnected) {
    # Handle offline scenario
}

# Validate port
$port = Test-PortAvailable -Port 25565
if (-not $port) {
    Write-Warning "Port 25565 already in use"
}

# Validate file
$file = Test-FileIntegrity -Path "paper.jar"
if ($file.Valid) {
    Write-Host "File OK: $($file.SizeMB) MB"
}

# Validate path safety
$path = Test-PathSafety -Path "C:\Server"
if (-not $path.Safe) {
    foreach ($issue in $path.Issues) {
        Write-Warning $issue
    }
}
```

**When to use:**
- BEFORE any destructive operation
- Start of installation phases
- In backup/restore scripts
- User-provided paths/input

---

### Config.ps1 - The Coordinator

**Purpose:** Manage all configuration, profiles, validation

**Key Concepts:**
```powershell
# Get defaults
$config = Get-DefaultConfiguration

# Or load from file
$config = Import-Configuration -Path "config.json"

# Or gather interactively
$config = Get-UserConfiguration  # Prompts user for all settings

# Validate
$validation = Test-Configuration -Config $config
if (-not $validation.Valid) {
    # Handle validation errors
    $validation.Issues | ForEach-Object { Write-Warning $_ }
}

# Save
Export-Configuration -Config $config -Path "config.json"

# Get install profile
$profile = Get-InstallProfile -ProfileName "Standard"
# Returns: @{Name, Description, Plugins[]}

# Memory recommendations
$memory = Get-RecommendedMemory
Write-Host "Your system: $($memory.TotalRAM) GB RAM"
Write-Host "Recommended: $($memory.Recommendation.Min) - $($memory.Recommendation.Max)"
```

**Configuration Schema:**
```powershell
@{
    ServerPath = "C:\MinecraftServer"
    ServerPort = 25565
    MaxPlayers = 20
    ViewDistance = 10
    SimulationDistance = 10
    Gamemode = "survival"
    Difficulty = "normal"
    OnlineMode = $true
    PVP = $true
    MemoryMin = "4G"
    MemoryMax = "8G"
    InstallProfile = "Standard"  # Minimal, Standard, or Full
    ClaudeAPIKey = ""
    AutoBackup = $true
    AcceptEULA = $false
}
```

---

## 🔧 Implementing Phase Modules

### Phase Module Template

Every phase follows this pattern:

```powershell
# XX-PhaseName.ps1
# Description of what this phase does
# Version: 1.0.0

#region Module Imports

# Import core modules (adjust path as needed)
$scriptRoot = Split-Path $PSScriptRoot -Parent
. "$scriptRoot\core\Display.ps1"
. "$scriptRoot\core\Logger.ps1"
. "$scriptRoot\core\Safety.ps1"
. "$scriptRoot\core\Config.ps1"

#endregion

#region Main Function

function Invoke-PhaseName {
    <#
    .SYNOPSIS
        Brief description of phase
    .DESCRIPTION
        Detailed description of what this phase does
    .PARAMETER Config
        Configuration hashtable from Config.ps1
    .PARAMETER OptionName
        Optional parameters specific to this phase
    .EXAMPLE
        Invoke-PhaseName -Config $config
    .OUTPUTS
        Hashtable with Success, Message, and Data
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Config,
        
        [Parameter(Mandatory=$false)]
        [switch]$OptionName
    )
    
    Write-Section -Title "Phase: Name" -Icon "⚙️"
    Write-Log -Message "Starting phase: Name" -Level "INFO"
    
    try {
        # Step 1
        Write-StatusBox -Title "Step 1: Description" -Status "Processing" -Type "Progress"
        
        # Your logic here
        Start-Sleep -Milliseconds 500  # Simulate work
        
        Write-StatusBox -Title "Step 1: Description" -Status "Complete" -Type "Success"
        Write-Log -Message "Step 1 complete" -Level "SUCCESS"
        
        # Step 2
        Write-StatusBox -Title "Step 2: Description" -Status "Processing" -Type "Progress"
        
        # More logic
        
        Write-StatusBox -Title "Step 2: Description" -Status "Complete" -Type "Success"
        Write-Log -Message "Step 2 complete" -Level "SUCCESS"
        
        # Return success
        return @{
            Success = $true
            Message = "Phase completed successfully"
            Data = @{
                # Any data to pass to next phase
                ItemsProcessed = 42
            }
        }
        
    } catch {
        # Handle errors
        Write-StatusBox -Title "Phase Failed" -Status $_.Exception.Message -Type "Error"
        Write-LogError -ErrorRecord $_
        
        return @{
            Success = $false
            Message = $_.Exception.Message
            Data = @{}
        }
    }
}

#endregion

#region Helper Functions (if needed)

function Get-SomeHelper {
    # Private helper functions for this phase
}

#endregion

# Export only the main function
Export-ModuleMember -Function Invoke-PhaseName
```

---

## 📝 Phase Implementation Guide

### 01-Preflight.ps1 - Prerequisites Check

**What it should do:**
1. Check PowerShell version (5.1+)
2. Verify admin rights
3. Check for Java (or note that phase 2 will install)
4. Check for PaperMC JAR in Downloads
5. Test network connectivity
6. Validate disk space
7. Display results table

**Key functions to use:**
```powershell
# From Safety.ps1
Test-DiskSpace
Test-NetworkConnectivity
Test-FileIntegrity

# From Display.ps1
Write-ResultsTable  # Display check results
```

**Result format:**
```powershell
@{
    Check = "PowerShell Version"
    Status = "✓ Pass" or "✗ Fail"
    Details = "Version 7.4.0"
}
```

---

### 02-Java.ps1 - Java Installation

**What it should do:**
1. Check if Java is already installed
2. If not, look for JDK zip in Downloads
3. Extract to C:\Java\jdk-XX
4. Set JAVA_HOME environment variable
5. Update PATH
6. Verify installation with `java -version`

**Key considerations:**
```powershell
# Find Java installer
$javaZip = Get-ChildItem "$env:USERPROFILE\Downloads" -Filter "openjdk-*_windows-x64*.zip" | 
    Sort-Object LastWriteTime -Descending | 
    Select-Object -First 1

# Extract
Expand-Archive -Path $javaZip.FullName -DestinationPath "C:\Java"

# Set environment variables
[Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Java\jdk-25", "Machine")
$path = [Environment]::GetEnvironmentVariable("Path", "Machine")
$path += ";C:\Java\jdk-25\bin"
[Environment]::SetEnvironmentVariable("Path", $path, "Machine")

# Verify
$javaVersion = & java -version 2>&1
```

---

### 03-PaperMC.ps1 - Server Installation

**What it should do:**
1. Create server directory structure
2. Find PaperMC JAR in Downloads
3. Copy to server directory as `paper.jar`
4. Create start.bat with Aikar's flags
5. Accept EULA
6. Initial server start (generate configs)
7. Stop server after initialization

**Directory structure:**
```
C:\MinecraftServer\
├── paper.jar
├── start.bat
├── eula.txt
├── server.properties
├── plugins\
├── world\
├── logs\
└── backups\
```

**start.bat template:**
```batch
@echo off
java -Xms{MemoryMin} -Xmx{MemoryMax} ^
  -XX:+UseG1GC ^
  -XX:+ParallelRefProcEnabled ^
  -XX:MaxGCPauseMillis=200 ^
  -XX:+UnlockExperimentalVMOptions ^
  -XX:+DisableExplicitGC ^
  -XX:+AlwaysPreTouch ^
  -XX:G1HeapWastePercent=5 ^
  -XX:G1MixedGCCountTarget=4 ^
  -XX:G1MixedGCLiveThresholdPercent=90 ^
  -XX:G1RSetUpdatingPauseTimePercent=5 ^
  -XX:SurvivorRatio=32 ^
  -XX:+PerfDisableSharedMem ^
  -XX:MaxTenuringThreshold=1 ^
  -jar paper.jar nogui
pause
```

---

### 04-Plugins.ps1 - Plugin Installation

**What it should do:**
1. Get plugin list from install profile
2. Search Downloads folder for plugin JARs
3. Copy found plugins to `plugins/` directory
4. Report missing plugins with download URLs
5. Handle ClaudeNPC separately (if built)

**Plugin matching logic:**
```powershell
$profile = Get-InstallProfile -ProfileName $Config.InstallProfile

foreach ($plugin in $profile.Plugins) {
    # Search Downloads
    $found = Get-ChildItem "$env:USERPROFILE\Downloads" -Filter "*$plugin*.jar" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    
    if ($found) {
        # Copy to plugins directory
        Copy-Item $found.FullName "$($Config.ServerPath)\plugins\" -Force
        Write-StatusBox -Title $plugin -Status "Installed" -Type "Success"
    } else {
        Write-StatusBox -Title $plugin -Status "Not found in Downloads" -Type "Warning"
    }
}
```

---

### 05-Configure.ps1 - Final Configuration

**What it should do:**
1. Update server.properties with user config
2. Configure paper-global.yml (if needed)
3. Configure ClaudeNPC config (API key, personalities)
4. Set MOTD
5. Set world seed (if provided)
6. Display "Next Steps" guide

**server.properties updates:**
```powershell
$propsPath = Join-Path $Config.ServerPath "server.properties"
$props = Get-Content $propsPath

$props = $props -replace '^server-port=.*', "server-port=$($Config.ServerPort)"
$props = $props -replace '^max-players=.*', "max-players=$($Config.MaxPlayers)"
$props = $props -replace '^view-distance=.*', "view-distance=$($Config.ViewDistance)"
# ... etc

$props | Set-Content $propsPath
```

**ClaudeNPC config:**
```yaml
api:
  key: "${ClaudeAPIKey}"
  model: "claude-sonnet-4-20250514"
  max_tokens: 300
  temperature: 0.7

conversation:
  memory_length: 10
  timeout_minutes: 5
  cooldown_seconds: 3

personalities:
  default:
    system_prompt: "You are a helpful NPC..."
```

---

## 🛠️ Creating Utility Scripts

### Backup-Server.ps1

```powershell
#Requires -Version 5.1
param(
    [Parameter(Mandatory=$true)]
    [string]$ServerPath,
    
    [Parameter(Mandatory=$false)]
    [string]$BackupPath = "$ServerPath\backups"
)

# Load modules
. "$PSScriptRoot\..\setup\core\Display.ps1"
. "$PSScriptRoot\..\setup\core\Logger.ps1"
. "$PSScriptRoot\..\setup\core\Safety.ps1"

Show-Banner
$logFile = Initialize-Logger -LogPath "$ServerPath\logs"

Write-Section -Title "Server Backup" -Icon "📦"

try {
    $backup = Backup-ExistingServer -ServerPath $ServerPath -BackupPath $BackupPath
    Write-StatusBox -Title "Backup Complete" -Status $backup -Type "Success"
    
    # Cleanup old backups (keep last 7)
    Get-ChildItem $BackupPath -Filter "*.zip" |
        Sort-Object LastWriteTime -Descending |
        Select-Object -Skip 7 |
        Remove-Item -Force
    
    Close-Logger -Success $true
} catch {
    Write-StatusBox -Title "Backup Failed" -Status $_.Exception.Message -Type "Error"
    Write-LogError -ErrorRecord $_
    Close-Logger -Success $false
    exit 1
}
```

---

### Start-Server.bat

```batch
@echo off
title ClaudeNPC Minecraft Server
color 0B

echo.
echo ╔══════════════════════════════════════════════════════════╗
echo ║           ClaudeNPC Minecraft Server                     ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

:: Check if paper.jar exists
if not exist "paper.jar" (
    echo [ERROR] paper.jar not found!
    echo Please run the setup script first.
    pause
    exit /b 1
)

:: Start server with optimized flags
echo [INFO] Starting server...
echo.

java -Xms4G -Xmx8G ^
  -XX:+UseG1GC ^
  -XX:+ParallelRefProcEnabled ^
  -XX:MaxGCPauseMillis=200 ^
  -XX:+UnlockExperimentalVMOptions ^
  -XX:+DisableExplicitGC ^
  -XX:+AlwaysPreTouch ^
  -XX:G1HeapWastePercent=5 ^
  -XX:G1MixedGCCountTarget=4 ^
  -XX:G1MixedGCLiveThresholdPercent=90 ^
  -XX:G1RSetUpdatingPauseTimePercent=5 ^
  -XX:SurvivorRatio=32 ^
  -XX:+PerfDisableSharedMem ^
  -XX:MaxTenuringThreshold=1 ^
  -jar paper.jar nogui

echo.
echo [INFO] Server stopped.
pause
```

---

## 📋 Common User Requests & How to Handle

### "Complete the installation phases"

**Steps:**
1. Read this guide thoroughly
2. Implement each phase module using the templates above
3. Test each phase independently
4. Integrate into Setup.ps1
5. Update documentation

**Code to add to Setup.ps1:**
```powershell
# After configuration validation...

# Phase 1: Preflight
if (-not $SkipPreflight) {
    . (Join-Path $script:SetupRoot "phases\01-Preflight.ps1")
    $result = Invoke-PreflightChecks -Config $config
    if (-not $result.Success) {
        throw "Preflight checks failed: $($result.Message)"
    }
}

# Phase 2: Java
. (Join-Path $script:SetupRoot "phases\02-Java.ps1")
$result = Invoke-JavaInstallation -Config $config
if (-not $result.Success) {
    throw "Java installation failed: $($result.Message)"
}

# Phase 3: PaperMC
. (Join-Path $script:SetupRoot "phases\03-PaperMC.ps1")
$result = Invoke-PaperMCSetup -Config $config
if (-not $result.Success) {
    throw "PaperMC setup failed: $($result.Message)"
}

# Phase 4: Plugins
. (Join-Path $script:SetupRoot "phases\04-Plugins.ps1")
$result = Invoke-PluginInstallation -Config $config
if (-not $result.Success) {
    throw "Plugin installation failed: $($result.Message)"
}

# Phase 5: Configure
. (Join-Path $script:SetupRoot "phases\05-Configure.ps1")
$result = Invoke-FinalConfiguration -Config $config
if (-not $result.Success) {
    throw "Configuration failed: $($result.Message)"
}
```

---

### "Add monitoring/health checks"

Create `scripts/Monitor-Server.ps1`:
```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$ServerPath,
    
    [Parameter(Mandatory=$false)]
    [int]$IntervalSeconds = 60
)

. "$PSScriptRoot\..\setup\core\Display.ps1"
. "$PSScriptRoot\..\setup\core\Safety.ps1"

Show-Banner
Write-Section -Title "Server Monitor" -Icon "📊"

while ($true) {
    Clear-Host
    Show-Banner
    Write-Section -Title "Server Status - $(Get-Date -Format 'HH:mm:ss')" -Icon "📊"
    
    # Check if server is running
    $process = Get-Process java -ErrorAction SilentlyContinue | Where-Object {
        $_.MainWindowTitle -like "*Minecraft*"
    }
    
    $status = @()
    
    # Server process
    if ($process) {
        $status += @{
            Check = "Server Process"
            Status = "✓ Running"
            Details = "PID: $($process.Id)"
        }
    } else {
        $status += @{
            Check = "Server Process"
            Status = "✗ Not Running"
            Details = "Server offline"
        }
    }
    
    # Disk space
    $disk = Test-DiskSpace -Path $ServerPath -RequiredGB 5
    $status += @{
        Check = "Disk Space"
        Status = if ($disk.Success) { "✓ $($disk.FreeSpaceGB) GB" } else { "⚠ Low" }
        Details = "Available on $($disk.Drive):"
    }
    
    # Port
    $port = Test-PortAvailable -Port 25565
    $status += @{
        Check = "Port 25565"
        Status = if (-not $port) { "✓ In Use" } else { "⚠ Available" }
        Details = "Server port"
    }
    
    Write-ResultsTable -Data $status -Headers @("Check", "Status", "Details")
    
    Start-Sleep -Seconds $IntervalSeconds
}
```

---

### "Create config templates"

Create `configs/templates/server.properties.template`:
```properties
# Minecraft Server Properties
# Generated by ClaudeNPC Server Suite
# {{GeneratedDate}}

# Network
server-port={{ServerPort}}
server-ip=
online-mode={{OnlineMode}}
max-players={{MaxPlayers}}

# World
level-name=world
level-seed={{WorldSeed}}
gamemode={{Gamemode}}
difficulty={{Difficulty}}
hardcore=false

# Performance
view-distance={{ViewDistance}}
simulation-distance={{SimulationDistance}}
max-tick-time=60000

# Features
pvp={{PVP}}
allow-flight=false
spawn-protection=16
spawn-monsters=true
spawn-animals=true
spawn-npcs=true

# Server Management
motd={{MOTD}}
enable-rcon=false
enable-query=false
enable-command-block=false
```

Then process it:
```powershell
$template = Get-Content "configs\templates\server.properties.template" -Raw

$template = $template -replace '{{ServerPort}}', $Config.ServerPort
$template = $template -replace '{{OnlineMode}}', $Config.OnlineMode.ToString().ToLower()
# ... etc

$template | Set-Content "$($Config.ServerPath)\server.properties"
```

---

## 🧪 Testing Guidelines

### Test Individual Modules

```powershell
# Test Display
. .\setup\core\Display.ps1
Show-Banner
Write-StatusBox -Title "Test" -Status "Working" -Type "Success"
Write-ResultsTable -Data @(@{A="1";B="2"}) -Headers @("A","B")

# Test Logger
. .\setup\core\Logger.ps1
$log = Initialize-Logger -LogPath ".\test-logs"
Write-Log -Message "Test" -Level "INFO"
Close-Logger -Success $true

# Test Safety
. .\setup\core\Safety.ps1
$disk = Test-DiskSpace -Path "C:\" -RequiredGB 10
Write-Host "Free: $($disk.FreeSpaceGB) GB"

# Test Config
. .\setup\core\Config.ps1
$config = Get-DefaultConfiguration
$valid = Test-Configuration -Config $config
Write-Host "Valid: $($valid.Valid)"
```

### Test Phase Modules

```powershell
# Test a phase independently
. .\setup\core\Display.ps1
. .\setup\core\Logger.ps1
. .\setup\phases\01-Preflight.ps1

$log = Initialize-Logger -LogPath ".\test-logs"
$config = Get-DefaultConfiguration

$result = Invoke-PreflightChecks -Config $config
Write-Host "Success: $($result.Success)"
Write-Host "Message: $($result.Message)"

Close-Logger -Success $result.Success
```

---

## 🎨 Customization Guide

### Change Colors

Edit `setup/core/Display.ps1`:
```powershell
$script:Theme = @{
    Primary = "Blue"        # Was Cyan
    Secondary = "Yellow"    # Was Magenta
    # ... customize others
}
```

### Add New Icons

```powershell
$script:Icons = @{
    # Existing icons...
    MyNewIcon = "🎯"
    CustomCheck = "☑"
}
```

### Create Custom Phase

1. Copy phase template from this guide
2. Save as `setup/phases/XX-YourPhase.ps1`
3. Implement your logic
4. Add to Setup.ps1
5. Test independently

### Add Configuration Options

In `Config.ps1`, update `$script:DefaultConfig`:
```powershell
$script:DefaultConfig = @{
    # Existing options...
    MyNewOption = "DefaultValue"
}
```

Then handle in `Get-UserConfiguration`:
```powershell
$input = Read-Host "  My New Option [$($config.MyNewOption)]"
if ($input) { $config.MyNewOption = $input }
```

---

## 🐛 Common Issues & Solutions

### "Module not found"

```powershell
# Use absolute paths
$scriptRoot = $PSScriptRoot
. "$scriptRoot\core\Display.ps1"

# Or
$modulePath = Join-Path $PSScriptRoot "core\Display.ps1"
. $modulePath
```

### "Function not recognized"

```powershell
# Ensure module is loaded
. .\setup\core\Display.ps1

# Check if loaded
Get-Command Show-Banner
```

### "Access denied"

```powershell
# Run as Administrator
# Right-click PowerShell → "Run as Administrator"
```

### "Execution policy"

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 📚 Key Principles to Follow

1. **Modularity** - Each module works independently
2. **Consistency** - Follow existing patterns
3. **Error Handling** - Always use try/catch
4. **Logging** - Log everything important
5. **User Feedback** - Use StatusBox for all operations
6. **Validation** - Validate before acting
7. **Documentation** - Comment your code
8. **Testing** - Test modules independently

---

## 🎯 Quick Reference

### Module Loading Pattern
```powershell
$scriptRoot = Split-Path $PSScriptRoot -Parent
. "$scriptRoot\core\Display.ps1"
. "$scriptRoot\core\Logger.ps1"
. "$scriptRoot\core\Safety.ps1"
. "$scriptRoot\core\Config.ps1"
```

### Phase Return Pattern
```powershell
return @{
    Success = $true/$false
    Message = "What happened"
    Data = @{} # Optional data
}
```

### Error Handling Pattern
```powershell
try {
    # Do work
    Write-StatusBox -Title "Task" -Status "Complete" -Type "Success"
} catch {
    Write-StatusBox -Title "Task" -Status "Failed" -Type "Error"
    Write-LogError -ErrorRecord $_
    throw
}
```

---

## 🚀 Ready to Start

When user says:
- **"Complete phase X"** → Use phase template, implement logic
- **"Create utility Y"** → Use module loading, follow patterns
- **"Fix bug Z"** → Review module code, test fix
- **"Add feature W"** → Extend appropriate module, test

**Always:**
1. Read existing code first
2. Follow established patterns
3. Test independently
4. Update documentation
5. Consider user experience

---

## 📖 Files to Reference

- **Display.ps1** - For UI patterns
- **Logger.ps1** - For logging patterns  
- **Safety.ps1** - For validation patterns
- **Config.ps1** - For configuration patterns
- **Setup.ps1** - For orchestration patterns
- **README.md** - For user-facing docs
- **DEPLOYMENT_GUIDE.md** - For examples

---

**You now have everything needed to understand and extend this project!**

Read the code, follow the patterns, test your changes, and maintain the same quality bar.

---

**SAIF Methodology • Claude Instance v2 • Built for Handoff**
