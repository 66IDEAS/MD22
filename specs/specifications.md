# Functional Specifications

## Version 1

### 1. Display a Dropped Markdown File

**Description:** As a user, I want to drag and drop a Markdown file into the application so that I can view its rendered content.

**Acceptance criteria:**

- The application accepts a Markdown file through drag and drop.
- After a valid Markdown file is dropped, its rendered content is displayed in the main panel.
- The dropped file is added to the file history.
- If the dropped file cannot be displayed, the application provides clear feedback without disrupting the currently displayed document.

### 2. View and Manage Markdown File History

**Description:** As a user, I want a persistent history of viewed Markdown files so that I can return to them and keep the list manageable.

**Acceptance criteria:**

- The history is displayed in a panel on the left side of the application.
- History persists across application restarts.
- Each file appears only once in history.
- Viewing an unpinned file moves it to the top of the unpinned history.
- The user can remove an individual history entry.
- Removing an entry does not remove its bookmarks or remembered reading position.
- The user can clear history while preserving pinned files.
- Clearing history does not remove bookmarks or remembered reading positions.
- An inaccessible file remains in history and is visibly marked as unavailable.
- The user can remove an unavailable file from history.
- The application does not provide a search or reconnection workflow for unavailable files.

### 3. Select a File from History

**Description:** As a user, I want to select a Markdown file from history so that I can display it again.

**Acceptance criteria:**

- Each available history entry can be selected.
- Selecting an entry displays that file's rendered Markdown content in the main panel.
- The selected history entry is visibly identifiable.
- Selecting an unavailable entry does not replace the currently displayed document and clearly communicates that the file is unavailable.

### 4. Open a Markdown File's Location

**Description:** As a user, I want to open the storage location of a selected Markdown file so that I can access it through my file browser.

**Acceptance criteria:**

- The user can invoke an action for a selected Markdown file to open its location.
- The location opens in Windows Explorer, macOS Finder, or the equivalent file browser on Linux.
- When supported by the operating system, the Markdown file is selected or highlighted in its containing folder.
- The action is unavailable when the file cannot be accessed.

### 5. Convert a Markdown File to HTML

**Description:** As a user, I want to convert the displayed Markdown file to HTML so that I can use its rendered content in a web-compatible format.

**Acceptance criteria:**

- The user can initiate HTML conversion for the displayed Markdown file.
- The HTML output is saved immediately beside the source file without a Save As dialog.
- The output uses the source file's base name with an `.html` extension.
- If that filename already exists, the application creates the next available numbered copy rather than overwriting it.
- The export preserves the source document's structure and does not add a generated table of contents, search, or other navigation content.
- The application communicates whether conversion succeeded or failed and identifies the created file after success.

### 6. Convert a Markdown File to PDF

**Description:** As a user, I want to convert the displayed Markdown file to PDF so that I can save or share it as a polished document.

**Acceptance criteria:**

- The user can initiate PDF conversion for the displayed Markdown file.
- The PDF output is saved immediately beside the source file without a Save As dialog.
- The output uses the source file's base name with a `.pdf` extension.
- If that filename already exists, the application creates the next available numbered copy rather than overwriting it.
- The export preserves the source document's structure and does not add a generated table of contents, search, bookmarks, or other navigation content.
- The application communicates whether conversion succeeded or failed and identifies the created file after success.

### 7. Use the Application as a Read-Only Viewer

**Description:** As a user, I want the application to remain focused on reading and exporting so that my source Markdown files are never changed.

**Acceptance criteria:**

- Version 1 does not provide controls for editing Markdown content.
- The application does not provide a save workflow for source Markdown files.
- Viewing, navigation, history, bookmarks, pins, theme selection, reading preferences, and export do not modify the source Markdown file.
- The application does not require an account or sign-in.
- The application does not require the user to create a vault, workspace, or project.
- A file can be viewed without importing or indexing its containing folder.
- The application does not show a startup dashboard that blocks access to the user's last document.

### 8. Choose a Markdown Display Theme

**Description:** As a user, I want expressive display themes so that reading Markdown is visually engaging while remaining readable.

**Acceptance criteria:**

- Version 1 includes light, dark, sci-fi, blueprint, and 8-bit themes.
- The user can switch the display theme at any time using a compact control in the status bar.
- A theme may style typography, spacing, headings, code, tables, diagrams, backgrounds, interface elements, and subtle motion.
- Each theme has a distinct visual identity rather than acting only as a color variation.
- All document content remains legible and understandable in every theme.
- Changing the display theme does not change the source Markdown file or the selected export theme.

### 9. Open Markdown Files Directly

