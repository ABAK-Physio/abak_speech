#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

ADDON="$ROOT_DIR/abak-speech"
WHISPER="$ROOT_DIR/whisper-cli"
MODEL="$ROOT_DIR/ggml-large-v3-turbo.bin"

BUILD_DIR="$ROOT_DIR/build/pkg"
ROOT_PKG="$BUILD_DIR/root"
OUTPUT_DIR="$ROOT_DIR/dist"

INSTALL_DIR="$ROOT_PKG/Library/Application Support/ABAK/speech"

PKG_IDENTIFIER="care.abak.speech"
PKG_VERSION="$(cat "$ROOT_DIR/VERSION")"
PKG_OUTPUT="$OUTPUT_DIR/ABAK_Speech_${PKG_VERSION}_macOS.pkg"

APP_SIGN_IDENTITY="Developer ID Application: Abak Metrics (LP84QVHHSV)"
PKG_SIGN_IDENTITY="Developer ID Installer: Abak Metrics (LP84QVHHSV)"
ENTITLEMENTS="$ROOT_DIR/macos/abak_speech.entitlements"

echo "==> Vérification des fichiers"

for FILE in "$ADDON" "$WHISPER" "$MODEL"; do
  if [ ! -f "$FILE" ]; then
    echo "ERREUR : fichier introuvable : $FILE"
    exit 1
  fi
done

echo "==> Nettoyage"

rm -rf "$BUILD_DIR"
mkdir -p "$INSTALL_DIR"
mkdir -p "$OUTPUT_DIR"

echo "==> Préparation du contenu"

cp "$ADDON" "$INSTALL_DIR/abak-speech"
cp "$WHISPER" "$INSTALL_DIR/whisper-cli"
cp "$MODEL" "$INSTALL_DIR/ggml-large-v3-turbo.bin"

chmod 755 "$INSTALL_DIR/abak-speech"
chmod 755 "$INSTALL_DIR/whisper-cli"
chmod 644 "$INSTALL_DIR/ggml-large-v3-turbo.bin"

echo "==> Signature des exécutables"

codesign \
  --force \
  --options runtime \
  --timestamp \
  --entitlements "$ENTITLEMENTS" \
  --sign "$APP_SIGN_IDENTITY" \
  "$INSTALL_DIR/abak-speech"

codesign \
  --force \
  --options runtime \
  --timestamp \
  --sign "$APP_SIGN_IDENTITY" \
  "$INSTALL_DIR/whisper-cli"

codesign --verify --verbose=2 "$INSTALL_DIR/abak-speech"
codesign --verify --verbose=2 "$INSTALL_DIR/whisper-cli"

"$INSTALL_DIR/abak-speech" --status

echo "==> Construction du package"

pkgbuild \
  --root "$ROOT_PKG" \
  --identifier "$PKG_IDENTIFIER" \
  --version "$PKG_VERSION" \
  --install-location "/" \
  --sign "$PKG_SIGN_IDENTITY" \
  "$PKG_OUTPUT"

echo
echo "Package créé avec succès :"
ls -lh "$PKG_OUTPUT"