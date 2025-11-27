param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)

Import-Module (Join-Path $PSScriptRoot 'common.psm1') -Force
$root = Get-RepoRoot -StartPath $RepoRoot
$paths = @(
    'chromium',
    'dist',
    'temp',
    'assets/icons',
    'my-extension',
    'resources',
    'src/launcher'
)

foreach ($relative in $paths) {
    $target = Join-Path $root $relative
    Ensure-Directory -Path $target
    Write-Host "Ensured $target"
}



