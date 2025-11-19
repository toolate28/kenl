#Requires -Version 5.1
<#
.SYNOPSIS
    KENL Gaming Module - Gaming optimization and play cards

.DESCRIPTION
    Module for creating and managing gaming play cards, hardware profiles,
    and gaming-specific optimizations.

.NOTES
    Author    : KENL Framework
    Version   : 1.0.0
    ATOM      : ATOM-GAMING-20251110-001
#>

#region Play Cards

function New-KenlPlayCard {
    <#
    .SYNOPSIS
        Creates a new gaming play card

    .DESCRIPTION
        Generates a YAML play card for gaming sessions with network and system optimizations

    .PARAMETER GameName
        Name of the game

    .PARAMETER Platform
        Gaming platform (Steam, Epic, Origin, etc.)

    .PARAMETER PriorityHosts
        Array of IP addresses to prioritize

    .PARAMETER BandwidthMbps
        Expected bandwidth in Mbps

    .PARAMETER LatencyMs
        Target latency in ms

    .EXAMPLE
        New-KenlPlayCard -GameName "Battlefield 2042" -Platform "Origin"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$GameName,

        [string]$Platform = "Steam",

        [string[]]$PriorityHosts = @(),

        [int]$BandwidthMbps = 100,

        [int]$LatencyMs = 40
    )

    $playCard = [PSCustomObject]@{
        name = $GameName
        platform = $Platform
        created = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
        atom = "ATOM-PLAYCARD-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

        network = @{
            bandwidth_mbps = $BandwidthMbps
            latency_ms = $LatencyMs
            priority_hosts = $PriorityHosts
            mtu = 1492
            tcp_congestion = "bbr"
        }

        gaming = @{
            launch_options = ""
            priority = "high"
            affinity = "auto"
        }

        system = @{
            disable_services = @()
            optimize_power = $true
        }
    }

    # Auto-detect priority hosts if not provided
    if ($PriorityHosts.Count -eq 0) {
        $playCard.network.priority_hosts = Get-KenlPriorityHosts -GameName $GameName
    }

    # Auto-detect launch options
    $detectedLaunchOptions = Get-KenlLaunchOptions -GameName $GameName -Platform $Platform
    if ($detectedLaunchOptions) {
        $playCard.gaming.launch_options = $detectedLaunchOptions
    }

    Write-KenlMessage "Created play card for $GameName" -Type Success

    # Log to ATOM trail
    if (Get-Command Write-AtomTrail -ErrorAction SilentlyContinue) {
        Write-AtomTrail -Type GAMING -Action "Created play card for $GameName ($Platform)"
    }

    return $playCard
}

function Get-KenlPlayCard {
    <#
    .SYNOPSIS
        Retrieves gaming play cards

    .PARAMETER Name
        Name of specific play card

    .PARAMETER Path
        Path to play card file

    .PARAMETER AutoDetect
        Auto-detect and create missing playcards

    .EXAMPLE
        Get-KenlPlayCard
        Get-KenlPlayCard -Name "Battlefield" -AutoDetect
    #>
    [CmdletBinding()]
    param(
        [string]$Name,

        [string]$Path = "$env:USERPROFILE\.kenl\playcards",

        [switch]$AutoDetect
    )

    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }

    $cards = Get-ChildItem $Path -Filter "*.yaml" -ErrorAction SilentlyContinue | ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        try {
            $yaml = ConvertFrom-Yaml $content
            $yaml | Add-Member -MemberType NoteProperty -Name "FilePath" -Value $_.FullName -PassThru
        } catch {
            Write-KenlMessage "Invalid playcard: $($_.Name)" -Type Warning
        }
    }

    # Auto-detect if requested and no cards found
    if ($AutoDetect -and (-not $cards -or $cards.Count -eq 0)) {
        Write-KenlMessage "No playcards found, auto-detecting games..." -Type Info
        $detectedGames = Find-KenlInstalledGames
        foreach ($game in $detectedGames) {
            $card = New-KenlPlayCard -GameName $game.Name -Platform $game.Platform -PriorityHosts $game.PriorityHosts
            Export-KenlPlayCard -PlayCard $card -Path (Join-Path $Path "$($game.Name -replace '[^a-zA-Z0-9]', '').yaml")
            Write-KenlMessage "Created playcard for $($game.Name)" -Type Success
        }
        # Re-scan after creation
        $cards = Get-ChildItem $Path -Filter "*.yaml" | ForEach-Object {
            $content = Get-Content $_.FullName -Raw
            $yaml = ConvertFrom-Yaml $content
            $yaml | Add-Member -MemberType NoteProperty -Name "FilePath" -Value $_.FullName -PassThru
        }
    }

    if ($Name) {
        $cards | Where-Object { $_.name -like "*$Name*" }
    } else {
        $cards
    }
}

