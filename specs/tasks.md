# MD22 Implementation Tasks

This backlog is ordered by implementation dependency within the two approved delivery phases. No additional MVP or intermediate release split is used.

Requirement IDs use these prefixes:

- `ARCH-n`: technical architecture requirement in `specs/architecture.md`
- `UX-n`: user-experience requirement in `specs/ux.md`
- `FR-n`: functional requirement in `specs/specifications.md`

## Phase 1

### Foundation and Repository

- [x] **T001 — Create the native macOS application foundation** (`ARCH-1`): Establish MD22 as a native Apple-platform application while keeping platform-independent rendering concepts reusable.
- [x] **T002 — Adopt the macOS 26 platform generation** (`ARCH-4`): Set macOS 26 as the minimum and use current SwiftUI, Observation, windowing, inspector, command, WebKit, and Liquid Glass capabilities.
- [x] **T003 — Configure Apple-silicon-only builds** (`ARCH-9`): Build and distribute only the `arm64` architecture.
- [x] **T004 — Establish MIT licensing and notices** (`ARCH-6`): Add the MIT license and a policy for preserving compatible third-party attributions across source and distributed artifacts.
- [x] **T005 — Integrate the fixed MD22 brand assets** (`UX-21`): Add the supplied icon and logo without redesign, recoloring, or theme-driven reinterpretation.
- [x] **T006 — Organize the open-source repository** (`ARCH-2`): Make source, build configuration, rendering assets, dependency versions, and replaceable boundaries suitable for public development.
- [x] **T007 — Create modular concurrency-safe boundaries** (`ARCH-12`): Separate file access, rendering, persistence, export, updates, and platform integration behind protocols and actor-isolated services.
- [x] **T008 — Prepare the renderer for app-extension reuse** (`ARCH-19`): Keep parsing, semantic HTML, themes, resource mapping, and bookmark-location logic independent of the main app and persistence store.
- [x] **T009 — Establish Apple-platform conformance criteria** (`ARCH-3`): Define implementation checks for macOS conventions, accessibility, privacy, security, menus, windows, signing, and notarization.
- [x] **T010 — Add dependency and release supply-chain controls** (`ARCH-17`): Commit lockfiles, enable dependency monitoring, enforce license and vulnerability policy, and prepare SBOM, checksums, provenance, and immutable releases.
- [x] **T011 — Establish accessibility and localization foundations** (`ARCH-22`): Use semantic native and HTML structures, honor system accessibility settings, and externalize all strings through String Catalogs.
- [x] **T012 — Apply the native Liquid Glass visual language** (`UX-1`): Style the application shell, controls, sidebars, selection, spacing, and motion according to current macOS conventions.
- [x] **T013 — Build independent application appearances** (`UX-2`): Provide polished System, Light, and Dark application chrome that remains independent from document themes.
- [x] **T014 — Construct the reading-first window composition** (`UX-3`): Make the document dominant, with compact left history, narrower right inspector, and quiet bottom status areas that yield space appropriately.

### Application Shell and File Opening

- [x] **T015 — Build the focused unified toolbar** (`UX-4`): Implement the approved leading navigation, central Open and Export, trailing search and inspector, contextual actions, menus, and keyboard discoverability.
- [x] **T016 — Centralize native file and window routing** (`ARCH-21`): Route UTType registration, Finder and Open With events, drops, commands, links, history, bookmarks, new windows, Finder reveal, and external URLs through shared services.
- [x] **T017 — Support direct Markdown opening** (`FR-9`): Implement Open, file association, double-click, Open With, history insertion, and standard keyboard access without importing files.
- [x] **T018 — Support drag-and-drop viewing** (`FR-1`): Accept valid Markdown drops, render them, add them to history, and reject invalid drops without disrupting the current document.
- [x] **T019 — Implement the first-launch and drop experience** (`UX-13`): Present the complete window shell, restrained welcome content, drop emphasis, native Open action, and calm invalid-item feedback.
- [x] **T020 — Enforce a read-only viewer experience** (`FR-7`): Exclude editing and source-save workflows, accounts, vaults, folder indexing, and startup dashboards while guaranteeing that source Markdown is never modified.

### Persistence, History, and Pins

