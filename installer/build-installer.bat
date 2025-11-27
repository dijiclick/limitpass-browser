@echo off
REM ============================================================
REM LimitPass Browser - One-Click Installer Builder
REM ============================================================
REM This script will:
REM   1. Try to build with Inno Setup (better, smaller installer)
REM   2. Fall back to PowerShell method if Inno Setup not found
REM ============================================================

echo.
echo ============================================================
echo    LimitPass Browser - Installer Builder
echo ============================================================
echo.

REM Check if dist folder exists
if not exist "dist\LimitPassBrowser" (
    echo [ERROR] Browser files not found!
    echo.
    echo Please run the build script first:
    echo   pwsh build\master-build.ps1
    echo.
    echo Then run this script again.
    echo.
    pause
    exit /b 1
)

echo [OK] Found browser files in dist\LimitPassBrowser
echo.

REM Try Inno Setup first
set "ISCC="

if exist "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe" (
    set "ISCC=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
)
if exist "%ProgramFiles%\Inno Setup 6\ISCC.exe" (
    set "ISCC=%ProgramFiles%\Inno Setup 6\ISCC.exe"
)

if defined ISCC (
    echo [INFO] Found Inno Setup - building professional installer...
    echo.
    
    cd installer
    "%ISCC%" LimitPassBrowser.iss
    cd ..
    
    if %errorlevel%==0 (
        echo.
        echo ============================================================
        echo [SUCCESS] Created: LimitPassBrowser_Setup.exe
        echo ============================================================
        echo.
        echo This is the installer you should distribute to users.
        echo.
        pause
        exit /b 0
    ) else (
        echo.
        echo [WARNING] Inno Setup failed. Trying PowerShell method...
        echo.
    )
)

echo [INFO] Inno Setup not found. Using PowerShell method...
echo.
echo (For a smaller, more professional installer, install Inno Setup from:
echo  https://jrsoftware.org/isdl.php)
echo.

powershell.exe -ExecutionPolicy Bypass -File "installer\Build-Installer.ps1"

echo.
pause

