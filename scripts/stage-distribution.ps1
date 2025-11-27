param(
    [string]$SourceChromium,
    [string]$DestinationRoot
)

Import-Module (Join-Path $PSScriptRoot 'common.psm1') -Force
$repoRoot = Get-RepoRoot -StartPath $PSScriptRoot
$branding = Get-BrandingConfig -RepoRoot $repoRoot

if (-not $SourceChromium) {
    $SourceChromium = Join-Path $repoRoot 'chromium'
}
if (-not (Test-Path $SourceChromium)) {
    throw "Chromium tree not found at $SourceChromium"
}

if (-not $DestinationRoot) {
    $DestinationRoot = Join-Path $repoRoot "dist/$($branding.BrowserName)"
}

if (Test-Path $DestinationRoot) {
    Remove-Item $DestinationRoot -Recurse -Force
}
Ensure-Directory -Path $DestinationRoot

Write-Section "Staging Chromium payload"
Copy-Item -Path (Join-Path $SourceChromium '*') -Destination $DestinationRoot -Recurse

# Copy config and launcher assets
$configDir = Join-Path $DestinationRoot 'config'
Ensure-Directory -Path $configDir
Copy-Item -Path (Join-Path $repoRoot 'config/chromium-flags.txt') -Destination $configDir -Force

Copy-Item -Path (Join-Path $repoRoot 'src/launcher/MyBrowser.cmd') -Destination (Join-Path $DestinationRoot ("{0}.cmd" -f $branding.BrowserName)) -Force

$iconSource = Join-Path $repoRoot $branding.IconPath
if (Test-Path $iconSource) {
    $iconDest = Join-Path $DestinationRoot (Split-Path $branding.IconPath -Leaf)
    Copy-Item -Path $iconSource -Destination $iconDest -Force
}

Write-Host "Payload staged at $DestinationRoot"

return @{
    PayloadRoot = $DestinationRoot
}