**Description:** As a user, I want to open Markdown files through familiar application and system actions so that I can begin reading quickly.

**Acceptance criteria:**

- The application provides an action for opening a Markdown file directly.
- When supported by the environment, a Markdown file associated with the application can be opened by double-clicking it.
- When supported by the environment, the application is available through the file browser's Open With action.
- Opening a file displays it and adds it to history without requiring an import process.
- Keyboard shortcuts are available for frequently used viewing actions, including opening a file.

### 10. Navigate Project-Relative Content

**Description:** As a user, I want links and images in a Markdown file to work relative to that file so that project-local documents render and navigate correctly without becoming a managed workspace.

**Acceptance criteria:**

- Images referenced relative to the displayed Markdown file are rendered in the document.
- Selecting a relative link to another Markdown file displays the linked file in the application.
- A Markdown file opened through a local link is added to history.
- Selecting an in-document anchor moves to the corresponding section.
- Selecting an external web link opens it using the appropriate external behavior.
- The user can navigate backward and forward after following document links.
- Missing link or image targets are clearly indicated without preventing the remainder of the document from being displayed.
- Following links does not import or index the containing project.

### 11. Render Rich Markdown Content

**Description:** As a user, I want rich Markdown constructs to render without additional setup so that complex documents are immediately useful.

**Acceptance criteria:**

- Fenced code blocks are syntax-highlighted and provide a copy action.
- Tables are rendered clearly.
- Task lists display checked and unchecked states without allowing source editing.
- Footnotes are rendered with navigation between references and definitions.
- Mathematical notation is rendered.
- Mermaid diagrams are rendered.
- Callouts or admonitions are rendered.
- Embedded HTML is displayed appropriately within the document.
- Unsupported or invalid rich content does not prevent the remainder of the document from being displayed.
- Rich rendering does not require the user to install or configure plugins.

### 12. Search Within the Displayed Document

**Description:** As a user, I want to search the displayed document so that I can find relevant content quickly.

**Acceptance criteria:**

- The user can initiate full-text search within the displayed Markdown document.
- All matches are highlighted in the rendered content.
- The application shows the total number of matches and the currently selected match.
- The user can move to the previous or next match.
- Search can be accessed and navigated using familiar keyboard shortcuts.
- Search applies only to the displayed document and is not used to locate unavailable files.

### 13. Navigate Using a Document Outline

**Description:** As a user, I want a heading outline so that I can understand and navigate long documents efficiently.

**Acceptance criteria:**

- A collapsible panel on the right side contains an Outline tab.
- The outline reflects the hierarchy of headings in the displayed document.
- Selecting an outline entry moves to the corresponding section.
- The outline identifies the current heading as the user scrolls.
- The outline updates when the displayed document changes or refreshes.

### 14. View Reading Status

**Description:** As a user, I want concise reading information in a status bar so that I can understand my position and the document's size.

**Acceptance criteria:**

- A status bar appears at the bottom of the application on first launch.
- The status bar shows reading progress.
- The status bar shows the current document section.
- The status bar shows the document's word count.
- The status bar shows estimated reading time.
- Status information updates as the user navigates or the document refreshes.

### 15. Customize Reading Appearance

**Description:** As a user, I want global reading controls so that every theme can suit my readability preferences.

**Acceptance criteria:**

- The user can adjust font size, line spacing, and content width.
- The user can enable reduced-motion behavior.
- The user can enable high-contrast behavior.
- Reading preferences apply globally across all display themes.
- Global reading preferences override theme defaults where necessary.
- The user can reset global reading preferences to their defaults.
- Reading preferences do not modify source Markdown files.

### 16. Automatically Refresh Changed Files

**Description:** As a user, I want the displayed document to refresh automatically when its source file changes so that I always see the latest saved content.

**Acceptance criteria:**

- The displayed document refreshes automatically after its source file changes.
- The application preserves the current heading and reading position whenever the updated document allows it.
- The application briefly indicates that the document was refreshed.
- Refreshing never writes changes to the source file.
- If the source becomes inaccessible, the associated history entry is marked unavailable.

### 17. Resume Reading

**Description:** As a user, I want the application to remember where I stopped reading so that I can continue without finding my place again.

**Acceptance criteria:**

- The application remembers a reading position for every viewed file.
- Returning to a file restores its most recently remembered reading position.
- Restarting the application automatically reopens the last displayed file.
- The last displayed file reopens at its remembered reading position.
- Removing or clearing a file from history does not delete its remembered reading position.
- Reopening a previously removed file restores its retained reading position.

### 18. Control the Reading Layout

**Description:** As a user, I want to control the visibility of supporting interface areas so that I can balance navigation with distraction-free reading.

