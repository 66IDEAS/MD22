import SwiftUI

struct DocumentWindowView: View {
    let environment: AppEnvironment
    let initialRequest: DocumentWindowRequest?
    @Environment(\.openWindow) private var openWindow
    @State private var session: DocumentSession
    @State private var renderer: WebDocumentRenderer
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var inspectorPresented = true
    @State private var statusBarPresented = true
    @State private var preferredHistoryVisible = true
    @State private var preferredInspectorVisible = true
    @State private var preferredStatusBarVisible = true
    @State private var windowWidth: CGFloat = 1_240
    @State private var isDistractionFree = false
    @State private var layoutBeforeDistractionFree: SavedWindowLayout?
    @State private var searchPresented = false
    @State private var searchQuery = ""
    @State private var searchState = DocumentSearchState()
    @State private var searchTask: Task<Void, Never>?
    @State private var exportTask: Task<Void, Never>?
    @State private var exportError: String?
    @State private var isDropTargeted = false
    @State private var historySelection: String?
    @State private var didAttemptRestoration = false
    @FocusState private var focusedRegion: WindowFocusRegion?

    init(environment: AppEnvironment, initialRequest: DocumentWindowRequest? = nil) {
        self.environment = environment
        self.initialRequest = initialRequest
        _session = State(initialValue: DocumentSession(environment: environment))
        _renderer = State(initialValue: WebDocumentRenderer())
        _columnVisibility = State(initialValue: environment.preferences.showsHistory ? .all : .detailOnly)
        _inspectorPresented = State(initialValue: environment.preferences.showsInspector)
        _statusBarPresented = State(initialValue: environment.preferences.showsStatusBar)
        _preferredHistoryVisible = State(initialValue: environment.preferences.showsHistory)
        _preferredInspectorVisible = State(initialValue: environment.preferences.showsInspector)
        _preferredStatusBarVisible = State(initialValue: environment.preferences.showsStatusBar)
    }

    var body: some View {
        windowInteractionView
    }

    private var windowChromeView: some View {
        VStack(spacing: 0) {
            NavigationSplitView(columnVisibility: $columnVisibility) {
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
            } detail: {
                documentContent
                    .contentShape(Rectangle())
                    .simultaneousGesture(
                        TapGesture().onEnded { dismissTemporaryPanelsIfNeeded() }
                    )
                    .onExitCommand(perform: dismissTemporaryPanelsIfNeeded)
                    .focusSection()
            }
            .inspector(isPresented: $inspectorPresented) {
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

            if statusBarPresented {
                Divider()
                ReadingStatusBar(session: session)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .focusable()
                    .focused($focusedRegion, equals: .statusBar)
                    .focusSection()
            }
        }
        .frame(minWidth: 760, minHeight: 520)
        .navigationTitle(session.windowTitle)
        .preferredColorScheme(environment.preferences.appAppearance.colorScheme)
        .toolbar {
            ReaderToolbar(
                columnVisibility: $columnVisibility,
                inspectorPresented: $inspectorPresented,
                searchPresented: $searchPresented,
                searchQuery: $searchQuery,
                statusBarPresented: $statusBarPresented,
                isDistractionFree: isDistractionFree,
                onToggleHistory: toggleHistory,
                onToggleInspector: toggleInspector,
                onToggleStatusBar: toggleStatusBar,
                onToggleDistractionFree: toggleDistractionFree,
                onOpen: openMarkdown,
                onNavigateBack: session.navigateBack,
                onNavigateForward: session.navigateForward,
                onSearch: showSearch,
                searchState: searchState,
                onPreviousSearchResult: previousSearchResult,
                onNextSearchResult: nextSearchResult,
                onCloseSearch: closeSearch,
                documentTitle: session.title,
                canNavigateBack: session.canNavigateBack,
                canNavigateForward: session.canNavigateForward,
                canExport: session.snapshot != nil,
                exportFormat: environment.preferences.exportFormat,
                exportTheme: environment.preferences.exportTheme,
                isExporting: session.isExporting,
                exportError: exportError,
                onExport: exportDocument,
                onRetryExport: retryExport,
                onDismissExportError: { exportError = nil }
            )
        }
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
        } action: { oldWidth, newWidth in
            windowWidth = newWidth
            if oldWidth < Self.overlayThreshold, newWidth >= Self.overlayThreshold {
                restorePreferredPanelVisibility()
            }
        }
    }

