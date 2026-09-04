import SwiftUI
import WebKit

struct ReadOnlyDocumentView: View {
    let snapshot: DocumentSnapshot
    let session: DocumentSession
    @Environment(AppEnvironment.self) private var environment
    @State private var renderer = WebDocumentRenderer()

    var body: some View {
        ZStack {
            WebView(renderer.page)
                .webViewTextSelection(.enabled)
                .webViewLinkPreviews(.enabled)
                .webViewBackForwardNavigationGestures(.disabled)
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
        }
        .task(id: snapshot) {
            do {
                try await renderer.render(snapshot: snapshot, themeID: "light")
                await renderer.restore(session.readingLocation)
                if let headingID = session.navigationTargetHeadingID {
                    await renderer.navigate(to: headingID)
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
    }

    private func handleNavigation(_ destination: URL) {
        if destination.isFileURL,
           destination.standardizedFileURL.path == snapshot.url.standardizedFileURL.path,
           let fragment = destination.fragment {
            Task { await renderer.navigate(to: fragment) }
        } else if destination.isFileURL, DocumentRouter.accepts(destination) {
            guard FileManager.default.isReadableFile(atPath: destination.path) else {
                session.showTransientMessage("The linked Markdown file is unavailable.")
                return
            }
            do {
                try environment.router.route(destination, source: .link)
            } catch {
                session.showTransientMessage(error.localizedDescription)
            }
        } else {
            environment.platform.openExternally(destination)
        }
    }
}
