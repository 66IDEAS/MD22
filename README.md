<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="implementations/mac/MD22/Resources/Brand/md22-dark.svg">
    <img src="implementations/mac/MD22/Resources/Brand/md22-light.svg" alt="MD22" width="380">
  </picture>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-2E62E8" alt="MIT license"></a>
  <a href="specs/specifications.md"><img src="https://img.shields.io/badge/spec-complete-2E62E8" alt="Specification complete"></a>
  <a href="https://66ideas.com"><img src="https://img.shields.io/badge/by-66IDEAS-16181D" alt="By 66IDEAS"></a>
</p>

**MD22 is a specification-first, open-source Markdown viewer, with a native
macOS reference implementation.** It is for the README in a project folder,
the long document you want to settle into, and the Markdown file you want to
share as a beautifully formatted PDF. No vault, no import, no editing.

The specifications describe the product; the implementations bring it to life.
Use the Mac app, improve the specifications, or build another implementation
on a different platform. The first implementation targets **macOS 26+ and
Apple silicon**, with native Liquid Glass chrome independent of document themes.

## What MD22 does

- **Beautiful reading themes:** Light, Dark, Sci-Fi, Blueprint, and 8-Bit, with
  shared controls for text size, line spacing, and reading width.
- **Focused long-document reading:** a collapsible heading outline, full-text
  search with highlighted matches, bookmarks, remembered reading positions,
  reading progress, and distraction-free mode.
- **Rich Markdown rendering:** tables, task lists, syntax-highlighted code,
  images, links, footnotes, mathematical notation, Mermaid diagrams, and callouts.
- **Files stay where they belong:** persistent history, pinned files, automatic
  refresh when the source changes, Reveal in Finder, and multiple document windows.
  Open files from Finder, the Open dialog, or drag and drop.
- **Publication exports:** HTML and paginated A4 PDF, with an export theme
  independent of the reading theme. Files are saved beside the Markdown source;
  existing exports are never overwritten.

Version 1 is deliberately **read-only**. MD22 does not modify your Markdown
source, manage a knowledge-base vault, or require an account.

## Get started

### Use the Mac app

Requires **macOS 26 or later on an Apple-silicon Mac**. Intel Macs, Windows,
and Linux do not have a published implementation in this repository yet.

Check [GitHub Releases](https://github.com/66IDEAS/MD22/releases) for packaged
downloads. As of September 9, 2026, no public signed and notarized installer
has been published. Version 1 is available as source; you can build a private
local copy using the instructions below.

Once installed, open a Markdown file or drop it into the window. Use the history
on the left to revisit documents and the outline or bookmarks on the right to
navigate. The export menu offers **Export as HTML**, **Export as PDF**, and
**Theme**; selecting a theme changes the export preference without creating a file.

### Build a local copy

See the [macOS implementation guide](implementations/mac/README.md) for
prerequisites, the private-build script, installation, and tests. The script
packages and ad-hoc signs the app and its embedded framework; a raw unsigned
Xcode build is not a portable installer.

Public release signing and notarization are separate maintainer steps, described
in [Direct Distribution](docs/DISTRIBUTION.md).

## Repository layout

| Path | Purpose |
| --- | --- |
| [`specs/`](specs/) | Functional requirements, UX, architecture, and implementation tracking |
| [`implementations/mac/`](implementations/mac/) | Native macOS reference implementation, built with SwiftUI and WebKit |
| [`implementations/mac/web/`](implementations/mac/web/) | Markdown rendering, bundled themes, and publication styles |
| [`implementations/mac/MD22Tests/`](implementations/mac/MD22Tests/) and [`MD22UITests/`](implementations/mac/MD22UITests/) | Rendering, export, lifecycle, and interface regression tests |
| [`docs/`](docs/) | Apple-platform conformance, distribution, and supply-chain guidance |
| `implementations/<name>/` | A separate home for each future implementation |

## The specification

- [Functional specification](specs/specifications.md): user stories, acceptance
  criteria, and the boundary between Version 1 and Phase 2.
- [UX specification](specs/ux.md): reading layout, navigation, themes, and interactions.
- [Architecture](specs/architecture.md): the current macOS implementation's
  technical decisions, rendering pipeline, persistence, testing, and distribution.
- [Task list](specs/tasks.md) and [bug tracker](specs/bugs.md): implementation
  progress, reported defects, and verification notes.

The functional and UX specifications are the starting point for another
implementation. The current architecture includes Apple-specific decisions;
document how a new platform implements or deliberately differs from them.

## Privacy

MD22 has no accounts, analytics, telemetry, or cloud document processing. Markdown rendering, search, bookmarks, history, and export remain on the Mac. The private WebKit renderer blocks remote code and styles; only resources that a document explicitly references may be loaded, while external links open in the default application.

## Contributing

Issues and pull requests are welcome for the specifications, documentation, and
implementations. Start with [CONTRIBUTING.md](CONTRIBUTING.md) for bug reports,
proposed behavior changes, and adding another implementation.

Keep proposals focused, preserve the read-only source-file guarantee, and include
verification appropriate to the change. Never attach private documents, signing
credentials, or access tokens to an issue or pull request.

## License

[MIT](LICENSE) — free to use, modify, and distribute, including commercially,
under the terms of the license. Third-party dependencies retain their own licenses.

---

<p align="center"><sub>A <a href="https://66ideas.com">66IDEAS</a> product · WENIGER. ABER BESSER.</sub></p>
