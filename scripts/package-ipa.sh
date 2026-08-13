#!/usr/bin/env bash
set -euo pipefail

# Empaqueta .app unsigned → .ipa (Payload) para Sideloadly / AltStore.

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="${1:-$ROOT/build}"
APP_PATH="$(find "$BUILD_DIR" -name 'AlertaCL.app' -type d | head -n1)"

if [[ -z "$APP_PATH" ]]; then
  echo "No se encontró AlertaCL.app en $BUILD_DIR" >&2
  exit 1
fi

STAGE="$(mktemp -d)"
mkdir -p "$STAGE/Payload"
cp -R "$APP_PATH" "$STAGE/Payload/"

OUT_DIR="$ROOT/dist"
mkdir -p "$OUT_DIR"
IPA="$OUT_DIR/AlertaCL-unsigned.ipa"
rm -f "$IPA"
(
  cd "$STAGE"
  zip -qry "$IPA" Payload
)

echo "IPA listo: $IPA"
ls -lh "$IPA"
