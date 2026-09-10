# MD22 for macOS

The native reference implementation of [MD22](../../README.md), using SwiftUI
for the macOS shell and WebKit for Markdown rendering and publication output.
It targets macOS 26+ on Apple silicon. Version 1 is read-only.

## Prerequisites

- An Apple-silicon Mac running macOS 26 or later
- Xcode 26 with its command-line tools selected (`xcode-select -p`)
- XcodeGen available on your PATH
- Node.js 24 and npm (the generation used by this repository's CI)
- Git and internet access for the initial dependency downloads

Builds use `xcodebuild`; you do not need to operate the Xcode GUI. Install Xcode
and complete its first-run setup before building. The standalone Command Line
Tools package alone does not provide everything required for the app and UI tests.

## Build a runnable private copy

From a new checkout:

```sh
git clone https://github.com/66IDEAS/MD22.git
cd MD22
implementations/mac/scripts/package-private-test.zsh
```

The script installs locked dependencies, builds the bundled renderer, generates
the Xcode project, builds Release, ad-hoc signs the application and embedded
code, and verifies the Apple-silicon architecture and ZIP archive.

With the default version settings, the output is:

```text
implementations/mac/build/private-test/MD22-1.0.0-1-arm64-private-test.zip
```

Extract that ZIP in Finder, move `MD22.app` to Applications, and open it. This is
a **private, ad-hoc-signed build**, not a Developer ID-signed or notarized public
release. macOS may require approval under Privacy & Security when opening a
transferred private build. Do not disable Gatekeeper or other system protections.

The script refuses to overwrite an existing archive. Use a new build number
when building another copy:

```sh
MD22_BUILD_NUMBER=2 implementations/mac/scripts/package-private-test.zsh
```

An optional first argument chooses another output directory. Markdown documents,
history, and preferences are not part of the generated archive.

## Open Markdown from Finder

After installing and launching MD22, right-click a Markdown file and choose
**Open With → MD22**. Supported extensions are `.md`, `.markdown`, `.mdown`,
`.mkd`, and `.mkdn`. MD22 does not replace your existing default application.
To use MD22 for double-click opening, select a Markdown file in Finder, choose
**Get Info → Open with → MD22 → Change All…**, and confirm your choice.

For a developer-installed build, refresh its Launch Services registration if
Finder has cached the previous bundle, then verify discovery from the repo root:

```sh
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f /Applications/MD22.app
xcrun swift implementations/mac/scripts/verify-file-associations.swift
```

These commands do not change the default application or require notarization.

## Development build

For compilation and development work, from this directory:

```sh
npm ci
npm run build:renderer
scripts/generate-project.zsh
xcodebuild -project MD22.xcodeproj -scheme MD22 \
  -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO build
```

The generated Debug app is at `DerivedData/Build/Products/Debug/MD22.app`.
The command above disables code signing; use the private-build script when you
need a runnable packaged copy rather than copying this unsigned output to another Mac.

Edit renderer sources in `web/`, then regenerate the bundled assets with
`npm run build:renderer`. The generated project uses the committed Swift package
resolution. Preserve dependency lockfiles when changing packages.

## Test

From this directory, run the full verification script:

```sh
scripts/ci.zsh
```

It covers dependency checks, renderer and native tests, UI tests, Release
compilation, and architecture validation. UI tests need an interactive macOS
session and the system permissions requested by Xcode's test runner.

For a targeted native export check:

```sh
xcodebuild -project MD22.xcodeproj -scheme MD22 \
  -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO \
  -only-testing:MD22Tests/ExportTests test
```

For UI tests, use `scripts/test-ui.zsh`, which prepares the disposable test
bundles for launch. Add `-only-testing:MD22UITests/MD22LaunchTests/<testName>`
to select a specific test.

## Public releases

Public distribution requires Developer ID signing, Hardened Runtime, Apple
notarization, and configured release credentials. The private-build script uses
a test-only library-validation entitlement and is not the public release process.

The repository contains a version-tag release workflow, but that workflow depends
on a protected GitHub release environment, signing/notarization credentials,
Sparkle keys, and repository settings being configured by the maintainer.

- [Direct Distribution](../../docs/DISTRIBUTION.md)
- [Dependency and Release Supply Chain](../../docs/SUPPLY_CHAIN.md)
- [Apple Platform Conformance](../../docs/APPLE_PLATFORM_CONFORMANCE.md)
