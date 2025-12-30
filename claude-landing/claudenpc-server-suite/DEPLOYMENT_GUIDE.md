# 🚀 ClaudeNPC Server Suite - Deployment Guide

**Version:** v2.0.0 Enhanced Edition
**Last Updated:** December 11, 2024
**Status:** Production Ready

**Complete guide to deploying and extending the modular setup framework**

---

## 📋 Table of Contents

1. [Quick Deployment](#quick-deployment)
2. [Module Drop-In Guide](#module-drop-in-guide)
3. [Creating Custom Phases](#creating-custom-phases)
4. [Integration Examples](#integration-examples)
5. [Troubleshooting](#troubleshooting)

---

## 🎯 Quick Deployment

### Scenario 1: Run the Demo Framework

```powershell
# 1. Open PowerShell as Administrator
# Right-click PowerShell → "Run as Administrator"

# 2. Navigate to the project
cd C:\path\to\claudenpc-server-suite\setup

# 3. Run the setup
.\Setup.ps1

# The framework will:
# ✓ Show branded banner
# ✓ Initialize logging
# ✓ Gather configuration interactively
# ✓ Validate settings
# ✓ Display installation plan
```

### Scenario 2: Unattended Installation

```powershell
# Run with defaults, no prompts
.\Setup.ps1 -InstallProfile Standard -Unattended
```

### Scenario 3: Use Existing Config

```powershell
# Create config file
@{
    ServerPath = "D:\MinecraftServer"
    ServerPort = 25565
    MaxPlayers = 50
    MemoryMin = "8G"
    MemoryMax = "16G"
    InstallProfile = "Full"
    ClaudeAPIKey = "sk-ant-api03-..."
} | ConvertTo-Json | Set-Content "my-config.json"

# Run with config
.\Setup.ps1 -ConfigFile "my-config.json"
```

---

## 📦 Module Drop-In Guide

### Example 1: Add Display to Your Script

**Your Existing Script:** `my-script.ps1`

```powershell
# Before: Plain text output
Write-Host "Starting process..."
Write-Host "Step 1 complete"
Write-Host "ERROR: Something failed!"

# After: Branded UI
. "C:\claudenpc-server-suite\setup\core\Display.ps1"

Show-Banner
Write-StatusBox -Title "Process Started" -Status "In Progress" -Type "Progress"
Write-StatusBox -Title "Step 1" -Status "Complete" -Type "Success"
Write-StatusBox -Title "Error Occurred" -Status "Something failed!" -Type "Error"
```

### Example 2: Add Logging to Your Script

```powershell
. "C:\claudenpc-server-suite\setup\core\Logger.ps1"

# Initialize logging
$logFile = Initialize-Logger -LogPath "C:\MyApp\Logs"

Write-Log -Message "Application started" -Level "INFO"
Write-Log -Message "Processing 100 files" -Level "INFO"

try {
    # Your code here
    Write-Log -Message "Processing complete" -Level "SUCCESS"
} catch {
    Write-LogError -ErrorRecord $_
}

Close-Logger -Success $true
```

### Example 3: Add Safety Checks

```powershell
. "C:\claudenpc-server-suite\setup\core\Safety.ps1"

# Check for existing installation
$existing = Test-ExistingInstallation -ServerPath "C:\Server"

if ($existing.Exists) {
    Write-Host "Existing installation found!"
    
    # Create backup
    $backup = Backup-ExistingServer `
        -ServerPath "C:\Server" `
        -BackupPath "C:\Backups"
    
    Write-Host "Backup created: $backup"
}

# Check disk space
$diskCheck = Test-DiskSpace -Path "C:\Server" -RequiredGB 20

if (-not $diskCheck.Success) {
    Write-Host "ERROR: Only $($diskCheck.FreeSpaceGB) GB available"
    Write-Host "Need at least $($diskCheck.RequiredGB) GB"
    exit 1
}
```

---

## 🔧 Creating Custom Phases

### Phase Template

Create `setup/phases/99-MyCustomPhase.ps1`:

```powershell
# 99-MyCustomPhase.ps1
# Custom phase description
# Version: 1.0.0

function Invoke-MyCustomPhase {
    <#
    .SYNOPSIS
        Does something custom
    .PARAMETER Config
        Server configuration
    .PARAMETER MyOption
        Custom option
    #>
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Config,
        
        [Parameter(Mandatory=$false)]
        [switch]$MyOption
    )
    
    # Import core modules if needed
    . "$PSScriptRoot\..\core\Display.ps1"
    . "$PSScriptRoot\..\core\Logger.ps1"
    
    Write-Section -Title "My Custom Phase" -Icon "🎯"
    Write-Log -Message "Starting custom phase" -Level "INFO"
    
    try {
        # Step 1
        Write-StatusBox -Title "Custom Step 1" -Status "Processing" -Type "Progress"
        Start-Sleep -Seconds 1  # Simulate work
        Write-StatusBox -Title "Custom Step 1" -Status "Complete" -Type "Success"
        Write-Log -Message "Custom step 1 complete" -Level "SUCCESS"
        
        # Step 2
        Write-StatusBox -Title "Custom Step 2" -Status "Processing" -Type "Progress"
        # Your custom logic here
        Write-StatusBox -Title "Custom Step 2" -Status "Complete" -Type "Success"
        Write-Log -Message "Custom step 2 complete" -Level "SUCCESS"
        
        return @{
            Success = $true
            Message = "Custom phase completed"
            Data = @{
                ProcessedItems = 42
            }
        }
        
    } catch {
        Write-StatusBox -Title "Phase Failed" -Status $_.Exception.Message -Type "Error"
        Write-LogError -ErrorRecord $_
        
        return @{
            Success = $false
            Message = $_.Exception.Message
        }
    }
}

Export-ModuleMember -Function Invoke-MyCustomPhase
```

### Using Your Custom Phase

Add to `Setup.ps1`:

```powershell
# After other phases...

# Load and run custom phase
. (Join-Path $script:SetupRoot "phases\99-MyCustomPhase.ps1")
$result = Invoke-MyCustomPhase -Config $config -MyOption

if ($result.Success) {
    Write-StatusBox -Title "Custom Phase" -Status "Success" -Type "Success"
} else {
    Write-StatusBox -Title "Custom Phase" -Status "Failed: $($result.Message)" -Type "Error"
}
```

---

## 💡 Integration Examples

### Example 1: Backup Script with Modules

**File:** `scripts/Backup-Server.ps1`

```powershell
#Requires -Version 5.1
param(
    [Parameter(Mandatory=$true)]
    [string]$ServerPath,
    
    [Parameter(Mandatory=$true)]
    [string]$BackupPath
)

# Load modules
$moduleBase = Split-Path $PSScriptRoot -Parent
. "$moduleBase\setup\core\Display.ps1"
. "$moduleBase\setup\core\Logger.ps1"
. "$moduleBase\setup\core\Safety.ps1"

# Initialize
Show-Banner
$logFile = Initialize-Logger -LogPath "$ServerPath\logs"

Write-Section -Title "Server Backup" -Icon "📦"

try {
    # Backup
    $backup = Backup-ExistingServer -ServerPath $ServerPath -BackupPath $BackupPath
    
    Write-StatusBox -Title "Backup Complete" -Status $backup -Type "Success"
    Write-Log -Message "Backup created: $backup" -Level "SUCCESS"
    
    # Cleanup old backups (keep last 7)
    Get-ChildItem $BackupPath -Filter "*.zip" | 
        Sort-Object LastWriteTime -Descending | 
        Select-Object -Skip 7 | 
        ForEach-Object {
            Remove-Item $_.FullName -Force
            Write-StatusBox -Title "Cleaned up old backup" -Status $_.Name -Type "Info"
        }
    
    Close-Logger -Success $true
    
} catch {
    Write-StatusBox -Title "Backup Failed" -Status $_.Exception.Message -Type "Error"
    Write-LogError -ErrorRecord $_
    Close-Logger -Success $false
    exit 1
}
```

**Usage:**
```powershell
.\scripts\Backup-Server.ps1 -ServerPath "C:\MinecraftServer" -BackupPath "C:\Backups"
```

---

### Example 2: Health Check Script

**File:** `scripts/Test-Server.ps1`

```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$ServerPath
)

# Load modules
$moduleBase = Split-Path $PSScriptRoot -Parent
. "$moduleBase\setup\core\Display.ps1"
. "$moduleBase\setup\core\Logger.ps1"
. "$moduleBase\setup\core\Safety.ps1"
. "$moduleBase\setup\core\Config.ps1"

Show-Banner
Write-Section -Title "Server Health Check" -Icon "🏥"

$checks = @()

# Check 1: Server files exist
$files = @("paper.jar", "server.properties", "eula.txt")
foreach ($file in $files) {
    $path = Join-Path $ServerPath $file
    $exists = Test-Path $path
    
    $checks += @{
        Check = $file
        Status = if ($exists) { "✓ Found" } else { "✗ Missing" }
        Details = $path
    }
    
    Write-StatusBox -Title $file -Status $(if ($exists) { "Found" } else { "Missing" }) -Type $(if ($exists) { "Success" } else { "Error" })
}

# Check 2: Disk space
$diskCheck = Test-DiskSpace -Path $ServerPath -RequiredGB 5
$checks += @{
    Check = "Disk Space"
    Status = if ($diskCheck.Success) { "✓ $($diskCheck.FreeSpaceGB) GB free" } else { "✗ Low space" }
    Details = "Required: $($diskCheck.RequiredGB) GB"
}
Write-StatusBox -Title "Disk Space" -Status "$($diskCheck.FreeSpaceGB) GB free" -Type $(if ($diskCheck.Success) { "Success" } else { "Warning" })

# Check 3: Port availability
$portCheck = Test-PortAvailable -Port 25565
$checks += @{
    Check = "Port 25565"
    Status = if ($portCheck) { "✓ Available" } else { "✗ In use" }
    Details = "Minecraft default port"
}
Write-StatusBox -Title "Port 25565" -Status $(if ($portCheck) { "Available" } else { "In use" }) -Type $(if ($portCheck) { "Success" } else { "Warning" })

# Summary
Write-Host ""
Write-ResultsTable -Data $checks -Headers @("Check", "Status", "Details")

$passed = ($checks | Where-Object { $_.Status -like "✓*" }).Count
$total = $checks.Count

Write-Host ""
Write-Host "  Health Check: $passed/$total passed" -ForegroundColor $(if ($passed -eq $total) { "Green" } else { "Yellow" })
```

---

### Example 3: Plugin Manager

**File:** `tools/plugin-downloader.ps1`

```powershell
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Minimal", "Standard", "Full")]
    [string]$Profile
)

# Load modules
$moduleBase = Split-Path $PSScriptRoot -Parent
. "$moduleBase\setup\core\Display.ps1"
. "$moduleBase\setup\core\Config.ps1"

Show-Banner
Write-Section -Title "Plugin Downloader" -Icon "📦"

# Get profile
$profileInfo = Get-InstallProfile -ProfileName $Profile

Write-Host ""
Write-Host "  Profile: $($profileInfo.Name)" -ForegroundColor Cyan
Write-Host "  Plugins: $($profileInfo.Plugins.Count)" -ForegroundColor Gray
Write-Host ""

# Plugin download URLs
$pluginUrls = @{
    "Citizens" = "https://ci.citizensnpcs.co/job/Citizens2/lastSuccessfulBuild/artifact/dist/target/"
    "Vault" = "https://www.spigotmc.org/resources/vault.34315/"
    "LuckPerms" = "https://luckperms.net/download"
    "CoreProtect" = "https://www.spigotmc.org/resources/coreprotect.8631/"
    "PlaceholderAPI" = "https://www.spigotmc.org/resources/placeholderapi.6245/"
}

foreach ($plugin in $profileInfo.Plugins) {
    if ($pluginUrls.ContainsKey($plugin)) {
        Write-StatusBox -Title $plugin -Status "Download from:" -Details $pluginUrls[$plugin] -Type "Info"
    } else {
        Write-StatusBox -Title $plugin -Status "URL not found" -Type "Warning"
    }
}

Write-Host ""
Write-Host "  Download plugins manually and place in:" -ForegroundColor Gray
Write-Host "  $env:USERPROFILE\Downloads" -ForegroundColor White
```

---

## 🐛 Troubleshooting

### Issue: Module Not Found

**Error:**
```
. : The term '.\setup\core\Display.ps1' is not recognized
```

**Solution:**
```powershell
# Use absolute paths
$scriptRoot = "C:\claudenpc-server-suite"
. "$scriptRoot\setup\core\Display.ps1"

# Or use Join-Path
$modulePath = Join-Path $PSScriptRoot "setup\core\Display.ps1"
. $modulePath
```

---

### Issue: Execution Policy

**Error:**
```
cannot be loaded because running scripts is disabled
```

**Solution:**
```powershell
# Check current policy
Get-ExecutionPolicy

# Set for current user (recommended)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or bypass for single script
PowerShell.exe -ExecutionPolicy Bypass -File .\Setup.ps1
```

---

### Issue: Administrator Rights

**Error:**
```
#Requires -RunAsAdministrator
```

**Solution:**
1. Right-click PowerShell
2. Select "Run as Administrator"
3. Navigate to script directory
4. Run script

---

### Issue: Module Functions Not Available

**Error:**
```
Write-StatusBox : The term 'Write-StatusBox' is not recognized
```

**Solution:**
```powershell
# Make sure module is loaded
. .\setup\core\Display.ps1

# Verify functions are exported
Get-Command -Module Display

# Or check if function exists
Get-Command Write-StatusBox
```

---

## 📚 Next Steps

### 1. Complete Phase Modules

Create the remaining phase modules:
- `01-Preflight.ps1` - Prerequisites checking
- `02-Java.ps1` - Java installation
- `03-PaperMC.ps1` - Server setup
- `04-Plugins.ps1` - Plugin installation
- `05-Configure.ps1` - Final configuration

Use the template in README.md as a starting point.

### 2. Add Utility Scripts

Create helpful utility scripts:
- `scripts/Start-Server.bat` - Server launcher
- `scripts/Monitor-Server.ps1` - Real-time monitoring
- `scripts/Update-Plugins.ps1` - Plugin updater

### 3. Create Config Templates

Add configuration templates:
- `configs/templates/server.properties.template`
- `configs/templates/paper-global.yml.template`
- `configs/templates/claudenpc.yml.template`

### 4. Add Documentation

Expand documentation:
- `docs/MODULES.md` - Detailed module docs
- `docs/PHASES.md` - Phase development guide
- `docs/API.md` - Complete function reference

---

## ✅ Deployment Checklist

- [ ] Extract project to permanent location
- [ ] Test Display module independently
- [ ] Test Logger module independently
- [ ] Test Safety module independently
- [ ] Test Config module independently
- [ ] Run Setup.ps1 in demo mode
- [ ] Create custom phase (optional)
- [ ] Integrate modules into existing scripts (optional)
- [ ] Create utility scripts (optional)
- [ ] Document customizations

---

## 🎉 Summary

You now have:

✅ **Modular Framework** - Reusable components  
✅ **Branded UI** - Professional appearance  
✅ **Complete Logging** - Track everything  
✅ **Safety Features** - Validation & backups  
✅ **Easy Extension** - Add phases & features  
✅ **Drop-In Ready** - Use in any project  

**Start experimenting:**
```powershell
cd claudenpc-server-suite\setup
.\Setup.ps1
```

**Questions or issues?** Check the main README.md or create an issue.

---

**Built with SAIF Methodology • Ready for Production**
