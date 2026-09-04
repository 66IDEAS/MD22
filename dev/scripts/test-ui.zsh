#!/bin/zsh
set -euo pipefail

script_dir=${0:A:h}
project_dir=${script_dir:h}
derived_data=${MD22_UI_DERIVED_DATA:-$(mktemp -d /tmp/md22-ui-tests.XXXXXX)}

cleanup() {
    if [[ -n ${MD22_KEEP_UI_DERIVED_DATA:-} ]]; then
        print "Preserved UI-test data at $derived_data"
        return
    fi
    case "$derived_data" in
        /tmp/md22-ui-tests.*) rm -rf -- "$derived_data" ;;
        *) print -u2 "Refusing to remove unexpected UI-test directory: $derived_data" ;;
    esac
}
trap cleanup EXIT

cd "$project_dir"
xcodebuild -quiet \
    -project MD22.xcodeproj \
    -scheme MD22 \
    -configuration Debug \
    -derivedDataPath "$derived_data" \
    -onlyUsePackageVersionsFromResolvedFile \
    CODE_SIGNING_ALLOWED=NO \
    build-for-testing

# An entirely unsigned target is rejected by Launch Services, while Xcode's
# macOS UI runner otherwise contains a mixture of platform-signed and unsigned
# test code. Sign both disposable test-only hierarchies ad hoc so the app can
# launch and dyld sees one identity. Production signing never uses --deep.
application="$derived_data/Build/Products/Debug/MD22.app"
runner="$derived_data/Build/Products/Debug/MD22UITests-Runner.app"
codesign --force --deep --sign - --timestamp=none "$application"
codesign --force --deep --sign - --timestamp=none "$runner"

xcodebuild -quiet \
    -project MD22.xcodeproj \
    -scheme MD22 \
    -configuration Debug \
    -derivedDataPath "$derived_data" \
    -onlyUsePackageVersionsFromResolvedFile \
    -only-testing:MD22UITests \
    test-without-building \
    "$@"
