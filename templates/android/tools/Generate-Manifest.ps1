[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Version,
    [ValidateSet('stable', 'development')][string]$Channel = 'development',
    [string]$AppId = 'app-name',
    [string]$DisplayName = 'AppName',
    [Parameter(Mandatory)][string]$PackageId,
    [Parameter(Mandatory)][ValidatePattern('^[A-Fa-f0-9]{64}$')][string]$SigningCertificateSha256,
    [Parameter(Mandatory)][uri]$DownloadBaseUrl,
    [string]$MinimumVersion = $Version,
    [string]$ReleaseDirectory = (Join-Path $PSScriptRoot "../artifacts/release/$Version")
)

$ErrorActionPreference = 'Stop'
$releaseDirectory = (Resolve-Path $ReleaseDirectory).Path
$fileName = "$DisplayName-v$Version.apk" -replace ' ', '-'
$assetPath = Join-Path $releaseDirectory $fileName
if (-not (Test-Path -LiteralPath $assetPath -PathType Leaf)) { throw "Missing APK: $assetPath" }
$file = Get-Item -LiteralPath $assetPath
$sha256 = (Get-FileHash -LiteralPath $assetPath -Algorithm SHA256).Hash.ToLowerInvariant()

$manifest = [ordered]@{
    schemaVersion = 1
    appId = $AppId
    displayName = $DisplayName
    platform = 'android'
    architecture = 'android-universal'
    channel = $Channel
    version = $Version
    publishedAt = [DateTime]::UtcNow.ToString('o')
    minimumVersion = $MinimumVersion
    mandatory = $false
    releaseNotesUrl = "docs/releases/v$Version.md"
    assets = @([ordered]@{
        fileName = $file.Name
        downloadUrl = ([uri]::new($DownloadBaseUrl, $file.Name)).AbsoluteUri
        size = $file.Length
        sha256 = $sha256
        packageId = $PackageId
        signingCertificateSha256 = $SigningCertificateSha256.ToLowerInvariant()
    })
    rollback = [ordered]@{ supported = $false; retainVersions = 0 }
}
$manifestPath = Join-Path $releaseDirectory 'release-manifest.json'
$manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $manifestPath -Encoding utf8
Write-Host "Manifest written: $manifestPath"
