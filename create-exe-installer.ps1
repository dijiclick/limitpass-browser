# Script to create .EXE installer using Inno Setup
# Run this after installing Inno Setup

param(
    [switch]$SkipBuild
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  LimitPass Browser - EXE Installer Builder" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Check for Inno Setup
$iscc = $null
$paths = @(
    "C:\Program Files (x86)\Inno Setup 6\ISCC.exe",
    "C:\Program Files\Inno Setup 6\ISCC.exe"
)

foreach ($path in $paths) {
    if (Test-Path $path) {
        $iscc = $path
        Write-Host "[OK] Found Inno Setup: $iscc" -ForegroundColor Green
        break
    }
}

if (-not $iscc) {
    Write-Host "[ERROR] Inno Setup not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Inno Setup 6.2+ from:" -ForegroundColor Yellow
    Write-Host "  https://jrsoftware.org/isdl.php" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "After installation, run this script again." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# Check if browser is built
if (-not $SkipBuild) {
    if (-not (Test-Path "dist\LimitPassBrowser")) {
        Write-Host "[INFO] Browser not built. Running build script..." -ForegroundColor Yellow
        Write-Host ""
        & powershell -NoProfile -ExecutionPolicy Bypass -File "build\master-build.ps1" -SkipDownload -SkipInstaller
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[ERROR] Build failed!" -ForegroundColor Red
            exit 1
        }
    }
}

if (-not (Test-Path "dist\LimitPassBrowser")) {
    Write-Host "[ERROR] Browser distribution not found: dist\LimitPassBrowser" -ForegroundColor Red
    Write-Host "Please run: pwsh build\master-build.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Browser distribution found" -ForegroundColor Green
Write-Host ""

# Check for icon
$iconPath = "assets\icons\mybrowser.ico"
if (-not (Test-Path $iconPath)) {
    $iconPath = "mybrowser.ico"
    if (-not (Test-Path $iconPath)) {
        Write-Host "[WARNING] Icon file not found. Installer will use default icon." -ForegroundColor Yellow
        Write-Host "  Place your icon at: assets\icons\mybrowser.ico or mybrowser.ico" -ForegroundColor Gray
        Write-Host ""
    }
}

# Compile installer
Write-Host "[INFO] Compiling installer with Inno Setup..." -ForegroundColor Cyan
Write-Host ""

$issFile = "installer\LimitPassBrowser.iss"
$outputDir = "dist"

# Set environment variables for Inno Setup
$env:IconPath = $iconPath

# Compile
& $iscc $issFile /O"$outputDir"

if ($LASTEXITCODE -eq 0) {
    $exeFile = Join-Path $outputDir "LimitPassBrowser_Setup.exe"
    if (Test-Path $exeFile) {
        $fileSize = (Get-Item $exeFile).Length / 1MB
        Write-Host ""
        Write-Host "============================================" -ForegroundColor Green
        Write-Host "  SUCCESS! Installer Created" -ForegroundColor Green
        Write-Host "============================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Installer: $exeFile" -ForegroundColor Cyan
        Write-Host "Size: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "This is a proper Windows .EXE installer ready for distribution!" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host "[WARNING] Compilation succeeded but installer file not found at expected location" -ForegroundColor Yellow
    }
} else {
    Write-Host ""
    Write-Host "[ERROR] Compilation failed! Check the errors above." -ForegroundColor Red
    Write-Host ""
    exit 1
}