function Edit-KenlPlayCard {
    <#
    .SYNOPSIS
        Edits an existing play card

    .PARAMETER Name
        Name of play card to edit

    .PARAMETER Property
        Property to update

    .PARAMETER Value
        New value

    .EXAMPLE
        Edit-KenlPlayCard -Name "Halo" -Property "network.bandwidth_mbps" -Value 200
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Property,

        [Parameter(Mandatory)]
        $Value,

        [string]$Path = "$env:USERPROFILE\.kenl\playcards"
    )

    $cardPath = Join-Path $Path "$Name.yaml"
    if (-not (Test-Path $cardPath)) {
        Write-KenlMessage "Play card not found: $Name" -Type Error
        return
    }

    $card = Get-Content $cardPath -Raw | ConvertFrom-Yaml

    # Update property using dot notation
    $propertyPath = $Property -split '\.'
    $current = $card
    for ($i = 0; $i -lt $propertyPath.Length - 1; $i++) {
        $current = $current.($propertyPath[$i])
    }
    $current.($propertyPath[-1]) = $Value

    $card | ConvertTo-Yaml | Out-File $cardPath -Encoding UTF8
    Write-KenlMessage "Updated $Property in play card $Name" -Type Success

function Export-KenlPlayCard {
    <#
    .SYNOPSIS
        Exports play card to file

    .PARAMETER PlayCard
        Play card object to export

    .PARAMETER Path
        Export path

    .EXAMPLE
        $card = New-KenlPlayCard -GameName "Halo"
        Export-KenlPlayCard -PlayCard $card -Path "halo.yaml"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSCustomObject]$PlayCard,

        [string]$Path = "$($PlayCard.name).yaml"
    )

    $yaml = ConvertTo-Yaml $PlayCard
    $yaml | Out-File $Path -Encoding UTF8

    Write-KenlMessage "Exported play card to $Path" -Type Success

    # Log to ATOM trail
    if (Get-Command Write-AtomTrail -ErrorAction SilentlyContinue) {
        Write-AtomTrail -Type GAMING -Action "Exported play card $($PlayCard.name) to $Path"
    }
}

#endregion

#region Hardware Profiles

function Get-KenlHardwareProfile {
    <#
    .SYNOPSIS
        Detects and creates hardware profile with peripherals and gamemode

    .EXAMPLE
        Get-KenlHardwareProfile
    #>
    [CmdletBinding()]
    param()

    $profile = [PSCustomObject]@{
        cpu = Get-CimInstance Win32_Processor | Select-Object -First 1 | ForEach-Object {
            @{
                name = $_.Name
                cores = $_.NumberOfCores
                threads = $_.NumberOfLogicalProcessors
                speed_mhz = $_.MaxClockSpeed
            }
        }

        gpu = Get-CimInstance Win32_VideoController | Where-Object { $_.AdapterRAM } | Select-Object -First 1 | ForEach-Object {
            @{
                name = $_.Name
                memory_mb = [math]::Round($_.AdapterRAM / 1MB)
                driver_version = $_.DriverVersion
            }
        }

        memory = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum | ForEach-Object {
            @{
                total_gb = [math]::Round($_.Sum / 1GB)
                slots = (Get-CimInstance Win32_PhysicalMemory).Count
            }
        }

        storage = Get-CimInstance Win32_DiskDrive | ForEach-Object {
            @{
                model = $_.Model
                size_gb = [math]::Round($_.Size / 1GB)
                type = if ($_.MediaType -match "SSD") { "SSD" } else { "HDD" }
            }
        }

        network = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | ForEach-Object {
            @{
                name = $_.Name
                speed_mbps = [math]::Round($_.Speed / 1MB)
                type = $_.PhysicalMediaType
            }
        }

        peripherals = @{
            controllers = Get-PnpDevice | Where-Object { $_.Class -eq "HIDClass" -and $_.Name -match "(Xbox|PlayStation|Controller)" } | ForEach-Object {
                @{
                    name = $_.Name
                    status = $_.Status
                }
            }
            monitors = Get-CimInstance Win32_DesktopMonitor | ForEach-Object {
                @{
                    name = $_.Name
                    resolution = "$($_.ScreenWidth)x$($_.ScreenHeight)"
                    refresh_rate = $_.MaxRefreshRate
                }
            }
            audio = Get-CimInstance Win32_SoundDevice | Where-Object { $_.Status -eq "OK" } | ForEach-Object {
                @{
                    name = $_.Name
                    manufacturer = $_.Manufacturer
                }
            }
        }

        gamemode = @{
            enabled = $false
            features = @()
        }
    }

    # Check for Game Mode (Windows 10+)
    try {
        $gameModeReg = Get-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -ErrorAction SilentlyContinue
        if ($gameModeReg.AllowAutoGameMode -eq 1) {
            $profile.gamemode.enabled = $true
            $profile.gamemode.features += "Auto Game Mode"
        }

        # Check for Game DVR
        $gameDvrReg = Get-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -ErrorAction SilentlyContinue
        if ($gameDvrReg.GameDVR_Enabled -eq 0) {
            $profile.gamemode.features += "Game DVR Disabled"
        }
    } catch {
        # Game Mode not available or registry access failed
    }

    # Check for NVIDIA GeForce Experience Game Mode
    $nvidiaPath = "${env:ProgramFiles}\NVIDIA Corporation\NVIDIA GeForce Experience"
    if (Test-Path $nvidiaPath) {
        $profile.gamemode.features += "NVIDIA GeForce Experience"
    }

    # Check for AMD Radeon Software Game Mode
    $amdPath = "${env:ProgramFiles}\AMD\CNext\CNext"
    if (Test-Path $amdPath) {
        $profile.gamemode.features += "AMD Radeon Software"
    }

    Write-KenlMessage "Hardware profile detected with peripherals and gamemode settings" -Type Success
    return $profile
}

