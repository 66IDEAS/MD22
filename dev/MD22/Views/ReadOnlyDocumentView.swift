import SwiftUI
import WebKit

struct ReadOnlyDocumentView: View {
    let snapshot: DocumentSnapshot
    let session: DocumentSession
    let renderer: WebDocumentRenderer
    @Environment(AppEnvironment.self) private var environment
    @State private var bookmarkControlsVisible = false
    @FocusState private var bookmarkControlFocused: Bool

    var body: some View {
        ZStack {
            WebView(renderer.page)
                .webViewTextSelection(.enabled)
                .webViewLinkPreviews(.enabled)
                .webViewBackForwardNavigationGestures(.disabled)
                .webViewContentBackground(.hidden)
                .opacity(renderer.isReady ? 1 : 0)
                .accessibilityLabel("Rendered Markdown document")

            if let error = renderer.renderError {
                ContentUnavailableView(
                    "Unable to Render Document",
                    systemImage: "doc.text.magnifyingglass",
                    description: Text(error)
                )
            } else if !renderer.isReady {
                ProgressView()
                    .controlSize(.small)
                    .accessibilityLabel("Rendering Markdown")
            }

            VStack {
                HStack {
                    Spacer()
                    bookmarkControl
                }
                Spacer()
            }
        }
        .onHover { bookmarkControlsVisible = $0 }
        .task(id: snapshot) {
            do {
                try await renderer.render(snapshot: snapshot, themeID: environment.preferences.displayTheme.rawValue)
                await applyReadingSettings()
                await renderer.restore(session.readingLocation)
                if let headingID = session.navigationTargetHeadingID {
                    await renderer.navigate(to: headingID)
                } else if session.navigationEmphasizesArrival {
                    await renderer.emphasizeCurrentLocation()
                }
                while !Task.isCancelled {
                    if let state = await renderer.viewState() {
                        session.updateRendererState(state)
                    }
                    try await Task.sleep(for: .milliseconds(250))
                }
            } catch {
                guard !Task.isCancelled else { return }
                session.showTransientMessage(error.localizedDescription)
            }
        }
        .onChange(of: renderer.pendingNavigationURL) { _, _ in
            guard let destination = renderer.consumePendingNavigation() else { return }
            handleNavigation(destination)
        }
        .onChange(of: environment.preferences.displayTheme) { _, theme in
            Task { await renderer.applyTheme(theme.rawValue) }
        }
        .onChange(of: environment.preferences.readingSettings) { _, _ in
            Task { await applyReadingSettings() }
        }
        .onChange(of: environment.accessibility.reduceMotion) { _, _ in
            Task { await applyReadingSettings() }
        }
        .onChange(of: environment.accessibility.increaseContrast) { _, _ in
            Task { await applyReadingSettings() }
        }
    }

    private var bookmarkMenu: some View {
        Menu {
            Button("Bookmark Selection") { addBookmark(.passage) }
                .disabled(session.selectedText.isEmpty)
            Button("Bookmark Current Heading") { addBookmark(.heading) }
                .disabled(session.readingLocation.headingID == nil)
            Button("Bookmark Reading Position") { addBookmark(.position) }
        } label: {
            Image(systemName: "bookmark")
                .accessibilityLabel("Add Bookmark")
        }
        .menuStyle(.borderlessButton)
        .padding(10)
        .focused($bookmarkControlFocused)
        .opacity(bookmarkControlsVisible || bookmarkControlFocused ? 1 : 0.28)
        .help("Add Bookmark (Command-D)")
    }

    @ViewBuilder
    private var bookmarkControl: some View {
        if environment.accessibility.reduceTransparency {
            bookmarkMenu
                .background(Color(nsColor: .windowBackgroundColor), in: Circle())
                .overlay(Circle().stroke(Color.secondary.opacity(0.45)))
        } else {
            bookmarkMenu
                .glassEffect(.regular, in: .circle)
        }
    }

    private func applyReadingSettings() async {
        await renderer.applyReadingSettings(
            environment.preferences.readingSettings,
            systemReduceMotion: environment.accessibility.reduceMotion,
            systemHighContrast: environment.accessibility.increaseContrast
        )
    }

    private func handleNavigation(_ destination: URL) {
        if destination.scheme == "md22-action", destination.host == "bookmark" {
            let headingID = URLComponents(url: destination, resolvingAgainstBaseURL: false)?
                .queryItems?.first(where: { $0.name == "heading" })?.value
            guard let headingID else { return }
            do {
                _ = try session.bookmarkHeading(headingID)
                session.showTransientMessage("Bookmark added")
            } catch {
                session.showTransientMessage(error.localizedDescription)
            }
        } else if destination.isFileURL,
           destination.standardizedFileURL.path == snapshot.url.standardizedFileURL.path,
           let fragment = destination.fragment {
            Task { await renderer.navigate(to: fragment) }
        } else if destination.isFileURL, DocumentRouter.accepts(destination) {
            guard FileManager.default.isReadableFile(atPath: destination.path) else {
                session.showTransientMessage("The linked Markdown file is unavailable.")
                return
            }
            let headingID = destination.fragment
            var components = URLComponents(url: destination.standardizedFileURL, resolvingAgainstBaseURL: false)
            components?.fragment = nil
            session.open(components?.url ?? destination.standardizedFileURL, targetHeadingID: headingID)
        } else {
            environment.platform.openExternally(destination)
        }
    }

    private func addBookmark(_ kind: BookmarkKind) {
        do {
            switch kind {
            case .heading: _ = try session.bookmarkCurrentHeading()
            case .passage: _ = try session.bookmarkSelection()
            case .position: _ = try session.bookmarkCurrentPosition()
            }
            session.showTransientMessage("Bookmark added")
        } catch {
            session.showTransientMessage(error.localizedDescription)
        }
    }
}
