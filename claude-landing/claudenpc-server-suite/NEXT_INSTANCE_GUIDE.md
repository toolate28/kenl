# 🤖 Guide for Next Claude Instance

**Version:** v2.0.0 Enhanced Edition
**Last Updated:** December 11, 2024
**Status:** Production Ready

**Everything you need to know to continue this project**

---

## 🎯 Project Context

You're working on **ClaudeNPC Server Suite** - a modular, production-ready framework for setting up Minecraft PaperMC servers with AI-powered NPCs.

### What's Already Done ✅

```
✅ Core Framework Architecture (COMPLETE)
   ├─ Display.ps1  - UI/branding/tables/prompts
   ├─ Logger.ps1   - Logging system with file output
   ├─ Safety.ps1   - Validation/backups/checks
   ├─ Config.ps1   - Configuration management
   └─ Setup.ps1    - Main orchestrator

✅ Documentation (COMPLETE)
   ├─ README.md           - Full project docs
   ├─ DEPLOYMENT_GUIDE.md - Practical examples
   ├─ PROJECT_OVERVIEW.md - Quick reference
   └─ This file           - Your roadmap

✅ Project Structure (READY)
   ├─ setup/core/         - Core modules (done)
   ├─ setup/phases/       - Phase modules (need implementation)
   ├─ scripts/            - Utility scripts (need creation)
   ├─ configs/            - Templates (need creation)
   └─ docs/               - Additional docs (optional)
```

### What Needs To Be Done 🚧

```
🚧 Phase Modules (Priority 1)
   ├─ 01-Preflight.ps1   - Check Java, disk, network
   ├─ 02-Java.ps1        - Install/verify Java
   ├─ 03-PaperMC.ps1     - Download and setup server
   ├─ 04-Plugins.ps1     - Install plugins from profile
   └─ 05-Configure.ps1   - Apply configuration

🚧 Utility Scripts (Priority 2)
   ├─ Start-Server.bat   - Server launcher with JVM flags
   ├─ Backup-Server.ps1  - Automated backup script
   └─ Monitor-Server.ps1 - Health check script

🚧 Configuration Templates (Priority 3)
   ├─ server.properties.template
   ├─ paper-global.yml.template
   └─ claudenpc.yml.template
```

---

## 🚀 Quick Start for You

### Step 1: Understand the Framework

```powershell
# Test what's already built
cd /mnt/user-data/outputs/claudenpc-server-suite/setup
cat Setup.ps1  # Main orchestrator
cat core/Display.ps1  # See how UI works
cat core/Logger.ps1   # See how logging works
```

### Step 2: Choose Your Task

**Pick ONE of these tasks to implement:**

1. **Preflight Phase** (Easiest - start here)
2. **Java Installation Phase**
3. **PaperMC Setup Phase**  
4. **Plugin Installation Phase**
5. **Configuration Phase**

### Step 3: Use the Templates Below

Scroll down to find:
- Complete phase module template
- Working code snippets
- Integration instructions

---

## 📋 Task-by-Task Implementation Guide

### Task 1: Implement Preflight Phase ⭐ START HERE

**File:** `setup/phases/01-Preflight.ps1`

**What it does:**
- Checks PowerShell version
- Verifies admin privileges
- Tests for Java installation
- Checks disk space
- Tests network connectivity
- Validates PaperMC JAR exists

**Implementation:**

