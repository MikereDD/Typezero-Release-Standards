[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ApkPath,
    [Parameter(Mandatory)][ValidatePattern('^[A-Fa-f0-9]{64}$')][string]$ExpectedSha256,
    [string]$ApkSignerPath = 'apksigner'
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $ApkPath -PathType Leaf)) { throw "APK not found: $ApkPath" }
$output = & $ApkSignerPath verify --print-certs $ApkPath 2>&1
if ($LASTEXITCODE -ne 0) { throw "apksigner verification failed:`n$output" }
$line = $output | Where-Object { $_ -match 'Signer #1 certificate SHA-256 digest:' } | Select-Object -First 1
if (-not $line) { throw 'Signing certificate SHA-256 digest was not found.' }
$actual = (($line -split ':', 2)[1] -replace '[^A-Fa-f0-9]', '').ToLowerInvariant()
if ($actual -ne $ExpectedSha256.ToLowerInvariant()) { throw "Signing certificate mismatch. Expected $ExpectedSha256; found $actual" }
Write-Host 'APK signing certificate verification passed.'
