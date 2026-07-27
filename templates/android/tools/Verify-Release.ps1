[CmdletBinding()]
param(
    [string]$ManifestPath = (Join-Path $PSScriptRoot '../release-manifest.json'),
    [string]$AssetDirectory = (Split-Path -Parent $ManifestPath),
    [string]$ApkSignerPath = 'apksigner'
)

$ErrorActionPreference = 'Stop'
$manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
if ($manifest.platform -ne 'android') { throw 'Manifest platform must be android.' }
foreach ($asset in $manifest.assets) {
    $path = Join-Path $AssetDirectory $asset.fileName
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing APK: $path" }
    $actualHash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actualHash -ne $asset.sha256.ToLowerInvariant()) { throw "Checksum mismatch: $($asset.fileName)" }
    & (Join-Path $PSScriptRoot 'Verify-Signing-Certificate.ps1') -ApkPath $path -ExpectedSha256 $asset.signingCertificateSha256 -ApkSignerPath $ApkSignerPath
}
Write-Host 'Release verification passed.'