```powershell
# 01-Preflight.ps1
# Prerequisites validation phase
# Version: 1.0.0

function Invoke-PreflightChecks {
    param(
        [Parameter(Mandatory=$false)]
        [switch]$SkipPreflight
    )
    
    # Import core modules
    $coreRoot = Join-Path $PSScriptRoot "..\core"
    . "$coreRoot\Display.ps1"
    . "$coreRoot\Logger.ps1"
    . "$coreRoot\Safety.ps1"
    
    if ($SkipPreflight) {
        Write-StatusBox -Title "Preflight Checks" -Status "Skipped" -Type "Warning"
        Write-Log -Message "Preflight checks skipped by user" -Level "WARNING"
        return @{Success = $true; Skipped = $true}
    }
    
    Write-Section -Title "Preflight Checks" -Icon "🛡️"
    Write-Log -Message "Starting preflight checks" -Level "INFO"
    
    $checks = @()
    
    # Check 1: PowerShell Version
    $psVersion = $PSVersionTable.PSVersion
    $psOK = $psVersion.Major -ge 5
    $checks += @{
        Check = "PowerShell Version"
        Status = if ($psOK) { "✓ $($psVersion.ToString())" } else { "✗ $($psVersion.ToString())" }
        Required = "5.1+"
        Critical = $true
    }
    Write-StatusBox -Title "PowerShell Version" -Status $psVersion.ToString() -Type $(if ($psOK) { "Success" } else { "Error" })
    
    # Check 2: Administrator
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    $checks += @{
        Check = "Administrator"
        Status = if ($isAdmin) { "✓ Yes" } else { "✗ No" }
        Required = "Required"
        Critical = $true
    }
    Write-StatusBox -Title "Administrator Rights" -Status $(if ($isAdmin) { "Yes" } else { "No" }) -Type $(if ($isAdmin) { "Success" } else { "Error" })
    
    # Check 3: Java
    $javaOK = $false
    $javaVersion = "Not installed"
    try {
        $javaCheck = java -version 2>&1
        if ($javaCheck -match 'version "(\d+)') {
            $javaVer = [int]$matches[1]
            $javaOK = $javaVer -ge 17
            $javaVersion = "Java $javaVer"
        }
    } catch {
        $javaVersion = "Not found"
    }
    $checks += @{
        Check = "Java JDK"
        Status = if ($javaOK) { "✓ $javaVersion" } else { "⚠ $javaVersion" }
        Required = "17+"
        Critical = $false
    }
    Write-StatusBox -Title "Java JDK" -Status $javaVersion -Type $(if ($javaOK) { "Success" } else { "Warning" })
    
    # Check 4: Disk Space
    $diskCheck = Test-DiskSpace -Path "C:\" -RequiredGB 10
    $checks += @{
        Check = "Disk Space"
        Status = if ($diskCheck.Success) { "✓ $($diskCheck.FreeSpaceGB) GB free" } else { "✗ $($diskCheck.FreeSpaceGB) GB free" }
        Required = "10+ GB"
        Critical = $diskCheck.FreeSpaceGB -lt 5
    }
    Write-StatusBox -Title "Disk Space" -Status "$($diskCheck.FreeSpaceGB) GB" -Type $(if ($diskCheck.Success) { "Success" } else { "Warning" })
    
    # Check 5: Network
    $netCheck = Test-NetworkConnectivity
    $netStatus = "$($netCheck.Results | Where-Object {$_.Connected} | Measure-Object).Count/$($netCheck.Results.Count) services"
    $checks += @{
        Check = "Network"
        Status = if ($netCheck.AllConnected) { "✓ Connected" } else { "⚠ $netStatus" }
        Required = "Internet"
        Critical = $false
    }
    Write-StatusBox -Title "Network Connectivity" -Status $netStatus -Type $(if ($netCheck.AllConnected) { "Success" } else { "Warning" })
    
    # Check 6: PaperMC JAR
    $downloadsPath = "$env:USERPROFILE\Downloads"
    $paperJar = Get-ChildItem $downloadsPath -Filter "paper-*.jar" -ErrorAction SilentlyContinue | Select-Object -First 1
    $paperOK = $null -ne $paperJar
    $checks += @{
        Check = "PaperMC JAR"
        Status = if ($paperOK) { "✓ Found" } else { "⚠ Not found" }
        Required = "In Downloads"
        Critical = $false
    }
    Write-StatusBox -Title "PaperMC JAR" -Status $(if ($paperOK) { "Found: $($paperJar.Name)" } else { "Not in Downloads" }) -Type $(if ($paperOK) { "Success" } else { "Warning" })
    
    # Display summary table
    Write-Host ""
    Write-ResultsTable -Data $checks -Headers @("Check", "Status", "Required")
    
    # Evaluate results
    $criticalFailures = $checks | Where-Object { $_.Critical -and $_.Status -notmatch '✓' }
    $warnings = $checks | Where-Object { -not $_.Critical -and $_.Status -notmatch '✓' }
    
    if ($criticalFailures.Count -gt 0) {
        Write-Host ""
        Write-StatusBox -Title "Preflight Failed" -Status "$($criticalFailures.Count) critical issues" -Type "Error"
        Write-Log -Message "Preflight failed with $($criticalFailures.Count) critical issues" -Level "ERROR"
        return @{Success = $false; Critical = $criticalFailures.Count; Warnings = $warnings.Count}
    }
    
    if ($warnings.Count -gt 0) {
        Write-Host ""
        Write-StatusBox -Title "Preflight Warnings" -Status "$($warnings.Count) non-critical issues" -Type "Warning"
        Write-Log -Message "Preflight passed with $($warnings.Count) warnings" -Level "WARNING"
        
        $proceed = Read-Confirmation -Message "Continue despite warnings?" -DefaultYes
        if (-not $proceed) {
            return @{Success = $false; UserCancelled = $true}
        }
    } else {
        Write-Host ""
        Write-StatusBox -Title "Preflight Complete" -Status "All checks passed" -Type "Success"
        Write-Log -Message "All preflight checks passed" -Level "SUCCESS"
    }
    
    return @{Success = $true; Warnings = $warnings.Count}
}

Export-ModuleMember -Function Invoke-PreflightChecks
```

