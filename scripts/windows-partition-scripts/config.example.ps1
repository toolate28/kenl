# User Configuration Template
# Copy this to 'config.local.ps1' and customize for your system
# config.local.ps1 is gitignored - your settings stay private

<#
.SYNOPSIS
    User-specific configuration for Windows partition scripts
.NOTES
    This template shows all configurable parameters.
    Copy to 'config.local.ps1' and modify values.
#>

# ============================================
# DISK CONFIGURATION
# ============================================

# Target disk number (check with: Get-Disk | Format-Table)
$DISK_NUMBER = 1

# Expected disk size (GB) - for safety verification
$EXPECTED_DISK_SIZE = 1800

# Disk description (for confirmation prompts)
$DISK_DESCRIPTION = "1.8TB Seagate FireCuda External HDD"

# ============================================
# PARTITION SIZES (GB)
# ============================================

# Adjust these based on your needs
# Total should not exceed disk size minus ~50GB overhead

$PARTITION_CONFIG = @{
    GamesUniversal = 900   # Shared Steam library (NTFS)
    ClaudeAI       = 500   # LLM models, datasets (ext4)
    Development    = 200   # Distrobox, repos (ext4)
    WindowsOnly    = 150   # Anti-cheat games (NTFS)
    Transfer       = 0     # Use remaining space (exFAT)
}

# ============================================
# DRIVE LETTER ASSIGNMENTS
# ============================================

$DRIVE_LETTERS = @{
    GamesUniversal = "H"
    ClaudeAI       = "I"
    Development    = "L"
    WindowsOnly    = "K"
    Transfer       = "J"
}

# ============================================
# OUTPUT CONFIGURATION
# ============================================

# Where to save handover documents
$HANDOVER_DIR = "$env:USERPROFILE\Desktop"

# Alternative: Save to archive directory (gitignored)
# $HANDOVER_DIR = "$PSScriptRoot\.archive"

# Include disk serial numbers in handover docs (privacy concern)
$INCLUDE_SERIAL_NUMBERS = $false

# Include full error stack traces in handover docs
$VERBOSE_ERRORS = $true

# ============================================
# SAFETY SETTINGS
# ============================================

# Require explicit confirmation before wiping disk
$REQUIRE_WIPE_CONFIRMATION = $true

# Confirmation phrase (must be typed exactly)
$WIPE_CONFIRMATION_PHRASE = "WIPE DISK $DISK_NUMBER"

# Allow wiping of system/boot disks (DANGEROUS - keep false)
$ALLOW_SYSTEM_DISK_WIPE = $false

# Minimum disk size for safety check (GB)
$MIN_DISK_SIZE = 1700

# Maximum disk size for safety check (GB)
# Set to 0 to disable
$MAX_DISK_SIZE = 2000

# ============================================
# ADVANCED OPTIONS
# ============================================

# Wait time after format before write test (seconds)
$FORMAT_WAIT_TIME = 2

# Retry count for failed operations
$MAX_RETRIES = 3

# Enable PowerShell transcript logging
$ENABLE_TRANSCRIPT = $false

# Transcript log directory
$TRANSCRIPT_DIR = "$PSScriptRoot\.archive\logs"

# ============================================
# USAGE EXAMPLE
# ============================================

<#
# In your scripts, source this config:

# Check if user config exists
if (Test-Path "$PSScriptRoot\config.local.ps1") {
    . "$PSScriptRoot\config.local.ps1"
    Write-Host "✓ Loaded user configuration" -ForegroundColor Green
} else {
    Write-Host "⚠️  No config.local.ps1 found - using defaults" -ForegroundColor Yellow
    Write-Host "   Copy config.example.ps1 to config.local.ps1 to customize" -ForegroundColor Gray
}
#>
