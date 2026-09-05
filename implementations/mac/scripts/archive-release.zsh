#!/bin/zsh
set -euo pipefail

SCRIPT_DIR=${0:A:h}
PROJECT_DIR=${SCRIPT_DIR:h}
RELEASE_ROOT=${1:-$PROJECT_DIR/build/release}
VERSION=${MD22_VERSION:-1.0.0}
BUILD_NUMBER=${MD22_BUILD_NUMBER:-1}
SIGNING_IDENTITY=${MD22_SIGNING_IDENTITY:-}
TEAM_ID=${MD22_TEAM_ID:-}

if [[ -z $SIGNING_IDENTITY || -z $TEAM_ID ]]; then
    print -u2 "Set MD22_SIGNING_IDENTITY to the complete Developer ID Application identity and MD22_TEAM_ID to the Apple Developer team ID."
    exit 64
fi

if ! security find-identity -v -p codesigning | rg -Fq \"$SIGNING_IDENTITY\"; then
    print -u2 "The requested signing identity is not available in the current keychain: $SIGNING_IDENTITY"
    exit 65
fi

ARCHIVE_NAME="MD22-$VERSION-$BUILD_NUMBER.xcarchive"
FINAL_ARCHIVE="$RELEASE_ROOT/$ARCHIVE_NAME"
FINAL_APP_DIRECTORY="$RELEASE_ROOT/MD22-$VERSION-$BUILD_NUMBER"
for OUTPUT_PATH in "$FINAL_ARCHIVE" "$FINAL_APP_DIRECTORY"; do
    if [[ -e $OUTPUT_PATH ]]; then
        print -u2 "Refusing to replace an existing release output: $OUTPUT_PATH"
        exit 73
    fi
done

TEMPORARY_ROOT=$(mktemp -d /tmp/md22-release.XXXXXX)
cleanup() {
    case $TEMPORARY_ROOT in
        /tmp/md22-release.*) rm -rf -- "$TEMPORARY_ROOT" ;;
        *) print -u2 "Refusing to remove unexpected temporary directory: $TEMPORARY_ROOT" ;;
    esac
}
trap cleanup EXIT

cd "$PROJECT_DIR"
npm ci
npm run build:renderer
"$SCRIPT_DIR/generate-project.zsh"

xcodebuild \
    -project MD22.xcodeproj \
    -scheme MD22 \
    -configuration Release \
    -destination 'generic/platform=macOS' \
    -onlyUsePackageVersionsFromResolvedFile \
    -derivedDataPath "$TEMPORARY_ROOT/DerivedData" \
    -archivePath "$TEMPORARY_ROOT/$ARCHIVE_NAME" \
    DEVELOPMENT_TEAM="$TEAM_ID" \
    CODE_SIGN_STYLE=Manual \
    CODE_SIGN_IDENTITY="$SIGNING_IDENTITY" \
    MARKETING_VERSION="$VERSION" \
    CURRENT_PROJECT_VERSION="$BUILD_NUMBER" \
    archive

EXPORT_OPTIONS="$TEMPORARY_ROOT/DeveloperIDExportOptions.plist"
ditto "$PROJECT_DIR/Config/DeveloperIDExportOptions.plist" "$EXPORT_OPTIONS"
/usr/libexec/PlistBuddy -c "Add :teamID string $TEAM_ID" "$EXPORT_OPTIONS"
xcodebuild \
    -exportArchive \
    -archivePath "$TEMPORARY_ROOT/$ARCHIVE_NAME" \
    -exportPath "$TEMPORARY_ROOT/Export" \
    -exportOptionsPlist "$EXPORT_OPTIONS"

APP_PATH="$TEMPORARY_ROOT/Export/MD22.app"
"$SCRIPT_DIR/verify-release.zsh" "$APP_PATH"

mkdir -p "$RELEASE_ROOT"
mv "$TEMPORARY_ROOT/$ARCHIVE_NAME" "$FINAL_ARCHIVE"
mv "$TEMPORARY_ROOT/Export" "$FINAL_APP_DIRECTORY"
print "Created signed release archive: $FINAL_ARCHIVE"
print "Created exported Developer ID app: $FINAL_APP_DIRECTORY/MD22.app"
