import SwiftUI
import WebKit

struct ReadOnlyDocumentView: View {
    let snapshot: DocumentSnapshot
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
            try? await renderer.render(snapshot: snapshot, themeID: "light")
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
            try? environment.router.route(destination, source: .link)
        } else {
            environment.platform.openExternally(destination)
        }
    }
}
