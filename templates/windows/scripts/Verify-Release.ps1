[CmdletBinding()]
param(
    [string]$ManifestPath = (Join-Path $PSScriptRoot '../release-manifest.json'),
    [string]$AssetDirectory = (Split-Path -Parent $ManifestPath)
)

$ErrorActionPreference = 'Stop'
$manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
if ($manifest.platform -ne 'windows') { throw 'Manifest platform must be windows.' }
if (-not $manifest.assets -or $manifest.assets.Count -lt 1) { throw 'Manifest has no assets.' }

foreach ($asset in $manifest.assets) {
    $path = Join-Path $AssetDirectory $asset.fileName
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing asset: $path" }
    $actual = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actual -ne $asset.sha256.ToLowerInvariant()) { throw "Checksum mismatch: $($asset.fileName)" }
    if ((Get-Item -LiteralPath $path).Length -ne [int64]$asset.size) { throw "Size mismatch: $($asset.fileName)" }
}
Write-Host 'Release verification passed.'
