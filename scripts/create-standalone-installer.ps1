param(
    [string]$PayloadRoot,
    [string]$OutputInstaller
)

Import-Module (Join-Path $PSScriptRoot 'common.psm1') -Force
$repoRoot = Get-RepoRoot -StartPath $PSScriptRoot
$branding = Get-BrandingConfig -RepoRoot $repoRoot

if (-not $PayloadRoot) {
    $PayloadRoot = Join-Path $repoRoot "dist/$($branding.BrowserName)"
}
if (-not (Test-Path $PayloadRoot)) {
    throw "Payload root not found at $PayloadRoot"
}

if (-not $OutputInstaller) {
    $OutputInstaller = Join-Path $repoRoot "dist/$($branding.OutputInstallerName)"
}

Write-Section "Creating standalone installer"

# Create temp directory for installer build
$installerTemp = Join-Path $repoRoot 'temp/installer-build'
if (Test-Path $installerTemp) {
    Remove-Item $installerTemp -Recurse -Force
}
Ensure-Directory -Path $installerTemp

# Copy payload
$installerPayload = Join-Path $installerTemp 'payload'
Write-Host "Copying payload files..."
Copy-Item -Path $PayloadRoot -Destination $installerPayload -Recurse

# Create installer PowerShell script
$browserName = $branding.BrowserName
$installDirName = $branding.InstallDirName
$browserDescription = $branding.BrowserDescription

$installerScript = @"
# $browserName Installer
`$ErrorActionPreference = 'Stop'
`$payloadPath = Join-Path `$PSScriptRoot 'payload'

# Check for admin rights
`$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not `$isAdmin) {
    Write-Host "This installer requires administrator privileges." -ForegroundColor Red
    Write-Host "Please right-click and select 'Run as administrator'"
    pause
    exit 1
}

Write-Host "Installing $browserName..." -ForegroundColor Green
Write-Host ""

# Installation paths
`$installDir = Join-Path `$env:ProgramFiles "$installDirName"
`$desktopPath = [Environment]::GetFolderPath('Desktop')
`$startMenuPath = Join-Path `$env:ProgramData "Microsoft\Windows\Start Menu\Programs"

# Remove existing installation
if (Test-Path `$installDir) {
    Write-Host "Removing existing installation..."
    Remove-Item `$installDir -Recurse -Force
}

# Copy files
Write-Host "Copying files to `$installDir..."
New-Item -Path `$installDir -ItemType Directory -Force | Out-Null
Copy-Item -Path `$payloadPath\* -Destination `$installDir -Recurse -Force

# Set permissions on policy folder
`$policyPath = Join-Path `$installDir 'policy'
if (Test-Path `$policyPath) {
    Write-Host "Securing policy folder..."
    `$acl = Get-Acl `$policyPath
    `$acl.SetAccessRuleProtection(`$true, `$false)
    `$rule = New-Object System.Security.AccessControl.FileSystemAccessRule([System.Security.Principal.WindowsIdentity]::GetCurrent().Name, "FullControl", "ContainerInherit,ObjectInherit", "None", "Deny")
    `$acl.AddAccessRule(`$rule)
    Set-Acl `$policyPath `$acl
}

# Create desktop shortcut
Write-Host "Creating desktop shortcut..."
`$wshShell = New-Object -ComObject WScript.Shell
`$desktopShortcut = `$wshShell.CreateShortcut((Join-Path `$desktopPath "$browserName.lnk"))
`$desktopShortcut.TargetPath = Join-Path `$installDir "MyBrowser.cmd"
`$desktopShortcut.WorkingDirectory = `$installDir
`$desktopShortcut.Description = "$browserDescription"
`$desktopShortcut.Save()

# Create start menu shortcut
Write-Host "Creating start menu shortcut..."
`$startMenuDir = Join-Path `$startMenuPath "$browserName"
New-Item -Path `$startMenuDir -ItemType Directory -Force | Out-Null
`$startMenuShortcut = `$wshShell.CreateShortcut((Join-Path `$startMenuDir "$browserName.lnk"))
`$startMenuShortcut.TargetPath = Join-Path `$installDir "MyBrowser.cmd"
`$startMenuShortcut.WorkingDirectory = `$installDir
`$startMenuShortcut.Description = "$browserDescription"
`$startMenuShortcut.Save()

