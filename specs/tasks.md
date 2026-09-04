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
- [ ] **T017 — Support direct Markdown opening** (`FR-9`): Implement Open, file association, double-click, Open With, history insertion, and standard keyboard access without importing files.
- [ ] **T018 — Support drag-and-drop viewing** (`FR-1`): Accept valid Markdown drops, render them, add them to history, and reject invalid drops without disrupting the current document.
- [ ] **T019 — Implement the first-launch and drop experience** (`UX-13`): Present the complete window shell, restrained welcome content, drop emphasis, native Open action, and calm invalid-item feedback.
- [ ] **T020 — Enforce a read-only viewer experience** (`FR-7`): Exclude editing and source-save workflows, accounts, vaults, folder indexing, and startup dashboards while guaranteeing that source Markdown is never modified.

### Persistence, History, and Pins

- [x] **T021 — Implement application-scoped local persistence** (`ARCH-11`): Store structured metadata in SwiftData, simple preferences in app defaults, no project sidecars, and resilient file identity through bookmarks and stable identifiers.
- [x] **T022 — Add versioned persistence migration and recovery** (`ARCH-18`): Define schema versions, tested migrations, pre-migration backups, damaged-store preservation, and safe recovery.
- [x] **T023 — Implement persistent history management** (`FR-2`): Maintain unique recency-ordered entries, removal and clearing rules, retained reading data and bookmarks, pins, and unavailable-file states.
- [ ] **T024 — Build the scan-first history sidebar** (`UX-5`): Present Pinned and Recent sections, two-line identity, native selection, accessible unavailable states, contextual actions, reordering, and restrained clearing controls.
- [ ] **T025 — Implement history selection behavior** (`FR-3`): Display selected available files, identify selection clearly, and leave the current document intact when an unavailable entry is chosen.
- [ ] **T026 — Implement pinned history entries** (`FR-20`): Add direct pinning, pinned-first ordering, manual reordering, persistence, unavailable states, and preservation during history clearing.
- [ ] **T027 — Reveal files in Finder** (`FR-4`): Reveal and select the chosen file in Finder and disable the action when the file cannot be accessed.

### File Lifecycle and Reading Continuity

- [ ] **T028 — Implement coordinated file access and monitoring** (`ARCH-14`): Use coordinated asynchronous reads, debounced filesystem events, immutable snapshots, sequencing guards, and strictly read-only source handling.
- [ ] **T029 — Automatically refresh changed files** (`FR-16`): Refresh saved changes, preserve heading and reading position where possible, report refresh briefly, and mark inaccessible sources unavailable.
- [ ] **T030 — Implement calm loading and lifecycle feedback** (`UX-14`): Avoid spinner flicker, preserve the current view during transitions, show nonmodal unavailability, and render clear inline failures for missing or invalid content.
- [ ] **T031 — Persist and restore reading continuity** (`FR-17`): Remember positions per file, reopen the last document and position, and retain positions independently from history membership.

### Secure Markdown Rendering

- [ ] **T032 — Build the local rich-rendering stack** (`ARCH-7`): Bundle pinned markdown-it, KaTeX, Mermaid, Highlight.js, and DOMPurify assets in WebKit with CSP, sanitization, navigation policy, and a narrow native bridge.
- [ ] **T033 — Enforce the local-first privacy boundary** (`ARCH-10`): Keep content processing local, exclude accounts and telemetry, restrict networking, block remote active content, and open external links outside MD22.
- [ ] **T034 — Build one canonical rendering and export pipeline** (`ARCH-13`): Share parser configuration, semantic HTML, extensions, anchors, theme tokens, and assets across reading, HTML, and PDF output.
- [ ] **T035 — Render the complete rich Markdown set** (`FR-11`): Support highlighted code and copy, tables, read-only tasks, footnotes, math, Mermaid, callouts, and sanitized embedded HTML with graceful partial failure.
- [ ] **T036 — Style rich content coherently** (`UX-19`): Apply the approved themed treatments for code, tables, tasks, callouts, footnotes, mathematics, Mermaid, embedded HTML, and wide-content overflow.
- [ ] **T037 — Resolve and navigate project-relative content** (`FR-10`): Render local images, follow Markdown links and anchors, open external links appropriately, support back and forward, and communicate missing targets without indexing a project.
- [ ] **T038 — Implement spatially clear link feedback** (`UX-18`): Show destinations, preserve navigation locations, emphasize anchor targets, distinguish external and broken links, and maintain accessible focus and visited states.

### Themes and Reading Appearance

- [ ] **T039 — Establish the declarative theme package model** (`ARCH-20`): Define the versioned manifest, design tokens, scoped CSS, static assets, validation rules, security limits, and document-only rendering boundary.
- [ ] **T040 — Implement built-in display-theme selection** (`FR-8`): Provide Light, Dark, Sci-Fi, Blueprint, and 8-Bit themes with instant status-bar switching, strong identities, legibility, and independence from export styling.
- [ ] **T041 — Build the theme-driven document canvas** (`UX-6`): Fill the central pane with the selected theme, center readable prose, provide wide lanes and safe overflow, and reveal content controls only contextually.
- [ ] **T042 — Create the five approved theme identities** (`UX-9`): Implement the complete Light, Dark, Sci-Fi, Blueprint, and 8-Bit visual systems, including rich elements, restrained motion, and readability overrides.
- [ ] **T043 — Implement global reading customization** (`FR-15`): Support font size, line spacing, content width, reduced motion, high contrast, global overrides, and reset without modifying source files.
- [ ] **T044 — Build live reading controls** (`UX-15`): Present the anchored status-bar popover with immediate updates, compact controls, reset, and correct focus restoration.

