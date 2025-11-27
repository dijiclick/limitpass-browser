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

Write-Section "Creating self-extracting installer"

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
Write-Host "Your browser is ready to use with extensions pre-installed!"
Write-Host ""
pause
"@

$installerScript | Out-File -FilePath (Join-Path $installerTemp 'install.ps1') -Encoding UTF8

# Create a batch launcher
$batchLauncher = @"
@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
if errorlevel 1 pause
"@

$batchLauncher | Out-File -FilePath (Join-Path $installerTemp 'setup.bat') -Encoding ASCII

# Create a PowerShell self-extracting script that embeds the zip
Write-Host "Creating self-extracting PowerShell installer..."

# Compress payload
$payloadZip = Join-Path $repoRoot 'temp/payload-temp.zip'
Add-Type -AssemblyName System.IO.Compression.FileSystem
if (Test-Path $payloadZip) {
    Remove-Item $payloadZip -Force -ErrorAction SilentlyContinue
}
Start-Sleep -Milliseconds 500
[System.IO.Compression.ZipFile]::CreateFromDirectory($installerTemp, $payloadZip)

# Read zip as base64
Write-Host "Reading installer package..."
$zipBytes = [System.IO.File]::ReadAllBytes($payloadZip)
Write-Host "Encoding installer data (this may take a moment)..."
$zipBase64 = [Convert]::ToBase64String($zipBytes)
$zipSizeMB = [math]::Round($zipBytes.Length / 1MB, 2)
Write-Host "Installer data size: $zipSizeMB MB"

# Create self-extracting PowerShell script
$sfxScript = @"
# Self-extracting installer for $browserName
# This is a PowerShell script - rename to .ps1 if needed, or run directly

`$ErrorActionPreference = 'Stop'
`$tempDir = Join-Path `$env:TEMP "MyBrowserInstaller_`$([Guid]::NewGuid().ToString())"
New-Item -Path `$tempDir -ItemType Directory -Force | Out-Null

try {
    Write-Host "Extracting installer files..." -ForegroundColor Cyan
    
    # Extract zip from embedded base64
    `$zipBase64 = @'
