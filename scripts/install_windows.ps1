$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent $PSScriptRoot
$InstallDir = "C:\ProgramData\ABAK\speech"

$Addon = Join-Path $RootDir "abak-speech.exe"
$Whisper = Join-Path $RootDir "whisper-cli.exe"
$Model = Join-Path $RootDir "ggml-large-v3-turbo.bin"

Write-Host "==> Vérification des fichiers"

foreach ($File in @($Addon, $Whisper, $Model)) {
    if (-not (Test-Path $File)) {
        throw "Fichier introuvable : $File"
    }
}

Write-Host "==> Création du dossier d'installation"

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

Write-Host "==> Installation de ABAK Speech"

Copy-Item $Addon   (Join-Path $InstallDir "abak-speech.exe") -Force
Copy-Item $Whisper (Join-Path $InstallDir "whisper-cli.exe") -Force
Copy-Item $Model   (Join-Path $InstallDir "ggml-large-v3-turbo.bin") -Force

Write-Host "==> Vérification"

& (Join-Path $InstallDir "abak-speech.exe") --status

Write-Host ""
Write-Host "ABAK Speech installé avec succès dans :"
Write-Host $InstallDir