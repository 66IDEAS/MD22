#!/bin/zsh
set -euo pipefail

SCRIPT_DIR=${0:A:h}
PROJECT_DIR=${SCRIPT_DIR:h}
RELEASE_DIRECTORY=${1:-}
PRIVATE_KEY_FILE=${2:-}
TAG=${3:-}

if [[ -z $RELEASE_DIRECTORY || -z $PRIVATE_KEY_FILE || -z $TAG ]]; then
    print -u2 "usage: $0 <release-directory> <Sparkle private EdDSA key file> <release-tag>"
    exit 64
fi
if [[ ! -d $RELEASE_DIRECTORY || ! -f $PRIVATE_KEY_FILE ]]; then
    print -u2 "The release directory and Sparkle private key file must exist."
    exit 66
fi
if [[ $TAG != v<->.<->.<-> ]]; then
    print -u2 "The release tag must use the form vMAJOR.MINOR.PATCH: $TAG"
    exit 64
fi

VERSION=${TAG#v}
REPOSITORY=${GITHUB_REPOSITORY:-alexanderilg/MD22}
UPDATE_ARCHIVE="$RELEASE_DIRECTORY/MD22-$VERSION-arm64.zip"
APPCAST_PATH="$RELEASE_DIRECTORY/appcast.xml"
if [[ ! -f $UPDATE_ARCHIVE ]]; then
    print -u2 "Expected the notarized Sparkle archive at: $UPDATE_ARCHIVE"
    exit 66
fi
if [[ -e $APPCAST_PATH ]]; then
    print -u2 "Refusing to replace an existing appcast: $APPCAST_PATH"
    exit 73
fi

TEMPORARY_ROOT=$(mktemp -d /tmp/md22-appcast.XXXXXX)
cleanup() {
    case $TEMPORARY_ROOT in
        /tmp/md22-appcast.*) rm -rf -- "$TEMPORARY_ROOT" ;;
        *) print -u2 "Refusing to remove unexpected temporary directory: $TEMPORARY_ROOT" ;;
    esac
}
trap cleanup EXIT

cd "$PROJECT_DIR"
"$SCRIPT_DIR/generate-project.zsh"
xcodebuild \
    -project MD22.xcodeproj \
    -scheme MD22 \
    -resolvePackageDependencies \
    -clonedSourcePackagesDirPath "$TEMPORARY_ROOT/Packages" \
    -onlyUsePackageVersionsFromResolvedFile

GENERATE_APPCAST="$TEMPORARY_ROOT/Packages/artifacts/sparkle/Sparkle/bin/generate_appcast"
if [[ ! -x $GENERATE_APPCAST ]]; then
    print -u2 "Sparkle's pinned generate_appcast tool was not resolved at: $GENERATE_APPCAST"
    exit 69
fi

APPCAST_SOURCE="$TEMPORARY_ROOT/Source"
mkdir -p "$APPCAST_SOURCE"
ditto "$UPDATE_ARCHIVE" "$APPCAST_SOURCE/${UPDATE_ARCHIVE:t}"
"$GENERATE_APPCAST" \
    --ed-key-file "$PRIVATE_KEY_FILE" \
    --download-url-prefix "https://github.com/$REPOSITORY/releases/download/$TAG/" \
    --link "https://github.com/$REPOSITORY/releases/tag/$TAG" \
    --maximum-versions 1 \
    -o "$TEMPORARY_ROOT/appcast.xml" \
    "$APPCAST_SOURCE"

if ! rg -q 'sparkle:edSignature=' "$TEMPORARY_ROOT/appcast.xml"; then
    print -u2 "Sparkle did not add an EdDSA archive signature to the appcast."
    exit 65
fi
if ! rg -q '<!-- sparkle-signatures:' "$TEMPORARY_ROOT/appcast.xml" || \
   ! rg -q '^edSignature: ' "$TEMPORARY_ROOT/appcast.xml"; then
    print -u2 "Sparkle did not add the required signed-feed signature to the appcast."
    exit 65
fi

mv "$TEMPORARY_ROOT/appcast.xml" "$APPCAST_PATH"
print "Created signed Sparkle appcast: $APPCAST_PATH"
