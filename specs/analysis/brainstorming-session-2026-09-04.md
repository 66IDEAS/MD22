---
stepsCompleted: [1, 2, 3, 4]
inputDocuments: []
session_topic: 'New user-facing functionality for a compelling Markdown editor and viewer'
session_goals: 'Generate a broad set of feature ideas and identify the strongest candidates for later versions without changing the agreed version-one scope'
selected_approach: 'progressive-flow'
techniques_used: ['What If Scenarios', 'Mind Mapping', 'SCAMPER Method', 'Decision Tree Mapping']
ideas_generated: 60
context_file: ''
technique_execution_complete: true
facilitation_notes: 'Alex consistently prioritized visual delight, export quality, focused reading, and source fidelity while rejecting table-stakes positioning, structural export augmentation, unnecessary recovery workflows, and technical-scope discussion.'
session_active: false
workflow_completed: true
---

# Brainstorming Session Results

**Facilitator:** Alex
**Date:** 2026-09-04

## Session Overview

**Topic:** New user-facing functionality for a compelling Markdown editor and viewer

**Goals:** Generate a broad set of feature ideas and identify the strongest candidates for later versions without changing the agreed version-one scope.

### Context Guidance

The product already has an initial version-one direction: drag-and-drop Markdown viewing, file history, file-location access, HTML and PDF conversion, read-only behavior, and multiple display themes. This brainstorming session explores additional functionality without automatically adding ideas to that committed scope.

### Session Setup

Alex confirmed that the session should explore a broad range of user-visible feature ideas and later identify the strongest candidates.

## Technique Selection

**Approach:** Progressive Technique Flow
**Journey Design:** Systematic development from exploration to action

**Progressive Techniques:**

- **Phase 1 - Exploration:** What If Scenarios for broad, unconstrained feature generation
- **Phase 2 - Pattern Recognition:** Mind Mapping for organizing ideas and discovering themes
- **Phase 3 - Development:** SCAMPER Method for refining the strongest concepts
- **Phase 4 - Action Planning:** Decision Tree Mapping for prioritization and concrete next steps

**Journey Rationale:** This sequence begins with imaginative possibilities, organizes the resulting ideas into meaningful product themes, develops the most promising concepts, and concludes with decisions that can inform future functional requirements.

## Technique Execution Notes

### Phase 1 - What If Scenarios

**Emerging product position:** The application should complement connected knowledge-workspace products such as Obsidian rather than reproduce them. Its focus is quick, low-commitment viewing of Markdown files that live in project folders or elsewhere outside a managed vault.

**Implications identified:**

- Opening a file should not require importing it into a workspace or knowledge base.
- The experience should optimize for a quick look at an existing file.
- Project-local files should remain in their original locations.
- Editing remains unnecessary for the initial product direction.

**Zero-friction access ideas:**

- Support operating-system file associations so Markdown files can be opened by double-clicking them.
- Appear as an option in the operating system's **Open With** action.
- Provide keyboard shortcuts for fast viewing actions.
- Pursue native file-manager preview as the ideal, highest-convenience experience.
- Treat browser-based access as a reduced experience where operating-system integration is unavailable.

**Emerging priority:** Double-click and **Open With** are baseline capabilities for an installed application; file-manager preview is a high-value aspirational capability.

**Project-aware viewing ideas:**

- Resolve and display images referenced with paths relative to the current Markdown file.
- Follow relative links to other Markdown files without importing the containing project.
- Follow in-document anchor links to the corresponding section.
- Open web links using the appropriate browser behavior.
- Add followed Markdown files to the viewer's history so the user can return to them.
- Offer familiar back and forward navigation after following links.
- Clearly identify links or images whose targets cannot be found.

**Boundary:** The viewer may use a file's local context for rendering and navigation, but it should not index or take ownership of the containing project.

**Rich rendering ideas — all identified as essential:**

- Render syntax-highlighted fenced code blocks and provide a convenient copy action.
- Render Markdown tables clearly.
- Render task lists, including their checked and unchecked states.
- Render footnotes and provide convenient movement between references and definitions.
- Render mathematical notation.
- Render Mermaid diagrams.
- Render callouts or admonitions.
- Display embedded HTML appropriately within the rendered document.
- Handle unsupported or invalid rich content gracefully rather than breaking the entire document view.

