#!/bin/zsh
set -euo pipefail

PROJECT_FILE="${1:-project.yml}"
PLIST_FILE="${2:-MD22/Info.plist}"

rg -q 'macOS: "26.0"' "$PROJECT_FILE"
rg -q 'ARCHS: arm64' "$PROJECT_FILE"
rg -q 'ENABLE_HARDENED_RUNTIME: true' "$PROJECT_FILE"
rg -q 'ENABLE_APP_SANDBOX: false' "$PROJECT_FILE"
plutil -lint "$PLIST_FILE" >/dev/null

print "Verified MD22 platform configuration"