- [x] **T021 — Implement application-scoped local persistence** (`ARCH-11`): Store structured metadata in SwiftData, simple preferences in app defaults, no project sidecars, and resilient file identity through bookmarks and stable identifiers.
- [x] **T022 — Add versioned persistence migration and recovery** (`ARCH-18`): Define schema versions, tested migrations, pre-migration backups, damaged-store preservation, and safe recovery.
- [x] **T023 — Implement persistent history management** (`FR-2`): Maintain unique recency-ordered entries, removal and clearing rules, retained reading data and bookmarks, pins, and unavailable-file states.
- [x] **T024 — Build the scan-first history sidebar** (`UX-5`): Present Pinned and Recent sections, two-line identity, native selection, accessible unavailable states, contextual actions, reordering, and restrained clearing controls.
- [x] **T025 — Implement history selection behavior** (`FR-3`): Display selected available files, identify selection clearly, and leave the current document intact when an unavailable entry is chosen.
- [x] **T026 — Implement pinned history entries** (`FR-20`): Add direct pinning, pinned-first ordering, manual reordering, persistence, unavailable states, and preservation during history clearing.
- [x] **T027 — Reveal files in Finder** (`FR-4`): Reveal and select the chosen file in Finder and disable the action when the file cannot be accessed.

### File Lifecycle and Reading Continuity

- [x] **T028 — Implement coordinated file access and monitoring** (`ARCH-14`): Use coordinated asynchronous reads, debounced filesystem events, immutable snapshots, sequencing guards, and strictly read-only source handling.
- [x] **T029 — Automatically refresh changed files** (`FR-16`): Refresh saved changes, preserve heading and reading position where possible, report refresh briefly, and mark inaccessible sources unavailable.
- [x] **T030 — Implement calm loading and lifecycle feedback** (`UX-14`): Avoid spinner flicker, preserve the current view during transitions, show nonmodal unavailability, and render clear inline failures for missing or invalid content.
- [x] **T031 — Persist and restore reading continuity** (`FR-17`): Remember positions per file, reopen the last document and position, and retain positions independently from history membership.

### Secure Markdown Rendering

- [x] **T032 — Build the local rich-rendering stack** (`ARCH-7`): Bundle pinned markdown-it, KaTeX, Mermaid, Highlight.js, and DOMPurify assets in WebKit with CSP, sanitization, navigation policy, and a narrow native bridge.
- [x] **T033 — Enforce the local-first privacy boundary** (`ARCH-10`): Keep content processing local, exclude accounts and telemetry, restrict networking, block remote active content, and open external links outside MD22.
- [x] **T034 — Build one canonical rendering and export pipeline** (`ARCH-13`): Share parser configuration, semantic HTML, extensions, anchors, theme tokens, and assets across reading, HTML, and PDF output.
- [x] **T035 — Render the complete rich Markdown set** (`FR-11`): Support highlighted code and copy, tables, read-only tasks, footnotes, math, Mermaid, callouts, and sanitized embedded HTML with graceful partial failure.
- [x] **T036 — Style rich content coherently** (`UX-19`): Apply the approved themed treatments for code, tables, tasks, callouts, footnotes, mathematics, Mermaid, embedded HTML, and wide-content overflow.
- [x] **T037 — Resolve and navigate project-relative content** (`FR-10`): Render local images, follow Markdown links and anchors, open external links appropriately, support back and forward, and communicate missing targets without indexing a project.
- [x] **T038 — Implement spatially clear link feedback** (`UX-18`): Show destinations, preserve navigation locations, emphasize anchor targets, distinguish external and broken links, and maintain accessible focus and visited states.

### Themes and Reading Appearance

- [x] **T039 — Establish the declarative theme package model** (`ARCH-20`): Define the versioned manifest, design tokens, scoped CSS, static assets, validation rules, security limits, and document-only rendering boundary.
- [x] **T040 — Implement built-in display-theme selection** (`FR-8`): Provide Light, Dark, Sci-Fi, Blueprint, and 8-Bit themes with instant status-bar switching, strong identities, legibility, and independence from export styling.
- [x] **T041 — Build the theme-driven document canvas** (`UX-6`): Fill the central pane with the selected theme, center readable prose, provide wide lanes and safe overflow, and reveal content controls only contextually.
- [x] **T042 — Create the five approved theme identities** (`UX-9`): Implement the complete Light, Dark, Sci-Fi, Blueprint, and 8-Bit visual systems, including rich elements, restrained motion, and readability overrides.
- [x] **T043 — Implement global reading customization** (`FR-15`): Support font size, line spacing, content width, reduced motion, high contrast, global overrides, and reset without modifying source files.
- [x] **T044 — Build live reading controls** (`UX-15`): Present the anchored status-bar popover with immediate updates, compact controls, reset, and correct focus restoration.