function Test-KenlHardware {
    <#
    .SYNOPSIS
        Validates hardware configuration

    .EXAMPLE
        Test-KenlHardware
    #>
    [CmdletBinding()]
    param()

    $profile = Get-KenlHardwareProfile
    $issues = @()

    # Check CPU
    if ($profile.cpu.threads -lt 4) {
        $issues += "Low CPU threads: $($profile.cpu.threads) (recommended: 8+)"
    }

    # Check GPU memory
    if ($profile.gpu.memory_mb -lt 4096) {
        $issues += "Low GPU memory: $($profile.gpu.memory_mb)MB (recommended: 8GB+)"
    }

    # Check memory
    if ($profile.memory.total_gb -lt 16) {
        $issues += "Low system memory: $($profile.memory.total_gb)GB (recommended: 32GB+)"
    }

    if ($issues.Count -eq 0) {
        Write-KenlMessage "Hardware validation passed" -Type Success
    } else {
        Write-KenlMessage "Hardware issues found:" -Type Warning
        $issues | ForEach-Object { Write-KenlMessage "  $_" -Type Warning }
    }

    return $issues
}

function Export-KenlHardwareProfile {
    <#
    .SYNOPSIS
        Exports hardware profile to YAML

    .PARAMETER Path
        Export path

    .EXAMPLE
        Export-KenlHardwareProfile -Path "hardware.yaml"
    #>
    [CmdletBinding()]
    param(
        [string]$Path = "hardware-profile.yaml"
    )

    $profile = Get-KenlHardwareProfile
    $yaml = ConvertTo-Yaml $profile
    $yaml | Out-File $Path -Encoding UTF8

    Write-KenlMessage "Hardware profile exported to $Path" -Type Success
}

#endregion

#region Gaming Optimization

function Optimize-KenlGaming {
    <#
    .SYNOPSIS
        Applies gaming optimizations

    .PARAMETER GameName
        Specific game to optimize for

    .EXAMPLE
        Optimize-KenlGaming
        Optimize-KenlGaming -GameName "Battlefield"
    #>
    [CmdletBinding()]
    param(
        [string]$GameName
    )

    # Check for administrator privileges
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-KenlMessage "Gaming optimizations require administrator privileges. Please run as administrator." -Type Error
        return
    }

    Write-KenlMessage "Applying gaming optimizations..." -Type Info

    # Disable unnecessary services
    $servicesToDisable = @(
        "SysMain",      # Superfetch
        "WSearch",      # Windows Search
        "Spooler"       # Print Spooler
    )

    foreach ($service in $servicesToDisable) {
        try {
            Stop-Service $service -ErrorAction SilentlyContinue
            Set-Service $service -StartupType Disabled -ErrorAction SilentlyContinue
            Write-KenlMessage "Disabled service: $service" -Type Success
        } catch {
            Write-KenlMessage "Could not disable $service" -Type Warning
        }
    }

    # Set power plan to high performance
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

    Write-KenlMessage "Gaming optimizations applied" -Type Success

    # Log to ATOM trail
    if (Get-Command Write-AtomTrail -ErrorAction SilentlyContinue) {
        Write-AtomTrail -Type GAMING -Action "Gaming optimizations applied: services disabled, power plan set to high performance"
    }
}

