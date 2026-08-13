$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent $PSScriptRoot

$VersionFile = Join-Path $RootDir "VERSION"
$IssFile = Join-Path $RootDir "installer\windows\abak_speech.iss"
$Iscc = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"

$Addon = Join-Path $RootDir "abak-speech.exe"
$Whisper = Join-Path $RootDir "whisper-cli.exe"
$Model = Join-Path $RootDir "ggml-large-v3-turbo.bin"

Write-Host "==> Verification des fichiers"

foreach ($File in @($VersionFile, $IssFile, $Addon, $Whisper, $Model, $Iscc)) {
    if (-not (Test-Path $File)) {
        throw "Fichier introuvable : $File"
    }
}

$Version = (Get-Content $VersionFile -Raw).Trim()

if ([string]::IsNullOrWhiteSpace($Version)) {
    throw "Le fichier VERSION est vide."
}

Write-Host "==> Version : $Version"
Write-Host "==> Construction de l'installateur Windows"

& $Iscc "/DMyAppVersion=$Version" $IssFile

if ($LASTEXITCODE -ne 0) {
    throw "La construction Inno Setup a echoue."
}

$Installer = Join-Path $RootDir "dist\ABAK_Speech_Windows.exe"

if (-not (Test-Path $Installer)) {
    throw "Installateur introuvable apres compilation : $Installer"
}

Write-Host ""
Write-Host "======================================="
Write-Host " Installateur Windows construit"
Write-Host "======================================="
Write-Host ""
Write-Host $Installer