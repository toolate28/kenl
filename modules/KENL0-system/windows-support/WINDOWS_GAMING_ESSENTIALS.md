---
project: Bazza-DX SAGE Framework
status: active
version: 2025-11-07
classification: OWI-DOC
atom: ATOM-CFG-20251107-022
owi-version: 1.0.0
---

# Windows 11 Gaming Essentials - BF6 Optimized Setup

**Purpose:** Essential libraries, tools, and optimizations for Windows 11 gaming (BF6/BF2042 focus)

**ATOM Tag:** `ATOM-CFG-20251107-022`
**Target:** Windows 11 (dual-boot with Bazzite-DX)
**GPU:** AMD Radeon Renoir (your system)

---

## 1. Core Gaming Libraries (MUST INSTALL)

### DirectX Runtime

**Why:** Required for almost all games, including BF6

```powershell
# Download DirectX End-User Runtime Web Installer
# https://www.microsoft.com/en-us/download/details.aspx?id=35

# Run installer (will download components as needed)
.\dxwebsetup.exe
```

**Verification:**
```powershell
# Check DirectX version
dxdiag
# Should show DirectX 12 on System tab
```

---

### Visual C++ Redistributables (ALL VERSIONS)

**Why:** Games compiled with different Visual Studio versions need different runtimes

**Option A: AIO Repack (Recommended - Easiest)**

```powershell
# Download VCRedist AIO from TechPowerUp
# https://www.techpowerup.com/download/visual-c-redistributable-runtime-installer-all-in-one/

# OR abbodi1406's VCRedist (GitHub, more trusted)
# https://github.com/abbodi1406/vcredist/releases

# Install all versions at once
.\VisualCppRedist_AIO_x86_x64.exe
```

**Option B: Manual Install (Tedious but official)**

Download from Microsoft:
- VC++ 2005 (x86 + x64)
- VC++ 2008 (x86 + x64)
- VC++ 2010 (x86 + x64)
- VC++ 2012 (x86 + x64)
- VC++ 2013 (x86 + x64)
- VC++ 2015-2022 (x86 + x64) ← **Most important**

**Verification:**
```powershell
# Check installed versions
Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*Visual C++*" } | Select-Object Name, Version
```

---

### .NET Framework

**Why:** Some launchers (EA App, Epic) require it

```powershell
# .NET Framework 4.8 (last version before .NET Core)
# https://dotnet.microsoft.com/en-us/download/dotnet-framework/net48

# .NET 8.0 Runtime (for modern apps)
# https://dotnet.microsoft.com/en-us/download/dotnet/8.0
# Download "Desktop Runtime x64"
```

**Verification:**
```powershell
# Check .NET Framework versions
reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" /v Release
# Release value >= 528040 = .NET 4.8
```

---

## 2. GPU Drivers (CRITICAL)

### AMD Radeon Adrenalin Drivers (Your System)

```powershell
# Download latest from AMD
# https://www.amd.com/en/support

# For Ryzen 4000 Series (Renoir):
# Select: Processors → Ryzen 4000 Series → Your exact model

# OR auto-detect:
# https://www.amd.com/en/support/download/drivers.html
# Click "Auto-Detect and Install"
```

**Recommended Settings (AMD Radeon Software):**

```
Gaming Tab:
├─ Radeon Anti-Lag: ON (reduces input latency)
├─ Radeon Boost: ON (dynamic resolution scaling)
├─ Radeon Chill: OFF (for BF6 competitive play)
├─ Radeon Image Sharpening: 80% (optional)
└─ FreeSync: ON (if monitor supports it)

Display Tab:
├─ GPU Scaling: OFF (let monitor handle it)
├─ Integer Scaling: OFF
└─ Custom Resolutions: (leave default)

Performance Tab:
├─ Tuning Control: Manual (if you want to overclock)
├─ GPU Tuning: Leave at Auto (unless experienced)
└─ Fan Tuning: Auto
```

**Verification:**
```powershell
# Check driver version
Get-WmiObject Win32_VideoController | Select-Object Name, DriverVersion
```

---

## 3. Game Launchers

### Steam

```powershell
# Download: https://store.steampowered.com/about/
# Install to C:\Program Files (x86)\Steam (default)

# Post-install settings:
# Steam → Settings → Downloads
# - Download Region: Nearest location
# - Limit bandwidth: OFF (unless needed)
# - Shader Pre-Caching: ON
```

