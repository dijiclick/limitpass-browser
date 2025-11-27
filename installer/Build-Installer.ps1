<#
.SYNOPSIS
    Creates a self-extracting installer for LimitPass Browser
    
.DESCRIPTION
    This script creates a Windows installer without requiring Inno Setup.
    It packages everything into a single executable that extracts and installs.
    
.NOTES
    Run this in your project root folder where dist\LimitPassBrowser exists
#>

param(
    [string]$BrowserName = "LimitPassBrowser",
    [string]$SourcePath = "dist\LimitPassBrowser",
    [string]$OutputPath = "dist",
    [string]$Version = "1.0.0",
    [string]$Publisher = "DijiClick"
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  LimitPass Browser - Installer Builder" -ForegroundColor Cyan  
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Verify source exists
if (-not (Test-Path $SourcePath)) {
    Write-Host "[ERROR] Source folder not found: $SourcePath" -ForegroundColor Red
    Write-Host "Run your build script first, then try again." -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Found source: $SourcePath" -ForegroundColor Green

# Create temp folder for installer package
$TempDir = Join-Path $env:TEMP "LimitPassInstaller_$(Get-Random)"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

Write-Host "[INFO] Creating installer package..." -ForegroundColor Yellow

# Create the installation script that will run on target machine
$InstallScript = @'
# LimitPass Browser Installation Script
# This runs when the user executes the installer

param(
    [switch]$Silent,
    [string]$InstallPath = "$env:ProgramFiles\LimitPassBrowser"
)

$ErrorActionPreference = "Stop"

# Check for admin rights
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "Administrator privileges required. Requesting elevation..." -ForegroundColor Yellow
    
    # Re-launch as admin
    $scriptPath = $MyInvocation.MyCommand.Path
    Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    exit
}

if (-not $Silent) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  LimitPass Browser Installer" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "This will install LimitPass Browser to:"
    Write-Host "  $InstallPath" -ForegroundColor Green
    Write-Host ""
    $confirm = Read-Host "Continue? (Y/N)"
    if ($confirm -notmatch '^[Yy]') {
        Write-Host "Installation cancelled." -ForegroundColor Yellow
        exit 0
    }
}

Write-Host ""
Write-Host "[1/5] Creating installation directory..." -ForegroundColor Cyan

# Create install directory
if (Test-Path $InstallPath) {
    Remove-Item -Path $InstallPath -Recurse -Force
}
New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null

Write-Host "[2/5] Copying browser files..." -ForegroundColor Cyan

# Get script directory (where extracted files are)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceFiles = Join-Path $ScriptDir "browser"

# Copy all files
Copy-Item -Path "$SourceFiles\*" -Destination $InstallPath -Recurse -Force

Write-Host "[3/5] Setting security policies..." -ForegroundColor Cyan

# Lock down policy folder
$PolicyPath = Join-Path $InstallPath "policy"
if (Test-Path $PolicyPath) {
    $acl = Get-Acl $PolicyPath
    $acl.SetAccessRuleProtection($true, $false)
    
    # Grant Administrators full control
    $adminRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        "Administrators", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
    )
    $acl.AddAccessRule($adminRule)
    
    # Grant SYSTEM full control
    $systemRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        "SYSTEM", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
    )
    $acl.AddAccessRule($systemRule)
    
    # Grant Users read/execute only
    $usersRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        "Users", "ReadAndExecute", "ContainerInherit,ObjectInherit", "None", "Allow"
    )
    $acl.AddAccessRule($usersRule)
    
    Set-Acl -Path $PolicyPath -AclObject $acl
    
    # Apply to all subdirectories
    Get-ChildItem -Path $PolicyPath -Recurse -Directory | ForEach-Object {
        Set-Acl -Path $_.FullName -AclObject $acl
    }
}

Write-Host "[4/5] Creating shortcuts..." -ForegroundColor Cyan

# Create shortcuts using WScript.Shell
$WshShell = New-Object -ComObject WScript.Shell

