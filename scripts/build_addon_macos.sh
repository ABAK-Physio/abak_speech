#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_BIN="$ROOT_DIR/abak-speech"

echo "==> Analyse Dart"

cd "$ROOT_DIR"
dart analyze

echo "==> Compilation de abak-speech"

dart compile exe \
  bin/abak_speech.dart \
  -o "$OUTPUT_BIN"

chmod +x "$OUTPUT_BIN"

echo
echo "abak-speech construit avec succès :"
ls -lh "$OUTPUT_BIN"