function Get-KenlGamingStatus {
    <#
    .SYNOPSIS
        Shows current gaming configuration status

    .EXAMPLE
        Get-KenlGamingStatus
    #>
    [CmdletBinding()]
    param()

    $status = [PSCustomObject]@{
        power_plan = (powercfg /getactivescheme).Split()[-1]
        services_disabled = @()
        network_optimized = $false
    }

    # Check disabled services
    $services = @("SysMain", "WSearch", "Spooler")
    foreach ($service in $services) {
        $svc = Get-Service $service -ErrorAction SilentlyContinue
        if ($svc -and $svc.StartType -eq "Disabled") {
            $status.services_disabled += $service
        }
    }

    # Check network optimization (simplified)
    $mtu = Get-KenlMTU | Where-Object { $_.MTU -eq 1492 }
    if ($mtu) {
        $status.network_optimized = $true
    }

    return $status
}

#endregion

#region Helper Functions

function Find-KenlInstalledGames {
    <#
    .SYNOPSIS
        Auto-detects installed games

    .EXAMPLE
        Find-KenlInstalledGames
    #>
    [CmdletBinding()]
    param()

    $detectedGames = @()

    # Steam games
    $steamPath = "${env:ProgramFiles(x86)}\Steam"
    if (Test-Path $steamPath) {
        $libraryFolders = Get-Content (Join-Path $steamPath "steamapps\libraryfolders.vdf") -ErrorAction SilentlyContinue
        if ($libraryFolders) {
            $paths = $libraryFolders | Select-String '"path"\s+"([^"]+)"' | ForEach-Object { $_.Matches.Groups[1].Value }
            foreach ($path in $paths) {
                $steamApps = Join-Path $path "steamapps"
                if (Test-Path $steamApps) {
                    $acfFiles = Get-ChildItem $steamApps -Filter "appmanifest_*.acf"
                    foreach ($acf in $acfFiles) {
                        $content = Get-Content $acf.FullName -Raw
                        $name = ($content | Select-String '"name"\s+"([^"]+)"').Matches.Groups[1].Value
                        $appid = ($content | Select-String '"appid"\s+"([^"]+)"').Matches.Groups[1].Value

                        $detectedGames += [PSCustomObject]@{
                            Name = $name
                            Platform = "Steam"
                            AppId = $appid
                            PriorityHosts = Get-KenlPriorityHosts -GameName $name
                        }
                    }
                }
            }
        }
    }

    # Epic Games
    $epicPath = "${env:ProgramFiles(x86)}\Epic Games"
    if (Test-Path $epicPath) {
        # Basic detection - could be enhanced
        $detectedGames += [PSCustomObject]@{
            Name = "Epic Games Store"
            Platform = "Epic"
            PriorityHosts = @()
        }
    }

    # Origin/EA
    $originPath = "${env:ProgramFiles(x86)}\Origin"
    if (Test-Path $originPath) {
        $detectedGames += [PSCustomObject]@{
            Name = "EA Origin"
            Platform = "Origin"
            PriorityHosts = @("159.153.71.17")
        }
    }

    # Battle.net
    $battleNetPath = "${env:ProgramFiles(x86)}\Battle.net"
    if (Test-Path $battleNetPath) {
        $detectedGames += [PSCustomObject]@{
            Name = "Battle.net"
            Platform = "Battle.net"
            PriorityHosts = @("24.105.29.0/24")
        }
    }

    # Ubisoft Connect
    $ubisoftPath = "${env:ProgramFiles(x86)}\Ubisoft\Ubisoft Game Launcher"
    if (Test-Path $ubisoftPath) {
        $detectedGames += [PSCustomObject]@{
            Name = "Ubisoft Connect"
            Platform = "Ubisoft"
            PriorityHosts = @()
        }
    }

    # Log to ATOM trail
    if (Get-Command Write-AtomTrail -ErrorAction SilentlyContinue) {
        Write-AtomTrail -Type GAMING -Action "Auto-detected $($detectedGames.Count) installed games/platforms"
    }

    return $detectedGames
}