# Desktop shortcut
$DesktopPath = [Environment]::GetFolderPath("Desktop")
$ShortcutPath = Join-Path $DesktopPath "LimitPass Browser.lnk"
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = Join-Path $InstallPath "LimitPassBrowser.cmd"
$Shortcut.WorkingDirectory = $InstallPath
$IconPath = Join-Path $InstallPath "mybrowser.ico"
if (Test-Path $IconPath) {
    $Shortcut.IconLocation = $IconPath
}
$Shortcut.Save()

# Start Menu shortcut
$StartMenuPath = [Environment]::GetFolderPath("CommonPrograms")
$StartMenuFolder = Join-Path $StartMenuPath "LimitPass Browser"
New-Item -ItemType Directory -Path $StartMenuFolder -Force | Out-Null

$ShortcutPath = Join-Path $StartMenuFolder "LimitPass Browser.lnk"
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = Join-Path $InstallPath "LimitPassBrowser.cmd"
$Shortcut.WorkingDirectory = $InstallPath
if (Test-Path $IconPath) {
    $Shortcut.IconLocation = $IconPath
}
$Shortcut.Save()

# Uninstall shortcut
$UninstallShortcut = Join-Path $StartMenuFolder "Uninstall.lnk"
$Shortcut = $WshShell.CreateShortcut($UninstallShortcut)
$Shortcut.TargetPath = Join-Path $InstallPath "uninstall.cmd"
$Shortcut.Save()

Write-Host "[5/5] Registering uninstaller..." -ForegroundColor Cyan

# Create uninstall script
$UninstallScript = @"
@echo off
echo Uninstalling LimitPass Browser...
echo.

REM Remove shortcuts
del /f /q "%USERPROFILE%\Desktop\LimitPass Browser.lnk" 2>nul
rmdir /s /q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\LimitPass Browser" 2>nul

REM Remove registry entry
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\LimitPassBrowser" /f 2>nul

REM Remove install folder (delayed to allow this script to finish)
echo @echo off > "%TEMP%\cleanup.bat"
echo timeout /t 2 /nobreak ^>nul >> "%TEMP%\cleanup.bat"
echo rmdir /s /q "$InstallPath" >> "%TEMP%\cleanup.bat"
echo del /f /q "%TEMP%\cleanup.bat" >> "%TEMP%\cleanup.bat"

start /min cmd /c "%TEMP%\cleanup.bat"
echo.
echo LimitPass Browser has been uninstalled.
pause
"@

$UninstallScript | Out-File -FilePath (Join-Path $InstallPath "uninstall.cmd") -Encoding ASCII

# Register in Windows Apps & Features
$UninstallRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\LimitPassBrowser"
New-Item -Path $UninstallRegPath -Force | Out-Null
Set-ItemProperty -Path $UninstallRegPath -Name "DisplayName" -Value "LimitPass Browser"
Set-ItemProperty -Path $UninstallRegPath -Name "DisplayVersion" -Value "1.0.0"
Set-ItemProperty -Path $UninstallRegPath -Name "Publisher" -Value "DijiClick"
Set-ItemProperty -Path $UninstallRegPath -Name "InstallLocation" -Value $InstallPath
Set-ItemProperty -Path $UninstallRegPath -Name "UninstallString" -Value (Join-Path $InstallPath "uninstall.cmd")
Set-ItemProperty -Path $UninstallRegPath -Name "NoModify" -Value 1 -Type DWord
Set-ItemProperty -Path $UninstallRegPath -Name "NoRepair" -Value 1 -Type DWord