**Emerging product promise:** Rich Markdown works out of the box without requiring the user to install or configure plugins.

**Long-document navigation ideas:**

- Provide a collapsible outline generated from the document's headings.
- Let users select an outline entry to jump to that section.
- Highlight the current heading in the outline as the user scrolls.
- Provide full-text search within the displayed document.
- Highlight all matching search results.
- Show the number and current position of matches.
- Provide previous-match and next-match controls.
- Provide familiar keyboard access to search.
- Show reading progress in a footer at the bottom of the application.

**Possible extensions:** The footer could also show the current section, word count, or estimated reading time without obscuring the document.

**Layout decisions:**

- Keep file history in the left side panel.
- Show the document outline in a separate, collapsible right side panel.
- Keep the rendered Markdown in the main center panel.
- Show reading progress, current section, word count, and estimated reading time in the footer.

**Live file behavior:**

- Automatically refresh the rendered document when the source file changes on disk.
- Preserve the reader's current heading and scroll position whenever the refreshed structure allows it.
- Briefly indicate that the displayed content was refreshed.
- Keep the external application editing the source file as the authoritative source.

**Product fit:** Automatic refresh supports the viewer's role as a read-only companion to code editors and other authoring tools.

**Unavailable file behavior:**

- Keep a moved, deleted, disconnected, or otherwise inaccessible file in history.
- Clearly mark the history entry as unavailable.
- Do not silently remove unavailable entries from history.
- A possible extension is to let the user locate the file again and reconnect the existing history entry.

### What If Scenarios - Phase Outcome

**Interactive focus:** Reframed the product away from connected knowledge management and toward instant, low-commitment viewing of project-local and standalone Markdown files.

**Key breakthroughs:**

- The product's niche is a lightweight, project-aware viewer that complements rather than competes with Obsidian.
- Native access paths and automatic refresh make it a useful companion to external editors.
- Project context should improve rendering and navigation without creating a vault or index.
- Rich Markdown support should be built in and require no plugin configuration.
- Long-document features can make the viewer useful for substantial technical documents, not just quick previews.

**Alex's priority signals:** Native opening, file-manager preview, comprehensive rich rendering, a separate right-side outline, full search and reading status, automatic refresh, and durable history all received explicit support.

**Phase transition:** Move from expansive What If exploration to Mind Mapping for theme and relationship discovery.

### Phase 2 - Mind Mapping

**Central concept:** Instant, read-only Markdown viewer

**Confirmed branches:**

1. **Access:** Drag and drop, double-click, Open With, keyboard shortcuts, and file-manager preview.
2. **Rendering:** Images, tables, tasks, footnotes, highlighted code with copy action, math, Mermaid, callouts, and embedded HTML.
3. **Project context:** Relative assets and links, local Markdown navigation, and no importing or indexing.
4. **Reading and navigation:** Full-text search, a right-side heading outline, back and forward navigation, anchors, and detailed reading status.
5. **File lifecycle:** Left-side history, automatic refresh, preserved reading position, and unavailable-file states.
6. **Presentation and output:** Multiple themes plus HTML and PDF export.
7. **Product boundary:** Read-only behavior, no vault, and untouched source files.

**Map validation:** Alex confirmed that the branch structure represents the idea space well without additions or restructuring.

**Priority correction:** Access capabilities such as drag and drop, double-click, and **Open With** are expected table stakes shared by Markdown applications. Although required, they have the lowest strategic priority and should not be presented as the product's headline feature or primary differentiator.

**Revised pattern hypothesis:** Faithful rich rendering and focused long-document reading are the likely sources of differentiated value. File lifecycle and presentation features support that experience, while access capabilities provide the expected baseline.

**Confirmed priority order:**

1. Beautiful themes and high-quality exports
2. Focused long-document reading and navigation
3. Faithful, comprehensive rich rendering
4. Reliable file lifecycle and history
5. Standard file-opening conveniences

