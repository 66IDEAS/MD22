import SwiftUI
import WebKit

struct ReadOnlyDocumentView: View {
    let snapshot: DocumentSnapshot
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
    }
}
