# Bazzite KDE ISO Download - Interactive Terminal
# ATOM-CFG-20251112-005
# Opens in separate window for monitoring

$ErrorActionPreference = "Stop"

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Bazzite KDE ISO Download" -ForegroundColor Cyan
Write-Host "  ATOM-CFG-20251112-005" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Create download directory
$downloadDir = "C:\Users\Matthew Ruhnau\Downloads\bazzite"
New-Item -ItemType Directory -Force -Path $downloadDir | Out-Null
Set-Location $downloadDir

Write-Host "[1/3] Download directory: $downloadDir" -ForegroundColor Green
Write-Host ""

# ISO URLs (latest build: 43.20251102)
$ISO_URL = "https://download.bazzite.gg/bazzite-43.20251102.iso"
$SHA256_URL = "https://download.bazzite.gg/bazzite-43.20251102.iso.sha256sum"

Write-Host "[2/3] Downloading Bazzite KDE Desktop ISO..." -ForegroundColor Yellow
Write-Host "  URL: $ISO_URL" -ForegroundColor Gray
Write-Host "  Using aria2c (16 connections)" -ForegroundColor Gray
Write-Host ""

# Download with aria2c (visible progress)
aria2c `
  --max-connection-per-server=16 `
  --split=16 `
  --min-split-size=1M `
  --continue=true `
  --file-allocation=none `
  --summary-interval=1 `
  --console-log-level=notice `
  $ISO_URL

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ Download failed with exit code: $LASTEXITCODE" -ForegroundColor Red
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "✅ ISO downloaded successfully!" -ForegroundColor Green
Write-Host ""

# Download SHA256 checksum
Write-Host "[3/3] Downloading SHA256 checksum..." -ForegroundColor Yellow
Invoke-WebRequest -Uri $SHA256_URL -OutFile "bazzite-43.20251102.iso.sha256sum"
Write-Host "  ✅ Checksum downloaded" -ForegroundColor Green
Write-Host ""

# Verify SHA256
Write-Host "Verifying SHA256 checksum..." -ForegroundColor Yellow
$Downloaded = (Get-FileHash -Path "bazzite-43.20251102.iso" -Algorithm SHA256).Hash.ToLower()
$Expected = (Get-Content "bazzite-43.20251102.iso.sha256sum" -Raw).Split()[0].ToLower()

Write-Host "  Expected: $Expected" -ForegroundColor Gray
Write-Host "  Downloaded: $Downloaded" -ForegroundColor Gray

if ($Downloaded -eq $Expected) {
    Write-Host ""
    Write-Host "✅ SHA256 VERIFICATION PASSED" -ForegroundColor Green
    Write-Host ""
    Write-Host "ISO is ready to use!" -ForegroundColor Cyan
    Write-Host "Location: $downloadDir\bazzite-43.20251102.iso" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "❌ SHA256 VERIFICATION FAILED" -ForegroundColor Red
    Write-Host "  The downloaded file is corrupted or tampered with!" -ForegroundColor Red
    Write-Host "  DO NOT USE THIS ISO!" -ForegroundColor Red
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Copy ISO to Ventoy USB (if verified)" -ForegroundColor White
Write-Host "  2. Run STEP1-WINDOWS-WIPE-DISK1.ps1 to prepare external drive" -ForegroundColor White
Write-Host "  3. Reboot and boot from Ventoy USB" -ForegroundColor White
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Log ATOM trail
$atomLog = "C:\Users\Matthew Ruhnau\kenl-atom-trail.log"
"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') | ATOM-CFG-20251112-005 | Bazzite KDE ISO downloaded and verified" | Out-File -FilePath $atomLog -Append

Read-Host "Press Enter to exit"