---

### EA App (Required for BF6/BF2042)

```powershell
# Download: https://www.ea.com/ea-app

# Post-install:
# Settings → Application
# - In-Game Overlay: OFF (reduces performance)
# - Auto-update games: ON
```

**EA App Game Install Location:**
```
Recommended: D:\ or E:\ (separate from C:\)
Settings → Downloads & Saves → Game Library Location
```

---

## 4. Performance Monitoring Tools (Optional but Recommended)

### MSI Afterburner + RivaTuner

**Why:** Best OSD (on-screen display) for monitoring FPS, temps, GPU usage

```powershell
# Download: https://www.msi.com/Landing/afterburner

# Setup:
# 1. Install MSI Afterburner
# 2. RivaTuner Statistics Server installs automatically
# 3. Configure OSD:
#    - GPU usage, temp
#    - CPU usage, temp
#    - RAM usage
#    - FPS
#    - Frametime
```

**Recommended OSD Settings:**
```
RivaTuner → Setup
├─ On-Screen Display → ON
├─ Show own statistics: ON
└─ Framerate limit: 0 (unlimited)

MSI Afterburner → Settings → Monitoring
├─ GPU temperature: ✓ Show in OSD
├─ GPU usage: ✓ Show in OSD
├─ CPU temperature: ✓ Show in OSD
├─ RAM usage: ✓ Show in OSD
└─ Framerate: ✓ Show in OSD
```

---

### HWiNFO64 (Advanced Monitoring)

**Why:** Detailed sensor data, logging for troubleshooting

```powershell
# Download: https://www.hwinfo.com/download/

# Run in Sensors-only mode
.\HWiNFO64.exe /SENSORS
```

---

## 5. Gaming Optimizations (Windows 11 Specific)

### Disable Windows Bloat

**Option A: Chris Titus Tech Utility (Automated)**

```powershell
# Open PowerShell as Administrator
irm christitus.com/win | iex

# In GUI:
# Tweaks Tab → Select "Gaming" preset → Run Tweaks
```

**Option B: Manual PowerShell Commands**

```powershell
# Open PowerShell as Administrator

# Disable Xbox Game Bar (causes stuttering)
Get-AppxPackage Microsoft.XboxGamingOverlay | Remove-AppxPackage
Get-AppxPackage Microsoft.XboxGameCallableUI | Remove-AppxPackage

# Disable Windows Search indexing (SSD only - saves CPU)
Stop-Service "WSearch"
Set-Service "WSearch" -StartupType Disabled

# Disable Superfetch/SysMain (for HDDs, keep ON for SSDs)
# If your main drive is HDD:
Stop-Service "SysMain"
Set-Service "SysMain" -StartupType Disabled

# Disable Windows Telemetry
Stop-Service "DiagTrack"
Set-Service "DiagTrack" -StartupType Disabled
Stop-Service "dmwappushservice"
Set-Service "dmwappushservice" -StartupType Disabled

# Disable hibernation (saves disk space)
powercfg /hibernate off
```

---

### Set High Performance Power Plan

```powershell
# List power plans
powercfg /list

# Set High Performance plan
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# OR create custom "Ultimate Performance" plan
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61
```

**AMD Ryzen Specific:**
```powershell
# Download AMD Ryzen Power Plan
# https://www.amd.com/en/support/chipsets/amd-socket-am4/x570

# Install chipset drivers (includes power plan)
```

---

### Visual Effects for Best Performance

```powershell
# Open System Properties Performance Options
SystemPropertiesPerformance.exe

# Select "Adjust for best performance"
# OR Custom with only these checked:
# - Show thumbnails instead of icons
# - Smooth edges of screen fonts
```

---

### Disable Game DVR / Game Mode

```powershell
# Disable Game DVR (causes microstutters)
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f

# Disable Game Mode (contradictory name, can cause issues)
reg add "HKCU\Software\Microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 0 /f
```

**Verification:**
```powershell
# Check Game DVR status
reg query "HKCU\System\GameConfigStore" /v GameDVR_Enabled
# Should return 0x0
```

---

### Network Optimizations (Low Latency)