**Integration into Setup.ps1:**

```powershell
# In Setup.ps1, after configuration loading:

# Execute Preflight Phase
. (Join-Path $script:SetupRoot "phases\01-Preflight.ps1")
$preflightResult = Invoke-PreflightChecks -SkipPreflight:$SkipPreflight

if (-not $preflightResult.Success) {
    Write-StatusBox -Title "Setup Aborted" -Status "Preflight checks failed" -Type "Error"
    Close-Logger -Success $false
    exit 1
}
```

---

### Task 2: Implement Java Installation Phase

**File:** `setup/phases/02-Java.ps1`

**What it does:**
- Checks if Java 17+ is installed
- If not, looks for Java installer in Downloads
- Extracts and installs Java
- Sets JAVA_HOME and PATH
- Verifies installation

**Key snippet:**

```powershell
function Install-Java {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Config
    )
    
    Write-Section -Title "Java Installation" -Icon "☕"
    
    # Check if Java already installed
    try {
        $javaCheck = java -version 2>&1
        if ($javaCheck -match 'version "(\d+)') {
            $javaVer = [int]$matches[1]
            if ($javaVer -ge 17) {
                Write-StatusBox -Title "Java $javaVer" -Status "Already installed" -Type "Success"
                return @{Success = $true; AlreadyInstalled = $true}
            }
        }
    } catch {
        Write-Log -Message "Java not found, will install" -Level "INFO"
    }
    
    # Find Java installer
    $javaZip = Get-ChildItem "$env:USERPROFILE\Downloads" -Filter "openjdk-*_windows-x64*.zip" | Select-Object -First 1
    
    if (-not $javaZip) {
        Write-StatusBox -Title "Java Installer" -Status "Not found in Downloads" -Type "Error"
        Write-Host ""
        Write-Host "  Please download Java from:" -ForegroundColor Yellow
        Write-Host "  https://jdk.java.net/" -ForegroundColor White
        return @{Success = $false; NotFound = $true}
    }
    
    # Extract Java
    $javaPath = "C:\Java\jdk-21"
    Write-StatusBox -Title "Extracting Java" -Status $javaPath -Type "Progress"
    
    Expand-Archive -Path $javaZip.FullName -DestinationPath "C:\Java" -Force
    
    # Set environment variables
    [Environment]::SetEnvironmentVariable("JAVA_HOME", $javaPath, "Machine")
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if ($currentPath -notlike "*$javaPath\bin*") {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$javaPath\bin", "Machine")
    }
    
    Write-StatusBox -Title "Java Installation" -Status "Complete" -Type "Success"
    return @{Success = $true; Installed = $true}
}
```

---

### Task 3: Implement PaperMC Setup Phase

**File:** `setup/phases/03-PaperMC.ps1`

**What it does:**
- Finds PaperMC JAR in Downloads
- Creates server directory structure
- Copies JAR
- Creates start.bat with optimized JVM flags
- Accepts EULA
- Runs first-time initialization

**Key snippet:**

