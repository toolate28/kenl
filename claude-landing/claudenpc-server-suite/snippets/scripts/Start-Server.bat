@echo off
REM ============================================================================
REM ClaudeNPC Server Suite - Server Launcher
REM Version: 1.0.0
REM Status: PRODUCTION READY - Drop-in snippet
REM 
REM This script uses Aikar's optimized JVM flags for Minecraft servers
REM Source: https://docs.papermc.io/paper/aikars-flags
REM ============================================================================

title ClaudeNPC Server - Starting...
color 0B

REM ============================================================================
REM Configuration (edit these values)
REM ============================================================================
set MIN_MEMORY=4G
set MAX_MEMORY=8G
set JAR_FILE=paper.jar

REM ============================================================================
REM Display Banner
REM ============================================================================
cls
echo.
echo ============================================================================
echo   ██████╗██╗      █████╗ ██╗   ██╗██████╗ ███████╗███╗   ██╗██████╗  ██████╗
echo  ██╔════╝██║     ██╔══██╗██║   ██║██╔══██╗██╔════╝████╗  ██║██╔══██╗██╔════╝
echo  ██║     ██║     ███████║██║   ██║██║  ██║█████╗  ██╔██╗ ██║██████╔╝██║     
echo  ██║     ██║     ██╔══██║██║   ██║██║  ██║██╔══╝  ██║╚██╗██║██╔═══╝ ██║     
echo  ╚██████╗███████╗██║  ██║╚██████╔╝██████╔╝███████╗██║ ╚████║██║     ╚██████╗
echo   ╚═════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚═╝      ╚═════╝
echo.
echo                        AI-Powered NPC Server
echo ============================================================================
echo.

REM ============================================================================
REM Pre-flight Checks
REM ============================================================================
echo [*] Running pre-flight checks...
echo.

REM Check if Java is installed
java -version >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo [ERROR] Java is not installed or not in PATH!
    echo.
    echo Please install Java 17 or higher from:
    echo https://adoptium.net/
    echo.
    pause
    exit /b 1
)

REM Check if server JAR exists
if not exist "%JAR_FILE%" (
    color 0C
    echo [ERROR] Server JAR not found: %JAR_FILE%
    echo.
    echo Please ensure the PaperMC server JAR is present in this directory.
    echo.
    pause
    exit /b 1
)

REM Check if EULA is accepted
if not exist "eula.txt" (
    echo [WARN] EULA not found. Creating default eula.txt...
    echo # By changing the setting below to TRUE you are indicating your agreement to our EULA (https://aka.ms/MinecraftEULA).> eula.txt
    echo eula=false>> eula.txt
    echo.
    echo [ERROR] Please read and accept the EULA by editing eula.txt
    echo.
    pause
    exit /b 1
)

findstr /C:"eula=false" eula.txt >nul
if %errorlevel% equ 0 (
    color 0E
    echo [ERROR] EULA not accepted!
    echo.
    echo Please accept the Minecraft EULA by changing "eula=false" to "eula=true" in eula.txt
    echo EULA: https://aka.ms/MinecraftEULA
    echo.
    pause
    exit /b 1
)

echo [OK] Java detected
echo [OK] Server JAR found: %JAR_FILE%
echo [OK] EULA accepted
echo.

REM ============================================================================
REM Memory Configuration Display
REM ============================================================================
echo [*] Memory Configuration:
echo     Min: %MIN_MEMORY%
echo     Max: %MAX_MEMORY%
echo.
echo [*] Using Aikar's optimized JVM flags
echo.

REM ============================================================================
REM Start Server with Aikar's Flags
REM ============================================================================
title ClaudeNPC Server - Running
color 0A

echo [*] Starting server...
echo.
echo ============================================================================
echo.

java -Xms%MIN_MEMORY% -Xmx%MAX_MEMORY% ^
     -XX:+UseG1GC ^
     -XX:+ParallelRefProcEnabled ^
     -XX:MaxGCPauseMillis=200 ^
     -XX:+UnlockExperimentalVMOptions ^
     -XX:+DisableExplicitGC ^
     -XX:+AlwaysPreTouch ^
     -XX:G1NewSizePercent=30 ^
     -XX:G1MaxNewSizePercent=40 ^
     -XX:G1HeapRegionSize=8M ^
     -XX:G1ReservePercent=20 ^
     -XX:G1HeapWastePercent=5 ^
     -XX:G1MixedGCCountTarget=4 ^
     -XX:InitiatingHeapOccupancyPercent=15 ^
     -XX:G1MixedGCLiveThresholdPercent=90 ^
     -XX:G1RSetUpdatingPauseTimePercent=5 ^
     -XX:SurvivorRatio=32 ^
     -XX:+PerfDisableSharedMem ^
     -XX:MaxTenuringThreshold=1 ^
     -Dusing.aikars.flags=https://mcflags.emc.gs ^
     -Daikars.new.flags=true ^
     -jar %JAR_FILE% nogui

REM ============================================================================
REM Server Stopped
REM ============================================================================
echo.
echo ============================================================================
echo [*] Server stopped
echo ============================================================================
echo.

REM Check exit code
if %errorlevel% equ 0 (
    color 0A
    echo [OK] Server shut down cleanly
) else (
    color 0C
    echo [ERROR] Server crashed or shut down with error code: %errorlevel%
    echo Check the logs folder for more information.
)

echo.
pause
