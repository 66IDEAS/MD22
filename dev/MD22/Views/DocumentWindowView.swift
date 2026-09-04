import SwiftUI

struct DocumentWindowView: View {
    let environment: AppEnvironment
    @State private var session: DocumentSession
    @State private var renderer: WebDocumentRenderer
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var inspectorPresented = true
    @State private var statusBarPresented = true
    @State private var isDistractionFree = false
    @State private var layoutBeforeDistractionFree: SavedWindowLayout?
    @State private var searchPresented = false
    @State private var searchQuery = ""
    @State private var searchState = DocumentSearchState()
    @State private var searchTask: Task<Void, Never>?
    @State private var isDropTargeted = false
    @State private var historySelection: String?
    @State private var didAttemptRestoration = false

    init(environment: AppEnvironment) {
        self.environment = environment
        _session = State(initialValue: DocumentSession(environment: environment))
        _renderer = State(initialValue: WebDocumentRenderer())
        _columnVisibility = State(initialValue: environment.preferences.showsHistory ? .all : .detailOnly)
        _inspectorPresented = State(initialValue: environment.preferences.showsInspector)
        _statusBarPresented = State(initialValue: environment.preferences.showsStatusBar)
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
                    onReveal: revealHistoryRecord
                )
            } detail: {
                documentContent
            }
            .inspector(isPresented: $inspectorPresented) {
                DocumentInspectorView(
                    session: session,
                    renderer: renderer,
                    onOpenBookmark: openBookmark
                )
            }

            if statusBarPresented {
                Divider()
                ReadingStatusBar(session: session)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .frame(minWidth: 760, minHeight: 520)
        .preferredColorScheme(environment.preferences.appAppearance.colorScheme)
        .toolbar {
            ReaderToolbar(
                columnVisibility: $columnVisibility,
                inspectorPresented: $inspectorPresented,
                searchPresented: $searchPresented,
                searchQuery: $searchQuery,
                statusBarPresented: $statusBarPresented,
                isDistractionFree: isDistractionFree,
                onToggleDistractionFree: toggleDistractionFree,
                searchState: searchState,
                onPreviousSearchResult: previousSearchResult,
                onNextSearchResult: nextSearchResult,
                onCloseSearch: closeSearch,
                documentTitle: session.title,
                canNavigateBack: session.canNavigateBack,
                canNavigateForward: session.canNavigateForward,
                canExport: session.snapshot != nil
            )
        }
    }

    private var documentRoutingView: some View {
        windowChromeView
        .onChange(of: environment.router.pendingRoute?.id, initial: true) { _, _ in
            guard let route = environment.router.pendingRoute,
                  route.disposition == .currentWindow else { return }
            session.open(
                route.url,
                targetHeadingID: route.headingID,
                targetLocation: route.location
            )
        }
        .task {
            guard !didAttemptRestoration else { return }
            didAttemptRestoration = true
            guard environment.router.pendingRoute == nil,
                  let url = environment.history.lastDocumentURL else { return }
            if await environment.fileAccess.isAvailable(url) {
                try? environment.router.route(url, source: .restoration)
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
                try? environment.router.route(url, source: .openPanel)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .md22NavigateBack)) { _ in
            session.navigateBack()
        }
        .onReceive(NotificationCenter.default.publisher(for: .md22NavigateForward)) { _ in
            session.navigateForward()
        }
        .onReceive(NotificationCenter.default.publisher(for: .md22AddBookmark)) { _ in
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
        .onChange(of: columnVisibility) { _, visibility in
            guard !isDistractionFree else { return }
            environment.preferences.showsHistory = visibility != .detailOnly
        }
        .onChange(of: inspectorPresented) { _, visible in
            guard !isDistractionFree else { return }
            environment.preferences.showsInspector = visible
        }
        .onChange(of: statusBarPresented) { _, visible in
            guard !isDistractionFree else { return }
            environment.preferences.showsStatusBar = visible
        }
    }

    private var layoutCommandView: some View {
        searchAndPreferenceView
        .onReceive(NotificationCenter.default.publisher(for: .md22ToggleHistory)) { _ in
            columnVisibility = columnVisibility == .detailOnly ? .all : .detailOnly
        }
        .onReceive(NotificationCenter.default.publisher(for: .md22ToggleInspector)) { _ in
            inspectorPresented.toggle()
        }
        .onReceive(NotificationCenter.default.publisher(for: .md22ToggleStatusBar)) { _ in
            statusBarPresented.toggle()
        }
        .onReceive(NotificationCenter.default.publisher(for: .md22ToggleDistractionFree)) { _ in
            toggleDistractionFree()
        }
    }

    private var windowInteractionView: some View {
        layoutCommandView
        .onDisappear { session.cancel() }
        .dropDestination(for: URL.self) { urls, _ in
            guard let url = DocumentDropHandler.firstMarkdownURL(in: urls) else {
                session.showTransientMessage(MD22Error.unsupportedFile.localizedDescription)
                return false
            }
            do {
                try environment.router.route(url, source: .drop)
                return true
            } catch {
                session.showTransientMessage(error.localizedDescription)
                return false
            }
        } isTargeted: { isTargeted in
            isDropTargeted = isTargeted
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
        do {
            try environment.router.route(url, source: .history)
        } catch {
            session.showTransientMessage(error.localizedDescription)
        }
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
        do {
            try environment.router.route(
                destination,
                source: .bookmark,
                bookmarkID: bookmark.id,
                location: bookmark.location
            )
        } catch {
            session.showTransientMessage(error.localizedDescription)
        }
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

    @ViewBuilder
    private var documentContent: some View {
        if let snapshot = session.snapshot {
            ReadOnlyDocumentView(snapshot: snapshot, session: session, renderer: renderer)
                .overlay(alignment: .top) {
                    if session.showsLoadingIndicator {
                        ProgressView()
                            .controlSize(.small)
                            .padding(8)
                            .glassEffect(.regular, in: .circle)
                            .accessibilityLabel("Loading document")
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
}

private struct SavedWindowLayout {
    let historyVisible: Bool
    let inspectorVisible: Bool
    let statusBarVisible: Bool
}
