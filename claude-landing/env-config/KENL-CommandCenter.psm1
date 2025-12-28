<#
.SYNOPSIS
    KENL Command Center - Persistent, Context-Aware Development Dashboard
.DESCRIPTION
    Bold, elegant real-time dashboard that adapts to your context.
    No boring static banners - this is a living command center.
.NOTES
    Designed for developers who demand excellence.
#>

# ============================================
# Core State Management
# ============================================

$script:CommandCenterState = @{
    Enabled = $true
    LastUpdate = Get-Date
    RefreshInterval = 5  # seconds
    ServiceCache = @{}
    NetworkCache = @{}
    GitCache = @{}
    ContextMode = 'Auto'  # Auto, Full, Minimal, Silent
}

# ============================================
# Visual Design System
# ============================================

$script:Glyphs = @{
    # Status Indicators
    Active = '●'
    Inactive = '○'
    Warning = '▲'
    Error = '✗'
    Success = '✓'
    Info = 'ℹ'

    # Connections
    Corner = '╭'
    CornerEnd = '╰'
    Line = '─'
    Vertical = '│'
    Branch = '├'

    # Services
    Server = '⚡'
    Dashboard = '📊'
    Network = '🌐'
    Git = '⎇'
    Clock = '⏱'
    CPU = '⚙'
}

$script:ColorScheme = @{
    Primary = 'Cyan'
    Success = 'Green'
    Warning = 'Yellow'
    Error = 'Red'
    Muted = 'DarkGray'
    Accent = 'Magenta'
    Highlight = 'White'
}

# ============================================
# Context Detection
# ============================================

function Get-CurrentContext {
    $location = Get-Location
    $context = @{
        Type = 'General'
        Icon = '💻'
        Name = 'Terminal'
        QuickActions = @()
    }

    switch -Regex ($location.Path) {
        'claudenpc-server-suite' {
            $context.Type = 'ClaudeNPC'
            $context.Icon = '🎮'
            $context.Name = 'ClaudeNPC Dev'
            $context.QuickActions = @(
                @{ Key = 'phase2'; Cmd = 'cat PHASE_2_ROADMAP.md | less'; Desc = 'View Phase 2 Roadmap' }
                @{ Key = 'test'; Cmd = './test-core-modules.ps1'; Desc = 'Test Core Modules' }
            )
        }
        'claude-bun-win11-hooks' {
            $context.Type = 'BunHooks'
            $context.Icon = '🔗'
            $context.Name = 'Claude Hooks'
            $context.QuickActions = @(
                @{ Key = 'dash'; Cmd = 'bun run viewer'; Desc = 'Start Dashboard' }
                @{ Key = 'test'; Cmd = 'bun run test'; Desc = 'Run Tests' }
                @{ Key = 'logs'; Cmd = 'cat .claude/hooks/hooks-log.txt | tail -50'; Desc = 'View Logs' }
            )
        }
        'modules.*powershell' {
            $context.Type = 'KENLModules'
            $context.Icon = '⚡'
            $context.Name = 'KENL Modules'
            $context.QuickActions = @(
                @{ Key = 'test'; Cmd = 'Test-KenlNetwork'; Desc = 'Network Diagnostics' }
                @{ Key = 'platform'; Cmd = 'Get-KenlPlatform'; Desc = 'Platform Info' }
            )
        }
        '.kenl.*claude-landing' {
            $context.Type = 'Root'
            $context.Icon = '🏠'
            $context.Name = 'KENL Landing'
            $context.QuickActions = @(
                @{ Key = 'status'; Cmd = 'git status --short'; Desc = 'Git Status' }
                @{ Key = 'docs'; Cmd = 'cat 00_START_HERE.md'; Desc = 'Documentation' }
            )
        }
    }

    return $context
}

# ============================================
# Real-Time Service Monitoring
# ============================================

