param(
    [string]$TargetRoot
)

Import-Module (Join-Path $PSScriptRoot 'common.psm1') -Force
$repoRoot = Get-RepoRoot -StartPath $PSScriptRoot
$branding = Get-BrandingConfig -RepoRoot $repoRoot

if (-not $TargetRoot) {
    $TargetRoot = Join-Path $repoRoot 'chromium'
}

$policySource = Join-Path $repoRoot 'config/policies'
$policyDest = Join-Path $TargetRoot 'policy'

Write-Section "Copying Chromium policy files"
if (Test-Path $policyDest) {
    Remove-Item $policyDest -Recurse -Force
}
Copy-Item -Path $policySource -Destination $policyDest -Recurse

# Optional templating
$templatePath = Join-Path $repoRoot 'config/policies/managed/policy.template.json'
$managedPath = Join-Path $policyDest 'managed/policy.json'
if (Test-Path $templatePath) {
    $template = Get-Content $templatePath -Raw
    $devToolsValue = if ($branding.DisableDevTools) { '2' } else { '1' }
    $webStoreValue = if ($branding.BlockChromeWebStore) { '0' } else { '1' }
    $values = @{
        '{{ExtensionId}}'            = $branding.ExtensionId
        '{{DeveloperToolsAvailability}}' = $devToolsValue
        '{{ChromeWebStoreEnabled}}'  = $webStoreValue
    }
    foreach ($key in $values.Keys) {
        $template = $template -replace [Regex]::Escape($key), $values[$key]
    }
    $json = $template | ConvertFrom-Json
    if (-not $branding.BlockExtensionsPage) {
        $json.URLBlocklist = @($json.URLBlocklist | Where-Object { $_ -ne 'chrome://extensions' })
    }
    if (-not $branding.BlockChromeWebStore) {
        $json.URLBlocklist = @($json.URLBlocklist | Where-Object { $_ -notmatch 'chromewebstore' })
    }
    $extensionIds = @()
    if ($branding.ExtensionId) {
        $extensionIds += $branding.ExtensionId
    }
    if ($branding.AdditionalExtensionIds) {
        $extensionIds += $branding.AdditionalExtensionIds
    }
    foreach ($extId in $extensionIds) {
        if (-not $extId) { continue }
        $hasKey = $json.ExtensionSettings.PSObject.Properties.Name -contains $extId
        if (-not $hasKey) {
            $json.ExtensionSettings | Add-Member -NotePropertyName $extId -NotePropertyValue (@{ installation_mode = 'allowed' }) -Force
        }
        $json.ExtensionSettings.$extId.incognito_mode = 'enabled'
        if ($json.ExtensionInstallAllowlist -notcontains $extId) {
            $json.ExtensionInstallAllowlist += $extId
        }
    }
    $template = $json | ConvertTo-Json -Depth 10
    $managedDir = Split-Path $managedPath -Parent
    Ensure-Directory -Path $managedDir
    $template | Out-File -FilePath $managedPath -Encoding UTF8 -Force
}

Write-Host "Policies staged at $policyDest"

