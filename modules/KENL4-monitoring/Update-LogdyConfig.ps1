#Requires -Version 5.1

<#
.SYNOPSIS
    Updates Logdy configuration for JSON ATOM trail

.DESCRIPTION
    Converts Logdy config to use JSON parser for ATOM trail.
    Optimized for AI communication and structured queries.

.EXAMPLE
    .\Update-LogdyConfig.ps1
#>

$logdyConfigPath = "$env:USERPROFILE\.config\logdy\config.yaml"

Write-Host "Updating Logdy configuration for JSON ATOM trail..." -ForegroundColor Cyan
Write-Host ""

# Backup existing config
if (Test-Path $logdyConfigPath) {
    $backupPath = "$logdyConfigPath.backup-$(Get-Date -Format 'yyyyMMddHHmmss')"
    Copy-Item $logdyConfigPath $backupPath
    Write-Host "✅ Backup created: $backupPath" -ForegroundColor Green
}

# Create optimized JSON-based config
$newConfig = @"
# Logdy Central Configuration (JSON-optimized for AI)
# ATOM: ATOM-CONFIG-20251117-003

listen: 0.0.0.0:8081

sources:
  # ATOM Trail (JSON format - AI-optimized)
  - name: atom-trail
    path: ~/.kenl/.atom-trail.json
    mode: tail
    parser:
      type: json

  # Windows System Events (JSON format)
  - name: windows-events
    path: ~/.kenl/.atom-logs/system-events.json
    mode: tail
    parser:
      type: json

  # Claude conversation logs (if available)
  - name: claude-logs
    path: ~/.kenl/claude-logs/*.json
    mode: tail
    parser:
      type: json

# Filters
filters:
  # Include all ATOM entries
  - field: atom_tag
    operator: exists

  # Exclude debug noise
  - field: severity
    operator: not_equals
    value: DEBUG

# UI Configuration
ui:
  # Default columns
  columns:
    - timestamp
    - atom_tag
    - atom_type
    - severity
    - message

  # Column widths (pixels)
  column_widths:
    timestamp: 180
    atom_tag: 220
    atom_type: 80
    severity: 80
    message: 500

  # Refresh interval (ms)
  refresh_interval: 1000

  # Theme
  theme: dark

# Storage
storage:
  type: memory
  max_entries: 10000

# Advanced: AI query endpoint (future)
# ai:
#   enabled: true
#   models:
#     - claude-sonnet-4.5
#     - qwen-2.5-14b
"@

# Write new config
$newConfig | Set-Content -Path $logdyConfigPath -Encoding UTF8

Write-Host "✅ Logdy configuration updated" -ForegroundColor Green
Write-Host ""
Write-Host "Configuration features:" -ForegroundColor Yellow
Write-Host "  • JSON parser for ATOM trail (AI-optimized)" -ForegroundColor White
Write-Host "  • Windows system events support" -ForegroundColor White
Write-Host "  • Claude logs integration" -ForegroundColor White
Write-Host "  • Auto-refresh every 1 second" -ForegroundColor White
Write-Host "  • Memory storage (10,000 entries)" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Initialize ATOM trail: Import-Module Write-AtomLog; atom-init" -ForegroundColor White
Write-Host "  2. Restart Logdy: .\Start-LogdyCentral.ps1 -Force" -ForegroundColor White
Write-Host "  3. Test: atom-log -Type TEST -Message 'Testing JSON format'" -ForegroundColor White
Write-Host "  4. View: http://localhost:8081" -ForegroundColor White