**Positioning insight:** The application's leading value is not how files enter it, but how polished those files look when read and exported. Reading features make substantial documents comfortable to consume, while rendering fidelity, file lifecycle, and native opening progressively support that core experience.

### Mind Mapping - Phase Outcome

**Patterns identified:** The feature map resolves into presentation and output, focused reading, rendering fidelity, file lifecycle, access, and a read-only product boundary.

**Priority breakthrough:** Presentation quality, rather than file-opening convenience, is the product's strongest potential differentiator.

**Resulting position:** A beautifully themed reader for standalone Markdown that turns long, complex files into polished reading and export experiences without becoming an editor or vault.

**Phase transition:** Move from pattern recognition to SCAMPER-based development of the highest-priority presentation and export concepts.

### Phase 3 - SCAMPER Method

**Development focus:** Beautiful themes and high-quality exports, supported by focused reading and comprehensive rendering.

#### Substitute - Separate Reading Themes from Export Styles

- Treat the on-screen reading theme and exported document style as independent choices.
- Let the user switch the reading theme at any time through a small dropdown or pop-up control in the application footer.
- When exporting, let the user choose the export format and export theme.
- Use a printer-friendly light theme as the initial export default.
- If the user overrides the export theme, remember that choice and propose it as the default on the next export.
- Keep export-theme choices from changing the active on-screen reading theme.

**Concept refinement:** Replace a single global theme setting with two purpose-specific experiences: immediate reading personalization and remembered publication styling.

**Export interaction decisions:**

- Maintain one remembered export-theme preference shared by HTML and PDF exports.
- Keep export as a fast, one-step action without a visual preview stage.
- After the user selects the export format, use the remembered export theme automatically.

#### Combine - Preserve Style Without Adding Structure

- Apply the chosen publication style consistently throughout HTML and PDF output.
- Export the document as it is rather than generating a table of contents or adding navigation content.
- Do not prioritize exported search, generated PDF bookmarks, or other reader-navigation additions.
- Treat fidelity to the source document as more important than enriching the exported structure.

**Combine outcome:** Consistent publication styling is valuable; combining exports with extra navigation features is not a product priority.

#### Adapt - Borrow Focused Reading Behaviors from E-Readers

- Remember the user's exact reading position for every file in history across application sessions.
- Offer compact controls for font size, line spacing, and content width.
- Provide a distraction-free reading mode that temporarily hides the left history panel, right outline panel, and footer.
- Restore each document at the position where the user last stopped reading.
- Keep reading preferences and remembered positions separate from the source Markdown files.

**Adapt outcome:** All proposed e-reader behaviors were accepted as valuable additions to the product.

#### Adapt Deep Dive - Local Bookmarks

**Concept:** Add a persistent personal bookmark layer for Markdown reading without modifying the source files.

**Initial principles:**

- Store bookmarks in the application rather than in the Markdown file.
- Keep bookmarks associated with the corresponding history entry.
- Let a bookmark return the user to a meaningful location in the rendered document.
- Preserve the product's read-only relationship with source content.

**Priority signal:** Alex identified bookmarks as a particularly compelling concept worth deeper development.

**Accepted bookmark types:**

- **Heading bookmark:** Identifies a heading and returns to its section.
- **Passage bookmark:** Captures selected text as context and returns to that passage.
- **Position bookmark:** Saves the current reading location when no heading or text selection is used.

**Distinction:** Pinning or favoriting an entire file should remain separate from bookmarking a location inside a document.

**Bookmark organization:**

- Give the right-side panel separate **Outline** and **Bookmarks** tabs.
- Show bookmarks for the current document by default.
- Provide a switch for viewing bookmarks across all files.
- Represent each bookmark with its heading, selected passage, or nearby text, depending on its type.
- Selecting a bookmark opens the corresponding file and restores the bookmarked location.

#### Adapt Extension - Pinned Files

- Let users pin selected Markdown files in the left-side history.
- Keep pinned files at the top of the history list.
- Treat pins as persistent application data without modifying source files.
- Keep pins conceptually separate from bookmarks inside documents.

**Confirmed pin behavior:**

