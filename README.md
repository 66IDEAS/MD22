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

## Project layout

- `dev/MD22`: native application source and bundled resources
- `dev/web`: isolated renderer source
- `dev/scripts`: reproducible build, validation, and release tools
- `dev/MD22Tests` and `dev/MD22UITests`: automated verification
- `specs`: approved functional, UX, architecture, and task specifications

MD22 is licensed under the [MIT License](LICENSE).

