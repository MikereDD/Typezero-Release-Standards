[CmdletBinding()]
param(
    [string]$ManifestPath = (Join-Path $PSScriptRoot '../release-manifest.json'),
    [string]$AssetDirectory = (Split-Path -Parent $ManifestPath),
    [Parameter(Mandatory)][string]$PublicKeyPath,
    [Parameter(Mandatory)][string]$ExpectedSigningKeyId,
    [bool]$VerifyGitSource = $true,
    [string]$OpenSslPath = 'openssl'
)

$ErrorActionPreference = 'Stop'
$manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
if ($manifest.schemaVersion -ne 2) { throw 'Manifest schemaVersion must be 2.' }
if ($manifest.platform -ne 'windows') { throw 'Manifest platform must be windows.' }
if (-not $manifest.assets -or $manifest.assets.Count -lt 1) { throw 'Manifest has no assets.' }
if ([int]$manifest.minimumUpdaterProtocolVersion -gt [int]$manifest.updaterProtocolVersion) {
    throw 'minimumUpdaterProtocolVersion cannot exceed updaterProtocolVersion.'
}
if ($manifest.source.tag -ne "v$($manifest.version)") { throw 'Source tag does not correspond to manifest version.' }

foreach ($asset in $manifest.assets) {
    $expectedFileName = ($manifest.displayName + '-v' + $manifest.version + '-' + $manifest.architecture + '.zip') -replace ' ', '-'
    if ($asset.fileName -cne $expectedFileName) { throw "Asset filename mismatch. Expected $expectedFileName; found $($asset.fileName)" }
    if ($asset.signature.fileName -cne "$($asset.fileName).sig") { throw 'Detached signature filename must equal payload filename plus .sig.' }
    $path = Join-Path $AssetDirectory $asset.fileName
    $signaturePath = Join-Path $AssetDirectory $asset.signature.fileName
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing asset: $path" }
    if (-not (Test-Path -LiteralPath $signaturePath -PathType Leaf)) { throw "Missing signature: $signaturePath" }
    $item = Get-Item -LiteralPath $path
    $sigItem = Get-Item -LiteralPath $signaturePath
    if ($item.Length -ne [int64]$asset.size) { throw "Size mismatch: $($asset.fileName)" }
    if ($sigItem.Length -ne [int64]$asset.signature.size) { throw "Signature size mismatch: $($asset.signature.fileName)" }
    $actual = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actual -ne $asset.sha256.ToLowerInvariant()) { throw "Checksum mismatch: $($asset.fileName)" }
    $actualSigHash = (Get-FileHash -LiteralPath $signaturePath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actualSigHash -ne $asset.signature.sha256.ToLowerInvariant()) { throw "Signature checksum mismatch: $($asset.signature.fileName)" }
    if ($asset.signature.keyId -ne $ExpectedSigningKeyId) {
        throw "Signing key ID mismatch. Expected $ExpectedSigningKeyId; found $($asset.signature.keyId)"
    }
    & (Join-Path $PSScriptRoot 'Verify-DetachedSignature.ps1') `
        -AssetPath $path `
        -SignaturePath $signaturePath `
        -PublicKeyPath $PublicKeyPath `
        -Algorithm $asset.signature.algorithm `
        -ExpectedPublicKeySha256 $asset.signature.publicKeySha256 `
        -OpenSslPath $OpenSslPath
}

if ($VerifyGitSource) {
    $gitTagCommit = & git rev-parse "$($manifest.source.tag)^{commit}" 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $gitTagCommit) { throw "Git tag not found: $($manifest.source.tag)" }
    $headForTag = ([string]$gitTagCommit).Trim()
    if ($headForTag.ToLowerInvariant() -ne $manifest.source.commit.ToLowerInvariant()) {
        throw "Git tag $($manifest.source.tag) does not resolve to manifest source commit."
    }
}
Write-Host 'Release verification passed.'