function Get-KenlLaunchOptions {
    <#
    .SYNOPSIS
        Detects launch options for games

    .PARAMETER GameName
        Name of the game

    .PARAMETER Platform
        Gaming platform

    .EXAMPLE
        Get-KenlLaunchOptions -GameName "Battlefield 2042" -Platform "Origin"
    #>
    [CmdletBinding()]
    param(
        [string]$GameName,
        [string]$Platform = "Steam"
    )

    $launchOptions = ""

    switch ($Platform.ToLower()) {
        "steam" {
            # Try to find Steam launch options in config files
            $steamPath = "${env:ProgramFiles(x86)}\Steam\userdata"
            if (Test-Path $steamPath) {
                $userDirs = Get-ChildItem $steamPath -Directory
                foreach ($userDir in $userDirs) {
                    $configPath = Join-Path $userDir.FullName "config\localconfig.vdf"
                    if (Test-Path $configPath) {
                        $content = Get-Content $configPath -Raw
                        # Look for launch options in the config
                        $pattern = "`"LaunchOptions`"\s*`"(.*?)`""
                        $matches = [regex]::Matches($content, $pattern)
                        if ($matches.Count -gt 0) {
                            $launchOptions = $matches[0].Groups[1].Value
                            break
                        }
                    }
                }
            }
        }
        "epic" {
            # Epic Games doesn't typically expose launch options easily
            $launchOptions = ""
        }
        "origin" {
            # EA Origin launch options
            $originPath = "${env:ProgramFiles(x86)}\Origin\Origin.exe"
            if (Test-Path $originPath) {
                # Common Origin launch options for performance
                $launchOptions = "-Origin_NoAppFocus"
            }
        }
        "battle.net" {
            # Battle.net games often have specific launch options
            $battleNetPath = "${env:ProgramFiles(x86)}\Battle.net\Battle.net.exe"
            if (Test-Path $battleNetPath) {
                # Common Battle.net launch options
                $launchOptions = ""
            }
        }
    }

    # Game-specific launch options
    switch -Wildcard ($GameName.ToLower()) {
        "*battlefield*" {
            $launchOptions += " +clientport 3659 +maxMem=8192 +maxVram=8192"
        }
        "*call of duty*" {
            $launchOptions += " -map=mp_dome -maxMem=16384"
        }
        "*halo*" {
            $launchOptions += " -windowed -novsync"
        }
        "*apex legends*" {
            $launchOptions += " -preload +fps_max unlimited +cl_showfps 1"
        }
        "*valorant*" {
            $launchOptions += " -allowthirdpartydlcs"
        }
    }

    return $launchOptions.Trim()
}

function Get-KenlPriorityHosts {
    <#
    .SYNOPSIS
        Gets priority hosts for a game

    .PARAMETER GameName
        Name of the game

    .EXAMPLE
        Get-KenlPriorityHosts -GameName "Battlefield"
    #>
    [CmdletBinding()]
    param(
        [string]$GameName
    )

    # Game-specific host mappings
    $gameHosts = @{
        "Battlefield" = @("104.68.26.184", "159.153.64.0/20")
        "Call of Duty" = @("23.61.207.0/24", "104.64.0.0/16")
        "Halo" = @("104.74.42.104", "8.8.8.8")
        "Steam" = @("104.74.42.104", "23.46.33.251")
        "EA" = @("159.153.71.17", "159.153.0.0/16")
    }

    $key = $gameHosts.Keys | Where-Object { $GameName -like "*$_*" } | Select-Object -First 1
    if ($key) {
        return $gameHosts[$key]
    }

    # Default gaming hosts
    return @("199.60.103.31", "23.46.33.251", "18.67.110.92")
}

#endregion

#region Export

# Export-ModuleMember -Function @(
#     'New-KenlPlayCard',
#     'Get-KenlPlayCard',
#     'Edit-KenlPlayCard',
#     'Export-KenlPlayCard',
#     'Get-KenlHardwareProfile',
#     'Test-KenlHardware',
#     'Export-KenlHardwareProfile',
#     'Optimize-KenlGaming',
#     'Get-KenlGamingStatus',
#     'Find-KenlInstalledGames',
#     'Get-KenlLaunchOptions',
#     'Get-KenlPriorityHosts'
# ) -Alias @(
#     'kcard-new',
#     'kcard-get',
#     'kcard-edit',
#     'khw-profile',
#     'khw-test',
#     'kgame-opt',
#     'kgame-status'
# )

#endregion

Write-Host "KENL.Gaming module loaded" -ForegroundColor Cyan
Write-Host "Quick start: New-KenlPlayCard -GameName 'YourGame'" -ForegroundColor Gray