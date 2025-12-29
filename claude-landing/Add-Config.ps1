# Add-Config.ps1
# Universal just-in-time configuration for KENL ecosystem
# "A tool that only uses the tools you need right then and there"

param(
    [Parameter(Mandatory, Position=0)]
    [ValidateSet("SlashCommand", "WaveTermAI", "MCPServer", "ClaudeSkill", "PowerShellAlias")]
    [string]$ConfigType,

    [Parameter(Mandatory, Position=1)]
    [string]$Name,

    [Parameter(Mandatory, Position=2)]
    [string]$Definition,

    [hashtable]$Config = @{},
    [string]$Example,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$timestamp = Get-Date -Format "yyyy-MM-dd"
$kenlRoot = Join-Path $env:USERPROFILE ".kenl\claude-landing"

# ============================================
# Claude Code Slash Command
# ============================================

function Add-SlashCommand {
    param($Name, $Definition, $Example)

    Write-Host "`nCreating Claude Code slash command..." -ForegroundColor Cyan

    $commandsDir = Join-Path $kenlRoot ".claude\commands"
    New-Item -ItemType Directory -Force -Path $commandsDir | Out-Null

    $commandFile = Join-Path $commandsDir "$Name.md"

    if (Test-Path $commandFile) {
        Write-Host "  [WARN] Command '/$Name' already exists" -ForegroundColor Yellow
        return
    }

    $commandContent = @"
# /$Name

$Definition

## Usage

``````bash
/$Name
``````

$(if ($Example) {
@"
## Example

``````
$Example
``````
"@
})

## Created

- **Date:** $timestamp
- **Tool:** Add-Config.ps1 (just-in-time configuration)
- **Type:** Dynamic slash command

## Integration

Part of KENL/SAIF just-in-time tooling - only loads what you need when you need it.
"@

    if ($DryRun) {
        Write-Host "DRY RUN - Would create:" -ForegroundColor Yellow
        Write-Host "  File: $commandFile" -ForegroundColor Gray
    } else {
        Set-Content -Path $commandFile -Value $commandContent
        Write-Host "  [OK] Created: /$Name" -ForegroundColor Green
        Write-Host "  Usage: /$Name" -ForegroundColor Cyan
    }
}

# ============================================
# WaveTerm AI Configuration
# ============================================

function Add-WaveTermAI {
    param($Name, $Definition, $Config)

    Write-Host "`nAdding WaveTerm AI configuration..." -ForegroundColor Cyan

    $waveConfigFile = Join-Path $kenlRoot "env-config\waveterm-ai-config.json"

    if (-not (Test-Path $waveConfigFile)) {
        Write-Host "  [ERROR] WaveTerm AI config not found" -ForegroundColor Red
        return
    }

    $waveConfig = Get-Content $waveConfigFile -Raw | ConvertFrom-Json

    # Add custom command
    $newCommand = @{
        name = $Name
        description = $Definition
        prompt = $Config.prompt ?? "Execute $Name"
        outputFormat = $Config.outputFormat ?? "text"
        includeContext = $Config.includeContext ?? $true
    }

    # Ensure customCommands exists
    if (-not $waveConfig.customCommands) {
        $waveConfig | Add-Member -MemberType NoteProperty -Name customCommands -Value @()
    }

    # Check if command already exists
    $existing = $waveConfig.customCommands | Where-Object { $_.name -eq $Name }
    if ($existing) {
        Write-Host "  [WARN] WaveTerm command '$Name' already exists" -ForegroundColor Yellow
        return
    }

    # Add new command
    $waveConfig.customCommands += $newCommand

    if ($DryRun) {
        Write-Host "DRY RUN - Would add to WaveTerm AI:" -ForegroundColor Yellow
        Write-Host "  Command: $Name" -ForegroundColor Gray
        Write-Host "  Prompt: $($newCommand.prompt)" -ForegroundColor Gray
    } else {
        $waveConfig | ConvertTo-Json -Depth 10 | Set-Content -Path $waveConfigFile
        Write-Host "  [OK] Added WaveTerm AI command: $Name" -ForegroundColor Green
    }
}

# ============================================
# MCP Server Configuration
# ============================================

function Add-MCPServer {
    param($Name, $Definition, $Config)

    Write-Host "`nAdding MCP server configuration..." -ForegroundColor Cyan

    $mcpConfigFile = Join-Path $env:APPDATA "Claude\claude_desktop_config.json"

    # Check if Claude Desktop config exists
    if (-not (Test-Path $mcpConfigFile)) {
        Write-Host "  [WARN] Claude Desktop config not found at $mcpConfigFile" -ForegroundColor Yellow
        Write-Host "  Creating new config..." -ForegroundColor Gray

        $mcpConfig = @{
            mcpServers = @{}
        }
    } else {
        $mcpConfig = Get-Content $mcpConfigFile -Raw | ConvertFrom-Json
    }

    # Ensure mcpServers exists
    if (-not $mcpConfig.mcpServers) {
        $mcpConfig | Add-Member -MemberType NoteProperty -Name mcpServers -Value @{}
    }

    # Check if server already exists
    if ($mcpConfig.mcpServers.PSObject.Properties.Name -contains $Name) {
        Write-Host "  [WARN] MCP server '$Name' already exists" -ForegroundColor Yellow
        return
    }

    # Add new MCP server
    $serverConfig = @{
        command = $Config.command ?? "npx"
        args = $Config.args ?? @("-y", "@modelcontextprotocol/$Name")
        env = $Config.env ?? @{}
    }

    $mcpConfig.mcpServers | Add-Member -MemberType NoteProperty -Name $Name -Value $serverConfig

    if ($DryRun) {
        Write-Host "DRY RUN - Would add MCP server:" -ForegroundColor Yellow
        Write-Host "  Name: $Name" -ForegroundColor Gray
        Write-Host "  Command: $($serverConfig.command)" -ForegroundColor Gray
    } else {
        $mcpConfig | ConvertTo-Json -Depth 10 | Set-Content -Path $mcpConfigFile
        Write-Host "  [OK] Added MCP server: $Name" -ForegroundColor Green
        Write-Host "  Restart Claude Desktop to load server" -ForegroundColor Yellow
    }
}

# ============================================
# Claude Code Skill (Managed)
# ============================================

function Add-ClaudeSkill {
    param($Name, $Definition, $Example)

    Write-Host "`nCreating Claude Code skill..." -ForegroundColor Cyan

    $skillsDir = Join-Path $kenlRoot ".claude\skills"
    New-Item -ItemType Directory -Force -Path $skillsDir | Out-Null

    $skillFile = Join-Path $skillsDir "$Name.md"

    $skillContent = @"
# $Name

## Description

$Definition

## Usage

``````bash
claude skill run $Name
``````

$(if ($Example) {
@"
## Example

``````
$Example
``````
"@
})

## Created

- **Date:** $timestamp
- **Tool:** Add-Config.ps1 (just-in-time configuration)

"@

    if ($DryRun) {
        Write-Host "DRY RUN - Would create skill:" -ForegroundColor Yellow
        Write-Host "  File: $skillFile" -ForegroundColor Gray
    } else {
        Set-Content -Path $skillFile -Value $skillContent
        Write-Host "  [OK] Created skill: $Name" -ForegroundColor Green
    }
}

# ============================================
# PowerShell Alias
# ============================================

function Add-PSAlias {
    param($Name, $Definition)

    Write-Host "`nAdding PowerShell alias..." -ForegroundColor Cyan

    $profilePath = $PROFILE.CurrentUserAllHosts
    $aliasLine = "Set-Alias -Name $Name -Value $Definition -ErrorAction SilentlyContinue"

    # Check if alias already exists in profile
    if (Test-Path $profilePath) {
        $profileContent = Get-Content $profilePath -Raw
        if ($profileContent -match "Set-Alias.*-Name $Name") {
            Write-Host "  [WARN] Alias '$Name' already exists in profile" -ForegroundColor Yellow
            return
        }
    }

    # Add alias to profile
    $comment = "# Added by Add-Config.ps1 on $timestamp - $Definition"

    if ($DryRun) {
        Write-Host "DRY RUN - Would add to profile:" -ForegroundColor Yellow
        Write-Host "  $comment" -ForegroundColor Gray
        Write-Host "  $aliasLine" -ForegroundColor Gray
    } else {
        Add-Content -Path $profilePath -Value "`n$comment"
        Add-Content -Path $profilePath -Value $aliasLine
        Write-Host "  [OK] Added alias: $Name -> $Definition" -ForegroundColor Green
        Write-Host "  Reload profile: . `$PROFILE" -ForegroundColor Cyan
    }
}

# ============================================
# Main Execution
# ============================================

Write-Host "=" * 70 -ForegroundColor Gray
Write-Host "Universal Just-In-Time Configuration" -ForegroundColor Cyan
Write-Host '"Only loads the tools you need when you need them"' -ForegroundColor DarkGray
Write-Host "=" * 70 -ForegroundColor Gray

Write-Host "`nConfig Type: $ConfigType" -ForegroundColor White
Write-Host "Name: $Name" -ForegroundColor White
Write-Host "Definition: $Definition" -ForegroundColor White

switch ($ConfigType) {
    "SlashCommand" {
        Add-SlashCommand -Name $Name -Definition $Definition -Example $Example
    }

    "WaveTermAI" {
        Add-WaveTermAI -Name $Name -Definition $Definition -Config $Config
    }

    "MCPServer" {
        Add-MCPServer -Name $Name -Definition $Definition -Config $Config
    }

    "ClaudeSkill" {
        Add-ClaudeSkill -Name $Name -Definition $Definition -Example $Example
    }

    "PowerShellAlias" {
        Add-PSAlias -Name $Name -Definition $Definition
    }
}

# Add ATOM trail entry
$atomScript = Join-Path $kenlRoot "Write-AtomTrail.ps1"
if ((Test-Path $atomScript) -and (-not $DryRun)) {
    & $atomScript -Type CONFIG -Message "Added $ConfigType '$Name' via just-in-time config" -Context CLI
}

Write-Host "`n" + "=" * 70 -ForegroundColor Gray
if (-not $DryRun) {
    Write-Host "Configuration added successfully!" -ForegroundColor Green
} else {
    Write-Host "DRY RUN complete - no changes made" -ForegroundColor Yellow
}
Write-Host ""
