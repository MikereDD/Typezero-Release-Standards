[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$AssetPath,
    [Parameter(Mandatory)][string]$PrivateKeyPath,
    [ValidateSet('rsa-sha256', 'ecdsa-sha256', 'ed25519')][string]$Algorithm = 'rsa-sha256',
    [string]$SignaturePath,
    [string]$OpenSslPath = 'openssl'
)

$ErrorActionPreference = 'Stop'
$asset = (Resolve-Path -LiteralPath $AssetPath).Path
$key = (Resolve-Path -LiteralPath $PrivateKeyPath).Path
if (-not $SignaturePath) { $SignaturePath = "$asset.sig" }

switch ($Algorithm) {
    'rsa-sha256' {
        & $OpenSslPath dgst -sha256 -sign $key -out $SignaturePath $asset
    }
    'ecdsa-sha256' {
        & $OpenSslPath dgst -sha256 -sign $key -out $SignaturePath $asset
    }
    'ed25519' {
        & $OpenSslPath pkeyutl -sign -inkey $key -rawin -in $asset -out $SignaturePath
    }
}
if ($LASTEXITCODE -ne 0) { throw "Detached signature creation failed with exit code $LASTEXITCODE." }
if (-not (Test-Path -LiteralPath $SignaturePath -PathType Leaf)) { throw "Signature was not created: $SignaturePath" }
Write-Host "Detached signature created: $SignaturePath"
