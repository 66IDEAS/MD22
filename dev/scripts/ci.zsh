#!/bin/zsh
set -euo pipefail

SCRIPT_DIR=${0:A:h}
PROJECT_DIR=${SCRIPT_DIR:h}
REPOSITORY_DIR=${PROJECT_DIR:h}
DERIVED_DATA=$(mktemp -d /tmp/md22-ci.XXXXXX)

cleanup() {
    case $DERIVED_DATA in
        /tmp/md22-ci.*) rm -rf -- "$DERIVED_DATA" ;;
        *) print -u2 "Refusing to remove unexpected CI directory: $DERIVED_DATA" ;;
    esac
}
trap cleanup EXIT

for TOOL in node npm xcodebuild xcodegen xcrun; do
    if ! command -v "$TOOL" >/dev/null; then
        print -u2 "Required build tool is unavailable: $TOOL"
        exit 69
    fi
done

XCODE_MAJOR=$(xcodebuild -version | awk 'NR == 1 { split($2, version, "."); print version[1] }')
SDK_MAJOR=$(xcrun --sdk macosx --show-sdk-version | awk -F. '{ print $1 }')
if (( XCODE_MAJOR < 26 || SDK_MAJOR < 26 )); then
    print -u2 "MD22 requires Xcode and the macOS SDK generation 26 or newer."
    exit 69
fi

cd "$PROJECT_DIR"
npm ci
npm run audit:dependencies
npm run build:renderer
git -C "$REPOSITORY_DIR" diff --exit-code -- dev/MD22/Resources/Renderer

"$SCRIPT_DIR/generate-project.zsh"
"$SCRIPT_DIR/verify-platform-conformance.sh"

xcodebuild -quiet \
    -project MD22.xcodeproj \
    -scheme MD22 \
    -configuration Debug \
    -derivedDataPath "$DERIVED_DATA" \
    -onlyUsePackageVersionsFromResolvedFile \
    CODE_SIGNING_ALLOWED=NO \
    -only-testing:MD22Tests \
    test

"$SCRIPT_DIR/test-ui.zsh"

xcodebuild -quiet \
    -project MD22.xcodeproj \
    -scheme MD22 \
    -configuration Release \
    -destination 'generic/platform=macOS' \
    -derivedDataPath "$DERIVED_DATA" \
    -onlyUsePackageVersionsFromResolvedFile \
    CODE_SIGNING_ALLOWED=NO \
    build
"$SCRIPT_DIR/verify-architecture.sh" "$DERIVED_DATA/Build/Products/Release/MD22.app"

print "MD22 CI verification passed with Xcode $XCODE_MAJOR and macOS SDK $SDK_MAJOR."
