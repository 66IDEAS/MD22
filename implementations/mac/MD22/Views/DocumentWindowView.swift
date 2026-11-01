import SwiftUI

struct DocumentWindowView: View {
    let environment: AppEnvironment
    let initialRequest: DocumentWindowRequest?
    @Environment(\.openWindow) private var openWindow
    @State private var session: DocumentSession
    @State private var renderer: WebDocumentRenderer
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var inspectorPresented = true
    @State private var preferredHistoryVisible = true
    @State private var preferredInspectorVisible = true
    @State private var windowWidth: CGFloat = 1_240
    @State private var didMeasureWindowWidth = false
    @State private var isRendererReady = false
    @State private var compactPanel: CompactPanel?
    @State private var isDistractionFree = false
    @State private var layoutBeforeDistractionFree: SavedWindowLayout?
    @State private var searchPresented = false
    @State private var searchFocusID = 0
    @State private var searchQuery = ""
    @State private var searchState = DocumentSearchState()
    @State private var searchTask: Task<Void, Never>?
    @State private var exportTask: Task<Void, Never>?
    @State private var exportError: String?
    @State private var isDropTargeted = false
    @State private var historySelection: String?
    @State private var didAttemptRestoration = false
    @State private var didReceiveExplicitOpen = false
    @FocusState private var focusedRegion: WindowFocusRegion?