    private var documentRoutingView: some View {
        windowChromeView
        .task(id: initialRequest?.id) {
            guard !didAttemptRestoration else { return }
            didAttemptRestoration = true
            if let initialRequest {
                openRequest(initialRequest)
                return
            }
            guard let url = environment.history.lastDocumentURL else { return }
            if await environment.fileAccess.isAvailable(url) {
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
        .onReceive(NotificationCenter.default.publisher(for: .md22ToggleStatusBar)) { _ in
            toggleStatusBar()
        }
        .onReceive(NotificationCenter.default.publisher(for: .md22ToggleDistractionFree)) { _ in
            toggleDistractionFree()
        }
    }

    private var windowInteractionView: some View {
        focusCommandView
        .focusedSceneValue(\.md22DocumentActions, focusedDocumentActions)
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
                guard statusBarPresented else { return }
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
        session.open(
            request.url,
            targetHeadingID: request.headingID,
            targetLocation: request.location,
            emphasizesArrival: request.source == .bookmark
        )
    }

    private func openRoute(_ route: DocumentRoute) {
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
            toggleStatusBar: toggleStatusBar,
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
                    statusBarPresented = saved.statusBarVisible
                }
                layoutBeforeDistractionFree = nil
                isDistractionFree = false
            } else {
                layoutBeforeDistractionFree = SavedWindowLayout(
                    historyVisible: columnVisibility != .detailOnly,
                    inspectorVisible: inspectorPresented,
                    statusBarVisible: statusBarPresented
                )
                isDistractionFree = true
                columnVisibility = .detailOnly
                inspectorPresented = false
                statusBarPresented = false
            }
        }
    }

    private func toggleHistory() {
        let visible = columnVisibility == .detailOnly
        preferredHistoryVisible = visible
        environment.preferences.showsHistory = visible
        withAnimation(layoutAnimation) {
            columnVisibility = visible ? .all : .detailOnly
        }
    }

    private func toggleInspector() {
        let visible = !inspectorPresented
        preferredInspectorVisible = visible
        environment.preferences.showsInspector = visible
        withAnimation(layoutAnimation) {
            inspectorPresented = visible
        }
    }

    private func toggleStatusBar() {
        let visible = !statusBarPresented
        preferredStatusBarVisible = visible
        environment.preferences.showsStatusBar = visible
        withAnimation(layoutAnimation) {
            statusBarPresented = visible
        }
    }

    private func dismissTemporaryPanelsIfNeeded() {
        guard windowWidth < Self.overlayThreshold else { return }
        withAnimation(layoutAnimation) {
            columnVisibility = .detailOnly
            inspectorPresented = false
        }
    }

    private func restorePreferredPanelVisibility() {
        guard !isDistractionFree else { return }
        withAnimation(layoutAnimation) {
            columnVisibility = preferredHistoryVisible ? .all : .detailOnly
            inspectorPresented = preferredInspectorVisible
            statusBarPresented = preferredStatusBarVisible
        }
    }

    private var layoutAnimation: Animation? {
        environment.accessibility.reduceMotion ? nil : .smooth(duration: 0.2)
    }

    private static let overlayThreshold: CGFloat = 960

    @ViewBuilder
    private var documentContent: some View {
        if let snapshot = session.snapshot {
            ReadOnlyDocumentView(snapshot: snapshot, session: session, renderer: renderer)
                .overlay(alignment: .top) {
                    if session.showsLoadingIndicator {
                        loadingIndicator
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
    let statusBarVisible: Bool
}

private enum WindowFocusRegion: Hashable {
    case history
    case inspector
    case statusBar
}