function Get-ServiceHealth {
    param(
        [switch]$UseCache
    )

    if ($UseCache -and $script:CommandCenterState.ServiceCache.Count -gt 0) {
        $age = (Get-Date) - $script:CommandCenterState.LastUpdate
        if ($age.TotalSeconds -lt $script:CommandCenterState.RefreshInterval) {
            return $script:CommandCenterState.ServiceCache
        }
    }

    $services = @{
        ClaudeDashboard = @{
            Name = 'Claude Dashboard'
            Port = 3456
            Status = 'Unknown'
            Glyph = $script:Glyphs.Dashboard
        }
        LogdyCentral = @{
            Name = 'Logdy Central'
            Port = 8081
            Status = 'Unknown'
            Glyph = $script:Glyphs.Server
        }
        MinecraftServer = @{
            Name = 'Minecraft Server'
            Port = 25565
            Status = 'Unknown'
            Glyph = '🎮'
        }
    }

    # Check each service
    $connections = netstat -ano | Select-String "LISTENING"
    foreach ($key in $services.Keys) {
        $port = $services[$key].Port
        $listening = $connections | Select-String ":$port "
        $services[$key].Status = if ($listening) { 'Active' } else { 'Inactive' }
    }

    $script:CommandCenterState.ServiceCache = $services
    $script:CommandCenterState.LastUpdate = Get-Date

    return $services
}

# ============================================
# Network Health (Fast Check)
# ============================================

function Get-NetworkHealth {
    param([switch]$UseCache)

    if ($UseCache -and $script:CommandCenterState.NetworkCache.Timestamp) {
        $age = (Get-Date) - $script:CommandCenterState.NetworkCache.Timestamp
        if ($age.TotalSeconds -lt 30) {
            return $script:CommandCenterState.NetworkCache
        }
    }

    $health = @{
        Status = 'Unknown'
        Latency = $null
        Quality = 'Unknown'
        Timestamp = Get-Date
    }

    try {
        # Quick ping to Cloudflare DNS
        $ping = Test-Connection -ComputerName 1.1.1.1 -Count 1 -ErrorAction Stop
        $latency = $ping.ResponseTime

        $health.Latency = $latency
        $health.Status = 'Online'

        # Quality assessment
        if ($latency -lt 20) { $health.Quality = 'EXCELLENT' }
        elseif ($latency -lt 50) { $health.Quality = 'GOOD' }
        elseif ($latency -lt 100) { $health.Quality = 'FAIR' }
        else { $health.Quality = 'POOR' }

    } catch {
        $health.Status = 'Offline'
        $health.Quality = 'NO CONNECTION'
    }

    $script:CommandCenterState.NetworkCache = $health
    return $health
}

# ============================================
# Git Status (Fast)
# ============================================

function Get-GitStatus {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        return $null
    }

    try {
        $branch = git branch --show-current 2>$null
        $status = git status --porcelain 2>$null

        return @{
            Branch = $branch
            Modified = ($status | Select-String '^.M').Count
            Added = ($status | Select-String '^A').Count
            Untracked = ($status | Select-String '^\?\?').Count
            Total = $status.Count
        }
    } catch {
        return $null
    }
}

# ============================================
# Command Center Rendering
# ============================================

