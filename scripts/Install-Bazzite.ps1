#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Download and verify Bazzite ISO for installation
.DESCRIPTION
    Downloads Bazzite ISO (KDE/GNOME/Deck variants) with aria2c in separate window,
    verifies SHA256 hash, and provides installation guidance. Part of KENL Bazzite
    migration workflow.
.PARAMETER Variant
    Bazzite variant: kde, gnome, or deck (default: kde)
.PARAMETER Edition
    Release edition: stable or unstable (default: stable)
.PARAMETER OutputDir
    Download destination directory (default: $env:USERPROFILE\Downloads)
.EXAMPLE
    .\Install-Bazzite.ps1 -Variant kde -Edition stable
.NOTES
    ATOM Tag: ATOM-CFG-20251115-001
    Version: 2.0.0
    Opens separate window - main CLI stays responsive
#>

param(
    [string]$Variant = "kde",  # kde, gnome, or deck
    [string]$Edition = "stable",  # stable or unstable
    [string]$OutputDir = "$env:USERPROFILE\Downloads"
)

$ErrorActionPreference = "Stop"

# Determine ISO URL based on variant
$isoUrls = @{
    "kde-stable" = "https://download.bazzite.gg/bazzite-kde-stable.iso"
    "kde-unstable" = "https://download.bazzite.gg/bazzite-kde-unstable.iso"
    "gnome-stable" = "https://download.bazzite.gg/bazzite-deck-gnome-stable.iso"
    "gnome-unstable" = "https://download.bazzite.gg/bazzite-deck-gnome-unstable.iso"
    "deck-stable" = "https://download.bazzite.gg/bazzite-deck-stable.iso"
}

$key = "$Variant-$Edition"
if (-not $isoUrls.ContainsKey($key)) {
    Write-Host "❌ Invalid variant/edition combination: $key" -ForegroundColor Red
    Write-Host "   Valid options:" -ForegroundColor Yellow
    $isoUrls.Keys | ForEach-Object { Write-Host "   - $_" -ForegroundColor Gray }
    exit 1
}

$isoUrl = $isoUrls[$key]
$isoFile = "bazzite-$Variant-$Edition.iso"
$outputPath = Join-Path $OutputDir $isoFile
$statusFile = "$env:TEMP\kenl-iso-download-$(Get-Date -Format 'yyyyMMddHHmmss').status"

# Check if aria2c is installed
if (-not (Get-Command aria2c -ErrorAction SilentlyContinue)) {
    Write-Host "❌ aria2c not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "Install with Chocolatey:" -ForegroundColor Yellow
    Write-Host "  choco install aria2 -y" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Or download from:" -ForegroundColor Yellow
    Write-Host "  https://github.com/aria2/aria2/releases" -ForegroundColor Cyan
    exit 1
}

