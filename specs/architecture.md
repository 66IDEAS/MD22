# Technical Architecture Requirements

## 1. Native macOS First Implementation

**Description:** The first implementation must be a native macOS application built with Apple platform technologies. Cross-platform delivery is not part of the initial architecture scope, but the internal design should avoid unnecessary coupling that would prevent later reuse of platform-independent rendering concepts.

## 2. Open-Source Development

**Description:** The application source, build configuration, and bundled rendering assets must be suitable for public open-source development. Dependencies must have licenses compatible with the project's eventual open-source license, be reproducibly versioned, and remain replaceable behind explicit architectural boundaries.

## 3. Apple Platform Conformance

**Description:** The architecture must use current, supported Apple frameworks and enable the application to follow Apple's macOS design conventions, accessibility guidance, privacy expectations, security practices, window and menu behaviors, keyboard interaction patterns, code-signing requirements, and notarized distribution practices.

## 4. macOS 26 Minimum Deployment Target

**Description:** Version 1 must target macOS 26 or later and use the current macOS 26 generation of Apple technologies without compatibility layers for earlier macOS releases. The application shell must use SwiftUI's current windowing, scene, observation, inspector, command, and WebKit integration APIs. The interface must adopt native Liquid Glass materials and behaviors through supported system components rather than custom visual imitation.

## 5. Direct Notarized Distribution

**Description:** Version 1 must be distributed directly rather than through the Mac App Store. Release builds must use Developer ID signing, the Hardened Runtime, and Apple notarization. The application will not adopt App Sandbox in version 1 so that explicitly opened Markdown files can resolve project-relative resources and create adjacent exports without additional folder-permission workflows.

## 6. MIT Project License

**Description:** MD22 source code must be released under the MIT License. All included source, packages, generated artifacts, fonts, icons, themes, and bundled renderer libraries must have licenses that permit redistribution in an MIT-licensed open-source application, with required attribution and license notices preserved.

## 7. Local Rich-Rendering Stack

**Description:** Markdown content must be rendered locally through WebKit for SwiftUI using `WebView` and `WebPage`. The renderer must bundle pinned versions of markdown-it, KaTeX, Mermaid, Highlight.js, and DOMPurify with the application rather than loading scripts, styles, fonts, or other executable resources from a CDN. The web-content boundary must use sanitization, a restrictive Content Security Policy, strict navigation handling, and a narrowly scoped native-to-JavaScript bridge. Third-party license notices must be included in the source repository and distributed application.

## 8. Secure Automatic Updates

**Description:** Directly distributed builds must use the current stable Sparkle 2 release for application updates. Sparkle must be integrated through Swift Package Manager, use an HTTPS appcast, verify updates with Sparkle's signing mechanism in addition to Apple code signing, and offer both automatic update checks and a manually initiated update check. Every published update must be Developer ID signed, Hardened Runtime enabled, and notarized before appearing in the update feed.

## 9. Apple Silicon Architecture

**Description:** MD22 must be built and distributed for Apple silicon only using the `arm64` architecture. Version 1 will not include an Intel `x86_64` slice or a Universal 2 build, even where an Intel Mac can run macOS 26.

## 10. Local-First Privacy Boundary

**Description:** MD22 must operate without an account, cloud backend, analytics, telemetry, or external crash-reporting service. Document parsing, rendering, search, bookmarking, persistence, and export must occur locally. Network access is limited to Sparkle update traffic and HTTPS resources explicitly referenced by an opened document. The renderer must block remote scripts and styles, prevent document content from invoking native capabilities, and send external links to the user's default browser.

## 11. Application-Scoped Local Persistence

**Description:** Structured application metadata, including history, pins, bookmarks, reading positions, and document identity, must be stored in a SwiftData database under the application's Application Support container. Simple application preferences must use `AppStorage` or `UserDefaults`. MD22 must not create sidecar files in source-project folders. File bookmark data and stable file identifiers must be used where possible to retain identity after a file is moved or renamed; unresolved files remain represented as unavailable metadata.

## 12. Modular Concurrency-Safe Application Architecture

**Description:** The native application shell must use SwiftUI and the Observation framework with explicit module and protocol boundaries for file access, rendering, persistence, export, updating, and platform integration. Potentially blocking file, rendering, and export operations must execute outside the main actor through structured Swift concurrency and actor-isolated services. Shared application metadata must remain consistent across windows, while each window owns an independent document session, navigation history, search state, outline state, and reading position.

## 13. Canonical Rendering and Export Pipeline

**Description:** On-screen rendering, HTML export, and PDF export must use one canonical Markdown parser configuration, semantic HTML representation, extension registry, stable heading-anchor algorithm, theme-token system, and bundled asset set. Export must consume the same rendering model as the reader instead of reparsing through an independent implementation. Format-specific output adapters may change packaging and pagination behavior but must not change document semantics. Rendering and export services must remain deterministic and independently testable.

PDF output must pass the canonical rendered HTML through WebKit's native print operation using portrait DIN A4 paper and explicit margins. Whole-content PDF capture is unsuitable because it produces one document-height page. A dedicated offscreen print adapter may use WKWebView while the reader continues to use WebPage; printing must save locally without showing a print panel or requiring a configured printer.

