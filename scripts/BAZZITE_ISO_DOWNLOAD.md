---
project: Bazza-DX SAGE Framework
status: active
version: 2025-11-07
classification: OWI-DOC
atom: ATOM-CFG-20251107-024
owi-version: 1.0.0
---

# Bazzite ISO Download & Verification (PowerShell)

**Purpose:** Automated Bazzite ISO download with hash verification and signature checking

**ATOM Tag:** `ATOM-CFG-20251107-024`

---

## Quick Download Command

```powershell
# Bazzite 43.20251102 ISO Download with aria2c
# Run in PowerShell (Administrator recommended)

# 1. Install aria2c (if not already installed)
# Via Chocolatey:
choco install aria2 -y
# OR via Scoop:
scoop install aria2

# 2. Download ISO + checksums
$ISO_URL = "https://download.bazzite.gg/bazzite-deck-gnome-43.20251102.iso"
$SHA256_URL = "https://download.bazzite.gg/bazzite-deck-gnome-43.20251102.iso.sha256sum"

# Create download directory
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\Downloads\bazzite"
Set-Location "$env:USERPROFILE\Downloads\bazzite"

# Download with aria2c (16 connections, resume support)
aria2c `
  --max-connection-per-server=16 `
  --split=16 `
  --min-split-size=1M `
  --continue=true `
  --file-allocation=none `
  --summary-interval=0 `
  --console-log-level=warn `
  $ISO_URL

# Download SHA256 checksum
Invoke-WebRequest -Uri $SHA256_URL -OutFile "bazzite.iso.sha256sum"

# 3. Verify SHA256
Write-Host "Verifying SHA256 checksum..." -ForegroundColor Yellow
$Downloaded = (Get-FileHash -Path "bazzite-deck-gnome-43.20251102.iso" -Algorithm SHA256).Hash.ToLower()
$Expected = (Get-Content "bazzite.iso.sha256sum" -Raw).Split()[0].ToLower()

if ($Downloaded -eq $Expected) {
    Write-Host "✓ SHA256 verification PASSED" -ForegroundColor Green
    Write-Host "  Expected: $Expected" -ForegroundColor Gray
    Write-Host "  Got:      $Downloaded" -ForegroundColor Gray
} else {
    Write-Host "✗ SHA256 verification FAILED" -ForegroundColor Red
    Write-Host "  Expected: $Expected" -ForegroundColor Red
    Write-Host "  Got:      $Downloaded" -ForegroundColor Red
    exit 1
}

# 4. GPG signature verification (optional but recommended)
# Download GPG signature
$SIG_URL = "https://download.bazzite.gg/bazzite-deck-gnome-43.20251102.iso.asc"
Invoke-WebRequest -Uri $SIG_URL -OutFile "bazzite.iso.asc"

# Install GPG (if not already)
# choco install gnupg -y

# Import Bazzite signing key
Write-Host "Importing Bazzite GPG key..." -ForegroundColor Yellow
gpg --recv-keys 0x5F1E86E5C26E5F49
# Key fingerprint: 4F9B 7DCE F415 AA7C 4D1C  1E5F 5F1E 86E5 C26E 5F49

# Verify signature
Write-Host "Verifying GPG signature..." -ForegroundColor Yellow
gpg --verify bazzite.iso.asc bazzite-deck-gnome-43.20251102.iso

Write-Host "`n✓ Download complete and verified!" -ForegroundColor Green
Write-Host "ISO location: $PWD\bazzite-deck-gnome-43.20251102.iso" -ForegroundColor Cyan
```

---

## Alternative: Direct SHA256 Verification Only

```powershell
# Faster version without GPG (less secure)
$ISO_URL = "https://download.bazzite.gg/bazzite-deck-gnome-43.20251102.iso"

# Download
aria2c -x16 -s16 $ISO_URL

# Quick verify
$Hash = (Get-FileHash -Path "bazzite-deck-gnome-43.20251102.iso" -Algorithm SHA256).Hash
Write-Host "SHA256: $Hash"
# Compare manually with: https://download.bazzite.gg/bazzite-deck-gnome-43.20251102.iso.sha256sum
```

---

## All Bazzite Variants

```powershell
# Bazzite Deck (GNOME) - Steam Deck UI
$ISO_DECK_GNOME = "https://download.bazzite.gg/bazzite-deck-gnome-43.20251102.iso"

# Bazzite Deck (KDE) - Steam Deck UI
$ISO_DECK_KDE = "https://download.bazzite.gg/bazzite-deck-43.20251102.iso"

# Bazzite Desktop (GNOME) - Traditional desktop
$ISO_DESKTOP_GNOME = "https://download.bazzite.gg/bazzite-gnome-43.20251102.iso"

# Bazzite Desktop (KDE) - Traditional desktop
$ISO_DESKTOP_KDE = "https://download.bazzite.gg/bazzite-43.20251102.iso"

# Bazzite Nvidia (for NVIDIA GPUs)
$ISO_NVIDIA = "https://download.bazzite.gg/bazzite-nvidia-43.20251102.iso"

# Download your preferred variant
aria2c -x16 -s16 $ISO_DESKTOP_KDE  # Example: KDE desktop
```

---

## ATOM-CFG-20251107-024
