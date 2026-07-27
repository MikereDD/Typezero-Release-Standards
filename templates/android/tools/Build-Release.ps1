[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Version,
    [ValidateSet('Release', 'Debug')][string]$Variant = 'Release',
    [string]$AppName = 'AppName',
    [string]$OutputRoot = (Join-Path $PSScriptRoot '../artifacts')
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Push-Location $repoRoot
try {
    $task = if ($Variant -eq 'Release') { 'assembleRelease' } else { 'assembleDebug' }
    & ./gradlew $task
    if ($LASTEXITCODE -ne 0) { throw "Gradle task $task failed." }

    $variantLower = $Variant.ToLowerInvariant()
    $builtApk = Get-ChildItem -Path (Join-Path $repoRoot "app/build/outputs/apk/$variantLower") -Filter '*.apk' |
        Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 1
    if (-not $builtApk) { throw 'Built APK was not found.' }

    $releaseDir = Join-Path $OutputRoot "release/$Version"
    New-Item -ItemType Directory -Path $releaseDir -Force | Out-Null
    $destination = Join-Path $releaseDir "$AppName-v$Version.apk"
    Copy-Item -LiteralPath $builtApk.FullName -Destination $destination -Force
    & (Join-Path $PSScriptRoot 'Generate-Checksums.ps1') -Path $destination
    Write-Host "Release created: $destination"
}
finally { Pop-Location }
