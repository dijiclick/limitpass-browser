param(
    [string]$TargetRoot
)

Import-Module (Join-Path $PSScriptRoot 'common.psm1') -Force
$repoRoot = Get-RepoRoot -StartPath $PSScriptRoot
$branding = Get-BrandingConfig -RepoRoot $repoRoot

$source = Join-Path $repoRoot $branding.ExtensionFolder
if (-not (Test-Path $source)) {
    throw "Extension folder '$($branding.ExtensionFolder)' not found."
}

if (-not $TargetRoot) {
    $TargetRoot = Join-Path $repoRoot 'chromium'
}

$dest = Join-Path $TargetRoot 'resources\extension'
if (Test-Path $dest) {
    Remove-Item $dest -Recurse -Force
}
Ensure-Directory -Path $dest

Write-Section "Copying extension from $source to $dest"

# Check if source has a manifest.json directly (single extension)
$rootManifest = Join-Path $source 'manifest.json'
if (Test-Path $rootManifest) {
    # Single extension at root
    Copy-Item -Path $source -Destination $dest -Recurse
    Write-Host "Copied single extension from root"
} else {
    # Multiple extensions in subfolders - copy each subfolder that has a manifest.json
    $extensionCount = 0
    Get-ChildItem -Path $source -Directory | ForEach-Object {
        $subFolder = $_.FullName
        $subManifest = Join-Path $subFolder 'manifest.json'
        if (Test-Path $subManifest) {
            $subDest = Join-Path $dest $_.Name
            Copy-Item -Path $subFolder -Destination $subDest -Recurse
            Write-Host "Copied extension: $($_.Name)"
            $extensionCount++
        }
    }
    if ($extensionCount -eq 0) {
        Write-Warning "No extensions found in $source (no manifest.json files found). Chromium will fail to load extensions."
    } else {
        Write-Host "Copied $extensionCount extension(s)"
    }
}


