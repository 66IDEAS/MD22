# MD22

MD22 is a native, read-only Markdown reader for macOS 26 and Apple silicon. It
is designed for quickly opening project Markdown files outside a knowledge-base
vault, with rich rendering, focused long-document navigation, memorable themes,
and publication-quality HTML and PDF export.

## Build from source

Requirements: macOS 26, Xcode 26 command-line tools, XcodeGen, and Node.js.

```sh
cd implementations/mac
npm ci
npm run build:renderer
scripts/generate-project.zsh
xcodebuild -project MD22.xcodeproj -scheme MD22 \
  -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO build
```

The generated app is at
`implementations/mac/DerivedData/Build/Products/Debug/MD22.app`.

Developer ID archive, notarization, DMG, and Gatekeeper verification commands
are documented in [Direct Distribution](docs/DISTRIBUTION.md). Release scripts
refuse to overwrite artifacts and keep all signing credentials outside the
repository.

Run the same dependency, renderer, native unit, UI, Release-build, and
architecture checks used by GitHub Actions with:

```sh
implementations/mac/scripts/ci.zsh
```

Version tags are built by the protected release environment into signed and
notarized Apple-silicon DMGs, signed Sparkle updates, SPDX SBOMs, checksums, and
GitHub attestations. Repository protection and secret setup are documented in
[Dependency and Release Supply Chain](docs/SUPPLY_CHAIN.md).

## Project layout

- `implementations`: independently buildable Markdown-viewer implementations
- `implementations/mac/MD22`: native macOS application source and bundled resources
- `implementations/mac/web`: isolated renderer source used by the macOS app
- `implementations/mac/scripts`: reproducible macOS build, validation, and release tools
- `implementations/mac/MD22Tests` and `implementations/mac/MD22UITests`: macOS automated verification
- `specs`: approved functional, UX, architecture, and task specifications

MD22 is licensed under the [MIT License](LICENSE).

## Privacy

MD22 has no accounts, analytics, telemetry, or cloud document processing. Markdown rendering, search, bookmarks, history, and export remain on the Mac. The private WebKit renderer blocks remote code and styles; only resources that a document explicitly references may be loaded, while external links open in the default application.