- Provide a direct pin or unpin action on history entries.
- Allow users to reorder pinned files manually.
- Sort unpinned history entries by most recently viewed.
- Keep unavailable pinned files in the pinned area and mark them as unavailable.
- Preserve pinned files and their manual order across application restarts.

**Adapt phase outcome:** The product borrows resumable reading, adjustable typography, distraction-free presentation, bookmarks, and persistent favorites from mature reading applications while keeping all personalization outside the source Markdown files.

#### Modify - Turn Themes into Complete Reading Experiences

- Let themes change more than colors, including typography, spacing, borders, heading treatments, code presentation, tables, diagrams, backgrounds, and application-interface styling.
- Allow expressive themes to use decorative backgrounds and subtle motion.
- Give light, dark, sci-fi, blueprint, and 8-bit themes distinct visual identities.
- Make the application fun and exciting to use rather than purely utilitarian.
- Keep readability as a top priority across every theme.
- Ensure expressive styling does not alter or obscure the meaning of document content.

**Modify direction:** Treat themes as art-directed reading experiences with strong personality, governed by consistent readability expectations.

**Global readability controls:**

- Apply font size, line spacing, and content width preferences across all themes.
- Apply reduced-motion and high-contrast preferences across all themes.
- Let users restore the global readability controls to their defaults.
- Let global readability preferences override theme defaults where necessary.
- Use static equivalents for theme motion in exported documents.

**Theme extensibility roadmap:**

- Keep version 1 focused on a curated collection of built-in themes.
- Consider importing or installing additional, potentially community-created theme packs in version 2.
- Do not make external theme support a dependency for the initial theme experience.

**Modify phase outcome:** Version 1 themes should be expressive, deeply styled, immediately switchable, and governed by global readability controls; community extensibility is deferred.

#### Put to Other Uses - Presentation Mode

- Let users present an ordinary Markdown file in full-screen mode.
- Hide application chrome during the presentation.
- Navigate between document headings using keyboard controls.
- Apply the selected visual theme to the presentation.
- Do not require conversion to a slide format or modification of the source Markdown.
- Plan presentation mode for a second implementation phase rather than version 1.

**Secondary-use insight:** The reading renderer can support live presentation while preserving the application's read-only, source-faithful character.

#### Eliminate - Remove Application Ceremony

Version 1 should intentionally eliminate:

- Accounts and sign-in requirements
- Vault, workspace, or project creation
- File import and indexing processes
- Editing toolbars and save workflows
- A startup dashboard that blocks immediate access to the last document
- Confirmation dialogs for harmless viewing actions

All secondary interface areas, including both side panels and the footer, should be hideable when the user wants an uncluttered reading surface.

**Eliminate outcome:** The version-one experience should move directly from opening to reading, navigating, or exporting with minimal interruption.

#### Reverse - Make the Document Primary

- Make rendered Markdown the primary surface rather than showing source text or editing controls.
- Let users hide the left history panel, right outline/bookmarks panel, and bottom status bar.
- Refer to the bottom information area as the **status bar**, not the footer.
- On the initial application launch, show both side panels and the status bar.
- After the first launch, remember the visibility of each panel and the status bar independently.
- On subsequent launches, restore the user's last visibility choices.
- Let a distraction-free state make the application resemble a typeset document rather than an editor.

**Reverse outcome:** The default layout exposes the application's navigation and status features, while returning users regain their personally configured, content-first layout automatically.

### SCAMPER - Phase Outcome

**Concepts developed:**

- Separate, immediately switchable reading themes from fast, remembered export styling.
- Preserve source structure in exports while applying a consistent publication style.
- Adapt e-reader behaviors: reading-position memory, typography controls, distraction-free mode, bookmarks, and pinned files.
- Turn themes into expressive reading experiences governed by global readability controls.
- Reserve community theme packs and Markdown presentation mode for a second implementation phase.
- Eliminate accounts, workspaces, importing, indexing, editing chrome, and unnecessary prompts from version 1.
- Make the rendered document primary while persisting each user's interface-visibility preferences.

**Phase transition:** Move from developed product concepts to Decision Tree Mapping for scope and implementation-phase decisions.

### Phase 4 - Decision Tree Mapping

