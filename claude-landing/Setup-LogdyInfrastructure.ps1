# Setup Logdy Infrastructure
# Creates directories, ATOM trail, and helper scripts

$ErrorActionPreference = "Stop"

Write-Host "`nSetting up Logdy infrastructure..." -ForegroundColor Cyan

# Create directory structure
$kenlRoot = Join-Path $env:USERPROFILE ".kenl"
$kenlBin = Join-Path $kenlRoot "bin"
$atomTrailPath = Join-Path $kenlRoot ".atom-trail"
$configDir = Join-Path $env:USERPROFILE ".config\logdy"

Write-Host "Creating directories..." -ForegroundColor Gray
New-Item -ItemType Directory -Force -Path $kenlBin | Out-Null
New-Item -ItemType Directory -Force -Path $configDir | Out-Null

# Create ATOM trail with initial entry
Write-Host "Creating ATOM trail..." -ForegroundColor Gray
$timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
$dateTag = Get-Date -Format "yyyyMMdd"
$initEntry = "$timestamp | ATOM-STATUS-$dateTag-001 | [System] | Local | Logdy Central infrastructure initialized"
Set-Content -Path $atomTrailPath -Value $initEntry -Encoding UTF8

# Create Logdy middlewares config
Write-Host "Creating Logdy configuration..." -ForegroundColor Gray
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
  }
]
'@
Set-Content -Path $middlewaresPath -Value $middlewares -Encoding UTF8

Write-Host "`nInfrastructure setup complete!" -ForegroundColor Green
Write-Host "  .kenl directory: $kenlRoot" -ForegroundColor White
Write-Host "  ATOM trail: $atomTrailPath" -ForegroundColor White
Write-Host "  Logdy config: $configDir" -ForegroundColor White

# Show ATOM trail
Write-Host "`nCurrent ATOM trail:" -ForegroundColor Cyan
Get-Content $atomTrailPath

Write-Host "`nNext: Download Logdy manually from:" -ForegroundColor Yellow
Write-Host "  https://github.com/logdyhq/logdy-core/releases" -ForegroundColor White
Write-Host "  Save as: $kenlBin\logdy.exe" -ForegroundColor White
