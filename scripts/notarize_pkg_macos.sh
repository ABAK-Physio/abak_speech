#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

PKG_VERSION="$(cat "$ROOT_DIR/VERSION")"
PACKAGE="$ROOT_DIR/dist/ABAK_Speech_${PKG_VERSION}_macOS.pkg"
KEYCHAIN_PROFILE="ABAK_Notary"

echo
echo "======================================="
echo " Notarisation du package ABAK Speech"
echo "======================================="
echo

if [ ! -f "$PACKAGE" ]; then
  echo "ERREUR : package introuvable :"
  echo "$PACKAGE"
  echo
  echo "Exécute d'abord :"
  echo "./scripts/build_pkg_macos.sh"
  exit 1
fi

echo "Package :"
echo "$PACKAGE"
echo

echo "Vérification de la signature..."
pkgutil --check-signature "$PACKAGE"

echo
echo "Envoi du package au service de notarisation Apple..."
echo

xcrun notarytool submit "$PACKAGE" \
  --keychain-profile "$KEYCHAIN_PROFILE" \
  --wait

echo
echo "Notarisation acceptée."
echo
echo "Ajout du ticket de notarisation au package..."
echo

xcrun stapler staple "$PACKAGE"

echo
echo "Vérification du ticket de notarisation..."
echo

xcrun stapler validate "$PACKAGE"

echo
echo "======================================="
echo " Package signé et notarisé avec succès"
echo "======================================="
echo
echo "$PACKAGE"
echo