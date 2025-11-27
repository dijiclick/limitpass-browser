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

$iss = Join-Path $repoRoot 'installer/MyBrowser.iss'
if (-not (Test-Path $iss)) {
    throw "Installer script missing: $iss"
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
    Write-Warning "Inno Setup not found. Creating self-extracting installer using IExpress..."
    & (Join-Path $PSScriptRoot 'create-sfx-installer.ps1') -PayloadRoot $PayloadRoot -OutputInstaller $OutputInstaller
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

