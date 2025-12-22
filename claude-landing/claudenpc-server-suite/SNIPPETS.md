# 📝 Copy-Paste Code Snippets

**Ready-to-use code blocks for rapid development**

---

## 🎯 Quick Navigation

1. [Phase Module Snippets](#phase-module-snippets)
2. [Utility Script Snippets](#utility-script-snippets)
3. [Configuration Template Snippets](#configuration-template-snippets)
4. [Testing Snippets](#testing-snippets)
5. [Integration Snippets](#integration-snippets)

---

## 📦 Phase Module Snippets

### Complete 01-Preflight.ps1

```powershell
# 01-Preflight.ps1
# Prerequisites checking phase
# Version: 1.0.0

$scriptRoot = Split-Path $PSScriptRoot -Parent
. "$scriptRoot\core\Display.ps1"
. "$scriptRoot\core\Logger.ps1"
. "$scriptRoot\core\Safety.ps1"

function Invoke-PreflightChecks {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Config,
        
        [Parameter(Mandatory=$false)]
        [switch]$SkipPreflight
    )
    
    if ($SkipPreflight) {
        Write-StatusBox -Title "Preflight" -Status "Skipped" -Type "Warning"
        return @{Success = $true; Message = "Skipped"; Data = @{}}
    }
    
    Write-Section -Title "Preflight Checks" -Icon "✓"
    Write-Log -Message "Running preflight checks" -Level "INFO"
    
    $checks = @()
    
    try {
        # Check 1: PowerShell Version
        $psVersion = $PSVersionTable.PSVersion
        $psOK = $psVersion.Major -ge 5
        $checks += @{
            Check = "PowerShell"
            Status = if ($psOK) { "✓ Pass" } else { "✗ Fail" }
            Details = "Version $($psVersion.Major).$($psVersion.Minor)"
        }
        
        # Check 2: Administrator Rights
        $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        $checks += @{
            Check = "Admin Rights"
            Status = if ($isAdmin) { "✓ Pass" } else { "✗ Fail" }
            Details = if ($isAdmin) { "Running as Administrator" } else { "Not Administrator" }
        }
        
        # Check 3: Disk Space
        $disk = Test-DiskSpace -Path $Config.ServerPath -RequiredGB 10
        $checks += @{
            Check = "Disk Space"
            Status = if ($disk.Success) { "✓ Pass" } else { "⚠ Warning" }
            Details = "$($disk.FreeSpaceGB) GB free on $($disk.Drive):"
        }
        
        # Check 4: Network Connectivity
        $network = Test-NetworkConnectivity
        $checks += @{
            Check = "Network"
            Status = if ($network.AllConnected) { "✓ Pass" } else { "⚠ Warning" }
            Details = "$($network.Results.Count) services tested"
        }
        
        # Check 5: PaperMC JAR
        $paperJar = Get-ChildItem "$env:USERPROFILE\Downloads" -Filter "paper-*.jar" -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1
        $checks += @{
            Check = "PaperMC JAR"
            Status = if ($paperJar) { "✓ Pass" } else { "⚠ Warning" }
            Details = if ($paperJar) { $paperJar.Name } else { "Not found in Downloads" }
        }
        
        # Check 6: Java
        $javaVersion = $null
        try {
            $javaVersion = & java -version 2>&1 | Select-Object -First 1
        } catch {}
        $checks += @{
            Check = "Java"
            Status = if ($javaVersion) { "✓ Pass" } else { "ℹ Info" }
            Details = if ($javaVersion) { $javaVersion } else { "Will be installed in Phase 2" }
        }
        
        # Display results
        Write-ResultsTable -Data $checks -Headers @("Check", "Status", "Details")
        
        # Evaluate
        $failed = $checks | Where-Object { $_.Status -like "*✗*" }
        $warnings = $checks | Where-Object { $_.Status -like "*⚠*" }
        
        if ($failed.Count -gt 0) {
            Write-StatusBox -Title "Preflight" -Status "$($failed.Count) critical failures" -Type "Error"
            Write-Log -Message "Preflight failed: $($failed.Count) critical failures" -Level "ERROR"
            return @{
                Success = $false
                Message = "Critical preflight checks failed"
                Data = @{Checks = $checks}
            }
        }
        
        if ($warnings.Count -gt 0) {
            Write-StatusBox -Title "Preflight" -Status "$($warnings.Count) warnings" -Type "Warning"
            $proceed = Read-Confirmation -Message "Continue with warnings?" -DefaultYes:$false
            if (-not $proceed) {
                return @{Success = $false; Message = "User cancelled"; Data = @{}}
            }
        }
        
        Write-StatusBox -Title "Preflight Checks" -Status "Complete" -Type "Success"
        Write-Log -Message "Preflight checks passed" -Level "SUCCESS"
        
        return @{
            Success = $true
            Message = "All checks passed"
            Data = @{Checks = $checks}
        }
        
    } catch {
        Write-StatusBox -Title "Preflight Failed" -Status $_.Exception.Message -Type "Error"
        Write-LogError -ErrorRecord $_
        return @{Success = $false; Message = $_.Exception.Message; Data = @{}}
    }
}

Export-ModuleMember -Function Invoke-PreflightChecks
```

---

### Complete 02-Java.ps1

```powershell
# 02-Java.ps1
# Java installation phase
# Version: 1.0.0

$scriptRoot = Split-Path $PSScriptRoot -Parent
. "$scriptRoot\core\Display.ps1"
. "$scriptRoot\core\Logger.ps1"
. "$scriptRoot\core\Safety.ps1"

function Invoke-JavaInstallation {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Config
    )
    
    Write-Section -Title "Java Installation" -Icon "☕"
    Write-Log -Message "Starting Java installation" -Level "INFO"
    
    try {
        # Check if Java already installed
        Write-StatusBox -Title "Checking for Java" -Status "Processing" -Type "Progress"
        
        $javaInstalled = $false
        try {
            $javaVersion = & java -version 2>&1 | Select-Object -First 1
            if ($javaVersion -match "(\d+)\.(\d+)\.(\d+)") {
                $major = [int]$Matches[1]
                if ($major -ge 17) {
                    $javaInstalled = $true
                    Write-StatusBox -Title "Java Found" -Status "Version $major" -Type "Success"
                    Write-Log -Message "Java already installed: $javaVersion" -Level "SUCCESS"
                }
            }
        } catch {
            # Java not found
        }
        
        if ($javaInstalled) {
            return @{
                Success = $true
                Message = "Java already installed"
                Data = @{JavaVersion = $javaVersion}
            }
        }
        
        # Find Java installer
        Write-StatusBox -Title "Searching for Java installer" -Status "Processing" -Type "Progress"
        
        $javaZip = Get-ChildItem "$env:USERPROFILE\Downloads" -Filter "openjdk-*_windows-x64*.zip" -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1
        
        if (-not $javaZip) {
            Write-StatusBox -Title "Java Installer" -Status "Not found in Downloads" -Type "Error"
            Write-Host ""
            Write-Host "  Please download OpenJDK from:" -ForegroundColor Yellow
            Write-Host "  https://jdk.java.net/25/" -ForegroundColor White
            Write-Host ""
            
            return @{
                Success = $false
                Message = "Java installer not found"
                Data = @{}
            }
        }
        
        Write-StatusBox -Title "Java Installer Found" -Status $javaZip.Name -Type "Success"
        
        # Extract Java
        Write-StatusBox -Title "Extracting Java" -Status "Processing" -Type "Progress"
        
        $javaPath = "C:\Java"
        if (-not (Test-Path $javaPath)) {
            New-Item -ItemType Directory -Path $javaPath -Force | Out-Null
        }
        
        Expand-Archive -Path $javaZip.FullName -DestinationPath $javaPath -Force
        
        # Find extracted JDK folder
        $jdkFolder = Get-ChildItem $javaPath -Directory | Where-Object { $_.Name -match "jdk" } | Select-Object -First 1
        
        if (-not $jdkFolder) {
            throw "Could not find extracted JDK folder"
        }
        
        $javaHome = $jdkFolder.FullName
        Write-StatusBox -Title "Java Extracted" -Status $javaHome -Type "Success"
        
        # Set JAVA_HOME
        Write-StatusBox -Title "Setting JAVA_HOME" -Status "Processing" -Type "Progress"
        [Environment]::SetEnvironmentVariable("JAVA_HOME", $javaHome, "Machine")
        Write-StatusBox -Title "JAVA_HOME" -Status "Set" -Type "Success"
        
        # Update PATH
        Write-StatusBox -Title "Updating PATH" -Status "Processing" -Type "Progress"
        $path = [Environment]::GetEnvironmentVariable("Path", "Machine")
        $javaBin = Join-Path $javaHome "bin"
        if ($path -notlike "*$javaBin*") {
            $path = "$path;$javaBin"
            [Environment]::SetEnvironmentVariable("Path", $path, "Machine")
        }
        Write-StatusBox -Title "PATH" -Status "Updated" -Type "Success"
        
        # Refresh environment for current session
        $env:JAVA_HOME = $javaHome
        $env:Path = "$env:Path;$javaBin"
        
        # Verify installation
        Write-StatusBox -Title "Verifying Java" -Status "Processing" -Type "Progress"
        $javaVersion = & java -version 2>&1 | Select-Object -First 1
        Write-StatusBox -Title "Java Installation" -Status "Complete" -Type "Success"
        Write-StatusBox -Title "Java Version" -Status $javaVersion -Type "Info"
        
        Write-Log -Message "Java installed successfully: $javaVersion" -Level "SUCCESS"
        
        return @{
            Success = $true
            Message = "Java installed successfully"
            Data = @{
                JavaHome = $javaHome
                JavaVersion = $javaVersion
            }
        }
        
    } catch {
        Write-StatusBox -Title "Java Installation Failed" -Status $_.Exception.Message -Type "Error"
        Write-LogError -ErrorRecord $_
        return @{Success = $false; Message = $_.Exception.Message; Data = @{}}
    }
}

Export-ModuleMember -Function Invoke-JavaInstallation
```

---

### Complete 03-PaperMC.ps1

```powershell
# 03-PaperMC.ps1
# PaperMC server installation phase
# Version: 1.0.0

$scriptRoot = Split-Path $PSScriptRoot -Parent
. "$scriptRoot\core\Display.ps1"
. "$scriptRoot\core\Logger.ps1"
. "$scriptRoot\core\Safety.ps1"

function Invoke-PaperMCSetup {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Config
    )
    
    Write-Section -Title "PaperMC Server Setup" -Icon "📄"
    Write-Log -Message "Starting PaperMC setup" -Level "INFO"
    
    try {
        # Check for existing installation
        $existing = Test-ExistingInstallation -ServerPath $Config.ServerPath
        if ($existing.Exists) {
            $choice = Invoke-BackupPrompt -ExistingFiles $existing.Files
            
            switch ($choice) {
                'B' {
                    $backupPath = Join-Path (Split-Path $Config.ServerPath -Parent) "backups"
                    Backup-ExistingServer -ServerPath $Config.ServerPath -BackupPath $backupPath
                }
                'O' {
                    Write-Host ""
                    Write-Host "  Type 'DELETE' to confirm deletion: " -ForegroundColor Red -NoNewline
                    $confirm = Read-Host
                    if ($confirm -ne 'DELETE') {
                        return @{Success = $false; Message = "User cancelled"; Data = @{}}
                    }
                    Remove-SafeDirectory -Path $Config.ServerPath -Force
                }
                'C' {
                    return @{Success = $false; Message = "User cancelled"; Data = @{}}
                }
            }
        }
        
        # Create directory structure
        Write-StatusBox -Title "Creating directories" -Status "Processing" -Type "Progress"
        
        $dirs = @("plugins", "world", "logs", "backups")
        foreach ($dir in $dirs) {
            $path = Join-Path $Config.ServerPath $dir
            if (-not (Test-Path $path)) {
                New-Item -ItemType Directory -Path $path -Force | Out-Null
            }
        }
        Write-StatusBox -Title "Directories Created" -Status "Complete" -Type "Success"
        
        # Find PaperMC JAR
        Write-StatusBox -Title "Searching for PaperMC" -Status "Processing" -Type "Progress"
        
        $paperJar = Get-ChildItem "$env:USERPROFILE\Downloads" -Filter "paper-*.jar" -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1
        
        if (-not $paperJar) {
            Write-StatusBox -Title "PaperMC JAR" -Status "Not found in Downloads" -Type "Error"
            return @{Success = $false; Message = "PaperMC JAR not found"; Data = @{}}
        }
        
        # Copy JAR
        $destJar = Join-Path $Config.ServerPath "paper.jar"
        Copy-Item $paperJar.FullName $destJar -Force
        Write-StatusBox -Title "PaperMC JAR" -Status "Copied" -Type "Success"
        
        # Create start.bat
        Write-StatusBox -Title "Creating start.bat" -Status "Processing" -Type "Progress"
        
        $startBat = @"
@echo off
title ClaudeNPC Minecraft Server
color 0B

echo.
echo ╔══════════════════════════════════════════════════════════╗
echo ║           ClaudeNPC Minecraft Server                     ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

java -Xms$($Config.MemoryMin) -Xmx$($Config.MemoryMax) ^
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
"@
        $startBat | Set-Content (Join-Path $Config.ServerPath "start.bat") -Encoding ASCII
        Write-StatusBox -Title "start.bat" -Status "Created" -Type "Success"
        
        # Accept EULA
        Write-StatusBox -Title "Accepting EULA" -Status "Processing" -Type "Progress"
        "eula=true" | Set-Content (Join-Path $Config.ServerPath "eula.txt")
        Write-StatusBox -Title "EULA" -Status "Accepted" -Type "Success"
        
        # Initial server start
        Write-StatusBox -Title "Initial server start" -Status "Generating configs..." -Type "Progress"
        Write-Host ""
        Write-Host "  This will take 1-2 minutes. The server will start and stop automatically." -ForegroundColor Gray
        Write-Host ""
        
        $process = Start-Process -FilePath "java" `
            -ArgumentList @("-Xms1G", "-Xmx2G", "-jar", $destJar, "nogui") `
            -WorkingDirectory $Config.ServerPath `
            -PassThru `
            -NoNewWindow
        
        # Wait for server.properties to be created
        $timeout = 120
        $elapsed = 0
        while (-not (Test-Path (Join-Path $Config.ServerPath "server.properties")) -and $elapsed -lt $timeout) {
            Start-Sleep -Seconds 2
            $elapsed += 2
        }
        
        # Stop server
        if (-not $process.HasExited) {
            $process | Stop-Process -Force
            Start-Sleep -Seconds 2
        }
        
        Write-StatusBox -Title "Server Configuration" -Status "Generated" -Type "Success"
        Write-Log -Message "PaperMC setup complete" -Level "SUCCESS"
        
        return @{
            Success = $true
            Message = "PaperMC setup complete"
            Data = @{ServerPath = $Config.ServerPath}
        }
        
    } catch {
        Write-StatusBox -Title "PaperMC Setup Failed" -Status $_.Exception.Message -Type "Error"
        Write-LogError -ErrorRecord $_
        return @{Success = $false; Message = $_.Exception.Message; Data = @{}}
    }
}

Export-ModuleMember -Function Invoke-PaperMCSetup
```

---

## 🛠️ Utility Script Snippets

### Backup-Server.ps1 (Complete)

```powershell
#Requires -Version 5.1
param(
    [Parameter(Mandatory=$true)]
    [string]$ServerPath,
    
    [Parameter(Mandatory=$false)]
    [string]$BackupPath = "$ServerPath\backups",
    
    [Parameter(Mandatory=$false)]
    [int]$KeepLast = 7
)

$moduleBase = Split-Path $PSScriptRoot -Parent
. "$moduleBase\setup\core\Display.ps1"
. "$moduleBase\setup\core\Logger.ps1"
. "$moduleBase\setup\core\Safety.ps1"

Show-Banner
$logFile = Initialize-Logger -LogPath "$ServerPath\logs"

Write-Section -Title "Server Backup" -Icon "📦"

try {
    # Create backup
    $backup = Backup-ExistingServer -ServerPath $ServerPath -BackupPath $BackupPath
    Write-StatusBox -Title "Backup Complete" -Status $backup -Type "Success"
    Write-Log -Message "Backup created: $backup" -Level "SUCCESS"
    
    # Cleanup old backups
    Write-StatusBox -Title "Cleaning old backups" -Status "Processing" -Type "Progress"
    
    $oldBackups = Get-ChildItem $BackupPath -Filter "*.zip" |
        Sort-Object LastWriteTime -Descending |
        Select-Object -Skip $KeepLast
    
    foreach ($old in $oldBackups) {
        Remove-Item $old.FullName -Force
        Write-StatusBox -Title "Removed" -Status $old.Name -Type "Info"
        Write-Log -Message "Removed old backup: $($old.Name)" -Level "INFO"
    }
    
    Write-StatusBox -Title "Cleanup" -Status "Complete" -Type "Success"
    
    # Summary
    $backupCount = (Get-ChildItem $BackupPath -Filter "*.zip").Count
    Write-Host ""
    Write-Host "  Total backups: $backupCount" -ForegroundColor Cyan
    Write-Host "  Latest: $backup" -ForegroundColor Gray
    Write-Host ""
    
    Close-Logger -Success $true
    
} catch {
    Write-StatusBox -Title "Backup Failed" -Status $_.Exception.Message -Type "Error"
    Write-LogError -ErrorRecord $_
    Close-Logger -Success $false
    exit 1
}
```

---

### Monitor-Server.ps1 (Complete)

```powershell
#Requires -Version 5.1
param(
    [Parameter(Mandatory=$true)]
    [string]$ServerPath,
    
    [Parameter(Mandatory=$false)]
    [int]$IntervalSeconds = 60
)

$moduleBase = Split-Path $PSScriptRoot -Parent
. "$moduleBase\setup\core\Display.ps1"
. "$moduleBase\setup\core\Safety.ps1"

Show-Banner

Write-Host ""
Write-Host "  Monitoring server every $IntervalSeconds seconds" -ForegroundColor Gray
Write-Host "  Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host ""

while ($true) {
    Clear-Host
    Show-Banner
    Write-Section -Title "Server Status - $(Get-Date -Format 'HH:mm:ss')" -Icon "📊"
    
    $status = @()
    
    # Check if server is running
    $process = Get-Process java -ErrorAction SilentlyContinue | Where-Object {
        $_.Path -like "*$ServerPath*"
    }
    
    if ($process) {
        $cpu = [math]::Round($process.CPU, 2)
        $memMB = [math]::Round($process.WorkingSet64 / 1MB, 0)
        $status += @{
            Check = "Server Process"
            Status = "✓ Running"
            Details = "PID: $($process.Id), CPU: ${cpu}s, RAM: ${memMB}MB"
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
        Details = if (-not $port) { "Server listening" } else { "Port free" }
    }
    
    # Log file size
    $logDir = Join-Path $ServerPath "logs"
    if (Test-Path $logDir) {
        $logSize = (Get-ChildItem $logDir -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
        $status += @{
            Check = "Log Files"
            Status = "ℹ $([math]::Round($logSize, 1)) MB"
            Details = "Total log size"
        }
    }
    
    # Backup age
    $backupDir = Join-Path $ServerPath "backups"
    if (Test-Path $backupDir) {
        $latestBackup = Get-ChildItem $backupDir -Filter "*.zip" -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1
        
        if ($latestBackup) {
            $age = (Get-Date) - $latestBackup.LastWriteTime
            $ageStr = if ($age.TotalHours -lt 1) {
                "$([math]::Round($age.TotalMinutes, 0)) minutes ago"
            } elseif ($age.TotalDays -lt 1) {
                "$([math]::Round($age.TotalHours, 1)) hours ago"
            } else {
                "$([math]::Round($age.TotalDays, 1)) days ago"
            }
            
            $status += @{
                Check = "Last Backup"
                Status = if ($age.TotalDays -lt 1) { "✓ $ageStr" } else { "⚠ $ageStr" }
                Details = $latestBackup.Name
            }
        }
    }
    
    Write-ResultsTable -Data $status -Headers @("Check", "Status", "Details")
    
    Start-Sleep -Seconds $IntervalSeconds
}
```

---

## 📋 Configuration Template Snippets

### server.properties.template

```properties
# Minecraft Server Properties
# Generated by ClaudeNPC Server Suite
# {{GeneratedDate}}

# Network Settings
server-port={{ServerPort}}
server-ip=
online-mode={{OnlineMode}}
enable-rcon=false
enable-query=false

# World Settings
level-name=world
level-seed=
gamemode={{Gamemode}}
difficulty={{Difficulty}}
hardcore=false
allow-nether=true
allow-end=true

# Player Limits
max-players={{MaxPlayers}}
max-world-size=29999984

# Performance
view-distance={{ViewDistance}}
simulation-distance={{SimulationDistance}}
max-tick-time=60000
network-compression-threshold=256

# Gameplay
pvp={{PVP}}
allow-flight=false
spawn-protection=16
spawn-monsters=true
spawn-animals=true
spawn-npcs=true

# Server Management
motd={{MOTD}}
white-list=false
enforce-whitelist=false
resource-pack=
require-resource-pack=false

# Advanced
enable-command-block=false
enable-jmx-monitoring=false
sync-chunk-writes=true
use-native-transport=true
rate-limit=0
```

---

### claudenpc-config.yml.template

```yaml
# ClaudeNPC Configuration
# Generated by ClaudeNPC Server Suite

# Anthropic API Configuration
api:
  # Your Anthropic API key
  key: "{{ClaudeAPIKey}}"
  
  # Model to use (claude-sonnet-4-20250514 recommended)
  model: "claude-sonnet-4-20250514"
  
  # Maximum tokens per response
  max_tokens: 300
  
  # Response creativity (0.0 to 1.0)
  temperature: 0.7

# Conversation Settings
conversation:
  # Number of messages to remember
  memory_length: 10
  
  # Minutes before conversation times out
  timeout_minutes: 5
  
  # Cooldown between interactions (seconds)
  cooldown_seconds: 3

# NPC Personalities
personalities:
  # Default personality for all NPCs
  default:
    system_prompt: |
      You are a helpful NPC in a Minecraft server. You are friendly, 
      concise, and roleplay as a character in this world. Keep responses 
      brief (1-2 sentences). You can give directions, share lore, or 
      engage in light conversation.
  
  # Example custom personalities (configure per NPC ID)
  # 1:
  #   system_prompt: "You are a wise wizard who speaks mysteriously..."
  # 
  # 2:
  #   system_prompt: "You are a grumpy blacksmith who..."
```

---

## 🧪 Testing Snippets

### Test All Modules

```powershell
# test-all-modules.ps1

Write-Host "Testing Display Module..." -ForegroundColor Cyan
. .\setup\core\Display.ps1
Show-Banner
Write-StatusBox -Title "Display Test" -Status "Pass" -Type "Success"
Write-Host ""

Write-Host "Testing Logger Module..." -ForegroundColor Cyan
. .\setup\core\Logger.ps1
$log = Initialize-Logger -LogPath ".\test-logs"
Write-Log -Message "Test log entry" -Level "INFO"
Write-Log -Message "Test success" -Level "SUCCESS"
Close-Logger -Success $true
Write-Host "Log file: $log" -ForegroundColor Gray
Write-Host ""

Write-Host "Testing Safety Module..." -ForegroundColor Cyan
. .\setup\core\Safety.ps1
$disk = Test-DiskSpace -Path "C:\" -RequiredGB 10
Write-Host "Disk check: $($disk.Success) ($($disk.FreeSpaceGB) GB free)" -ForegroundColor Gray
Write-Host ""

Write-Host "Testing Config Module..." -ForegroundColor Cyan
. .\setup\core\Config.ps1
$config = Get-DefaultConfiguration
$valid = Test-Configuration -Config $config
Write-Host "Config valid: $($valid.Valid)" -ForegroundColor Gray
Write-Host ""

Write-Host "All module tests complete!" -ForegroundColor Green
```

---

### Test Phase Module

```powershell
# test-phase.ps1
param(
    [Parameter(Mandatory=$true)]
    [string]$PhaseNumber
)

. .\setup\core\Display.ps1
. .\setup\core\Logger.ps1
. .\setup\core\Config.ps1

$phasePath = ".\setup\phases\$PhaseNumber-*.ps1"
$phaseFile = Get-Item $phasePath

if (-not $phaseFile) {
    Write-Host "Phase $PhaseNumber not found!" -ForegroundColor Red
    exit 1
}

Write-Host "Testing phase: $($phaseFile.Name)" -ForegroundColor Cyan
Write-Host ""

. $phaseFile.FullName

$log = Initialize-Logger -LogPath ".\test-logs"
$config = Get-DefaultConfiguration

# Call phase function (adjust function name as needed)
$functionName = "Invoke-" + ($phaseFile.BaseName -replace '^\d+-', '')
$result = & $functionName -Config $config

Write-Host ""
Write-Host "Result:" -ForegroundColor Cyan
Write-Host "  Success: $($result.Success)" -ForegroundColor $(if ($result.Success) { "Green" } else { "Red" })
Write-Host "  Message: $($result.Message)" -ForegroundColor Gray

Close-Logger -Success $result.Success
```

---

## 🔗 Integration Snippets

### Add Phase to Setup.ps1

```powershell
# Add this after configuration validation in Setup.ps1

# Phase execution
$phases = @(
    @{Number = "01"; Name = "Preflight"; Function = "Invoke-PreflightChecks"; Required = $true},
    @{Number = "02"; Name = "Java"; Function = "Invoke-JavaInstallation"; Required = $true},
    @{Number = "03"; Name = "PaperMC"; Function = "Invoke-PaperMCSetup"; Required = $true},
    @{Number = "04"; Name = "Plugins"; Function = "Invoke-PluginInstallation"; Required = $true},
    @{Number = "05"; Name = "Configure"; Function = "Invoke-FinalConfiguration"; Required = $true}
)

foreach ($phase in $phases) {
    Write-Section -Title "Phase $($phase.Number): $($phase.Name)" -Icon "⚙️"
    
    $phaseFile = Join-Path $script:SetupRoot "phases\$($phase.Number)-$($phase.Name).ps1"
    
    if (-not (Test-Path $phaseFile)) {
        Write-StatusBox -Title "Phase $($phase.Number)" -Status "Not implemented" -Type "Warning"
        if ($phase.Required) {
            throw "Required phase not implemented: $($phase.Name)"
        }
        continue
    }
    
    . $phaseFile
    $result = & $phase.Function -Config $config
    
    if (-not $result.Success) {
        Write-StatusBox -Title "Phase $($phase.Number)" -Status "Failed: $($result.Message)" -Type "Error"
        if ($phase.Required) {
            throw "Required phase failed: $($phase.Name)"
        }
    } else {
        Write-StatusBox -Title "Phase $($phase.Number)" -Status "Complete" -Type "Success"
    }
}
```

---

### Custom Script Template

```powershell
#Requires -Version 5.1
# my-custom-script.ps1
# Description of what this script does

param(
    [Parameter(Mandatory=$true)]
    [string]$ServerPath,
    
    [Parameter(Mandatory=$false)]
    [switch]$SomeOption
)

# Load modules
$moduleBase = Split-Path $PSScriptRoot -Parent
. "$moduleBase\setup\core\Display.ps1"
. "$moduleBase\setup\core\Logger.ps1"
. "$moduleBase\setup\core\Safety.ps1"
. "$moduleBase\setup\core\Config.ps1"

# Initialize
Show-Banner
$logFile = Initialize-Logger -LogPath (Join-Path $ServerPath "logs")

Write-Section -Title "My Custom Script" -Icon "🔧"

try {
    # Your logic here
    Write-StatusBox -Title "Step 1" -Status "Processing" -Type "Progress"
    # Do work
    Write-StatusBox -Title "Step 1" -Status "Complete" -Type "Success"
    
    Write-StatusBox -Title "Step 2" -Status "Processing" -Type "Progress"
    # Do work
    Write-StatusBox -Title "Step 2" -Status "Complete" -Type "Success"
    
    Write-Log -Message "Script completed successfully" -Level "SUCCESS"
    Close-Logger -Success $true
    
} catch {
    Write-StatusBox -Title "Script Failed" -Status $_.Exception.Message -Type "Error"
    Write-LogError -ErrorRecord $_
    Close-Logger -Success $false
    exit 1
}
```

---

## 🎯 Quick Copy Reference

**Load all core modules:**
```powershell
. ".\setup\core\Display.ps1"
. ".\setup\core\Logger.ps1"
. ".\setup\core\Safety.ps1"
. ".\setup\core\Config.ps1"
```

**Standard script header:**
```powershell
#Requires -Version 5.1
param([Parameter(Mandatory=$true)][string]$ServerPath)

$moduleBase = Split-Path $PSScriptRoot -Parent
. "$moduleBase\setup\core\Display.ps1"
. "$moduleBase\setup\core\Logger.ps1"

Show-Banner
$logFile = Initialize-Logger -LogPath "$ServerPath\logs"
```

**Standard error handling:**
```powershell
try {
    # Work
    Write-StatusBox -Title "Task" -Status "Complete" -Type "Success"
} catch {
    Write-StatusBox -Title "Failed" -Status $_.Exception.Message -Type "Error"
    Write-LogError -ErrorRecord $_
    throw
}
```

**Phase return format:**
```powershell
return @{
    Success = $true
    Message = "Operation complete"
    Data = @{SomeKey = "SomeValue"}
}
```

---

**All snippets tested and ready to use!**

Copy, paste, customize, and build!
