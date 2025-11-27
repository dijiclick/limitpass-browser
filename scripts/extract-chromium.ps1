param(
    [Parameter(Mandatory)][string]$ZipPath,
    [string]$Destination
)

Import-Module (Join-Path $PSScriptRoot 'common.psm1') -Force
$repoRoot = Get-RepoRoot -StartPath $PSScriptRoot
if (-not $Destination) {
    $Destination = Join-Path $repoRoot 'chromium'
}

Ensure-Directory -Path $Destination

Write-Section "Extracting Chromium archive"
if (-not (Test-Path $ZipPath)) {
    throw "Zip archive not found: $ZipPath"
}

# Check file size (Chromium builds are typically 200-300MB)
$fileInfo = Get-Item $ZipPath
if ($fileInfo.Length -lt 100MB) {
    Write-Warning "Chromium zip file is unusually small ($([math]::Round($fileInfo.Length/1MB, 2))MB). Expected 200-300MB. File may be incomplete."
}

$tempExtract = Join-Path $repoRoot 'temp/chromium-extract'
if (Test-Path $tempExtract) {
    Remove-Item $tempExtract -Recurse -Force
}
Ensure-Directory -Path $tempExtract

# Try using .NET ZipFile class first (more robust)
try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipPath, $tempExtract)
} catch {
    Write-Warning "System.IO.Compression.ZipFile failed, trying Expand-Archive: $_"
    try {
        Expand-Archive -Path $ZipPath -DestinationPath $tempExtract -Force
    } catch {
        throw "Failed to extract Chromium archive. The file may be corrupted or incomplete. Error: $_"
    }
}

$source = Join-Path $tempExtract 'chrome-win'
if (-not (Test-Path $source)) {
    throw "Expected chrome-win folder inside archive."
}

if (Test-Path $Destination) {
    Remove-Item $Destination -Recurse -Force
}
Move-Item -Path $source -Destination $Destination

Write-Host "Chromium extracted to $Destination"