### Long-Document Navigation and Bookmarks

- [x] **T045 — Implement the heading outline** (`FR-13`): Build the right-panel outline hierarchy, heading navigation, current-section tracking, collapse behavior, and refresh updates.
- [x] **T046 — Build the quiet Outline and Bookmarks inspector** (`UX-7`): Implement its segmented tabs, restrained outline tracking, compact bookmark rows, scope filter, contextual actions, and accessible unavailable states.
- [x] **T047 — Implement document bookmarks** (`FR-19`): Support heading, passage, and position bookmarks; current and all-file scopes; retained metadata; target restoration; and removal of invalidated targets without changing source.
- [x] **T048 — Implement immediate contextual bookmarking** (`UX-11`): Add margin, selection, menu, keyboard, confirmation, and direct-removal interactions without modal naming or forced tab changes.
- [x] **T049 — Implement in-document search** (`FR-12`): Search only the displayed document, highlight all matches, report active and total counts, and support previous, next, and standard keyboard interaction.
- [x] **T050 — Build the compact toolbar search experience** (`UX-10`): Expand search in place, use accessible theme-aware highlights, preserve orientation, show section context and empty results, and restore focus on close.
- [x] **T051 — Compute and present reading status** (`FR-14`): Show and update progress, current section, word count, and estimated reading time in the bottom status bar.
- [x] **T052 — Build the quiet status-bar hierarchy** (`UX-8`): Add its progress track, information layout, theme and reading controls, temporary messages, responsive collapse, and keyboard access.

### Layout, Accessibility, and Multiple Windows

- [x] **T053 — Implement controllable reading layout** (`FR-18`): Show all support regions on first launch, allow independent visibility, add distraction-free reading, expand content, and persist subsequent choices.
- [x] **T054 — Implement responsive panels and distraction-free mode** (`UX-16`): Support native resizing, transitions, narrow-window overlays, restoration, per-window layouts, and standard full-screen toolbar behavior.
- [x] **T055 — Complete keyboard and assistive access** (`UX-17`): Implement predictable region focus, standard reading and list keys, visible focus affordances, VoiceOver semantics, shortcut discovery, and accessibility-setting adaptations.
- [x] **T056 — Open history entries and bookmarks in new windows** (`FR-22`): Preserve the originating window, restore files or bookmark targets, permit duplicate-file windows, and re-add retained bookmark files to history.
- [x] **T057 — Implement native multiwindow continuity** (`UX-25`): Cascade and identify new windows, inherit global appearance, keep window state independent, emphasize bookmark arrival, and preserve standard macOS window behavior.

### Export

- [x] **T058 — Export the displayed document to HTML** (`FR-5`): Save beside the source using safe numbered filenames, preserve document structure without reader navigation UI, and report the resulting file or failure.
- [x] **T059 — Export the displayed document to PDF** (`FR-6`): Produce polished adjacent PDFs with safe numbered filenames, no reader navigation artifacts, and clear success or failure feedback.
- [x] **T060 — Implement independent remembered export styling** (`FR-21`): Select format and export theme independently, default to Light, remember one theme across formats, preserve publication consistency, and make motion static.
- [x] **T061 — Build the one-step export interaction** (`UX-12`): Implement the split button, remembered primary action, immediate alternatives, nonblocking progress, success and Finder reveal, silent numbering, and anchored retry feedback.

### Settings, Updates, and Support

- [x] **T062 — Integrate secure Sparkle updates** (`ARCH-8`): Add stable Sparkle 2 through SwiftPM with an HTTPS appcast, signed and notarized updates, automatic checks, and a manual check command.
- [x] **T063 — Build minimal Settings and About windows** (`UX-20`): Present General appearance and update controls, inline status, standard application information, the GitHub link, license, and third-party acknowledgements without duplicating reading controls.
- [x] **T064 — Add privacy-safe local diagnostics** (`ARCH-24`): Use categorized Unified Logging, redact user-derived values, avoid automatic transmission, and create explicit, inspectable diagnostic packages.