function Show-CommandCenter {
    param(
        [ValidateSet('Auto', 'Full', 'Minimal', 'Silent')]
        [string]$Mode = 'Auto'
    )

    if (-not $script:CommandCenterState.Enabled) { return }

    # Detect context
    $context = Get-CurrentContext

    # Determine display mode
    $displayMode = if ($Mode -eq 'Auto') {
        switch ($context.Type) {
            'Root' { 'Full' }
            'ClaudeNPC' { 'Full' }
            'BunHooks' { 'Full' }
            default { 'Minimal' }
        }
    } else { $Mode }

    if ($displayMode -eq 'Silent') { return }

    # Gather data
    $services = Get-ServiceHealth -UseCache
    $network = Get-NetworkHealth -UseCache
    $git = Get-GitStatus

    # Build display
    $width = $Host.UI.RawUI.WindowSize.Width - 2
    $line = $script:Glyphs.Line * $width

    Write-Host ""
    Write-Host "$($script:Glyphs.Corner)$line" -ForegroundColor $script:ColorScheme.Primary

    # Header with context
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "$($script:Glyphs.Vertical) " -NoNewline -ForegroundColor $script:ColorScheme.Primary
    Write-Host "$($context.Icon) " -NoNewline
    Write-Host "$($context.Name)" -NoNewline -ForegroundColor $script:ColorScheme.Highlight

    # Right-aligned timestamp
    $headerText = "$($context.Icon) $($context.Name)"
    $padding = " " * ($width - $headerText.Length - $timestamp.Length - 3)
    Write-Host $padding -NoNewline
    Write-Host "$($script:Glyphs.Clock) $timestamp" -ForegroundColor $script:ColorScheme.Muted

    if ($displayMode -eq 'Full') {
        # Services Section
        Write-Host "$($script:Glyphs.Branch)$($script:Glyphs.Line * 3) Services" -ForegroundColor $script:ColorScheme.Primary

        foreach ($key in $services.Keys) {
            $svc = $services[$key]
            $statusGlyph = if ($svc.Status -eq 'Active') { $script:Glyphs.Active } else { $script:Glyphs.Inactive }
            $statusColor = if ($svc.Status -eq 'Active') { $script:ColorScheme.Success } else { $script:ColorScheme.Muted }

            Write-Host "$($script:Glyphs.Vertical)   $statusGlyph " -NoNewline -ForegroundColor $statusColor
            Write-Host "$($svc.Glyph) $($svc.Name)" -NoNewline
            Write-Host " :$($svc.Port) " -NoNewline -ForegroundColor $script:ColorScheme.Muted
            Write-Host "$($svc.Status)" -ForegroundColor $statusColor
        }

        # Network Section
        Write-Host "$($script:Glyphs.Branch)$($script:Glyphs.Line * 3) Network" -ForegroundColor $script:ColorScheme.Primary
        $netColor = switch ($network.Quality) {
            'EXCELLENT' { $script:ColorScheme.Success }
            'GOOD' { $script:ColorScheme.Success }
            'FAIR' { $script:ColorScheme.Warning }
            default { $script:ColorScheme.Error }
        }
        Write-Host "$($script:Glyphs.Vertical)   $($script:Glyphs.Network) " -NoNewline
        Write-Host "$($network.Status)" -NoNewline -ForegroundColor $netColor
        if ($network.Latency) {
            Write-Host " | " -NoNewline -ForegroundColor $script:ColorScheme.Muted
            Write-Host "$($network.Latency)ms" -NoNewline -ForegroundColor $netColor
            Write-Host " ($($network.Quality))" -ForegroundColor $script:ColorScheme.Muted
        } else {
            Write-Host ""
        }

        # Git Section
        if ($git) {
            Write-Host "$($script:Glyphs.Branch)$($script:Glyphs.Line * 3) Git" -ForegroundColor $script:ColorScheme.Primary
            Write-Host "$($script:Glyphs.Vertical)   $($script:Glyphs.Git) " -NoNewline
            Write-Host "$($git.Branch)" -NoNewline -ForegroundColor $script:ColorScheme.Accent

            if ($git.Total -gt 0) {
                Write-Host " | " -NoNewline -ForegroundColor $script:ColorScheme.Muted
                if ($git.Modified -gt 0) {
                    Write-Host "$($git.Modified)M " -NoNewline -ForegroundColor $script:ColorScheme.Warning
                }
                if ($git.Added -gt 0) {
                    Write-Host "$($git.Added)A " -NoNewline -ForegroundColor $script:ColorScheme.Success
                }
                if ($git.Untracked -gt 0) {
                    Write-Host "$($git.Untracked)? " -NoNewline -ForegroundColor $script:ColorScheme.Muted
                }
                Write-Host ""
            } else {
                Write-Host " | " -NoNewline -ForegroundColor $script:ColorScheme.Muted
                Write-Host "clean" -ForegroundColor $script:ColorScheme.Success
            }
        }

        # Quick Actions
        if ($context.QuickActions.Count -gt 0) {
            Write-Host "$($script:Glyphs.Branch)$($script:Glyphs.Line * 3) Quick Actions" -ForegroundColor $script:ColorScheme.Primary
            foreach ($action in $context.QuickActions) {
                Write-Host "$($script:Glyphs.Vertical)   " -NoNewline -ForegroundColor $script:ColorScheme.Primary
                Write-Host "$($action.Key)" -NoNewline -ForegroundColor $script:ColorScheme.Accent
                Write-Host " → $($action.Desc)" -ForegroundColor $script:ColorScheme.Muted
            }
        }
    } else {
        # Minimal mode - single status line
        $activeServices = ($services.Values | Where-Object { $_.Status -eq 'Active' }).Count
        $totalServices = $services.Count

        Write-Host "$($script:Glyphs.Vertical) " -NoNewline -ForegroundColor $script:ColorScheme.Primary
        Write-Host "Services: $activeServices/$totalServices" -NoNewline -ForegroundColor $script:ColorScheme.Success
        Write-Host " | " -NoNewline -ForegroundColor $script:ColorScheme.Muted

        if ($network.Latency) {
            Write-Host "Network: $($network.Latency)ms" -NoNewline -ForegroundColor $script:ColorScheme.Success
        } else {
            Write-Host "Network: Offline" -NoNewline -ForegroundColor $script:ColorScheme.Error
        }

        if ($git) {
            Write-Host " | " -NoNewline -ForegroundColor $script:ColorScheme.Muted
            Write-Host "Git: $($git.Branch)" -NoNewline -ForegroundColor $script:ColorScheme.Accent
            if ($git.Total -gt 0) {
                Write-Host " ($($git.Total) changes)" -ForegroundColor $script:ColorScheme.Warning
            } else {
                Write-Host ""
            }
        } else {
            Write-Host ""
        }
    }

    Write-Host "$($script:Glyphs.CornerEnd)$line" -ForegroundColor $script:ColorScheme.Primary
    Write-Host ""
}

