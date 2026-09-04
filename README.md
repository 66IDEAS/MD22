# MD22

MD22 is a native, read-only Markdown reader for macOS 26 and Apple silicon. It
is designed for quickly opening project Markdown files outside a knowledge-base
vault, with rich rendering, focused long-document navigation, memorable themes,
and publication-quality HTML and PDF export.

## Build from source

Requirements: macOS 26, Xcode 26 command-line tools, XcodeGen, and Node.js.

```sh
cd dev
npm ci
npm run build:renderer
xcodegen generate
xcodebuild -project MD22.xcodeproj -scheme MD22 \
  -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO build
```

The generated app is at
`dev/DerivedData/Build/Products/Debug/MD22.app`.

Developer ID archive, notarization, DMG, and Gatekeeper verification commands
are documented in [Direct Distribution](docs/DISTRIBUTION.md). Release scripts
refuse to overwrite artifacts and keep all signing credentials outside the
repository.

## Project layout

- `dev/MD22`: native application source and bundled resources
- `dev/web`: isolated renderer source
- `dev/scripts`: reproducible build, validation, and release tools
- `dev/MD22Tests` and `dev/MD22UITests`: automated verification
- `specs`: approved functional, UX, architecture, and task specifications

MD22 is licensed under the [MIT License](LICENSE).

## Privacy

MD22 has no accounts, analytics, telemetry, or cloud document processing. Markdown rendering, search, bookmarks, history, and export remain on the Mac. The private WebKit renderer blocks remote code and styles; only resources that a document explicitly references may be loaded, while external links open in the default application.