**Action-planning focus:** Separate version-one essentials from later-phase ideas and resolve the remaining product choices before converting accepted concepts into functional specifications.

#### Confirmed Release Structure

**Version 1:**

- **Beautiful reading and export:** Curated expressive themes, global readability controls, separate reading and export themes, and fast HTML and PDF export.
- **Serious document reading:** Search with highlighted matches, a right-side outline and bookmarks panel, a detailed status bar, remembered reading positions, and distraction-free mode.
- **Rich rendering:** Project-relative links and images plus code, tables, task lists, footnotes, math, Mermaid, callouts, and embedded HTML.
- **File lifecycle:** History, pinned files, automatic refresh, and unavailable-file states.
- **Minimal read-only experience:** No accounts, vaults, importing, editing, or save workflow; interface preferences persist.

**Phase 2:**

- Full-screen presentation mode
- Imported or community-created theme packs

**Unresolved branches:**

- Timing of the 8-bit theme
- Timing of file-manager preview integration
- History cleanup and duplicate behavior
- Relocating unavailable files
- Export destination and naming

**Decision status:** Alex confirmed this release structure as the basis for subsequent decisions.

#### Decision 1 - Built-In Theme Set

Version 1 will include five curated themes: light, dark, sci-fi, blueprint, and 8-bit. External or community-created themes remain deferred to phase 2.

#### Decision 2 - File-Manager Preview

Native file-manager preview integration is deferred to phase 2. Version 1 retains ordinary application-level opening behavior such as drag and drop, double-click, and **Open With** where supported.

#### Decision 3 - History Behavior

- Persist file history across application restarts.
- Maintain one history entry per file rather than adding duplicates.
- Move an unpinned entry to the top of the unpinned history when the file is viewed again.
- Keep pinned entries at the top in their manual order.
- Let users remove individual history entries.
- Provide a **Clear history** action that preserves pinned files.

#### Decision 4 - Unavailable Files

- Mark an inaccessible history entry as unavailable.
- Let the user remove the unavailable entry from history.
- Do not provide a file-search, locate, or reconnection workflow for moved files.
- Keep missing-file handling intentionally simple.

**Search distinction:** Full-text search within the currently displayed Markdown document remains a version-one requirement. Only searching for or reconnecting a missing file is excluded.

#### Decision 5 - Export Destination and Naming

- Export immediately to the same folder as the source Markdown file.
- Reuse the source file's base name with the selected output extension, such as `.html` or `.pdf`.
- Do not show a **Save As** dialog during the normal export flow.
- Preserve the fast, one-step export interaction.
- If the target filename already exists, create a numbered copy such as `README-2.pdf` rather than replacing the existing export.

#### Functional Scope Boundary

Platform and delivery choices, such as desktop versus web and operating-system rollout strategy, are intentionally excluded from this functional brainstorming session.

### Decision Tree Mapping - Phase Outcome

**Version-one decisions resolved:**

- Include light, dark, sci-fi, blueprint, and 8-bit themes.
- Defer native file-manager preview to phase 2.
- Persist and deduplicate history, order unpinned entries by recency, allow removal, and preserve pinned entries when clearing history.
- Mark missing files as unavailable and allow removal without a search or reconnection workflow.
- Retain full-text search inside the displayed document.
- Export beside the source with the same base filename and create numbered copies rather than overwriting existing output.

**Planning boundary:** Implementation technology and target-platform choices remain outside the functional requirements process.

## Technique Execution Results

**What If Scenarios:**

- **Interactive focus:** Define a meaningful role for standalone and project-local Markdown outside managed knowledge workspaces.
- **Key breakthrough:** The application should compete on the quality of reading and presentation, not ordinary file-opening behavior.
- **Developed ideas:** Project-aware rendering, rich Markdown support, serious navigation, automatic refresh, persistent history, and unavailable-file handling.

**Mind Mapping:**

- **Building on previous work:** Grouped the ideas into presentation and output, focused reading, rendering fidelity, file lifecycle, access, and product boundaries.
- **Priority insight:** Beautiful themes and high-quality exports rank above long-document reading, rich rendering, lifecycle, and ordinary opening conveniences.

**SCAMPER Method:**