# ============================================
# Command Center Control Functions
# ============================================

function Enable-CommandCenter {
    <#
    .SYNOPSIS
        Enable the KENL Command Center
    #>
    $script:CommandCenterState.Enabled = $true
    Show-CommandCenter
}

function Disable-CommandCenter {
    <#
    .SYNOPSIS
        Disable the KENL Command Center
    #>
    $script:CommandCenterState.Enabled = $false
    Write-Host "Command Center disabled. Use " -NoNewline
    Write-Host "Enable-CommandCenter" -ForegroundColor Cyan -NoNewline
    Write-Host " to re-enable."
}

function Refresh-CommandCenter {
    <#
    .SYNOPSIS
        Force refresh the Command Center display
    #>
    $script:CommandCenterState.ServiceCache = @{}
    $script:CommandCenterState.NetworkCache = @{}
    Show-CommandCenter
}

function Set-CommandCenterMode {
    <#
    .SYNOPSIS
        Set the display mode for Command Center
    .PARAMETER Mode
        Display mode: Auto, Full, Minimal, or Silent
    #>
    param(
        [ValidateSet('Auto', 'Full', 'Minimal', 'Silent')]
        [string]$Mode
    )

    $script:CommandCenterState.ContextMode = $Mode
    Write-Host "Command Center mode set to: " -NoNewline
    Write-Host $Mode -ForegroundColor Cyan
    Show-CommandCenter -Mode $Mode
}

# ============================================
# Auto-Display on Directory Change
# ============================================

$script:OriginalPrompt = $function:prompt

function prompt {
    # Call original prompt
    $result = & $script:OriginalPrompt

    # Show Command Center on directory change
    if ($script:CommandCenterState.Enabled) {
        $currentLocation = Get-Location
        if ($currentLocation -ne $script:CommandCenterState.LastLocation) {
            Show-CommandCenter -Mode $script:CommandCenterState.ContextMode
            $script:CommandCenterState.LastLocation = $currentLocation
        }
    }

    return $result
}

# ============================================
# Aliases for Quick Access
# ============================================

Set-Alias -Name cc -Value Show-CommandCenter
Set-Alias -Name ccon -Value Enable-CommandCenter
Set-Alias -Name ccoff -Value Disable-CommandCenter
Set-Alias -Name ccref -Value Refresh-CommandCenter

# ============================================
# Export Functions
# ============================================

Export-ModuleMember -Function @(
    'Show-CommandCenter',
    'Enable-CommandCenter',
    'Disable-CommandCenter',
    'Refresh-CommandCenter',
    'Set-CommandCenterMode',
    'Get-ServiceHealth',
    'Get-NetworkHealth',
    'Get-GitStatus',
    'Get-CurrentContext'
) -Alias @('cc', 'ccon', 'ccoff', 'ccref')

# ============================================
# Welcome Message
# ============================================

Write-Host "`nKENL Command Center " -NoNewline -ForegroundColor Cyan
Write-Host "loaded" -ForegroundColor Green
Write-Host "  Quick commands: " -NoNewline -ForegroundColor DarkGray
Write-Host "cc" -NoNewline -ForegroundColor Yellow
Write-Host " (show), " -NoNewline -ForegroundColor DarkGray
Write-Host "ccref" -NoNewline -ForegroundColor Yellow
Write-Host " (refresh), " -NoNewline -ForegroundColor DarkGray
Write-Host "ccoff" -NoNewline -ForegroundColor Yellow
Write-Host " (disable)" -ForegroundColor DarkGray
