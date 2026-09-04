#!/bin/zsh
set -euo pipefail

SCRIPT_DIR=${0:A:h}
PROJECT_DIR=${SCRIPT_DIR:h}
SOURCE_APP=${1:-}
OUTPUT_DIRECTORY=${2:-$PROJECT_DIR/build/release}
SIGNING_IDENTITY=${MD22_SIGNING_IDENTITY:-}

if [[ -z $SOURCE_APP || ! -d $SOURCE_APP ]]; then
    print -u2 "usage: $0 <signed MD22.app> [output-directory]"
    exit 64
fi
if [[ -z $SIGNING_IDENTITY ]]; then
    print -u2 "Set MD22_SIGNING_IDENTITY to the complete Developer ID Application identity."
    exit 64
fi

typeset -a NOTARY_AUTHENTICATION
if [[ -n ${MD22_NOTARY_KEYCHAIN_PROFILE:-} ]]; then
    NOTARY_AUTHENTICATION=(--keychain-profile "$MD22_NOTARY_KEYCHAIN_PROFILE")
elif [[ -n ${MD22_NOTARY_KEY_PATH:-} && -n ${MD22_NOTARY_KEY_ID:-} ]]; then
    NOTARY_AUTHENTICATION=(--key "$MD22_NOTARY_KEY_PATH" --key-id "$MD22_NOTARY_KEY_ID")
    if [[ -n ${MD22_NOTARY_ISSUER_ID:-} ]]; then
        NOTARY_AUTHENTICATION+=(--issuer "$MD22_NOTARY_ISSUER_ID")
    fi
else
    print -u2 "Set MD22_NOTARY_KEYCHAIN_PROFILE, or provide MD22_NOTARY_KEY_PATH and MD22_NOTARY_KEY_ID (plus MD22_NOTARY_ISSUER_ID for a team API key)."
    exit 64
fi

VERSION=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$SOURCE_APP/Contents/Info.plist")
DMG_PATH="$OUTPUT_DIRECTORY/MD22-$VERSION-arm64.dmg"
UPDATE_ARCHIVE="$OUTPUT_DIRECTORY/MD22-$VERSION-arm64.zip"
CHECKSUM_PATH="$OUTPUT_DIRECTORY/SHA256SUMS"
for OUTPUT_PATH in "$DMG_PATH" "$UPDATE_ARCHIVE" "$CHECKSUM_PATH"; do
    if [[ -e $OUTPUT_PATH ]]; then
        print -u2 "Refusing to replace an existing release artifact: $OUTPUT_PATH"
        exit 73
    fi
done

TEMPORARY_ROOT=$(mktemp -d /tmp/md22-notary.XXXXXX)
cleanup() {
    case $TEMPORARY_ROOT in
        /tmp/md22-notary.*) rm -rf -- "$TEMPORARY_ROOT" ;;
        *) print -u2 "Refusing to remove unexpected temporary directory: $TEMPORARY_ROOT" ;;
    esac
}
trap cleanup EXIT

WORKING_APP="$TEMPORARY_ROOT/MD22.app"
SUBMISSION_ARCHIVE="$TEMPORARY_ROOT/MD22-notarization.zip"
DMG_STAGING="$TEMPORARY_ROOT/dmg"
ditto "$SOURCE_APP" "$WORKING_APP"
"$SCRIPT_DIR/verify-release.zsh" "$WORKING_APP"
if ! codesign -dvv "$WORKING_APP" 2>&1 | rg -Fq "Authority=$SIGNING_IDENTITY"; then
    print -u2 "The application and DMG signing identities must match: $SIGNING_IDENTITY"
    exit 65
fi

# ZIP is Apple's lossless notarization transport for an application bundle.
ditto -c -k --sequesterRsrc --keepParent "$WORKING_APP" "$SUBMISSION_ARCHIVE"
xcrun notarytool submit "$SUBMISSION_ARCHIVE" "${NOTARY_AUTHENTICATION[@]}" --wait --timeout 30m
xcrun stapler staple "$WORKING_APP"
xcrun stapler validate "$WORKING_APP"

mkdir -p "$OUTPUT_DIRECTORY" "$DMG_STAGING"
ditto "$WORKING_APP" "$DMG_STAGING/MD22.app"
ln -s /Applications "$DMG_STAGING/Applications"
ditto "$PROJECT_DIR/../LICENSE" "$DMG_STAGING/LICENSE.txt"
ditto "$PROJECT_DIR/../THIRD_PARTY_NOTICES.md" "$DMG_STAGING/THIRD_PARTY_NOTICES.txt"

hdiutil create \
    -volname "MD22 $VERSION" \
    -srcfolder "$DMG_STAGING" \
    -format UDZO \
    "$DMG_PATH"
codesign --force --sign "$SIGNING_IDENTITY" --timestamp "$DMG_PATH"

xcrun notarytool submit "$DMG_PATH" "${NOTARY_AUTHENTICATION[@]}" --wait --timeout 30m
xcrun stapler staple "$DMG_PATH"
xcrun stapler validate "$DMG_PATH"

# Sparkle distributes the same stapled application in a resource-preserving ZIP.
ditto -c -k --sequesterRsrc --keepParent "$WORKING_APP" "$UPDATE_ARCHIVE"
(
    cd "$OUTPUT_DIRECTORY"
    shasum -a 256 "${DMG_PATH:t}" "${UPDATE_ARCHIVE:t}" > "${CHECKSUM_PATH:t}"
)

"$SCRIPT_DIR/verify-release.zsh" "$WORKING_APP" "$DMG_PATH"
print "Created notarized release artifacts:"
print "  $DMG_PATH"
print "  $UPDATE_ARCHIVE"
print "  $CHECKSUM_PATH"
