# UX Requirements

## 1. Native macOS Visual Language

**Description:** The surrounding application interface must follow Apple's current macOS design conventions and feel immediately native. Window chrome, toolbars, sidebars, controls, menus, selection states, spacing, and motion must use Liquid Glass appropriately and with restraint, preserving clarity and legibility instead of treating the material as decoration.

## 2. System Light and Dark Appearance

**Description:** The application interface must provide polished light and dark appearances that remain distinct from the selected document theme. Changing the document theme must not recolor or visually transform the entire application shell; expressive styling belongs primarily to the document canvas while the surrounding interface retains a consistent macOS identity.

## 3. Reading-First Window Composition

**Description:** The central document canvas must be the visually dominant area of the window. A compact translucent history sidebar sits on the left, a slightly narrower outline and bookmarks inspector sits on the right, and a quiet single-line status bar runs along the bottom. These supporting areas must feel structurally attached to the native window rather than presented as separate floating cards. When the window grows, the document receives most additional space; when space becomes constrained, supporting panels yield before readability does.

## 4. Focused Unified Toolbar

**Description:** The toolbar must remain concise and group controls by purpose. The leading area contains the history-sidebar toggle, backward and forward navigation, and the document title; the center contains the frequently used Open and Export actions; and the trailing area contains document search, the right-inspector toggle, and a direct distraction-free reading toggle. Toolbar icons use an unadorned native presentation without circular or pill-shaped shared control backgrounds. Theme and reading controls belong in the status bar rather than the toolbar. Pinning, revealing, removal, and new-window actions appear contextually. Every toolbar action must also remain discoverable through the macOS menu bar and keyboard interaction.

## 5. Scan-First History Sidebar

The visible history sidebar starts at an ideal width of 280 points and resizes between 240 and 360 points. Width constraints apply at the split-view column boundary, including launch with an empty history, so filenames are not reduced to a few characters.

**Description:** The history sidebar must separate Pinned and Recent files into clear sections, with compact two-line rows showing the filename prominently and a shortened parent path as secondary context. Selection uses the native macOS treatment without card-like decoration. Pin controls appear persistently for pinned entries and on hover or keyboard focus for recent entries. Unavailable files remain in place and combine a warning symbol, muted styling, and an explicit label so status is never communicated by color alone. Contextual actions provide secondary file operations, pinned rows support direct drag reordering, and Clear History remains in a restrained sidebar menu. Thumbnails and reading statistics must not clutter the list.

## 6. Theme-Driven Document Canvas

**Description:** The selected document theme must fill the entire central document pane without recoloring the surrounding application interface. Prose sits in a centered reading column with generous breathing room, without a permanent floating-card container. Themes may establish their own visual surface while preserving clear typography and hierarchy. Tables, diagrams, code blocks, and large images may use a wider lane than prose, and oversized content scrolls horizontally instead of shrinking into illegibility. The toolbar transitions naturally above scrolling content, and content-specific controls remain subdued until hover or keyboard focus.

## 7. Quiet Outline and Bookmarks Inspector

**Description:** The right inspector must use a compact segmented control to switch between Outline and Bookmarks. The outline appears as an indented, collapsible tree whose complete hierarchy is expanded when first shown, with restrained hierarchy and a native highlight for the current section; automatic tracking keeps the active entry visible without distracting jumps. Bookmarks use compact rows with small symbols distinguishing headings, passages, and reading positions. A quiet scope filter switches between the current document and all files, with filename and shortened path shown as secondary context when needed. Long excerpts truncate gracefully and reveal their complete text on hover. New-window and removal actions remain contextual, and unavailable targets use the same accessible warning treatment as history entries.

## 8. Information-Dense but Quiet Status Bar

**Description:** The bottom status bar must remain a single, unobtrusive line with a thin reading-progress track along its upper edge. The current section appears on the left; reading percentage, word count, and estimated reading time occupy the center; and compact theme and reading-appearance controls sit on the right. Temporary messages such as refresh and export status briefly replace the center metrics before fading away. As the window narrows, secondary metrics collapse progressively instead of wrapping or crowding. The status bar remains fully keyboard-accessible but must not visually compete with the toolbar.

## 9. Distinct Built-In Theme Identities

**Description:** Each built-in document theme must have a complete and recognizable visual language rather than a simple color swap. Light uses warm paper tones, dark ink, editorial serif body text, clean sans-serif headings, and publication-quality details. Dark uses deep charcoal, soft off-white text, restrained cool accents, and low-glare editorial hierarchy. Sci-Fi uses a midnight surface, sparing luminous cyan with amber or magenta accents, geometric headings, subtle grids, and restrained glow or scan motion. Blueprint uses rich cobalt, fine cyan-white construction lines, technical typography, diagram-like borders, and a quiet drafting grid. 8-Bit uses a considered retro-console palette, pixel typography for headings and ornaments, and crisp stepped details while retaining a highly readable non-pixel body face. Every theme must style rich content coherently, limit motion to accents, and yield to global readability preferences.

