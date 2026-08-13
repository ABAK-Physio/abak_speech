$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent $PSScriptRoot
$OutputExe = Join-Path $RootDir "abak-speech.exe"

Write-Host "==> Analyse Dart"
Set-Location $RootDir
dart analyze

$VersionFile = Join-Path $RootDir "VERSION"
$Version = (Get-Content $VersionFile -Raw).Trim()

Write-Host "==> Compilation de abak-speech.exe"
dart compile exe `
  "-DABAK_SPEECH_VERSION=$Version" `
  bin\abak_speech.dart `
  -o $OutputExe

Write-Host ""
Write-Host "abak-speech.exe construit avec succes :"
Get-Item $OutputExe | Format-List Name, Length, LastWriteTime