```powershell
function Install-PaperMC {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Config
    )
    
    Write-Section -Title "PaperMC Installation" -Icon "📦"
    
    # Find PaperMC JAR
    $paperJar = Get-ChildItem "$env:USERPROFILE\Downloads" -Filter "paper-*.jar" | Select-Object -First 1
    
    if (-not $paperJar) {
        Write-StatusBox -Title "PaperMC JAR" -Status "Not found" -Type "Error"
        return @{Success = $false}
    }
    
    # Create directory structure
    $serverPath = $Config.ServerPath
    New-Item -ItemType Directory -Path $serverPath -Force | Out-Null
    New-Item -ItemType Directory -Path "$serverPath\plugins" -Force | Out-Null
    New-Item -ItemType Directory -Path "$serverPath\logs" -Force | Out-Null
    
    # Copy JAR
    Copy-Item $paperJar.FullName -Destination "$serverPath\paper.jar"
    Write-StatusBox -Title "Paper JAR" -Status "Copied" -Type "Success"
    
    # Create start.bat with Aikar's flags
    $startScript = @"
@echo off
title PaperMC Server - ClaudeNPC Suite

java -Xms$($Config.MemoryMin) -Xmx$($Config.MemoryMax) \
     -XX:+UseG1GC \
     -XX:+ParallelRefProcEnabled \
     -XX:MaxGCPauseMillis=200 \
     -XX:+UnlockExperimentalVMOptions \
     -XX:+DisableExplicitGC \
     -XX:+AlwaysPreTouch \
     -XX:G1NewSizePercent=30 \
     -XX:G1MaxNewSizePercent=40 \
     -XX:G1HeapRegionSize=8M \
     -XX:G1ReservePercent=20 \
     -XX:G1HeapWastePercent=5 \
     -XX:G1MixedGCCountTarget=4 \
     -XX:InitiatingHeapOccupancyPercent=15 \
     -XX:G1MixedGCLiveThresholdPercent=90 \
     -XX:G1RSetUpdatingPauseTimePercent=5 \
     -XX:SurvivorRatio=32 \
     -XX:+PerfDisableSharedMem \
     -XX:MaxTenuringThreshold=1 \
     -Dusing.aikars.flags=https://mcflags.emc.gs \
     -Daikars.new.flags=true \
     -jar paper.jar nogui

pause
"@
    $startScript | Set-Content "$serverPath\start.bat" -Encoding ASCII
    Write-StatusBox -Title "Start Script" -Status "Created" -Type "Success"
    
    # Accept EULA
    "eula=true" | Set-Content "$serverPath\eula.txt"
    Write-StatusBox -Title "EULA" -Status "Accepted" -Type "Success"
    
    return @{Success = $true}
}
```

---

### Task 4: Implement Plugin Installation Phase

**File:** `setup/phases/04-Plugins.ps1`

**What it does:**
- Loads plugin list from install profile
- Searches Downloads for plugin JARs
- Copies found plugins to plugins/
- Reports missing plugins with download URLs

**Key snippet:**

```powershell
function Install-Plugins {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Config
    )
    
    Write-Section -Title "Plugin Installation" -Icon "🔌"
    
    $profile = Get-InstallProfile -ProfileName $Config.InstallProfile
    $pluginsPath = Join-Path $Config.ServerPath "plugins"
    
    $installed = @()
    $missing = @()
    
    foreach ($plugin in $profile.Plugins) {
        # Search for plugin JAR
        $pluginJar = Get-ChildItem "$env:USERPROFILE\Downloads" -Filter "$plugin*.jar" -ErrorAction SilentlyContinue | Select-Object -First 1
        
        if ($pluginJar) {
            Copy-Item $pluginJar.FullName -Destination $pluginsPath
            $installed += $plugin
            Write-StatusBox -Title $plugin -Status "Installed" -Type "Success"
        } else {
            $missing += $plugin
            Write-StatusBox -Title $plugin -Status "Not found" -Type "Warning"
        }
    }
    
    if ($missing.Count -gt 0) {
        Write-Host ""
        Write-Host "  Missing plugins - download from:" -ForegroundColor Yellow
        Write-Host "  • Citizens: https://ci.citizensnpcs.co/job/Citizens2/" -ForegroundColor White
        Write-Host "  • Vault: https://www.spigotmc.org/resources/vault.34315/" -ForegroundColor White
        # ... more URLs
    }
    
    return @{
        Success = $true
        Installed = $installed.Count
        Missing = $missing.Count
        PluginList = $installed
    }
}
```

---

### Task 5: Implement Configuration Phase

**File:** `setup/phases/05-Configure.ps1`

**What it does:**
- Loads configuration templates
- Replaces placeholders with actual values
- Writes server.properties, paper-global.yml, etc.
- Configures ClaudeNPC with API key

---

## 🔧 Integration Checklist

When you implement a phase, follow this checklist:

1. **Create the phase file** in `setup/phases/`
2. **Import core modules** at the top:
   ```powershell
   $coreRoot = Join-Path $PSScriptRoot "..\core"
   . "$coreRoot\Display.ps1"
   . "$coreRoot\Logger.ps1"
   . "$coreRoot\Safety.ps1"
   . "$coreRoot\Config.ps1"
   ```
3. **Use Write-StatusBox** for all user feedback
4. **Use Write-Log** for all logging
5. **Return a result hashtable** with Success key
6. **Export the main function** at the end
7. **Update Setup.ps1** to call your phase
8. **Test independently** before integration

