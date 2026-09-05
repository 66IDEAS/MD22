#!/bin/zsh
set -euo pipefail

SCRIPT_DIR=${0:A:h}
PROJECT_DIR=${SCRIPT_DIR:h}
OUTPUT_DIRECTORY=${1:-$PROJECT_DIR/build/private-test}
VERSION=${MD22_VERSION:-1.0.0}
BUILD_NUMBER=${MD22_BUILD_NUMBER:-1}
ARTIFACT_PATH="$OUTPUT_DIRECTORY/MD22-$VERSION-$BUILD_NUMBER-arm64-private-test.zip"
TEMPORARY_ROOT=$(mktemp -d /tmp/md22-private-test.XXXXXX)

cleanup() {
    case $TEMPORARY_ROOT in
        /tmp/md22-private-test.*) rm -rf -- "$TEMPORARY_ROOT" ;;
        *) print -u2 "Refusing to remove unexpected private-build directory: $TEMPORARY_ROOT" ;;
    esac
}
trap cleanup EXIT

if [[ -e $ARTIFACT_PATH ]]; then
    print -u2 "Refusing to replace an existing private test build: $ARTIFACT_PATH"
    exit 73
fi

cd "$PROJECT_DIR"
npm ci
npm run build:renderer
"$SCRIPT_DIR/generate-project.zsh"

xcodebuild -quiet \
    -project MD22.xcodeproj \
    -scheme MD22 \
    -configuration Release \
    -destination 'generic/platform=macOS' \
    -derivedDataPath "$TEMPORARY_ROOT/DerivedData" \
    -onlyUsePackageVersionsFromResolvedFile \
    CODE_SIGNING_ALLOWED=NO \
    MARKETING_VERSION="$VERSION" \
    CURRENT_PROJECT_VERSION="$BUILD_NUMBER" \
    build

APP_PATH="$TEMPORARY_ROOT/DerivedData/Build/Products/Release/MD22.app"

# Private builds have no shared Developer ID team. Re-sign all bundled code
# ad hoc, then allow the host to load those independently signed components.
# Public releases continue to use archive-release.zsh and library validation.
codesign --force --deep --sign - --options runtime "$APP_PATH"
codesign \
    --force \
    --sign - \
    --options runtime \
    --entitlements "$PROJECT_DIR/Config/PrivateTest.entitlements" \
    "$APP_PATH"

codesign --verify --deep --strict --verbose=2 "$APP_PATH"
"$SCRIPT_DIR/verify-architecture.sh" "$APP_PATH"

mkdir -p "$OUTPUT_DIRECTORY"
ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$ARTIFACT_PATH"
unzip -tq "$ARTIFACT_PATH"

print "Created verified private test build: $ARTIFACT_PATH"
shasum -a 256 "$ARTIFACT_PATH"
