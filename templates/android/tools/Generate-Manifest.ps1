[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidatePattern('^[0-9]+(?:\.[0-9]+)+(?:-dev(?:\.[0-9]+)+)?$')][string]$Version,
    [ValidateSet('stable', 'development')][string]$Channel = 'development',
    [string]$AppId = 'app-name',
    [string]$DisplayName = 'AppName',
    [Parameter(Mandatory)][string]$PackageId,
    [Parameter(Mandatory)][ValidatePattern('^[A-Fa-f0-9]{64}$')][string]$SigningCertificateSha256,
    [int]$UpdaterProtocolVersion = 1,
    [int]$MinimumUpdaterProtocolVersion = 1,
    [Parameter(Mandatory)][uri]$DownloadBaseUrl,
    [Parameter(Mandatory)][string]$SigningKeyId,
    [Parameter(Mandatory)][string]$PublicKeyPath,
    [ValidateSet('rsa-sha256', 'ecdsa-sha256', 'ed25519')][string]$SignatureAlgorithm = 'rsa-sha256',
    [string]$OpenSslPath = 'openssl',
    [string]$MinimumVersion = $Version,
    [string]$ReleaseDirectory = (Join-Path $PSScriptRoot "../artifacts/release/$Version"),
    [string]$RepositoryUrl,
    [string]$SourceCommit,
    [string]$SourceTag = "v$Version",
    [string]$ReleaseNotesUrl = "docs/releases/v$Version.md",
    [string]$ChangelogUrl = 'CHANGELOG.md'
)

$ErrorActionPreference = 'Stop'
if ($MinimumUpdaterProtocolVersion -gt $UpdaterProtocolVersion) {
    throw 'MinimumUpdaterProtocolVersion cannot exceed UpdaterProtocolVersion.'
}
$releaseDirectory = (Resolve-Path $ReleaseDirectory).Path
$fileName = "$DisplayName-v$Version.apk" -replace ' ', '-'
$assetPath = Join-Path $releaseDirectory $fileName
$signaturePath = "$assetPath.sig"
if (-not (Test-Path -LiteralPath $assetPath -PathType Leaf)) { throw "Missing APK: $assetPath" }
if (-not (Test-Path -LiteralPath $signaturePath -PathType Leaf)) { throw "Missing detached signature: $signaturePath" }
$publicKey = (Resolve-Path -LiteralPath $PublicKeyPath).Path
$file = Get-Item -LiteralPath $assetPath
$signatureFile = Get-Item -LiteralPath $signaturePath
$sha256 = (Get-FileHash -LiteralPath $assetPath -Algorithm SHA256).Hash.ToLowerInvariant()
$signatureSha256 = (Get-FileHash -LiteralPath $signaturePath -Algorithm SHA256).Hash.ToLowerInvariant()
$derPath = [IO.Path]::GetTempFileName()
try {
    & $OpenSslPath pkey -pubin -in $publicKey -outform DER -out $derPath
    if ($LASTEXITCODE -ne 0) { throw 'Failed to canonicalize public key.' }
    $publicKeySha256 = (Get-FileHash -LiteralPath $derPath -Algorithm SHA256).Hash.ToLowerInvariant()
}
finally {
    Remove-Item -LiteralPath $derPath -Force -ErrorAction SilentlyContinue
}

if (-not $SourceCommit) {
    $gitCommit = & git rev-parse HEAD 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $gitCommit) { throw 'SourceCommit was not supplied and could not be read from Git.' }
    $SourceCommit = ([string]$gitCommit).Trim()
}
if (-not $RepositoryUrl) {
    $gitRemote = & git remote get-url origin 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $gitRemote) { throw 'RepositoryUrl was not supplied and could not be read from Git origin.' }
    $RepositoryUrl = ([string]$gitRemote).Trim()
}
if ($SourceCommit -notmatch '^(?:[A-Fa-f0-9]{40}|[A-Fa-f0-9]{64})$') { throw 'SourceCommit must be a full 40- or 64-hex Git commit ID.' }
if ($SourceTag -ne "v$Version") { throw "SourceTag must equal v$Version under the default Typezer∅ naming standard." }
$downloadBase = $DownloadBaseUrl.AbsoluteUri
if (-not $downloadBase.EndsWith('/')) { $downloadBase += '/' }
$downloadBaseUri = [uri]$downloadBase

$manifest = [ordered]@{
    schemaVersion = 2
    appId = $AppId
    displayName = $DisplayName
    platform = 'android'
    architecture = 'android-universal'
    channel = $Channel
    version = $Version
    publishedAt = [DateTime]::UtcNow.ToString('o')
    minimumVersion = $MinimumVersion
    updaterProtocolVersion = $UpdaterProtocolVersion
    minimumUpdaterProtocolVersion = $MinimumUpdaterProtocolVersion
    mandatory = $false
    releaseNotesUrl = $ReleaseNotesUrl
    changelogUrl = $ChangelogUrl
    assets = @([ordered]@{
        fileName = $file.Name
        downloadUrl = ([uri]::new($downloadBaseUri, $file.Name)).AbsoluteUri
        size = $file.Length
        sha256 = $sha256
        signature = [ordered]@{
            algorithm = $SignatureAlgorithm
            fileName = $signatureFile.Name
            downloadUrl = ([uri]::new($downloadBaseUri, $signatureFile.Name)).AbsoluteUri
            size = $signatureFile.Length
            sha256 = $signatureSha256
            keyId = $SigningKeyId
            publicKeySha256 = $publicKeySha256
        }
        packageId = $PackageId
        signingCertificateSha256 = $SigningCertificateSha256.ToLowerInvariant()
    })
    source = [ordered]@{
        repositoryUrl = $RepositoryUrl
        tag = $SourceTag
        commit = $SourceCommit.ToLowerInvariant()
    }
    rollback = [ordered]@{ supported = $false; retainVersions = 0 }
}
$manifestPath = Join-Path $releaseDirectory 'release-manifest.json'
$manifest | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $manifestPath -Encoding utf8
Write-Host "Manifest written: $manifestPath"