if (Test-Path (Join-Path $InstallPath "mybrowser.ico")) {
    Set-ItemProperty -Path $UninstallRegPath -Name "DisplayIcon" -Value (Join-Path $InstallPath "mybrowser.ico")
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "LimitPass Browser has been installed to:"
Write-Host "  $InstallPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "You can now launch it from:"
Write-Host "  - Desktop shortcut"
Write-Host "  - Start Menu > LimitPass Browser"
Write-Host ""

if (-not $Silent) {
    $launch = Read-Host "Launch LimitPass Browser now? (Y/N)"
    if ($launch -match '^[Yy]') {
        Start-Process (Join-Path $InstallPath "LimitPassBrowser.cmd")
    }
}
'@

# Save install script
$InstallScriptPath = Join-Path $TempDir "install.ps1"
$InstallScript | Out-File -FilePath $InstallScriptPath -Encoding UTF8

# Create browser folder in temp
$BrowserTempPath = Join-Path $TempDir "browser"
New-Item -ItemType Directory -Path $BrowserTempPath -Force | Out-Null

Write-Host "[INFO] Copying browser files to package..." -ForegroundColor Yellow
Copy-Item -Path "$SourcePath\*" -Destination $BrowserTempPath -Recurse -Force

Write-Host "[INFO] Creating ZIP archive..." -ForegroundColor Yellow

# Create ZIP file
$ZipPath = Join-Path $TempDir "payload.zip"
Compress-Archive -Path "$TempDir\*" -DestinationPath $ZipPath -Force

# Read ZIP as base64
$ZipBytes = [System.IO.File]::ReadAllBytes($ZipPath)
$ZipBase64 = [System.Convert]::ToBase64String($ZipBytes)

Write-Host "[INFO] Generating self-extracting installer..." -ForegroundColor Yellow

# Create the self-extracting PowerShell script
$SfxScript = @'
# LimitPass Browser Self-Extracting Installer
# Generated: {GENERATION_DATE}

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "Extracting LimitPass Browser installer..." -ForegroundColor Cyan
Write-Host ""

# Decode and extract
$TempDir = Join-Path $env:TEMP "LimitPassInstall_$(Get-Random)"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

try {
    # Embedded payload (base64 encoded ZIP)
    $payload = @"
{PAYLOAD_BASE64}
"@

    $zipPath = Join-Path $TempDir "installer.zip"
    [System.IO.File]::WriteAllBytes($zipPath, [System.Convert]::FromBase64String($payload))
    
    # Extract
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $TempDir)
    
    # Run installer
    $installScript = Join-Path $TempDir "install.ps1"
    & $installScript
}
finally {
    # Cleanup handled by install script
}
'@

# Replace placeholders
$SfxScript = $SfxScript -replace '{GENERATION_DATE}', (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
$SfxScript = $SfxScript -replace '{PAYLOAD_BASE64}', $ZipBase64

# Save the SFX installer
$OutputFile = Join-Path $OutputPath "$BrowserName`_Setup.ps1"
$SfxScript | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host ""
Write-Host "[INFO] Creating launcher scripts..." -ForegroundColor Yellow

# Create a batch file launcher (easier to double-click)
$BatchLauncher = @"
@echo off
PowerShell.exe -ExecutionPolicy Bypass -File "%~dp0$BrowserName`_Setup.ps1"
"@
$BatchLauncher | Out-File -FilePath (Join-Path $OutputPath "$BrowserName`_Setup.bat") -Encoding ASCII

# Create VBS launcher (runs hidden, no console window)
$VbsLauncher = @"
Set objShell = CreateObject("WScript.Shell")
objShell.Run "powershell.exe -ExecutionPolicy Bypass -WindowStyle Normal -File ""%~dp0$BrowserName`_Setup.ps1""", 1, False
"@
$VbsLauncher | Out-File -FilePath (Join-Path $OutputPath "$BrowserName`_Setup.vbs") -Encoding ASCII

# Cleanup temp
Remove-Item -Path $TempDir -Recurse -Force

# Get file size
$FileSize = (Get-Item $OutputFile).Length / 1MB

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  Installer Created Successfully!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Output files:" -ForegroundColor Cyan
Write-Host "  $OutputFile" -ForegroundColor White
Write-Host "  $($BrowserName)_Setup.bat (batch launcher)" -ForegroundColor White
Write-Host "  $($BrowserName)_Setup.vbs (VBS launcher)" -ForegroundColor White
Write-Host ""
Write-Host "Size: $([math]::Round($FileSize, 2)) MB" -ForegroundColor Yellow
Write-Host ""
Write-Host "To install, run any of these:"
Write-Host "  - Double-click $($BrowserName)_Setup.bat"
Write-Host "  - Right-click $($BrowserName)_Setup.ps1 > Run with PowerShell"
Write-Host ""