## 10. Compact In-Document Search

**Description:** Invoking document search must expand and focus a compact search group within the trailing toolbar area. Match count and previous and next controls remain inside this group. Every match receives a theme-aware, accessible highlight, while the active match uses a clearly stronger treatment that does not rely on color alone. Navigation must preserve spatial orientation without feeling slow, and a small section label briefly identifies the active match's location. Empty results appear directly in the search group rather than in an alert. Closing search removes its highlights and returns focus to the document at the active result.

## 11. Immediate Contextual Bookmarking

**Description:** Bookmark creation must remain anchored to the content and avoid modal interruption. Hovering or keyboard-focusing a heading reveals a bookmark symbol in the outer document margin, with a filled state indicating an existing bookmark. Selecting passage text reveals a compact contextual bookmarking action. A Bookmarks menu in the inspector header provides Bookmark Current Position and exposes its keyboard shortcut. Labels are derived automatically from the relevant content, and creation receives brief confirmation at the bookmarked location and in the status bar without switching inspector tabs. Removing a heading bookmark uses the same direct control; other bookmarks are removed contextually from the inspector.

## 12. One-Step Contextual Export

The primary export icon must remain a directly clickable toolbar button beside a separate options disclosure, never be collapsed into an unlabeled menu row. Export success and its Reveal in Finder action remain visible for ten seconds; PDF and HTML files are saved beside the source document.

**Description:** Export must use a native split-button interaction. Activating the main Export button immediately uses the most recently selected format and export theme, while its disclosure menu clearly presents the active combination and available alternatives. Selecting another format or theme starts that export immediately and remembers the choice without a separate confirmation step. The initial combination is PDF with the printer-friendly Light theme. Export progress remains restrained and nonblocking. Success appears temporarily in the status bar with the created filename and a Reveal in Finder action; automatically numbered filenames require no interruption. Failure appears in an anchored popover with a concise explanation and retry action while leaving the document undisturbed.

## 13. Direct First-Launch and Drop Experience

**Description:** First launch must present the normal reading window with its toolbar, both side panels, and status bar already visible. The empty document canvas contains a restrained welcome state with the MD22 icon, a clear invitation to drop a Markdown file, a native Open button, and a short reassurance that files remain in place rather than being imported. Dragging a valid file over any part of the window gently emphasizes the canvas using a theme-neutral tint and subtle motion instead of a large upload box. A successful drop transitions directly into the rendered document. Invalid items receive brief visual rejection and a concise status-bar explanation without an alert. Subsequent launches replace the welcome state with the last document when available.

## 14. Calm Loading, Refresh, and Failure Feedback

**Description:** Feedback must preserve reading context and avoid unnecessary interruption. Fast loads show no spinner, while perceptibly longer work reveals restrained progress only after a short delay. When switching files, the current page remains visible until its replacement is ready, followed by a brief crossfade. Automatic refresh preserves position and receives only a short status-bar confirmation. If the displayed file becomes unavailable, its last rendered content remains beneath a slim nonmodal warning. Missing images use proportionate inline placeholders with a symbol and shortened path; broken links retain their label with an accessible warning treatment; and invalid rich content is replaced locally by a compact themed error block. Errors use plain language and contextual recovery actions rather than generic modal alerts or technical traces.

## 15. Live Global Reading Controls

**Description:** The reading-appearance control in the status bar must open a compact anchored popover. Familiar smaller and larger text controls adjust font size and display its percentage, while concise sliders adjust line spacing and content width with clear default positions. High Contrast and Reduce Motion appear as simple switches. Every adjustment updates the visible document immediately, applies consistently across themes, and requires no Apply step or separate preview. A subdued Reset Reading Settings action appears at the bottom, and closing the popover returns keyboard focus to the document.

## 16. Responsive Panels and Distraction-Free Reading

**Description:** Both side panels must resize through native dividers within sensible limits. Showing or hiding a panel uses a brief native transition, recenters the document, and preserves reading position. In a narrow window, an opened panel temporarily overlays the document instead of compressing the reading column below a usable width; clicking the document or pressing Escape dismisses that overlay without changing saved preferences. The status bar remains visible throughout normal reading and has no independent hide control. A single direct toolbar action enters or exits distraction-free mode; it hides both panels and the status bar, retains toolbar access, and restores the previous side-panel arrangement on exit. Each window preserves its own panel widths and visibility, while full-screen presentation follows standard macOS toolbar-reveal behavior.

## 17. Complete Keyboard and Assistive Access

