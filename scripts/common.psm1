function Get-RepoRoot {
    param(
        [string]$StartPath
    )
    $path = if ($StartPath) { Resolve-Path -LiteralPath $StartPath } else { Split-Path -Parent $PSScriptRoot }
    while ($path -and -not (Test-Path (Join-Path $path 'config/branding.psd1'))) {
        $parent = Split-Path -Parent $path
        if ($parent -eq $path) { break }
        $path = $parent
    }
    if (-not $path) {
        throw "Unable to locate repository root (branding.psd1 not found)."
    }
    return $path
}

function Get-BrandingConfig {
    param(
        [string]$RepoRoot = (Get-RepoRoot -StartPath $PSScriptRoot)
    )
    $brandingPath = Join-Path $RepoRoot 'config/branding.psd1'
    if (-not (Test-Path $brandingPath)) {
        throw "Branding configuration missing at $brandingPath"
    }
    return Import-PowerShellDataFile -Path $brandingPath
}

function Ensure-Directory {
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

function Write-Section {
    param([string]$Message)
    Write-Host ''
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Get-LatestChromiumSnapshot {
    param(
        [string]$Platform = 'Win_x64'
    )
    $base = "https://storage.googleapis.com/chromium-browser-snapshots/$Platform"
    $revision = (Invoke-WebRequest -Uri "$base/LAST_CHANGE" -UseBasicParsing).Content.Trim()
    $zipUrl = "$base/$revision/chrome-win.zip"
    return @{
        Revision = $revision
        Url      = $zipUrl
    }
}

Export-ModuleMember -Function *-*



