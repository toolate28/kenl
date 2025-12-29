# Install Logdy Central
# Creates SAIF monitoring infrastructure

$ErrorActionPreference = "Stop"

Write-Host "Installing Logdy Central..." -ForegroundColor Cyan

# Create .kenl directory structure
$kenlRoot = Join-Path $env:USERPROFILE ".kenl"
$kenlBin = Join-Path $kenlRoot "bin"
$logdyPath = Join-Path $kenlBin "logdy.exe"
$atomTrailPath = Join-Path $kenlRoot ".atom-trail"
$configDir = Join-Path $env:USERPROFILE ".config\logdy"

Write-Host "  Creating directories..." -ForegroundColor Gray
New-Item -ItemType Directory -Force -Path $kenlBin | Out-Null
New-Item -ItemType Directory -Force -Path $configDir | Out-Null

# Download Logdy
Write-Host "  Downloading Logdy..." -ForegroundColor Gray
$logdyUrl = "https://github.com/logdyhq/logdy-core/releases/download/v0.9.1/logdy-windows-amd64.exe"
try {
    Invoke-WebRequest -Uri $logdyUrl -OutFile $logdyPath -UseBasicParsing
    Write-Host "  Downloaded to: $logdyPath" -ForegroundColor Green
} catch {
    Write-Host "  Download failed: $_" -ForegroundColor Red
    exit 1
}

# Create initial ATOM trail file
if (-not (Test-Path $atomTrailPath)) {
    Write-Host "  Creating ATOM trail..." -ForegroundColor Gray
    $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
    $initEntry = "$timestamp | ATOM-STATUS-$(Get-Date -Format 'yyyyMMdd')-001 | [System] | Local | Logdy Central infrastructure initialized"
    Set-Content -Path $atomTrailPath -Value $initEntry -Encoding UTF8
    Write-Host "  Created: $atomTrailPath" -ForegroundColor Green
}

# Create Logdy middlewares configuration
$middlewaresPath = Join-Path $configDir "middlewares.json"
$middlewares = @'
[
  {
    "name": "atom_trail_parser",
    "type": "column",
    "config": {
      "delimiter": " | ",
      "columns": ["timestamp", "atom_tag", "context", "location", "message"]
    }
  },
  {
    "name": "atom_type_colorizer",
    "type": "transform",
    "config": {
      "rules": [
        {"pattern": "NETWORK", "color": "#00AFF4"},
        {"pattern": "CONFIG", "color": "#FEE75C"},
        {"pattern": "MONITORING", "color": "#57F287"},
        {"pattern": "STATUS", "color": "#5865F2"},
        {"pattern": "FIX", "color": "#FF6B6B"}
      ]
    }
  }
]
'@

Set-Content -Path $middlewaresPath -Value $middlewares -Encoding UTF8
Write-Host "  Created middlewares: $middlewaresPath" -ForegroundColor Green

# Add to PATH if not already there
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$kenlBin*") {
    Write-Host "  Adding to PATH..." -ForegroundColor Gray
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$kenlBin", "User")
    Write-Host "  Added $kenlBin to PATH" -ForegroundColor Green
}

Write-Host "`nLogdy Central installed successfully!" -ForegroundColor Green
Write-Host "  Executable: $logdyPath" -ForegroundColor White
Write-Host "  ATOM Trail: $atomTrailPath" -ForegroundColor White
Write-Host "  Config: $configDir" -ForegroundColor White
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "  1. Run: Start-LogdyCentral.ps1" -ForegroundColor White
Write-Host "  2. Open: http://localhost:8081" -ForegroundColor White
