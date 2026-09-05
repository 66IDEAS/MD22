# MD22 Bug Tracker

This file tracks defects found while exercising Phase 1. Each bug remains open
until its fix is committed and the stated verification has passed.

## B001 — Duplicate history-sidebar toggle

- **Status:** Fixed
- **Severity:** Medium
- **Actual:** Two adjacent toolbar buttons expose the same left-sidebar
  collapse and expand behavior.
- **Expected:** The window presents exactly one native history-sidebar toggle.
- **Evidence:** [Duplicate sidebar toggle](bugs/screenshots/B001-duplicate-sidebar-toggle.png)
- **Verification:** Removed the redundant custom toolbar item so the
  `NavigationSplitView` contributes the window's sole native sidebar toggle;
  the Debug application build passes.
- **Fix commit:** `fix: remove duplicate history toggle`

## B002 — Duplicate document bookmarks

- **Status:** Fixed
- **Severity:** High
- **Actual:** The same logical bookmark target can be added more than once and
  appears as duplicate rows in the Bookmarks inspector.
- **Expected:** A file can contain only one bookmark for a given logical target;
  repeating the add action must not create another record.
- **Evidence:** [Duplicate bookmark rows](bugs/screenshots/B002-duplicate-bookmarks.png)
- **Verification:** Repository tests confirm repeated heading, normalized passage,
  and nearby position targets reuse one record, distinct positions remain
  independent, and previously stored duplicates are coalesced on load.
- **Fix commit:** `fix: make bookmark creation idempotent`

## B003 — Bookmark rows use the wrong symbol and cannot toggle directly

- **Status:** Open
- **Severity:** Medium
- **Actual:** Bookmark rows use an `Aa`-style symbol and do not expose a direct
  star control for removal.
- **Expected:** Every bookmark row displays a filled star. Clicking that star
  removes only that bookmark.
- **Evidence:** [Bookmark row symbols](bugs/screenshots/B002-duplicate-bookmarks.png)
- **Verification:** Inspect the Bookmarks inspector, activate a row's filled
  star, and confirm that only the selected record is removed.
- **Fix commit:** Pending

## B004 — A bookmarked document target does not retain its visible star

- **Status:** Open
- **Severity:** Medium
- **Actual:** The document bookmark control remains subdued or transient after
  the current target has been bookmarked.
- **Expected:** The star stays visibly filled while the current document target
  is bookmarked and acts as a direct unbookmark control.
- **Evidence:** [Document bookmark visibility](bugs/screenshots/B004-bookmark-visibility.png)
- **Verification:** Bookmark the current target, move the pointer away, verify
  that the filled star remains visible, then click it and verify removal.
- **Fix commit:** Pending

## B005 — Search repeats “Find” and does not focus its input

- **Status:** Open
- **Severity:** Medium
- **Actual:** The expanded search control shows “Find” in both the empty input
  and the adjacent status, and the user must click before typing.
- **Expected:** The empty field has no redundant visible placeholder and receives
  keyboard focus immediately whenever search opens.
- **Evidence:** [Repeated Find label](bugs/screenshots/B005-search-find-duplicate.png)
- **Verification:** Press Command-F and type without clicking; confirm the query
  enters the field and only one empty-state Find label is visible.
- **Fix commit:** Pending

## B006 — Export toolbar control has no export icon

- **Status:** Open
- **Severity:** Low
- **Actual:** The toolbar's export control appears without a recognizable export
  glyph.
- **Expected:** The primary export action displays Apple's standard export/share
  symbol while preserving its one-step action and options menu.
- **Evidence:** [Missing export icon](bugs/screenshots/B006-missing-export-icon.png)
- **Verification:** Inspect the toolbar in enabled and disabled states and run
  the export-control UI test.
- **Fix commit:** Pending

## B007 — Document-theme selection has an unnecessary submenu

- **Status:** Open
- **Severity:** Medium
- **Actual:** Opening the status-bar theme control first shows a “Document Theme”
  submenu, requiring another pointer action before themes appear.
- **Expected:** Clicking the theme control immediately presents Light, Dark,
  Sci-Fi, Blueprint, and 8-Bit in one menu.
- **Evidence:** [Nested theme menu](bugs/screenshots/B007-nested-theme-menu.png)
- **Verification:** Click the status-bar theme control and confirm all five themes
  are immediately available and selectable.
- **Fix commit:** Pending

## B008 — Layout control requires a menu and exposes Hide Status Bar

- **Status:** Open
- **Severity:** Medium
- **Actual:** The toolbar layout control opens a menu containing an unwanted
  independent Hide Status Bar command and a second-step distraction-free action.
- **Expected:** The toolbar provides a one-click distraction-free toggle. The
  status bar is visible in the normal layout and hidden only as part of
  distraction-free reading.
- **Evidence:** [Layout menu](bugs/screenshots/B008-layout-menu.png)
- **Verification:** Toggle distraction-free reading on and off with one click;
  confirm supporting chrome hides and the normal status bar returns.
- **Fix commit:** Pending