**Description:** Keyboard focus must move predictably among the toolbar, history, document, inspector, and status bar using standard macOS navigation. Lists and outlines use familiar arrow-key and disclosure behavior, while the document supports conventional reading keys without trapping focus inside rendered content. Every hover-only affordance must also appear on keyboard focus with a clear native focus ring, and shortcuts must be discoverable through menus and relevant tooltips. VoiceOver receives named interface landmarks, semantic document headings, link destinations, bookmark state, search-result position, and reading progress. Reduced Transparency, Increased Contrast, and Reduce Motion must preserve structure and meaning while replacing translucent, low-contrast, glowing, crossfading, scanning, or animated-scrolling treatments as necessary.

## 18. Spatially Clear Link Navigation

**Description:** Hovering or keyboard-focusing a link must reveal its destination in the status bar without covering the document. Relative Markdown links use normal theme styling and a restrained page transition. Back and Forward restore the exact prior document location and communicate disabled states quietly; their contextual history menu identifies filenames and sections. In-document anchors move to and briefly emphasize the destination heading to aid orientation. External links use a subtle external-link symbol, while broken links preserve their original text with an accessible warning symbol and explanation. Link focus and visited states must remain distinguishable in every theme without relying on color alone.

## 19. Cohesive Rich-Content Presentation

**Description:** Every rich Markdown element must feel native to the active document theme while preserving consistent reading rhythm. Code blocks use a themed container with a language label, a quiet Copy control, and horizontal scrolling; inline code remains distinct but restrained. Tables emphasize headers and alignment with subtle row separation and scroll safely when wide. Task markers communicate read-only status instead of resembling editable controls. Callouts combine symbols, labels, borders, and tint so meaning does not depend on color. Footnote references and returns remain compact and orienting, mathematics aligns naturally with surrounding typography, and Mermaid diagrams inherit theme colors while retaining clear contrast and line hierarchy. Embedded HTML adopts theme typography where the author has not supplied styling, and all elements share coherent spacing, corners, and hierarchy.

## 20. Minimal Native Settings and About Surfaces

**Description:** Settings must use a small native window with one uncluttered General pane rather than a sidebar of sparse categories. The application-appearance control offers System, Light, and Dark and defaults to System, affecting only native chrome. An Updates section presents automatic-update preference, current channel, Check Now, and inline status. Reading controls remain in the document status-bar popover and are not duplicated. The standard About window presents the MD22 icon, name, version and build, MIT license, GitHub project link, and Third-Party Acknowledgements. Supporting information uses conventional windows or sheets rather than heavily branded dialogs.

## 21. Authoritative Supplied Brand Assets

**Description:** The application icon and MD22 logo supplied by the product owner are fixed, authoritative brand assets. They must be used without conceptual redesign, recoloring, or reinterpretation. The surrounding interface must accommodate the supplied assets while retaining its native macOS appearance; document themes and interface tinting must not alter the logo or icon's established identity.

## 22. Phase-Two Presentation Experience

**Description:** Presentation mode must let the active document theme fill the display edge to edge, increase typography appropriately for distance reading, and remove normal application chrome. A minimal translucent navigation heads-up display appears only during pointer movement or keyboard navigation and identifies the current heading, document progress, previous and next navigation, and Exit. When the interface recedes, the document remains the sole visual focus.

## 23. Phase-Two Theme Pack Management

**Description:** When installable themes ship, Settings gains a dedicated Themes pane rather than crowding the initial General pane. Built-in and installed themes appear as compact visual previews with their names and authors. Import, validation feedback, and removal use native sheets with clear language and preserve the visibility of built-in themes. Theme management must feel like a controlled extension of the existing theme selector rather than a marketplace or plugin browser.

## 24. Phase-Two Quick Look Simplicity

**Description:** Finder Quick Look previews must prioritize speed, predictability, and readability by using a simplified system-matched Light or Dark reading style instead of an expressive document theme. The preview contains no MD22-specific application chrome and relies on Finder's standard affordance for opening the file in MD22. Rich content must fit the preview surface cleanly without exposing controls intended for the full reader.

## 25. Native Multiwindow Continuity

**Description:** Opening a history entry or bookmark in a new window must create a standard cascading macOS window near the originating window, bring it forward, and leave the original unchanged. The File menu exposes one unambiguous New Window command for an empty reader; routed document windows remain an internal implementation detail rather than a second user-facing command. The filename serves as the window title, with parent-folder context used to disambiguate identical names. A new window inherits the current application appearance, document theme, and global reading preferences, while its panels, navigation, search, and reading position remain independent. Bookmark windows briefly emphasize their target on arrival. Multiple windows showing the same file may occupy different reading positions, and all window switching, tiling, full-screen, minimization, restoration, and closing behavior must remain conventionally macOS-like.
