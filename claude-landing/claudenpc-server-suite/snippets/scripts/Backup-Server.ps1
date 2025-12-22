# Backup-Server.ps1
# Automated backup script for ClaudeNPC Server Suite
# Version: 1.0.0
# Status: PRODUCTION READY - Drop-in snippet

#Requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$ServerPath = "C:\MinecraftServer",
    
    [Parameter(Mandatory=$false)]
    [string]$BackupPath = "C:\MinecraftBackups",
    
    [Parameter(Mandatory=$false)]
    [int]$KeepBackups = 7,
    
    [Parameter(Mandatory=$false)]
    [switch]$Quiet
)

$ErrorActionPreference = "Stop"

#region Helper Functions

function Write-BackupLog {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Console output
    if (-not $Quiet) {
        $color = switch ($Level) {
            "ERROR" { "Red" }
            "WARNING" { "Yellow" }
            "SUCCESS" { "Green" }
            default { "White" }
        }
        Write-Host $logMessage -ForegroundColor $color
    }
    
    # Log file
    $logFile = Join-Path $BackupPath "backup.log"
    try {
        Add-Content -Path $logFile -Value $logMessage -ErrorAction SilentlyContinue
    } catch {
        # Silently continue if logging fails
    }
}

function Show-BackupBanner {
    $banner = @"

╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║   ██████╗██╗      █████╗ ██╗   ██╗██████╗ ███████╗███╗   ██╗   ║
║  ██╔════╝██║     ██╔══██╗██║   ██║██╔══██╗██╔════╝████╗  ██║   ║
║  ██║     ██║     ███████║██║   ██║██║  ██║█████╗  ██╔██╗ ██║   ║
║  ██║     ██║     ██╔══██║██║   ██║██║  ██║██╔══╝  ██║╚██╗██║   ║
║  ╚██████╗███████╗██║  ██║╚██████╔╝██████╔╝███████╗██║ ╚████║   ║
║   ╚═════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝   ║
║                                                                  ║
║                     S E R V E R   B A C K U P                   ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝

"@
    if (-not $Quiet) {
        Write-Host $banner -ForegroundColor Cyan
    }
}

#endregion

#region Main Backup Process