### Quality, Performance, and Delivery

- [x] **T065 — Establish responsiveness and cancellation budgets** (`ARCH-23`): Add small, 1 MB, 10 MB, and rich-content performance fixtures; measure critical flows; cancel obsolete work; and prevent main-actor blocking.
- [x] **T066 — Build the layered automated test suite** (`ARCH-16`): Cover units, integrations, UI flows, fixtures, conformance, semantic output, theme and export regression, migrations, lifecycle, multiwindow, accessibility, and performance.
- [x] **T067 — Configure direct signed and notarized distribution** (`ARCH-5`): Enable Developer ID signing and Hardened Runtime, omit App Sandbox, notarize releases, and verify expected adjacent-file access.
- [x] **T068 — Automate GitHub builds and releases** (`ARCH-15`): Run protected CI and create signed, notarized arm64 DMGs, immutable GitHub releases, and signed Sparkle appcasts with protected secrets.

## Phase 1 Stabilization

- [x] **T075 — Create the Phase 1 bug tracker**: Record user-reported defects with portable screenshot evidence, expected behavior, status, verification, and fix commits in `specs/bugs.md`.
- [x] **T097 — Restore the one-step export shortcut** (`B012`): Assign Command-E to the remembered export action and verify that it creates the selected output format for the active document.
- [x] **T098 — Restore the document bookmark shortcut** (`B013`): Expose Add Bookmark in the File menu, assign Command-D, and verify confirmation for the active document.
- [x] **T099 — Use keyboard-layout-independent history navigation** (`B014`): Replace bracket shortcuts with Command-Left Arrow and Command-Right Arrow and verify backward and forward linked-document navigation.
- [x] **T076 — Remove the duplicate history-sidebar toggle** (`B001`): Retain one native toolbar control for expanding and collapsing history.
- [x] **T077 — Prevent duplicate logical bookmarks** (`B002`): Make repeated heading, passage, and position bookmark creation idempotent and verify persistence.
- [x] **T078 — Add direct filled-star bookmark removal** (`B003`): Use a filled star for inspector bookmark rows and remove the selected bookmark when its star is activated.
- [x] **T079 — Persist the visible bookmarked state in the reader** (`B004`): Keep the current target's filled star visible and make it toggle bookmark removal.
- [x] **T080 — Focus and simplify document search** (`B005`): Focus the field when search opens and remove its redundant visible placeholder.
- [x] **T081 — Add the standard export toolbar icon** (`B006`): Display a recognizable native export symbol on the primary toolbar action.
- [x] **T082 — Flatten status-bar theme selection** (`B007`): Present all document themes immediately without an intermediate submenu.
- [x] **T083 — Make distraction-free reading a direct toolbar toggle** (`B008`): Remove independent status-bar hiding and toggle distraction-free mode with one click.
- [x] **T084 — Expand the complete outline initially** (`B009`): Reveal every heading level when an outline opens while preserving native per-branch collapse controls.
- [x] **T085 — Remove shared toolbar control backgrounds** (`B010`): Suppress circular and pill-shaped shared backgrounds without changing toolbar actions or accessibility.
- [x] **T086 — Expose one document-window command** (`B011`): Present one New Window command while retaining typed open-in-new-window routing as an internal scene.
- [x] **T087 — Establish a multi-implementation repository layout**: Move the native macOS implementation from `dev/` to `implementations/mac/`, update repository tooling and documentation, remove the obsolete `dev/` directory, and verify the complete implementation from its new location.

## Phase 2

- [ ] **T069 — Add full-screen document presentation** (`FR-23`): Present ordinary Markdown full-screen, hide application chrome, navigate headings, use the display theme, and preserve read-only source behavior.
- [ ] **T070 — Build the phase-two presentation experience** (`UX-22`): Use an edge-to-edge themed document, distance-readable type, and a transient navigation HUD that yields completely to the content.
- [ ] **T071 — Add installable theme packs** (`FR-24`): Import, select, and remove additional themes while preserving built-ins, source files, and global readability preferences.
- [ ] **T072 — Build phase-two theme-pack management** (`UX-23`): Add a focused Themes settings pane with compact previews, attribution, native import and removal, and clear validation feedback.
- [ ] **T073 — Add Finder Quick Look previews** (`FR-25`): Render Markdown in Finder without modifying it and preserve the system path into the full application.
- [ ] **T074 — Build the phase-two Quick Look experience** (`UX-24`): Provide fast, chrome-free, system-matched Light or Dark previews with rich content adapted to the constrained surface.