```powershell
# Disable Nagle's Algorithm (reduces TCP latency)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{YOUR-INTERFACE-GUID}" /v TcpAckFrequency /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{YOUR-INTERFACE-GUID}" /v TCPNoDelay /t REG_DWORD /d 1 /f

# Easier method: Use TCP Optimizer
# Download: https://www.speedguide.net/downloads.php
# Select "Optimal" preset → Apply
```

---

### Windows Update Settings (Keep Drivers Updated)

```powershell
# Don't disable Windows Update entirely (security risk)
# But pause for up to 5 weeks:

# Settings → Windows Update → Pause updates
# Select 5 weeks

# OR via PowerShell:
$WU = New-Object -ComObject Microsoft.Update.AutoUpdate
$WU.Settings.NotificationLevel = 2  # Notify before download
```

---

## 6. BF6-Specific Optimizations

### EA App Settings

```
Settings → Application:
├─ In-Game Overlay: OFF
├─ Origin In-Game: OFF
├─ Background Downloads: OFF (while gaming)
└─ Auto-update: ON (outside gaming hours)
```

---

### BF6 In-Game Settings (Predicted - Adjust as Needed)

**Graphics:**
```
Resolution: Native (your monitor's max)
Refresh Rate: Maximum supported
Display Mode: Fullscreen (not borderless)
V-Sync: OFF (use FreeSync/G-Sync instead)
Future Frame Rendering: ON
Field of View: 90-100° (preference)

Quality Presets: Start with "High", adjust individual:
├─ Texture Quality: Ultra
├─ Mesh Quality: High
├─ Terrain Quality: Medium
├─ Effects Quality: Medium
├─ Post-Process Quality: Low (visibility)
├─ Shadows: Low (performance)
├─ Ambient Occlusion: OFF
└─ Anti-Aliasing: TAA or OFF (preference)
```

**Advanced:**
```
DirectX Version: DirectX 12
Ray Tracing: OFF (unless RTX GPU)
DLSS/FSR: Use if available (AMD = FSR)
```

---

### Windows Game Bar Shortcuts (If Enabled)

```
Win+G: Open Game Bar
Win+Alt+R: Start/stop recording
Win+Alt+PrintScreen: Screenshot
Win+Alt+M: Mute/unmute mic
```

**Recommendation:** Keep Game Bar DISABLED for best performance.

---

## 7. Essential Utilities

### 7-Zip (File Compression)

```powershell
# Download: https://www.7-zip.org/
# Winget install:
winget install 7zip.7zip
```

---

### Notepad++ (Better Text Editor)

```powershell
# Download: https://notepad-plus-plus.org/
# Winget install:
winget install Notepad++.Notepad++
```

---

### Process Lasso (CPU Optimization)

**Why:** Prevents background processes from stealing CPU during gaming

```powershell
# Download: https://bitsum.com/

# Setup:
# 1. Enable ProBalance algorithm
# 2. Add BF6 executable to "Always boost" list
# 3. Set CPU affinity optimization
```

---

### LatencyMon (Diagnose DPC Latency)

**Why:** Identifies drivers causing microstutters

```powershell
# Download: https://www.resplendence.com/latencymon

# Run for 5 minutes while gaming
# Check "Drivers" tab for high latency culprits
```

---

## 8. Security (Don't Disable Entirely)

### Windows Defender (Keep ON)

**Why:** BF6's Javelin anti-cheat may conflict if you disable Defender

```powershell
# Add game exclusions (reduces scanning overhead)
Add-MpPreference -ExclusionPath "C:\Program Files\EA Games\Battlefield 6"
Add-MpPreference -ExclusionPath "D:\SteamLibrary"  # Your game library

# Disable real-time scanning ONLY during gaming (manual toggle)
Set-MpPreference -DisableRealtimeMonitoring $true
# Re-enable after gaming:
Set-MpPreference -DisableRealtimeMonitoring $false
```

---

## 9. Automated Setup Script

**Save as:** `gaming-setup.ps1`

```powershell
# Run as Administrator
#Requires -RunAsAdministrator

Write-Host "=== Windows 11 Gaming Setup ===" -ForegroundColor Cyan

# 1. Install Chocolatey package manager
Write-Host "Installing Chocolatey..." -ForegroundColor Yellow
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# 2. Install essential software
Write-Host "Installing gaming essentials..." -ForegroundColor Yellow
choco install -y `
  steam `
  7zip `
  notepadplusplus `
  msiafterburner `
  hwinfo