# Create uninstaller
`$uninstallerPath = Join-Path `$installDir 'Uninstall.ps1'
`$uninstallerContent = @'
# Uninstaller for $browserName
`$ErrorActionPreference = 'Stop'
`$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not `$isAdmin) {
    Write-Host "Uninstaller requires administrator privileges." -ForegroundColor Red
    pause
    exit 1
}
`$installDir = '@INSTALL_DIR@'
`$desktopPath = [Environment]::GetFolderPath('Desktop')
`$startMenuPath = Join-Path `$env:ProgramData "Microsoft\Windows\Start Menu\Programs"
Write-Host "Uninstalling $browserName..." -ForegroundColor Yellow
`$desktopShortcut = Join-Path `$desktopPath "$browserName.lnk"
if (Test-Path `$desktopShortcut) { Remove-Item `$desktopShortcut -Force }
`$startMenuDir = Join-Path `$startMenuPath "$browserName"
if (Test-Path `$startMenuDir) { Remove-Item `$startMenuDir -Recurse -Force }
if (Test-Path `$installDir) { Remove-Item `$installDir -Recurse -Force }
Write-Host "Uninstallation complete." -ForegroundColor Green
pause
'@
`$uninstallerContent = `$uninstallerContent -replace '@INSTALL_DIR@', `$installDir
`$uninstallerContent | Out-File -FilePath `$uninstallerPath -Encoding UTF8

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host "Installed to: `$installDir"
Write-Host ""
pause
"@

$installerScript | Out-File -FilePath (Join-Path $installerTemp 'install.ps1') -Encoding UTF8

# Create a batch file launcher
$batchLauncher = @"
@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
if errorlevel 1 pause
"@

$batchLauncher | Out-File -FilePath (Join-Path $installerTemp 'setup.bat') -Encoding ASCII

# Create a zip file containing everything
Write-Host "Creating installer package..."
$zipPath = $OutputInstaller -replace '\.exe$', '_Data.zip'
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($installerTemp, $zipPath)

# Create a simple batch installer that looks for the zip in the same directory
$installerBatch = @"
@echo off
setlocal enabledelayedexpansion
title $browserName Installer

echo ========================================
echo   $browserName Installer
echo ========================================
echo.
echo This installer requires administrator privileges.
echo.
pause

REM Check for admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo ERROR: This installer requires administrator privileges.
    echo Please right-click and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

REM Find the zip file (should be in same directory as this batch)
set "BATCH_DIR=%~dp0"
set "ZIP_FILE=%BATCH_DIR%MyBrowser_Setup_Data.zip"

if not exist "%ZIP_FILE%" (
    echo ERROR: Installer data file not found!
    echo Expected: %ZIP_FILE%
    echo.
    echo Please ensure MyBrowser_Setup_Data.zip is in the same folder as this installer.
    echo.
    pause
    exit /b 1
)

set "TEMP_DIR=%TEMP%\MyBrowserInstaller_%RANDOM%%RANDOM%"
mkdir "%TEMP_DIR%" 2>nul

echo Extracting installer files...
powershell.exe -NoProfile -Command "Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('%ZIP_FILE%', '%TEMP_DIR%')"

if not exist "%TEMP_DIR%\install.ps1" (
    echo ERROR: Failed to extract installer files.
    pause
    rmdir /s /q "%TEMP_DIR%" 2>nul
    exit /b 1
)

echo Starting installation...
cd /d "%TEMP_DIR%"
call setup.bat

REM Cleanup
cd /d "%TEMP%"
timeout /t 2 /nobreak >nul
rmdir /s /q "%TEMP_DIR%" 2>nul

endlocal
exit /b 0
"@

# Save as .bat file (can be renamed to .cmd or distributed as-is)
$batOutput = $OutputInstaller -replace '\.exe$', '.bat'
$installerBatch | Out-File -FilePath $batOutput -Encoding ASCII

# Also create a VBScript wrapper that can be saved as .vbs and looks more like an installer
$vbsWrapper = @"
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")
strBatchPath = objFSO.BuildPath(objFSO.GetParentFolderName(WScript.ScriptFullName), "MyBrowser_Setup.bat")
If objFSO.FileExists(strBatchPath) Then
    objShell.Run "cmd /c """ & strBatchPath & """", 1, False
Else
    MsgBox "Installer batch file not found: " & strBatchPath, vbCritical, "$browserName Installer"
End If
Set objShell = Nothing
Set objFSO = Nothing
"@

$vbsOutput = $OutputInstaller -replace '\.exe$', '.vbs'
$vbsWrapper | Out-File -FilePath $vbsOutput -Encoding ASCII

Write-Host ""
Write-Host "Installer files created:"
Write-Host "  1. $batOutput (Main installer - run this as administrator)"
Write-Host "  2. $zipPath (Required data file - must be in same folder)"
Write-Host "  3. $vbsOutput (Optional VBScript launcher)"
Write-Host ""
Write-Host "To distribute: Include both the .bat file and the _Data.zip file together."
Write-Host "Users should run the .bat file as administrator."

Write-Host "Standalone installer created: $OutputInstaller"
Write-Host "File size: $([math]::Round((Get-Item $OutputInstaller).Length / 1MB, 2)) MB"
Write-Host ""
Write-Host "Note: This is a batch-based installer. If Windows shows a warning,"
Write-Host "you may need to rename it to .bat or .cmd, or right-click and"
Write-Host "select 'Run as administrator'."
