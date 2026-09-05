#!/bin/zsh
set -euo pipefail

APP_PATH="${1:-DerivedData/Build/Products/Debug/MD22.app}"
BINARY_PATH="$APP_PATH/Contents/MacOS/MD22"

if [[ ! -f "$BINARY_PATH" ]]; then
  print -u2 "MD22 executable not found at $BINARY_PATH"
  exit 1
fi

ARCHITECTURES="$(lipo -archs "$BINARY_PATH")"
if [[ "$ARCHITECTURES" != "arm64" ]]; then
  print -u2 "Expected arm64 only, found: $ARCHITECTURES"
  exit 1
fi

print "Verified Apple-silicon-only executable: $ARCHITECTURES"
