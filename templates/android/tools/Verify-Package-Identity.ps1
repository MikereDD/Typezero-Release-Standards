[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ApkPath,
    [Parameter(Mandatory)][string]$ExpectedPackageId,
    [string]$ApkAnalyzerPath = 'apkanalyzer'
)

$ErrorActionPreference = 'Stop'
$apk = (Resolve-Path -LiteralPath $ApkPath).Path
$output = & $ApkAnalyzerPath manifest application-id $apk 2>&1
if ($LASTEXITCODE -ne 0) { throw "apkanalyzer package-ID inspection failed:`n$output" }
$actual = ([string]($output | Select-Object -First 1)).Trim()
if (-not $actual) { throw 'APK package ID could not be determined.' }
if ($actual -cne $ExpectedPackageId) {
    throw "APK package ID mismatch. Expected $ExpectedPackageId; found $actual"
}
Write-Host 'APK package identity verification passed.'
