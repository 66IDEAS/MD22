# Apple Platform Conformance

Every Phase 1 release must satisfy these checks on macOS 26 and Apple silicon.

## Interaction and presentation

- Windows, menus, commands, toolbars, inspectors, panels, file pickers, alerts,
  context menus, keyboard shortcuts, focus, and full-screen behavior use native
  macOS conventions.
- Application chrome uses system materials and remains independent from the
  selected document theme.
- All actions are keyboard reachable, labels are exposed to VoiceOver, focus is
  visible, contrast is sufficient, and Reduce Motion/Increase Contrast settings
  are honored.
- User-facing strings are localizable and no path is the sole identity cue.

## Files, privacy, and security

- Source Markdown is opened in place and never written by MD22.
- File reads are coordinated; metadata stays in Application Support and defaults,
  never in a project sidecar.
- Parsing and rendering are local. There are no accounts, analytics, telemetry,
  advertising identifiers, or automatic diagnostic uploads.
- Rendered HTML is sanitized, governed by a restrictive CSP, and cannot execute
  remote scripts. External links leave the application.

## Distribution

- The app requires macOS 26, contains only arm64 code, uses Hardened Runtime,
  and does not use App Sandbox.
- Release archives are signed with Developer ID Application, notarized, stapled,
  assessed by Gatekeeper, and distributed in a signed DMG.
- Sparkle updates use HTTPS and EdDSA signatures. Dependency versions, licenses,
  checksums, and an SBOM accompany each immutable release.

The automated conformance script enforces machine-verifiable items; the release
checklist records manual VoiceOver, keyboard, visual, and Gatekeeper inspection.