    init(environment: AppEnvironment, initialRequest: DocumentWindowRequest? = nil) {
        self.environment = environment
        self.initialRequest = initialRequest
        _session = State(initialValue: DocumentSession(environment: environment))
        _renderer = State(initialValue: WebDocumentRenderer())
        _columnVisibility = State(initialValue: environment.preferences.showsHistory ? .all : .detailOnly)
        if #available(macOS 27.0, *) {
            // The restored width is unknown until the first layout pass.
            // Show the inspector after measuring the available reader width.
            _inspectorPresented = State(initialValue: false)
        } else {
            _inspectorPresented = State(initialValue: environment.preferences.showsInspector)
        }
        _preferredHistoryVisible = State(initialValue: environment.preferences.showsHistory)
        _preferredInspectorVisible = State(initialValue: environment.preferences.showsInspector)
    }

    var body: some View {
        windowInteractionView
            .background(ReaderWindowSizingHook())
    }

    private var windowChromeView: some View {
        GeometryReader { geometry in
            let isTiny = Self.usesTinyLayout(at: geometry.size.width)
            VStack(spacing: 0) {
                if !isTiny {
                    compactHeader
                    Divider()
                }
                GeometryReader { contentGeometry in
                    readerPane(size: contentGeometry.size, isTiny: isTiny)
                }
                if isTiny {
                    Divider()
                    HStack(spacing: 4) {
                        Text(session.windowTitle)
                            .font(.caption)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Spacer(minLength: 0)
                        tinyActionMenu
                    }
                    .padding(.horizontal, 6)
                    .frame(height: 28)
                } else if !isDistractionFree {
                    Divider()
                    ReadingStatusBar(session: session)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .focusable()
                        .focused($focusedRegion, equals: .statusBar)
                        .focusSection()
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .frame(minWidth: 200, minHeight: 200)
        .navigationTitle(usesTinyLayout ? "" : session.windowTitle)
        .preferredColorScheme(environment.preferences.appAppearance.colorScheme)
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { oldSize, newSize in
            let firstMeasurement = !didMeasureWindowWidth
            let changedLayout = Self.usesTinyLayout(at: oldSize.width) != Self.usesTinyLayout(at: newSize.width)
            if firstMeasurement {
                isRendererReady = false
                Task { @MainActor in
                    await Task.yield()
                    isRendererReady = true
                }
            }
            didMeasureWindowWidth = true
            windowWidth = newSize.width
            if firstMeasurement
                || changedLayout
                || Self.usesCompactPanelLayout(at: oldSize.width) != Self.usesCompactPanelLayout(at: newSize.width)
                || (oldSize.width < Self.overlayThreshold && newSize.width >= Self.overlayThreshold) {
                if !usesTinyLayout { compactPanel = nil }
                restorePreferredPanelVisibility()
            }
        }
    }

    private var documentRoutingView: some View {
        windowChromeView
        .task(id: initialRequest?.id) {
            guard !didAttemptRestoration else { return }
            didAttemptRestoration = true
#if DEBUG
            if let uiTestDocumentURL = Self.uiTestDocumentURL {
                openCurrent(uiTestDocumentURL, source: .openPanel)
                return
            }
            if ProcessInfo.processInfo.arguments.contains("--md22-ui-test-fresh") {
                return
            }
#endif
            if let initialRequest {
                openRequest(initialRequest)
                return
            }
            guard !didReceiveExplicitOpen, let url = environment.history.lastDocumentURL else { return }
            let isAvailable = await environment.fileAccess.isAvailable(url)
            // Finder may deliver its file while the asynchronous availability
            // check is in flight. Never replace that explicit user choice.
            guard !didReceiveExplicitOpen else { return }
            if isAvailable {
                openCurrent(url, source: .restoration)
            } else {
                try? environment.history.markUnavailable(path: url.standardizedFileURL.path)
            }
        }
        .onChange(of: historySelection) { _, path in
            guard let path,
                  let record = (environment.history.pinnedRecords + environment.history.recentRecords)
                    .first(where: { $0.canonicalPath == path }) else { return }
            openHistoryRecord(record)
        }
        .onChange(of: session.snapshot?.url) { _, url in
            if let url {
                historySelection = url.standardizedFileURL.path
            }
        }
    }

#if DEBUG
    private static var uiTestDocumentURL: URL? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let flag = arguments.firstIndex(of: "--md22-ui-test-document"),
              arguments.indices.contains(flag + 1) else { return nil }
        return URL(fileURLWithPath: arguments[flag + 1])
    }
#endif

    private var commandHandlingView: some View {
        documentRoutingView
        .onReceive(NotificationCenter.default.publisher(for: .md22OpenDocument)) { _ in
            Task { @MainActor in
                guard let url = await environment.router.chooseMarkdownFile() else { return }
                openCurrent(url, source: .openPanel)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .md22NavigateBack)) { _ in
            session.navigateBack()
        }
        .onReceive(NotificationCenter.default.publisher(for: .md22NavigateForward)) { _ in
            session.navigateForward()
        }
        .onReceive(NotificationCenter.default.publisher(for: .md22AddBookmark)) { _ in
            addBookmark()
        }
        .onReceive(NotificationCenter.default.publisher(for: .md22ToggleSearch)) { _ in
            searchPresented = true
        }
    }

    private var searchAndPreferenceView: some View {
        commandHandlingView
        .onChange(of: searchQuery) { _, query in
            searchTask?.cancel()
            searchTask = Task {
                try? await Task.sleep(for: .milliseconds(120))
                guard !Task.isCancelled else { return }
                searchState = await renderer.search(query)
            }
        }
        .onChange(of: session.snapshot?.url) { _, _ in
            searchQuery = ""
            searchState = DocumentSearchState()
        }
    }

    private var layoutCommandView: some View {
        searchAndPreferenceView
        .onReceive(NotificationCenter.default.publisher(for: .md22ToggleHistory)) { _ in
            toggleHistory()
        }
        .onReceive(NotificationCenter.default.publisher(for: .md22ToggleInspector)) { _ in
            toggleInspector()
        }
        .onReceive(NotificationCenter.default.publisher(for: .md22ToggleDistractionFree)) { _ in
            toggleDistractionFree()
        }
    }

    private var windowInteractionView: some View {
        focusCommandView
        .focusedSceneValue(\.md22DocumentActions, focusedDocumentActions)
        .background(BookmarkShortcutMonitor(onAddBookmark: addBookmark, onFind: showSearch))
        .onOpenURL { url in
            openCurrent(url, source: .finder)
        }
        .onDisappear {
            exportTask?.cancel()
            session.cancel()
        }
        .dropDestination(for: URL.self) { urls, _ in
            guard let url = DocumentDropHandler.firstMarkdownURL(in: urls) else {
                session.showTransientMessage(MD22Error.unsupportedFile.localizedDescription)
                return false
            }
            openCurrent(url, source: .drop)
            return true
        } isTargeted: { isTargeted in
            isDropTargeted = isTargeted
        }
    }

    private var focusCommandView: some View {
        layoutCommandView
            .onReceive(NotificationCenter.default.publisher(for: .md22FocusHistory)) { _ in
                guard columnVisibility != .detailOnly else { return }
                focusedRegion = .history
            }
            .onReceive(NotificationCenter.default.publisher(for: .md22FocusDocument)) { _ in
                focusedRegion = nil
                Task { await renderer.focusDocument() }
            }
            .onReceive(NotificationCenter.default.publisher(for: .md22FocusInspector)) { _ in
                guard inspectorPresented else { return }
                focusedRegion = .inspector
            }
            .onReceive(NotificationCenter.default.publisher(for: .md22FocusStatusBar)) { _ in
                guard !isDistractionFree else { return }
                focusedRegion = .statusBar
            }
    }

    private func openHistoryRecord(_ record: HistoryRecord) {
        guard record.isAvailable,
              let url = environment.history.resolvedURL(for: record),
              FileManager.default.isReadableFile(atPath: url.path) else {
            try? environment.history.markUnavailable(path: record.canonicalPath)
            session.showTransientMessage(MD22Error.unavailableFile.localizedDescription)
            return
        }
        guard session.snapshot?.url.standardizedFileURL != url.standardizedFileURL else { return }
        openCurrent(url, source: .history)
    }

    private func revealHistoryRecord(_ record: HistoryRecord) {
        guard record.isAvailable,
              let url = environment.history.resolvedURL(for: record),
              FileManager.default.isReadableFile(atPath: url.path) else {
            try? environment.history.markUnavailable(path: record.canonicalPath)
            session.showTransientMessage(MD22Error.unavailableFile.localizedDescription)
            return
        }
        environment.router.reveal(url)
    }

    private func openBookmark(_ bookmark: BookmarkRecord) {
        let url = URL(fileURLWithPath: bookmark.canonicalPath)
        guard FileManager.default.isReadableFile(atPath: url.path) else {
            session.showTransientMessage(MD22Error.unavailableFile.localizedDescription)
            return
        }
        var destination = url
        if let headingID = bookmark.headingID,
           var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            components.fragment = headingID
            destination = components.url ?? url
        }
        openCurrent(
            destination,
            source: .bookmark,
            bookmarkID: bookmark.id,
            location: bookmark.location,
            usesFragment: bookmark.kind == .heading
        )
    }

    private func openHistoryRecordInNewWindow(_ record: HistoryRecord) {
        guard record.isAvailable,
              let url = environment.history.resolvedURL(for: record),
              FileManager.default.isReadableFile(atPath: url.path) else {
            try? environment.history.markUnavailable(path: record.canonicalPath)
            session.showTransientMessage(MD22Error.unavailableFile.localizedDescription)
            return
        }
        openNewWindow(url, source: .history)
    }

    private func openBookmarkInNewWindow(_ bookmark: BookmarkRecord) {
        let url = URL(fileURLWithPath: bookmark.canonicalPath)
        guard FileManager.default.isReadableFile(atPath: url.path) else {
            session.showTransientMessage(MD22Error.unavailableFile.localizedDescription)
            return
        }
        openNewWindow(
            url,
            source: .bookmark,
            bookmarkID: bookmark.id,
            headingID: bookmark.kind == .heading ? bookmark.headingID : nil,
            location: bookmark.location
        )
    }

    private func openNewWindow(
        _ url: URL,
        source: DocumentRouteSource,
        bookmarkID: UUID? = nil,
        headingID: String? = nil,
        location: ReadingLocation? = nil
    ) {
        do {
            var destination = url
            if let headingID,
               var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                components.fragment = headingID
                destination = components.url ?? url
            }
            let route = try environment.router.route(
                destination,
                source: source,
                disposition: .newWindow,
                bookmarkID: bookmarkID,
                location: location
            )
            openWindow(value: DocumentWindowRequest(route: route))
        } catch {
            session.showTransientMessage(error.localizedDescription)
        }
    }

    private func openCurrent(
        _ url: URL,
        source: DocumentRouteSource,
        bookmarkID: UUID? = nil,
        location: ReadingLocation? = nil,
        usesFragment: Bool = true
    ) {
        do {
            if source != .restoration { didReceiveExplicitOpen = true }
            MD22Log.lifecycle.notice("Document route source: \(source.rawValue, privacy: .public)")
            var destination = url
            if !usesFragment, var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                components.fragment = nil
                destination = components.url ?? url
            }
            let route = try environment.router.route(
                destination,
                source: source,
                bookmarkID: bookmarkID,
                location: location
            )
            openRoute(route)
        } catch {
            session.showTransientMessage(error.localizedDescription)
        }
    }

    private func openRequest(_ request: DocumentWindowRequest) {
        compactPanel = nil
        session.open(
            request.url,
            targetHeadingID: request.headingID,
            targetLocation: request.location,
            emphasizesArrival: request.source == .bookmark
        )
    }

    private func openRoute(_ route: DocumentRoute) {
        compactPanel = nil
        session.open(
            route.url,
            targetHeadingID: route.headingID,
            targetLocation: route.location,
            emphasizesArrival: route.source == .bookmark
        )
    }

    private func previousSearchResult() {
        Task { searchState = await renderer.previousSearchResult(query: searchQuery) }
    }

    private func nextSearchResult() {
        Task { searchState = await renderer.nextSearchResult(query: searchQuery) }
    }

    private func closeSearch() {
        searchTask?.cancel()
        searchPresented = false
        searchQuery = ""
        searchState = DocumentSearchState()
        Task {
            await renderer.clearSearch()
            await renderer.focusDocument()
        }
    }

    private func openMarkdown() {
        Task { @MainActor in
            guard let url = await environment.router.chooseMarkdownFile() else { return }
            openCurrent(url, source: .openPanel)
        }
    }

    private func showSearch() {
        guard session.snapshot != nil else { return }
        compactPanel = nil
        searchFocusID += 1
        searchPresented = true
    }

    private func addBookmark() {
        do {
            if !session.selectedText.isEmpty {
                _ = try session.bookmarkSelection()
            } else {
                _ = try session.bookmarkCurrentHeading()
            }
            session.showTransientMessage("Bookmark added")
        } catch {
            session.showTransientMessage(error.localizedDescription)
        }
    }

    private var focusedDocumentActions: FocusedDocumentActions {
        FocusedDocumentActions(
            canNavigateBack: session.canNavigateBack,
            canNavigateForward: session.canNavigateForward,
            canExport: session.snapshot != nil,
            open: openMarkdown,
            export: retryExport,
            addBookmark: addBookmark,
            navigateBack: session.navigateBack,
            navigateForward: session.navigateForward,
            find: showSearch,
            toggleHistory: toggleHistory,
            toggleInspector: toggleInspector,
            toggleDistractionFree: toggleDistractionFree,
            focusHistory: { focusedRegion = .history },
            focusDocument: {
                focusedRegion = nil
                Task { await renderer.focusDocument() }
            },
            focusInspector: { focusedRegion = .inspector },
            focusStatusBar: { focusedRegion = .statusBar }
        )
    }

    private func exportDocument(format: ExportFormat, theme: DisplayTheme) {
        guard let snapshot = session.snapshot, !session.isExporting else { return }
        environment.preferences.exportFormat = format
        environment.preferences.exportTheme = theme
        exportError = nil
        session.beginExport()
        exportTask?.cancel()
        exportTask = Task { @MainActor in
            do {
                let output: URL
                switch format {
                case .html:
                    output = try await environment.exportService.exportHTML(
                        snapshot: snapshot,
                        renderer: renderer,
                        themeID: theme.rawValue
                    )
                case .pdf:
                    output = try await environment.exportService.exportPDF(
                        snapshot: snapshot,
                        themeID: theme.rawValue
                    )
                }
                try Task.checkCancellation()
                session.finishExport(at: output)
            } catch is CancellationError {
                session.failExport()
            } catch {
                session.failExport()
                exportError = error.localizedDescription
            }
        }
    }

    private func retryExport() {
        exportDocument(
            format: environment.preferences.exportFormat,
            theme: environment.preferences.exportTheme
        )
    }

    private func toggleDistractionFree() {
        withAnimation(environment.accessibility.reduceMotion ? nil : .smooth(duration: 0.22)) {
            if isDistractionFree {
                if let saved = layoutBeforeDistractionFree {
                    columnVisibility = saved.historyVisible ? .all : .detailOnly
                    inspectorPresented = saved.inspectorVisible
                        && !(Self.usesCompactPanelLayout(at: windowWidth) && saved.historyVisible)
                }
                layoutBeforeDistractionFree = nil
                isDistractionFree = false
            } else {
                layoutBeforeDistractionFree = SavedWindowLayout(
                    historyVisible: columnVisibility != .detailOnly,
                    inspectorVisible: inspectorPresented
                )
                isDistractionFree = true
                columnVisibility = .detailOnly
                inspectorPresented = false
            }
        }
    }

    private func toggleHistory() {
        if usesTinyLayout {
            focusedRegion = nil
            compactPanel = compactPanel == .history ? nil : .history
            return
        }
        focusedRegion = nil
        let visible = columnVisibility == .detailOnly
        preferredHistoryVisible = visible
        environment.preferences.showsHistory = visible
        withAnimation(layoutAnimation) {
            columnVisibility = visible ? .all : .detailOnly
            if Self.usesCompactPanelLayout(at: windowWidth) {
                if visible {
                    inspectorPresented = false
                } else if preferredInspectorVisible {
                    inspectorPresented = true
                }
            }
        }
    }

    private func toggleInspector() {
        if usesTinyLayout {
            focusedRegion = nil
            compactPanel = compactPanel == .inspector ? nil : .inspector
            return
        }
        focusedRegion = nil
        let visible = !inspectorPresented
        preferredInspectorVisible = visible
        environment.preferences.showsInspector = visible
        withAnimation(layoutAnimation) {
            inspectorPresented = visible
            if Self.usesCompactPanelLayout(at: windowWidth) {
                if visible {
                    columnVisibility = .detailOnly
                } else if preferredHistoryVisible {
                    columnVisibility = .all
                }
            }
        }
    }

    private func dismissTemporaryPanelsIfNeeded() {
        guard windowWidth < Self.overlayThreshold else { return }
        withAnimation(layoutAnimation) {
            compactPanel = nil
            columnVisibility = .detailOnly
            inspectorPresented = false
        }
    }

    private func restorePreferredPanelVisibility() {
        guard !isDistractionFree else { return }
        if usesTinyLayout {
            columnVisibility = .detailOnly
            inspectorPresented = false
        } else if Self.usesCompactPanelLayout(at: windowWidth)
            && preferredHistoryVisible && preferredInspectorVisible {
            let inspectorWasActive = inspectorPresented && columnVisibility == .detailOnly
            columnVisibility = inspectorWasActive ? .detailOnly : .all
            inspectorPresented = inspectorWasActive
        } else {
            columnVisibility = preferredHistoryVisible ? .all : .detailOnly
            inspectorPresented = preferredInspectorVisible
        }
    }

    private var layoutAnimation: Animation? {
        environment.accessibility.reduceMotion ? nil : .smooth(duration: 0.2)
    }

    private static let overlayThreshold: CGFloat = 960

    private static let tinyLayoutThreshold: CGFloat = 700
    private var usesTinyLayout: Bool {
        Self.usesTinyLayout(at: windowWidth)
    }

    private static func usesTinyLayout(at width: CGFloat) -> Bool {
        width < tinyLayoutThreshold
    }

    private static let compactPanelThreshold: CGFloat = 1_180

    private static func usesCompactPanelLayout(at width: CGFloat) -> Bool {
        if #available(macOS 27.0, *) {
            return width < compactPanelThreshold
        }
        return false
    }

    private var inspectorContent: some View {
        DocumentInspectorView(
            session: session,
            renderer: renderer,
            onOpenBookmark: openBookmark,
            onOpenBookmarkInNewWindow: openBookmarkInNewWindow
        )
        .focusable()
        .focused($focusedRegion, equals: .inspector)
        .focusSection()
    }

    private var compactHeader: some View {
        HStack(spacing: 10) {
            Button(action: toggleHistory) {
                Image(systemName: "sidebar.left")
            }
            .buttonStyle(.borderless)
            .help("Show or hide History")
            Button(action: session.navigateBack) {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(.borderless)
            .disabled(!session.canNavigateBack)
            .help("Go Back")
            Button(action: session.navigateForward) {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.borderless)
            .disabled(!session.canNavigateForward)
            .help("Go Forward")
            Text(session.windowTitle)
                .font(.headline)
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer(minLength: 0)
            Button(action: openMarkdown) {
                Image(systemName: "folder")
            }
            .buttonStyle(.borderless)
            .help("Open Markdown…")
            ExportToolbarControl(
                theme: environment.preferences.exportTheme,
                isExporting: session.isExporting,
                errorMessage: exportError,
                onExport: exportDocument,
                onSelectTheme: { environment.preferences.exportTheme = $0 },
                onRetry: retryExport,
                onDismissError: { exportError = nil }
            )
            .disabled(session.snapshot == nil)
            Button(action: showSearch) {
                Image(systemName: "magnifyingglass")
            }
            .buttonStyle(.borderless)
            .disabled(session.snapshot == nil)
            .help("Find in Document")
            Button(action: toggleInspector) {
                Image(systemName: "sidebar.right")
            }
            .buttonStyle(.borderless)
            .help("Show or hide Outline and Bookmarks")
            Button(action: toggleDistractionFree) {
                Image(systemName: isDistractionFree
                    ? "arrow.down.right.and.arrow.up.left"
                    : "arrow.up.left.and.arrow.down.right")
            }
            .buttonStyle(.borderless)
            .help(isDistractionFree ? "Exit Distraction-Free Reading" : "Enter Distraction-Free Reading")
            tinyActionMenu
        }
        .padding(.horizontal, 10)
        .frame(height: 36)
        .background(.bar)
    }

    private func readerPane(size: CGSize, isTiny: Bool) -> some View {
        let historyWidth: CGFloat = !isTiny && columnVisibility != .detailOnly ? 280 : 0
        let inspectorWidth: CGFloat = !isTiny && inspectorPresented ? 246 : 0
        return ZStack(alignment: .topLeading) {
            // Keep one WebView mounted while panels and the window change size.
            documentContent
                .contentShape(Rectangle())
                .simultaneousGesture(TapGesture().onEnded { dismissTemporaryPanelsIfNeeded() })
                .onExitCommand(perform: dismissTemporaryPanelsIfNeeded)
                .focusSection()
                .frame(width: max(1, size.width - historyWidth - inspectorWidth), height: size.height)
                .offset(x: historyWidth)
                .allowsHitTesting(!isTiny || compactPanel == nil)

            if historyWidth > 0 || (isTiny && compactPanel == .history) {
                HistorySidebarView(
                history: environment.history,
                selection: $historySelection,
                onOpen: openHistoryRecord,
                onOpenInNewWindow: openHistoryRecordInNewWindow,
                onReveal: revealHistoryRecord
                )
                .focusable()
                .focused($focusedRegion, equals: .history)
                .focusSection()
                .frame(width: isTiny ? size.width : historyWidth, height: size.height)
            }
            if inspectorWidth > 0 || (isTiny && compactPanel == .inspector) {
                inspectorContent
                    .frame(width: isTiny ? size.width : inspectorWidth, height: size.height)
                    .offset(x: isTiny ? 0 : size.width - inspectorWidth)
            }
        }
        .frame(width: size.width, height: size.height, alignment: .topLeading)
        .clipped()
    }

    private var tinyActionMenu: some View {
        Menu {
            Button("Document") { compactPanel = nil }
            Button("History") { toggleHistory() }
            Button("Outline and Bookmarks") { toggleInspector() }
            Divider()
            Button("Open Markdown…", action: openMarkdown)
            Button("Back", action: session.navigateBack)
                .disabled(!session.canNavigateBack)
            Button("Forward", action: session.navigateForward)
                .disabled(!session.canNavigateForward)
            Button("Find in Document", action: showSearch)
                .disabled(session.snapshot == nil)
            Menu("Export") {
                Button("HTML") { exportDocument(format: .html, theme: environment.preferences.exportTheme) }
                Button("PDF") { exportDocument(format: .pdf, theme: environment.preferences.exportTheme) }
                Menu("Theme") {
                    ForEach(DisplayTheme.allCases) { theme in
                        Button(theme.title) { environment.preferences.exportTheme = theme }
                    }
                }
            }
            .disabled(session.snapshot == nil || session.isExporting)
            Menu("Document Theme") {
                ForEach(DisplayTheme.allCases) { theme in
                    Button(theme.title) { environment.preferences.displayTheme = theme }
                }
            }
            Divider()
            Button(isDistractionFree ? "Exit Distraction-Free Reading" : "Enter Distraction-Free Reading",
                   action: toggleDistractionFree)
        } label: {
            Image(systemName: "ellipsis.circle")
                .accessibilityLabel("Reader actions")
        }
        .menuStyle(.borderlessButton)
        .accessibilityIdentifier("reader.actions")
    }

    @ViewBuilder
    private var documentContent: some View {
        if let snapshot = session.snapshot, isRendererReady {
            ReadOnlyDocumentView(snapshot: snapshot, session: session, renderer: renderer)
                .overlay(alignment: .top) {
                    if session.showsLoadingIndicator {
                        loadingIndicator
                    }
                }
                .overlay(alignment: .topTrailing) {
                    if searchPresented {
                        SearchToolbarView(
                            query: $searchQuery,
                            state: searchState,
                            onPrevious: previousSearchResult,
                            onNext: nextSearchResult,
                            onClose: closeSearch
                        )
                        .id(searchFocusID)
                        .padding(12)
                    }
                }
        } else if let errorMessage = session.errorMessage {
            ContentUnavailableView(
                "Unable to Open Document",
                systemImage: "exclamationmark.triangle",
                description: Text(errorMessage)
            )
        } else {
            WelcomeView(isDropTargeted: isDropTargeted)
        }
    }

    @ViewBuilder
    private var loadingIndicator: some View {
        let indicator = ProgressView()
            .controlSize(.small)
            .padding(8)
            .accessibilityLabel("Loading document")
        if environment.accessibility.reduceTransparency {
            indicator
                .background(Color(nsColor: .windowBackgroundColor), in: Circle())
                .overlay(Circle().stroke(Color.secondary.opacity(0.45)))
        } else {
            indicator.glassEffect(.regular, in: .circle)
        }
    }
}

private struct SavedWindowLayout {
    let historyVisible: Bool
    let inspectorVisible: Bool
}

private enum WindowFocusRegion: Hashable {
    case history
    case inspector
    case statusBar
}

private enum CompactPanel {
    case history
    case inspector
}

private struct ReaderWindowSizingHook: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView { WindowAttachmentView() }
    func updateNSView(_ nsView: NSView, context: Context) {
        (nsView as? WindowAttachmentView)?.allowCompactSize()
    }

    private final class WindowAttachmentView: NSView {
        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            allowCompactSize()
        }

        func allowCompactSize() {
            guard let window else { return }
            window.contentMinSize = NSSize(width: 200, height: 200)
            window.minSize = NSSize(width: 200, height: 200)
        }
    }
}