### Long-Document Navigation and Bookmarks

- [ ] **T045 — Implement the heading outline** (`FR-13`): Build the right-panel outline hierarchy, heading navigation, current-section tracking, collapse behavior, and refresh updates.
- [ ] **T046 — Build the quiet Outline and Bookmarks inspector** (`UX-7`): Implement its segmented tabs, restrained outline tracking, compact bookmark rows, scope filter, contextual actions, and accessible unavailable states.
- [ ] **T047 — Implement document bookmarks** (`FR-19`): Support heading, passage, and position bookmarks; current and all-file scopes; retained metadata; target restoration; and removal of invalidated targets without changing source.
- [ ] **T048 — Implement immediate contextual bookmarking** (`UX-11`): Add margin, selection, menu, keyboard, confirmation, and direct-removal interactions without modal naming or forced tab changes.
- [ ] **T049 — Implement in-document search** (`FR-12`): Search only the displayed document, highlight all matches, report active and total counts, and support previous, next, and standard keyboard interaction.
- [ ] **T050 — Build the compact toolbar search experience** (`UX-10`): Expand search in place, use accessible theme-aware highlights, preserve orientation, show section context and empty results, and restore focus on close.
- [ ] **T051 — Compute and present reading status** (`FR-14`): Show and update progress, current section, word count, and estimated reading time in the bottom status bar.
- [ ] **T052 — Build the quiet status-bar hierarchy** (`UX-8`): Add its progress track, information layout, theme and reading controls, temporary messages, responsive collapse, and keyboard access.

### Layout, Accessibility, and Multiple Windows

- [ ] **T053 — Implement controllable reading layout** (`FR-18`): Show all support regions on first launch, allow independent visibility, add distraction-free reading, expand content, and persist subsequent choices.
- [ ] **T054 — Implement responsive panels and distraction-free mode** (`UX-16`): Support native resizing, transitions, narrow-window overlays, restoration, per-window layouts, and standard full-screen toolbar behavior.
- [ ] **T055 — Complete keyboard and assistive access** (`UX-17`): Implement predictable region focus, standard reading and list keys, visible focus affordances, VoiceOver semantics, shortcut discovery, and accessibility-setting adaptations.
- [ ] **T056 — Open history entries and bookmarks in new windows** (`FR-22`): Preserve the originating window, restore files or bookmark targets, permit duplicate-file windows, and re-add retained bookmark files to history.
- [ ] **T057 — Implement native multiwindow continuity** (`UX-25`): Cascade and identify new windows, inherit global appearance, keep window state independent, emphasize bookmark arrival, and preserve standard macOS window behavior.

### Export

- [ ] **T058 — Export the displayed document to HTML** (`FR-5`): Save beside the source using safe numbered filenames, preserve document structure without reader navigation UI, and report the resulting file or failure.
- [ ] **T059 — Export the displayed document to PDF** (`FR-6`): Produce polished adjacent PDFs with safe numbered filenames, no reader navigation artifacts, and clear success or failure feedback.
- [ ] **T060 — Implement independent remembered export styling** (`FR-21`): Select format and export theme independently, default to Light, remember one theme across formats, preserve publication consistency, and make motion static.
- [ ] **T061 — Build the one-step export interaction** (`UX-12`): Implement the split button, remembered primary action, immediate alternatives, nonblocking progress, success and Finder reveal, silent numbering, and anchored retry feedback.

### Settings, Updates, and Support

- [ ] **T062 — Integrate secure Sparkle updates** (`ARCH-8`): Add stable Sparkle 2 through SwiftPM with an HTTPS appcast, signed and notarized updates, automatic checks, and a manual check command.
- [ ] **T063 — Build minimal Settings and About windows** (`UX-20`): Present General appearance and update controls, inline status, standard application information, the GitHub link, license, and third-party acknowledgements without duplicating reading controls.
- [ ] **T064 — Add privacy-safe local diagnostics** (`ARCH-24`): Use categorized Unified Logging, redact user-derived values, avoid automatic transmission, and create explicit, inspectable diagnostic packages.

### Quality, Performance, and Delivery

- [ ] **T065 — Establish responsiveness and cancellation budgets** (`ARCH-23`): Add small, 1 MB, 10 MB, and rich-content performance fixtures; measure critical flows; cancel obsolete work; and prevent main-actor blocking.
- [ ] **T066 — Build the layered automated test suite** (`ARCH-16`): Cover units, integrations, UI flows, fixtures, conformance, semantic output, theme and export regression, migrations, lifecycle, multiwindow, accessibility, and performance.
- [ ] **T067 — Configure direct signed and notarized distribution** (`ARCH-5`): Enable Developer ID signing and Hardened Runtime, omit App Sandbox, notarize releases, and verify expected adjacent-file access.
- [ ] **T068 — Automate GitHub builds and releases** (`ARCH-15`): Run protected CI and create signed, notarized arm64 DMGs, immutable GitHub releases, and signed Sparkle appcasts with protected secrets.

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
