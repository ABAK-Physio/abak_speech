#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL_DIR="/Library/Application Support/ABAK/speech"

ADDON="$ROOT_DIR/abak-speech"
WHISPER="$ROOT_DIR/whisper-cli"
MODEL="$ROOT_DIR/ggml-large-v3-turbo.bin"

echo "==> Vérification des fichiers"

for FILE in "$ADDON" "$WHISPER" "$MODEL"; do
  if [ ! -f "$FILE" ]; then
    echo "ERREUR : fichier introuvable : $FILE"
    exit 1
  fi
done

echo "==> Création du dossier d'installation"

sudo mkdir -p "$INSTALL_DIR"

echo "==> Installation de ABAK Speech"

sudo cp "$ADDON" "$INSTALL_DIR/abak-speech"
sudo cp "$WHISPER" "$INSTALL_DIR/whisper-cli"
sudo cp "$MODEL" "$INSTALL_DIR/ggml-large-v3-turbo.bin"

sudo chmod 755 "$INSTALL_DIR/abak-speech"
sudo chmod 755 "$INSTALL_DIR/whisper-cli"
sudo chmod 644 "$INSTALL_DIR/ggml-large-v3-turbo.bin"

echo
echo "Installation terminée :"
ls -lh "$INSTALL_DIR"