## 14. Coordinated File Access and Monitoring

**Description:** Source documents and project-relative resources must be accessed through coordinated Foundation file APIs, using `NSFileCoordinator` and `NSFilePresenter` where applicable. Reads and change monitoring must run asynchronously, coalesce bursts of filesystem events, and produce an immutable document snapshot before parsing begins. Generation identifiers or equivalent sequencing must prevent an older asynchronous render from replacing newer content. The file subsystem must remain read-only with respect to Markdown source files.

## 15. GitHub Build and Release Automation

**Description:** The canonical open-source repository must be hosted on GitHub. GitHub Actions must build and test pull requests and protected branches using the project's supported Xcode and macOS toolchain. A version-tagged release workflow must create an Apple-silicon DMG, sign every executable component with Developer ID, enable Hardened Runtime, submit the artifact with Apple's current notarization tooling, staple and verify the notarization ticket, publish release artifacts through GitHub Releases, and generate the signed Sparkle appcast. Signing credentials and update keys must be confined to protected release secrets and must never be exposed to pull-request workflows or committed to the repository.

## 16. Layered Automated Testing

**Description:** MD22 must use Swift Testing for unit and integration tests and XCTest with XCUIAutomation for end-to-end interface tests. The test suite must include a representative Markdown fixture corpus, parser and extension conformance cases, deterministic semantic-HTML snapshots, theme rendering comparisons, export validation, persistence migrations, filesystem lifecycle scenarios, multiwindow behavior, accessibility-critical workflows, and performance regression coverage. Tests that do not require UI automation must be runnable from both Xcode and the command line.

## 17. Dependency and Release Supply-Chain Controls

**Description:** Resolved SwiftPM and npm dependency versions must be committed and reproducible. GitHub dependency monitoring and security updates must be enabled, and CI must reject dependencies that violate the approved license policy or introduce disallowed known vulnerabilities. Each release must include an SPDX-compatible software bill of materials, cryptographic checksums, and verifiable build provenance. Published GitHub releases and their associated tags and assets must be immutable.

## 18. Versioned Persistence and Recovery

**Description:** Persistent metadata must use explicit SwiftData schema versions with automated, repeatable, and tested migration paths. Before a destructive schema migration, the existing local metadata store must be copied to a recoverable backup. If migration or store loading fails, the application must preserve the damaged store for diagnosis and recover to a usable state without reading from or writing to Markdown source files as part of recovery.

## 19. App-Extension-Ready Rendering Core

**Description:** Markdown parsing, semantic HTML generation, heading and bookmark location logic, theme resolution, and local-resource mapping must be packaged as reusable targets that do not depend on the main application's windows, commands, or SwiftData store. These targets and their bundled assets must be usable by a future Quick Look Preview Extension with the extension's restricted lifecycle and security environment. The Quick Look target must be able to return HTML and attachments through `QLPreviewReply` while using the same canonical renderer as the main application.

## 20. Declarative and Sandboxed Theme Architecture

**Description:** Built-in themes and future installable theme packs must conform to one versioned theme-package schema composed of a manifest, design tokens, scoped CSS, and local static assets. Theme packages must not contain executable JavaScript, native code, plugins, or remote asset references. The loader must validate schema versions, paths, content types, package size limits, and CSS constraints before a theme becomes available, and themes must render only within the document-content boundary.

## 21. Unified Native File and Window Routing

**Description:** The application must declare supported Markdown document types through Uniform Type Identifiers and route Finder events, Open With requests, drag-and-drop transfers, file-open commands, relative Markdown links, history entries, and bookmarks through one document-opening service. SwiftUI `WindowGroup`-based sessions must create independent windows for explicit new-window requests while sharing application-level persistence. Platform-specific file revelation and external-link behavior must be isolated behind AppKit integration adapters.

## 22. Accessibility and Localization Foundations

**Description:** Native interface elements must use semantic SwiftUI controls, and rendered documents must use semantic HTML with a coherent heading hierarchy and accessibility tree. Application and renderer behavior must honor system accessibility settings, including reduced motion, increased contrast, text sizing, and keyboard focus. All user-facing native and renderer strings must be externalized through Xcode String Catalogs from the initial implementation so localization does not require architectural rework.

## 23. Measured Responsiveness and Cancellation

**Description:** The project must maintain repeatable performance fixtures for small, 1 MB, and 10 MB Markdown documents, including representative rich content. Continuous integration must track launch, parsing, initial rendering, scrolling, search, and export performance on the supported Apple-silicon architecture. Opening, refreshing, or closing a document must cancel obsolete work, and filesystem, parsing, rendering, persistence, and export operations must not synchronously block the main actor.

## 24. Privacy-Safe Local Diagnostics

**Description:** Diagnostic events must use Apple Unified Logging with stable subsystems, categories, and severity levels. File paths, document content, rendered HTML, search terms, bookmarks, and other user-derived values must be omitted or explicitly marked private. Logs must remain local and must never be transmitted automatically. Any diagnostic package intended for support must be generated only through an explicit user action, apply redaction before packaging, and disclose the files that will be included.
