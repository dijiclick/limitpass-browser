param(
    [string]$OutputZip,
    [string]$Platform = 'Win_x64'
)

Import-Module (Join-Path $PSScriptRoot 'common.psm1') -Force
$repoRoot = Get-RepoRoot -StartPath $PSScriptRoot
$tempDir = Join-Path $repoRoot 'temp'
Ensure-Directory -Path $tempDir

if (-not $OutputZip) {
    $OutputZip = Join-Path $tempDir 'chromium.zip'
}

Write-Section "Fetching latest Chromium snapshot metadata"
$snapshot = Get-LatestChromiumSnapshot -Platform $Platform
$url = $snapshot.Url
Write-Host "Revision: $($snapshot.Revision)"
Write-Host "URL: $url"

Write-Section "Downloading Chromium to $OutputZip"
Invoke-WebRequest -Uri $url -OutFile $OutputZip -UseBasicParsing

Write-Host "Downloaded Chromium build $($snapshot.Revision) to $OutputZip"

return @{
    ZipPath = $OutputZip
    Revision = $snapshot.Revision
    Url = $url
}