try {
    # Display banner
    Show-BackupBanner
    
    Write-BackupLog "Starting backup process" -Level "INFO"
    Write-BackupLog "Server path: $ServerPath" -Level "INFO"
    Write-BackupLog "Backup path: $BackupPath" -Level "INFO"
    
    # Validate server path
    if (-not (Test-Path $ServerPath)) {
        throw "Server path not found: $ServerPath"
    }
    
    # Create backup directory
    if (-not (Test-Path $BackupPath)) {
        Write-BackupLog "Creating backup directory: $BackupPath" -Level "INFO"
        New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
    }
    
    # Generate backup name
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupName = "server-backup-$timestamp"
    $tempBackupPath = Join-Path $BackupPath $backupName
    $zipPath = "$tempBackupPath.zip"
    
    Write-BackupLog "Creating temporary backup folder: $backupName" -Level "INFO"
    New-Item -ItemType Directory -Path $tempBackupPath -Force | Out-Null
    
    # Items to backup
    $backupItems = @(
        @{Path = "world"; Description = "Overworld"},
        @{Path = "world_nether"; Description = "Nether"},
        @{Path = "world_the_end"; Description = "The End"},
        @{Path = "plugins"; Description = "Plugins"},
        @{Path = "server.properties"; Description = "Server config"},
        @{Path = "bukkit.yml"; Description = "Bukkit config"},
        @{Path = "spigot.yml"; Description = "Spigot config"},
        @{Path = "paper-global.yml"; Description = "Paper config"},
        @{Path = "paper-world-defaults.yml"; Description = "Paper world defaults"},
        @{Path = "ops.json"; Description = "Operators"},
        @{Path = "whitelist.json"; Description = "Whitelist"},
        @{Path = "banned-players.json"; Description = "Banned players"},
        @{Path = "banned-ips.json"; Description = "Banned IPs"}
    )
    
    $backedUpCount = 0
    $skippedCount = 0
    $totalSize = 0
    
    Write-Host ""
    Write-BackupLog "Backing up server files..." -Level "INFO"
    Write-Host ""
    
    foreach ($item in $backupItems) {
        $sourcePath = Join-Path $ServerPath $item.Path
        
        if (Test-Path $sourcePath) {
            $destPath = Join-Path $tempBackupPath $item.Path
            
            try {
                # Copy item
                Copy-Item -Path $sourcePath -Destination $destPath -Recurse -Force -ErrorAction Stop
                
                # Calculate size
                if (Test-Path $destPath -PathType Container) {
                    $itemSize = (Get-ChildItem $destPath -Recurse -File | Measure-Object -Property Length -Sum).Sum
                } else {
                    $itemSize = (Get-Item $destPath).Length
                }
                $totalSize += $itemSize
                
                $backedUpCount++
                Write-BackupLog "  ✓ $($item.Description) ($([math]::Round($itemSize / 1MB, 2)) MB)" -Level "SUCCESS"
            } catch {
                Write-BackupLog "  ✗ Failed to backup $($item.Description): $($_.Exception.Message)" -Level "ERROR"
            }
        } else {
            $skippedCount++
            Write-BackupLog "  - $($item.Description) (not found, skipped)" -Level "INFO"
        }
    }
    
    Write-Host ""
    Write-BackupLog "Compressing backup archive..." -Level "INFO"
    
    # Compress backup
    Compress-Archive -Path $tempBackupPath -DestinationPath $zipPath -CompressionLevel Optimal -Force
    
    # Remove temporary folder
    Remove-Item -Path $tempBackupPath -Recurse -Force
    
    # Get final zip size
    $zipSize = (Get-Item $zipPath).Length
    $compressionRatio = if ($totalSize -gt 0) { 
        [math]::Round((1 - ($zipSize / $totalSize)) * 100, 1) 
    } else { 
        0 
    }
    
    Write-Host ""
    Write-BackupLog "✓ Backup complete!" -Level "SUCCESS"
    Write-BackupLog "  Location: $zipPath" -Level "SUCCESS"
    Write-BackupLog "  Size: $([math]::Round($zipSize / 1MB, 2)) MB (compressed from $([math]::Round($totalSize / 1MB, 2)) MB)" -Level "SUCCESS"
    Write-BackupLog "  Compression: $compressionRatio% reduction" -Level "SUCCESS"
    Write-BackupLog "  Items backed up: $backedUpCount" -Level "SUCCESS"
    Write-BackupLog "  Items skipped: $skippedCount" -Level "SUCCESS"
    
    # Cleanup old backups
    Write-Host ""
    Write-BackupLog "Cleaning up old backups (keeping last $KeepBackups)..." -Level "INFO"
    
    $oldBackups = Get-ChildItem $BackupPath -Filter "server-backup-*.zip" | 
                  Sort-Object LastWriteTime -Descending | 
                  Select-Object -Skip $KeepBackups
    
    if ($oldBackups) {
        foreach ($oldBackup in $oldBackups) {
            try {
                Remove-Item $oldBackup.FullName -Force
                Write-BackupLog "  ✓ Removed old backup: $($oldBackup.Name)" -Level "INFO"
            } catch {
                Write-BackupLog "  ✗ Failed to remove: $($oldBackup.Name)" -Level "WARNING"
            }
        }
    } else {
        Write-BackupLog "  No old backups to remove" -Level "INFO"
    }
    
    Write-Host ""
    Write-Host ("═" * 70) -ForegroundColor Green
    Write-Host ""
    Write-Host "  ✓ Backup completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host ("═" * 70) -ForegroundColor Green
    Write-Host ""
    
    exit 0
    
} catch {
    Write-Host ""
    Write-Host ("═" * 70) -ForegroundColor Red
    Write-Host ""
    Write-Host "  ✗ Backup failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host ("═" * 70) -ForegroundColor Red
    Write-Host ""
    
    Write-BackupLog "Backup failed: $($_.Exception.Message)" -Level "ERROR"
    exit 1
}

#endregion
