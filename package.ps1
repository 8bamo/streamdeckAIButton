param(
    [switch]$Install
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$pluginId = "com.aiapproval.buttons.sdPlugin"
$dist = Join-Path $root "dist"
$pluginDir = Join-Path $dist $pluginId
$packagePath = Join-Path $dist "AI-Approval-Buttons.streamDeckPlugin"
$zipPath = "$packagePath.zip"

& (Join-Path $root "build.ps1") -Install:$Install

if (Test-Path $packagePath) {
    Remove-Item -Force $packagePath
}
if (Test-Path $zipPath) {
    Remove-Item -Force $zipPath
}

Compress-Archive -Path $pluginDir -DestinationPath $zipPath -Force
Move-Item -Force $zipPath $packagePath

Write-Host "Packaged $packagePath"