**Acceptance criteria:**

- On first launch, the left history panel, right outline/bookmarks panel, and bottom status bar are visible.
- The user can show or hide the left panel, right panel, and status bar independently.
- A distraction-free reading action hides both panels and the status bar.
- When supporting interface areas are hidden, the rendered document uses the available space.
- After the first launch, the application remembers the visibility of each panel and the status bar.
- On subsequent launches, the application restores the user's last visibility choices.

### 19. Bookmark Document Locations

**Description:** As a user, I want to bookmark meaningful locations without changing the source file so that I can return to important content later.

**Acceptance criteria:**

- The user can create a bookmark for a heading.
- The user can create a bookmark for selected passage text.
- The user can create a bookmark for the current reading position without selecting a heading or passage.
- Bookmarks are stored separately from the source Markdown file.
- The right-side panel contains separate Outline and Bookmarks tabs.
- The Bookmarks tab shows bookmarks for the current document by default.
- The user can switch the Bookmarks tab to show bookmarks across all files.
- A bookmark displays its heading, selected passage, or nearby text as appropriate.
- Selecting a bookmark opens its file and restores the bookmarked location.
- If the file is not in history, selecting its retained bookmark adds it back to history.
- Removing or clearing a history entry does not remove its bookmarks.
- If an accessible file changes and a bookmark target can no longer be located, that bookmark is removed.
- Bookmark actions do not modify the source Markdown file.

### 20. Pin Files in History

**Description:** As a user, I want to pin important files so that they remain easy to access at the top of history.

**Acceptance criteria:**

- Each history entry provides a direct pin or unpin action.
- Pinned files appear above unpinned history entries.
- The user can reorder pinned files manually.
- The application preserves pinned files and their manual order across restarts.
- An unavailable pinned file remains in the pinned area and is visibly marked as unavailable.
- Clearing history preserves pinned files.
- Pinning does not modify the source Markdown file.

### 21. Choose and Remember an Export Style

**Description:** As a user, I want export styling to be independent from my reading theme so that I can read comfortably and publish appropriately.

**Acceptance criteria:**

- The export action lets the user choose HTML or PDF as the output format.
- The export action lets the user choose an export theme independently of the active display theme.
- The initial export-theme default is the printer-friendly light theme.
- If the user chooses another export theme, the application remembers it for the next export.
- One remembered export-theme preference is shared by HTML and PDF exports.
- Exporting does not change the active display theme.
- Export begins immediately after the user makes the export choices, without a preview or Save As step.
- The selected publication style is applied consistently throughout the exported document.
- Animated theme effects use an appropriate static appearance in exported output.

### 22. Open a History Entry or Bookmark in a New Window

**Description:** As a user, I want to open a history entry or bookmark in a new window so that I can view multiple documents or locations without replacing my current view.

**Acceptance criteria:**

- A history entry provides an Open in New Window action.
- A bookmark provides an Open in New Window action.
- Opening an entry in a new window leaves the current window unchanged.
- A new window opened from history displays the selected file.
- A new window opened from a bookmark displays the associated file at the bookmarked heading, passage, or position.
- The user can open the same file in more than one window.
- Opening a retained bookmark for a file that is not in history adds that file back to history.

## Phase 2

### 23. Present a Markdown Document Full-Screen

**Description:** As a user, I want to present an ordinary Markdown file full-screen so that I can use a styled document for a live presentation without converting it into slides.

**Acceptance criteria:**

- The user can enter a full-screen presentation mode for the displayed Markdown file.
- Presentation mode hides the normal application interface.
- The user can move between document headings using keyboard controls.
- Presentation mode applies the selected display theme.
- Entering or leaving presentation mode does not change the source Markdown file.
- Presentation mode does not require conversion to a slide format.

### 24. Install Additional Theme Packs

**Description:** As a user, I want to add theme packs beyond the built-in collection so that I can expand the application's visual styles.

**Acceptance criteria:**

- The user can import or install an additional theme pack.
- Installed themes are available through the same theme-selection experience as built-in themes.
- The user can remove an installed theme pack without affecting source Markdown files.
- Global readability preferences apply to installed themes.
- The built-in themes remain available without installing external themes.

### 25. Preview Markdown in the File Manager

**Description:** As a user, I want to preview rendered Markdown from my file manager so that I can inspect a file without opening the full application window.

**Acceptance criteria:**

- Where supported, the file manager can display a rendered preview of a selected Markdown file.
- The preview displays the file's Markdown content rather than only its source text.
- Previewing a file does not modify it.
- The user can open the full application from the preview when more reading or navigation features are needed.
