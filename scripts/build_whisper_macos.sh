#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WHISPER_DIR="$ROOT_DIR/whisper.cpp"
OUTPUT_BIN="$ROOT_DIR/whisper-cli"

echo "==> Préparation de whisper.cpp"

if [ ! -d "$WHISPER_DIR/.git" ]; then
  git clone https://github.com/ggml-org/whisper.cpp.git "$WHISPER_DIR"
else
  echo "whisper.cpp déjà présent."
fi

echo "==> Compilation statique"

cmake -S "$WHISPER_DIR" -B "$WHISPER_DIR/build" \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF

cmake --build "$WHISPER_DIR/build" -j --config Release

echo "==> Copie de whisper-cli"

cp "$WHISPER_DIR/build/bin/whisper-cli" "$OUTPUT_BIN"
chmod +x "$OUTPUT_BIN"

echo "==> Vérification des dépendances"

if otool -L "$OUTPUT_BIN" | grep -q "libwhisper.*dylib"; then
  echo "ERREUR : whisper-cli dépend encore de libwhisper.dylib."
  exit 1
fi

echo
echo "whisper-cli construit avec succès :"
ls -lh "$OUTPUT_BIN"