- **Developed ideas:** Independent reading and export themes, fast remembered exports, e-reader controls, bookmarks, pinned files, expressive themes, presentation mode, minimal application ceremony, and a content-first interface.
- **Scope choices:** Community themes and presentation mode were assigned to phase 2; version 1 remains curated and read-only.

**Decision Tree Mapping:**

- **Decisions resolved:** Version-one theme set, file-manager preview timing, history behavior, missing-file behavior, document search, export destination, and collision-safe export naming.
- **Boundary reinforced:** Functional behavior is documented independently of implementation technology and platform strategy.

**Overall creative journey:** The session moved from a generic Markdown-viewer concept toward a distinctive, visually expressive reading and publishing experience for standalone files. Alex repeatedly used clear priority judgments to distinguish expected conveniences from product-defining functionality.

### Session Highlights

**Alex's creative strengths:** Strong product-boundary awareness, decisive prioritization, and a consistent preference for delightful but readable presentation.

**Facilitation approach:** Provocative scenarios widened the idea space, a mind map exposed value clusters, SCAMPER developed the strongest concepts, and a decision tree resolved release scope.

**Breakthrough moments:** Reframing access as table stakes; placing themes and exports first; separating reading from export styling; and adding a source-independent layer for bookmarks, pins, and remembered reading state.

**Energy flow:** The session progressed from corrective product positioning into increasingly concrete feature behavior and release decisions.

## Idea Organization and Prioritization

### Thematic Organization

**1. Visual Identity and Publication**

- Five expressive built-in themes: light, dark, sci-fi, blueprint, and 8-bit
- Global readability overrides across themes
- Independent reading and export styles
- One remembered export preference shared by HTML and PDF
- Fast, source-adjacent exports with collision-safe numbered filenames

**Pattern insight:** Visual quality and publication-ready output form the leading product value, with speed and consistency reinforcing the experience.

**2. Focused Long-Document Reading**

- Full-text search with highlighted matches and previous/next controls
- A collapsible heading outline in the right panel
- A status bar with reading progress, current section, word count, and estimated reading time
- Remembered per-file reading positions
- Global typography controls and distraction-free mode

**Pattern insight:** The application should support sustained reading of substantial documents rather than serving only as a transient preview.

**3. Rich, Project-Aware Rendering**

- Relative images, links, and anchors
- Local Markdown navigation with back and forward behavior
- Code, tables, tasks, footnotes, math, Mermaid, callouts, and embedded HTML
- Graceful handling of unsupported or invalid rich content
- No project import, indexing, or ownership

**Pattern insight:** Awareness of local context exists solely to render and navigate the current material faithfully.

**4. Personal Reading Continuity**

- Persistent, deduplicated history with pinned files
- Heading, passage, and position bookmarks
- Current-file and all-file bookmark views
- Unavailable-file states and removal
- Persisted side-panel and status-bar visibility

**Pattern insight:** A source-independent personal layer makes loose files resumable and memorable without turning them into a managed knowledge base.

**5. Live Read-Only Companionship**

- Automatic refresh when the source file changes
- Preserved heading and scroll position after refresh
- Brief refresh feedback
- The external editor remains authoritative

**Pattern insight:** The viewer complements active authoring tools while remaining strictly read-only.

**6. Low-Ceremony Access**

- Drag and drop, double-click, **Open With**, and keyboard shortcuts
- No accounts, workspaces, importing, indexing, editing, or save workflow
- Direct access to the last document rather than a blocking dashboard

**Pattern insight:** These capabilities are necessary table stakes and product-boundary protections, not the primary differentiation.

### Prioritization Results

**Top priority concepts:**

1. Expressive themes paired with consistent, publication-quality export
2. A serious long-document reading surface
3. Source-independent bookmarks and reading continuity

**Breakthrough combination:** Beautiful presentation, serious reading, and zero modification of source files.

**Confirmed value order:**

1. Beautiful themes and high-quality exports
2. Focused long-document reading and navigation
3. Faithful, comprehensive rich rendering
4. Reliable file lifecycle and history
5. Standard file-opening conveniences

## Functional Action Planning