---

## 📝 Testing Your Phase

```powershell
# Test independently
. .\setup\core\Display.ps1
. .\setup\core\Logger.ps1
. .\setup\phases\01-Preflight.ps1

Show-Banner
$log = Initialize-Logger -LogPath ".\test-logs"
$result = Invoke-PreflightChecks
Close-Logger -Success $result.Success

Write-Host "Result: $($result | ConvertTo-Json)"
```

---

## 🎯 Priority Order

Implement in this order for best results:

1. ⭐ **01-Preflight.ps1** (Easy, validates everything)
2. **02-Java.ps1** (Medium, file operations)
3. **03-PaperMC.ps1** (Medium, creates server)
4. **04-Plugins.ps1** (Easy, file copying)
5. **05-Configure.ps1** (Medium, template processing)

---

## 💡 Tips for Success

### Use Existing Patterns

```powershell
# Good - matches existing style
Write-StatusBox -Title "Task Name" -Status "Complete" -Type "Success"
Write-Log -Message "Task completed" -Level "SUCCESS"

# Bad - doesn't match
Write-Host "Task complete" -ForegroundColor Green
```

### Always Return Results

```powershell
# Good
return @{
    Success = $true
    ItemsProcessed = 42
    Warnings = @("Warning 1", "Warning 2")
}

# Bad
return $true  # Loses context
```

### Error Handling

```powershell
try {
    # Risky operation
    Write-StatusBox -Title "Operation" -Status "Complete" -Type "Success"
    return @{Success = $true}
} catch {
    Write-StatusBox -Title "Failed" -Status $_.Exception.Message -Type "Error"
    Write-LogError -ErrorRecord $_
    return @{Success = $false; Error = $_.Exception.Message}
}
```

---

## 📚 Reference Files

**Must read before starting:**
- `README.md` - Complete project documentation
- `DEPLOYMENT_GUIDE.md` - Usage examples
- `setup/core/Display.ps1` - See how UI works
- `setup/core/Logger.ps1` - See how logging works

**Templates to copy:**
- Phase template (above in Task 1)
- Error handling pattern
- Return value pattern

---

## 🎉 When You're Done

1. **Test each phase independently**
2. **Test full Setup.ps1 execution**
3. **Update this guide** with any learnings
4. **Document any issues** you encountered
5. **Celebrate!** You've built a production system

---

## 🚨 Common Pitfalls to Avoid

❌ **Don't** write monolithic code - keep functions focused  
❌ **Don't** skip error handling - wrap everything in try/catch  
❌ **Don't** forget logging - log all major operations  
❌ **Don't** hardcode paths - use Join-Path and parameters  
❌ **Don't** ignore return values - always check Success  

✅ **Do** use existing Display functions  
✅ **Do** follow the module patterns  
✅ **Do** test independently  
✅ **Do** document as you go  
✅ **Do** ask user for confirmation on destructive ops  

---

## 📞 Need Help?

Check these files:
- `setup/core/Display.ps1` - For UI functions
- `setup/core/Logger.ps1` - For logging
- `setup/core/Safety.ps1` - For validation examples
- `DEPLOYMENT_GUIDE.md` - For working examples

---

## ✅ Task Completion Tracker

```
Phase Modules:
[ ] 01-Preflight.ps1   - Prerequisites check
[ ] 02-Java.ps1        - Java installation
[ ] 03-PaperMC.ps1     - Server setup
[ ] 04-Plugins.ps1     - Plugin installation
[ ] 05-Configure.ps1   - Configuration

Utility Scripts:
[ ] Start-Server.bat   - Server launcher
[ ] Backup-Server.ps1  - Backup automation
[ ] Monitor-Server.ps1 - Health monitoring

Templates:
[ ] server.properties.template
[ ] paper-global.yml.template
[ ] claudenpc.yml.template

Testing:
[ ] Test each phase independently
[ ] Test full Setup.ps1 flow
[ ] Test error handling
[ ] Test user cancellation
[ ] Test with different profiles
```

---

## 🎯 Your Mission

**Implement the phase modules to complete this production-ready server setup framework.**

**Start with:** `01-Preflight.ps1` (easiest)

**Use:** The templates and snippets above

**Follow:** Existing patterns in core modules

**Test:** Each phase independently before integration

**You've got this!** The hard architecture work is done. You're just filling in the implementation details following clear patterns.

---

**Good luck! Build something amazing! 🚀**