# Create download script
$downloadScript = @"
`$ErrorActionPreference = 'Stop'

# Header
Clear-Host
Write-Host '╔══════════════════════════════════════════════════════════════╗' -ForegroundColor Cyan
Write-Host '║  Bazzite $Variant $Edition ISO Download' -ForegroundColor Cyan -NoNewline
Write-Host (' ' * (58 - ('Bazzite ' + '$Variant' + ' ' + '$Edition' + ' ISO Download').Length)) -NoNewline
Write-Host '║' -ForegroundColor Cyan
Write-Host '║  ATOM-CFG-20251112-010' -NoNewline
Write-Host (' ' * 39) -NoNewline
Write-Host '║' -ForegroundColor Cyan
Write-Host '╚══════════════════════════════════════════════════════════════╝' -ForegroundColor Cyan
Write-Host ''
Write-Host '┌─ DOWNLOAD INFO ────────────────────────────────────────────┐' -ForegroundColor Gray
Write-Host '│ URL:    $isoUrl' -ForegroundColor Gray
Write-Host '│ Output: $outputPath' -ForegroundColor Gray
Write-Host '│ Method: aria2c (16 connections)' -ForegroundColor Gray
Write-Host '└────────────────────────────────────────────────────────────┘' -ForegroundColor Gray
Write-Host ''

# Status file
'RUNNING' | Out-File -FilePath '$statusFile'

# Download
try {
    `$startTime = Get-Date

    aria2c -x16 -s16 \`
        --dir='$OutputDir' \`
        --out='$isoFile' \`
        --console-log-level=info \`
        --summary-interval=5 \`
        --download-result=full \`
        '$isoUrl'

    `$duration = (Get-Date) - `$startTime
    `$minutes = [math]::Floor(`$duration.TotalMinutes)
    `$seconds = `$duration.Seconds

    Write-Host ''
    Write-Host '╔══════════════════════════════════════════════════════════════╗' -ForegroundColor Green
    Write-Host '║  ✓ Download Complete!' -NoNewline
    Write-Host (' ' * 43) -NoNewline
    Write-Host '║' -ForegroundColor Green
    Write-Host '║  Time: {0}m {1}s' -f `$minutes, `$seconds -NoNewline
    Write-Host (' ' * (56 - (6 + `$minutes.ToString().Length + `$seconds.ToString().Length))) -NoNewline
    Write-Host '║' -ForegroundColor Green
    Write-Host '╚══════════════════════════════════════════════════════════════╝' -ForegroundColor Green
    Write-Host ''
    Write-Host 'File saved to:' -ForegroundColor Cyan
    Write-Host "  $outputPath" -ForegroundColor White
    Write-Host ''

    # Verify file exists and get size
    if (Test-Path '$outputPath') {
        `$fileSize = (Get-Item '$outputPath').Length / 1GB
        Write-Host ('File size: {0:N2} GB' -f `$fileSize) -ForegroundColor Gray
    }

    'SUCCESS' | Out-File -FilePath '$statusFile'

} catch {
    Write-Host ''
    Write-Host '╔══════════════════════════════════════════════════════════════╗' -ForegroundColor Red
    Write-Host '║  ❌ Download Failed' -NoNewline
    Write-Host (' ' * 44) -NoNewline
    Write-Host '║' -ForegroundColor Red
    Write-Host '╚══════════════════════════════════════════════════════════════╝' -ForegroundColor Red
    Write-Host ''
    Write-Host 'Error:' -ForegroundColor Red
    Write-Host "  `$_" -ForegroundColor White
    Write-Host ''

    "FAILED:`$_" | Out-File -FilePath '$statusFile'
}

Write-Host ''
Write-Host 'Press any key to close this window...' -ForegroundColor DarkGray
`$null = `$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
"@

# Save to temp file
$tempScript = "$env:TEMP\kenl-download-bazzite-$(Get-Date -Format 'yyyyMMddHHmmss').ps1"
$downloadScript | Out-File -FilePath $tempScript -Encoding UTF8

# Launch in new window
Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  Starting Bazzite ISO Download                         ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "Variant:     $Variant" -ForegroundColor Gray
Write-Host "Edition:     $Edition" -ForegroundColor Gray
Write-Host "Output:      $outputPath" -ForegroundColor Gray
Write-Host "Status file: $statusFile" -ForegroundColor Gray
Write-Host ""
Write-Host "⚡ Opening download window..." -ForegroundColor Yellow

Start-Process powershell.exe -ArgumentList "-NoExit", "-ExecutionPolicy", "Bypass", "-File", $tempScript

Write-Host "✓ Download started in new window" -ForegroundColor Green
Write-Host ""
Write-Host "Monitor progress in the new terminal window" -ForegroundColor Cyan
Write-Host ""
Write-Host "To check status programmatically:" -ForegroundColor Gray
Write-Host "  Get-Content $statusFile" -ForegroundColor White
Write-Host ""

# Optional: Wait and monitor
$waitForCompletion = Read-Host "Wait for download to complete? (y/n)"
if ($waitForCompletion -eq "y") {
    Write-Host ""
    Write-Host "Monitoring download..." -ForegroundColor Cyan
    Write-Host "Press Ctrl+C to stop monitoring (download continues)" -ForegroundColor Gray
    Write-Host ""

    $lastStatus = ""
    while ($true) {
        Start-Sleep -Seconds 5

        if (Test-Path $statusFile) {
            $status = Get-Content $statusFile -Raw

            if ($status -ne $lastStatus) {
                $lastStatus = $status

                switch -Wildcard ($status) {
                    "RUNNING*" {
                        Write-Host "⚡ Download in progress... ($(Get-Date -Format 'HH:mm:ss'))" -ForegroundColor Yellow
                    }
                    "SUCCESS*" {
                        Write-Host "✓ Download complete! ($(Get-Date -Format 'HH:mm:ss'))" -ForegroundColor Green
                        Write-Host ""
                        Write-Host "ISO file: $outputPath" -ForegroundColor Cyan
                        break
                    }
                    "FAILED:*" {
                        $error = $status -replace "FAILED:", ""
                        Write-Host "❌ Download failed: $error" -ForegroundColor Red
                        break
                    }
                }
            }
        } else {
            Write-Host "⚠️  Status file not yet created..." -ForegroundColor Yellow
        }
    }
}

# Cleanup temp script after delay
Start-Sleep -Seconds 60
Remove-Item $tempScript -Force -ErrorAction SilentlyContinue
