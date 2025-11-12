@echo off
REM Bazzite KDE ISO Download - Batch Launcher
REM ATOM-CFG-20251112-005

echo ===============================================================
echo   Bazzite KDE ISO Download
echo   ATOM-CFG-20251112-005
echo ===============================================================
echo.

REM Create download directory
set DOWNLOAD_DIR=C:\Users\Matthew Ruhnau\Downloads\bazzite
if not exist "%DOWNLOAD_DIR%" mkdir "%DOWNLOAD_DIR%"
cd /d "%DOWNLOAD_DIR%"

echo [1/3] Download directory: %DOWNLOAD_DIR%
echo.

REM ISO URLs
set ISO_URL=https://download.bazzite.gg/bazzite-43.20251102.iso
set SHA256_URL=https://download.bazzite.gg/bazzite-43.20251102.iso.sha256sum

echo [2/3] Downloading Bazzite KDE Desktop ISO...
echo   URL: %ISO_URL%
echo   Using aria2c (16 connections)
echo.

REM Download with aria2c
aria2c --max-connection-per-server=16 --split=16 --min-split-size=1M --continue=true --file-allocation=none --summary-interval=1 --console-log-level=notice "%ISO_URL%"

if errorlevel 1 (
    echo.
    echo ERROR: Download failed
    echo.
    pause
    exit /b 1
)

echo.
echo SUCCESS: ISO downloaded!
echo.

REM Download checksum
echo [3/3] Downloading SHA256 checksum...
curl -L -o bazzite-43.20251102.iso.sha256sum "%SHA256_URL%"
echo   Checksum downloaded
echo.

REM Verify SHA256 using PowerShell (quick command)
echo Verifying SHA256 checksum...
powershell -NoProfile -Command "$h = (Get-FileHash -Path 'bazzite-43.20251102.iso' -Algorithm SHA256).Hash.ToLower(); $e = (Get-Content 'bazzite-43.20251102.iso.sha256sum' -Raw).Split()[0].ToLower(); if ($h -eq $e) { Write-Host 'SHA256 VERIFIED' -ForegroundColor Green } else { Write-Host 'SHA256 FAILED' -ForegroundColor Red }"

echo.
echo ===============================================================
echo   Download Complete!
echo   Location: %DOWNLOAD_DIR%\bazzite-43.20251102.iso
echo ===============================================================
echo.
echo Next Steps:
echo   1. Copy ISO to Ventoy USB
echo   2. Run STEP1-WINDOWS-WIPE-DISK1.ps1
echo   3. Reboot and boot from Ventoy USB
echo.

REM Log ATOM trail
echo %date% %time% ^| ATOM-CFG-20251112-005 ^| Bazzite KDE ISO downloaded >> "C:\Users\Matthew Ruhnau\kenl-atom-trail.log"

pause