### Priority 1 - Expressive Themes and Publication-Quality Export

**Why this matters:** This is the product's leading differentiator and the clearest reason to choose it over ordinary Markdown viewers.

**Next steps:**

1. Define the visual character and readability expectations of all five built-in themes.
2. Specify every global readability override and how it interacts with theme defaults.
3. Convert reading-theme, export-style, export-format, remembered-preference, destination, and filename decisions into acceptance criteria.
4. Assemble representative Markdown examples for evaluating screen, HTML, and PDF presentation consistently.

**Resources needed:** Theme reference material, a representative rich-Markdown sample set, and explicit export-quality criteria.

**Potential obstacles:** Expressive presentation could reduce readability, and the same publication style may behave differently across screen, HTML, and PDF.

**Success indicators:** Every supported element remains readable in all themes; exported styling is consistent; first-use and remembered export defaults behave exactly as specified; existing exports are never overwritten.

### Priority 2 - Focused Long-Document Reading

**Why this matters:** This makes the application useful for substantial technical and project documents rather than only quick previews.

**Next steps:**

1. Specify the default three-region layout plus the status bar and all visibility states.
2. Define outline synchronization, heading navigation, search behavior, and match navigation.
3. Define progress, current-section, word-count, and reading-time behavior.
4. Specify distraction-free mode, typography controls, remembered reading positions, and restart restoration.

**Resources needed:** Representative long Markdown documents and functional examples covering deeply nested headings and many search matches.

**Potential obstacles:** Navigation features could make the interface feel crowded, and content changes could disrupt the user's reading position.

**Success indicators:** Users can find and revisit content quickly; the active heading remains clear; reading state survives file switches and restarts; hiding interface regions produces a clean content-first view.

### Priority 3 - Bookmarks and Reading Continuity

**Why this matters:** This adds durable personal value without modifying source files or introducing a vault.

**Next steps:**

1. Specify creation, display, navigation, and removal for heading, passage, and position bookmarks.
2. Define the right-panel **Outline** and **Bookmarks** tabs, including current-file and all-file bookmark views.
3. Specify pinning, manual pin order, history recency, deduplication, entry removal, and history clearing.
4. Define behavior for bookmarks, pins, and reading state when a source file changes or becomes unavailable.

**Resources needed:** Functional scenarios involving long files, changed content, pinned files, missing files, and multiple bookmark types.

**Potential obstacles:** Source changes may invalidate precise bookmark targets, and history cleanup must not remove content the user intentionally preserved.

**Success indicators:** All bookmark types return users to meaningful locations; pin order persists; history remains predictable; unavailable files are clearly marked; source Markdown is never changed.

### Roadmap Follow-Up

- Keep presentation mode, community theme packs, and native file-manager preview in phase 2.
- Convert the accepted version-one concepts into numbered functional user stories and acceptance criteria.
- Use those functional specifications as the input for later UX and technical planning.

## Session Summary and Insights

### Key Achievements

- Reframed the product as a beautifully themed, serious Markdown reader and publisher for standalone and project-local files.
- Organized more than 60 ideas and refinements into six functional themes.
- Established a user-defined priority order led by themes and export quality.
- Identified three top concepts with functional action plans.
- Confirmed a broad version-one scope and explicitly deferred presentation mode, community themes, and native file-manager preview.
- Preserved a strict boundary between functional requirements and later technical decisions.

### Key Product Insights

- Standard opening behavior is necessary but does not differentiate the product.
- Expressive themes can create delight when global readability controls remain authoritative.
- Long-document navigation makes the viewer valuable beyond quick previews.
- Bookmarks, pins, and reading state create personal continuity without changing source files or introducing a vault.
- Fast exports should preserve source structure, remember the user's publication style, and never overwrite previous output.

### Session Reflection

The progressive flow successfully moved from broad exploration through pattern recognition and concept development to release-scope decisions. Alex consistently clarified which behaviors were differentiating, which were expected, which should be deferred, and which fell outside functional analysis.

### Completion

The brainstorming workflow is complete. The next recommended activity is to translate the accepted version-one behavior into numbered user stories with testable acceptance criteria in `specs/specifications.md`.
