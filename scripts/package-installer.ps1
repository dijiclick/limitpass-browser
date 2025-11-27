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

# Try LimitPassBrowser.iss first, fall back to MyBrowser.iss for compatibility
# Try LimitPassBrowser.iss first, fall back to MyBrowser.iss for compatibility
$iss = Join-Path $repoRoot 'installer/LimitPassBrowser.iss'
if (-not (Test-Path $iss)) {
    $iss = Join-Path $repoRoot 'installer/MyBrowser.iss'
    if (-not (Test-Path $iss)) {
        throw "Installer script missing. Expected: installer/LimitPassBrowser.iss or installer/MyBrowser.iss"
    }
}

# Copy icon to root if it exists in assets (for Inno Setup)
$iconSource = Join-Path $repoRoot $branding.IconPath
$iconRoot = Join-Path $repoRoot 'mybrowser.ico'
if ((Test-Path $iconSource) -and -not (Test-Path $iconRoot)) {
    Copy-Item -Path $iconSource -Destination $iconRoot -Force -ErrorAction SilentlyContinue
}

$iscc = $branding.IsccPath
$hasInnoSetup = $false
try {
    if (Get-Command $iscc -ErrorAction SilentlyContinue) {
        $hasInnoSetup = $true
    } else {
        # Try common installation paths
        $commonPaths = @(
            "C:\Program Files (x86)\Inno Setup 6\ISCC.exe",
            "C:\Program Files\Inno Setup 6\ISCC.exe"
        )
        foreach ($path in $commonPaths) {
            if (Test-Path $path) {
                $iscc = $path
                $hasInnoSetup = $true
                break
            }
        }
    }
} catch {
    $hasInnoSetup = $false
}

if (-not $hasInnoSetup) {
    Write-Warning "Inno Setup not found. Creating self-extracting installer using PowerShell method..."
    Write-Warning "For a proper .EXE installer, install Inno Setup from: https://jrsoftware.org/isdl.php"
    # Try the new Build-Installer.ps1 first, fall back to create-sfx-installer.ps1
    $buildInstaller = Join-Path $repoRoot 'installer/Build-Installer.ps1'
    if (Test-Path $buildInstaller) {
        & $buildInstaller -SourcePath $PayloadRoot -OutputPath (Split-Path $OutputInstaller -Parent) -BrowserName $branding.InstallDirName
    } else {
        & (Join-Path $PSScriptRoot 'create-sfx-installer.ps1') -PayloadRoot $PayloadRoot -OutputInstaller $OutputInstaller
    }
    return
}

if (-not $OutputInstaller) {
    $OutputInstaller = Join-Path $repoRoot "dist/$($branding.OutputInstallerName)"
}

Write-Section "Compiling Inno Setup installer"
$defines = @(
    "/DBrowserName=$($branding.BrowserName)",
    "/DPublisherName=$($branding.PublisherName)",
    "/DCompanyName=$($branding.CompanyName)",
    "/DVersion=$($branding.Version)",
    "/DIconPath=$($branding.IconPath)",
    "/DPayloadRoot=$PayloadRoot",
    "/DOutputInstaller=$OutputInstaller",
    "/DInstallDirName=$($branding.InstallDirName)",
    "/DRepoRoot=$repoRoot"
)

& $iscc @defines $iss

if (-not (Test-Path $OutputInstaller)) {
    throw "Installer compilation did not produce $OutputInstaller"
}

Write-Host "Installer ready: $OutputInstaller"

