param(
    [switch]$Install
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$pluginId = "com.aiapproval.buttons.sdPlugin"
$dist = Join-Path $root "dist"
$pluginDir = Join-Path $dist $pluginId
$binDir = Join-Path $pluginDir "bin"

& (Join-Path $root "tools\generate-icons.ps1")

$resolvedDist = [System.IO.Path]::GetFullPath($dist)
$resolvedPluginDir = [System.IO.Path]::GetFullPath($pluginDir)
if ($resolvedPluginDir.StartsWith($resolvedDist, [System.StringComparison]::OrdinalIgnoreCase) -and (Test-Path $pluginDir)) {
    Remove-Item -Recurse -Force $pluginDir
}

dotnet publish (Join-Path $root "src\AiApprovalDeck\AiApprovalDeck.csproj") `
    -c Release `
    -r win-x64 `
    --self-contained false `
    -o $binDir
if ($LASTEXITCODE -ne 0) {
    throw "dotnet publish failed with exit code $LASTEXITCODE"
}

New-Item -ItemType Directory -Force -Path $pluginDir | Out-Null
Copy-Item -Force (Join-Path $root "plugin\manifest.json") (Join-Path $pluginDir "manifest.json")
Copy-Item -Recurse -Force (Join-Path $root "plugin\property-inspector") (Join-Path $pluginDir "property-inspector")
Copy-Item -Recurse -Force (Join-Path $root "plugin\images") (Join-Path $pluginDir "images")

Write-Host "Built $pluginDir"

if ($Install) {
    $streamDeckPlugins = Join-Path $env:APPDATA "Elgato\StreamDeck\Plugins"
    New-Item -ItemType Directory -Force -Path $streamDeckPlugins | Out-Null
    $target = Join-Path $streamDeckPlugins $pluginId
    if (Test-Path $target) {
        Remove-Item -Recurse -Force $target
    }
    Copy-Item -Recurse -Force $pluginDir $target
    Write-Host "Installed to $target"
    Write-Host "Restart the Stream Deck app if the plugin is not visible yet."
}
