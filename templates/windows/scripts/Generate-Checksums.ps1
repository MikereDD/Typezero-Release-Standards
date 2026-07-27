[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Path
)

$ErrorActionPreference = 'Stop'
$item = Get-Item -LiteralPath $Path
if ($item.PSIsContainer) { throw "Path must be a file: $Path" }

$hash = (Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
$outputPath = "$($item.FullName).sha256"
"$hash  $($item.Name)" | Set-Content -LiteralPath $outputPath -Encoding ascii
Write-Host "SHA-256: $hash"
Write-Host "Written: $outputPath"
