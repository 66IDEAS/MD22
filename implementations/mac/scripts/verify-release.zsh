#!/bin/zsh
set -euo pipefail

APP_PATH=${1:-}
DMG_PATH=${2:-}
if [[ -z $APP_PATH || ! -d $APP_PATH ]]; then
    print -u2 "usage: $0 <MD22.app> [notarized-dmg]"
    exit 64
fi

MAIN_EXECUTABLE="$APP_PATH/Contents/MacOS/MD22"
INFO_PLIST="$APP_PATH/Contents/Info.plist"
if [[ ! -f $MAIN_EXECUTABLE || ! -f $INFO_PLIST ]]; then
    print -u2 "The supplied bundle is not a complete MD22 application: $APP_PATH"
    exit 65
fi

[[ $(lipo -archs "$MAIN_EXECUTABLE") == arm64 ]]
[[ $(/usr/libexec/PlistBuddy -c 'Print :LSMinimumSystemVersion' "$INFO_PLIST") == 26.* ]]
codesign --verify --deep --strict --verbose=2 "$APP_PATH"

SIGNATURE_DESCRIPTION=$(codesign -dvv "$APP_PATH" 2>&1)
print -r -- "$SIGNATURE_DESCRIPTION" | rg -q '^Authority=Developer ID Application:'
print -r -- "$SIGNATURE_DESCRIPTION" | rg -q '^flags=.*runtime'

ENTITLEMENTS_FILE=$(mktemp /tmp/md22-entitlements.XXXXXX)
cleanup() {
    case $ENTITLEMENTS_FILE in
        /tmp/md22-entitlements.*) rm -f -- "$ENTITLEMENTS_FILE" ;;
        *) print -u2 "Refusing to remove unexpected temporary file: $ENTITLEMENTS_FILE" ;;
    esac
}
trap cleanup EXIT
codesign -d --entitlements "$ENTITLEMENTS_FILE" "$APP_PATH" >/dev/null 2>&1 || true
if [[ -s $ENTITLEMENTS_FILE ]] && \
   [[ $(/usr/libexec/PlistBuddy -c 'Print :com.apple.security.app-sandbox' "$ENTITLEMENTS_FILE" 2>/dev/null || true) == true ]]; then
    print -u2 "Release unexpectedly enables App Sandbox."
    exit 66
fi

if [[ -n $DMG_PATH ]]; then
    if [[ ! -f $DMG_PATH ]]; then
        print -u2 "Notarized DMG not found: $DMG_PATH"
        exit 65
    fi
    xcrun stapler validate "$APP_PATH"
    xcrun stapler validate "$DMG_PATH"
    codesign --verify --strict --verbose=2 "$DMG_PATH"
    spctl --assess --type execute --verbose=4 "$APP_PATH"
    spctl --assess --type open --context context:primary-signature --verbose=4 "$DMG_PATH"
fi

print "Verified Developer ID signing, Hardened Runtime, arm64 application architecture, and non-sandboxed file access."
