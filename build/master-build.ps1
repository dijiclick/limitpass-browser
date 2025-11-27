param(
    [switch]$SkipDownload,
    [switch]$SkipInstaller
)

$ErrorActionPreference = 'Stop'

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
Import-Module (Join-Path $repoRoot 'scripts/common.psm1') -Force
$branding = Get-BrandingConfig -RepoRoot $repoRoot

Write-Section "Starting build for $($branding.BrowserName)"
& (Join-Path $repoRoot 'scripts/setup-folders.ps1')

# Check for chrome-win.zip first (common user download name), then fall back to chromium.zip
$zipPath = Join-Path $repoRoot 'temp/chrome-win.zip'
if (-not (Test-Path $zipPath)) {
    $zipPath = Join-Path $repoRoot 'temp/chromium.zip'
}

if (-not $SkipDownload) {
    $downloadResult = & (Join-Path $repoRoot 'scripts/download-chromium.ps1') -OutputZip $zipPath
    $zipPath = $downloadResult.ZipPath
} elseif (-not (Test-Path $zipPath)) {
    throw "SkipDownload specified but neither temp/chrome-win.zip nor temp/chromium.zip found."
}

& (Join-Path $repoRoot 'scripts/extract-chromium.ps1') -ZipPath $zipPath -Destination (Join-Path $repoRoot 'chromium')

& (Join-Path $repoRoot 'scripts/copy-extension.ps1') -TargetRoot (Join-Path $repoRoot 'chromium')

& (Join-Path $repoRoot 'scripts/apply-policies.ps1') -TargetRoot (Join-Path $repoRoot 'chromium')

$stage = & (Join-Path $repoRoot 'scripts/stage-distribution.ps1') -SourceChromium (Join-Path $repoRoot 'chromium') -DestinationRoot (Join-Path $repoRoot "dist/$($branding.BrowserName)")

if (-not $SkipInstaller) {
    & (Join-Path $repoRoot 'scripts/package-installer.ps1') -PayloadRoot $stage.PayloadRoot -OutputInstaller (Join-Path $repoRoot "dist/$($branding.OutputInstallerName)")
} else {
    Write-Host "Installer compilation skipped by flag."
}

Write-Section "Build complete"


