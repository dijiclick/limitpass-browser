@echo off
REM ============================================================
REM LimitPass Browser - Installer Compiler Script
REM ============================================================
REM This script compiles the Inno Setup installer
REM 
REM Prerequisites:
REM   1. Inno Setup 6.2+ installed (https://jrsoftware.org/isinfo.php)
REM   2. Your dist\LimitPassBrowser folder ready with the browser
REM   3. mybrowser.ico icon file in project root or assets/icons/
REM ============================================================

echo.
echo ============================================================
echo    LimitPass Browser - Installer Compiler
echo ============================================================
echo.

REM Check for Inno Setup in common locations
set "ISCC="

REM Try Program Files
if exist "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe" (
    set "ISCC=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
    goto :found
)

if exist "%ProgramFiles%\Inno Setup 6\ISCC.exe" (
    set "ISCC=%ProgramFiles%\Inno Setup 6\ISCC.exe"
    goto :found
)

REM Try PATH
where ISCC.exe >nul 2>&1
if %errorlevel%==0 (
    set "ISCC=ISCC.exe"
    goto :found
)

echo [ERROR] Inno Setup not found!
echo.
echo Please install Inno Setup 6.2+ from:
echo   https://jrsoftware.org/isdl.php
echo.
echo Or add ISCC.exe to your PATH.
echo.
pause
exit /b 1

:found
echo [OK] Found Inno Setup: %ISCC%
echo.

REM Check for required files
if not exist "dist\LimitPassBrowser" (
    echo [ERROR] dist\LimitPassBrowser folder not found!
    echo.
    echo Make sure you have:
    echo   1. Run the build script first (build\master-build.ps1)
    echo   2. The dist\LimitPassBrowser folder exists with Chromium
    echo.
    pause
    exit /b 1
)

echo [OK] Found dist\LimitPassBrowser folder
echo.

REM Check for icon
if not exist "mybrowser.ico" (
    if exist "assets\icons\mybrowser.ico" (
        copy "assets\icons\mybrowser.ico" "mybrowser.ico" >nul
        echo [OK] Copied icon from assets\icons\
    ) else (
        echo [WARNING] mybrowser.ico not found - using default
        echo Creating placeholder...
        REM Create a simple placeholder - in production, use a real icon
    )
)

echo.
echo Compiling installer...
echo ============================================================
echo.

cd installer
"%ISCC%" LimitPassBrowser.iss
cd ..

if %errorlevel%==0 (
    echo.
    echo ============================================================
    echo [SUCCESS] Installer created: LimitPassBrowser_Setup.exe
    echo ============================================================
    echo.
) else (
    echo.
    echo [ERROR] Compilation failed! Check the errors above.
    echo.
)

pause

