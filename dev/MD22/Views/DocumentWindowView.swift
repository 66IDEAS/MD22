import SwiftUI

struct DocumentWindowView: View {
    let environment: AppEnvironment
    @State private var session: DocumentSession
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var inspectorPresented = true
    @State private var searchPresented = false
    @State private var isDropTargeted = false
    @State private var historySelection: String?

    init(environment: AppEnvironment) {
        self.environment = environment
        _session = State(initialValue: DocumentSession(environment: environment))
    }

    var body: some View {
        VStack(spacing: 0) {
            NavigationSplitView(columnVisibility: $columnVisibility) {
                HistorySidebarView(
                    history: environment.history,
                    selection: $historySelection
                )
            } detail: {
                documentContent
            }
            .inspector(isPresented: $inspectorPresented) {
                DocumentInspectorView()
            }

            Divider()
            ReadingStatusBar()
        }
        .frame(minWidth: 760, minHeight: 520)
        .preferredColorScheme(environment.preferences.appAppearance.colorScheme)
        .toolbar {
            ReaderToolbar(
                columnVisibility: $columnVisibility,
                inspectorPresented: $inspectorPresented,
                searchPresented: $searchPresented,
                documentTitle: session.title,
                canNavigateBack: session.canNavigateBack,
                canNavigateForward: session.canNavigateForward,
                canExport: session.snapshot != nil
            )
        }
        .onChange(of: environment.router.pendingRoute?.id, initial: true) { _, _ in
            guard let route = environment.router.pendingRoute,
                  route.disposition == .currentWindow else { return }
            session.open(route.url)
        }
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
        .overlay(alignment: .top) {
            if let message = session.transientMessage {
                Text(message)
                    .font(.callout)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .glassEffect(.regular, in: .capsule)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    @ViewBuilder
    private var documentContent: some View {
        if let snapshot = session.snapshot {
            ReadOnlyDocumentView(snapshot: snapshot)
                .overlay(alignment: .top) {
                    if session.isLoading { ProgressView().controlSize(.small).padding(8) }
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