## Resolved Implementation Issues

- [x] **E001 — Resolve generated test-module collisions**: Assign explicit, distinct product and module names to the unit-test and UI-test bundles so Xcode can build both in one scheme.
- [x] **E002 — Enable app-module testability in Debug builds**: Explicitly enable testability and unoptimized Swift compilation for Debug because generated target settings did not inherit those flags.
- [x] **E003 — Preserve testable app symbols**: Disable dead-code stripping for Debug app builds so hosted tests can link internal symbols that are intentionally not referenced by the executable.
- [x] **E004 — Link hosted tests against the app**: Set the unit-test bundle loader explicitly so internal MD22 symbols resolve against its test host under generated Xcode 26 projects.
- [x] **E005 — Correct the container renderer pin**: Replace the unpublished `markdown-it-container` 4.0.1 reference with the verified 4.0.0 release before producing the dependency lockfile.
- [x] **E006 — Resolve Markdown UTTypes dynamically**: Build accepted content types from registered Markdown filename extensions because the macOS 26 SDK does not expose a static `UTType.markdown` member.
- [x] **E007 — Import Foundation in persistence tests**: Add the explicit Foundation dependency required for filesystem URL construction under Swift 6's stricter module imports.
- [x] **E008 — Separate throwing migration setup from test unwrapping**: Evaluate the throwing backup operation before `#require` so Swift Testing can unwrap the optional result without masking error handling.
- [x] **E009 — Make file-type validation actor independent**: Mark the pure Markdown URL validator nonisolated so drag decoding can reuse it without losing MainActor isolation.
- [x] **E010 — Use concrete colors for conditional history styling**: Resolve SwiftUI shape-style inference explicitly when switching unavailable history labels between secondary and error colors.
- [x] **E011 — Handle dependency packages without license files**: Preserve the declared package-license metadata when an upstream renderer package omits a standalone license file from its distribution.
- [x] **E012 — Construct a mutable WebPage configuration**: Use value semantics correctly while configuring the private WebKit data store and subresource policy.
- [x] **E013 — Await WebPage navigation before renderer readiness**: Consume the structured navigation event sequence before probing the page bridge, allowing large bundled renderer assets to finish initial execution.
- [x] **E014 — Surface renderer startup diagnostics in tests**: Capture local JavaScript startup failures without exposing document content so WebKit integration failures can be diagnosed deterministically.
- [x] **E015 — Return values from WebPage JavaScript calls**: Use explicit JavaScript returns because the macOS 26 bridge executes supplied source as an asynchronous function body rather than an expression evaluator.
- [x] **E016 — Normalize generated renderer whitespace**: Remove line-ending whitespace emitted inside bundled grammar literals so repository hygiene checks remain deterministic.
- [x] **E017 — Preserve fragments on project-relative links**: Resolve local paths independently from percent-encoded heading fragments so cross-document anchor navigation retains its target.
- [x] **E018 — Isolate defaults in concurrent session tests**: Inject per-test defaults suites so parallel document sessions cannot race over the application-level restoration key.
- [x] **E019 — Align duplicate heading anchors across native and web renderers**: Use the same zero-based duplicate suffix progression so outline, links, bookmarks, reading state, and rendered headings share stable identifiers.
- [x] **E020 — Decode JavaScript numbers and preserve heading labels**: Bridge numeric search state through `NSNumber` and exclude contextual bookmark glyphs from semantic outline and search-section titles.
- [x] **E021 — Address WebPage arguments by their declared names**: Use the macOS 26 JavaScript bridge's named parameters directly so theme, reading, navigation, restoration, and search commands execute correctly.
- [x] **E022 — Split the document-window modifier graph**: Break the large SwiftUI modifier expression into smaller typed view stages so Swift 6 can type-check the complete window lifecycle deterministically.
- [x] **E023 — Use the declared renderer verification path**: Run renderer integration tests through the Xcode test target because the asset package intentionally exposes build and audit scripts rather than an npm test script.
- [x] **E024 — Remove duplicate native panel constraints**: Keep each split-view width contract at one view boundary so AppKit can satisfy the native sidebar and inspector constraints without recovery warnings.
- [x] **E025 — Isolate HTML publication preparation from the reader**: Wait for fonts and images without mutating the visible page's display theme, search state, or reader controls before cloning its static export DOM.
- [x] **E026 — Scope document commands to the focused window**: Route menu and keyboard actions through SwiftUI focused values so commands affect only the active window in a multiwindow session.
- [x] **E027 — Preserve build status through zsh pipelines**: Avoid Bash-specific `PIPESTATUS` checks when validating piped Xcode builds under the repository's zsh command environment.
- [x] **E028 — Preserve asynchronous read return semantics after logging**: Return the detached coordinated-read result explicitly after adding a preceding Unified Logging statement.
- [x] **E029 — Decode diagnostic timestamps consistently**: Configure the package test decoder for the ISO 8601 date representation emitted by the diagnostic manifest.
- [x] **E030 — Keep diagnostic package creation responsive**: Mirror bounded privacy-safe event codes alongside categorized Unified Logging instead of synchronously enumerating the process log store.
- [x] **E031 — Import Foundation for bundle conformance checks**: Add the explicit module import required by Swift 6 when the foundation test inspects application metadata and bundled legal resources.
- [x] **E032 — Distinguish inert unsafe-link text from executable links**: Assert that sanitization removes a `javascript:` href while allowing the rejected Markdown syntax to remain visible as harmless readable text.
- [x] **E033 — Provide a default typed window value**: Supply an explicit welcome request for the value-based `WindowGroup` so a full reader window opens on ordinary application launch.
- [x] **E034 — Handle nonoptional value-window bindings**: Adapt the default-value `WindowGroup` content closure to its concrete bound request while translating the welcome sentinel into no initial document.
- [x] **E035 — Restore explicit request construction**: Add the private complete initializer needed for synthetic welcome requests after the route initializer suppressed Swift's memberwise initializer.
- [x] **E036 — Align UI-test identities without a development certificate**: Ad-hoc sign the disposable target application and complete macOS UI-test runner after an unsigned build so Launch Services and XCTest can load them on credential-free CLI and CI hosts.
- [x] **E037 — Separate default and routed window scenes**: Use an ordinary `WindowGroup` with explicit presented launch behavior for the welcome and New Window experience while retaining a value-based group for targeted history and bookmark windows.
- [x] **E038 — Restore embedded-framework runtime lookup**: Preserve the inherited macOS framework runpath in generated target settings so the bundled Sparkle framework loads in standalone and UI-test launches.
- [x] **E039 — Restore the generated Debug compilation condition**: Declare the standard `DEBUG` Swift condition explicitly so test-only launch fixtures remain excluded from releases and available to the UI suite.
- [x] **E040 — Use Xcode's supported generic macOS archive destination**: Select the generic macOS destination and enforce Apple silicon through the target `ARCHS` setting because Xcode rejects an architecture qualifier on `Any Mac`.
- [x] **E041 — Export archives through Xcode's Developer ID distribution path**: Run `xcodebuild -exportArchive` with committed export policy so Sparkle helpers and the final application receive Xcode's complete distribution-signing treatment.
- [x] **E042 — Verify Sparkle's signed-feed trailer**: Validate the signed appcast's trailing EdDSA signature block in addition to each update archive signature because Sparkle stores the feed signature in a dedicated XML comment.
- [x] **E043 — Constrain incomplete dependency license metadata**: Tie the reviewed MIT license for `khroma` to its exact locked version because the distributed package includes the license text but omits its metadata field.
- [x] **E044 — Declare custom workflow shells explicitly**: Use GitHub Actions' `zsh {0}` custom-shell form so inline release scripts retain zsh semantics and pass workflow validation.
- [x] **E045 — Preflight immutability with least privilege**: Query GitHub's administration-read immutable-release endpoint with a narrowly scoped protected token because the ordinary workflow token cannot receive that permission, while retaining the short-lived workflow token for publication.
- [x] **E046 — Resolve recursive outline identifier inference**: Accumulate expandable heading identifiers explicitly so Swift 6 preserves the concrete `Set<String>` element type through recursive branches.
- [x] **E047 — Rebase repository-level resources after implementation nesting**: Resolve shared specification assets and release legal files from the repository root after moving the macOS project two levels below it.
