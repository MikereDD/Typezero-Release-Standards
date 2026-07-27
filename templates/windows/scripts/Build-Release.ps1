[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[0-9A-Za-z][0-9A-Za-z.-]*$')]
    [string]$Version,
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Release',
    [ValidateSet('win-x64', 'win-arm64')]
    [string]$Runtime = 'win-x64',
    [string]$Project = (Join-Path $PSScriptRoot '../src/AppName/AppName.csproj'),
    [string]$OutputRoot = (Join-Path $PSScriptRoot '../artifacts')
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$outputRootFull = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $OutputRoot))
$publishDir = Join-Path $outputRootFull "publish/$Runtime"
$releaseDir = Join-Path $outputRootFull "release/$Version"
$archiveName = "AppName-v$Version-$Runtime.zip"
$archivePath = Join-Path $releaseDir $archiveName

Remove-Item -LiteralPath $publishDir -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $publishDir, $releaseDir -Force | Out-Null

dotnet publish $Project -c $Configuration -r $Runtime --self-contained false -o $publishDir
if ($LASTEXITCODE -ne 0) { throw 'dotnet publish failed.' }

Remove-Item -LiteralPath $archivePath -Force -ErrorAction SilentlyContinue
Compress-Archive -Path (Join-Path $publishDir '*') -DestinationPath $archivePath -CompressionLevel Optimal
& (Join-Path $PSScriptRoot 'Generate-Checksums.ps1') -Path $archivePath
Write-Host "Release created: $archivePath"
