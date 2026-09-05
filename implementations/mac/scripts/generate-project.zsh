#!/bin/zsh
set -euo pipefail

SCRIPT_DIR=${0:A:h}
PROJECT_DIR=${SCRIPT_DIR:h}
RESOLVED_DIRECTORY="$PROJECT_DIR/MD22.xcodeproj/project.xcworkspace/xcshareddata/swiftpm"

cd "$PROJECT_DIR"
xcodegen generate
mkdir -p "$RESOLVED_DIRECTORY"
ditto "$PROJECT_DIR/Package.resolved" "$RESOLVED_DIRECTORY/Package.resolved"
print "Generated MD22.xcodeproj with the committed Swift package resolution."