$zipBase64
'@
    `$zipBytes = [Convert]::FromBase64String(`$zipBase64)
    `$zipPath = Join-Path `$tempDir 'installer.zip'
    [System.IO.File]::WriteAllBytes(`$zipPath, `$zipBytes)
    
    # Extract zip
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory(`$zipPath, `$tempDir)
    Remove-Item `$zipPath -Force
    
    # Run installer
    Write-Host "Starting installation..." -ForegroundColor Green
    `$installerPath = Join-Path `$tempDir 'setup.bat'
    & cmd /c "`"`$installerPath`""
    
} catch {
    Write-Host "Error during installation: `$_" -ForegroundColor Red
    pause
} finally {
    # Cleanup
    Start-Sleep -Seconds 2
    if (Test-Path `$tempDir) {
        Remove-Item `$tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
"@

# Save as .ps1 first (this is the actual installer - single file!)
$ps1Output = $OutputInstaller -replace '\.exe$', '.ps1'
$sfxScript | Out-File -FilePath $ps1Output -Encoding UTF8
Write-Host "PowerShell installer created: $ps1Output ($([math]::Round((Get-Item $ps1Output).Length / 1MB, 2)) MB)" -ForegroundColor Green

# Cleanup temp zip
Remove-Item $payloadZip -Force -ErrorAction SilentlyContinue

# Create a VBScript wrapper that makes it look like an .exe
$vbsWrapper = @"
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")
ps1File = fso.BuildPath(fso.GetParentFolderName(WScript.ScriptFullName), fso.GetBaseName(WScript.ScriptFullName) & ".ps1")
If fso.FileExists(ps1File) Then
    shell.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -File """ & ps1File & """", 1, False
Else
    MsgBox "Installer script not found: " & ps1File, vbCritical, "$browserName Installer"
End If
"@

$vbsOutput = $OutputInstaller -replace '\.exe$', '.vbs'
$vbsWrapper | Out-File -FilePath $vbsOutput -Encoding ASCII

# Also create a batch file that can be renamed to .exe (won't work but provides alternative)
$batOutput = $OutputInstaller -replace '\.exe$', '_Launcher.bat'
$batLauncher = @"
@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0$($branding.OutputInstallerName -replace '\.exe$', '.ps1')"
"@
$batLauncher | Out-File -FilePath $batOutput -Encoding ASCII

# Use IExpress to create a real .exe (if available)
$iexpressPath = Join-Path ${env:SystemRoot} "System32\iexpress.exe"
if (Test-Path $iexpressPath) {
    Write-Host "Creating IExpress self-extracting archive..."
    
    # Create file list for IExpress (must be relative paths from installerTemp)
    $listFile = Join-Path $installerTemp 'filelist.txt'
    $fileList = @()
    Get-ChildItem -Path $installerTemp -Recurse -File | ForEach-Object {
        $relativePath = $_.FullName.Substring($installerTemp.Length + 1)
        $fileList += $relativePath
    }
    $fileList | Out-File -FilePath $listFile -Encoding ASCII
    
    # Create IExpress SED file
    $sedFile = Join-Path $installerTemp 'installer.sed'
    $outputFileName = Split-Path $OutputInstaller -Leaf
    $sedContent = @"
[Version]
Class=IEXPRESS
SEDVersion=3
[Options]
PackagePurpose=InstallApp
ShowInstallProgramWindow=1
HideExtractAnimation=0
UseLongFileName=1
InsideCompressed=0
CAB_FixedSize=0
CAB_ResvCodeSigning=0
RebootMode=N
InstallPrompt=%AppName% Installer
DisplayLicense=
FinishMessage=Installation complete! Your browser is ready to use with extensions pre-installed.
TargetName=$outputFileName
FriendlyName=$browserName Installer
AppLaunched=setup.bat
LaunchAppAfterInstall=0
PostInstallCmd=
AdminQuietInstCmd=
UserQuietInstCmd=
SourceFiles=$listFile
[Strings]
AppName=$browserName Installer
FILE0="setup.bat"
"@
    
    $sedContent | Out-File -FilePath $sedFile -Encoding ASCII
    
    # Run IExpress silently
    $iexpressArgs = "/N /Q `"$sedFile`""
    Write-Host "Running IExpress (this may take a few minutes)..."
    $process = Start-Process -FilePath $iexpressPath -ArgumentList $iexpressArgs -Wait -PassThru -WindowStyle Hidden
    
    # IExpress creates the file in the same directory as the SED file
    $iexpressOutput = Join-Path (Split-Path $sedFile -Parent) $outputFileName
    if (Test-Path $iexpressOutput) {
        Copy-Item -Path $iexpressOutput -Destination $OutputInstaller -Force
        Write-Host "IExpress installer created successfully: $OutputInstaller" -ForegroundColor Green
    } else {
        Write-Warning "IExpress did not create the expected output file. Using PowerShell installer instead."
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  INSTALLER CREATED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Single-file installer ready:" -ForegroundColor Cyan
Write-Host "  $ps1Output" -ForegroundColor Yellow
Write-Host ""
Write-Host "This is a SINGLE FILE that contains everything!" -ForegroundColor Green
Write-Host "Users can:" -ForegroundColor White
Write-Host "  1. Right-click the .ps1 file" -ForegroundColor White
Write-Host "  2. Select 'Run with PowerShell'" -ForegroundColor White
Write-Host "  3. Or rename to .exe and use the VBScript launcher" -ForegroundColor White
Write-Host ""
if (Test-Path $OutputInstaller) {
    Write-Host "Also created: $OutputInstaller (IExpress .exe)" -ForegroundColor Cyan
} else {
    Write-Host "Alternative launchers created:" -ForegroundColor Cyan
    Write-Host "  - $vbsOutput (Double-click to run)" -ForegroundColor Yellow
    Write-Host "  - $batOutput (Batch launcher)" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "The .ps1 file IS the complete installer - it's self-contained!" -ForegroundColor Green

