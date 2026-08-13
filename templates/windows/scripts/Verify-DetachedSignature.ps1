[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$AssetPath,
    [Parameter(Mandatory)][string]$SignaturePath,
    [Parameter(Mandatory)][string]$PublicKeyPath,
    [Parameter(Mandatory)][ValidateSet('rsa-sha256', 'ecdsa-sha256', 'ed25519')][string]$Algorithm,
    [Parameter(Mandatory)][ValidatePattern('^[A-Fa-f0-9]{64}$')][string]$ExpectedPublicKeySha256,
    [string]$OpenSslPath = 'openssl'
)

$ErrorActionPreference = 'Stop'
$asset = (Resolve-Path -LiteralPath $AssetPath).Path
$signature = (Resolve-Path -LiteralPath $SignaturePath).Path
$publicKey = (Resolve-Path -LiteralPath $PublicKeyPath).Path
$derPath = [IO.Path]::GetTempFileName()
try {
    & $OpenSslPath pkey -pubin -in $publicKey -outform DER -out $derPath
    if ($LASTEXITCODE -ne 0) { throw 'Failed to canonicalize public key.' }
    $keyHash = (Get-FileHash -LiteralPath $derPath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($keyHash -ne $ExpectedPublicKeySha256.ToLowerInvariant()) {
        throw "Pinned public-key fingerprint mismatch. Expected $ExpectedPublicKeySha256; found $keyHash"
    }

    switch ($Algorithm) {
        'rsa-sha256' {
            & $OpenSslPath dgst -sha256 -verify $publicKey -signature $signature $asset
        }
        'ecdsa-sha256' {
            & $OpenSslPath dgst -sha256 -verify $publicKey -signature $signature $asset
        }
        'ed25519' {
            & $OpenSslPath pkeyutl -verify -pubin -inkey $publicKey -rawin -in $asset -sigfile $signature
        }
    }
    if ($LASTEXITCODE -ne 0) { throw "Detached signature verification failed with exit code $LASTEXITCODE." }
    Write-Host 'Detached signature verification passed.'
}
finally {
    Remove-Item -LiteralPath $derPath -Force -ErrorAction SilentlyContinue
}