# 3. Download VCRedist AIO
Write-Host "Download Visual C++ Redistributables from:" -ForegroundColor Yellow
Write-Host "https://github.com/abbodi1406/vcredist/releases" -ForegroundColor White

# 4. Optimize Windows
Write-Host "Applying gaming optimizations..." -ForegroundColor Yellow

# Disable Xbox Game Bar
Get-AppxPackage Microsoft.XboxGamingOverlay | Remove-AppxPackage -ErrorAction SilentlyContinue

# Disable telemetry
Stop-Service DiagTrack -ErrorAction SilentlyContinue
Set-Service DiagTrack -StartupType Disabled -ErrorAction SilentlyContinue

# Disable Game DVR
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f

# Set High Performance power plan
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# Disable hibernation
powercfg /hibernate off

Write-Host "=== Setup Complete! ===" -ForegroundColor Green
Write-Host "Manual steps remaining:" -ForegroundColor Yellow
Write-Host "1. Install AMD Radeon drivers from https://www.amd.com/en/support" -ForegroundColor White
Write-Host "2. Install DirectX from https://www.microsoft.com/download/details.aspx?id=35" -ForegroundColor White
Write-Host "3. Install Visual C++ Redistributables (link shown above)" -ForegroundColor White
Write-Host "4. Install EA App from https://www.ea.com/ea-app" -ForegroundColor White
Write-Host "5. Reboot system" -ForegroundColor White
```

**Usage:**
```powershell
# Save script, then:
Set-ExecutionPolicy Bypass -Scope Process -Force
.\gaming-setup.ps1
```

---

## 10. Verification Checklist

After setup, verify:

- [ ] DirectX 12 installed (`dxdiag` shows DX12)
- [ ] AMD Radeon drivers installed (check Device Manager)
- [ ] All Visual C++ versions installed (see installed programs)
- [ ] .NET Framework 4.8 installed
- [ ] Steam installed and signed in
- [ ] EA App installed and signed in
- [ ] MSI Afterburner OSD working
- [ ] Game DVR disabled (check registry)
- [ ] High Performance power plan active (`powercfg /list`)
- [ ] Windows Defender exclusions added for game folders

---

## 11. Pre-BF6 Launch Checklist

Before launching BF6:

```powershell
# 1. Close background apps
taskkill /F /IM Discord.exe
taskkill /F /IM chrome.exe
# etc.

# 2. Check GPU driver version
Get-WmiObject Win32_VideoController | Select Name,DriverVersion

# 3. Verify game files (in EA App)
# Right-click BF6 → Repair

# 4. Enable MSI Afterburner OSD
# Start MSI Afterburner

# 5. Check temperatures before launch
# HWiNFO64 sensors mode
```

---

## 12. Troubleshooting

### BF6 won't launch

1. Verify DirectX: `dxdiag`
2. Verify VC++ installed: Check Programs
3. Update GPU drivers
4. Verify game files in EA App
5. Check Windows Event Viewer for errors

### Low FPS

1. Check MSI Afterburner: GPU usage should be 95-100%
2. If CPU usage is 100%: Close background apps
3. Lower in-game settings (Shadows, Effects)
4. Enable FSR (AMD upscaling)

### Stuttering

1. Disable Game DVR (see script above)
2. Close Chrome/Discord
3. Run LatencyMon to find problematic drivers
4. Disable Windows Search indexing
5. Check CPU temperature (shouldn't exceed 85°C)

---

## ATOM Traceability

**Document:** `WINDOWS_GAMING_ESSENTIALS.md`
**ATOM Tag:** `ATOM-CFG-20251107-022`
**Related:**
- `ATOM-CFG-20251107-021` - Dual-boot setup
- `ATOM-DOC-20251107-020` - BF6 Linux launch options

**Software Inventory:**
- DirectX End-User Runtime
- Visual C++ Redistributables (2005-2022)
- .NET Framework 4.8
- AMD Radeon Adrenalin (latest)
- Steam, EA App
- MSI Afterburner, RivaTuner, HWiNFO64
- 7-Zip, Notepad++

---

**Last Updated:** 2025-11-07
**ATOM-CFG-20251107-022**
